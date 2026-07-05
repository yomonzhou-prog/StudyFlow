/**
 * StudyFlow OS - 自测题数据模型
 */

export interface QuizItem {
  id: string
  question: string             // 题目
  options: string[]            // 选项（可为空，表示简答题）
  correctAnswer: string        // 正确答案
  explanation: string          // 解析
  type: string                 // choice | short_answer
}
