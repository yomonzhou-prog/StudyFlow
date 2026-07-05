/**
 * StudyFlow OS - 安全解析器
 * 统一处理 DeepSeek 返回 JSON 的解析与 Mock 降级
 */

import { JsonUtils } from './JsonUtils'
import { CourseProfile } from '../models/CourseProfile'

export class ParseResult<T> {
  data: T | null = null
  isMock: boolean = false
  errorMessage: string = ''

  constructor(data: T | null, isMock: boolean, errorMessage: string) {
    this.data = data
    this.isMock = isMock
    this.errorMessage = errorMessage
  }

  isSuccess(): boolean {
    return this.data !== null
  }
}

export class SafeParser {
  /**
   * 安全解析课程画像
   * API结果解析失败时返回null，由调用方降级到MockData
   */
  static parseCourseProfile(rawJson: string, isMock: boolean): ParseResult<CourseProfile> {
    try {
      const jsonStr = JsonUtils.extractJson(rawJson)
      const parsed = JSON.parse(jsonStr) as CourseProfile
      if (!parsed || !parsed.courseName) {
        return new ParseResult<CourseProfile>(null, true, '解析结果缺少必要字段')
      }
      return new ParseResult<CourseProfile>(parsed, isMock, '')
    } catch (e) {
      return new ParseResult<CourseProfile>(null, true, `JSON解析失败: ${e}`)
    }
  }

  /**
   * 通用安全解析
   */
  static parse<T>(rawJson: string, validator?: (obj: T) => boolean): ParseResult<T> {
    try {
      const jsonStr = JsonUtils.extractJson(rawJson)
      const parsed = JSON.parse(jsonStr) as T
      if (validator && !validator(parsed)) {
        return new ParseResult<T>(null, true, '数据校验失败')
      }
      return new ParseResult<T>(parsed, false, '')
    } catch (e) {
      return new ParseResult<T>(null, true, `JSON解析失败: ${e}`)
    }
  }
}
