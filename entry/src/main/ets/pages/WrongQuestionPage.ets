/**
 * StudyFlow OS - 错题本页
 * 展示所有错题，支持标记已掌握
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { QuestionBankStore } from '../services/QuestionBankStore'
import { WrongQuestion } from '../models/WrongQuestion'
import { StudyTheme } from '../common/StudyTheme'

@Entry
@Component
struct WrongQuestionPage {
  @State wrongQuestions: WrongQuestion[] = []

  private questionBankStore: QuestionBankStore = QuestionBankStore.getInstance()

  aboutToAppear(): void {
    this.loadData()
  }

  loadData(): void {
    this.wrongQuestions = this.questionBankStore.getUnmasteredWrongQuestions()
  }

  handleMarkMastered(id: string): void {
    this.questionBankStore.markWrongQuestionMastered(id)
    promptAction.showToast({ message: '已标记为掌握', duration: 1500 })
    this.loadData()
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24).height(24)
          .fillColor(StudyTheme.TEXT_PRIMARY)
          .onClick(() => { router.back() })

        Text('错题本')
          .fontSize(StudyTheme.FONT_LG)
          .fontColor(StudyTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Row().width(24).height(24)
      }
      .width('100%')
      .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_MD })

      if (this.wrongQuestions.length === 0) {
        Column() {
          Text('暂无错题')
            .fontSize(StudyTheme.FONT_LG)
            .fontColor(StudyTheme.TEXT_HINT)
            .margin({ bottom: StudyTheme.SPACE_SM })
          Text('完成复习后，错题会自动收集到这里')
            .fontSize(StudyTheme.FONT_SM)
            .fontColor(StudyTheme.TEXT_HINT)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.wrongQuestions, (item: WrongQuestion) => {
            ListItem() {
              Column() {
                Text(item.question)
                  .fontSize(StudyTheme.FONT_SM)
                  .fontColor(StudyTheme.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Medium)
                  .lineHeight(22)
                  .maxLines(3)

                Row() {
                  Text(`你的答案: ${item.userAnswer}`)
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.DANGER)
                  Text(`正确答案: ${item.correctAnswer}`)
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.SUCCESS)
                    .margin({ left: StudyTheme.SPACE_MD })
                }
                .margin({ top: StudyTheme.SPACE_SM })

                if (item.explanation) {
                  Text(item.explanation)
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.TEXT_SECONDARY)
                    .margin({ top: StudyTheme.SPACE_SM })
                    .maxLines(2)
                }

                Row() {
                  Text(item.knowledgePointTitle)
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.ACCENT)
                    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                    .backgroundColor(StudyTheme.ACCENT_BG)
                    .borderRadius(StudyTheme.RADIUS_SM)

                  Blank()

                  if (item.isMastered) {
                    Text('已掌握')
                      .fontSize(StudyTheme.FONT_XS)
                      .fontColor(StudyTheme.SUCCESS)
                  } else {
                    Text('掌握了')
                      .fontSize(StudyTheme.FONT_XS)
                      .fontColor(StudyTheme.ACCENT)
                      .fontWeight(FontWeight.Medium)
                      .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                      .border({ width: 1, color: StudyTheme.ACCENT })
                      .borderRadius(StudyTheme.RADIUS_SM)
                      .onClick(() => { this.handleMarkMastered(item.id) })
                  }
                }
                .width('100%')
                .margin({ top: StudyTheme.SPACE_SM })
              }
              .width('100%')
              .padding(StudyTheme.SPACE_MD)
              .backgroundColor(StudyTheme.CARD_BG)
              .borderRadius(StudyTheme.RADIUS_MD)
              .border({ width: 1, color: StudyTheme.CARD_BORDER })
            }
            .margin({ bottom: StudyTheme.SPACE_SM })
          })
        }
        .layoutWeight(1)
        .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(StudyTheme.BG)
  }
}
