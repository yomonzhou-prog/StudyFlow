/**
 * StudyFlow OS - 学习教练 Agent
 * 处理学习教练对话，调用 DeepSeek API 生成回答
 * 失败时使用本地规则兜底
 */

import { DeepSeekClient, DeepSeekResponse } from './DeepSeekClient'
import { CoachMessage } from '../models/CoachMessage'
import { PlanStore } from './PlanStore'
import { CourseStore } from './CourseStore'
import { Constants } from '../common/Constants'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

export interface CoachResult {
  success: boolean
  content: string
  isMockFallback: boolean
  errorMessage?: string
}

export class CoachAgent {
  private static instance: CoachAgent

  private deepSeekClient: DeepSeekClient = new DeepSeekClient()
  private planStore: PlanStore = PlanStore.getInstance()
  private courseStore: CourseStore = CourseStore.getInstance()

  static getInstance(): CoachAgent {
    if (!CoachAgent.instance) {
      CoachAgent.instance = new CoachAgent()
    }
    return CoachAgent.instance
  }

  /**
   * 学习教练对话
   */
  async chat(userMessage: string, history: CoachMessage[]): Promise<CoachResult> {
    if (Constants.USE_MOCK) {
      return this.generateLocalResponse(userMessage)
    }

    try {
      const response: DeepSeekResponse = await this.deepSeekClient.chat(
        this.getSystemPrompt(),
        userMessage
      )
      if (response.success && response.content) {
        return {
          success: true,
          content: response.content,
          isMockFallback: false
        }
      }
      return this.generateLocalResponse(userMessage)
    } catch (_err) {
      return this.generateLocalResponse(userMessage)
    }
  }

  /**
   * 生成系统提示
   */
  private getSystemPrompt(): string {
    const profile = this.courseStore.getCurrentProfile()
    const weakPoints = this.planStore.getWeakKnowledgePoints()

    let context = '你是一位专业的学习教练，帮助学生解答学习问题。请用鼓励、友好的语气回答。回答要简洁，不超过200字。'

    if (profile) {
      context += `\n当前课程：${profile.courseName}`
    }
    if (weakPoints.length > 0) {
      const titles = weakPoints.slice(0, 3).map(w => w.title).join('、')
      context += `\n学生薄弱知识点：${titles}`
    }

    return context
  }

  /**
   * 本地规则兜底
   */
  private generateLocalResponse(userMessage: string): CoachResult {
    let content = ''

    const msg = userMessage.toLowerCase()

    if (msg.includes('计划') || msg.includes('建议') || msg.includes('复习')) {
      const weakPoints = this.planStore.getWeakKnowledgePoints()
      if (weakPoints.length > 0) {
        const titles = weakPoints.slice(0, 3).map(w => w.title).join('、')
        content = `📋 学习建议：\n\n你目前有 ${weakPoints.length} 个薄弱知识点，重点关注：${titles}。建议每天安排30分钟专门复习这些内容，配合复习卡片巩固。坚持就是胜利！💪`
      } else {
        content = '📋 太好了！你目前没有薄弱知识点。建议继续保持当前的学习节奏，可以尝试做一些综合练习来检验学习效果。'
      }
    } else if (msg.includes('进度') || msg.includes('统计') || msg.includes('情况')) {
      const tasks = this.planStore.getTasks()
      const cards = this.planStore.getReviewCards()
      const completed = tasks.filter(t => t.status === 'completed').length
      content = `📊 学习统计：\n\n📋 总任务：${tasks.length} | ✅ 已完成：${completed}\n🃏 复习卡片：${cards.length}\n🎯 薄弱点：${this.planStore.getWeakKnowledgePoints().length}\n\n继续保持好状态！🚀`
    } else if (msg.includes('方法') || msg.includes('怎么学') || msg.includes('技巧')) {
      content = '💡 学习方法建议：\n\n1. 间隔重复：每学完一个知识点，1天/3天/7天后分别复习\n2. 费曼技巧：试着用自己的话讲给别人听\n3. 主动回忆：看着知识点标题，尝试回忆内容\n4. 番茄工作法：25分钟专注 + 5分钟休息\n\n试着用这些方法提升效率吧！'
    } else if (msg.includes('鼓励') || msg.includes('加油') || msg.includes('动力')) {
      content = '🌟 你已经很棒了！每一次学习都是在为未来投资。记住：Rome wasn\'t built in a day。每天进步一点点，积少成多。相信自己，你可以的！💪🔥'
    } else {
      content = `👋 你好！我是你的学习教练。\n\n你可以问我：\n• "帮我制定学习计划"\n• "我的学习进度如何"\n• "有什么好的学习方法"\n• "鼓励我一下"\n\n试试看吧！😊`
    }

    return {
      success: true,
      content: content,
      isMockFallback: true
    }
  }
}
