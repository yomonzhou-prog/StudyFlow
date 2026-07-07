/**
 * StudyFlow OS - Chip 选择器组件
 * 横向可滚动的 Chip 标签选择器
 * 替换 CourseInputPage 和 KnowledgeMapPage 中的重复实现
 */

import { Theme } from '../common/Theme'

export interface ChipOption {
  value: string
  label: string
  count?: number
}

@Component
export struct ChipSelector {
  @Prop options: ChipOption[] = []
  @Prop selectedValue: string = ''
  onSelect?: (value: string) => void

  build() {
    Scroll() {
      Row() {
        ForEach(this.options, (option: ChipOption) => {
          Text(option.count !== undefined ? `${option.label} (${option.count})` : option.label)
            .fontSize(Theme.FONT_SM)
            .fontColor(this.selectedValue === option.value ? Theme.TEXT_INVERSE : Theme.TEXT_SECONDARY)
            .backgroundColor(this.selectedValue === option.value ? Theme.PRIMARY : Theme.BG)
            .borderRadius(Theme.RADIUS_XL)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
            .margin({ right: Theme.SPACING_SM })
            .onClick(() => {
              if (this.onSelect) {
                this.onSelect(option.value)
              }
            })
        })
      }
    }
    .scrollBar(BarState.Off)
    .scrollable(ScrollDirection.Horizontal)
  }
}
