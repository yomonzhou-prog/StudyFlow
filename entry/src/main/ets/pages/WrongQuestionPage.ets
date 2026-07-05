/**
 * StudyFlow OS - 错题本页
 * 展示所有错题，支持回顾和标记已掌握
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { QuestionBankStore } from '../services/QuestionBankStore'
import { WrongQuestion } from '../models/WrongQuestion'
import { Theme } from '../common/Theme'
import { PageHeader } from '../components/PageHeader'
import { EmptyState } from '../components/EmptyState'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'

@Entry
@Component
struct WrongQuestionPage {
  @State wrongQuestions: WrongQuestion[] = []
  @State isLoading: boolean = true

  private questionBankStore: QuestionBankStore = QuestionBankStore.getInstance()

  aboutToAppear(): void {
    this.loadData()
  }

  loadData(): void {
    this.wrongQuestions = this.questionBankStore.getWrongQuestions()
    this.isLoading = false
  }

  handleMarkMastered(id: string): void {
    this.questionBankStore.markWrongQuestionMastered(id)
    promptAction.showToast({ message: '已标记为掌握', duration: 1500 })
    this.loadData()
  }

  build() {
    Column() {
      PageHeader({ title: '错题本' })

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(36).height(36).color(Theme.PRIMARY)
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
      } else if (this.wrongQuestions.length === 0) {
        EmptyState({ icon: '🎉', message: '还没有错题，继续保持！' })
      } else {
        Scroll() {
          Column() {
            Text(`共 ${this.wrongQuestions.length} 道错题`)
              .fontSize(Theme.FONT_XS)
              .fontColor(Theme.TEXT_HINT)
              .width('100%')
              .padding({ left: Theme.SPACING_LG, bottom: Theme.SPACING_MD })

            ForEach(this.wrongQuestions, (wq: WrongQuestion) => {
              Column() {
                Row() {
                  Column() {
                    Text(wq.question)
                      .fontSize(Theme.FONT_MD)
                      .fontColor(Theme.TEXT_PRIMARY)
                      .fontWeight(FontWeight.Medium)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Row() {
                      Text(`你的答案: ${wq.userAnswer}`)
                        .fontSize(Theme.FONT_XS)
                        .fontColor(Theme.DANGER)
                      Text(`正确答案: ${wq.correctAnswer}`)
                        .fontSize(Theme.FONT_XS)
                        .fontColor(Theme.SUCCESS)
                        .margin({ left: Theme.SPACING_MD })
                    }
                    .margin({ top: Theme.SPACING_XS })

                    if (wq.isMastered) {
                      Text('✅ 已掌握')
                        .fontSize(Theme.FONT_XS)
                        .fontColor(Theme.SUCCESS)
                        .margin({ top: Theme.SPACING_XS })
                    }
                  }
                  .layoutWeight(1)

                  if (!wq.isMastered) {
                    SecondaryButton({
                      label: '掌握了',
                      fullWidth: false,
                      onAction: () => { this.handleMarkMastered(wq.id) }
                    })
                  }
                }
                .width('100%')
              }
              .width('100%')
              .padding(Theme.SPACING_MD)
              .backgroundColor(Theme.CARD_BG)
              .borderRadius(Theme.RADIUS_MD)
              .margin({ bottom: Theme.SPACING_SM, left: Theme.SPACING_LG, right: Theme.SPACING_LG })
            })
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
