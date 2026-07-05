/**
 * StudyFlow OS - 空状态组件
 */

import { Theme } from '../common/Theme'

@Component
export struct EmptyState {
  @Prop icon: string = '📭'
  @Prop message: string = '暂无数据'

  build() {
    Column() {
      Text(this.icon)
        .fontSize(48)
        .margin({ bottom: Theme.SPACING_MD })

      Text(this.message)
        .fontSize(Theme.FONT_MD)
        .fontColor(Theme.TEXT_HINT)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
