/**
 * StudyFlow OS - 重要程度标签组件
 */

import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'

@Component
export struct ImportanceTag {
  @Prop importance: string = 'medium'

  build() {
    Text(Constants.IMPORTANCE_LABELS[this.importance] || this.importance)
      .fontSize(Theme.FONT_XS)
      .fontColor(this.getColor())
      .backgroundColor(this.getBgColor())
      .borderRadius(Theme.RADIUS_SM)
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
  }

  getColor(): string {
    switch (this.importance) {
      case 'critical': return '#FFFFFF'
      case 'high': return Theme.IMPORTANCE_HIGH_COLOR
      case 'medium': return Theme.IMPORTANCE_MEDIUM_COLOR
      case 'low': return Theme.IMPORTANCE_LOW_COLOR
      default: return Theme.TEXT_SECONDARY
    }
  }

  getBgColor(): string {
    switch (this.importance) {
      case 'critical': return Theme.IMPORTANCE_CRITICAL_COLOR
      case 'high': return Theme.DANGER_BG
      case 'medium': return Theme.WARNING_BG
      case 'low': return Theme.DIVIDER
      default: return Theme.DIVIDER
    }
  }
}
