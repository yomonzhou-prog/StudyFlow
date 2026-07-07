/**
 * StudyFlow OS - 复习卡片页
 * 展示复习卡片、自测题、反馈入口，实现闭环关键节点
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { CourseStore } from '../services/CourseStore'
import { PlanStore } from '../services/PlanStore'
import { ReviewCard } from '../models/ReviewCard'
import { LearningFeedback } from '../models/LearningFeedback'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'
import { ReviewCardView } from '../components/ReviewCardView'
import { EmptyState } from '../components/EmptyState'
import { FeedbackAgent } from '../services/FeedbackAgent'
import { PageHeader } from '../components/PageHeader'
import { LoadingView } from '../components/LoadingView'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'

@Entry
@Component
struct ReviewCardPage {
  @State reviewCards: ReviewCard[] = []
  @State currentCardIndex: number = 0
  @State showAnswer: boolean = false
  @State isLoading: boolean = true
  @State feedbackSubmitted: boolean = false
  @State lastFeedbackStatus: string = ''
  @State nextReviewSuggestion: string = ''

  private courseStore: CourseStore = CourseStore.getInstance()
  private planStore: PlanStore = PlanStore.getInstance()

  aboutToAppear(): void {
    this.loadData()
  }

  loadData(): void {
    if (this.planStore.getReviewCards().length === 0) {
      this.courseStore.initMockData()
      this.planStore.initMockData()
    }

    this.reviewCards = this.planStore.getReviewCards()
    this.isLoading = false
  }

  getCurrentCard(): ReviewCard | null {
    if (this.reviewCards.length === 0) return null
    return this.reviewCards[this.currentCardIndex]
  }

  handleShowAnswer(): void {
    this.showAnswer = true
  }

  async handleFeedback(status: string): Promise<void> {
    const card = this.getCurrentCard()
    if (!card) return

    // 保存反馈
    const feedback: LearningFeedback = {
      id: IdUtils.generate(),
      reviewCardId: card.id,
      knowledgePointId: card.knowledgePointId,
      knowledgePointTitle: card.knowledgePointTitle,
      status: status,
      timestamp: DateUtils.now(),
      note: this.getFeedbackNote(status)
    }
    this.planStore.addFeedback(feedback)
    this.planStore.updateReviewCardFeedback(card.id, status)

    this.feedbackSubmitted = true
    this.lastFeedbackStatus = status

    // 调用 FeedbackAgent 分析反馈并生成新任务
    const feedbackAgent = FeedbackAgent.getInstance()
    const allFeedbacks = this.planStore.getFeedbacks()
    const analyzeResult = await feedbackAgent.analyzeFeedback(allFeedbacks, this.reviewCards)

    if (analyzeResult.data) {
      // 合并新任务到 PlanStore
      if (analyzeResult.data.newTasks.length > 0) {
        this.planStore.addTasks(analyzeResult.data.newTasks)
      }
      // 使用Agent分析结果作为建议（如果有的话）
      this.nextReviewSuggestion = analyzeResult.data.analysis.length > 0
        ? `${analyzeResult.data.analysis}\n\n${analyzeResult.data.summary}`
        : this.generateLocalSuggestion(status, card)

      const modeLabel = analyzeResult.isMock ? '本地规则' : '智能分析'
      promptAction.showToast({
        message: `反馈已保存（${modeLabel}）`,
        duration: 2000
      })
    } else {
      // 降级本地建议
      this.nextReviewSuggestion = this.generateLocalSuggestion(status, card)
      promptAction.showToast({
        message: `反馈已保存：${Constants.FEEDBACK_LABELS[status]}`,
        duration: 2000
      })
    }
  }

  generateLocalSuggestion(status: string, card: ReviewCard): string {
    switch (status) {
      case 'mastered':
        return `「${card.knowledgePointTitle}」已掌握，建议3天后简短回顾，重点转向薄弱知识点。`
      case 'fuzzy':
        return `「${card.knowledgePointTitle}」还模糊，建议明天重新复习，重点看：${card.keyReminder}。已生成强化任务。`
      case 'wrong':
        return `「${card.knowledgePointTitle}」做错了！建议今天内重新学习，重点关注常见错误：${card.commonMistakes.join('、')}。已生成紧急复习任务。`
      default:
        return '请继续复习该知识点。'
    }
  }

  getFeedbackNote(status: string): string {
    switch (status) {
      case 'mastered': return '已完全掌握该知识点'
      case 'fuzzy': return '理解不够深刻，需要再次复习'
      case 'wrong': return '概念错误或计算失误，需要重新学习'
      default: return ''
    }
  }

  handleNextCard(): void {
    if (this.currentCardIndex < this.reviewCards.length - 1) {
      this.currentCardIndex++
      this.showAnswer = false
      this.feedbackSubmitted = false
      this.lastFeedbackStatus = ''
    } else {
      // 所有卡片已完成
      promptAction.showToast({
        message: '所有复习卡片已完成！',
        duration: 2000
      })
    }
  }

  handlePrevCard(): void {
    if (this.currentCardIndex > 0) {
      this.currentCardIndex--
      this.showAnswer = false
      this.feedbackSubmitted = false
      this.lastFeedbackStatus = ''
    }
  }

  handleViewPlan(): void {
    router.pushUrl({ url: 'pages/PlanPage' })
  }

  build() {
    Column() {
      PageHeader({ title: '复习卡片' })

      if (this.isLoading) {
        LoadingView({ message: '加载复习卡片...' })
      } else if (this.reviewCards.length === 0) {
        Column() {
          EmptyState({ icon: '📭', message: '暂无复习卡片，请先生成' })
          PrimaryButton({ label: '返回', onAction: () => { router.back() } })
        }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            // 进度指示
            this.buildProgressBar()

            // 当前卡片
            if (this.getCurrentCard()) {
              ReviewCardView({
                reviewCard: this.getCurrentCard()!,
                showAnswer: this.showAnswer,
                onShowAnswer: () => { this.handleShowAnswer() },
                onFeedback: (status: string) => { this.handleFeedback(status) }
              })
            }

            // 反馈结果展示
            if (this.feedbackSubmitted) {
              this.buildFeedbackResult()
            }

            // 导航按钮
            this.buildNavigationButtons()

          }
          .width('100%')
          .padding({ bottom: 40 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  buildProgressBar() {
    Column() {
      Row() {
        Text(`第 ${this.currentCardIndex + 1} / ${this.reviewCards.length} 张`)
          .fontSize(Theme.FONT_SM)
          .fontColor(Theme.TEXT_SECONDARY)

        Blank()

        // 状态指示
        ForEach(this.reviewCards.slice(0, Math.min(8, this.reviewCards.length)), (card: ReviewCard, index: number) => {
          Text(index === this.currentCardIndex ? '●' : (card.lastFeedbackStatus ? '✓' : '○'))
            .fontSize(12)
            .fontColor(index === this.currentCardIndex ? Theme.PRIMARY :
              (card.lastFeedbackStatus === 'mastered' ? Theme.SUCCESS :
              (card.lastFeedbackStatus === 'wrong' ? Theme.DANGER : Theme.TEXT_HINT)))
            .margin({ left: 2, right: 2 })
        })
      }
      .width('100%')
      .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
    }
    .width('100%')
  }

  @Builder
  buildFeedbackResult() {
    Column() {
      // 反馈状态
      Row() {
        Text(this.getFeedbackEmoji(this.lastFeedbackStatus))
          .fontSize(32)
        Text(this.getFeedbackTitle(this.lastFeedbackStatus))
          .fontSize(Theme.FONT_LG)
          .fontColor(this.getFeedbackColor(this.lastFeedbackStatus))
          .fontWeight(FontWeight.Bold)
          .margin({ left: Theme.SPACING_SM })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 二次复习建议
      Text(this.nextReviewSuggestion)
        .fontSize(Theme.FONT_SM)
        .fontColor(Theme.TEXT_SECONDARY)
        .lineHeight(22)
        .width('100%')
        .margin({ top: Theme.SPACING_MD })
        .textAlign(TextAlign.Start)

      // 操作按钮
      Row() {
        SecondaryButton({ label: '📋 查看复习计划', fullWidth: false, onAction: () => { this.handleViewPlan() } })
          .layoutWeight(1)

        if (this.currentCardIndex < this.reviewCards.length - 1) {
          PrimaryButton({ label: '▶ 下一张卡片', fullWidth: false, onAction: () => { this.handleNextCard() } })
            .layoutWeight(1)
            .margin({ left: Theme.SPACING_MD })
        }
      }
      .width('100%')
      .margin({ top: Theme.SPACING_MD })
    }
    .width('100%')
    .padding(Theme.SPACING_LG)
    .backgroundColor(Theme.CARD_BG)
    .borderRadius(Theme.RADIUS_MD)
    .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }

  @Builder
  buildNavigationButtons() {
    Row() {
      SecondaryButton({ label: '◀ 上一张', isEnabled: this.currentCardIndex > 0, fullWidth: false, onAction: () => { this.handlePrevCard() } })
        .layoutWeight(1)

      if (this.currentCardIndex < this.reviewCards.length - 1) {
        SecondaryButton({ label: '下一张 ▶', fullWidth: false, onAction: () => { this.handleNextCard() } })
          .layoutWeight(1)
          .margin({ left: Theme.SPACING_MD })
      } else {
        PrimaryButton({ label: '✅ 完成复习', fullWidth: false, onAction: () => { this.handleViewPlan() } })
          .layoutWeight(1)
          .margin({ left: Theme.SPACING_MD })
      }
    }
    .width('100%')
    .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }

  getFeedbackEmoji(status: string): string {
    switch (status) {
      case 'mastered': return '✅'
      case 'fuzzy': return '🤔'
      case 'wrong': return '❌'
      default: return ''
    }
  }

  getFeedbackTitle(status: string): string {
    switch (status) {
      case 'mastered': return '已掌握！'
      case 'fuzzy': return '还模糊'
      case 'wrong': return '做错了'
      default: return ''
    }
  }

  getFeedbackColor(status: string): string {
    switch (status) {
      case 'mastered': return Theme.SUCCESS
      case 'fuzzy': return Theme.WARNING
      case 'wrong': return Theme.DANGER
      default: return Theme.TEXT_PRIMARY
    }
  }
}
