/**
 * StudyFlow OS - 课程解析Agent
 * 负责调用DeepSeek API解析课程资料，生成CourseProfile
 * 页面层必须通过此Agent调用，不得直接使用DeepSeekClient
 */

import { CourseMaterial } from '../models/CourseMaterial'
import { CourseProfile } from '../models/CourseProfile'
import { DeepSeekClient } from './DeepSeekClient'
import { PromptBuilder } from './PromptBuilder'
import { SafeParser, ParseResult } from '../utils/SafeParser'
import { JsonUtils } from '../utils/JsonUtils'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'
import { MockData } from './MockData'

export class CourseParserAgent {
  private static instance: CourseParserAgent
  private deepSeekClient: DeepSeekClient

  private constructor() {
    this.deepSeekClient = DeepSeekClient.getInstance()
  }

  static getInstance(): CourseParserAgent {
    if (!CourseParserAgent.instance) {
      CourseParserAgent.instance = new CourseParserAgent()
    }
    return CourseParserAgent.instance
  }

  /**
   * 解析课程资料，生成课程画像
   * 失败时自动降级到MockData
   */
  async parseCourse(material: CourseMaterial): Promise<ParseResult<CourseProfile>> {
    try {
      // 构建Prompt
      const systemPrompt = PromptBuilder.courseAnalysisSystemPrompt()
      const userMessage = PromptBuilder.buildCourseAnalysisUserMessage(material)

      // 调用DeepSeek
      const response = await this.deepSeekClient.chat(systemPrompt, userMessage)

      if (!response.success || response.isMockFallback) {
        console.info('CourseParserAgent: DeepSeek调用失败，降级MockData:', response.errorMessage)
        return this.getMockProfile(material.id)
      }

      // 解析JSON响应
      const jsonStr = JsonUtils.extractJson(response.content)
      const parseResult = SafeParser.parseCourseProfile(jsonStr, false)

      if (!parseResult.isSuccess() || !parseResult.data) {
        console.info('CourseParserAgent: JSON解析失败，降级MockData:', parseResult.errorMessage)
        return this.getMockProfile(material.id)
      }

      // 补全profile字段
      const profile = parseResult.data
      profile.id = IdUtils.generate()
      profile.materialId = material.id
      profile.courseName = material.courseName
      profile.createdAt = DateUtils.now()
      profile.isMockData = false

      return new ParseResult<CourseProfile>(profile, false, '')
    } catch (error) {
      console.error('CourseParserAgent.parseCourse error:', JSON.stringify(error))
      return this.getMockProfile(material.id)
    }
  }

  /**
   * 获取Mock课程画像
   */
  private getMockProfile(materialId: string): ParseResult<CourseProfile> {
    const profile = MockData.getSampleProfile_probability()
    profile.materialId = materialId
    profile.isMockData = true
    return new ParseResult<CourseProfile>(profile, true, '使用MockData（AI服务不可用或为Mock模式）')
  }
}
