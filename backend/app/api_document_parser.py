"""
场景一：PDF 试卷上传 → PyMuPDF 提取文本 → DeepSeek 拆题卡
POST /api/upload-pdf   (multipart/form-data)
POST /api/upload-text  (multipart/form-data, txt fallback)
"""

from __future__ import annotations

import logging
import os
import tempfile
from typing import Optional

from fastapi import APIRouter, File, Form, UploadFile
from pydantic import ValidationError

from .deepseek_client import get_deepseek
from .models import ParseDocumentResponse, QuestionCard

logger = logging.getLogger(__name__)

router = APIRouter()

# ═══════════════════════════════════════════════════════════════
# PDF 文本提取 — PyMuPDF (fitz)
# ═══════════════════════════════════════════════════════════════

def _extract_pdf(file_path: str, original_filename: str) -> str:
    """用 PyMuPDF 逐页提取文本；遇不可读内容时记录警告并跳过。"""
    import fitz
    doc: Optional[fitz.Document] = None
    pages_out: list[str] = []
    try:
        doc = fitz.open(file_path)
        total = len(doc)
        for i, page in enumerate(doc, start=1):
            try:
                text: str = page.get_text()
                if text.strip():
                    pages_out.append(text)
                else:
                    logger.warning(f"第 {i}/{total} 页无文字内容")
            except Exception as e:
                logger.warning(f"第 {i}/{total} 页提取异常: {e}")
    except Exception as e:
        raise RuntimeError(f"PyMuPDF 无法打开文件「{original_filename}」: {e}") from e
    finally:
        if doc is not None:
            try:
                doc.close()
            except Exception:
                pass

    if not pages_out:
        raise RuntimeError(f"文件「{original_filename}」未提取到任何文本，请确认 PDF 不是纯图片扫描件")

    return "\n\n".join(pages_out)


def _extract_text_file(file_path: str) -> str:
    """读取纯文本文件，自动检测编码。"""
    try:
        import chardet
        with open(file_path, "rb") as fh:
            raw = fh.read()
        det = chardet.detect(raw)
        enc = det.get("encoding", "utf-8") or "utf-8"
        return raw.decode(enc, errors="replace")
    except ImportError:
        # 无 chardet 时回退 utf-8
        with open(file_path, "r", encoding="utf-8", errors="replace") as fh:
            return fh.read()


# ═══════════════════════════════════════════════════════════════
# DeepSeek System Prompt — 试卷拆题
# ═══════════════════════════════════════════════════════════════

PARSE_SYSTEM_PROMPT = """\
你是一名严谨的理工科大学助教，负责批改和整理试卷。你需要分析以下试卷/题库文本，完成：

## 任务
1. 识别每一道题目（选择题、填空题、计算题、证明题）
2. 给每道题写出**完整的标准解答**（步骤清晰、推导严谨）
3. 给每道题编写**详细的考点解析**，解释涉及的定理、公式、典型错误
4. 标注题目难度、关联知识点、常见错误

## 核心规则
- **公式全部用 LaTeX**：行内用 `$...$`，独立公式用 `$$...$$`
  - 正确示例：`$P(X=k)=C_n^k p^k(1-p)^{n-k}$`
  - 正确示例：`$$\\oint \\vec{E}\\cdot d\\vec{A}=\\frac{Q}{\\varepsilon_0}$$`
  - 矩阵、积分、极限、导数、根号、分数等必须用 LaTeX
- **每道题必须给出答案**，即使原文只写了题目没写答案
- **解析必须解释「为什么」**，不只是重复答案
- 选择题的 options 数组要包含完整的 A/B/C/D 选项文本

## JSON 输出格式
{
  "course_name": "根据试卷内容推断的课程名",
  "cards": [
    {
      "question": "题干（可含 $LaTeX$）",
      "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
      "answer": "标准答案（含推导过程，$LaTeX$）",
      "explanation": "考点解析与解题思路（$LaTeX$）",
      "related_knowledge": ["知识点1", "知识点2"],
      "difficulty": "medium",
      "common_mistake": "学生易犯错误"
    }
  ]
}

只输出 JSON，不要输出任何其他文本。"""


# ═══════════════════════════════════════════════════════════════
# 上传解析路由
# ═══════════════════════════════════════════════════════════════

async def _save_and_extract(file: UploadFile, suffix: str) -> str:
    """把上传文件落到临时目录，提取文本后清理。"""
    raw_bytes: bytes = await file.read()
    if not raw_bytes:
        raise RuntimeError("上传文件为空")

    fd, tmp_path = tempfile.mkstemp(suffix=suffix)
    try:
        with os.fdopen(fd, "wb") as fh:
            fh.write(raw_bytes)

        if suffix == ".pdf":
            return _extract_pdf(tmp_path, file.filename or "upload.pdf")
        else:
            return _extract_text_file(tmp_path)
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass


async def _call_ai_and_parse(extracted_text: str, course_hint: str) -> ParseDocumentResponse:
    """调用 DeepSeek → Pydantic 校验 → 返回 ParseDocumentResponse。"""
    # 截断保护（128K 窗口留足余量）
    max_len = 80_000
    if len(extracted_text) > max_len:
        logger.info(f"文本过长 ({len(extracted_text)} 字符)，截断至 {max_len}")
        extracted_text = extracted_text[:max_len] + "\n\n[因长度限制，后续内容已截断]"

    user_prompt = f"{course_hint}请分析以下试卷文本，识别题目并输出 JSON：\n\n{extracted_text}"

    ds = get_deepseek()
    result = await ds.chat_json(PARSE_SYSTEM_PROMPT, user_prompt, temperature=0.3, max_tokens=8192)

    cards: list[QuestionCard] = []
    for item in result.get("cards", []):
        try:
            cards.append(QuestionCard(**item))
        except ValidationError as ve:
            logger.warning(f"单张卡片校验失败，跳过: {ve.errors()}")

    course_name = result.get("course_name", course_hint.replace("课程名称：", "") or "未命名课程")

    return ParseDocumentResponse(
        success=True,
        course_name=course_name,
        cards=cards,
        total_count=len(cards),
    )


@router.post("/upload-pdf", response_model=ParseDocumentResponse)
async def upload_pdf(
    file: UploadFile = File(..., description="PDF 文件"),
    course_name: str = Form(default="", description="课程名称（可选，AI 自动识别）"),
):
    """
    上传 PDF 试卷/题库文件，AI 自动拆解为结构化题目卡片。

    - 后端使用 PyMuPDF 逐页提取文本
    - DeepSeek 识别题目 → 补全答案 → 编写解析 → 输出 JSON
    - 所有公式强制使用 LaTeX
    """
    filename: str = (file.filename or "upload").lower()
    if not filename.endswith(".pdf"):
        return ParseDocumentResponse(
            success=False,
            error_message=f"请上传 PDF 文件（收到: {filename}）",
        )

    try:
        extracted_text = await _save_and_extract(file, suffix=".pdf")
    except Exception as exc:
        logger.exception("PDF 文本提取失败")
        return ParseDocumentResponse(success=False, error_message=str(exc))

    if len(extracted_text.strip()) < 20:
        return ParseDocumentResponse(
            success=False,
            error_message="提取的文本过短（<20字符）。该 PDF 可能是扫描图片，建议先用 OCR 处理。",
        )

    course_hint = f"课程名称：{course_name.strip()}\n\n" if course_name.strip() else "请根据试卷内容自动识别课程名称。\n\n"

    try:
        return await _call_ai_and_parse(extracted_text, course_hint)
    except Exception as exc:
        logger.exception("AI 解析失败")
        return ParseDocumentResponse(success=False, error_message=f"AI 解析出错: {str(exc)}")


@router.post("/upload-text", response_model=ParseDocumentResponse)
async def upload_text(
    file: UploadFile = File(..., description="TXT 文件"),
    course_name: str = Form(default="", description="课程名称（可选）"),
):
    """上传 TXT 题库文件（与 upload-pdf 逻辑相同，仅跳过 PDF 提取步骤）。"""
    filename: str = (file.filename or "upload").lower()
    if not filename.endswith(".txt"):
        return ParseDocumentResponse(
            success=False,
            error_message=f"请上传 .txt 文本文件（收到: {filename}）",
        )

    try:
        extracted_text = await _save_and_extract(file, suffix=".txt")
    except Exception as exc:
        return ParseDocumentResponse(success=False, error_message=str(exc))

    course_hint = f"课程名称：{course_name.strip()}\n\n" if course_name.strip() else "请根据试卷内容自动识别课程名称。\n\n"

    try:
        return await _call_ai_and_parse(extracted_text, course_hint)
    except Exception as exc:
        return ParseDocumentResponse(success=False, error_message=f"AI 解析出错: {str(exc)}")


# ── 保留旧兼容端点（JSON-base64 模式）──────────────────────────

import base64 as _base64
from pydantic import BaseModel as _BaseModel, Field as _Field


class _ParseDocumentJsonRequest(_BaseModel):
    file_name: str = _Field(default="document.txt")
    file_content_base64: str = _Field(..., description="Base64 编码的文件内容")
    course_name: str = _Field(default="")


@router.post("/parse-document-json", response_model=ParseDocumentResponse)
async def parse_document_json(request: _ParseDocumentJsonRequest):
    """JSON-base64 兼容端点（用于不支持 multipart 的场景）。"""
    try:
        raw = _base64.b64decode(request.file_content_base64)
    except Exception as e:
        return ParseDocumentResponse(success=False, error_message=f"Base64 解码失败: {e}")

    fn = request.file_name.lower()
    if fn.endswith(".pdf"):
        fd, tp = tempfile.mkstemp(suffix=".pdf")
        try:
            with os.fdopen(fd, "wb") as f:
                f.write(raw)
            text = _extract_pdf(tp, request.file_name)
        finally:
            try:
                os.unlink(tp)
            except OSError:
                pass
    else:
        try:
            import chardet
            det = chardet.detect(raw)
            enc = det.get("encoding", "utf-8") or "utf-8"
            text = raw.decode(enc, errors="replace")
        except ImportError:
            text = raw.decode("utf-8", errors="replace")

    ch = f"课程名称：{request.course_name}\n\n" if request.course_name else "请根据试卷内容自动识别课程名称。\n\n"
    return await _call_ai_and_parse(text, ch)
