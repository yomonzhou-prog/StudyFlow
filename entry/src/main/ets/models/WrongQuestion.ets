/**
 * StudyFlow OS - 错题本数据模型
 * 记录用户做错的题目及回顾信息
 */

export interface WrongQuestion {
  id: string
  /** 关联的题目ID */
  questionId: string
  /** 题目内容快照 */
  question: string
  /** 选项快照 */
  options: string[]
  /** 正确答案 */
  correctAnswer: string
  /** 用户选择的答案 */
  userAnswer: string
  /** 答案解析 */
  explanation: string
  /** 所属课程 */
  courseName: string
  /** 所属章节 */
  chapter: string
  /** 关联知识点ID */
  knowledgePointId: string
  /** 知识点名称 */
  knowledgePointTitle: string
  /** 做错时间 */
  wrongTime: string
  /** 已复习次数 */
  reviewCount: number
  /** 是否已掌握 */
  isMastered: boolean
}
