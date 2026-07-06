# StudyFlow

## 面向大学生期末复习的沉浸式学习卡片系统

### 产品定位

StudyFlow 不是任务管理器，不是 AI 聊天 App，而是一个**期末复习卡片系统**。核心理念参考沉浸式背单词体验：一题一卡，翻转查看答案，认识/模糊/忘了反馈，错题自动收集，复习优先级智能排序。

### 核心学习闭环

```
考试安排 / 课程资料 / 老师重点 / 复习题
→ 智能解析
→ 生成考试倒计时、复习优先级、题目卡片
→ 每日沉浸式刷卡复习
→ 认识 / 模糊 / 忘了反馈
→ 错题本与薄弱知识点自动更新
→ 复习计划重新排序
```

### 功能特性

- **简约登录**：启动页 → 引导页 → 登录/注册（Mock） → 游客模式
- **期末复习首页**：考试倒计时、今日复习入口、复习优先级 Top 3、轻量统计
- **复习题导入**：粘贴文本自动拆分为一张张答题卡片
- **沉浸式卡片复习**：全屏单卡片、查看答案、认识/模糊/忘了三档反馈
- **考试倒计时**：粘贴考试安排文本，自动生成倒计时和复习提醒
- **复习优先级**：综合老师重点 + 考试临近 + 错题反馈 + 知识点难度
- **题库与错题本**：课程/难度筛选、随机刷题、错题自动收集
- **学习教练**：学习策略建议面板，快捷提问
- **个人中心**：学习数据统计、连续天数、设置入口
- **AI 状态检测**：设置页可检测 API 连接状态，明确显示 Mock/在线模式

### 技术架构

| 层级 | 技术 |
|------|------|
| 开发语言 | ArkTS |
| UI 框架 | ArkUI 声明式 |
| 操作系统 | HarmonyOS NEXT (API 12+) |
| AI 模型 | DeepSeek (deepseek-chat) |
| AI 架构 | Agent 服务层（6 个 Agent） |
| 状态管理 | 单例模式（6 个 Store） |

### 项目结构

```
entry/src/main/ets/
├── pages/          # 17个页面
├── components/     # 15个可复用组件
├── models/         # 14个数据模型
├── services/       # Agent + Store（16个文件）
├── utils/          # 工具类
└── common/         # 常量和主题
```

### 快速开始

1. 使用 DevEco Studio 打开项目根目录
2. 选择模拟器或真机运行
3. 默认 Mock 模式即可演示完整流程

### 页面导航

```
SplashPage → OnboardingPage → LoginPage/RegisterPage → MainPage
  ├── 复习 Tab → HomePage（期末复习首页）
  │   ├── 考试倒计时 → ExamSchedulePage
  │   ├── 开始今日复习 → ImmersiveReviewPage
  │   └── 导入复习题 → ExamPaperImportPage
  ├── 题库 Tab → QuestionBankPage → QuestionDetailPage
  ├── 教练 Tab → CoachPage
  └── 我的 Tab → ProfilePage
      ├── 错题本 → WrongQuestionPage
      └── 设置 → SettingsPage
```

### 设计原则

1. 页面不直接调用 API，必须通过 Agent 服务层
2. API 失败自动降级 MockData，保障演示稳定
3. 简约高级学习产品风格，不出现 AI/机器人/emoji 横幅
4. 沉浸式单卡片复习体验
5. OCR 拍照功能开发中，当前支持文本化输入
