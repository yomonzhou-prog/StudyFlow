/**
 * StudyFlow OS - 区块标题组件
 */

import { Theme } from '../common/Theme'

@Component
export struct SectionHeader {
  @Prop title: string = ''
  @Prop actionLabel: string = ''
  onAction?: () => void

  build() {
    Row() {
      Text(this.title)
        .fontSize(Theme.FONT_LG)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)

      Blank()

      if (this.actionLabel) {
        Text(this.actionLabel)
          .fontSize(Theme.FONT_SM)
          .fontColor(Theme.PRIMARY_LIGHT)
          .onClick(() => {
            if (this.onAction) {
              this.onAction()
            }
          })
      }
    }
    .width('100%')
    .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD, bottom: Theme.SPACING_SM })
  }
}
