/**
 * StudyFlow OS - 题库题目数据模型
 */

export interface QuestionItem {
  id: string
  /** 所属课程 */
  courseName: string
  /** 所属章节 */
  chapter: string
  /** 关联知识点ID */
  knowledgePointId: string
  /** 题目内容 */
  question: string
  /** 选项列表 */
  options: string[]
  /** 正确答案 */
  correctAnswer: string
  /** 答案解析 */
  explanation: string
  /** 题型 */
  type: 'choice' | 'multi_choice' | 'true_false'
  /** 难度 */
  difficulty: 'easy' | 'medium' | 'hard'
  /** 来源 */
  source: string
  /** 创建时间 */
  createdAt: string
  /** 做题次数 */
  attemptCount: number
  /** 做错次数 */
  wrongCount: number
}
