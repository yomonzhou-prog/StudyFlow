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

- **启动与登录**：启动页 → 引导页 → 登录/注册（Mock模式）→ 游客模式
- **底部Tab导航**：学习 / 题库 / 学习教练 / 我的，4个Tab一键切换
- **学习驾驶舱**：问候语+连续天数+掌握率进度、今日任务、复习卡片、薄弱知识点
- **课程资料输入**：支持 6 种类型（PPT/教材/通知/作业/考试范围/错题）的文本输入
- **智能课程解析**：DeepSeek 自动分析课程内容，生成摘要、章节结构、知识点、考试重点
- **知识点结构化**：按章节分组展示，标注重要程度和难度，章节筛选
- **复习卡片系统**：包含知识点解释、重点提醒、常见错误、自测题和答案解析
- **随机复习模式**：沉浸式单卡片复习 → 选择答案 → 查看解析 → 反馈（认识了/还模糊/没掌握）
- **自测反馈闭环**：已掌握/还模糊/做错了 → 自动生成二次复习计划
- **题库模块**：8道示例题目，按课程/难度筛选，答题后显示正误和解析
- **错题本**：自动收集错题，支持标记已掌握和重复复习
- **学习教练**：聊天式 AI 对话，快捷提问卡片（学习计划/进度/方法/鼓励）
- **个人中心**：学习数据统计、连续天数、错题本入口、设置入口
- **学习设置**：每日目标时长、新卡片数、复习卡片数、提醒时间
- **Mock 兜底机制**：API Key 缺失或网络失败时自动使用内置示例数据

### 🏗️ 技术架构

| 层级 | 技术 |
|------|------|
| 开发语言 | ArkTS |
| UI 框架 | ArkUI 声明式 |
| 操作系统 | HarmonyOS NEXT |
| AI 模型 | DeepSeek V4 (deepseek-chat) |
| AI 架构 | Agent 服务层（CourseParserAgent / ReviewPlannerAgent / FeedbackAgent / CoachAgent） |
| 状态管理 | CourseStore / PlanStore / AuthStore / QuestionBankStore / SettingsStore（单例模式） |
| 兜底机制 | MockData → 概率论与数理统计 |

**AI Agent 分层架构：**
```
页面层 → Agent服务层 (CourseParserAgent / ReviewPlannerAgent / FeedbackAgent / CoachAgent)
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
│   ├── pages/          # 18个页面（6个Tab嵌入+12个独立页面）
│   ├── components/     # 14个可复用组件
│   ├── models/         # 11个数据模型
│   ├── services/       # AI Agent + 状态管理（13个服务文件）
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
SplashPage → OnboardingPage → LoginPage / RegisterPage → MainPage
                                                             ├── 📋 学习 Tab → HomePage (驾驶舱)
                                                             │   ├── ➕ 新建课程 → CourseInputPage → CourseAnalysisPage
                                                             │   │                              ├── 🧠 知识地图 → KnowledgeMapPage
                                                             │   │                              └── 🃏 生成卡片 → ReviewCardPage → PlanPage
                                                             │   ├── 🃏 复习卡片 → ReviewCardPage
                                                             │   └── 📋 复习计划 → PlanPage
                                                             ├── 📝 题库 Tab → QuestionBankPage
                                                             │   └── 答题 → QuestionDetailPage
                                                             ├── 💬 教练 Tab → CoachPage（AI对话）
                                                             └── 👤 我的 Tab → ProfilePage
                                                                 ├── 📝 错题本 → WrongQuestionPage
                                                                 └── ⚙️ 设置 → SettingsPage
```

### 🔑 核心设计原则

1. **页面不得直接调用 DeepSeek API**，必须通过 Agent 服务层
2. **DeepSeek 输出严格 JSON**，通过 SafeParser 统一解析
3. **API 失败自动降级 MockData**，保证答辩演示稳定
4. **不做复杂图谱算法**，知识点用分组卡片展示
5. **组件复用**：PageHeader/LoadingView/AppButton/MockBanner/SectionCard 等14个共享组件

### 📄 许可证

本项目为本科毕业设计/重点项目原型。
