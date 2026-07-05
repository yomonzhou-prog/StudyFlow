/**
 * StudyFlow OS - 随机复习页
 * 沉浸式单卡片复习，用户看到题目→作答→查看答案→反馈（认识/模糊/忘了）
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { PlanStore } from '../services/PlanStore'
import { ReviewSessionStore, SessionStats } from '../services/ReviewSessionStore'
import { ReviewCard } from '../models/ReviewCard'
import { LearningFeedback } from '../models/LearningFeedback'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { PageHeader } from '../components/PageHeader'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

@Entry
@Component
struct RandomReviewPage {
  @State currentCard: ReviewCard | null = null
  @State showAnswer: boolean = false
  @State selectedAnswer: string = ''
  @State isSessionComplete: boolean = false
  @State sessionStats: SessionStats | null = null
  @State currentPosition: number = 0
  @State totalCount: number = 0
  @State progress: number = 0

  private planStore: PlanStore = PlanStore.getInstance()
  private sessionStore: ReviewSessionStore = ReviewSessionStore.getInstance()

  aboutToAppear(): void {
    this.initSession()
  }

  initSession(): void {
    const allCards = this.planStore.getReviewCards()
    if (allCards.length === 0) {
      this.planStore.initMockData()
      const cards = this.planStore.getReviewCards()
      this.sessionStore.startSession(cards)
    } else {
      this.sessionStore.startSession(allCards)
    }
    this.updateDisplay()
  }

  updateDisplay(): void {
    this.currentCard = this.sessionStore.getCurrentCard()
    this.currentPosition = this.sessionStore.getCurrentPosition()
    this.totalCount = this.sessionStore.getTotalCount()
    this.progress = this.sessionStore.getProgress()
    this.isSessionComplete = this.sessionStore.isComplete()
  }

  handleSelectOption(option: string): void {
    if (!this.showAnswer) {
      this.selectedAnswer = option
    }
  }

  handleRevealAnswer(): void {
    if (!this.selectedAnswer) {
      promptAction.showToast({ message: '请先选择一个选项', duration: 1500 })
      return
    }
    this.showAnswer = true
  }

  handleFeedback(status: string): void {
    this.sessionStore.submitFeedback(status)

    // 更新 PlanStore 中的卡片状态
    const card = this.currentCard
    if (card) {
      this.planStore.updateReviewCardFeedback(card.id, status)

      // 记录反馈
      const feedback: LearningFeedback = {
        id: IdUtils.generate(),
        reviewCardId: card.id,
        knowledgePointId: card.knowledgePointId,
        knowledgePointTitle: card.knowledgePointTitle,
        status: status,
        timestamp: DateUtils.now(),
        note: ''
      }
      this.planStore.addFeedback(feedback)
    }

    if (this.sessionStore.isComplete()) {
      this.sessionStats = this.sessionStore.getSessionStats()
      this.isSessionComplete = true
    } else {
      this.showAnswer = false
      this.selectedAnswer = ''
      this.updateDisplay()
    }
  }

  getOptionBg(option: string): string {
    if (!this.showAnswer) {
      return this.selectedAnswer === option ? Theme.PRIMARY_BG : Theme.CARD_BG
    }
    const isCorrect = option.substring(0, 1) === this.currentCard?.quiz.correctAnswer
    if (isCorrect) return Theme.SUCCESS_BG
    if (this.selectedAnswer === option && !isCorrect) return Theme.DANGER_BG
    return Theme.CARD_BG
  }

  getOptionTextColor(option: string): string {
    if (!this.showAnswer) {
      return this.selectedAnswer === option ? Theme.PRIMARY : Theme.TEXT_PRIMARY
    }
    const isCorrect = option.substring(0, 1) === this.currentCard?.quiz.correctAnswer
    if (isCorrect) return Theme.SUCCESS
    if (this.selectedAnswer === option && !isCorrect) return Theme.DANGER
    return Theme.TEXT_PRIMARY
  }

  isCorrectAnswer(): boolean {
    if (!this.currentCard) return false
    return this.selectedAnswer.substring(0, 1) === this.currentCard.quiz.correctAnswer
  }

  build() {
    Column() {
      PageHeader({
        title: `复习卡片 ${this.currentPosition}/${this.totalCount}`
      })

      if (this.isSessionComplete) {
        this.buildSessionComplete()
      } else if (this.currentCard) {
        this.buildCardReview()
      } else {
        Column() {
          Text('📭').fontSize(64)
          Text('没有待复习的卡片').fontSize(Theme.FONT_MD).fontColor(Theme.TEXT_SECONDARY).margin({ top: Theme.SPACING_MD })
          PrimaryButton({
            label: '返回',
            onAction: () => { router.back() }
          })
          .margin({ top: Theme.SPACING_LG })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
        .width('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  buildProgressBar() {
    Row() {
      Progress({ value: this.currentPosition, total: this.totalCount, type: ProgressType.Linear })
        .width('100%')
        .height(4)
        .color(Theme.PRIMARY)
        .backgroundColor(Theme.BORDER)
    }
    .width('100%')
    .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, bottom: Theme.SPACING_MD })
  }

  @Builder
  buildCardReview() {
    Column() {
      this.buildProgressBar()

      Scroll() {
        Column() {
          // 知识点信息
          Column() {
            Text(this.currentCard!.knowledgePointTitle)
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.PRIMARY)
              .fontWeight(FontWeight.Medium)
            Text(this.currentCard!.keyReminder)
              .fontSize(Theme.FONT_XS)
              .fontColor(Theme.TEXT_HINT)
              .margin({ top: Theme.SPACING_XS })
          }
          .width('100%')
          .padding(Theme.SPACING_MD)
          .backgroundColor(Theme.PRIMARY_BG)
          .borderRadius(Theme.RADIUS_MD)
          .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })

          // 题目
          Column() {
            Text(this.currentCard!.quiz.question)
              .fontSize(Theme.FONT_LG)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .lineHeight(26)
          }
          .width('100%')
          .padding(Theme.SPACING_LG)
          .backgroundColor(Theme.CARD_BG)
          .borderRadius(Theme.RADIUS_MD)
          .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

          // 选项
          Column() {
            ForEach(this.currentCard!.quiz.options, (option: string) => {
              Row() {
                Text(option)
                  .fontSize(Theme.FONT_MD)
                  .fontColor(this.getOptionTextColor(option))
                  .layoutWeight(1)
                if (this.showAnswer && option.substring(0, 1) === this.currentCard?.quiz.correctAnswer) {
                  Text('✓').fontSize(18).fontColor(Theme.SUCCESS)
                }
              }
              .width('100%')
              .padding(Theme.SPACING_MD)
              .backgroundColor(this.getOptionBg(option))
              .borderRadius(Theme.RADIUS_MD)
              .border({ width: 1, color: this.getOptionTextColor(option) === Theme.PRIMARY ? Theme.PRIMARY : Theme.BORDER })
              .margin({ bottom: Theme.SPACING_SM })
              .onClick(() => { this.handleSelectOption(option) })
            })
          }
          .width('100%')
          .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

          // 答案展示 + 反馈按钮
          if (this.showAnswer) {
            Column() {
              // 结果提示
              Row() {
                Text(this.isCorrectAnswer() ? '✅ 回答正确！' : '❌ 回答错误')
                  .fontSize(Theme.FONT_MD)
                  .fontColor(this.isCorrectAnswer() ? Theme.SUCCESS : Theme.DANGER)
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .padding(Theme.SPACING_MD)
              .backgroundColor(this.isCorrectAnswer() ? Theme.SUCCESS_BG : Theme.DANGER_BG)
              .borderRadius(Theme.RADIUS_MD)

              // 解析
              Text(`📖 ${this.currentCard!.quiz.explanation}`)
                .fontSize(Theme.FONT_SM)
                .fontColor(Theme.TEXT_SECONDARY)
                .lineHeight(22)
                .margin({ top: Theme.SPACING_MD })

              // 反馈按钮
              Text('你对这个知识点的掌握程度？')
                .fontSize(Theme.FONT_SM)
                .fontColor(Theme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .margin({ top: Theme.SPACING_LG })

              Row() {
                SecondaryButton({
                  label: '😊 认识了',
                  fullWidth: false,
                  onAction: () => { this.handleFeedback('mastered') }
                })
                .layoutWeight(1)

                SecondaryButton({
                  label: '🤔 还模糊',
                  fullWidth: false,
                  onAction: () => { this.handleFeedback('fuzzy') }
                })
                .layoutWeight(1)
                .margin({ left: Theme.SPACING_SM })

                SecondaryButton({
                  label: '😰 没掌握',
                  fullWidth: false,
                  onAction: () => { this.handleFeedback('wrong') }
                })
                .layoutWeight(1)
                .margin({ left: Theme.SPACING_SM })
              }
              .margin({ top: Theme.SPACING_MD })
            }
            .width('100%')
            .padding(Theme.SPACING_LG)
            .backgroundColor(Theme.CARD_BG)
            .borderRadius(Theme.RADIUS_MD)
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
          } else {
            // 确认按钮
            PrimaryButton({
              label: '确认答案',
              isEnabled: this.selectedAnswer !== '',
              onAction: () => { this.handleRevealAnswer() }
            })
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_LG })
          }
        }
        .width('100%')
        .padding({ bottom: 40 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildSessionComplete() {
    Column() {
      Blank()
      Text('🎉')
        .fontSize(80)
        .margin({ bottom: Theme.SPACING_LG })
      Text('复习完成！')
        .fontSize(Theme.FONT_XXL)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)

      if (this.sessionStats) {
        Column() {
          this.buildSessionStatItem('📊', '总题数', this.sessionStats.total.toString())
          this.buildSessionStatItem('✅', '已掌握', this.sessionStats.mastered.toString())
          this.buildSessionStatItem('🤔', '还模糊', this.sessionStats.fuzzy.toString())
          this.buildSessionStatItem('❌', '需加强', this.sessionStats.wrong.toString())
        }
        .width('100%')
        .padding(Theme.SPACING_LG)
        .backgroundColor(Theme.CARD_BG)
        .borderRadius(Theme.RADIUS_LG)
        .margin({ top: Theme.SPACING_LG, left: Theme.SPACING_XXL, right: Theme.SPACING_XXL })
      }

      Blank()

      PrimaryButton({
        label: '🔁 再复习一次',
        onAction: () => {
          this.isSessionComplete = false
          this.showAnswer = false
          this.selectedAnswer = ''
          this.sessionStats = null
          this.initSession()
        }
      })
      .margin({ bottom: Theme.SPACING_MD })

      SecondaryButton({
        label: '返回',
        onAction: () => { router.back() }
      })
    }
    .width('100%')
    .height('100%')
    .padding(Theme.SPACING_XXL)
    .backgroundColor(Theme.BG)
  }

  @Builder
  buildSessionStatItem(emoji: string, label: string, count: string) {
    Row() {
      Text(emoji).fontSize(18)
      Text(label).fontSize(Theme.FONT_MD).fontColor(Theme.TEXT_PRIMARY).layoutWeight(1).margin({ left: Theme.SPACING_SM })
      Text(count).fontSize(Theme.FONT_XL).fontColor(Theme.PRIMARY).fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
  }
}
