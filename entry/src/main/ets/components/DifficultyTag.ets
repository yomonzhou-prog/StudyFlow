/**
 * StudyFlow OS - 难度标签组件
 */

import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'

@Component
export struct DifficultyTag {
  @Prop difficulty: string = 'medium'

  build() {
    Text(Constants.DIFFICULTY_LABELS[this.difficulty] || this.difficulty)
      .fontSize(Theme.FONT_XS)
      .fontColor(this.getColor())
      .backgroundColor(this.getBgColor())
      .borderRadius(Theme.RADIUS_SM)
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
  }

  getColor(): string {
    switch (this.difficulty) {
      case 'hard': return Theme.DIFFICULTY_HARD_COLOR
      case 'medium': return Theme.DIFFICULTY_MEDIUM_COLOR
      case 'easy': return Theme.DIFFICULTY_EASY_COLOR
      default: return Theme.TEXT_SECONDARY
    }
  }

  getBgColor(): string {
    switch (this.difficulty) {
      case 'hard': return Theme.DANGER_BG
      case 'medium': return Theme.WARNING_BG
      case 'easy': return Theme.SUCCESS_BG
      default: return Theme.DIVIDER
    }
  }
}
