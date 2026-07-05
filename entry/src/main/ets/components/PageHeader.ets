/**
 * StudyFlow OS - 页面头部组件
 * 统一的导航头部，消除6个页面中的重复代码
 */

import { router } from '@kit.ArkUI'
import { Theme } from '../common/Theme'

@Component
export struct PageHeader {
  @Prop title: string = ''
  @BuilderParam rightContent?: () => void

  build() {
    Row() {
      Image($r('sys.media.ohos_ic_public_arrow_left'))
        .width(24)
        .height(24)
        .fillColor(Theme.TEXT_PRIMARY)
        .onClick(() => { router.back() })

      Text(this.title)
        .fontSize(Theme.FONT_XL)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .margin({ left: Theme.SPACING_MD })

      Blank()

      if (this.rightContent) {
        this.rightContent()
      }
    }
    .width('100%')
    .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_XL, bottom: Theme.SPACING_MD })
    .backgroundColor(Theme.CARD_BG)
  }
}
