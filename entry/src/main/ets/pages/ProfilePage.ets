/**
 * StudyFlow OS - 个人中心页
 * 展示用户信息、学习统计、快捷入口
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { AuthStore } from '../services/AuthStore'
import { PlanStore } from '../services/PlanStore'
import { Theme } from '../common/Theme'
import { PageHeader } from '../components/PageHeader'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'
import { SectionHeader } from '../components/SectionHeader'

@Component
export struct ProfilePage {
  private authStore: AuthStore = AuthStore.getInstance()
  private planStore: PlanStore = PlanStore.getInstance()

  getTotalTasks(): number {
    return this.planStore.getTasks().length
  }
  getCompletedTasks(): number {
    return this.planStore.getTasksByStatus('completed').length
  }
  getTotalCards(): number {
    return this.planStore.getReviewCards().length
  }
  getMasteredCards(): number {
    return this.planStore.getReviewCards().filter(c => c.lastFeedbackStatus === 'mastered').length
  }

  handleLogout(): void {
    this.authStore.logout()
    promptAction.showToast({ message: '已退出登录', duration: 1500 })
    router.replaceUrl({ url: 'pages/LoginPage' })
  }

  build() {
    Column() {
      PageHeader({ title: '我的' })

      Scroll() {
        Column() {
          // 用户信息卡片
          Column() {
            Text(this.authStore.getCurrentUser()?.avatar || '📚')
              .fontSize(56)
              .margin({ bottom: Theme.SPACING_MD })
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
              Text(`🔥 连续 ${this.authStore.getCurrentUser()?.streak || 0} 天`)
                .fontSize(Theme.FONT_SM)
                .fontColor(Theme.WARNING)
              Text(`⏱️ 累计 ${this.authStore.getCurrentUser()?.totalStudyMinutes || 0} 分钟`)
                .fontSize(Theme.FONT_SM)
                .fontColor(Theme.TEXT_SECONDARY)
                .margin({ left: Theme.SPACING_MD })
            }
            .margin({ top: Theme.SPACING_SM })
          }
          .width('100%')
          .padding(Theme.SPACING_XXL)
          .backgroundColor(Theme.CARD_BG)
          .borderRadius(Theme.RADIUS_LG)
          .alignItems(HorizontalAlign.Center)
          .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

          // 学习数据统计
          Column() {
            SectionHeader({ title: '📊 学习数据', actionLabel: '' })

            Row() {
              Column() {
                Text(this.getTotalTasks().toString())
                  .fontSize(Theme.FONT_XXL)
                  .fontColor(Theme.PRIMARY)
                  .fontWeight(FontWeight.Bold)
                Text('总任务').fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).margin({ top: 2 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Column() {
                Text(this.getCompletedTasks().toString())
                  .fontSize(Theme.FONT_XXL)
                  .fontColor(Theme.SUCCESS)
                  .fontWeight(FontWeight.Bold)
                Text('已完成').fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).margin({ top: 2 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)

              Column() {
                Text(this.getMasteredCards().toString())
                  .fontSize(Theme.FONT_XXL)
                  .fontColor(Theme.PRIMARY)
                  .fontWeight(FontWeight.Bold)
                Text('已掌握').fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).margin({ top: 2 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.SPACING_LG)
          .backgroundColor(Theme.CARD_BG)
          .borderRadius(Theme.RADIUS_LG)
          .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

          // 快捷入口
          Column() {
            SectionHeader({ title: '⚙️ 功能', actionLabel: '' })

            this.buildMenuItem('📝', '错题本', () => {
              router.pushUrl({ url: 'pages/WrongQuestionPage' })
            })
            this.buildMenuItem('⚙️', '学习设置', () => {
              router.pushUrl({ url: 'pages/SettingsPage' })
            })
            this.buildMenuItem('❓', '关于 StudyFlow', () => {
              promptAction.showToast({ message: 'StudyFlow OS v1.0 — 学习任务操作系统', duration: 2000 })
            })
          }
          .width('100%')
          .padding(Theme.SPACING_LG)
          .backgroundColor(Theme.CARD_BG)
          .borderRadius(Theme.RADIUS_LG)
          .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

          // 退出登录
          if (!this.authStore.getCurrentUser()?.isGuest) {
            SecondaryButton({
              label: '退出登录',
              onAction: () => { this.handleLogout() }
            })
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_XL })
          }

          PrimaryButton({
            label: '🎒 登录/注册（完整功能）',
            onAction: () => { router.replaceUrl({ url: 'pages/LoginPage' }) }
          })
          .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
        }
        .width('100%')
        .padding({ bottom: 40 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  buildMenuItem(icon: string, label: string, onClick: () => void) {
    Row() {
      Text(icon).fontSize(18)
      Text(label).fontSize(Theme.FONT_MD).fontColor(Theme.TEXT_PRIMARY).layoutWeight(1).margin({ left: Theme.SPACING_SM })
      Image($r('sys.media.ohos_ic_public_arrow_right')).width(20).height(20).fillColor(Theme.TEXT_HINT)
    }
    .width('100%')
    .padding({ top: Theme.SPACING_MD, bottom: Theme.SPACING_MD })
    .onClick(onClick)
  }
}
