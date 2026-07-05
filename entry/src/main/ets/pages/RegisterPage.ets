/**
 * StudyFlow OS - 注册页
 * 支持 Mock 注册
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { AuthStore } from '../services/AuthStore'
import { Theme } from '../common/Theme'
import { PrimaryButton } from '../components/AppButton'
import { PageHeader } from '../components/PageHeader'

@Entry
@Component
struct RegisterPage {
  @State username: string = ''
  @State email: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State isLoading: boolean = false
  @State showErrors: boolean = false
  @State usernameError: string = ''
  @State passwordError: string = ''
  @State confirmError: string = ''

  private authStore: AuthStore = AuthStore.getInstance()

  validate(): boolean {
    let valid = true
    this.usernameError = ''
    this.passwordError = ''
    this.confirmError = ''

    if (!this.username.trim() || this.username.trim().length < 2) {
      this.usernameError = '用户名至少2个字符'
      valid = false
    }
    if (!this.password || this.password.length < 6) {
      this.passwordError = '密码至少6位'
      valid = false
    }
    if (this.password !== this.confirmPassword) {
      this.confirmError = '两次输入的密码不一致'
      valid = false
    }

    this.showErrors = true
    return valid
  }

  async handleRegister(): Promise<void> {
    if (!this.validate()) {
      return
    }

    this.isLoading = true

    const result = await this.authStore.register(this.username, this.email, this.password)

    this.isLoading = false

    if (result.success) {
      promptAction.showToast({ message: result.message, duration: 1500 })
      router.replaceUrl({ url: 'pages/MainPage' })
    } else {
      promptAction.showToast({ message: result.message, duration: 2000 })
    }
  }

  build() {
    Column() {
      PageHeader({ title: '注册新账号' })

      Scroll() {
        Column() {
          // Username
          Column() {
            Text('用户名 *')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: Theme.SPACING_SM })

            TextInput({ text: this.username, placeholder: '请输入用户名（至少2位）' })
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

          // Email
          Column() {
            Text('邮箱（选填）')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: Theme.SPACING_SM })

            TextInput({ text: this.email, placeholder: '请输入邮箱地址' })
              .fontSize(Theme.FONT_MD)
              .backgroundColor(Theme.BG)
              .borderRadius(Theme.RADIUS_MD)
              .padding(Theme.SPACING_MD)
              .type(InputType.Email)
              .onChange((value: string) => { this.email = value })
          }
          .width('100%')
          .margin({ bottom: Theme.SPACING_LG })

          // Password
          Column() {
            Text('密码 *')
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
          .margin({ bottom: Theme.SPACING_LG })

          // Confirm Password
          Column() {
            Text('确认密码 *')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: Theme.SPACING_SM })

            TextInput({ text: this.confirmPassword, placeholder: '请再次输入密码' })
              .fontSize(Theme.FONT_MD)
              .backgroundColor(Theme.BG)
              .borderRadius(Theme.RADIUS_MD)
              .padding(Theme.SPACING_MD)
              .type(InputType.Password)
              .onChange((value: string) => { this.confirmPassword = value })

            if (this.showErrors && this.confirmError) {
              Text(this.confirmError)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.DANGER)
                .margin({ top: Theme.SPACING_XS })
            }
          }
          .width('100%')

          // Register button
          PrimaryButton({
            label: this.isLoading ? '注册中...' : '注册',
            isEnabled: !this.isLoading,
            onAction: () => { this.handleRegister() }
          })
            .margin({ top: Theme.SPACING_XXL })

          // Back to login
          Row() {
            Text('已有账号？')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_SECONDARY)
            Text('返回登录')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ left: Theme.SPACING_XS })
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .margin({ top: Theme.SPACING_LG })
          .onClick(() => { router.back() })
        }
        .width('100%')
        .padding({ left: Theme.SPACING_XXL, right: Theme.SPACING_XXL, bottom: 40 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }
}
