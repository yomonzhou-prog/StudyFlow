/**
 * StudyFlow OS - 状态提示横幅
 * 替代 MockBanner，简约低调显示当前数据模式
 */

import { Constants } from '../common/Constants'
import { StudyTheme } from '../common/StudyTheme'

@Component
export struct StatusBanner {
  @Prop mockMessage: string = '离线演示模式'
  @Prop apiMessage: string = '在线模式'
  @Prop showAlways: boolean = false

  build() {
    if (Constants.USE_MOCK || !Constants.DEEPSEEK_API_KEY) {
      Row() {
        Text(this.mockMessage)
          .fontSize(StudyTheme.FONT_XS)
          .fontColor(StudyTheme.TEXT_HINT)
      }
      .width('100%')
      .padding({ top: StudyTheme.SPACE_SM, bottom: StudyTheme.SPACE_SM })
      .justifyContent(FlexAlign.Center)
    } else if (this.showAlways) {
      Row() {
        Text(this.apiMessage)
          .fontSize(StudyTheme.FONT_XS)
          .fontColor(StudyTheme.TEXT_HINT)
      }
      .width('100%')
      .padding({ top: StudyTheme.SPACE_SM, bottom: StudyTheme.SPACE_SM })
      .justifyContent(FlexAlign.Center)
    }
  }
}
