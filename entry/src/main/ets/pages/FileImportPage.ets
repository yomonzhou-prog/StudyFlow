/**
 * StudyFlow OS — 试卷/题库文件导入页（场景一前端）
 *
 * 流程：选择文件 → 上传后端解析 → 预览解析结果 → 导入题库 → 开始刷题
 */

import { router } from '@kit.ArkUI'
import { picker } from '@kit.CoreFileKit'
import { StudyTheme } from '../common/StudyTheme'
import { ApiClient, ParseDocumentResult, QuestionCardDTO } from '../services/ApiClient'
import { MathRenderer } from '../components/MathRenderer'
import { QuestionCardStore } from '../services/QuestionCardStore'
import { QuestionCard } from '../models/QuestionCard'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

// ─── 页面状态 ───

enum ImportStep {
  SELECT = 'select',
  UPLOADING = 'uploading',
  PREVIEW = 'preview',
  IMPORTING = 'importing',
}

@Entry
@Component
struct FileImportPage {
  @State currentStep: ImportStep = ImportStep.SELECT
  @State selectedFileName: string = ''
  @State selectedFileUri: string = ''
  @State courseName: string = ''
  @State parsedCards: QuestionCardDTO[] = []
  @State parsedCourseName: string = ''
  @State parsedTotalCount: number = 0
  @State errorMessage: string = ''
  @State flipStates: boolean[] = []
  private apiClient: ApiClient = ApiClient.getInstance()
  private cardStore: QuestionCardStore = QuestionCardStore.getInstance()

  // ─── 文件选择 ───

  async handleSelectFile(): Promise<void> {
    try {
      const documentPicker = new picker.DocumentViewPicker()
      const uris: string[] = await documentPicker.select({
        maxSelectNumber: 1,
      })

      if (uris.length > 0) {
        const firstUri: string = uris[0]
        this.selectedFileUri = firstUri
        const parts: string[] = firstUri.split('/')
        const lastName: string = parts[parts.length - 1]
        this.selectedFileName = lastName
        this.errorMessage = ''
      }
    } catch (error) {
      this.errorMessage = `文件选择失败: ${JSON.stringify(error)}`
    }
  }

  // ─── 上传并解析 ───

  async handleUploadAndParse(): Promise<void> {
    if (this.selectedFileUri.length === 0) {
      this.errorMessage = '请先选择文件'
      return
    }

    this.currentStep = ImportStep.UPLOADING
    this.errorMessage = ''

    const result = await this.apiClient.parseDocument(
      this.selectedFileUri,
      this.selectedFileName,
      this.courseName.trim(),
    )

    if (result.success) {
      const data: ParseDocumentResult = result.data
      this.parsedCards = data.cards
      this.parsedCourseName = data.courseName
      this.parsedTotalCount = data.totalCount
      this.flipStates = []
      for (let i = 0; i < this.parsedCards.length; i++) {
        this.flipStates.push(false)
      }
      this.currentStep = ImportStep.PREVIEW
    } else {
      this.errorMessage = result.errorMessage
      this.currentStep = ImportStep.SELECT
    }
  }

  // ─── 导入题库 ───

  handleImportToBank(): void {
    this.currentStep = ImportStep.IMPORTING

    const newCards: QuestionCard[] = []
    for (let i = 0; i < this.parsedCards.length; i++) {
      const dto: QuestionCardDTO = this.parsedCards[i]
      let difficulty: 'easy' | 'medium' | 'hard' = 'medium'
      if (dto.difficulty === 'hard') {
        difficulty = 'hard'
      } else if (dto.difficulty === 'easy') {
        difficulty = 'easy'
      }
      const card: QuestionCard = {
        id: IdUtils.generate(),
        courseName: dto.course_name.length > 0 ? dto.course_name : this.parsedCourseName,
        question: dto.question,
        options: dto.options,
        answer: dto.answer,
        explanation: dto.explanation,
        relatedKnowledge: dto.related_knowledge,
        difficulty: difficulty,
        commonMistake: dto.common_mistake,
        sourcePaperId: dto.source_paper_id,
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now(),
      }
      newCards.push(card)
    }

    this.cardStore.addCards(newCards)

    setTimeout(() => {
      router.replaceUrl({ url: 'pages/ImmersiveReviewPage' })
    }, 300)
  }

  // ─── 卡片翻转 ───

  toggleFlip(index: number): void {
    const newFlips: boolean[] = []
    for (let i = 0; i < this.flipStates.length; i++) {
      if (i === index) {
        newFlips.push(!this.flipStates[i])
      } else {
        newFlips.push(this.flipStates[i])
      }
    }
    this.flipStates = newFlips
  }

  // ─── 难度文本 ───

  getDifficultyText(difficulty: string): string {
    if (difficulty === 'hard') return '困难'
    if (difficulty === 'easy') return '简单'
    return '中等'
  }

  // ─── 构建 ───

  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(22).height(22)
          .fillColor(StudyTheme.TEXT_HINT)
          .onClick(() => { router.back() })
        Text('试卷导入')
          .fontSize(StudyTheme.FONT_LG)
          .fontColor(StudyTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Row().width(22).height(22)
      }
      .width('100%')
      .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_MD })

      // ── 步骤一：选择文件 ──
      if (this.currentStep === ImportStep.SELECT) {
        Scroll() {
          Column() {
            // 课程名称输入
            Text('课程名称').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_SECONDARY).margin({ bottom: StudyTheme.SPACE_SM }).width('100%')
            TextInput({ text: this.courseName, placeholder: '如：概率论与数理统计' })
              .fontSize(StudyTheme.FONT_MD)
              .backgroundColor(StudyTheme.CARD_BG)
              .borderRadius(StudyTheme.RADIUS_MD)
              .border({ width: 1, color: StudyTheme.BORDER })
              .padding(StudyTheme.SPACE_MD)
              .width('100%')
              .margin({ bottom: StudyTheme.SPACE_LG })
              .onChange((value: string) => { this.courseName = value })

            // 文件选择区域
            Column() {
              if (this.selectedFileName.length > 0) {
                Image($r('sys.media.ohos_ic_public_add'))
                  .width(48).height(48)
                  .fillColor(StudyTheme.ACCENT)
                  .margin({ bottom: StudyTheme.SPACE_MD })
                Text(this.selectedFileName)
                  .fontSize(StudyTheme.FONT_MD)
                  .fontColor(StudyTheme.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: StudyTheme.SPACE_SM })
                Text('点击重新选择')
                  .fontSize(StudyTheme.FONT_XS)
                  .fontColor(StudyTheme.TEXT_HINT)
              } else {
                Image($r('sys.media.ohos_ic_public_add'))
                  .width(40).height(40)
                  .fillColor(StudyTheme.TEXT_HINT)
                  .margin({ bottom: StudyTheme.SPACE_MD })
                Text('选择试卷文件')
                  .fontSize(StudyTheme.FONT_MD)
                  .fontColor(StudyTheme.TEXT_HINT)
                  .margin({ bottom: StudyTheme.SPACE_XS })
                Text('支持 PDF / TXT 格式')
                  .fontSize(StudyTheme.FONT_XS)
                  .fontColor(StudyTheme.TEXT_HINT)
              }
            }
            .width('100%')
            .height(160)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(StudyTheme.CARD_BG)
            .borderRadius(StudyTheme.RADIUS_LG)
            .border({ width: 1, color: StudyTheme.BORDER, style: BorderStyle.Dashed })
            .margin({ bottom: StudyTheme.SPACE_LG })
            .onClick(() => { this.handleSelectFile() })

            // 错误提示
            if (this.errorMessage.length > 0) {
              Text(this.errorMessage)
                .fontSize(StudyTheme.FONT_XS)
                .fontColor(StudyTheme.DANGER)
                .margin({ bottom: StudyTheme.SPACE_MD })
                .width('100%')
            }

            // 开始解析按钮
            Row() {
              Text('开始 AI 解析')
                .fontSize(StudyTheme.FONT_MD)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .height(52)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedFileName.length > 0 ? StudyTheme.ACCENT : StudyTheme.TEXT_HINT)
            .borderRadius(StudyTheme.RADIUS_MD)
            .onClick(() => {
              if (this.selectedFileName.length > 0) this.handleUploadAndParse()
            })

            // 提示信息
            Text('AI 将自动识别试卷题目、补充标准答案和考点解析。理科公式将以数学符号渲染。')
              .fontSize(StudyTheme.FONT_XS)
              .fontColor(StudyTheme.TEXT_HINT)
              .lineHeight(18)
              .margin({ top: StudyTheme.SPACE_LG })
              .width('100%')
          }
          .width('100%')
          .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_LG })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // ── 步骤二：上传中 ──
      if (this.currentStep === ImportStep.UPLOADING) {
        Column() {
          LoadingProgress()
            .width(48).height(48)
            .color(StudyTheme.ACCENT)
            .margin({ bottom: StudyTheme.SPACE_XL })
          Text('AI 正在解析试卷...')
            .fontSize(StudyTheme.FONT_LG)
            .fontColor(StudyTheme.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: StudyTheme.SPACE_SM })
          Text('识别题目、补充答案、编写解析')
            .fontSize(StudyTheme.FONT_SM)
            .fontColor(StudyTheme.TEXT_HINT)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }

      // ── 步骤三：预览解析结果 ──
      if (this.currentStep === ImportStep.PREVIEW) {
        Column() {
          // 结果摘要
          Row() {
            Column() {
              Text(`${this.parsedTotalCount}`)
                .fontSize(StudyTheme.FONT_DISPLAY)
                .fontColor(StudyTheme.ACCENT)
                .fontWeight(FontWeight.Bold)
              Text('识别题目')
                .fontSize(StudyTheme.FONT_XS)
                .fontColor(StudyTheme.TEXT_HINT)
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(this.parsedCourseName)
                .fontSize(StudyTheme.FONT_SM)
                .fontColor(StudyTheme.TEXT_SECONDARY)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text('课程名称')
                .fontSize(StudyTheme.FONT_XS)
                .fontColor(StudyTheme.TEXT_HINT)
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding(StudyTheme.SPACE_MD)
          .backgroundColor(StudyTheme.CARD_BG)
          .borderRadius(StudyTheme.RADIUS_LG)
          .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_MD })

          // 卡片列表预览
          List() {
            ForEach(this.parsedCards, (card: QuestionCardDTO, index: number) => {
              ListItem() {
                Column() {
                  Row() {
                    Text(`${index + 1}.`)
                      .fontSize(StudyTheme.FONT_SM)
                      .fontColor(StudyTheme.TEXT_HINT)
                      .margin({ right: StudyTheme.SPACE_SM })
                    Column() {
                      MathRenderer({
                        text: card.question,
                        fontSize: StudyTheme.FONT_MD,
                        fontColor: StudyTheme.TEXT_PRIMARY,
                        lineHeight: 24,
                      })

                      Row() {
                        Text(this.getDifficultyText(card.difficulty))
                          .fontSize(StudyTheme.FONT_XS)
                          .fontColor(StudyTheme.TEXT_HINT)
                          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          .border({ width: 1, color: StudyTheme.BORDER })
                          .borderRadius(StudyTheme.RADIUS_SM)
                          .margin({ right: StudyTheme.SPACE_SM })

                        if (card.related_knowledge.length > 0) {
                          Text(card.related_knowledge[0])
                            .fontSize(StudyTheme.FONT_XS)
                            .fontColor(StudyTheme.ACCENT)
                            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                            .backgroundColor(StudyTheme.ACCENT_BG)
                            .borderRadius(StudyTheme.RADIUS_SM)
                        }
                      }
                      .margin({ top: StudyTheme.SPACE_SM })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)

                    Image($r('sys.media.ohos_ic_public_arrow_down'))
                      .width(16).height(16)
                      .fillColor(StudyTheme.TEXT_HINT)
                      .rotate({ angle: this.flipStates[index] ? 180 : 0 })
                      .animation({ duration: 300, curve: Curve.EaseInOut })
                  }
                  .width('100%')
                  .padding(StudyTheme.SPACE_MD)
                  .alignItems(VerticalAlign.Top)

                  // 翻转后显示答案和解析
                  if (this.flipStates[index]) {
                    Column() {
                      Divider().color(StudyTheme.BORDER).margin({ bottom: StudyTheme.SPACE_MD })

                      Row() {
                        Text('答案').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).width(40)
                        MathRenderer({
                          text: card.answer,
                          fontSize: StudyTheme.FONT_MD,
                          fontColor: StudyTheme.ACCENT,
                          lineHeight: 24,
                        })
                      }
                      .width('100%')
                      .margin({ bottom: StudyTheme.SPACE_SM })
                      .alignItems(VerticalAlign.Top)

                      Row() {
                        Text('解析').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).width(40)
                        MathRenderer({
                          text: card.explanation,
                          fontSize: StudyTheme.FONT_SM,
                          fontColor: StudyTheme.TEXT_SECONDARY,
                          lineHeight: 22,
                        })
                      }
                      .width('100%')
                      .margin({ bottom: card.common_mistake.length > 0 ? StudyTheme.SPACE_SM : 0 })
                      .alignItems(VerticalAlign.Top)

                      if (card.common_mistake.length > 0) {
                        Row() {
                          Text(card.common_mistake)
                            .fontSize(StudyTheme.FONT_XS)
                            .fontColor(StudyTheme.WARNING)
                            .padding(8)
                        }
                        .width('100%')
                        .backgroundColor(StudyTheme.WARNING_BG)
                        .borderRadius(StudyTheme.RADIUS_SM)
                      }
                    }
                    .width('100%')
                    .padding({ left: StudyTheme.SPACE_MD, right: StudyTheme.SPACE_MD, bottom: StudyTheme.SPACE_MD })
                  }
                }
                .width('100%')
                .backgroundColor(StudyTheme.CARD_BG)
                .borderRadius(StudyTheme.RADIUS_MD)
                .border({ width: 1, color: StudyTheme.BORDER })
                .onClick(() => { this.toggleFlip(index) })
              }
              .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_SM })
            }, (card: QuestionCardDTO, index: number) => `preview_${index}`)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)

          // 底部操作栏
          Column() {
            Row() {
              Row() {
                Text('返回修改')
                  .fontSize(StudyTheme.FONT_SM)
                  .fontColor(StudyTheme.TEXT_SECONDARY)
              }
              .width('45%')
              .height(48)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(StudyTheme.CARD_BG)
              .borderRadius(StudyTheme.RADIUS_MD)
              .border({ width: 1, color: StudyTheme.BORDER })
              .onClick(() => {
                this.currentStep = ImportStep.SELECT
                this.parsedCards = []
              })

              Row() {
                Text(`导入题库 · 开始刷题 (${this.parsedTotalCount}题)`)
                  .fontSize(StudyTheme.FONT_SM)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Medium)
              }
              .layoutWeight(1)
              .height(48)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(StudyTheme.ACCENT)
              .borderRadius(StudyTheme.RADIUS_MD)
              .margin({ left: StudyTheme.SPACE_MD })
              .onClick(() => { this.handleImportToBank() })
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_MD, bottom: StudyTheme.SPACE_XXL })
          .backgroundColor(StudyTheme.CARD_BG)
          .border({ width: { top: 1 }, color: StudyTheme.BORDER })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(StudyTheme.BG)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(StudyTheme.BG)
  }
}
