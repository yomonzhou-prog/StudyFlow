/**
 * StudyFlow OS - ID生成工具
 */

export class IdUtils {
  /**
   * 生成唯一ID
   */
  static generate(): string {
    const timestamp = Date.now().toString(36)
    const random = Math.random().toString(36).substring(2, 8)
    return `${timestamp}-${random}`
  }

  /**
   * 生成短ID（8位）
   */
  static shortId(): string {
    return Math.random().toString(36).substring(2, 10)
  }
}
