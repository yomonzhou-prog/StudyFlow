/**
 * StudyFlow OS - 新手引导页
 * Swiper 展示 3 页功能介绍，最后一页可进入应用
 */

import { router } from '@kit.ArkUI'
import { Theme } from '../common/Theme'
import { PrimaryButton } from '../components/AppButton'

interface OnboardingSlide {
  emoji: string
  title: string
  description: string
}

@Entry
@Component
struct OnboardingPage {
  @State currentIndex: number = 0
  private swiperController: SwiperController = new SwiperController()

  private slides: OnboardingSlide[] = [
    {
      emoji: '📋',
      title: '输入课程资料',
      description: '支持教材、PPT、通知、作业等多种资料类型。粘贴文本即可自动解析为结构化知识点。'
    },
    {
      emoji: '🧠',
      title: '知识点结构化',
      description: 'DeepSeek AI 自动提取知识点、标注重要程度和难度，构建属于你的知识地图。'
    },
    {
      emoji: '📝',
      title: '智能复习闭环',
      description: '自动生成复习卡片和自测题。反馈"掌握/模糊/做错"后，AI 会为你制定二次复习计划。'
    }
  ]

  handleGetStarted(): void {
    router.replaceUrl({ url: 'pages/LoginPage' })
  }

  handleSkip(): void {
    router.replaceUrl({ url: 'pages/LoginPage' })
  }

  build() {
    Column() {
      // Skip button
      Row() {
        Blank()
        Text('跳过')
          .fontSize(Theme.FONT_MD)
          .fontColor(Theme.TEXT_SECONDARY)
          .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD, bottom: Theme.SPACING_MD })
          .onClick(() => { this.handleSkip() })
      }
      .width('100%')
      .padding({ top: Theme.SPACING_XL, right: Theme.SPACING_MD })

      // Swiper
      Swiper(this.swiperController) {
        ForEach(this.slides, (slide: OnboardingSlide) => {
          Column() {
            Text(slide.emoji)
              .fontSize(80)
              .margin({ bottom: Theme.SPACING_XXL })

            Text(slide.title)
              .fontSize(Theme.FONT_XXL)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)

            Text(slide.description)
              .fontSize(Theme.FONT_MD)
              .fontColor(Theme.TEXT_SECONDARY)
              .textAlign(TextAlign.Center)
              .maxLines(4)
              .lineHeight(24)
              .padding({ left: Theme.SPACING_XXL, right: Theme.SPACING_XXL })
              .margin({ top: Theme.SPACING_LG })
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .height('100%')
        })
      }
      .index(this.currentIndex)
      .indicator(true)
      .loop(false)
      .duration(300)
      .curve(Curve.EaseInOut)
      .onChange((index: number) => { this.currentIndex = index })
      .layoutWeight(1)

      // Bottom area
      Column() {
        // Dots indicator (custom)
        Row() {
          ForEach(this.slides, (_slide: OnboardingSlide, index: number) => {
            Row()
              .width(this.currentIndex === index ? 24 : 8)
              .height(8)
              .borderRadius(4)
              .backgroundColor(this.currentIndex === index ? Theme.PRIMARY : Theme.BORDER)
              .margin({ left: 4, right: 4 })
              .animation({ duration: 200, curve: Curve.EaseInOut })
          })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .margin({ bottom: Theme.SPACING_LG })

        PrimaryButton({
          label: this.currentIndex === this.slides.length - 1 ? '开始学习' : '下一步',
          onAction: () => {
            if (this.currentIndex < this.slides.length - 1) {
              this.swiperController.showNext()
            } else {
              this.handleGetStarted()
            }
          }
        })

        if (this.currentIndex < this.slides.length - 1) {
          Text('跳过')
            .fontSize(Theme.FONT_SM)
            .fontColor(Theme.TEXT_SECONDARY)
            .margin({ top: Theme.SPACING_LG })
            .onClick(() => { this.handleSkip() })
        }
      }
      .width('100%')
      .padding({
        left: Theme.SPACING_XXL,
        right: Theme.SPACING_XXL,
        bottom: Theme.SPACING_XXL
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }
}
