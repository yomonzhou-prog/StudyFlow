/**
 * StudyFlow OS - 新手引导页
 */

import { router } from '@kit.ArkUI'
import { StudyTheme } from '../common/StudyTheme'

interface OnboardingSlide { title: string; description: string }

@Entry
@Component
struct OnboardingPage {
  @State currentIndex: number = 0
  private swiperController: SwiperController = new SwiperController()
  private slides: OnboardingSlide[] = [
    { title: '导入复习资料', description: '粘贴期末复习题、考试安排、老师重点，系统自动拆分为一张张复习卡片。支持文本输入，拍照OCR功能开发中。' },
    { title: '沉浸式卡片复习', description: '一题一卡，左右翻转。查看答案后选择认识、模糊或忘了，系统自动记录薄弱点，错题自动加入错题本。' },
    { title: '智能复习规划', description: '根据考试倒计时、老师重点、错题反馈和知识点难度，自动计算复习优先级。每天告诉你今天该复习什么。' }
  ]

  handleGetStarted(): void { router.replaceUrl({ url: 'pages/LoginPage' }) }
  handleSkip(): void { router.replaceUrl({ url: 'pages/LoginPage' }) }

  build() {
    Column() {
      Row() { Blank(); Text('跳过').fontSize(StudyTheme.FONT_MD).fontColor(StudyTheme.TEXT_SECONDARY).padding({ left: StudyTheme.SPACE_LG, right: StudyTheme.SPACE_LG, top: StudyTheme.SPACE_MD, bottom: StudyTheme.SPACE_MD }).onClick(() => { this.handleSkip() }) }
      .width('100%').padding({ top: StudyTheme.SPACE_XL, right: StudyTheme.SPACE_MD })
      Swiper(this.swiperController) {
        ForEach(this.slides, (slide: OnboardingSlide) => {
          Column() {
            Column() { Text(`${this.slides.indexOf(slide) + 1}`).fontSize(20).fontColor(StudyTheme.ACCENT).fontWeight(FontWeight.Bold) }
            .width(48).height(48).borderRadius(24).backgroundColor(StudyTheme.ACCENT_BG).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).margin({ bottom: StudyTheme.SPACE_XXL })
            Text(slide.title).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
            Text(slide.description).fontSize(StudyTheme.FONT_MD).fontColor(StudyTheme.TEXT_SECONDARY).textAlign(TextAlign.Center).maxLines(5).lineHeight(24).padding({ left: StudyTheme.SPACE_XXL, right: StudyTheme.SPACE_XXL }).margin({ top: StudyTheme.SPACE_LG })
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).width('100%').height('100%')
        })
      }
      .index(this.currentIndex).indicator(true).loop(false).duration(300).curve(Curve.EaseInOut).onChange((index: number) => { this.currentIndex = index }).layoutWeight(1)
      Column() {
        Row() { ForEach(this.slides, (_: OnboardingSlide, i: number) => { Row().width(this.currentIndex === i ? 24 : 8).height(8).borderRadius(4).backgroundColor(this.currentIndex === i ? StudyTheme.ACCENT : StudyTheme.BORDER).margin({ left: 4, right: 4 }).animation({ duration: 200, curve: Curve.EaseInOut }) }) }
        .justifyContent(FlexAlign.Center).width('100%').margin({ bottom: StudyTheme.SPACE_LG })
        Row() { Text(this.currentIndex === this.slides.length - 1 ? '开始学习' : '下一步').fontSize(StudyTheme.FONT_MD).fontColor(StudyTheme.TEXT_INVERSE).fontWeight(FontWeight.Medium) }
        .width('100%').height(48).justifyContent(FlexAlign.Center).backgroundColor(StudyTheme.ACCENT).borderRadius(StudyTheme.RADIUS_MD)
        .onClick(() => { if (this.currentIndex < this.slides.length - 1) this.swiperController.showNext(); else this.handleGetStarted() })
        if (this.currentIndex < this.slides.length - 1) Text('跳过').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_SECONDARY).margin({ top: StudyTheme.SPACE_LG }).onClick(() => { this.handleSkip() })
      }.width('100%').padding({ left: StudyTheme.SPACE_XXL, right: StudyTheme.SPACE_XXL, bottom: StudyTheme.SPACE_XXL })
    }.width('100%').height('100%').backgroundColor(StudyTheme.BG)
  }
}
