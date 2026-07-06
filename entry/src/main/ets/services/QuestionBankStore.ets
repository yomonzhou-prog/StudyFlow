/**
 * StudyFlow OS - 题库状态管理
 * 管理题目和错题的本地存储
 */

import { QuestionItem } from '../models/QuestionItem'
import { WrongQuestion } from '../models/WrongQuestion'
import { MockData } from './MockData'
import { CourseStore } from './CourseStore'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

export class QuestionBankStore {
  private static instance: QuestionBankStore

  private questions: QuestionItem[] = []
  private wrongQuestions: WrongQuestion[] = []

  static getInstance(): QuestionBankStore {
    if (!QuestionBankStore.instance) {
      QuestionBankStore.instance = new QuestionBankStore()
    }
    return QuestionBankStore.instance
  }

  /**
   * 初始化 Mock 数据
   */
  initMockData(): void {
    this.questions = MockData.getSampleQuestions()
    this.wrongQuestions = MockData.getSampleWrongQuestions()
  }

  /**
   * 获取所有题目
   */
  getQuestions(): QuestionItem[] {
    return this.questions
  }

  /**
   * 根据课程筛选
   */
  getQuestionsByCourse(courseName: string): QuestionItem[] {
    return this.questions.filter(q => q.courseName === courseName)
  }

  /**
   * 根据章节筛选
   */
  getQuestionsByChapter(chapter: string): QuestionItem[] {
    return this.questions.filter(q => q.chapter === chapter)
  }

  /**
   * 根据知识点筛选
   */
  getQuestionsByKnowledgePoint(kpId: string): QuestionItem[] {
    return this.questions.filter(q => q.knowledgePointId === kpId)
  }

  /**
   * 根据难度筛选
   */
  getQuestionsByDifficulty(difficulty: string): QuestionItem[] {
    return this.questions.filter(q => q.difficulty === difficulty)
  }

  /**
   * 根据题目ID获取
   */
  getQuestionById(id: string): QuestionItem | undefined {
    return this.questions.find(q => q.id === id)
  }

  /**
   * 获取所有错题
   */
  getWrongQuestions(): WrongQuestion[] {
    return this.wrongQuestions
  }

  /**
   * 获取未掌握的错题
   */
  getUnmasteredWrongQuestions(): WrongQuestion[] {
    return this.wrongQuestions.filter(wq => !wq.isMastered)
  }

  /**
   * 添加错题
   */
  addWrongQuestion(question: QuestionItem, userAnswer: string): void {
    const kpTitle = this.resolveKnowledgePointTitle(question.knowledgePointId)
    const wq: WrongQuestion = {
      id: IdUtils.generate(),
      questionId: question.id,
      question: question.question,
      options: question.options,
      correctAnswer: question.correctAnswer,
      userAnswer: userAnswer,
      explanation: question.explanation,
      courseName: question.courseName,
      chapter: question.chapter,
      knowledgePointId: question.knowledgePointId,
      knowledgePointTitle: kpTitle,
      wrongTime: DateUtils.now(),
      reviewCount: 0,
      isMastered: false
    }
    this.wrongQuestions.unshift(wq)
  }

  /**
   * 根据知识点ID解析标题
   */
  private resolveKnowledgePointTitle(knowledgePointId: string): string {
    const profiles = CourseStore.getInstance().getProfiles()
    for (const profile of profiles) {
      const kp = profile.knowledgePoints.find(p => p.id === knowledgePointId)
      if (kp) {
        return kp.title
      }
    }
    return ''
  }

  /**
   * 标记错题已掌握
   */
  markWrongQuestionMastered(id: string): void {
    const wq = this.wrongQuestions.find(w => w.id === id)
    if (wq) {
      wq.isMastered = true
      wq.reviewCount++
    }
  }

  /**
   * 错题复习一次
   */
  reviewWrongQuestion(id: string): void {
    const wq = this.wrongQuestions.find(w => w.id === id)
    if (wq) {
      wq.reviewCount++
    }
  }

  /**
   * 获取课程列表（从题目中提取）
   */
  getCourseNames(): string[] {
    const names: string[] = []
    this.questions.forEach(q => {
      if (!names.includes(q.courseName)) {
        names.push(q.courseName)
      }
    })
    return names
  }

  /**
   * 清空数据
   */
  clear(): void {
    this.questions = []
    this.wrongQuestions = []
  }
}
