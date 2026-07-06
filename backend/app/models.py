"""
StudyFlow OS — 共享 Pydantic 数据模型
前后端通信统一使用这些模型进行 JSON 序列化/反序列化与校验
"""

from __future__ import annotations

from datetime import datetime
from typing import Optional
from uuid import uuid4

from pydantic import BaseModel, Field, field_validator


# ──────────────────────────────────────────────
# 基础工具
# ──────────────────────────────────────────────

def _new_id() -> str:
    return uuid4().hex[:12]


def _now() -> str:
    return datetime.now().isoformat()


# ──────────────────────────────────────────────
# 题目卡片（场景一核心产出）
# ──────────────────────────────────────────────

class QuestionCard(BaseModel):
    """一道完整的复习题目卡片，由 AI 解析试卷后产出"""
    id: str = Field(default_factory=_new_id)
    course_name: str = Field(..., description="所属课程名称")
    question: str = Field(..., description="题干，可包含 LaTeX 公式 ($...$ 或 $$...$$)")
    options: list[str] = Field(default_factory=list, description="选项列表（选择题），填空/简答可为空")
    answer: str = Field(..., description="标准答案，可包含 LaTeX")
    explanation: str = Field(..., description="详细考点解析与解题思路，可包含 LaTeX")
    related_knowledge: list[str] = Field(default_factory=list, description="关联知识点名称列表")
    difficulty: str = Field(default="medium", description="难度: easy / medium / hard")
    common_mistake: str = Field(default="", description="常见错误提示")
    source_paper_id: str = Field(default="", description="来源试卷ID")
    created_at: str = Field(default_factory=_now)

    @field_validator("difficulty")
    @classmethod
    def _check_difficulty(cls, v: str) -> str:
        if v not in ("easy", "medium", "hard"):
            raise ValueError(f"difficulty must be easy/medium/hard, got '{v}'")
        return v


class ParseDocumentResponse(BaseModel):
    """场景一 API 返回体"""
    success: bool
    course_name: str = ""
    cards: list[QuestionCard] = Field(default_factory=list)
    total_count: int = 0
    error_message: str = ""


# ──────────────────────────────────────────────
# 知识图谱（场景二核心产出）
# ──────────────────────────────────────────────

class GraphNode(BaseModel):
    """知识树中的一个节点"""
    id: str = Field(default_factory=_new_id)
    label: str = Field(..., description="知识点名称")
    level: int = Field(default=0, description="层级深度: 0=根, 1=章, 2=节, 3=点")
    parent_id: Optional[str] = Field(default=None)
    importance: str = Field(default="medium", description="critical / high / medium / low")
    is_highlight: bool = Field(default=False, description="是否命中教师重点")
    summary: str = Field(default="", description="该知识点一句话摘要")

    # 发散题卡：命中重点时 AI 额外生成的 3 道复习题
    divergent_cards: list[QuestionCard] = Field(default_factory=list)


class GraphEdge(BaseModel):
    """知识节点之间的边"""
    source_id: str
    target_id: str
    relation: str = Field(default="child", description="child / prerequisite / related")


class KnowledgeGraphResponse(BaseModel):
    """场景二 API 返回体"""
    success: bool
    course_name: str = ""
    nodes: list[GraphNode] = Field(default_factory=list)
    edges: list[GraphEdge] = Field(default_factory=list)
    error_message: str = ""


# ──────────────────────────────────────────────
# 学习规划（场景三核心产出）
# ──────────────────────────────────────────────

class StudyTaskItem(BaseModel):
    """每日细化学习任务"""
    id: str = Field(default_factory=_new_id)
    day_index: int = Field(..., description="第 N 天 (从1开始)")
    date_label: str = Field(default="", description="日期标签如 '第1天·7月8日'")
    title: str = Field(..., description="任务标题")
    description: str = Field(default="", description="任务详细描述")
    course_name: str = Field(default="")
    estimated_minutes: int = Field(default=30, description="预计耗时(分钟)")
    priority: str = Field(default="medium", description="high / medium / low")
    knowledge_points: list[str] = Field(default_factory=list, description="涉及知识点")
    status: str = Field(default="pending", description="pending / in_progress / completed")
    tip: str = Field(default="", description="学习方法提示")


class PlannerChatRequest(BaseModel):
    """场景三 对话请求"""
    session_id: str = Field(default_factory=_new_id, description="会话ID，用于多轮对话")
    message: str = Field(..., description="用户消息")
    # 上下文信息（首轮填写，后续可为空）
    course_name: str = Field(default="")
    exam_date: str = Field(default="", description="考试日期 YYYY-MM-DD")
    available_days: int = Field(default=0, description="距离考试还有多少天")
    daily_hours: float = Field(default=2.0, description="每天可投入小时数")
    known_weaknesses: list[str] = Field(default_factory=list, description="已知薄弱知识点")
    # 对话历史（前端维护，每次全量传入）
    history: list[dict] = Field(default_factory=list, description="[{\"role\":\"user\"/\"assistant\",\"content\":\"...\"}]")


class PlannerChatResponse(BaseModel):
    """场景三 API 返回体"""
    success: bool
    session_id: str = ""
    reply: str = Field(default="", description="AI 教练的文字回复，可包含 LaTeX")
    # 当 AI 确认考纲后生成的每日计划
    daily_tasks: list[StudyTaskItem] = Field(default_factory=list)
    # 本轮总结
    summary: str = Field(default="", description="本轮规划摘要")
    error_message: str = ""


# ──────────────────────────────────────────────
# 通用
# ──────────────────────────────────────────────

class HealthResponse(BaseModel):
    status: str = "ok"
    version: str = "3.1.0"
    deepseek_available: bool = False
