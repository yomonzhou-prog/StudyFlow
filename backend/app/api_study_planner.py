"""
场景三：无资料盲考的智能规划教练
POST /api/chat-planner
"""

from __future__ import annotations

import json
import logging
from typing import Optional

from fastapi import APIRouter
from pydantic import ValidationError

from .deepseek_client import get_deepseek
from .models import PlannerChatRequest, PlannerChatResponse, StudyTaskItem

logger = logging.getLogger(__name__)

router = APIRouter()


# ---------------------------------------------------------------------------
# System Prompt — 严厉但科学的规划导师
# ---------------------------------------------------------------------------

PLANNER_SYSTEM_PROMPT = """\
你是一位名叫"严教授"的学习规划导师。你以严厉、科学、高效著称，曾帮助数千名理工科大学生在期末考试中取得优异成绩。

## 你的性格
- 直接、不废话、不说套话
- 用数据和逻辑说话
- 对懒惰和拖延零容忍，但真心为学生的进步感到高兴
- 偶尔用幽默的讽刺激励学生（如"你昨天只学了20分钟？蚂蚁搬家的效率都比你高。"）

## 你的核心方法论
1. **倒推规划**：从考试日期往前倒推，把大目标拆解为每天可执行的小任务
2. **二八法则**：优先攻克占分80%的核心知识点
3. **间隔重复**：每天的任务包含新学+复习，确保记忆曲线最优化
4. **靶向打击**：针对薄弱点布置额外练习，不做无用功

## 对话流程

### 第一轮：收集信息
如果学生还没有提供以下信息，请逐项询问（不要一次全问，自然对话）：
- 课程名称
- 考试日期（计算剩余天数）
- 每天可投入的学习时间
- 已知的薄弱知识点或章节
- 手头有什么资料（教材、PPT、往年试卷等）

### 第二轮及以后：输出计划
当信息收集充分后，输出一个 JSON 格式的每日复习计划。

## 每日计划 JSON 格式
当你确认考纲和用户时间后，在回复末尾附加以下 JSON（用 ```json ``` 包裹）：

```json
{
  "summary": "本轮规划总结（一句话）",
  "daily_tasks": [
    {
      "day_index": 1,
      "date_label": "第1天·7月8日",
      "title": "任务标题",
      "description": "任务详细描述（可含 $LaTeX$）",
      "course_name": "课程名",
      "estimated_minutes": 45,
      "priority": "high",
      "knowledge_points": ["知识点1", "知识点2"],
      "tip": "学习方法提示"
    }
  ]
}
```

## 注意事项
- 所有数学/物理公式使用 LaTeX：行内 `$...$`，独立 `$$...$$`
- 计划中的 estimated_minutes 总和应接近学生每天的可用时间
- 优先安排高频考点和学生的薄弱点
- 每天留 5-10 分钟缓冲时间
- 考前最后 2 天以回顾错题和模拟为主
- 如果学生说"今天不想学"，严厉但温和地鼓励他们至少完成最小任务量（15分钟）
"""

# ---------------------------------------------------------------------------
# 路由
# ---------------------------------------------------------------------------

@router.post("/chat-planner", response_model=PlannerChatResponse)
async def chat_planner(request: PlannerChatRequest):
    """
    与 AI 学习规划教练进行多轮对话。

    首轮传入课程名、考试日期等信息；后续轮次传入对话历史。
    当 AI 确认考纲后，会自动返回结构化的每日 StudyTask 列表。
    """
    ds = get_deepseek()

    # 构造上下文提示词（首轮信息注入）
    context_parts: list[str] = []

    if request.course_name:
        context_parts.append(f"学生正在准备 **{request.course_name}** 的期末考试。")

    if request.exam_date:
        context_parts.append(f"考试日期为 **{request.exam_date}**。")

    if request.available_days > 0:
        context_parts.append(f"距离考试还有 **{request.available_days}** 天。")

    if request.daily_hours > 0:
        context_parts.append(f"学生每天可投入 **{request.daily_hours}** 小时学习。")

    if request.known_weaknesses:
        weak_list = "、".join(request.known_weaknesses)
        context_parts.append(f"学生自述薄弱知识点：{weak_list}。")

    # 构造完整 system prompt
    system_prompt = PLANNER_SYSTEM_PROMPT
    if context_parts:
        system_prompt += "\n\n## 当前学生的已知信息\n" + "\n".join(f"- {p}" for p in context_parts)

    # 构造对话历史
    history: list[dict] = []
    for h in request.history:
        role = h.get("role", "user")
        content = h.get("content", "")
        if role in ("user", "assistant") and content:
            history.append({"role": role, "content": content})

    # 添加当前用户消息
    history.append({"role": "user", "content": request.message})

    # 调用 DeepSeek（文本模式，非 JSON 模式——因为 AI 回复是自然语言 + 末尾 JSON）
    try:
        raw_reply = await ds.chat_with_history(
            system_prompt,
            history,
            temperature=0.7,
            max_tokens=4096,
            response_format="text",
        )
    except Exception as exc:
        logger.exception("DeepSeek API 调用失败")
        return PlannerChatResponse(
            success=False,
            session_id=request.session_id,
            reply=f"抱歉，AI 服务暂时不可用。错误信息：{str(exc)}",
            error_message=str(exc),
        )

    # 尝试从回复末尾提取 JSON 计划
    daily_tasks: list[StudyTaskItem] = []
    summary = ""

    # 查找 ```json ... ``` 块
    import re
    json_match = re.search(r"```json\s*(.*?)\s*```", raw_reply, re.DOTALL)
    if json_match:
        try:
            plan_data = json.loads(json_match.group(1))
            summary = plan_data.get("summary", "")

            for item in plan_data.get("daily_tasks", []):
                try:
                    task = StudyTaskItem(**item)
                    daily_tasks.append(task)
                except ValidationError as ve:
                    logger.warning(f"StudyTaskItem 校验失败: {ve.errors()}")
        except json.JSONDecodeError as je:
            logger.warning(f"AI 返回的计划 JSON 解析失败: {je}")

    # 从回复中移除 JSON 块，保留纯文本
    clean_reply = re.sub(r"```json\s*.*?\s*```", "", raw_reply, flags=re.DOTALL).strip()

    return PlannerChatResponse(
        success=True,
        session_id=request.session_id,
        reply=clean_reply,
        daily_tasks=daily_tasks,
        summary=summary,
    )
