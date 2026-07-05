/**
 * StudyFlow OS - 统一加载视图组件
 * 消除5个页面中重复的 LoadingProgress + 提示文字
 */

import { Theme } from '../common/Theme'

@Component
export struct LoadingView {
  @Prop message: string = '加载中...'

  build() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color(Theme.PRIMARY)

      Text(this.message)
        .fontSize(Theme.FONT_MD)
        .fontColor(Theme.TEXT_HINT)
        .margin({ top: Theme.SPACING_MD })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
