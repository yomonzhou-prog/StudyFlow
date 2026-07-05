/**
 * StudyFlow OS - 登录页
 * 支持 Mock 登录、注册跳转、游客模式
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { AuthStore } from '../services/AuthStore'
import { Theme } from '../common/Theme'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'

@Entry
@Component
struct LoginPage {
  @State username: string = ''
  @State password: string = ''
  @State isLoading: boolean = false
  @State showErrors: boolean = false
  @State usernameError: string = ''
  @State passwordError: string = ''

  private authStore: AuthStore = AuthStore.getInstance()

  aboutToAppear(): void {
    if (this.authStore.getCurrentUser() === null) {
      this.authStore.initMockData()
    }
  }

  validate(): boolean {
    let valid = true
    this.usernameError = ''
    this.passwordError = ''

    if (!this.username.trim()) {
      this.usernameError = '请输入用户名'
      valid = false
    }
    if (!this.password || this.password.length < 6) {
      this.passwordError = '密码至少6位'
      valid = false
    }

    this.showErrors = true
    return valid
  }

  async handleLogin(): Promise<void> {
    if (!this.validate()) {
      return
    }

    this.isLoading = true

    const result = await this.authStore.login(this.username, this.password)

    this.isLoading = false

    if (result.success) {
      promptAction.showToast({ message: result.message, duration: 1500 })
      router.replaceUrl({ url: 'pages/MainPage' })
    } else {
      promptAction.showToast({ message: result.message, duration: 2000 })
    }
  }

  handleGuest(): void {
    this.authStore.loginAsGuest()
    promptAction.showToast({ message: '已进入游客模式', duration: 1500 })
    router.replaceUrl({ url: 'pages/MainPage' })
  }

  build() {
    Column() {
      // Top area
      Column() {
        Text('📚')
          .fontSize(56)
          .margin({ bottom: Theme.SPACING_MD })

        Text('StudyFlow OS')
          .fontSize(Theme.FONT_XXL)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)

        Text('学习任务操作系统')
          .fontSize(Theme.FONT_SM)
          .fontColor(Theme.TEXT_SECONDARY)
          .margin({ top: Theme.SPACING_XS })
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .padding({ top: 60, bottom: Theme.SPACING_XXL })

      // Form area
      Scroll() {
        Column() {
          // Username
          Column() {
            Text('用户名')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: Theme.SPACING_SM })

            TextInput({ text: this.username, placeholder: '请输入用户名（任意名称即可）' })
              .fontSize(Theme.FONT_MD)
              .backgroundColor(Theme.BG)
              .borderRadius(Theme.RADIUS_MD)
              .padding(Theme.SPACING_MD)
              .type(InputType.Normal)
              .onChange((value: string) => { this.username = value })

            if (this.showErrors && this.usernameError) {
              Text(this.usernameError)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.DANGER)
                .margin({ top: Theme.SPACING_XS })
            }
          }
          .width('100%')
          .margin({ bottom: Theme.SPACING_LG })

          // Password
          Column() {
            Text('密码')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: Theme.SPACING_SM })

            TextInput({ text: this.password, placeholder: '请输入密码（至少6位）' })
              .fontSize(Theme.FONT_MD)
              .backgroundColor(Theme.BG)
              .borderRadius(Theme.RADIUS_MD)
              .padding(Theme.SPACING_MD)
              .type(InputType.Password)
              .onChange((value: string) => { this.password = value })

            if (this.showErrors && this.passwordError) {
              Text(this.passwordError)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.DANGER)
                .margin({ top: Theme.SPACING_XS })
            }
          }
          .width('100%')

          // Login button
          PrimaryButton({
            label: this.isLoading ? '登录中...' : '登录',
            isEnabled: !this.isLoading,
            onAction: () => { this.handleLogin() }
          })
            .margin({ top: Theme.SPACING_XXL })

          // Register link
          Row() {
            Text('还没有账号？')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_SECONDARY)
            Text('立即注册')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ left: Theme.SPACING_XS })
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACING_LG })
          .onClick(() => { router.pushUrl({ url: 'pages/RegisterPage' }) })

          // Divider
          Row() {
            Divider().layoutWeight(1).color(Theme.BORDER)
            Text('或').fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).margin({ left: Theme.SPACING_MD, right: Theme.SPACING_MD })
            Divider().layoutWeight(1).color(Theme.BORDER)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .margin({ top: Theme.SPACING_XL })

          // Guest mode
          SecondaryButton({
            label: '🎒 游客体验',
            onAction: () => { this.handleGuest() }
          })
            .margin({ top: Theme.SPACING_LG })

          // Hint
          Text('💡 提示：输入任意用户名和6位以上密码即可登录（Mock模式）')
            .fontSize(Theme.FONT_XS)
            .fontColor(Theme.TEXT_HINT)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: Theme.SPACING_XL })
        }
        .width('100%')
        .padding({ left: Theme.SPACING_XXL, right: Theme.SPACING_XXL, bottom: 40 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.CARD_BG)
  }
}
