/**
 * StudyFlow OS - 复习卡片视图组件
 */

import { ReviewCard } from '../models/ReviewCard'
import { Theme } from '../common/Theme'

@Component
export struct ReviewCardView {
  @Prop reviewCard: ReviewCard
  @Prop showAnswer: boolean = false
  onShowAnswer?: () => void
  onFeedback?: (status: string) => void

  build() {
    Column() {
      // 知识点标题
      Text(this.reviewCard.knowledgePointTitle)
        .fontSize(Theme.FONT_LG)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)

      // 解释
      Text(this.reviewCard.knowledgePointExplanation)
        .fontSize(Theme.FONT_SM)
        .fontColor(Theme.TEXT_SECONDARY)
        .width('100%')
        .margin({ top: Theme.SPACING_MD })
        .lineHeight(22)

      // 重点提醒
      Row() {
        Text('💡')
          .fontSize(Theme.FONT_MD)
        Text(this.reviewCard.keyReminder)
          .fontSize(Theme.FONT_SM)
          .fontColor(Theme.PRIMARY)
          .margin({ left: Theme.SPACING_SM })
          .layoutWeight(1)
      }
      .width('100%')
      .padding(Theme.SPACING_MD)
      .backgroundColor(Theme.PRIMARY_BG)
      .borderRadius(Theme.RADIUS_MD)
      .margin({ top: Theme.SPACING_MD })

      // 常见错误
      if (this.reviewCard.commonMistakes.length > 0) {
        Column() {
          Text('⚠ 常见错误')
            .fontSize(Theme.FONT_SM)
            .fontColor(Theme.WARNING)
            .fontWeight(FontWeight.Medium)

          ForEach(this.reviewCard.commonMistakes, (mistake: string, index: number) => {
            Text(`${index + 1}. ${mistake}`)
              .fontSize(Theme.FONT_XS)
              .fontColor(Theme.TEXT_SECONDARY)
              .margin({ top: Theme.SPACING_XS })
          })
        }
        .width('100%')
        .padding(Theme.SPACING_MD)
        .backgroundColor(Theme.WARNING_BG)
        .borderRadius(Theme.RADIUS_MD)
        .margin({ top: Theme.SPACING_MD })
        .alignItems(HorizontalAlign.Start)
      }

      // 自测题
      Column() {
        Text('📝 自测题')
          .fontSize(Theme.FONT_MD)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: Theme.SPACING_SM })

        Text(this.reviewCard.quiz.question)
          .fontSize(Theme.FONT_SM)
          .fontColor(Theme.TEXT_PRIMARY)
          .lineHeight(22)

        // 选项
        if (this.reviewCard.quiz.options && this.reviewCard.quiz.options.length > 0) {
          ForEach(this.reviewCard.quiz.options, (option: string) => {
            Text(option)
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_SECONDARY)
              .width('100%')
              .padding({ left: Theme.SPACING_MD, top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
              .backgroundColor(this.getOptionBg(option))
              .borderRadius(Theme.RADIUS_SM)
              .margin({ top: Theme.SPACING_XS })
          })
        }

        // 显示答案按钮
        if (!this.showAnswer) {
          Button('查看答案与解析')
            .fontSize(Theme.FONT_SM)
            .fontColor(Theme.PRIMARY)
            .backgroundColor(Theme.PRIMARY_BG)
            .borderRadius(Theme.RADIUS_MD)
            .margin({ top: Theme.SPACING_MD })
            .width('100%')
            .onClick(() => {
              if (this.onShowAnswer) {
                this.onShowAnswer()
              }
            })
        }

        // 答案与解析
        if (this.showAnswer) {
          Column() {
            Text(`✅ 正确答案: ${this.reviewCard.quiz.correctAnswer}`)
              .fontSize(Theme.FONT_MD)
              .fontColor(Theme.SUCCESS)
              .fontWeight(FontWeight.Medium)

            Text(this.reviewCard.quiz.explanation)
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_SECONDARY)
              .lineHeight(22)
              .margin({ top: Theme.SPACING_SM })
          }
          .width('100%')
          .padding(Theme.SPACING_MD)
          .backgroundColor(Theme.SUCCESS_BG)
          .borderRadius(Theme.RADIUS_MD)
          .margin({ top: Theme.SPACING_MD })
          .alignItems(HorizontalAlign.Start)

          // 反馈按钮
          Row() {
            Button('✅ 已掌握')
              .fontSize(Theme.FONT_SM)
              .backgroundColor(Theme.SUCCESS_BG)
              .fontColor(Theme.SUCCESS)
              .borderRadius(Theme.RADIUS_MD)
              .layoutWeight(1)
              .onClick(() => {
                if (this.onFeedback) this.onFeedback('mastered')
              })

            Button('🤔 还模糊')
              .fontSize(Theme.FONT_SM)
              .backgroundColor(Theme.WARNING_BG)
              .fontColor(Theme.WARNING)
              .borderRadius(Theme.RADIUS_MD)
              .layoutWeight(1)
              .margin({ left: Theme.SPACING_SM, right: Theme.SPACING_SM })
              .onClick(() => {
                if (this.onFeedback) this.onFeedback('fuzzy')
              })

            Button('❌ 做错了')
              .fontSize(Theme.FONT_SM)
              .backgroundColor(Theme.DANGER_BG)
              .fontColor(Theme.DANGER)
              .borderRadius(Theme.RADIUS_MD)
              .layoutWeight(1)
              .onClick(() => {
                if (this.onFeedback) this.onFeedback('wrong')
              })
          }
          .width('100%')
          .margin({ top: Theme.SPACING_MD })
        }
      }
      .width('100%')
      .padding(Theme.SPACING_MD)
      .backgroundColor(Theme.BG)
      .borderRadius(Theme.RADIUS_MD)
      .margin({ top: Theme.SPACING_MD })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Theme.SPACING_LG)
    .backgroundColor(Theme.CARD_BG)
    .borderRadius(Theme.RADIUS_LG)
    .margin({ bottom: Theme.SPACING_MD })
  }

  /**
   * 通过选项编号精确匹配（如 "A." 或 "A " 开头），避免 startsWith 误判
   */
  getOptionBg(option: string): string {
    if (!this.showAnswer) return Theme.BG
    const answerLetter = this.reviewCard.quiz.correctAnswer.trim().charAt(0)
    const optionLetter = option.trim().charAt(0)
    if (optionLetter === answerLetter) {
      return Theme.SUCCESS_BG
    }
    return Theme.BG
  }
}
