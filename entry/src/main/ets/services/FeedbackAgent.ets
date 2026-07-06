/**
 * StudyFlow OS - 反馈处理Agent
 * 负责分析学习反馈，生成二次复习建议和新任务
 * 页面层必须通过此Agent调用，不得直接使用DeepSeekClient
 */

import { LearningFeedback } from '../models/LearningFeedback'
import { StudyTask } from '../models/StudyTask'
import { ReviewCard } from '../models/ReviewCard'
import { DeepSeekClient } from './DeepSeekClient'
import { PromptBuilder } from './PromptBuilder'
import { SafeParser, ParseResult } from '../utils/SafeParser'
import { JsonUtils } from '../utils/JsonUtils'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

export interface FeedbackAnalysisResult {
  analysis: string
  newTasks: StudyTask[]
  summary: string
}

export class FeedbackAgent {
  private static instance: FeedbackAgent
  private deepSeekClient: DeepSeekClient

  private constructor() {
    this.deepSeekClient = DeepSeekClient.getInstance()
  }

  static getInstance(): FeedbackAgent {
    if (!FeedbackAgent.instance) {
      FeedbackAgent.instance = new FeedbackAgent()
    }
    return FeedbackAgent.instance
  }

  /**
   * 分析学习反馈，生成二次复习计划
   * 失败时自动降级到本地规则生成
   */
  async analyzeFeedback(
    feedbacks: LearningFeedback[],
    reviewCards: ReviewCard[]
  ): Promise<ParseResult<FeedbackAnalysisResult>> {
    try {
      if (feedbacks.length === 0) {
        return new ParseResult<FeedbackAnalysisResult>(
          { analysis: '暂无学习反馈', newTasks: [], summary: '请先完成复习卡片自测' },
          true,
          '无反馈数据'
        )
      }

      const systemPrompt = PromptBuilder.feedbackAnalysisSystemPrompt()
      const userMessage = PromptBuilder.buildFeedbackAnalysisUserMessage(feedbacks)

      const response = await this.deepSeekClient.chat(systemPrompt, userMessage)

      if (!response.success || response.isMockFallback) {
        console.info('FeedbackAgent: DeepSeek调用失败，降级本地规则:', response.errorMessage)
        return this.generateLocalFeedbackPlan(feedbacks, reviewCards)
      }

      const jsonStr = JsonUtils.extractJson(response.content)

      interface FeedbackResponse {
        analysis: string
        newTasks: StudyTask[]
        summary: string
      }

      const parseResult = SafeParser.parse<FeedbackResponse>(jsonStr, (obj) => {
        return obj && typeof obj.analysis === 'string' && Array.isArray(obj.newTasks)
      })

      if (!parseResult.isSuccess() || !parseResult.data) {
        console.info('FeedbackAgent: JSON解析失败，降级本地规则:', parseResult.errorMessage)
        return this.generateLocalFeedbackPlan(feedbacks, reviewCards)
      }

      // 补全任务ID
      const tasks = parseResult.data.newTasks.map((task: StudyTask) => {
        task.id = IdUtils.generate()
        task.createdAt = DateUtils.now()
        if (!task.status) task.status = 'pending'
        return task
      })

      return new ParseResult<FeedbackAnalysisResult>(
        {
          analysis: parseResult.data.analysis,
          newTasks: tasks,
          summary: parseResult.data.summary
        },
        false,
        ''
      )
    } catch (error) {
      console.error('FeedbackAgent.analyzeFeedback error:', JSON.stringify(error))
      return this.generateLocalFeedbackPlan(feedbacks, reviewCards)
    }
  }

  /**
   * 本地规则生成复习计划（Mock降级方案）
   */
  private generateLocalFeedbackPlan(
    feedbacks: LearningFeedback[],
    reviewCards: ReviewCard[]
  ): ParseResult<FeedbackAnalysisResult> {
    const newTasks: StudyTask[] = []
    const fuzzyOrWrong: string[] = []
    const mastered: string[] = []

    for (const fb of feedbacks) {
      switch (fb.status) {
        case 'wrong':
          fuzzyOrWrong.push(fb.knowledgePointTitle)
          newTasks.push({
            id: IdUtils.generate(),
            title: `重新学习：${fb.knowledgePointTitle}`,
            courseName: '当前课程',
            description: `自测做错了，需要重新学习该知识点的全部内容。注意：${fb.note}`,
            priority: 'high',
            estimatedMinutes: 45,
            deadline: DateUtils.today(),
            status: 'pending',
            sourceType: 'weakness',
            relatedKnowledgePointIds: [fb.knowledgePointId],
            createdAt: DateUtils.now()
          })
          break
        case 'fuzzy':
          fuzzyOrWrong.push(fb.knowledgePointTitle)
          newTasks.push({
            id: IdUtils.generate(),
            title: `巩固复习：${fb.knowledgePointTitle}`,
            courseName: '当前课程',
            description: `理解不够透彻，需要再次复习并做补充练习`,
            priority: 'medium',
            estimatedMinutes: 30,
            deadline: DateUtils.daysLater(1),
            status: 'pending',
            sourceType: 'weakness',
            relatedKnowledgePointIds: [fb.knowledgePointId],
            createdAt: DateUtils.now()
          })
          break
        case 'mastered':
          mastered.push(fb.knowledgePointTitle)
          break
      }
    }

    const analysis = mastered.length > 0
      ? `已掌握${mastered.length}个知识点，但${fuzzyOrWrong.length}个知识点仍需加强。${fuzzyOrWrong.join('、')}建议优先复习。`
      : `${fuzzyOrWrong.length}个知识点需要加强复习。`

    const summary = fuzzyOrWrong.length > 0
      ? `重点复习${fuzzyOrWrong.join('、')}，建议每天投入1-2小时专项练习。`
      : '当前学习状态良好，继续保持！'

    return new ParseResult<FeedbackAnalysisResult>(
      { analysis, newTasks, summary },
      true,
      '使用本地规则生成复习计划'
    )
  }
}
