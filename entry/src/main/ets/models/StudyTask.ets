/**
 * StudyFlow OS - 学习任务数据模型
 * 用于驾驶舱任务卡片和复习计划
 */

export interface StudyTask {
  id: string
  title: string
  courseName: string
  description: string
  priority: string        // high | medium | low
  estimatedMinutes: number
  deadline: string        // ISO date string
  status: string          // pending | in_progress | completed
  sourceType: string      // homework | review | weakness | exam
  relatedKnowledgePointIds: string[]
  createdAt: string
}
