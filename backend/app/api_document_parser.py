"""
场景一：试卷/题库解析与自动拆卡
POST /api/parse-document
"""

from __future__ import annotations

import json
import logging
import os
import tempfile
from typing import Optional

import base64

from fastapi import APIRouter, File, Form, UploadFile
from pydantic import BaseModel, Field, ValidationError

from .deepseek_client import get_deepseek
from .models import ParseDocumentResponse, QuestionCard

logger = logging.getLogger(__name__)

router = APIRouter()

# ---------------------------------------------------------------------------
# PDF 文本提取
# ---------------------------------------------------------------------------

def _extract_pdf_text(file_path: str) -> str:
    """使用 PyMuPDF 提取 PDF 全文"""
    import fitz  # PyMuPDF — 延迟导入，避免非 PDF 场景下缺少库时报错
    doc = fitz.open(file_path)
    pages: list[str] = []
    for page in doc:
        pages.append(page.get_text())
    doc.close()
    return "\n\n".join(pages)


def _extract_text_file(file_path: str) -> str:
    """提取文本文件内容（自动检测编码）"""
    import chardet
    with open(file_path, "rb") as f:
        raw = f.read()
    detected = chardet.detect(raw)
    encoding = detected.get("encoding", "utf-8") or "utf-8"
    return raw.decode(encoding, errors="replace")


async def _extract_content(file: UploadFile, suffix: str) -> str:
    """将上传文件保存到临时目录并提取文本"""
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        tmp.write(await file.read())
        tmp_path = tmp.name

    try:
        if suffix == ".pdf":
            return _extract_pdf_text(tmp_path)
        else:
            return _extract_text_file(tmp_path)
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass


# ---------------------------------------------------------------------------
# DeepSeek System Prompt — 试卷解析
# ---------------------------------------------------------------------------

PARSE_DOCUMENT_SYSTEM_PROMPT = """\
你是一名顶尖的理工科大学助教，精通高等数学、线性代数、概率论与数理统计、大学物理、电路分析等课程。

你的任务：分析用户提供的试卷或题库文本，完成以下工作，并输出严格的 JSON。

## 核心要求
1. **识别每一道题目**：包括选择题、填空题、计算题、证明题。
2. **自动补充标准答案**：如果原文缺少答案，请根据你的学科知识给出准确的解答。
3. **编写详细考点解析**：解释每一步的推导过程、涉及的定理和公式、常见错误。
4. **公式一律使用 LaTeX**：
   - 行内公式用 `$...$`
   - 独立公式用 `$$...$$`
   - 矩阵、积分、求和、分数、根号等必须用 LaTeX 正确书写
   - 例如：`$P(X=k) = C_n^k p^k (1-p)^{n-k}$`
   - 例如：`$$\\frac{d}{dx}\\int_a^x f(t)dt = f(x)$$`
5. **标注难度**：easy / medium / hard
6. **标注关联知识点**：每道题列出 1-3 个知识点名称
7. **标注常见错误**：学生容易犯的典型错误

## JSON 输出格式
```json
{
  "course_name": "课程名称",
  "cards": [
    {
      "question": "题干...（可含 $LaTeX$）",
      "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
      "answer": "标准答案（可含 $LaTeX$）",
      "explanation": "考点解析与解题思路（可含 $LaTeX$）",
      "related_knowledge": ["知识点1", "知识点2"],
      "difficulty": "medium",
      "common_mistake": "学生常见错误提示"
    }
  ]
}
```

注意：
- 选择题的 `options` 字段必须包含完整选项文本
- 填空题和简答题的 `options` 可以为空数组 []
- 每道题都必须有 `answer` 和 `explanation`，不得遗漏
- 只输出 JSON，不要有任何其他文字
"""


# ---------------------------------------------------------------------------
# 路由
# ---------------------------------------------------------------------------

@router.post("/parse-document", response_model=ParseDocumentResponse)
async def parse_document(
    file: UploadFile = File(..., description="试卷文件（PDF 或 .txt）"),
    course_name: str = Form(default="", description="课程名称（可选，留空则由 AI 自动识别）"),
):
    """
    上传试卷/题库文件，AI 自动拆解为结构化题目卡片。

    支持格式: PDF (.pdf) 和纯文本 (.txt)
    返回: 包含完整题干、答案、解析、知识点的 QuestionCard 列表
    """
    # 1. 校验文件类型
    filename = (file.filename or "upload").lower()
    if filename.endswith(".pdf"):
        suffix = ".pdf"
    elif filename.endswith(".txt"):
        suffix = ".txt"
    else:
        return ParseDocumentResponse(
            success=False,
            error_message=f"不支持的文件格式，请上传 PDF 或 TXT 文件（收到: {filename}）",
        )

    # 2. 提取文本
    try:
        raw_text = await _extract_content(file, suffix)
    except Exception as exc:
        logger.exception("文件文本提取失败")
        return ParseDocumentResponse(
            success=False,
            error_message=f"文件解析失败: {str(exc)}",
        )

    if not raw_text or len(raw_text.strip()) < 10:
        return ParseDocumentResponse(
            success=False,
            error_message="文件内容为空或过短（<10字符），请检查文件",
        )

    # 截断过长文本（DeepSeek 上下文窗口约 128K tokens，留足余量）
    max_chars = 80_000
    if len(raw_text) > max_chars:
        logger.warning(f"文本过长({len(raw_text)}字符)，截断至{max_chars}字符")
        raw_text = raw_text[:max_chars] + "\n\n[文本已截断...]"

    # 3. 构造用户提示词
    course_hint = f"课程名称：{course_name}\n\n" if course_name else "请根据试卷内容自动识别课程名称。\n\n"
    user_prompt = f"{course_hint}请分析以下试卷/题库文本，识别所有题目并输出 JSON：\n\n{raw_text}"

    # 4. 调用 DeepSeek
    ds = get_deepseek()
    try:
        result = await ds.chat_json(
            PARSE_DOCUMENT_SYSTEM_PROMPT,
            user_prompt,
            temperature=0.3,
            max_tokens=8192,
        )
    except Exception as exc:
        logger.exception("DeepSeek API 调用失败")
        return ParseDocumentResponse(
            success=False,
            error_message=f"AI 解析失败: {str(exc)}",
        )

    # 5. Pydantic 校验 & 转换
    cards: list[QuestionCard] = []
    raw_cards = result.get("cards", [])
    for i, item in enumerate(raw_cards):
        try:
            card = QuestionCard(**item)
            cards.append(card)
        except ValidationError as ve:
            logger.warning(f"第{i+1}张卡片校验失败，跳过: {ve.errors()}")

    detected_course = result.get("course_name", course_name or "未命名课程")

    return ParseDocumentResponse(
        success=True,
        course_name=detected_course,
        cards=cards,
        total_count=len(cards),
    )


# ---------------------------------------------------------------------------
# JSON-base64 模式（HarmonyOS 前端兼容路径）
# ---------------------------------------------------------------------------

class ParseDocumentJsonRequest(BaseModel):
    file_name: str = Field(default="document.txt")
    file_content_base64: str = Field(..., description="Base64 编码的文件内容")
    course_name: str = Field(default="")


@router.post("/parse-document-json", response_model=ParseDocumentResponse)
async def parse_document_json(request: ParseDocumentJsonRequest):
    """
    通过 JSON + Base64 上传试卷文件（兼容 ArkTS 前端 multipart 限制）。
    流程与 /parse-document 完全相同。
    """
    # 解码 base64
    try:
        raw_bytes = base64.b64decode(request.file_content_base64)
    except Exception as exc:
        return ParseDocumentResponse(
            success=False,
            error_message=f"Base64 解码失败: {str(exc)}",
        )

    # 检测文件类型
    filename = request.file_name.lower()
    if filename.endswith(".pdf"):
        # PDF → 保存临时文件后用 PyMuPDF 提取
        with tempfile.NamedTemporaryFile(suffix=".pdf", delete=False) as tmp:
            tmp.write(raw_bytes)
            tmp_path = tmp.name
        try:
            raw_text = _extract_pdf_text(tmp_path)
        finally:
            try:
                os.unlink(tmp_path)
            except OSError:
                pass
    else:
        # 文本文件
        import chardet
        detected = chardet.detect(raw_bytes)
        encoding = detected.get("encoding", "utf-8") or "utf-8"
        raw_text = raw_bytes.decode(encoding, errors="replace")

    if not raw_text or len(raw_text.strip()) < 10:
        return ParseDocumentResponse(
            success=False,
            error_message="文件内容为空或过短",
        )

    # 截断保护
    max_chars = 80_000
    if len(raw_text) > max_chars:
        raw_text = raw_text[:max_chars] + "\n\n[文本已截断...]"

    # 构造提示词
    course_hint = f"课程名称：{request.course_name}\n\n" if request.course_name else "请根据试卷内容自动识别课程名称。\n\n"
    user_prompt = f"{course_hint}请分析以下试卷/题库文本，识别所有题目并输出 JSON：\n\n{raw_text}"

    # 调用 DeepSeek
    ds = get_deepseek()
    try:
        result = await ds.chat_json(PARSE_DOCUMENT_SYSTEM_PROMPT, user_prompt, temperature=0.3, max_tokens=8192)
    except Exception as exc:
        logger.exception("DeepSeek API 调用失败")
        return ParseDocumentResponse(success=False, error_message=f"AI 解析失败: {str(exc)}")

    # Pydantic 校验
    cards: list[QuestionCard] = []
    for item in result.get("cards", []):
        try:
            cards.append(QuestionCard(**item))
        except ValidationError as ve:
            logger.warning(f"卡片校验失败，跳过: {ve.errors()}")

    detected_course = result.get("course_name", request.course_name or "未命名课程")

    return ParseDocumentResponse(
        success=True,
        course_name=detected_course,
        cards=cards,
        total_count=len(cards),
    )
