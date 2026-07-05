/**
 * StudyFlow OS - 知识点卡片组件
 */

import { KnowledgePoint } from '../models/KnowledgePoint'
import { Theme } from '../common/Theme'
import { DifficultyTag } from './DifficultyTag'
import { ImportanceTag } from './ImportanceTag'

@Component
export struct KnowledgePointCard {
  @Prop knowledgePoint: KnowledgePoint
  onCardClick?: () => void

  build() {
    Column() {
      // 标题行
      Row() {
        Text(this.knowledgePoint.title)
          .fontSize(Theme.FONT_MD)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        ImportanceTag({ importance: this.knowledgePoint.importance })
      }
      .width('100%')

      // 章节
      Text(this.knowledgePoint.chapter)
        .fontSize(Theme.FONT_XS)
        .fontColor(Theme.PRIMARY_LIGHT)
        .margin({ top: Theme.SPACING_XS, bottom: Theme.SPACING_SM })

      // 解释
      Text(this.knowledgePoint.explanation)
        .fontSize(Theme.FONT_SM)
        .fontColor(Theme.TEXT_SECONDARY)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(20)

      // 标签行
      Row() {
        DifficultyTag({ difficulty: this.knowledgePoint.difficulty })

        if (this.knowledgePoint.commonMistakes.length > 0) {
          Text(`⚠ ${this.knowledgePoint.commonMistakes[0]}`)
            .fontSize(Theme.FONT_XS)
            .fontColor(Theme.WARNING)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ left: Theme.SPACING_SM })
        }
      }
      .width('100%')
      .margin({ top: Theme.SPACING_SM })
    }
    .width('100%')
    .padding(Theme.SPACING_MD)
    .backgroundColor(Theme.CARD_BG)
    .borderRadius(Theme.RADIUS_MD)
    .margin({ bottom: Theme.SPACING_SM })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick()
      }
    })
  }
}
