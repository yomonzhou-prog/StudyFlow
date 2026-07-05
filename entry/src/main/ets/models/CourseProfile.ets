/**
 * StudyFlow OS - 课程画像数据模型
 * 由 CourseParserAgent 解析生成
 */

import { KnowledgePoint } from './KnowledgePoint'

export interface ChapterStructure {
  title: string
  order: number
  summary: string
  knowledgePointIds: string[]
}

export interface ExamFocus {
  topic: string
  importance: string    // critical | high | medium
  description: string
}

export interface HomeworkTask {
  title: string
  deadline: string
  description: string
  priority: string      // high | medium | low
}

export interface RiskWarning {
  level: string         // high | medium | low
  message: string
  suggestion: string
}

export interface CourseProfile {
  id: string
  materialId: string
  courseName: string
  summary: string               // 课程摘要
  chapters: ChapterStructure[]  // 章节结构
  knowledgePoints: KnowledgePoint[]  // 核心知识点
  examFocuses: ExamFocus[]      // 考试重点
  homeworkTasks: HomeworkTask[] // 作业任务
  riskWarnings: RiskWarning[]   // 学习风险提醒
  createdAt: string
  isMockData: boolean
}
