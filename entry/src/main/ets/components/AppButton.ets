/**
 * StudyFlow OS - 主按钮组件
 * 消除全项目 10+ 处重复的主按钮样式链
 */

import { Theme } from '../common/Theme'

@Component
export struct PrimaryButton {
  @Prop label: string = ''
  @Prop isEnabled: boolean = true
  @Prop fullWidth: boolean = true
  onAction?: () => void

  build() {
    Button(this.label)
      .fontSize(Theme.FONT_MD)
      .fontColor(Theme.TEXT_INVERSE)
      .backgroundColor(this.isEnabled ? Theme.PRIMARY : Theme.TEXT_HINT)
      .borderRadius(Theme.RADIUS_LG)
      .height(48)
      .width(this.fullWidth ? '100%' : undefined)
      .enabled(this.isEnabled)
      .onClick(() => {
        if (this.onAction) {
          this.onAction()
        }
      })
  }
}

/**
 * StudyFlow OS - 次按钮组件
 * 消除全项目 6+ 处重复的次按钮样式链
 */
@Component
export struct SecondaryButton {
  @Prop label: string = ''
  @Prop isEnabled: boolean = true
  @Prop fullWidth: boolean = true
  onAction?: () => void

  build() {
    Button(this.label)
      .fontSize(Theme.FONT_MD)
      .fontColor(Theme.PRIMARY)
      .backgroundColor(Theme.PRIMARY_BG)
      .borderRadius(Theme.RADIUS_LG)
      .height(48)
      .width(this.fullWidth ? '100%' : undefined)
      .enabled(this.isEnabled)
      .onClick(() => {
        if (this.onAction) {
          this.onAction()
        }
      })
  }
}
