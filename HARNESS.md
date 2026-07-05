# StudyFlow OS Harness 指令

你是资深 HarmonyOS NEXT 原生应用架构师、ArkTS/ArkUI 高级工程师、AI 大模型应用落地专家和本科重点项目交付负责人。

现在需要在 2 天内完成一个可运行、可演示、可测试、可打包、可写论文的本科重点项目原型。

项目名称：

StudyFlow OS

中文题目：

基于 HarmonyOS NEXT 与 DeepSeek V4 的大学生学习任务操作系统设计与实现

项目定位：

本项目不是普通 AI 聊天 App，不是简单待办软件，也不是资料管理器。它面向大学生课程资料碎片化、复习计划断裂、作业任务分散、错题反馈不可持续等问题，构建一个学习任务操作系统。

系统核心闭环为：

课程资料输入
→ DeepSeek 课程理解
→ 知识点结构化
→ 学习任务拆解
→ 复习卡片生成
→ 自测反馈
→ 二次复习规划

第一版必须保证可以在答辩现场稳定演示。

---

## 一、硬性约束

1. 使用 HarmonyOS NEXT 原生开发。
2. 使用 ArkTS 作为主要开发语言。
3. 使用 ArkUI 声明式框架构建界面。
4. 使用 DeepSeek API 实现 AI 能力。
5. 使用 Claude Code / Harness 辅助开发，但最终项目代码必须结构清晰、可编译。
6. 页面不得直接调用 DeepSeek API，必须通过 AI Agent 服务层调用。
7. DeepSeek 输出必须要求为严格 JSON。
8. API Key 缺失、网络失败、JSON 解析失败时，必须自动使用 MockData。
9. 不实现登录注册。
10. 不实现云数据库。
11. 不实现真实 PDF/PPT 复杂解析。
12. 不实现 OCR。
13. 不读取真实微信或社交软件数据。
14. 不实现外部硬件能力。
15. 不实现多端协同。
16. 不做复杂动态图谱算法。
17. 不做过度动画。
18. 每一步开发后都必须保证项目可编译、可运行。

---

## 二、项目目标

系统需要完成以下核心目标：

1. 用户可以输入课程名称和课程资料文本。
2. 用户可以选择资料类型：PPT、教材、通知、作业、考试范围、错题。
3. 用户可以使用内置示例课程资料。
4. 系统调用 DeepSeek 对课程资料进行结构化解析。
5. 系统生成课程画像，包括课程摘要、章节结构、核心知识点、考试重点、作业任务和风险提醒。
6. 系统生成知识点结构卡片。
7. 系统生成复习卡片和自测题。
8. 用户可以对自测结果选择“已掌握 / 还模糊 / 做错了”。
9. 系统根据反馈生成二次复习计划。
10. 系统提供学习驾驶舱，展示今日任务、三天内截止任务、薄弱知识点和今日复习卡片。
11. 系统支持 Mock 模式，保证无网络也能答辩演示。
12. 系统最终需要补充 README、测试说明和答辩演示脚本。

---

## 三、页面范围

只实现 6 个核心页面，不要增加过多页面。

### 1. HomePage：学习驾驶舱

页面目标：

展示学生当前学习状态，让首页有“学习任务操作系统”的感觉。

必须包含以下区域：

- 今日必须完成
- 三天内截止
- 薄弱知识点
- 今日复习卡片
- 新建课程资料按钮
- 查看复习计划按钮

任务卡片显示：

- 任务标题
- 所属课程
- 优先级
- 预计耗时
- 截止时间
- 完成状态

薄弱知识点卡片显示：

- 知识点名称
- 所属章节
- 难度
- 重要程度
- 最近反馈状态

### 2. CourseInputPage：课程资料输入页

页面目标：

让用户输入或导入文本化课程资料。

必须包含：

- 课程名称输入框
- 资料标题输入框
- 资料类型选择器
  - ppt
  - textbook
  - notice
  - homework
  - exam
  - wrong_question
- 大文本输入框
- 使用示例资料按钮
- AI 解析课程按钮
- 输入为空时的错误提示

注意：

第一版不做真实 PDF/PPT/OCR，只做文本化输入。

### 3. CourseAnalysisPage：课程解析结果页

页面目标：

展示 DeepSeek 对课程资料的结构化理解结果。

必须包含：

- 课程名称
- 课程摘要
- 章节结构
- 核心知识点列表
- 考试重点
- 作业任务
- 学习风险提醒
- 生成复习卡片按钮
- 查看知识点结构按钮
- 保存课程画像按钮

### 4. KnowledgeMapPage：知识点结构页

页面目标：

展示“伪知识图谱”效果，但不要做复杂图算法。

第一版用章节分组 + 知识点卡片实现。

每个知识点卡片显示：

- 知识点标题
- 所属章节
- 解释
- 重要程度
- 难度
- 常见错误
- 相关知识点

注意：

不要做复杂 Canvas 图谱，不要做拖拽关系图。用分组卡片即可，保证稳定。

### 5. ReviewCardPage：复习卡片页

页面目标：

展示复习卡片、自测题和反馈入口。

每张复习卡片必须包含：

- 知识点标题
- 知识点解释
- 重点提醒
- 常见错误
- 自测题
- 选项，如果有
- 答案
- 解析
- 下次复习建议

用户反馈按钮：

- 已掌握
- 还模糊
- 做错了

点击反馈后：

- 保存 LearningFeedback
- 跳转或刷新 PlanPage
- 显示系统生成的二次复习建议

### 6. PlanPage：复习计划页

页面目标：

展示学习闭环中的“再规划”结果。

必须包含：

- 今日计划
- 明日建议
- 薄弱点强化任务
- 临考冲刺建议
- 根据反馈生成的新任务
- 每个任务的优先级和预计耗时

---

## 四、推荐目录结构

请尽量按以下结构生成项目文件。

entry/src/main/ets/
├── pages/
│   ├── HomePage.ets
│   ├── CourseInputPage.ets
│   ├── CourseAnalysisPage.ets
│   ├── KnowledgeMapPage.ets
│   ├── ReviewCardPage.ets
│   └── PlanPage.ets
│
├── components/
│   ├── StudyTaskCard.ets
│   ├── KnowledgePointCard.ets
│   ├── ReviewCardView.ets
│   ├── PriorityTag.ets
│   ├── DifficultyTag.ets
│   ├── ImportanceTag.ets
│   ├── EmptyState.ets
│   └── SectionHeader.ets
│
├── models/
│   ├── CourseMaterial.ets
│   ├── CourseProfile.ets
│   ├── KnowledgePoint.ets
│   ├── StudyTask.ets
│   ├── ReviewCard.ets
│   ├── QuizItem.ets
│   └── LearningFeedback.ets
│
├── services/
│   ├── DeepSeekClient.ets
│   ├── PromptBuilder.ets
│   ├── CourseParserAgent.ets
│   ├── ReviewPlannerAgent.ets
│   ├── FeedbackAgent.ets
│   ├── CourseStore.ets
│   ├── PlanStore.ets
│   └── MockData.ets
│
├── utils/
│   ├── DateUtils.ets
│   ├── IdUtils.ets
│   ├── JsonUtils.ets
│   └── SafeParser.ets
│
└── common/
    ├── Constants.ets
    └── Theme.ets

根目录需要补充：

README.md
TEST.md
DEMO_SCRIPT.md
PAPER_OUTLINE.md

---

## 五、核心数据模型

请创建以下 ArkTS interface。字段命名必须保持一致，方便页面与服务层调用。

### CourseMaterial

```ts
export interface CourseMaterial {
  id: string
  courseName: string
  title: string
  content: string
  type: 'ppt' | 'textbook' | 'notice' | 'homework' | 'exam' | 'wrong_question'
  createdAt: string
}
```