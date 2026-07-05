/**
 * StudyFlow OS - 区块卡片包装组件
 * 统一 SectionHeader + 内容的卡片式布局，消除 CourseAnalysisPage 中 6 处重复
 */

import { Theme } from '../common/Theme'

@Component
export struct SectionCard {
  @BuilderParam header?: () => void
  @BuilderParam content: () => void

  build() {
    Column() {
      if (this.header) {
        this.header()
      }

      Column() {
        this.content()
      }
      .width('100%')
      .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
    }
    .width('100%')
    .backgroundColor(Theme.CARD_BG)
    .borderRadius(Theme.RADIUS_MD)
    .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }
}
