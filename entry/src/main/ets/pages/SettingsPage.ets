/**
 * StudyFlow OS - 设置页
 * 学习目标、复习数量、提醒时间等偏好设置
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { SettingsStore } from '../services/SettingsStore'
import { StudySettings } from '../models/StudySettings'
import { Theme } from '../common/Theme'
import { PageHeader } from '../components/PageHeader'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'
import { SectionHeader } from '../components/SectionHeader'

@Entry
@Component
struct SettingsPage {
  @State settings: StudySettings | null = null
  @State dailyGoalText: string = ''
  @State dailyNewCardsText: string = ''
  @State dailyReviewCardsText: string = ''
  @State reminderTimeText: string = ''

  private settingsStore: SettingsStore = SettingsStore.getInstance()

  aboutToAppear(): void {
    this.settings = this.settingsStore.getSettings()
    this.dailyGoalText = this.settings.dailyStudyGoal.toString()
    this.dailyNewCardsText = this.settings.dailyNewCards.toString()
    this.dailyReviewCardsText = this.settings.dailyReviewCards.toString()
    this.reminderTimeText = this.settings.reminderTime
  }

  handleSave(): void {
    if (!this.settings) return

    const goalMinutes = parseInt(this.dailyGoalText)
    const newCards = parseInt(this.dailyNewCardsText)
    const reviewCards = parseInt(this.dailyReviewCardsText)

    if (isNaN(goalMinutes) || goalMinutes < 5 || goalMinutes > 480) {
      promptAction.showToast({ message: '每日目标5-480分钟', duration: 2000 })
      return
    }
    if (isNaN(newCards) || newCards < 1 || newCards > 100) {
      promptAction.showToast({ message: '新卡片数1-100', duration: 2000 })
      return
    }
    if (isNaN(reviewCards) || reviewCards < 1 || reviewCards > 200) {
      promptAction.showToast({ message: '复习卡片数1-200', duration: 2000 })
      return
    }

    this.settingsStore.updateSettings({
      dailyStudyGoal: goalMinutes,
      dailyNewCards: newCards,
      dailyReviewCards: reviewCards,
      reminderTime: this.reminderTimeText
    })

    promptAction.showToast({ message: '设置已保存', duration: 1500 })
  }

  handleReset(): void {
    this.settingsStore.resetDefaults()
    this.settings = this.settingsStore.getSettings()
    this.dailyGoalText = this.settings.dailyStudyGoal.toString()
    this.dailyNewCardsText = this.settings.dailyNewCards.toString()
    this.dailyReviewCardsText = this.settings.dailyReviewCards.toString()
    this.reminderTimeText = this.settings.reminderTime
    promptAction.showToast({ message: '已恢复默认设置', duration: 1500 })
  }

  build() {
    Column() {
      PageHeader({ title: '学习设置' })

      if (!this.settings) {
        Column() {
          LoadingProgress().width(36).height(36).color(Theme.PRIMARY)
        }
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .width('100%')
      } else {
        Scroll() {
          Column() {
            // 学习目标
            Column() {
              SectionHeader({ title: '📊 学习目标', actionLabel: '' })
              this.buildSettingItem('每日学习时长（分钟）', this.dailyGoalText,
                (value: string) => { this.dailyGoalText = value })
            }
            .width('100%')
            .padding(Theme.SPACING_LG)
            .backgroundColor(Theme.CARD_BG)
            .borderRadius(Theme.RADIUS_LG)
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

            // 复习设置
            Column() {
              SectionHeader({ title: '🃏 复习计划', actionLabel: '' })
              this.buildSettingItem('每日新卡片数', this.dailyNewCardsText,
                (value: string) => { this.dailyNewCardsText = value })
              this.buildSettingItem('每日复习卡片数', this.dailyReviewCardsText,
                (value: string) => { this.dailyReviewCardsText = value })
            }
            .width('100%')
            .padding(Theme.SPACING_LG)
            .backgroundColor(Theme.CARD_BG)
            .borderRadius(Theme.RADIUS_LG)
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

            // 提醒设置
            Column() {
              SectionHeader({ title: '⏰ 学习提醒', actionLabel: '' })
              this.buildSettingItem('提醒时间（HH:mm）', this.reminderTimeText,
                (value: string) => { this.reminderTimeText = value })

              Row() {
                Text('开启提醒')
                  .fontSize(Theme.FONT_MD)
                  .fontColor(Theme.TEXT_PRIMARY)
                  .layoutWeight(1)
                Toggle({ type: ToggleType.Switch, isOn: this.settings!.reminderEnabled })
                  .onChange((isOn: boolean) => {
                    this.settingsStore.updateSettings({ reminderEnabled: isOn })
                    this.settings = this.settingsStore.getSettings()
                  })
              }
              .width('100%')
              .margin({ top: Theme.SPACING_MD })
            }
            .width('100%')
            .padding(Theme.SPACING_LG)
            .backgroundColor(Theme.CARD_BG)
            .borderRadius(Theme.RADIUS_LG)
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

            // 保存/重置
            Column() {
              PrimaryButton({
                label: '💾 保存设置',
                onAction: () => { this.handleSave() }
              })
              SecondaryButton({
                label: '🔄 恢复默认',
                onAction: () => { this.handleReset() }
              })
              .margin({ top: Theme.SPACING_MD })
            }
            .width('100%')
            .padding(Theme.SPACING_LG)
            .margin({ top: Theme.SPACING_MD })
          }
          .width('100%')
          .padding({ bottom: 40 })
        }
        .scrollBar(BarState.Off)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  buildSettingItem(label: string, value: string, onChange: (value: string) => void) {
    Row() {
      Text(label)
        .fontSize(Theme.FONT_MD)
        .fontColor(Theme.TEXT_PRIMARY)
        .layoutWeight(1)
      TextInput({ text: value, placeholder: '' })
        .fontSize(Theme.FONT_MD)
        .textAlign(TextAlign.End)
        .backgroundColor(Theme.BG)
        .borderRadius(Theme.RADIUS_SM)
        .padding({ left: Theme.SPACING_MD, right: Theme.SPACING_MD })
        .width(100)
        .onChange(onChange)
    }
    .width('100%')
    .padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
  }
}
