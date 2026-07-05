/**
 * StudyFlow OS - 复习规划Agent
 * 负责根据课程画像生成复习卡片和学习任务
 * 页面层必须通过此Agent调用，不得直接使用DeepSeekClient
 */

import { CourseProfile } from '../models/CourseProfile'
import { ReviewCard } from '../models/ReviewCard'
import { StudyTask } from '../models/StudyTask'
import { KnowledgePoint } from '../models/KnowledgePoint'
import { DeepSeekClient } from './DeepSeekClient'
import { PromptBuilder } from './PromptBuilder'
import { SafeParser, ParseResult } from '../utils/SafeParser'
import { JsonUtils } from '../utils/JsonUtils'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'
import { MockData } from './MockData'

export interface ReviewPlanResult {
  reviewCards: ReviewCard[]
  newTasks: StudyTask[]
}

export class ReviewPlannerAgent {
  private static instance: ReviewPlannerAgent
  private deepSeekClient: DeepSeekClient

  private constructor() {
    this.deepSeekClient = DeepSeekClient.getInstance()
  }

  static getInstance(): ReviewPlannerAgent {
    if (!ReviewPlannerAgent.instance) {
      ReviewPlannerAgent.instance = new ReviewPlannerAgent()
    }
    return ReviewPlannerAgent.instance
  }

  /**
   * 根据课程画像生成复习卡片
   * 失败时自动降级到MockData
   */
  async generateReviewCards(profile: CourseProfile): Promise<ParseResult<ReviewCard[]>> {
    try {
      // 筛选需要生成卡片的知识点（高重要度和中高难度优先）
      const targetKps = profile.knowledgePoints
        .filter(kp => kp.importance === 'critical' || kp.importance === 'high' || kp.difficulty === 'hard')
        .slice(0, 8)

      const systemPrompt = PromptBuilder.reviewCardSystemPrompt()
      const userMessage = PromptBuilder.buildReviewCardUserMessage(targetKps)

      const response = await this.deepSeekClient.chat(systemPrompt, userMessage)

      if (!response.success || response.isMockFallback) {
        console.info('ReviewPlannerAgent: DeepSeek调用失败，降级MockData:', response.errorMessage)
        return this.getMockReviewCards(profile)
      }

      const jsonStr = JsonUtils.extractJson(response.content)

      interface ReviewCardResponse {
        reviewCards: ReviewCard[]
      }

      const parseResult = SafeParser.parse<ReviewCardResponse>(jsonStr, (obj) => {
        return obj && Array.isArray(obj.reviewCards) && obj.reviewCards.length > 0
      })

      if (!parseResult.isSuccess() || !parseResult.data) {
        console.info('ReviewPlannerAgent: JSON解析失败，降级MockData:', parseResult.errorMessage)
        return this.getMockReviewCards(profile)
      }

      // 补充ID和时间信息
      const cards = parseResult.data.reviewCards.map((card: ReviewCard) => {
        card.id = IdUtils.generate()
        card.profileId = profile.id
        card.reviewCount = 0
        card.lastFeedbackStatus = ''
        return card
      })

      return new ParseResult<ReviewCard[]>(cards, false, '')
    } catch (error) {
      console.error('ReviewPlannerAgent.generateReviewCards error:', JSON.stringify(error))
      return this.getMockReviewCards(profile)
    }
  }

  /**
   * 根据课程画像拆解学习任务
   * 失败时自动降级到MockData
   */
  async generateStudyTasks(profile: CourseProfile): Promise<ParseResult<StudyTask[]>> {
    try {
      // 从课程画像中提取任务
      const tasks: StudyTask[] = []

      // 将作业任务转为StudyTask
      for (const hw of profile.homeworkTasks) {
        tasks.push({
          id: IdUtils.generate(),
          title: hw.title,
          courseName: profile.courseName,
          description: hw.description,
          priority: hw.priority,
          estimatedMinutes: 60,
          deadline: hw.deadline,
          status: 'pending',
          sourceType: 'homework',
          relatedKnowledgePointIds: [],
          createdAt: DateUtils.now()
        })
      }

      // 为每个危险级别为high的风险生成复习任务
      for (const risk of profile.riskWarnings.filter(r => r.level === 'high')) {
        tasks.push({
          id: IdUtils.generate(),
          title: `复习：${risk.message}`,
          courseName: profile.courseName,
          description: risk.suggestion,
          priority: 'high',
          estimatedMinutes: 45,
          deadline: DateUtils.daysLater(1),
          status: 'pending',
          sourceType: 'weakness',
          relatedKnowledgePointIds: [],
          createdAt: DateUtils.now()
        })
      }

      return new ParseResult<StudyTask[]>(tasks, profile.isMockData, '')
    } catch (error) {
      console.error('ReviewPlannerAgent.generateStudyTasks error:', JSON.stringify(error))
      return new ParseResult<StudyTask[]>(MockData.getSampleTasks(), true, '使用Mock任务数据')
    }
  }

  /**
   * 获取Mock复习卡片
   */
  private getMockReviewCards(profile: CourseProfile): ParseResult<ReviewCard[]> {
    const cards = MockData.getSampleReviewCards_probability()
    cards.forEach(c => { c.profileId = profile.id })
    return new ParseResult<ReviewCard[]>(cards, true, '使用Mock复习卡片（AI服务不可用或为Mock模式）')
  }
}
