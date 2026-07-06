/**
 * StudyFlow OS - 复习题目卡片数据模型
 * 一题一卡，沉浸式复习的核心数据单元
 */

export interface QuestionCard {
  id: string
  courseName: string
  question: string
  options: string[]
  answer: string
  explanation: string
  relatedKnowledge: string[]       // 关联知识点
  difficulty: 'easy' | 'medium' | 'hard'
  commonMistake: string
  sourcePaperId: string            // 来源试卷ID
  isWrong: boolean                 // 是否在错题本
  reviewedCount: number            // 已复习次数
  lastResult: string               // 'correct' | 'unclear' | 'wrong' | ''
  createdAt: string
}
