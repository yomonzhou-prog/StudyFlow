/**
 * StudyFlow OS - 启动页
 */

import { router } from '@kit.ArkUI'
import { AuthStore } from '../services/AuthStore'
import { StudyTheme } from '../common/StudyTheme'

@Entry
@Component
struct SplashPage {
  private authStore: AuthStore = AuthStore.getInstance()
  aboutToAppear(): void {
    this.authStore.initMockData()
    setTimeout(() => { this.navigateToNext() }, 1500)
  }
  navigateToNext(): void {
    if (this.authStore.isLoggedIn()) router.replaceUrl({ url: 'pages/MainPage' })
    else if (this.authStore.isFirstLaunch()) router.replaceUrl({ url: 'pages/OnboardingPage' })
    else router.replaceUrl({ url: 'pages/LoginPage' })
  }
  build() {
    Column() {
      Column() {
        Text('S').fontSize(48).fontColor(StudyTheme.ACCENT).fontWeight(FontWeight.Bold)
        Text('StudyFlow').fontSize(StudyTheme.FONT_TITLE).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold).margin({ top: StudyTheme.SPACE_MD })
        Text('期末复习，从一张卡片开始').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_SECONDARY).margin({ top: StudyTheme.SPACE_SM })
        LoadingProgress().width(32).height(32).color(StudyTheme.ACCENT).margin({ top: StudyTheme.SPACE_XXXL })
      }
      .alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center).width('100%').height('100%')
    }
    .width('100%').height('100%').backgroundColor(StudyTheme.BG)
  }
}
