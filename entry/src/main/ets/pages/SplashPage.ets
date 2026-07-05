/**
 * StudyFlow OS - 启动页
 * 显示应用 Logo，1.5秒后自动跳转：
 *   已登录 → MainPage
 *   首次使用 → OnboardingPage
 *   未登录 → LoginPage
 */

import { router } from '@kit.ArkUI'
import { AuthStore } from '../services/AuthStore'
import { Theme } from '../common/Theme'

@Entry
@Component
struct SplashPage {
  private authStore: AuthStore = AuthStore.getInstance()

  aboutToAppear(): void {
    this.authStore.initMockData()
    setTimeout(() => {
      this.navigateToNext()
    }, 1500)
  }

  navigateToNext(): void {
    if (this.authStore.isLoggedIn()) {
      router.replaceUrl({ url: 'pages/MainPage' })
    } else if (this.authStore.isFirstLaunch()) {
      router.replaceUrl({ url: 'pages/OnboardingPage' })
    } else {
      router.replaceUrl({ url: 'pages/LoginPage' })
    }
  }

  build() {
    Column() {
      Column() {
        // Logo
        Text('📚')
          .fontSize(72)
          .margin({ bottom: Theme.SPACING_LG })

        // App Name
        Text('StudyFlow OS')
          .fontSize(Theme.FONT_TITLE)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)

        // Tagline
        Text('让学习有结构，让知识有回路')
          .fontSize(Theme.FONT_SM)
          .fontColor(Theme.TEXT_SECONDARY)
          .margin({ top: Theme.SPACING_SM })

        // Loading indicator
        LoadingProgress()
          .width(36)
          .height(36)
          .color(Theme.PRIMARY)
          .margin({ top: Theme.SPACING_XXL + Theme.SPACING_XL })
      }
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }
}
