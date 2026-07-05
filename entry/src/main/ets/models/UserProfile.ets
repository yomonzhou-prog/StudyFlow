/**
 * StudyFlow OS - 用户资料数据模型
 * 管理用户登录、学习统计和偏好信息
 */

export interface UserProfile {
  id: string
  username: string
  email: string
  avatar: string
  /** 连续学习天数 */
  streak: number
  /** 累计学习分钟数 */
  totalStudyMinutes: number
  /** 学习卡片总数 */
  totalCards: number
  /** 已掌握知识点数 */
  totalMastered: number
  /** 上次学习日期 ISO格式 */
  lastStudyDate: string
  createdAt: string
  isLoggedIn: boolean
  isGuest: boolean
}
