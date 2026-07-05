/**
 * StudyFlow OS - 学习反馈数据模型
 * 记录用户对每个知识点的掌握状态
 */

export interface LearningFeedback {
  id: string
  reviewCardId: string
  knowledgePointId: string
  knowledgePointTitle: string
  status: string              // mastered | fuzzy | wrong
  timestamp: string           // ISO date string
  note: string                // 用户备注或系统建议
}
