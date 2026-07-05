/**
 * StudyFlow OS - 知识点数据模型
 * 知识点卡片的核心数据
 */

export interface KnowledgePoint {
  id: string
  profileId: string
  title: string                    // 知识点标题
  chapter: string                  // 所属章节
  explanation: string              // 解释
  importance: string               // critical | high | medium | low
  difficulty: string               // hard | medium | easy
  commonMistakes: string[]         // 常见错误
  relatedKnowledgePointIds: string[] // 相关知识点
  order: number                    // 排序
}
