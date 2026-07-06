/**
 * StudyFlow OS - 状态提示横幅
 */

import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'

@Component
export struct MockBanner {
  @Prop mockMessage: string = '离线演示模式'
  @Prop apiMessage: string = ''
  build() {
    if (Constants.USE_MOCK || !Constants.DEEPSEEK_API_KEY) {
      Row() {
        Text(this.mockMessage).fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT)
      }.width('100%').padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM }).justifyContent(FlexAlign.Center)
    }
  }
}
