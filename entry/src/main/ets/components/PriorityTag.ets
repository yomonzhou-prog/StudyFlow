/**
 * StudyFlow OS - 优先级标签组件
 */

import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'

@Component
export struct PriorityTag {
  @Prop priority: string = 'medium'

  build() {
    Text(Constants.PRIORITY_LABELS[this.priority] || this.priority)
      .fontSize(Theme.FONT_XS)
      .fontColor(this.getColor())
      .backgroundColor(this.getBgColor())
      .borderRadius(Theme.RADIUS_SM)
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
  }

  getColor(): string {
    switch (this.priority) {
      case 'high': return Theme.TEXT_INVERSE
      case 'medium': return '#B8956A'
      case 'low': return Theme.TEXT_SECONDARY
      default: return Theme.TEXT_SECONDARY
    }
  }

  getBgColor(): string {
    switch (this.priority) {
      case 'high': return Theme.PRIORITY_HIGH_COLOR
      case 'medium': return Theme.WARNING_BG
      case 'low': return Theme.DIVIDER
      default: return Theme.DIVIDER
    }
  }
}
