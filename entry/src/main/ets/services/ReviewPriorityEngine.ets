/**
 * StudyFlow OS - 复习优先级计算引擎
 * 综合四个维度计算复习优先级：
 *   老师强调 + 考试临近 + 错题反馈 + 知识点难度
 */

import { ReviewPriority } from '../models/ReviewPriority'
import { IdUtils } from '../utils/IdUtils'

interface ScoredItem {
  title: string
  courseName: string
  score: number
  reasons: string[]
}

export class ReviewPriorityEngine {
  private static instance: ReviewPriorityEngine

  static getInstance(): ReviewPriorityEngine {
    if (!ReviewPriorityEngine.instance) {
      ReviewPriorityEngine.instance = new ReviewPriorityEngine()
    }
    return ReviewPriorityEngine.instance
  }

  /**
   * 计算复习优先级
   * @param teacherFocusItems 老师强调的知识点标题
   * @param wrongItems 做错的知识点标题
   * @param examDaysLeft 距离考试天数
   * @param allKnowledgeItems 全部知识点 { title, courseName, difficulty }
   */
  calculatePriorities(
    teacherFocusItems: string[],
    wrongItems: string[],
    examDaysLeft: number,
    allKnowledgeItems: KnowledgeRef[]
  ): ReviewPriority[] {
    const scored: ScoredItem[] = []

    for (const item of allKnowledgeItems) {
      let score = 0
      const reasons: string[] = []

      // 老师强调：+40
      if (teacherFocusItems.some(t => item.title.includes(t) || t.includes(item.title))) {
        score += 40
        reasons.push('老师强调')
      }

      // 最近做错：+30
      if (wrongItems.some(w => item.title.includes(w) || w.includes(item.title))) {
        score += 30
        reasons.push('最近做错')
      }

      // 考试3天内：+20
      if (examDaysLeft <= 3) {
        score += 20
        if (!reasons.includes('考试临近')) {
          reasons.push('考试临近')
        }
      } else if (examDaysLeft <= 7) {
        score += 10
      }

      // 难度：hard +15, medium +5
      if (item.difficulty === 'hard') {
        score += 15
        reasons.push('难度较高')
      } else if (item.difficulty === 'medium') {
        score += 5
      }

      scored.push({
        title: item.title,
        courseName: item.courseName,
        score: score,
        reasons: reasons
      })
    }

    // 按分数降序排列
    scored.sort((a, b) => b.score - a.score)

    // 转换为 ReviewPriority
    const result: ReviewPriority[] = []
    for (const item of scored) {
      const level = item.score >= 50 ? 'high' : item.score >= 25 ? 'medium' : 'low'
      const estimatedMinutes = level === 'high' ? 25 : level === 'medium' ? 15 : 10

      result.push({
        id: IdUtils.generate(),
        courseName: item.courseName,
        knowledgeTitle: item.title,
        score: item.score,
        level: level,
        reasons: item.reasons.length > 0 ? item.reasons : ['常规复习'],
        suggestedAction: level === 'high'
          ? '今天优先复习，先看概念再做3道题'
          : level === 'medium'
            ? '近两天安排复习'
            : '有空时回顾即可',
        estimatedMinutes: estimatedMinutes
      })
    }

    return result
  }

  /**
   * 获取Mock优先级数据
   */
  getMockPriorities(): ReviewPriority[] {
    return this.calculatePriorities(
      ['最大似然估计', '方差计算', '协方差'],
      ['方差计算', '协方差', '二叉树遍历'],
      5,
      [
        { title: '方差定义与计算', courseName: '概率论与数理统计', difficulty: 'hard' },
        { title: '协方差与相关系数', courseName: '概率论与数理统计', difficulty: 'hard' },
        { title: '最大似然估计', courseName: '概率论与数理统计', difficulty: 'hard' },
        { title: '数学期望的性质', courseName: '概率论与数理统计', difficulty: 'medium' },
        { title: '二叉树遍历', courseName: '数据结构', difficulty: 'medium' },
        { title: '常见分布期望方差', courseName: '概率论与数理统计', difficulty: 'easy' },
        { title: '二叉搜索树', courseName: '数据结构', difficulty: 'medium' }
      ]
    )
  }
}

export interface KnowledgeRef {
  title: string
  courseName: string
  difficulty: string
}
