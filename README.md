# StudyFlow OS

## 基于 HarmonyOS NEXT 与 DeepSeek V4 的大学生学习任务操作系统

### 📖 项目简介

StudyFlow OS 是一个面向大学生的智能学习任务操作系统。它不是一个简单的 AI 聊天 App，也不是待办软件，而是围绕"课程理解 → 知识结构化 → 任务拆解 → 复习检测 → 反馈再规划"构建的完整学习闭环。

**核心闭环：**
```
课程资料输入 → DeepSeek 课程理解 → 知识点结构化
→ 学习任务拆解 → 复习卡片生成 → 自测反馈 → 二次复习规划
```

### 🎯 功能特性

- **学习驾驶舱**：今日任务、即将截止、薄弱知识点、复习卡片一目了然
- **课程资料输入**：支持 6 种类型（PPT/教材/通知/作业/考试范围/错题）的文本输入
- **AI 课程解析**：DeepSeek 自动分析课程内容，生成摘要、章节结构、知识点、考试重点
- **知识点结构化**：按章节分组展示，标注重要程度和难度
- **复习卡片系统**：包含知识点解释、重点提醒、常见错误、自测题和答案解析
- **自测反馈闭环**：已掌握/还模糊/做错了 → 自动生成二次复习计划
- **复习计划再规划**：基于反馈动态调整学习优先级
- **Mock 兜底机制**：API Key 缺失或网络失败时自动使用内置示例数据

### 🏗️ 技术架构

| 层级 | 技术 |
|------|------|
| 开发语言 | ArkTS |
| UI 框架 | ArkUI 声明式 |
| 操作系统 | HarmonyOS NEXT |
| AI 模型 | DeepSeek V4 (deepseek-chat) |
| AI 架构 | Agent 服务层（CourseParserAgent / ReviewPlannerAgent / FeedbackAgent） |
| 状态管理 | CourseStore / PlanStore（单例模式） |
| 兜底机制 | MockData → 概率论与数理统计 |

**AI Agent 分层架构：**
```
页面层 → Agent服务层 (CourseParserAgent / ReviewPlannerAgent / FeedbackAgent)
       → DeepSeekClient (底层HTTP通信)
       → PromptBuilder (结构化Prompt)
       → SafeParser (JSON安全解析)
       → DeepSeek API
失败自动降级 → MockData
```

### 📁 项目结构

```
StudyFlow OS/
├── entry/src/main/ets/
│   ├── pages/          # 6个核心页面
│   ├── components/     # 8个可复用组件
│   ├── models/         # 7个数据模型
│   ├── services/       # AI Agent + 状态管理
│   ├── utils/          # 工具类
│   └── common/         # 常量和主题
├── README.md
├── TEST.md
├── DEMO_SCRIPT.md
└── PAPER_OUTLINE.md
```

### 🚀 快速开始

#### 环境要求

- DevEco Studio 5.0+
- HarmonyOS NEXT SDK (API 12+)
- 模拟器或真机（HarmonyOS NEXT）

#### 运行步骤

1. 使用 DevEco Studio 打开项目根目录
2. 等待依赖同步完成
3. 选择模拟器或真机运行
4. **默认 Mock 模式即可演示完整流程**（无需配置 API Key）

#### 配置 DeepSeek API（可选）

编辑 `entry/src/main/ets/common/Constants.ets`：

```typescript
static readonly DEEPSEEK_API_KEY: string = 'your-api-key-here'
static readonly USE_MOCK: boolean = false
```

### 📱 页面导航

```
HomePage (学习驾驶舱)
├── ➕ 新建课程资料 → CourseInputPage → CourseAnalysisPage
│                                      ├── 🧠 查看知识点结构 → KnowledgeMapPage
│                                      └── 🃏 生成复习卡片 → ReviewCardPage → PlanPage
└── 📋 查看复习计划 → PlanPage
```

### 🔑 核心设计原则

1. **页面不得直接调用 DeepSeek API**，必须通过 Agent 服务层
2. **DeepSeek 输出严格 JSON**，通过 SafeParser 统一解析
3. **API 失败自动降级 MockData**，保证答辩演示稳定
4. **不做复杂图谱算法**，知识点用分组卡片展示
5. **不实现登录/注册/云数据库/OCR/PDF解析**

### 📄 许可证

本项目为本科毕业设计/重点项目原型。
