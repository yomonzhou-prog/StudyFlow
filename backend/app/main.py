"""
StudyFlow OS — FastAPI 应用入口
启动: uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
"""

from __future__ import annotations

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api_document_parser import router as document_router
from .api_knowledge_graph import router as graph_router
from .api_study_planner import router as planner_router
from .deepseek_client import get_deepseek
from .models import HealthResponse

# ── 应用实例 ──────────────────────────────────

app = FastAPI(
    title="StudyFlow OS API",
    description="面向理工科大学生的期末复习后端服务",
    version="3.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS（允许 HarmonyOS 应用访问） ────────────

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── 注册路由 ──────────────────────────────────

app.include_router(document_router, prefix="/api", tags=["Document Parser"])
app.include_router(graph_router, prefix="/api", tags=["Knowledge Graph"])
app.include_router(planner_router, prefix="/api", tags=["Study Planner"])


# ── 健康检查 ──────────────────────────────────

@app.get("/api/health", response_model=HealthResponse)
async def health_check():
    ds = get_deepseek()
    available = await ds.ping()
    return HealthResponse(deepseek_available=available)


# ── 启动入口 ──────────────────────────────────

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
