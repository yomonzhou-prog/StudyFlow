/**
 * StudyFlow OS - 题目卡片状态管理
 * 管理复习卡片题库、错题本、复习队列
 */

import { QuestionCard } from '../models/QuestionCard'
import { ExamPaperParserAgent } from './ExamPaperParserAgent'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

export class QuestionCardStore {
  private static instance: QuestionCardStore
  private cards: QuestionCard[] = []

  static getInstance(): QuestionCardStore {
    if (!QuestionCardStore.instance) {
      QuestionCardStore.instance = new QuestionCardStore()
    }
    return QuestionCardStore.instance
  }

  initMockData(): void {
    if (this.cards.length > 0) return
    const parser = ExamPaperParserAgent.getInstance()
    const result = parser.getMockCards('概率论与数理统计')
    if (result.data) {
      this.cards = result.data
    }
  }

  getCards(): QuestionCard[] {
    return this.cards
  }

  getCardsByCourse(courseName: string): QuestionCard[] {
    return this.cards.filter(c => c.courseName === courseName)
  }

  getCourseNames(): string[] {
    const names: string[] = []
    for (const c of this.cards) {
      if (!names.includes(c.courseName)) {
        names.push(c.courseName)
      }
    }
    return names
  }

  getCardById(id: string): QuestionCard | null {
    return this.cards.find(c => c.id === id) || null
  }

  getWrongCards(): QuestionCard[] {
    return this.cards.filter(c => c.isWrong)
  }

  getTodayReviewCards(): QuestionCard[] {
    // Return wrong cards + cards not yet reviewed
    return this.cards.filter(c => c.isWrong || c.reviewedCount === 0)
  }

  addCards(cards: QuestionCard[]): void {
    for (const c of cards) {
      c.id = c.id || IdUtils.generate()
      c.createdAt = c.createdAt || DateUtils.now()
    }
    this.cards.push(...cards)
  }

  markResult(cardId: string, result: string): void {
    const card = this.cards.find(c => c.id === cardId)
    if (card) {
      card.lastResult = result
      card.reviewedCount++
      if (result === 'wrong') {
        card.isWrong = true
      }
    }
  }

  markMastered(cardId: string): void {
    const card = this.cards.find(c => c.id === cardId)
    if (card) {
      card.isWrong = false
    }
  }

  clearCards(): void {
    this.cards = []
  }

  getTotalCount(): number {
    return this.cards.length
  }

  getReviewedCount(): number {
    return this.cards.filter(c => c.reviewedCount > 0).length
  }

  getWrongCount(): number {
    return this.cards.filter(c => c.isWrong).length
  }
}
