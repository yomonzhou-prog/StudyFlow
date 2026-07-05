/**
 * StudyFlow OS - 学习教练消息模型
 */

export interface CoachMessage {
  id: string
  /** 'user' | 'coach' */
  role: string
  /** 消息内容 */
  content: string
  /** ISO 时间戳 */
  timestamp: string
}

/**
 * 快捷提问卡片
 */
export interface CoachCard {
  id: string
  emoji: string
  title: string
  /** 点击后发送的提示词 */
  prompt: string
}
