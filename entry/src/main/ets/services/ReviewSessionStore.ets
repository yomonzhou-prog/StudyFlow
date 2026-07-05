/**
 * StudyFlow OS - 随机复习会话管理
 * 管理复习会话状态：当前卡片索引、已复习列表、复习进度
 */

import { ReviewCard } from '../models/ReviewCard'

export class ReviewSessionStore {
  private static instance: ReviewSessionStore

  private cards: ReviewCard[] = []
  private currentIndex: number = 0
  private reviewedIds: string[] = []
  private masteredIds: string[] = []
  private fuzzyIds: string[] = []
  private wrongIds: string[] = []

  static getInstance(): ReviewSessionStore {
    if (!ReviewSessionStore.instance) {
      ReviewSessionStore.instance = new ReviewSessionStore()
    }
    return ReviewSessionStore.instance
  }

  /**
   * 开始复习会话
   */
  startSession(cards: ReviewCard[]): void {
    this.cards = this.shuffle(cards)
    this.currentIndex = 0
    this.reviewedIds = []
    this.masteredIds = []
    this.fuzzyIds = []
    this.wrongIds = []
  }

  /**
   * 获取当前卡片
   */
  getCurrentCard(): ReviewCard | null {
    if (this.cards.length === 0 || this.currentIndex >= this.cards.length) {
      return null
    }
    return this.cards[this.currentIndex]
  }

  /**
   * 获取总卡片数
   */
  getTotalCount(): number {
    return this.cards.length
  }

  /**
   * 获取当前位置（从1开始）
   */
  getCurrentPosition(): number {
    return this.currentIndex + 1
  }

  /**
   * 是否还有下一张卡片
   */
  hasNext(): boolean {
    return this.currentIndex < this.cards.length - 1
  }

  /**
   * 是否有上一张卡片
   */
  hasPrevious(): boolean {
    return this.currentIndex > 0
  }

  /**
   * 记录反馈并移到下一张
   */
  submitFeedback(status: string): void {
    const card = this.getCurrentCard()
    if (!card) return

    const cardId = card.id
    this.reviewedIds.push(cardId)

    if (status === 'mastered') {
      this.masteredIds.push(cardId)
    } else if (status === 'fuzzy') {
      this.fuzzyIds.push(cardId)
    } else if (status === 'wrong') {
      this.wrongIds.push(cardId)
    }

    this.currentIndex++
  }

  /**
   * 移到下一张
   */
  nextCard(): void {
    if (this.hasNext()) {
      this.currentIndex++
    }
  }

  /**
   * 移到上一张
   */
  previousCard(): void {
    if (this.hasPrevious()) {
      this.currentIndex--
    }
  }

  /**
   * 获取会话统计
   */
  getSessionStats(): SessionStats {
    return {
      total: this.cards.length,
      reviewed: this.reviewedIds.length,
      mastered: this.masteredIds.length,
      fuzzy: this.fuzzyIds.length,
      wrong: this.wrongIds.length
    }
  }

  /**
   * 是否全部复习完毕
   */
  isComplete(): boolean {
    return this.cards.length > 0 && this.currentIndex >= this.cards.length
  }

  /**
   * 获取复习进度 (0-1)
   */
  getProgress(): number {
    if (this.cards.length === 0) return 0
    return this.reviewedIds.length / this.cards.length
  }

  /**
   * 重置会话
   */
  reset(): void {
    this.cards = []
    this.currentIndex = 0
    this.reviewedIds = []
    this.masteredIds = []
    this.fuzzyIds = []
    this.wrongIds = []
  }

  /**
   * Fisher-Yates 洗牌
   */
  private shuffle(array: ReviewCard[]): ReviewCard[] {
    const result = array.slice()
    for (let i = result.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const temp = result[i]
      result[i] = result[j]
      result[j] = temp
    }
    return result
  }
}

export interface SessionStats {
  total: number
  reviewed: number
  mastered: number
  fuzzy: number
  wrong: number
}
