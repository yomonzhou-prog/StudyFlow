/**
 * StudyFlow OS - 沉浸式复习卡片页
 * 单卡片：题目 → 查看答案 → 认识/模糊/忘了 → 下一张
 */

import { router } from '@kit.ArkUI'
import { QuestionCardStore } from '../services/QuestionCardStore'
import { QuestionCard } from '../models/QuestionCard'
import { StudyTheme } from '../common/StudyTheme'

@Entry
@Component
struct ImmersiveReviewPage {
  @State cards: QuestionCard[] = []
  @State currentIndex: number = 0
  @State showAnswer: boolean = false
  @State isComplete: boolean = false
  @State totalCards: number = 0
  private cardStore: QuestionCardStore = QuestionCardStore.getInstance()

  aboutToAppear(): void {
    this.cardStore.initMockData()
    this.cards = this.cardStore.getTodayReviewCards()
    if (this.cards.length === 0) this.cards = this.cardStore.getCards()
    this.totalCards = this.cards.length
  }

  getCurrentCard(): QuestionCard | null { return this.cards.length > 0 && this.currentIndex < this.cards.length ? this.cards[this.currentIndex] : null }
  getCorrectCount(): number { return this.cards.filter(c => c.lastResult === 'correct').length }
  getUnclearCount(): number { return this.cards.filter(c => c.lastResult === 'unclear').length }
  getWrongCount(): number { return this.cards.filter(c => c.lastResult === 'wrong').length }

  handleShowAnswer(): void { this.showAnswer = true }
  handleFeedback(result: string): void {
    const card = this.getCurrentCard()
    if (card) this.cardStore.markResult(card.id, result)
    if (this.currentIndex >= this.cards.length - 1) this.isComplete = true
    else { this.currentIndex++; this.showAnswer = false }
  }
  handleRestart(): void {
    this.currentIndex = 0; this.showAnswer = false; this.isComplete = false
    for (const c of this.cards) c.lastResult = ''
  }

  build() {
    Column() {
      if (this.cards.length === 0) {
        Column() {
          Text('暂无复习卡片').fontSize(StudyTheme.FONT_LG).fontColor(StudyTheme.TEXT_HINT).margin({ bottom: StudyTheme.SPACE_MD })
          Row() { Text('导入题目').fontSize(StudyTheme.FONT_SM).fontColor('#FFFFFF').fontWeight(FontWeight.Medium).padding({ left: 24, right: 24, top: 10, bottom: 10 }).backgroundColor(StudyTheme.ACCENT).borderRadius(StudyTheme.RADIUS_FULL) }
          .onClick(() => { router.pushUrl({ url: 'pages/ExamPaperImportPage' }) })
        }.width('100%').height('100%').justifyContent(FlexAlign.Center).backgroundColor(StudyTheme.BG)
      } else if (this.isComplete) {
        Column() {
          Column() {
            Text('复习完成').fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold).margin({ bottom: StudyTheme.SPACE_XL })
            Row() {
              Column() { Text(this.totalCards.toString()).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold); Text('总题数').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 }) }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              Column() { Text(this.getCorrectCount().toString()).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold); Text('认识').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 }) }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              Column() { Text(this.getUnclearCount().toString()).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold); Text('模糊').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 }) }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              Column() { Text(this.getWrongCount().toString()).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold); Text('忘了').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 }) }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }.width('100%')
            if (this.getWrongCount() > 0) Text(`${this.getWrongCount()} 道错题已加入错题本`).fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_HINT).margin({ top: StudyTheme.SPACE_LG })
          }.width('100%').padding(StudyTheme.SPACE_XXL).backgroundColor(StudyTheme.CARD_BG).borderRadius(StudyTheme.RADIUS_LG).border({ width: 1, color: StudyTheme.CARD_BORDER })
          Blank()
          Row() { Text('再复习一次').fontSize(StudyTheme.FONT_MD).fontColor('#FFFFFF').fontWeight(FontWeight.Medium) }
          .width('100%').height(52).justifyContent(FlexAlign.Center).backgroundColor(StudyTheme.ACCENT).borderRadius(StudyTheme.RADIUS_MD)
          .onClick(() => { this.handleRestart() }).margin({ bottom: StudyTheme.SPACE_MD, left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD })
          Row() { Text('返回首页').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_SECONDARY) }
          .width('100%').height(44).justifyContent(FlexAlign.Center).onClick(() => { router.replaceUrl({ url: 'pages/MainPage' }) }).margin({ bottom: StudyTheme.SPACE_XXL })
        }.width('100%').height('100%').backgroundColor(StudyTheme.BG).padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XXL })
      } else {
        Column() {
          Row() {
            Image($r('sys.media.ohos_ic_public_arrow_left')).width(22).height(22).fillColor(StudyTheme.TEXT_HINT).onClick(() => { router.back() })
            Text(`${this.currentIndex + 1} / ${this.totalCards}`).fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_HINT).layoutWeight(1).textAlign(TextAlign.Center)
            if (this.getCurrentCard()) Text(this.getCurrentCard()!.difficulty === 'easy' ? '简单' : this.getCurrentCard()!.difficulty === 'hard' ? '困难' : '中等').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).padding({ left: 8, right: 8, top: 3, bottom: 3 }).border({ width: 1, color: StudyTheme.BORDER }).borderRadius(StudyTheme.RADIUS_SM)
          }.width('100%').padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_SM })
          Progress({ value: this.currentIndex + 1, total: this.totalCards, type: ProgressType.Linear }).width('100%').height(3).color(StudyTheme.ACCENT).backgroundColor(StudyTheme.BORDER)
          Scroll() {
            Column() {
              if (this.getCurrentCard() && this.getCurrentCard()!.relatedKnowledge.length > 0) {
                Row() {
                  ForEach(this.getCurrentCard()!.relatedKnowledge.slice(0, 3), (tag: string) => {
                    Text(tag).fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.ACCENT).padding({ left: 8, right: 8, top: 4, bottom: 4 }).backgroundColor(StudyTheme.ACCENT_BG).borderRadius(StudyTheme.RADIUS_SM).margin({ right: StudyTheme.SPACE_SM })
                  })
                }.width('100%').margin({ bottom: StudyTheme.SPACE_XL })
              }
              Text(this.getCurrentCard()!.question).fontSize(StudyTheme.FONT_XL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium).lineHeight(30).width('100%')
              if (this.showAnswer && this.getCurrentCard()) {
                Column() {
                  Divider().color(StudyTheme.BORDER).margin({ top: StudyTheme.SPACE_XXL, bottom: StudyTheme.SPACE_XXL })
                  Text('答案').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ bottom: StudyTheme.SPACE_SM })
                  Text(this.getCurrentCard()!.answer).fontSize(StudyTheme.FONT_XL).fontColor(StudyTheme.ACCENT).fontWeight(FontWeight.Bold).margin({ bottom: StudyTheme.SPACE_LG })
                  Text('解析').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ bottom: StudyTheme.SPACE_SM })
                  Text(this.getCurrentCard()!.explanation).fontSize(StudyTheme.FONT_MD).fontColor(StudyTheme.TEXT_SECONDARY).lineHeight(24)
                  if (this.getCurrentCard()!.commonMistake) {
                    Row() { Text(this.getCurrentCard()!.commonMistake).fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.WARNING).padding(10) }
                    .width('100%').backgroundColor(StudyTheme.WARNING_BG).borderRadius(StudyTheme.RADIUS_SM).margin({ top: StudyTheme.SPACE_LG })
                  }
                  Column().height(40)
                }.width('100%').alignItems(HorizontalAlign.Start)
              }
              Column().height(120)
            }.width('100%').padding({ left: StudyTheme.SPACE_XXL, right: StudyTheme.SPACE_XXL, top: StudyTheme.SPACE_XL })
          }.scrollBar(BarState.Off).layoutWeight(1)
          Column() {
            if (!this.showAnswer) {
              Row() { Text('查看答案').fontSize(StudyTheme.FONT_MD).fontColor('#FFFFFF').fontWeight(FontWeight.Medium) }
              .width('100%').height(52).justifyContent(FlexAlign.Center).backgroundColor(StudyTheme.ACCENT).borderRadius(StudyTheme.RADIUS_MD)
              .margin({ left: StudyTheme.SPACE_XXL, right: StudyTheme.SPACE_XXL }).onClick(() => { this.handleShowAnswer() })
            } else {
              Row() {
                Column() { Text('忘了').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.DANGER).fontWeight(FontWeight.Medium) }
                .width('30%').height(48).justifyContent(FlexAlign.Center).backgroundColor(StudyTheme.DANGER_BG).borderRadius(StudyTheme.RADIUS_MD).border({ width: 1, color: StudyTheme.DANGER }).onClick(() => { this.handleFeedback('wrong') })
                Column() { Text('模糊').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.WARNING).fontWeight(FontWeight.Medium) }
                .layoutWeight(1).height(48).justifyContent(FlexAlign.Center).backgroundColor(StudyTheme.WARNING_BG).borderRadius(StudyTheme.RADIUS_MD).border({ width: 1, color: StudyTheme.WARNING }).margin({ left: StudyTheme.SPACE_SM, right: StudyTheme.SPACE_SM }).onClick(() => { this.handleFeedback('unclear') })
                Column() { Text('认识').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.SUCCESS).fontWeight(FontWeight.Medium) }
                .width('30%').height(48).justifyContent(FlexAlign.Center).backgroundColor(StudyTheme.SUCCESS_BG).borderRadius(StudyTheme.RADIUS_MD).border({ width: 1, color: StudyTheme.SUCCESS }).onClick(() => { this.handleFeedback('correct') })
              }.width('100%').padding({ left: StudyTheme.SPACE_XXL, right: StudyTheme.SPACE_XXL })
            }
          }.width('100%').padding({ top: StudyTheme.SPACE_MD, bottom: StudyTheme.SPACE_XXL }).backgroundColor(StudyTheme.CARD_BG).border({ width: { top: 1 }, color: StudyTheme.BORDER })
        }.width('100%').height('100%').backgroundColor(StudyTheme.BG)
      }
    }.width('100%').height('100%').backgroundColor(StudyTheme.BG)
  }
}
