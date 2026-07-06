/**
 * StudyFlow OS - 考试安排状态管理
 * 单例模式，管理考试倒计时和复习提醒
 */

import { ExamSchedule } from '../models/ExamSchedule'
import { DateUtils } from '../utils/DateUtils'
import { IdUtils } from '../utils/IdUtils'

export class ExamStore {
  private static instance: ExamStore
  private exams: ExamSchedule[] = []

  static getInstance(): ExamStore {
    if (!ExamStore.instance) {
      ExamStore.instance = new ExamStore()
    }
    return ExamStore.instance
  }

  initMockData(): void {
    if (this.exams.length > 0) return

    this.exams = [
      {
        id: IdUtils.generate(),
        courseName: '概率论与数理统计',
        examDate: DateUtils.daysLater(5),
        examTime: '09:00-11:00',
        location: '教学楼A201',
        daysLeft: 5,
        priority: 'high',
        topics: '随机变量数字特征、参数估计、假设检验',
        suggestedFocus: '方差与协方差计算、最大似然估计、正态分布相关题型',
        createdAt: DateUtils.daysAgo(2)
      },
      {
        id: IdUtils.generate(),
        courseName: '数据结构',
        examDate: DateUtils.daysLater(8),
        examTime: '14:30-16:30',
        location: '实验楼B102',
        daysLeft: 8,
        priority: 'high',
        topics: '树与二叉树、图论、排序算法',
        suggestedFocus: '二叉树遍历与还原、最短路径算法、快速排序与归并排序',
        createdAt: DateUtils.daysAgo(3)
      },
      {
        id: IdUtils.generate(),
        courseName: '大学英语',
        examDate: DateUtils.daysLater(10),
        examTime: '08:30-10:30',
        location: '综合楼C303',
        daysLeft: 10,
        priority: 'medium',
        topics: '学术写作、阅读理解、翻译',
        suggestedFocus: 'Essay结构写作、学术词汇应用、长难句分析',
        createdAt: DateUtils.daysAgo(5)
      }
    ]
  }

  getExams(): ExamSchedule[] {
    return this.exams
  }

  /**
   * 动态计算考试剩余天数（基于当前日期）
   */
  static getDaysLeft(examDate: string): number {
    const today = new Date()
    today.setHours(0, 0, 0, 0)
    const exam = new Date(examDate)
    exam.setHours(0, 0, 0, 0)
    const diffMs = exam.getTime() - today.getTime()
    return Math.ceil(diffMs / (1000 * 60 * 60 * 24))
  }

  getNearestExam(): ExamSchedule | null {
    if (this.exams.length === 0) return null
    return this.exams.reduce((a, b) => ExamStore.getDaysLeft(a.examDate) < ExamStore.getDaysLeft(b.examDate) ? a : b)
  }

  getExamsByPriority(): ExamSchedule[] {
    const order: Record<string, number> = { 'high': 0, 'medium': 1, 'low': 2 }
    return [...this.exams].sort((a, b) => (order[a.priority] || 3) - (order[b.priority] || 3))
  }

  addExam(exam: ExamSchedule): void {
    this.exams.push(exam)
  }

  clearExams(): void {
    this.exams = []
  }
}
