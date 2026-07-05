/**
 * StudyFlow OS - 学习任务卡片组件
 */

import { StudyTask } from '../models/StudyTask'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { DateUtils } from '../utils/DateUtils'
import { PriorityTag } from './PriorityTag'

@Component
export struct StudyTaskCard {
  @Prop task: StudyTask
  @State isChecked: boolean = false
  onToggle?: (taskId: string) => void
  onCardClick?: () => void

  aboutToAppear(): void {
    this.isChecked = this.task.status === 'completed'
  }

  build() {
    Row() {
      // 原生 Toggle Checkbox 替代 emoji 文本
      Toggle({ type: ToggleType.Checkbox, isOn: this.isChecked })
        .selectedColor(Theme.PRIMARY)
        .margin({ right: Theme.SPACING_MD })
        .onChange((isOn: boolean) => {
          this.isChecked = isOn
          if (this.onToggle) {
            this.onToggle(this.task.id)
          }
        })

      Column() {
        // 标题行
        Row() {
          Text(this.task.title)
            .fontSize(Theme.FONT_MD)
            .fontColor(this.task.status === 'completed' ? Theme.TEXT_HINT : Theme.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .decoration({ type: this.task.status === 'completed' ? TextDecorationType.LineThrough : TextDecorationType.None })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          PriorityTag({ priority: this.task.priority })
        }
        .width('100%')

        // 信息行
        Row() {
          Text(this.task.courseName)
            .fontSize(Theme.FONT_XS)
            .fontColor(Theme.TEXT_HINT)

          Text(' · ')
            .fontSize(Theme.FONT_XS)
            .fontColor(Theme.TEXT_HINT)

          Text(`⏱ ${this.task.estimatedMinutes}分钟`)
            .fontSize(Theme.FONT_XS)
            .fontColor(Theme.TEXT_HINT)

          Text(' · ')
            .fontSize(Theme.FONT_XS)
            .fontColor(Theme.TEXT_HINT)

          Text(`📅 ${DateUtils.formatDate(this.task.deadline)}截止`)
            .fontSize(Theme.FONT_XS)
            .fontColor(this.getDeadlineColor())
        }
        .width('100%')
        .margin({ top: Theme.SPACING_XS })
      }
      .layoutWeight(1)
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

  getDeadlineColor(): string {
    if (DateUtils.isOverdue(this.task.deadline)) return Theme.DANGER
    if (DateUtils.isToday(this.task.deadline)) return Theme.WARNING
    return Theme.TEXT_HINT
  }
}
