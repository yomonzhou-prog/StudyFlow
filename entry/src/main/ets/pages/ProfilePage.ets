/**
 * StudyFlow OS - 个人中心页
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { AuthStore } from '../services/AuthStore'
import { PlanStore } from '../services/PlanStore'
import { Theme } from '../common/Theme'

@Component
export struct ProfilePage {
  private authStore: AuthStore = AuthStore.getInstance()
  private planStore: PlanStore = PlanStore.getInstance()

  getTotalTasks(): number { return this.planStore.getTasks().length }
  getCompletedTasks(): number { return this.planStore.getTasksByStatus('completed').length }
  getTotalCards(): number { return this.planStore.getReviewCards().length }
  getMasteredCards(): number { return this.planStore.getReviewCards().filter(c => c.lastFeedbackStatus === 'mastered').length }

  handleLogout(): void {
    this.authStore.logout()
    promptAction.showToast({ message: '已退出登录', duration: 1500 })
    router.replaceUrl({ url: 'pages/LoginPage' })
  }

  build() {
    Column() {
      Text('我的')
        .fontSize(Theme.FONT_LG)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .width('100%').textAlign(TextAlign.Center)
        .padding({ top: Theme.SPACING_XL, bottom: Theme.SPACING_MD })

      Scroll() {
        Column() {
          // User card
          Column() {
            Text(this.authStore.getCurrentUser()?.username || '同学')
              .fontSize(Theme.FONT_XXL)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
            if (this.authStore.getCurrentUser()?.isGuest) {
              Text('游客模式')
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.TEXT_HINT)
                .margin({ top: Theme.SPACING_XS })
            }
            Row() {
              Text(`连续 ${this.authStore.getCurrentUser()?.streak || 0} 天`)
                .fontSize(Theme.FONT_SM).fontColor(Theme.WARNING)
              Text(`累计 ${this.authStore.getCurrentUser()?.totalStudyMinutes || 0} 分钟`)
                .fontSize(Theme.FONT_SM).fontColor(Theme.TEXT_SECONDARY)
                .margin({ left: Theme.SPACING_MD })
            }
            .margin({ top: Theme.SPACING_SM })
          }
          .width('100%').padding(Theme.SPACING_XXL)
          .backgroundColor(Theme.CARD_BG).borderRadius(Theme.RADIUS_LG)
          .border({ width: 1, color: Theme.BORDER })
          .alignItems(HorizontalAlign.Center)
          .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

          // Stats
          Column() {
            Text('学习数据')
              .fontSize(Theme.FONT_SM).fontColor(Theme.TEXT_HINT)
              .fontWeight(FontWeight.Medium).margin({ bottom: Theme.SPACING_MD })
            Row() {
              Column() {
                Text(this.getTotalTasks().toString())
                  .fontSize(Theme.FONT_XXL).fontColor(Theme.PRIMARY).fontWeight(FontWeight.Bold)
                Text('总任务').fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).margin({ top: 2 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              Column() {
                Text(this.getCompletedTasks().toString())
                  .fontSize(Theme.FONT_XXL).fontColor(Theme.SUCCESS).fontWeight(FontWeight.Bold)
                Text('已完成').fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).margin({ top: 2 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              Column() {
                Text(this.getMasteredCards().toString())
                  .fontSize(Theme.FONT_XXL).fontColor(Theme.PRIMARY).fontWeight(FontWeight.Bold)
                Text('已掌握').fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).margin({ top: 2 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }
            .width('100%')
          }
          .width('100%').padding(Theme.SPACING_LG)
          .backgroundColor(Theme.CARD_BG).borderRadius(Theme.RADIUS_LG)
          .border({ width: 1, color: Theme.BORDER })
          .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

          // Menu
          Column() {
            this.buildMenuItem('错题本', () => { router.pushUrl({ url: 'pages/WrongQuestionPage' }) })
            this.buildMenuItem('学习设置', () => { router.pushUrl({ url: 'pages/SettingsPage' }) })
            this.buildMenuItem('关于 StudyFlow', () => {
              promptAction.showToast({ message: 'StudyFlow — 期末复习卡片系统', duration: 2000 })
            })
          }
          .width('100%').padding(Theme.SPACING_LG)
          .backgroundColor(Theme.CARD_BG).borderRadius(Theme.RADIUS_LG)
          .border({ width: 1, color: Theme.BORDER })
          .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

          // Logout
          if (!this.authStore.getCurrentUser()?.isGuest) {
            Row() {
              Text('退出登录').fontSize(Theme.FONT_SM).fontColor(Theme.DANGER)
            }
            .width('100%').height(44).justifyContent(FlexAlign.Center)
            .border({ width: 1, color: Theme.BORDER }).borderRadius(Theme.RADIUS_MD)
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_XL })
            .onClick(() => { this.handleLogout() })
          }

          if (this.authStore.getCurrentUser()?.isGuest) {
            Row() {
              Text('登录/注册（完整功能）')
                .fontSize(Theme.FONT_SM).fontColor(Theme.TEXT_INVERSE).fontWeight(FontWeight.Medium)
            }
            .width('100%').height(44).justifyContent(FlexAlign.Center)
            .backgroundColor(Theme.PRIMARY).borderRadius(Theme.RADIUS_MD)
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
            .onClick(() => { router.replaceUrl({ url: 'pages/LoginPage' }) })
          }
        }
        .width('100%').padding({ bottom: 40 })
      }
      .scrollBar(BarState.Off).layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor(Theme.BG)
  }

  @Builder
  buildMenuItem(label: string, onClick: () => void) {
    Row() {
      Text(label).fontSize(Theme.FONT_MD).fontColor(Theme.TEXT_PRIMARY).layoutWeight(1)
      Image($r('sys.media.ohos_ic_public_arrow_right'))
        .width(20).height(20).fillColor(Theme.TEXT_HINT)
    }
    .width('100%').padding({ top: Theme.SPACING_MD, bottom: Theme.SPACING_MD })
    .onClick(onClick)
  }
}
