/**
 * StudyFlow OS - 登录页
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { AuthStore } from '../services/AuthStore'
import { StudyTheme } from '../common/StudyTheme'

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

  aboutToAppear(): void { if (this.authStore.getCurrentUser() === null) this.authStore.initMockData() }

  validate(): boolean {
    let valid = true
    this.usernameError = ''; this.passwordError = ''
    if (!this.username.trim()) { this.usernameError = '请输入用户名'; valid = false }
    if (!this.password || this.password.length < 6) { this.passwordError = '密码至少6位'; valid = false }
    this.showErrors = true; return valid
  }

  async handleLogin(): Promise<void> {
    if (!this.validate()) return
    this.isLoading = true
    const result = await this.authStore.login(this.username, this.password)
    this.isLoading = false
    if (result.success) { promptAction.showToast({ message: result.message, duration: 1500 }); router.replaceUrl({ url: 'pages/MainPage' }) }
    else promptAction.showToast({ message: result.message, duration: 2000 })
  }

  handleGuest(): void { this.authStore.loginAsGuest(); router.replaceUrl({ url: 'pages/MainPage' }) }

  build() {
    Column() {
      Column() {
        Text('StudyFlow').fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
        Text('期末复习，从一张卡片开始').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_SECONDARY).margin({ top: StudyTheme.SPACE_SM })
      }.alignItems(HorizontalAlign.Center).width('100%').padding({ top: 80, bottom: StudyTheme.SPACE_XXL })
      Scroll() {
        Column() {
          Column() {
            Text('用户名').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium).margin({ bottom: StudyTheme.SPACE_SM })
            TextInput({ text: this.username, placeholder: '请输入用户名' }).fontSize(StudyTheme.FONT_MD).backgroundColor(StudyTheme.BG).borderRadius(StudyTheme.RADIUS_MD).padding(StudyTheme.SPACE_MD).type(InputType.Normal).onChange((v: string) => { this.username = v })
            if (this.showErrors && this.usernameError) Text(this.usernameError).fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.DANGER).margin({ top: StudyTheme.SPACE_XS })
          }.width('100%').margin({ bottom: StudyTheme.SPACE_LG })
          Column() {
            Text('密码').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium).margin({ bottom: StudyTheme.SPACE_SM })
            TextInput({ text: this.password, placeholder: '请输入密码（至少6位）' }).fontSize(StudyTheme.FONT_MD).backgroundColor(StudyTheme.BG).borderRadius(StudyTheme.RADIUS_MD).padding(StudyTheme.SPACE_MD).type(InputType.Password).onChange((v: string) => { this.password = v })
            if (this.showErrors && this.passwordError) Text(this.passwordError).fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.DANGER).margin({ top: StudyTheme.SPACE_XS })
          }.width('100%')
          Row() { Text(this.isLoading ? '登录中...' : '登录').fontSize(StudyTheme.FONT_MD).fontColor('#FFFFFF').fontWeight(FontWeight.Medium) }
          .width('100%').height(48).justifyContent(FlexAlign.Center).backgroundColor(this.isLoading ? StudyTheme.TEXT_HINT : StudyTheme.ACCENT).borderRadius(StudyTheme.RADIUS_MD).margin({ top: StudyTheme.SPACE_XXL }).onClick(() => { this.handleLogin() })
          Row() {
            Text('还没有账号？').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_SECONDARY)
            Text('立即注册').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.ACCENT).fontWeight(FontWeight.Medium).margin({ left: StudyTheme.SPACE_XS })
          }.justifyContent(FlexAlign.Center).width('100%').margin({ top: StudyTheme.SPACE_LG }).onClick(() => { router.pushUrl({ url: 'pages/RegisterPage' }) })
          Row() {
            Divider().layoutWeight(1).color(StudyTheme.BORDER)
            Text('或').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ left: StudyTheme.SPACE_MD, right: StudyTheme.SPACE_MD })
            Divider().layoutWeight(1).color(StudyTheme.BORDER)
          }.width('100%').alignItems(VerticalAlign.Center).margin({ top: StudyTheme.SPACE_XL })
          Row() { Text('游客体验').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.ACCENT).fontWeight(FontWeight.Medium) }
          .width('100%').height(44).justifyContent(FlexAlign.Center).border({ width: 1, color: StudyTheme.ACCENT }).borderRadius(StudyTheme.RADIUS_MD).margin({ top: StudyTheme.SPACE_LG }).onClick(() => { this.handleGuest() })
          Text('你可以直接使用游客模式体验完整功能').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).textAlign(TextAlign.Center).width('100%').margin({ top: StudyTheme.SPACE_XL })
        }.width('100%').padding({ left: StudyTheme.SPACE_XXL, right: StudyTheme.SPACE_XXL, bottom: 40 })
      }.scrollBar(BarState.Off).layoutWeight(1)
    }.width('100%').height('100%').backgroundColor(StudyTheme.CARD_BG)
  }
}
