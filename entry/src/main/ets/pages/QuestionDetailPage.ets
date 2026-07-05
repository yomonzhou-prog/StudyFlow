/**
 * StudyFlow OS - 题目详情/答题页
 * 显示题目、选项，用户作答后展示正误和解析
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { QuestionBankStore } from '../services/QuestionBankStore'
import { QuestionItem } from '../models/QuestionItem'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { PageHeader } from '../components/PageHeader'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'
import { DifficultyTag } from '../components/DifficultyTag'

@Entry
@Component
struct QuestionDetailPage {
  @State question: QuestionItem | null = null
  @State selectedAnswer: string = ''
  @State hasSubmitted: boolean = false
  @State isCorrect: boolean = false

  private questionBankStore: QuestionBankStore = QuestionBankStore.getInstance()
  private questionId: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>
    if (params && params['questionId']) {
      this.questionId = params['questionId'] as string
    }
    this.loadQuestion()
  }

  loadQuestion(): void {
    if (this.questionBankStore.getQuestions().length === 0) {
      this.questionBankStore.initMockData()
    }
    this.question = this.questionBankStore.getQuestionById(this.questionId) || null
  }

  handleSelectOption(option: string): void {
    if (!this.hasSubmitted) {
      this.selectedAnswer = option
    }
  }

  handleSubmit(): void {
    if (!this.question || !this.selectedAnswer) {
      promptAction.showToast({ message: '请先选择一个选项', duration: 1500 })
      return
    }

    this.hasSubmitted = true
    this.isCorrect = this.selectedAnswer.substring(0, 1) === this.question.correctAnswer

    if (!this.isCorrect && this.question) {
      this.questionBankStore.addWrongQuestion(this.question, this.selectedAnswer)
    }
  }

  getOptionBg(option: string): string {
    if (!this.hasSubmitted) {
      return this.selectedAnswer === option ? Theme.PRIMARY_BG : Theme.BG
    }
    const isCorrectOption = option.substring(0, 1) === this.question?.correctAnswer
    if (isCorrectOption) return Theme.SUCCESS_BG
    if (this.selectedAnswer === option && !this.isCorrect) return Theme.DANGER_BG
    return Theme.BG
  }

  getOptionTextColor(option: string): string {
    if (!this.hasSubmitted) {
      return this.selectedAnswer === option ? Theme.PRIMARY : Theme.TEXT_PRIMARY
    }
    const isCorrectOption = option.substring(0, 1) === this.question?.correctAnswer
    if (isCorrectOption) return Theme.SUCCESS
    if (this.selectedAnswer === option && !this.isCorrect) return Theme.DANGER
    return Theme.TEXT_PRIMARY
  }

  build() {
    Column() {
      if (!this.question) {
        Column() {
          Text('题目不存在').fontSize(Theme.FONT_MD).fontColor(Theme.TEXT_SECONDARY)
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('100%')
      } else {
        Column() {
          PageHeader({ title: '答题' })
        }

        Scroll() {
          Column() {
            // 题目标签
            Row() {
              Text(this.question.courseName)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.TEXT_SECONDARY)
              DifficultyTag({ difficulty: this.question.difficulty })
                .margin({ left: Theme.SPACING_SM })
              Blank()
              Text(this.question.chapter)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.TEXT_HINT)
            }
            .width('100%')
            .padding(Theme.SPACING_LG)

            // 题目
            Column() {
              Text(this.question.question)
                .fontSize(Theme.FONT_LG)
                .fontColor(Theme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .lineHeight(26)
            }
            .width('100%')
            .padding(Theme.SPACING_LG)
            .backgroundColor(Theme.CARD_BG)
            .borderRadius(Theme.RADIUS_MD)
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })

            // 选项
            Column() {
              ForEach(this.question.options, (option: string) => {
                Row() {
                  Text(option)
                    .fontSize(Theme.FONT_MD)
                    .fontColor(this.getOptionTextColor(option))
                    .layoutWeight(1)
                  if (this.hasSubmitted && option.substring(0, 1) === this.question?.correctAnswer) {
                    Text('✓').fontSize(18).fontColor(Theme.SUCCESS)
                  }
                  if (this.hasSubmitted && this.selectedAnswer === option && !this.isCorrect) {
                    Text('✗').fontSize(18).fontColor(Theme.DANGER)
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
            .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_LG })

            // 结果反馈
            if (this.hasSubmitted) {
              Column() {
                if (this.isCorrect) {
                  Row() {
                    Text('✅').fontSize(20)
                    Text('回答正确！').fontSize(Theme.FONT_MD).fontColor(Theme.SUCCESS).fontWeight(FontWeight.Bold).margin({ left: Theme.SPACING_SM })
                  }
                } else {
                  Row() {
                    Text('❌').fontSize(20)
                    Text('回答错误').fontSize(Theme.FONT_MD).fontColor(Theme.DANGER).fontWeight(FontWeight.Bold).margin({ left: Theme.SPACING_SM })
                  }
                }

                Text(`解析：${this.question.explanation}`)
                  .fontSize(Theme.FONT_SM)
                  .fontColor(Theme.TEXT_SECONDARY)
                  .lineHeight(22)
                  .margin({ top: Theme.SPACING_MD })
              }
              .width('100%')
              .padding(Theme.SPACING_LG)
              .backgroundColor(this.isCorrect ? Theme.SUCCESS_BG : Theme.DANGER_BG)
              .borderRadius(Theme.RADIUS_MD)
              .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_LG })
            }

            // 提交按钮 / 下一题按钮
            Row() {
              if (!this.hasSubmitted) {
                PrimaryButton({
                  label: '提交答案',
                  isEnabled: this.selectedAnswer !== '',
                  onAction: () => { this.handleSubmit() }
                })
              } else {
                SecondaryButton({
                  label: '返回题库',
                  fullWidth: false,
                  onAction: () => { router.back() }
                })
                .layoutWeight(1)

                PrimaryButton({
                  label: '下一题',
                  fullWidth: false,
                  onAction: () => { router.back() }
                })
                .layoutWeight(1)
                .margin({ left: Theme.SPACING_MD })
              }
            }
            .width('100%')
            .padding(Theme.SPACING_LG)
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
}
