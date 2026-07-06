"""
StudyFlow OS — DeepSeek API 封装客户端
所有后端 Agent 统一通过此模块调用 DeepSeek，不直接使用 httpx
"""

from __future__ import annotations

import json
import os
import re
from typing import Optional

import httpx

# ---------------------------------------------------------------------------
# 配置（通过环境变量注入，未设置时回退到硬编码开发密钥）
# ---------------------------------------------------------------------------
DEEPSEEK_API_URL: str = os.getenv(
    "DEEPSEEK_API_URL",
    "https://api.deepseek.com/v1/chat/completions",
)
DEEPSEEK_API_KEY: str = os.getenv(
    "DEEPSEEK_API_KEY",
    "sk-7b9291e6c67942baa11b6748eb09a32b",
)
DEEPSEEK_MODEL: str = os.getenv("DEEPSEEK_MODEL", "deepseek-chat")
HTTP_TIMEOUT: float = float(os.getenv("DEEPSEEK_HTTP_TIMEOUT", "90.0"))


# ---------------------------------------------------------------------------
# 客户端
# ---------------------------------------------------------------------------

class DeepSeekClient:
    """单例 DeepSeek HTTP 客户端"""

    _instance: Optional["DeepSeekClient"] = None

    def __init__(self) -> None:
        self._client: Optional[httpx.AsyncClient] = None

    @classmethod
    def get_instance(cls) -> "DeepSeekClient":
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None:
            self._client = httpx.AsyncClient(timeout=HTTP_TIMEOUT)
        return self._client

    # ------------------------------------------------------------------
    # 核心调用
    # ------------------------------------------------------------------

    async def chat_json(
        self,
        system_prompt: str,
        user_prompt: str,
        *,
        temperature: float = 0.3,
        max_tokens: int = 8192,
    ) -> dict:
        """
        发送 chat 请求并强制返回 JSON 对象。
        内部处理 JSON 解析、markdown code-block 剥离、截断修复。
        失败时抛出 RuntimeError。
        """
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ]
        raw = await self._raw_chat(messages, temperature, max_tokens, response_format="json_object")
        return self._parse_json_response(raw)

    async def chat_text(
        self,
        system_prompt: str,
        user_prompt: str,
        *,
        temperature: float = 0.7,
        max_tokens: int = 4096,
    ) -> str:
        """
        发送 chat 请求并返回纯文本（场景三教练对话等）。
        """
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ]
        raw = await self._raw_chat(messages, temperature, max_tokens, response_format="text")
        return raw

    async def chat_with_history(
        self,
        system_prompt: str,
        history: list[dict],
        *,
        temperature: float = 0.7,
        max_tokens: int = 4096,
        response_format: str = "text",
    ) -> str:
        """
        多轮对话：在 system_prompt 后拼接 history。
        history: [{"role":"user"/"assistant","content":"..."}]
        """
        messages = [{"role": "system", "content": system_prompt}] + history
        raw = await self._raw_chat(messages, temperature, max_tokens, response_format=response_format)
        if response_format == "json_object":
            parsed = self._parse_json_response(raw)
            return json.dumps(parsed, ensure_ascii=False)
        return raw

    # ------------------------------------------------------------------
    # 内部实现
    # ------------------------------------------------------------------

    async def _raw_chat(
        self,
        messages: list[dict],
        temperature: float,
        max_tokens: int,
        response_format: str,
    ) -> str:
        client = await self._get_client()
        body: dict = {
            "model": DEEPSEEK_MODEL,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
        }
        if response_format == "json_object":
            body["response_format"] = {"type": "json_object"}

        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {DEEPSEEK_API_KEY}",
        }

        resp = await client.post(DEEPSEEK_API_URL, json=body, headers=headers)

        if resp.status_code != 200:
            detail = resp.text[:500]
            raise RuntimeError(f"DeepSeek API HTTP {resp.status_code}: {detail}")

        data = resp.json()
        content: str = data.get("choices", [{}])[0].get("message", {}).get("content", "")
        if not content:
            raise RuntimeError("DeepSeek returned empty content")
        return content

    @staticmethod
    def _parse_json_response(raw: str) -> dict:
        """从 AI 返回中提取合法 JSON 对象"""
        # 去除 markdown 代码块包裹
        cleaned = re.sub(r"^```(?:json)?\s*", "", raw.strip())
        cleaned = re.sub(r"\s*```$", "", cleaned)

        # 尝试直接解析
        try:
            return json.loads(cleaned)
        except json.JSONDecodeError:
            pass

        # 尝试匹配第一个 {...} 块（处理 AI 偶尔多输出的情况）
        match = re.search(r"\{.*\}", cleaned, re.DOTALL)
        if match:
            try:
                return json.loads(match.group(0))
            except json.JSONDecodeError:
                pass

        # 尝试修复常见错误：尾部多余逗号
        fixed = re.sub(r",\s*([}\]])", r"\1", cleaned)
        try:
            return json.loads(fixed)
        except json.JSONDecodeError:
            pass

        raise RuntimeError(f"Failed to parse JSON from DeepSeek response: {raw[:300]}...")

    # ------------------------------------------------------------------
    # 健康检查
    # ------------------------------------------------------------------

    async def ping(self) -> bool:
        """发送最小请求验证 API Key 可用"""
        try:
            await self.chat_text("You are a helpful assistant.", "Reply with just 'pong'.")
            return True
        except Exception:
            return False


# ---------------------------------------------------------------------------
# 便捷函数（供路由直接使用）
# ---------------------------------------------------------------------------

def get_deepseek() -> DeepSeekClient:
    return DeepSeekClient.get_instance()
