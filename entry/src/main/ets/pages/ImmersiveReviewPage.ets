/**
 * StudyFlow OS — 沉浸式复习卡片页（v3.1 增强版）
 * 单卡片模式：题目 → 查看答案 → 认识/模糊/忘了 → 下一张
 * v3.1: 集成 MathRenderer 数学公式渲染 + 滑动手势切换
 */

import { router } from '@kit.ArkUI'
import { QuestionCardStore } from '../services/QuestionCardStore'
import { QuestionCard } from '../models/QuestionCard'
import { StudyTheme } from '../common/StudyTheme'
import { MathRenderer } from '../components/MathRenderer'

@Entry
@Component
struct ImmersiveReviewPage {
  @State cards: QuestionCard[] = []
  @State currentIndex: number = 0
  @State showAnswer: boolean = false
  @State isComplete: boolean = false
  @State totalCards: number = 0
  @State swipeOffset: number = 0    // 手势滑动偏移
  private cardStore: QuestionCardStore = QuestionCardStore.getInstance()

  aboutToAppear(): void {
    this.cardStore.initMockData()
    this.cards = this.cardStore.getTodayReviewCards()
    if (this.cards.length === 0) this.cards = this.cardStore.getCards()
    this.totalCards = this.cards.length
  }

  getCurrentCard(): QuestionCard | null {
    return this.cards.length > 0 && this.currentIndex < this.cards.length ? this.cards[this.currentIndex] : null
  }
  getCorrectCount(): number { return this.cards.filter(c => c.lastResult === 'correct').length }
  getUnclearCount(): number { return this.cards.filter(c => c.lastResult === 'unclear').length }
  getWrongCount(): number { return this.cards.filter(c => c.lastResult === 'wrong').length }

  handleShowAnswer(): void { this.showAnswer = true }
  handleFeedback(result: string): void {
    const card = this.getCurrentCard()
    if (card) this.cardStore.markResult(card.id, result)
    if (this.currentIndex >= this.cards.length - 1) this.isComplete = true
    else { this.currentIndex++; this.showAnswer = false; this.swipeOffset = 0 }
  }
  handleRestart(): void {
    this.currentIndex = 0; this.showAnswer = false; this.isComplete = false; this.swipeOffset = 0
    for (const c of this.cards) c.lastResult = ''
  }

  // ─── 滑动手势处理 ───

  handleSwipeStart(): void { /* gesture start */ }
  handleSwipeUpdate(event: GestureEvent): void {
    this.swipeOffset = event.offsetX
  }
  handleSwipeEnd(): void {
    if (Math.abs(this.swipeOffset) > 80 && !this.showAnswer) {
      // 左滑跳过（标记为模糊）
      if (this.swipeOffset < -80) {
        this.handleFeedback('unclear')
      }
      // 右滑认识
      else if (this.swipeOffset > 80) {
        this.handleFeedback('correct')
      }
    }
    this.swipeOffset = 0
  }

  // ─── 难度标签文本 ───

  getDifficultyLabel(): string {
    const card = this.getCurrentCard()
    if (!card) return ''
    return card.difficulty === 'easy' ? '简单' : card.difficulty === 'hard' ? '困难' : '中等'
  }

  build() {
    Column() {
      if (this.cards.length === 0) {
        // ── 空状态 ──
        Column() {
          Text('暂无复习卡片')
            .fontSize(StudyTheme.FONT_LG)
            .fontColor(StudyTheme.TEXT_HINT)
            .margin({ bottom: StudyTheme.SPACE_MD })
          Row() {
            Text('导入题目').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_INVERSE).fontWeight(FontWeight.Medium)
              .padding({ left: 24, right: 24, top: 10, bottom: 10 })
              .backgroundColor(StudyTheme.ACCENT).borderRadius(StudyTheme.RADIUS_FULL)
          }
          .onClick(() => { router.pushUrl({ url: 'pages/ExamPaperImportPage' }) })
          Row() {
            Text('上传试卷').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.ACCENT).fontWeight(FontWeight.Medium)
              .padding({ left: 24, right: 24, top: 10, bottom: 10 })
              .border({ width: 1, color: StudyTheme.ACCENT }).borderRadius(StudyTheme.RADIUS_FULL)
              .margin({ left: StudyTheme.SPACE_MD })
          }
          .onClick(() => { router.pushUrl({ url: 'pages/FileImportPage' }) })
        }
        .width('100%').height('100%')
        .justifyContent(FlexAlign.Center).backgroundColor(StudyTheme.BG)
      } else if (this.isComplete) {
        // ── 完成页 ──
        Column() {
          Column() {
            Text('复习完成')
              .fontSize(StudyTheme.FONT_XXL)
              .fontColor(StudyTheme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: StudyTheme.SPACE_XL })

            Row() {
              Column() {
                Text(this.totalCards.toString()).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
                Text('总题数').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              Column() {
                Text(this.getCorrectCount().toString()).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
                Text('认识').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              Column() {
                Text(this.getUnclearCount().toString()).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
                Text('模糊').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              Column() {
                Text(this.getWrongCount().toString()).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
                Text('忘了').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }.width('100%')

            if (this.getWrongCount() > 0) {
              Text(`${this.getWrongCount()} 道错题已加入错题本`)
                .fontSize(StudyTheme.FONT_SM)
                .fontColor(StudyTheme.TEXT_HINT)
                .margin({ top: StudyTheme.SPACE_LG })
            }
          }
          .width('100%')
          .padding(StudyTheme.SPACE_XXL)
          .backgroundColor(StudyTheme.CARD_BG)
          .borderRadius(StudyTheme.RADIUS_LG)
          .border({ width: 1, color: StudyTheme.CARD_BORDER })

          Blank()
          Row() {
            Text('再复习一次').fontSize(StudyTheme.FONT_MD).fontColor(StudyTheme.TEXT_INVERSE).fontWeight(FontWeight.Medium)
          }
          .width('100%').height(52)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(StudyTheme.ACCENT)
          .borderRadius(StudyTheme.RADIUS_MD)
          .onClick(() => { this.handleRestart() })
          .margin({ bottom: StudyTheme.SPACE_MD, left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD })

          Row() {
            Text('返回首页').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_SECONDARY)
          }
          .width('100%').height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => { router.replaceUrl({ url: 'pages/MainPage' }) })
          .margin({ bottom: StudyTheme.SPACE_XXL })
        }
        .width('100%').height('100%')
        .backgroundColor(StudyTheme.BG)
        .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XXL })
      } else {
        // ── 卡片复习 ──
        Column() {
          // 顶部导航
          Row() {
            Image($r('sys.media.ohos_ic_public_arrow_left'))
              .width(22).height(22)
              .fillColor(StudyTheme.TEXT_HINT)
              .onClick(() => { router.back() })
            Text(`${this.currentIndex + 1} / ${this.totalCards}`)
              .fontSize(StudyTheme.FONT_SM)
              .fontColor(StudyTheme.TEXT_HINT)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
            Text(this.getDifficultyLabel())
              .fontSize(StudyTheme.FONT_XS)
              .fontColor(StudyTheme.TEXT_HINT)
              .padding({ left: 8, right: 8, top: 3, bottom: 3 })
              .border({ width: 1, color: StudyTheme.BORDER })
              .borderRadius(StudyTheme.RADIUS_SM)
          }
          .width('100%')
          .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_SM })

          // 进度条
          Progress({ value: this.currentIndex + 1, total: this.totalCards, type: ProgressType.Linear })
            .width('100%').height(3)
            .color(StudyTheme.ACCENT)
            .backgroundColor(StudyTheme.BORDER)

          // 卡片内容（支持手势滑动）
          Scroll() {
            Column() {
              // 知识点标签
              if (this.getCurrentCard() && this.getCurrentCard()!.relatedKnowledge.length > 0) {
                Row() {
                  ForEach(this.getCurrentCard()!.relatedKnowledge.slice(0, 3), (tag: string) => {
                    Text(tag)
                      .fontSize(StudyTheme.FONT_XS)
                      .fontColor(StudyTheme.ACCENT)
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .backgroundColor(StudyTheme.ACCENT_BG)
                      .borderRadius(StudyTheme.RADIUS_SM)
                      .margin({ right: StudyTheme.SPACE_SM })
                  })
                }.width('100%').margin({ bottom: StudyTheme.SPACE_XL })
              }

              // 题干 — 使用 MathRenderer 渲染 LaTeX 公式
              if (this.getCurrentCard()) {
                MathRenderer({
                  text: this.getCurrentCard()!.question,
                  fontSize: StudyTheme.FONT_XL,
                  fontColor: StudyTheme.TEXT_PRIMARY,
                  lineHeight: 30,
                })
                .width('100%')
              }

              // 选项列表
              if (this.getCurrentCard() && this.getCurrentCard()!.options.length > 0) {
                Column() {
                  ForEach(this.getCurrentCard()!.options, (opt: string, idx: number) => {
                    Row() {
                      Text(String.fromCharCode(65 + idx))  // A, B, C, D
                        .fontSize(StudyTheme.FONT_SM)
                        .fontColor(StudyTheme.ACCENT)
                        .fontWeight(FontWeight.Bold)
                        .width(24)
                      MathRenderer({
                        text: opt,
                        fontSize: StudyTheme.FONT_MD,
                        fontColor: StudyTheme.TEXT_PRIMARY,
                        lineHeight: 24,
                      })
                      .layoutWeight(1)
                    }
                    .width('100%')
                    .padding({ top: StudyTheme.SPACE_SM, bottom: StudyTheme.SPACE_SM })
                    .alignItems(VerticalAlign.Top)
                  })
                }
                .width('100%')
                .margin({ top: StudyTheme.SPACE_LG })
              }

              // 答案区（点击后展开）
              if (this.showAnswer && this.getCurrentCard()) {
                Column() {
                  Divider()
                    .color(StudyTheme.BORDER)
                    .margin({ top: StudyTheme.SPACE_XXL, bottom: StudyTheme.SPACE_XXL })

                  Text('答案')
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.TEXT_HINT)
                    .margin({ bottom: StudyTheme.SPACE_SM })

                  MathRenderer({
                    text: this.getCurrentCard()!.answer,
                    fontSize: StudyTheme.FONT_XL,
                    fontColor: StudyTheme.ACCENT,
                    lineHeight: 30,
                  })
                  .width('100%')
                  .margin({ bottom: StudyTheme.SPACE_LG })

                  Text('解析')
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.TEXT_HINT)
                    .margin({ bottom: StudyTheme.SPACE_SM })

                  MathRenderer({
                    text: this.getCurrentCard()!.explanation,
                    fontSize: StudyTheme.FONT_MD,
                    fontColor: StudyTheme.TEXT_SECONDARY,
                    lineHeight: 24,
                  })
                  .width('100%')

                  // 常见错误
                  if (this.getCurrentCard()!.commonMistake) {
                    Row() {
                      MathRenderer({
                        text: this.getCurrentCard()!.commonMistake,
                        fontSize: StudyTheme.FONT_XS,
                        fontColor: StudyTheme.WARNING,
                        lineHeight: 18,
                      })
                      .padding(10)
                    }
                    .width('100%')
                    .backgroundColor(StudyTheme.WARNING_BG)
                    .borderRadius(StudyTheme.RADIUS_SM)
                    .margin({ top: StudyTheme.SPACE_LG })
                  }

                  Column().height(40)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }

              Column().height(120)
            }
            .width('100%')
            .padding({ left: StudyTheme.SPACE_XXL, right: StudyTheme.SPACE_XXL, top: StudyTheme.SPACE_XL })
          }
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .gesture(
            PanGesture({ direction: PanDirection.Horizontal, distance: 20 })
              .onActionStart(() => { this.handleSwipeStart() })
              .onActionUpdate((event: GestureEvent) => { this.handleSwipeUpdate(event) })
              .onActionEnd(() => { this.handleSwipeEnd() })
          )
          .offset({ x: this.swipeOffset })
          .animation({ duration: 200, curve: Curve.EaseOut })

          // 底部操作栏
          Column() {
            if (!this.showAnswer) {
              Row() {
                Text('查看答案')
                  .fontSize(StudyTheme.FONT_MD)
                  .fontColor(StudyTheme.TEXT_INVERSE)
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%').height(52)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(StudyTheme.ACCENT)
              .borderRadius(StudyTheme.RADIUS_MD)
              .margin({ left: StudyTheme.SPACE_XXL, right: StudyTheme.SPACE_XXL })
              .onClick(() => { this.handleShowAnswer() })
            } else {
              Row() {
                // 忘了
                Column() {
                  Text('忘了').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.DANGER).fontWeight(FontWeight.Medium)
                }
                .width('30%').height(48)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(StudyTheme.DANGER_BG)
                .borderRadius(StudyTheme.RADIUS_MD)
                .border({ width: 1, color: StudyTheme.DANGER })
                .onClick(() => { this.handleFeedback('wrong') })

                // 模糊
                Column() {
                  Text('模糊').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.WARNING).fontWeight(FontWeight.Medium)
                }
                .layoutWeight(1).height(48)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(StudyTheme.WARNING_BG)
                .borderRadius(StudyTheme.RADIUS_MD)
                .border({ width: 1, color: StudyTheme.WARNING })
                .margin({ left: StudyTheme.SPACE_SM, right: StudyTheme.SPACE_SM })
                .onClick(() => { this.handleFeedback('unclear') })

                // 认识
                Column() {
                  Text('认识').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.SUCCESS).fontWeight(FontWeight.Medium)
                }
                .width('30%').height(48)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(StudyTheme.SUCCESS_BG)
                .borderRadius(StudyTheme.RADIUS_MD)
                .border({ width: 1, color: StudyTheme.SUCCESS })
                .onClick(() => { this.handleFeedback('correct') })
              }
              .width('100%')
              .padding({ left: StudyTheme.SPACE_XXL, right: StudyTheme.SPACE_XXL })
            }

            // 滑动手势提示
            Text('← 左滑跳过  |  右滑认识 →')
              .fontSize(10)
              .fontColor(StudyTheme.TEXT_HINT)
              .margin({ top: StudyTheme.SPACE_SM })
          }
          .width('100%')
          .padding({ top: StudyTheme.SPACE_MD, bottom: StudyTheme.SPACE_XXL })
          .backgroundColor(StudyTheme.CARD_BG)
          .border({ width: { top: 1 }, color: StudyTheme.BORDER })
        }
        .width('100%').height('100%')
        .backgroundColor(StudyTheme.BG)
      }
    }
    .width('100%').height('100%')
    .backgroundColor(StudyTheme.BG)
  }
}
