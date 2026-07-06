/**
 * StudyFlow OS - 复习优先级数据模型
 */

export interface ReviewPriority {
  id: string
  courseName: string
  knowledgeTitle: string
  score: number
  level: 'high' | 'medium' | 'low'
  reasons: string[]         // e.g. ["老师强调", "最近做错", "考试高频"]
  suggestedAction: string   // 建议行动
  estimatedMinutes: number
}
