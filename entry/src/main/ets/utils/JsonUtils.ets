/**
 * StudyFlow OS - JSON工具类
 */

export class JsonUtils {
  /**
   * 安全 JSON 解析
   * 解析失败返回 null
   */
  static safeParse<T>(jsonStr: string): T | null {
    try {
      return JSON.parse(jsonStr) as T
    } catch (e) {
      console.error('JsonUtils.safeParse error:', JSON.stringify(e))
      return null
    }
  }

  /**
   * 安全 JSON 序列化
   */
  static safeStringify(obj: Object): string {
    try {
      return JSON.stringify(obj, null, 2)
    } catch (e) {
      console.error('JsonUtils.safeStringify error:', JSON.stringify(e))
      return '{}'
    }
  }

  /**
   * 从 DeepSeek 响应中提取 JSON
   * 处理 markdown 代码块包裹的情况
   */
  static extractJson(response: string): string {
    // 尝试匹配 ```json ... ``` 代码块
    const codeBlockMatch = response.match(/```json\s*([\s\S]*?)\s*```/)
    if (codeBlockMatch) {
      return codeBlockMatch[1].trim()
    }

    // 尝试匹配 ``` ... ``` 代码块
    const genericBlockMatch = response.match(/```\s*([\s\S]*?)\s*```/)
    if (genericBlockMatch) {
      return genericBlockMatch[1].trim()
    }

    // 尝试匹配第一个 { 到最后一个 }
    const firstBrace = response.indexOf('{')
    const lastBrace = response.lastIndexOf('}')
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      return response.substring(firstBrace, lastBrace + 1)
    }

    return response.trim()
  }

  /**
   * 验证是否为有效JSON
   */
  static isValidJson(str: string): boolean {
    try {
      JSON.parse(str)
      return true
    } catch (e) {
      return false
    }
  }
}
