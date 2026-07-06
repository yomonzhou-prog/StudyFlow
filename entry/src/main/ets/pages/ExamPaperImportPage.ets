/**
 * StudyFlow OS - 复习题导入页
 * 粘贴期末复习题文本，自动拆分为答题卡片
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { ExamPaperParserAgent } from '../services/ExamPaperParserAgent'
import { QuestionCardStore } from '../services/QuestionCardStore'
import { QuestionCard } from '../models/QuestionCard'
import { StudyTheme } from '../common/StudyTheme'
import { StatusBanner } from '../components/StatusBanner'

@Entry
@Component
struct ExamPaperImportPage {
  @State courseName: string = ''
  @State rawText: string = ''
  @State isParsing: boolean = false
  @State parsedCards: QuestionCard[] = []
  @State showResult: boolean = false
  @State parseModeLabel: string = ''

  private parserAgent: ExamPaperParserAgent = ExamPaperParserAgent.getInstance()
  private cardStore: QuestionCardStore = QuestionCardStore.getInstance()

  async handleParse(): Promise<void> {
    const text = this.rawText.trim()
    const course = this.courseName.trim()

    if (!text) {
      promptAction.showToast({ message: '请粘贴复习题文本', duration: 1500 })
      return
    }
    if (!course) {
      promptAction.showToast({ message: '请输入课程名称', duration: 1500 })
      return
    }

    this.isParsing = true

    const result = await this.parserAgent.parseExamText(text, course)

    if (result.data && result.data.length > 0) {
      this.parsedCards = result.data
      this.showResult = true
      this.parseModeLabel = result.isMock ? '本地解析' : '智能解析'
    } else {
      promptAction.showToast({ message: '未能解析出题目，请检查文本格式', duration: 2000 })
    }

    this.isParsing = false
  }

  handleConfirmAndReview(): void {
    this.cardStore.addCards(this.parsedCards)
    promptAction.showToast({ message: `已导入 ${this.parsedCards.length} 道题`, duration: 1500 })
    router.replaceUrl({ url: 'pages/ImmersiveReviewPage' })
  }

  handleLoadSample(): void {
    this.courseName = '概率论与数理统计'
    this.rawText =
`1. 设离散型随机变量X的分布律为P(X=1)=0.3, P(X=2)=0.5, P(X=3)=0.2，求E(X)。
A. 1.5  B. 1.9  C. 2.0  D. 2.1
答案：B  解析：E(X)=1×0.3+2×0.5+3×0.2=1.9

2. 已知E(X)=5，则E(2X+3)等于？
A. 10  B. 13  C. 16  D. 8
答案：B  解析：E(2X+3)=2E(X)+3=13

3. 设随机变量X满足E(X)=3，E(X²)=13，则D(X)等于？
A. 4  B. 10  C. 13  D. 16
答案：A  解析：D(X)=E(X²)-[E(X)]²=13-9=4

4. 设X~B(10,0.3)，则D(X)等于？
A. 3  B. 2.1  C. 7  D. 0.21
答案：B  解析：D(X)=np(1-p)=10×0.3×0.7=2.1

5. 若X与Y相互独立，则Cov(X,Y)等于？
A. 1  B. E(XY)  C. 0  D. D(X)
答案：C  解析：独立时E(XY)=E(X)E(Y)，Cov=0`
    promptAction.showToast({ message: '已加载示例复习题', duration: 1500 })
  }

  getDifficultyLabel(diff: string): string {
    if (diff === 'easy') return '简单'
    if (diff === 'hard') return '困难'
    return '中等'
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24).height(24)
          .fillColor(StudyTheme.TEXT_PRIMARY)
          .onClick(() => {
            if (this.showResult) {
              this.showResult = false
            } else {
              router.back()
            }
          })

        Text(this.showResult ? '解析结果' : '导入复习题')
          .fontSize(StudyTheme.FONT_LG)
          .fontColor(StudyTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // Placeholder for alignment
        Row().width(24).height(24)
      }
      .width('100%')
      .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_MD })

      StatusBanner()

      if (this.showResult) {
        // Result view
        Scroll() {
          Column() {
            Row() {
              Text(`已识别 ${this.parsedCards.length} 道题`)
                .fontSize(StudyTheme.FONT_LG)
                .fontColor(StudyTheme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Bold)

              Blank()

              Text(this.parseModeLabel)
                .fontSize(StudyTheme.FONT_XS)
                .fontColor(StudyTheme.TEXT_HINT)
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .border({ width: 1, color: StudyTheme.BORDER })
                .borderRadius(StudyTheme.RADIUS_SM)
            }
            .width('100%')
            .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_LG })

            ForEach(this.parsedCards, (card: QuestionCard, index: number) => {
              Column() {
                Row() {
                  Text(`${index + 1}`)
                    .fontSize(StudyTheme.FONT_SM)
                    .fontColor(StudyTheme.ACCENT)
                    .fontWeight(FontWeight.Bold)
                    .width(24)

                  Text(card.question)
                    .fontSize(StudyTheme.FONT_SM)
                    .fontColor(StudyTheme.TEXT_PRIMARY)
                    .layoutWeight(1)
                    .maxLines(2)
                }
                .width('100%')
                .alignItems(VerticalAlign.Top)

                Row() {
                  if (card.relatedKnowledge.length > 0) {
                    Text(card.relatedKnowledge[0])
                      .fontSize(StudyTheme.FONT_XS)
                      .fontColor(StudyTheme.TEXT_HINT)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .backgroundColor(StudyTheme.ACCENT_BG)
                      .borderRadius(StudyTheme.RADIUS_SM)
                  }

                  Blank()

                  Text(this.getDifficultyLabel(card.difficulty))
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(
                      card.difficulty === 'easy' ? StudyTheme.DIFF_EASY :
                        card.difficulty === 'hard' ? StudyTheme.DIFF_HARD :
                        StudyTheme.DIFF_MEDIUM
                    )
                }
                .width('100%')
                .margin({ top: StudyTheme.SPACE_SM })
              }
              .width('100%')
              .padding(StudyTheme.SPACE_MD)
              .backgroundColor(StudyTheme.CARD_BG)
              .borderRadius(StudyTheme.RADIUS_MD)
              .border({ width: 1, color: StudyTheme.CARD_BORDER })
              .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_SM })
            })

            Column().height(120)
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)

        // Bottom button
        Row() {
          Row() {
            Text('返回修改')
              .fontSize(StudyTheme.FONT_MD)
              .fontColor(StudyTheme.TEXT_SECONDARY)
          }
          .onClick(() => { this.showResult = false })

          Row() {
            Text('开始刷题')
              .fontSize(StudyTheme.FONT_MD)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
          }
          .padding({ left: 32, right: 32, top: 12, bottom: 12 })
          .backgroundColor(StudyTheme.ACCENT)
          .borderRadius(StudyTheme.RADIUS_FULL)
          .onClick(() => { this.handleConfirmAndReview() })
        }
        .width('100%')
        .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_MD, bottom: StudyTheme.SPACE_XXL })
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor(StudyTheme.CARD_BG)
        .border({ width: { top: 1 }, color: StudyTheme.BORDER })
      } else {
        // Input view
        Scroll() {
          Column() {
            // Course name
            TextInput({ text: this.courseName, placeholder: '课程名称（如：概率论与数理统计）' })
              .fontSize(StudyTheme.FONT_MD)
              .backgroundColor(StudyTheme.CARD_BG)
              .borderRadius(StudyTheme.RADIUS_MD)
              .padding(StudyTheme.SPACE_MD)
              .width('100%')
              .onChange((value: string) => { this.courseName = value })
              .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_LG })

            // Text input
            TextArea({ text: this.rawText, placeholder: '请粘贴期末复习题文本，支持多道题目...\n\n格式示例：\n1. 题目内容\nA. 选项A  B. 选项B  C. 选项C  D. 选项D\n答案：B  解析：...\n\n2. 题目内容\n...' })
              .height(240)
              .fontSize(StudyTheme.FONT_SM)
              .backgroundColor(StudyTheme.CARD_BG)
              .borderRadius(StudyTheme.RADIUS_MD)
              .padding(StudyTheme.SPACE_MD)
              .width('100%')
              .onChange((value: string) => { this.rawText = value })
              .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_MD })

            // Action buttons
            Row() {
              Row() {
                Text('加载示例')
                  .fontSize(StudyTheme.FONT_SM)
                  .fontColor(StudyTheme.ACCENT)
                  .padding({ left: 16, right: 16, top: 10, bottom: 10 })
                  .border({ width: 1, color: StudyTheme.ACCENT })
                  .borderRadius(StudyTheme.RADIUS_FULL)
              }
              .onClick(() => { this.handleLoadSample() })

              Row() {
                Text(this.isParsing ? '解析中...' : '开始解析')
                  .fontSize(StudyTheme.FONT_SM)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Medium)
                  .padding({ left: 24, right: 24, top: 10, bottom: 10 })
                  .backgroundColor(this.isParsing ? StudyTheme.TEXT_HINT : StudyTheme.ACCENT)
                  .borderRadius(StudyTheme.RADIUS_FULL)
              }
              .onClick(() => { this.handleParse() })
              .margin({ left: StudyTheme.SPACE_MD })
            }
            .width('100%')
            .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_LG })

            Text('当前版本支持粘贴文本题目，拍照OCR功能开发中')
              .fontSize(StudyTheme.FONT_XS)
              .fontColor(StudyTheme.TEXT_HINT)
              .margin({ top: StudyTheme.SPACE_MD, left: StudyTheme.PAGE_PAD })
          }
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(StudyTheme.BG)
  }
}
