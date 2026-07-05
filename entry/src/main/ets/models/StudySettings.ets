/**
 * StudyFlow OS - 学习设置数据模型
 */

export interface StudySettings {
  /** 每日学习目标（分钟） */
  dailyStudyGoal: number
  /** 每日新卡片数 */
  dailyNewCards: number
  /** 每日复习卡片数 */
  dailyReviewCards: number
  /** 提醒时间 (HH:mm 格式，空字符串表示关闭) */
  reminderTime: string
  /** 是否开启学习提醒 */
  reminderEnabled: boolean
  /** 是否显示Mock数据提示 */
  showMockBanner: boolean
  /** 主题模式: 'light' | 'dark' */
  themeMode: string
}
