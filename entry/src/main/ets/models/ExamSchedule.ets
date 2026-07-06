/**
 * StudyFlow OS - 考试安排数据模型
 */

export interface ExamSchedule {
  id: string
  courseName: string
  examDate: string       // ISO date string
  examTime: string        // e.g. "09:00-11:00"
  location: string
  daysLeft: number
  priority: 'high' | 'medium' | 'low'
  topics: string          // 考试范围简述
  suggestedFocus: string  // 建议重点复习内容
  createdAt: string
}
