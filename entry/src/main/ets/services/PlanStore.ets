/**
 * StudyFlow OS - 学习计划状态管理
 * 管理学习任务和反馈的本地存储
 */

import { StudyTask } from '../models/StudyTask'
import { LearningFeedback } from '../models/LearningFeedback'
import { ReviewCard } from '../models/ReviewCard'
import { MockData } from './MockData'
import { DateUtils } from '../utils/DateUtils'

export interface WeakPoint {
  title: string
  chapter: string
  difficulty: string
  importance: string
  lastFeedback: string
}

export class PlanStore {
  private static instance: PlanStore

  private tasks: StudyTask[] = []
  private feedbacks: LearningFeedback[] = []
  private reviewCards: ReviewCard[] = []

  static getInstance(): PlanStore {
    if (!PlanStore.instance) {
      PlanStore.instance = new PlanStore()
    }
    return PlanStore.instance
  }

  /**
   * 初始化示例数据
   */
  initMockData(): void {
    this.tasks = MockData.getSampleTasks()
    this.feedbacks = MockData.getSampleFeedbacks()
    this.reviewCards = MockData.getSampleReviewCards_probability()
  }

  // ========== 任务管理 ==========

  /**
   * 添加任务
   */
  addTask(task: StudyTask): void {
    this.tasks.unshift(task)
  }

  /**
   * 添加多个任务
   */
  addTasks(tasks: StudyTask[]): void {
    this.tasks.unshift(...tasks)
  }

  /**
   * 获取所有任务
   */
  getTasks(): StudyTask[] {
    return this.tasks
  }

  /**
   * 获取今日任务
   */
  getTodayTasks(): StudyTask[] {
    return this.tasks.filter(t =>
      t.status !== 'completed' && DateUtils.isToday(t.deadline)
    )
  }

  /**
   * 获取三天内截止的任务
   */
  getUrgentTasks(): StudyTask[] {
    return this.tasks.filter(t =>
      t.status !== 'completed' && DateUtils.isWithinDays(t.deadline, 3)
    ).sort((a, b) => new Date(a.deadline).getTime() - new Date(b.deadline).getTime())
  }

  /**
   * 获取薄弱点任务
   */
  getWeaknessTasks(): StudyTask[] {
    return this.tasks.filter(t => t.sourceType === 'weakness')
  }

  /**
   * 根据状态获取任务
   */
  getTasksByStatus(status: string): StudyTask[] {
    return this.tasks.filter(t => t.status === status)
  }

  /**
   * 更新任务状态
   */
  updateTaskStatus(taskId: string, status: string): void {
    const task = this.tasks.find(t => t.id === taskId)
    if (task) {
      task.status = status
    }
  }

  // ========== 反馈管理 ==========

  /**
   * 添加学习反馈
   */
  addFeedback(feedback: LearningFeedback): void {
    this.feedbacks.unshift(feedback)
  }

  /**
   * 获取所有反馈
   */
  getFeedbacks(): LearningFeedback[] {
    return this.feedbacks
  }

  /**
   * 获取薄弱知识点（最近反馈为fuzzy或wrong的知识点）
   */
  getWeakKnowledgePoints(): WeakPoint[] {
    const latestFeedbackMap = new Map<string, LearningFeedback>()
    this.feedbacks.forEach(fb => {
      if (!latestFeedbackMap.has(fb.knowledgePointId) ||
        new Date(fb.timestamp).getTime() > new Date(latestFeedbackMap.get(fb.knowledgePointId)!.timestamp).getTime()) {
        latestFeedbackMap.set(fb.knowledgePointId, fb)
      }
    })

    const weakPoints: WeakPoint[] = []
    latestFeedbackMap.forEach((fb) => {
      if (fb.status === 'fuzzy' || fb.status === 'wrong') {
        const wp: WeakPoint = {
          title: fb.knowledgePointTitle,
          chapter: '',
          difficulty: fb.status === 'wrong' ? 'hard' : 'medium',
          importance: 'high',
          lastFeedback: fb.status
        }
        weakPoints.push(wp)
      }
    })
    return weakPoints
  }

  /**
   * 根据知识点ID获取最新反馈
   */
  getLatestFeedbackByKpId(knowledgePointId: string): LearningFeedback | undefined {
    return this.feedbacks
      .filter(f => f.knowledgePointId === knowledgePointId)
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())[0]
  }

  // ========== 复习卡片管理 ==========

  /**
   * 设置复习卡片列表
   */
  setReviewCards(cards: ReviewCard[]): void {
    this.reviewCards = cards
  }

  /**
   * 获取所有复习卡片
   */
  getReviewCards(): ReviewCard[] {
    return this.reviewCards
  }

  /**
   * 获取今日应复习的卡片（最近反馈非mastered的）
   */
  getTodayReviewCards(): ReviewCard[] {
    return this.reviewCards.filter(rc =>
      rc.lastFeedbackStatus !== 'mastered' || rc.reviewCount === 0
    )
  }

  /**
   * 更新复习卡片反馈状态
   */
  updateReviewCardFeedback(cardId: string, status: string): void {
    const card = this.reviewCards.find(rc => rc.id === cardId)
    if (card) {
      card.lastFeedbackStatus = status
      card.reviewCount++
    }
  }

  /**
   * 清空所有数据
   */
  clear(): void {
    this.tasks = []
    this.feedbacks = []
    this.reviewCards = []
  }
}
