/**
 * StudyFlow OS - Mock 模式提示横幅组件
 * 消除3个页面中重复的 Mock/API 状态横幅
 */

import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'

@Component
export struct MockBanner {
  @Prop mockMessage: string = 'Mock 模式运行中 — 使用示例数据演示'
  @Prop apiMessage: string = 'DeepSeek AI 驱动 — 学习任务操作系统运行中'

  build() {
    Row() {
      if (Constants.USE_MOCK || !Constants.DEEPSEEK_API_KEY) {
        Text(`🔶 ${this.mockMessage}`)
          .fontSize(Theme.FONT_XS)
          .fontColor(Theme.WARNING)
      } else {
        Text(`🟢 ${this.apiMessage}`)
          .fontSize(Theme.FONT_XS)
          .fontColor(Theme.SUCCESS)
      }
    }
    .width('100%')
    .padding(Theme.SPACING_SM)
    .backgroundColor(Constants.USE_MOCK || !Constants.DEEPSEEK_API_KEY ? Theme.WARNING_BG : Theme.SUCCESS_BG)
    .justifyContent(FlexAlign.Center)
  }
}
