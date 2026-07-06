"""
场景二：靶向知识图谱与发散题卡生成
POST /api/generate-graph
"""

from __future__ import annotations

import json
import logging
from typing import Optional

from fastapi import APIRouter
from pydantic import BaseModel, Field, ValidationError

from .deepseek_client import get_deepseek
from .models import GraphEdge, GraphNode, KnowledgeGraphResponse, QuestionCard

logger = logging.getLogger(__name__)

router = APIRouter()


# ---------------------------------------------------------------------------
# 请求体
# ---------------------------------------------------------------------------

class GenerateGraphRequest(BaseModel):
    textbook_content: str = Field(..., description="教材内容/考纲文本", min_length=10)
    teacher_highlights: str = Field(default="", description="教师标注的重点内容")
    course_name: str = Field(default="", description="课程名称")


# ---------------------------------------------------------------------------
# DeepSeek System Prompt — 知识图谱生成
# ---------------------------------------------------------------------------

KNOWLEDGE_GRAPH_SYSTEM_PROMPT = """\
你是一名顶尖的理工科课程设计师，精通知识体系构建和认知科学。

你的任务：根据用户提供的教材内容（textbook_content）和教师标注重点（teacher_highlights），构建一个多层级知识树图谱。

## 核心要求

1. **多层级知识树**：
   - Level 0: 课程根节点（仅一个）
   - Level 1: 章/大模块
   - Level 2: 节/中模块
   - Level 3: 具体知识点
   每个节点必须有 `parent_id` 指向父节点（根节点 parent_id 为 null）。

2. **交叉比对教师重点**：
   - 如果某个知识点命中教师标注的重点，设置 `is_highlight: true`
   - 命中重点的 **Level 3 节点**，额外生成 3 道发散复习题（`divergent_cards`）

3. **发散题卡生成规则**：
   - 第 1 道：基础概念题（考察对该知识点的直接理解）
   - 第 2 道：综合应用题（将该知识点与其他知识点串联）
   - 第 3 道：易错/变体题（考察对该知识点的深层理解和常见误区）
   - 每题必须包含完整题干、标准答案、考点解析

4. **LaTeX 公式**：
   - 所有理科公式必须使用 LaTeX 语法
   - 行内 `$...$`，独立 `$$...$$`

5. **边（edges）关系**：
   - 父子关系：`child`
   - 前置依赖：`prerequisite`（学 B 前必须先学 A）
   - 关联关系：`related`（两个知识点高度相关）

## JSON 输出格式
```json
{
  "course_name": "课程名",
  "nodes": [
    {
      "id": "root",
      "label": "课程名",
      "level": 0,
      "parent_id": null,
      "importance": "critical",
      "is_highlight": false,
      "summary": "课程概述",
      "divergent_cards": []
    },
    {
      "id": "ch1",
      "label": "第一章 xxx",
      "level": 1,
      "parent_id": "root",
      "importance": "high",
      "is_highlight": false,
      "summary": "本章概述",
      "divergent_cards": []
    },
    {
      "id": "kp_xxx",
      "label": "知识点名",
      "level": 3,
      "parent_id": "sec_xxx",
      "importance": "critical",
      "is_highlight": true,
      "summary": "该知识点一句话概述",
      "divergent_cards": [
        {
          "question": "基础题题干 $LaTeX$",
          "options": [],
          "answer": "答案 $LaTeX$",
          "explanation": "解析 $LaTeX$",
          "related_knowledge": ["知识点A"],
          "difficulty": "easy",
          "common_mistake": "常见错误"
        },
        ...共3道
      ]
    }
  ],
  "edges": [
    {"source_id": "ch1", "target_id": "root", "relation": "child"},
    {"source_id": "kp_xxx", "target_id": "kp_yyy", "relation": "prerequisite"}
  ]
}
```

注意：
- 每个 level 3 节点如果 `is_highlight: true`，必须包含恰好 3 个 divergent_cards
- 如果 `is_highlight: false`，divergent_cards 为空数组 []
- 只输出 JSON，不要有任何其他文字
"""


# ---------------------------------------------------------------------------
# 路由
# ---------------------------------------------------------------------------

@router.post("/generate-graph", response_model=KnowledgeGraphResponse)
async def generate_graph(request: GenerateGraphRequest):
    """
    根据教材内容和教师重点，生成多层级知识树图谱。

    命中重点的知识点将附带 3 道发散复习题。
    """
    # 构造用户提示词
    parts = [f"## 教材内容/考纲\n\n{request.textbook_content}"]

    if request.teacher_highlights.strip():
        parts.append(f"## 教师标注重点\n\n{request.teacher_highlights}")
    else:
        parts.append("## 教师标注重点\n\n（未提供，请根据教材内容自行判断重点）")

    if request.course_name:
        parts.insert(0, f"课程名称：{request.course_name}")

    user_prompt = "\n\n---\n\n".join(parts)

    # 截断保护
    if len(user_prompt) > 80_000:
        user_prompt = user_prompt[:80_000] + "\n\n[内容已截断...]"

    # 调用 DeepSeek
    ds = get_deepseek()
    try:
        result = await ds.chat_json(
            KNOWLEDGE_GRAPH_SYSTEM_PROMPT,
            user_prompt,
            temperature=0.3,
            max_tokens=8192,
        )
    except Exception as exc:
        logger.exception("DeepSeek API 调用失败")
        return KnowledgeGraphResponse(
            success=False,
            error_message=f"AI 图谱生成失败: {str(exc)}",
        )

    # Pydantic 校验
    nodes: list[GraphNode] = []
    errors: list[str] = []

    for item in result.get("nodes", []):
        try:
            # 先提取 divergent_cards 进行单独校验
            raw_cards = item.pop("divergent_cards", [])
            validated_cards: list[QuestionCard] = []
            for card_data in raw_cards:
                try:
                    validated_cards.append(QuestionCard(**card_data))
                except ValidationError:
                    pass  # 跳过无法校验的卡片
            node = GraphNode(**item, divergent_cards=validated_cards)
            nodes.append(node)
        except ValidationError as ve:
            errors.append(f"节点 '{item.get('label', '?')}' 校验失败: {ve.errors()}")

    edges: list[GraphEdge] = []
    for item in result.get("edges", []):
        try:
            edges.append(GraphEdge(**item))
        except ValidationError:
            pass

    if errors:
        logger.warning(f"图谱节点校验警告: {errors}")

    detected_course = result.get("course_name", request.course_name or "未命名课程")

    return KnowledgeGraphResponse(
        success=True,
        course_name=detected_course,
        nodes=nodes,
        edges=edges,
    )
