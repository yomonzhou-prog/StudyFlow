/**
 * StudyFlow OS - 复习题解析Agent
 * 将一段复习题文本拆分为 QuestionCard[]
 * 优先调用 DeepSeek，失败时使用本地规则 + MockData
 */

import { QuestionCard } from '../models/QuestionCard'
import { DeepSeekClient } from './DeepSeekClient'
import { PromptBuilder } from './PromptBuilder'
import { SafeParser, ParseResult } from '../utils/SafeParser'
import { JsonUtils } from '../utils/JsonUtils'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

interface ExamParseApiResult {
  courseName: string
  questions: QuestionCard[]
}

export class ExamPaperParserAgent {
  private static instance: ExamPaperParserAgent
  private deepSeekClient: DeepSeekClient

  private constructor() {
    this.deepSeekClient = DeepSeekClient.getInstance()
  }

  static getInstance(): ExamPaperParserAgent {
    if (!ExamPaperParserAgent.instance) {
      ExamPaperParserAgent.instance = new ExamPaperParserAgent()
    }
    return ExamPaperParserAgent.instance
  }

  /**
   * 解析复习题文本 → QuestionCard[]
   */
  async parseExamText(rawText: string, courseName: string): Promise<ParseResult<QuestionCard[]>> {
    try {
      const systemPrompt = PromptBuilder.examParsingSystemPrompt()
      const userMessage = PromptBuilder.buildExamParsingUserMessage(rawText, courseName)

      const response = await this.deepSeekClient.chat(systemPrompt, userMessage)

      if (!response.success || response.isMockFallback) {
        console.info('ExamPaperParserAgent: API failed, falling back to local parse:', response.errorMessage)
        return this.parseLocal(rawText, courseName)
      }

      const jsonStr = JsonUtils.extractJson(response.content)
      const parseResult = SafeParser.parse<ExamParseApiResult>(jsonStr, (obj) => {
        return obj && Array.isArray(obj.questions) && obj.questions.length > 0
      })

      if (!parseResult.isSuccess() || !parseResult.data) {
        console.info('ExamPaperParserAgent: JSON parse failed, falling back to local:', parseResult.errorMessage)
        return this.parseLocal(rawText, courseName)
      }

      const cards: QuestionCard[] = parseResult.data.questions.map((q: QuestionCard) => {
        q.id = IdUtils.generate()
        q.courseName = parseResult.data ? parseResult.data.courseName || courseName : courseName
        q.sourcePaperId = ''
        q.isWrong = false
        q.reviewedCount = 0
        q.lastResult = ''
        q.createdAt = DateUtils.now()
        return q
      })

      return new ParseResult<QuestionCard[]>(cards, false, '')
    } catch (err) {
      console.error('ExamPaperParserAgent.parseExamText error:', JSON.stringify(err))
      return this.parseLocal(rawText, courseName)
    }
  }

  /**
   * 本地规则拆分（Mock fallback）
   */
  private parseLocal(rawText: string, courseName: string): ParseResult<QuestionCard[]> {
    const cards: QuestionCard[] = []
    const blocks = rawText.split(/\n\s*\n/)

    for (let i = 0; i < blocks.length; i++) {
      const block = blocks[i].trim()
      if (!block) continue

      // Match numbered questions: "1." "2." "第1题" etc.
      const isQuestion = /^(\d+[.、)）]|第\d+题)/.test(block)
      if (!isQuestion && cards.length === 0) continue

      const card: QuestionCard = {
        id: IdUtils.generate(),
        courseName: courseName,
        question: block.split('\n')[0].replace(/^\d+[.、)）]\s*/, '').trim(),
        options: ['A. ', 'B. ', 'C. ', 'D. '],
        answer: '',
        explanation: '请查看答案后手动记录解析',
        relatedKnowledge: [],
        difficulty: 'medium',
        commonMistake: '',
        sourcePaperId: '',
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now()
      }

      // Extract options if present
      const optionPattern = /([A-D])[.、]\s*(.+)/g
      const opts: string[] = []
      let match = optionPattern.exec(block)
      while (match) {
        opts.push(`${match[1]}. ${match[2]}`)
        match = optionPattern.exec(block)
      }
      if (opts.length === 4) {
        card.options = opts
      } else {
        card.options = [
          'A. 选项A',
          'B. 选项B',
          'C. 选项C',
          'D. 选项D'
        ]
      }

      // Try to extract answer
      const answerMatch = block.match(/答案[：:]\s*([A-D])/)
      if (answerMatch) {
        card.answer = answerMatch[1]
      }

      // Try to extract explanation
      const explainMatch = block.match(/解析[：:]\s*(.+)/)
      if (explainMatch) {
        card.explanation = explainMatch[1]
      }

      cards.push(card)
    }

    // Fallback: if no questions parsed, use MockData
    if (cards.length === 0) {
      return this.getMockCards(courseName)
    }

    return new ParseResult<QuestionCard[]>(cards, true, '使用本地规则拆分')
  }

  /**
   * Mock题目卡片
   */
  getMockCards(courseName?: string): ParseResult<QuestionCard[]> {
    const name = courseName || '概率论与数理统计'
    const cards: QuestionCard[] = [
      {
        id: IdUtils.generate(),
        courseName: name,
        question: '设离散型随机变量X的分布律为P(X=1)=0.3, P(X=2)=0.5, P(X=3)=0.2，求E(X)',
        options: ['A. 1.5', 'B. 1.9', 'C. 2.0', 'D. 2.1'],
        answer: 'B',
        explanation: 'E(X)=1×0.3+2×0.5+3×0.2=0.3+1.0+0.6=1.9',
        relatedKnowledge: ['数学期望', '离散型随机变量'],
        difficulty: 'easy',
        commonMistake: '忘记乘以对应概率',
        sourcePaperId: '',
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now()
      },
      {
        id: IdUtils.generate(),
        courseName: name,
        question: '已知E(X)=5，则E(2X+3)等于？',
        options: ['A. 10', 'B. 13', 'C. 16', 'D. 8'],
        answer: 'B',
        explanation: '利用线性性质：E(2X+3)=2E(X)+3=2×5+3=13',
        relatedKnowledge: ['数学期望', '期望的性质'],
        difficulty: 'easy',
        commonMistake: '忽略常数项+3',
        sourcePaperId: '',
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now()
      },
      {
        id: IdUtils.generate(),
        courseName: name,
        question: '设随机变量X满足E(X)=3，E(X²)=13，则D(X)等于？',
        options: ['A. 4', 'B. 10', 'C. 13', 'D. 16'],
        answer: 'A',
        explanation: 'D(X)=E(X²)-[E(X)]²=13-9=4',
        relatedKnowledge: ['方差', '方差计算公式'],
        difficulty: 'medium',
        commonMistake: '混淆方差定义式和计算式',
        sourcePaperId: '',
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now()
      },
      {
        id: IdUtils.generate(),
        courseName: name,
        question: '设X~B(10,0.3)，则D(X)等于？',
        options: ['A. 3', 'B. 2.1', 'C. 7', 'D. 0.21'],
        answer: 'B',
        explanation: '二项分布D(X)=np(1-p)=10×0.3×0.7=2.1',
        relatedKnowledge: ['二项分布', '方差'],
        difficulty: 'medium',
        commonMistake: '忘记乘(1-p)',
        sourcePaperId: '',
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now()
      },
      {
        id: IdUtils.generate(),
        courseName: name,
        question: '若X与Y相互独立，则Cov(X,Y)等于？',
        options: ['A. 1', 'B. E(XY)', 'C. 0', 'D. D(X)'],
        answer: 'C',
        explanation: '独立时E(XY)=E(X)E(Y)，Cov(X,Y)=E(XY)-E(X)E(Y)=0',
        relatedKnowledge: ['协方差', '独立性'],
        difficulty: 'medium',
        commonMistake: 'Cov=0不能推出独立，但独立可推出Cov=0',
        sourcePaperId: '',
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now()
      },
      {
        id: IdUtils.generate(),
        courseName: name,
        question: '相关系数ρ_XY的取值范围是？',
        options: ['A. [0,1]', 'B. (-∞,+∞)', 'C. [-1,1]', 'D. [0,+∞)'],
        answer: 'C',
        explanation: '|ρ|≤1，ρ=±1表示完全线性相关，ρ=0表示不线性相关',
        relatedKnowledge: ['相关系数'],
        difficulty: 'easy',
        commonMistake: 'ρ=0只说明不线性相关，不能说明独立',
        sourcePaperId: '',
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now()
      },
      {
        id: IdUtils.generate(),
        courseName: name,
        question: '设连续型随机变量X的概率密度为f(x)=2x (0<x<1)，则E(X)等于？',
        options: ['A. 1/3', 'B. 2/3', 'C. 1/2', 'D. 1'],
        answer: 'B',
        explanation: 'E(X)=∫₀¹ x·2x dx=2∫₀¹ x² dx=2·(1/3)=2/3',
        relatedKnowledge: ['数学期望', '连续型随机变量'],
        difficulty: 'hard',
        commonMistake: '积分上下限取错',
        sourcePaperId: '',
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now()
      },
      {
        id: IdUtils.generate(),
        courseName: name,
        question: '设X~P(λ)（泊松分布），则E(X)和D(X)分别等于？',
        options: ['A. E=λ, D=λ²', 'B. E=λ, D=λ', 'C. E=1/λ, D=1/λ', 'D. E=λ, D=1/λ'],
        answer: 'B',
        explanation: '泊松分布的期望和方差都等于参数λ，这是重要特征',
        relatedKnowledge: ['泊松分布', '常见分布'],
        difficulty: 'hard',
        commonMistake: '忘记泊松分布E=D=λ的结论',
        sourcePaperId: '',
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now()
      }
    ]
    return new ParseResult<QuestionCard[]>(cards, true, '使用Mock题目数据')
  }
}
