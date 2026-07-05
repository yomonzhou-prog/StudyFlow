# 论文大纲：基于 HarmonyOS NEXT 与 DeepSeek V4 的大学生学习任务操作系统设计与实现

## 摘要

针对大学生课程资料碎片化、复习计划断裂、作业任务分散、错题反馈不可持续等问题，本文设计并实现了一款基于 HarmonyOS NEXT 与 DeepSeek V4 的学习任务操作系统——StudyFlow OS。系统构建了"课程资料输入 → AI 课程理解 → 知识点结构化 → 学习任务拆解 → 复习卡片生成 → 自测反馈 → 二次复习规划"的完整学习闭环。系统采用 ArkTS + ArkUI 声明式框架开发，通过 AI Agent 服务层架构实现对 DeepSeek V4 大模型的结构化调用，并设计了 Mock 兜底机制保障系统在无网络环境下的可用性。实验表明，系统能够有效辅助大学生进行课程知识的结构化管理和个性化复习规划。

**关键词：** HarmonyOS NEXT；DeepSeek；学习任务操作系统；AI Agent；知识结构化；复习闭环

---

## 第一章 绪论

### 1.1 研究背景与意义
- 大学生学习管理的现状与痛点
  - 课程资料碎片化（PPT、教材、通知、作业分散）
  - 复习计划缺乏持续性
  - 错题反馈不可追溯
  - 任务管理工具与学习内容脱节
- 移动端学习工具的发展趋势
- 国产操作系统 HarmonyOS NEXT 的战略意义
- 大语言模型在教育领域的应用前景

### 1.2 国内外研究现状
- 传统学习管理工具（Notion、Todoist、Anki）
- AI 教育产品（Khan Academy AI、Duolingo AI）
- 知识图谱与自适应学习系统
- 现有方案的不足：缺乏从课程理解到复习规划的完整闭环

### 1.3 研究内容与创新点
- 设计"学习任务操作系统"的产品定位
- 构建课程理解-任务拆解-反馈闭环的完整链路
- 基于 AI Agent 服务层的架构设计
- Mock 兜底机制保障系统可用性
- 基于 HarmonyOS NEXT 的原生实现

### 1.4 论文组织结构

---

## 第二章 相关技术概述

### 2.1 HarmonyOS NEXT 与 ArkUI 框架
- HarmonyOS NEXT 系统架构
- ArkTS 语言特性
- ArkUI 声明式开发范式
- 路由导航与状态管理

### 2.2 DeepSeek V4 大语言模型
- DeepSeek 模型能力概述
- API 调用方式与参数配置
- JSON 结构化输出能力
- Long Context 课程资料理解

### 2.3 AI Agent 架构模式
- Agent 服务层的设计理念
- Prompt Engineering 与结构化输出协议
- 多层降级与容错机制

### 2.4 学习科学理论基础
- 间隔重复（Spaced Repetition）
- 测试效应（Testing Effect）
- 元认知与自我评估
- 任务优先级排序理论

---

## 第三章 系统需求分析

### 3.1 用户角色与场景分析
- 目标用户画像
- 核心使用场景
  - 课后资料整理
  - 考前系统复习
  - 作业追踪管理
  - 错题反馈迭代

### 3.2 功能性需求
- 课程资料输入与管理
- AI 课程理解与结构化
- 知识点组织与展示
- 复习卡片生成与自测
- 自测反馈采集
- 二次复习计划生成
- 学习驾驶舱展示

### 3.3 非功能性需求
- Mock 模式下的完整可用性
- AI 服务失败的优雅降级
- 界面简洁，适合答辩投屏
- 数据本地化，无云依赖

### 3.4 可行性分析

---

## 第四章 系统设计

### 4.1 系统总体架构
- 分层架构图（用户交互层 → AI Agent 服务层 → 数据模型层 → 存储层）
- 核心闭环数据流设计
- 模块划分与接口定义

### 4.2 核心数据模型设计
- CourseMaterial（课程资料）
- CourseProfile（课程画像）
- KnowledgePoint（知识点）
- StudyTask（学习任务）
- ReviewCard（复习卡片）
- QuizItem（自测题）
- LearningFeedback（学习反馈）
- 模型之间的关系与映射

### 4.3 AI Agent 服务层设计
- CourseParserAgent：课程解析 Agent
- ReviewPlannerAgent：复习规划 Agent
- FeedbackAgent：反馈分析 Agent
- PromptBuilder：结构化 Prompt 构建
- DeepSeekClient：底层 API 通信
- 三层降级策略：API → SafeParser → MockData

### 4.4 页面与交互设计
- HomePage：学习驾驶舱
- CourseInputPage：课程资料输入
- CourseAnalysisPage：课程解析展示
- KnowledgeMapPage：知识点结构
- ReviewCardPage：复习卡片与自测
- PlanPage：复习计划与再规划
- 页面导航流程设计

### 4.5 状态管理设计
- CourseStore 单例设计
- PlanStore 单例设计
- 数据初始化与 Mock 注入

### 4.6 Mock 兜底机制设计
- MockData 的数据构建策略
- 多课程示例数据设计
- 降级触发条件与切换逻辑

---

## 第五章 系统实现

### 5.1 开发环境与工具
- DevEco Studio 5.0
- ArkTS 语言
- HarmonyOS NEXT SDK (API 12)

### 5.2 数据模型层实现
- 7 个核心 interface 定义
- 字段命名规范与类型约束

### 5.3 AI Agent 服务层实现
- DeepSeekClient HTTP 通信实现
- PromptBuilder 四类 Prompt 模板
- CourseParserAgent JSON 解析链路
- ReviewPlannerAgent 复习卡片生成
- FeedbackAgent 本地规则 + AI 双模式

### 5.4 页面层实现
- 6 个核心页面的 ArkUI 实现
- 8 个可复用组件的封装
- 路由导航与参数传递

### 5.5 Mock 数据实现
- 概率论与数理统计完整示例
- 数据结构、大学英语辅助示例
- 知识点、复习卡片、学习任务的关联构建

### 5.6 关键技术难点与解决方案
- JSON 解析容错（JsonUtils.extractJson）
- 异步调用的页面状态管理
- Mock 模式的无感切换
- 大文本输入的性能优化

---

## 第六章 系统测试与分析

### 6.1 测试环境
### 6.2 功能测试
- 10 项核心测试用例及结果
- 完整闭环流程测试

### 6.3 Mock 模式可用性验证
- 无网络环境下的功能完整性
- 三种降级路径测试

### 6.4 AI 解析效果评估（如有 API Key）
- 解析成功率
- JSON 格式合规率
- 知识点提取准确率

### 6.5 系统展示效果评估
- 答辩投屏适配
- 交互流畅度
- 界面一致性

---

## 第七章 总结与展望

### 7.1 工作总结
### 7.2 不足与局限
- 未实现真实 PDF/PPT 解析
- 未接入云数据库
- 知识点图谱缺少可视化
- 未进行大规模用户测试

### 7.3 未来展望
- OCR + PDF 解析集成
- 云端同步与多端协同
- 真实知识图谱可视化
- 学习数据分析和长期追踪
- 社交化学习（学习小组、排名）
- 接入更多 AI 模型（对比评估）

---

## 参考文献

[1] HarmonyOS NEXT 开发者文档. 华为开发者联盟.
[2] DeepSeek API 文档. DeepSeek.
[3] ArkUI 声明式开发指南. 华为开发者联盟.
[4] 刘知远等. 大语言模型. 高等教育出版社, 2024.
[5] Ebbinghaus H. Memory: A Contribution to Experimental Psychology. 1885.
[6] Roediger H L, Karpicke J D. Test-Enhanced Learning. Psychological Science, 2006.
[7] Cepeda N J, et al. Spacing Effects in Learning. Psychological Bulletin, 2006.
[8] Biggs J, Tang C. Teaching for Quality Learning at University. Open University Press, 2011.
[9] Anderson L W, Krathwohl D R. A Taxonomy for Learning, Teaching, and Assessing. Longman, 2001.
[10] Flavell J H. Metacognition and Cognitive Monitoring. American Psychologist, 1979.

---

## 致谢
