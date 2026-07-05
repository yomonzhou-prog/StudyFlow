/**
 * StudyFlow OS - 复习卡片数据模型
 * 用于自测、复习和反馈
 */

import { QuizItem } from './QuizItem'

export interface ReviewCard {
  id: string
  profileId: string
  knowledgePointId: string
  knowledgePointTitle: string
  knowledgePointExplanation: string
  keyReminder: string           // 重点提醒
  commonMistakes: string[]      // 常见错误
  quiz: QuizItem                // 自测题
  nextReviewSuggestion: string  // 下次复习建议
  reviewCount: number           // 已复习次数
  lastFeedbackStatus: string    // 最近反馈状态
}
