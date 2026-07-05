/**
 * StudyFlow OS - 日期工具类
 */

export class DateUtils {
  /**
   * 获取当前 ISO 日期字符串
   */
  static now(): string {
    return new Date().toISOString()
  }

  /**
   * 获取今天的日期字符串 YYYY-MM-DD
   */
  static today(): string {
    const d = new Date()
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  }

  /**
   * 获取N天后的日期
   */
  static daysLater(days: number): string {
    const d = new Date()
    d.setDate(d.getDate() + days)
    return d.toISOString()
  }

  /**
   * 获取N天前的日期
   */
  static daysAgo(days: number): string {
    const d = new Date()
    d.setDate(d.getDate() - days)
    return d.toISOString()
  }

  /**
   * 格式化显示日期
   */
  static formatDate(isoStr: string): string {
    const d = new Date(isoStr)
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    return `${month}月${day}日`
  }

  /**
   * 格式化显示日期时间
   */
  static formatDateTime(isoStr: string): string {
    const d = new Date(isoStr)
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    const hour = String(d.getHours()).padStart(2, '0')
    const min = String(d.getMinutes()).padStart(2, '0')
    return `${month}月${day}日 ${hour}:${min}`
  }

  /**
   * 检查是否在N天内截止
   */
  static isWithinDays(isoStr: string, days: number): boolean {
    const target = new Date(isoStr).getTime()
    const now = Date.now()
    const diff = target - now
    return diff >= 0 && diff <= days * 24 * 60 * 60 * 1000
  }

  /**
   * 检查是否在今天截止
   */
  static isToday(isoStr: string): boolean {
    return DateUtils.isWithinDays(isoStr, 1) &&
      new Date(isoStr).toDateString() === new Date().toDateString()
  }

  /**
   * 检查是否已过期
   */
  static isOverdue(isoStr: string): boolean {
    return new Date(isoStr).getTime() < Date.now()
  }
}
