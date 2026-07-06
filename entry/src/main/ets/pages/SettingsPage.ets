/**
 * StudyFlow OS - 设置页
 * 学习偏好设置 + AI 状态检测
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { SettingsStore } from '../services/SettingsStore'
import { DeepSeekClient } from '../services/DeepSeekClient'
import { Constants } from '../common/Constants'
import { StudyTheme } from '../common/StudyTheme'

@Entry
@Component
struct SettingsPage {
  @State dailyGoal: string = '60'
  @State newCards: string = '10'
  @State reviewCards: string = '20'
  @State reminderTime: string = '09:00'
  @State reminderEnabled: boolean = true
  @State aiStatusLabel: string = ''
  @State aiStatusDetail: string = ''
  @State isTestingAI: boolean = false

  private settingsStore: SettingsStore = SettingsStore.getInstance()
  private deepSeekClient: DeepSeekClient = DeepSeekClient.getInstance()

  aboutToAppear(): void {
    const s = this.settingsStore.getSettings()
    this.dailyGoal = s.dailyStudyGoal.toString()
    this.newCards = s.dailyNewCards.toString()
    this.reviewCards = s.dailyReviewCards.toString()
    this.reminderTime = s.reminderTime
    this.reminderEnabled = s.reminderEnabled
    this.checkAIStatus()
  }

  checkAIStatus(): void {
    if (Constants.USE_MOCK) {
      this.aiStatusLabel = 'Mock 模式'
      this.aiStatusDetail = '当前使用本地演示数据，非真实 AI 响应'
    } else if (!Constants.DEEPSEEK_API_KEY) {
      this.aiStatusLabel = 'API Key 未配置'
      this.aiStatusDetail = '请在 Constants.ets 中配置 DEEPSEEK_API_KEY'
    } else {
      this.aiStatusLabel = '在线模式'
      this.aiStatusDetail = 'DeepSeek API 已配置，正常连接中'
    }
  }

  async handleTestAI(): Promise<void> {
    this.isTestingAI = true
    this.aiStatusLabel = '测试中...'
    this.aiStatusDetail = '正在发送测试请求...'

    const response = await this.deepSeekClient.chat(
      '回复一个简短的确认消息。',
      'ping',
      { responseFormat: 'text' }
    )

    if (response.success && !response.isMockFallback) {
      this.aiStatusLabel = '连接正常'
      this.aiStatusDetail = 'DeepSeek API 响应成功'
    } else {
      this.aiStatusLabel = '连接失败'
      this.aiStatusDetail = response.errorMessage || '未知错误'
    }

    this.isTestingAI = false
  }

  handleSave(): void {
    const goal = parseInt(this.dailyGoal)
    const nCards = parseInt(this.newCards)
    const rCards = parseInt(this.reviewCards)

    if (goal < 5 || goal > 480) {
      promptAction.showToast({ message: '学习时长需在 5-480 分钟之间', duration: 2000 })
      return
    }
    if (nCards < 1 || nCards > 100) {
      promptAction.showToast({ message: '新卡片数需在 1-100 之间', duration: 2000 })
      return
    }

    this.settingsStore.updateSettings({
      dailyStudyGoal: goal,
      dailyNewCards: nCards,
      dailyReviewCards: rCards,
      reminderTime: this.reminderTime,
      reminderEnabled: this.reminderEnabled
    })
    promptAction.showToast({ message: '设置已保存', duration: 1500 })
  }

  handleReset(): void {
    this.settingsStore.resetDefaults()
    const s = this.settingsStore.getSettings()
    this.dailyGoal = s.dailyStudyGoal.toString()
    this.newCards = s.dailyNewCards.toString()
    this.reviewCards = s.dailyReviewCards.toString()
    this.reminderTime = s.reminderTime
    this.reminderEnabled = s.reminderEnabled
    promptAction.showToast({ message: '已恢复默认设置', duration: 1500 })
  }

  build() {
    Column() {
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24).height(24)
          .fillColor(StudyTheme.TEXT_PRIMARY)
          .onClick(() => { router.back() })

        Text('学习设置')
          .fontSize(StudyTheme.FONT_LG)
          .fontColor(StudyTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Row().width(24).height(24)
      }
      .width('100%')
      .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_MD })

      Scroll() {
        Column() {
          // Study settings
          Column() {
            Text('学习偏好')
              .fontSize(StudyTheme.FONT_SM)
              .fontColor(StudyTheme.TEXT_HINT)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: StudyTheme.SPACE_MD })

            this.buildSettingItem('每日学习时长（分钟）', this.dailyGoal, (v: string) => { this.dailyGoal = v })
            this.buildSettingItem('每日新卡片', this.newCards, (v: string) => { this.newCards = v })
            this.buildSettingItem('每日复习卡片', this.reviewCards, (v: string) => { this.reviewCards = v })
            this.buildSettingItem('提醒时间', this.reminderTime, (v: string) => { this.reminderTime = v })

            Row() {
              Text('开启提醒')
                .fontSize(StudyTheme.FONT_SM)
                .fontColor(StudyTheme.TEXT_PRIMARY)
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: this.reminderEnabled })
                .onChange((value: boolean) => { this.reminderEnabled = value })
            }
            .width('100%')
            .padding({ top: StudyTheme.SPACE_MD, bottom: StudyTheme.SPACE_MD })
          }
          .width('100%')
          .padding(StudyTheme.SPACE_LG)
          .backgroundColor(StudyTheme.CARD_BG)
          .borderRadius(StudyTheme.RADIUS_LG)
          .border({ width: 1, color: StudyTheme.CARD_BORDER })
          .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD })

          // AI Status
          Column() {
            Text('AI 状态')
              .fontSize(StudyTheme.FONT_SM)
              .fontColor(StudyTheme.TEXT_HINT)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: StudyTheme.SPACE_MD })

            Row() {
              Column() {
                Text(this.aiStatusLabel)
                  .fontSize(StudyTheme.FONT_MD)
                  .fontColor(StudyTheme.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Medium)
                Text(this.aiStatusDetail)
                  .fontSize(StudyTheme.FONT_XS)
                  .fontColor(StudyTheme.TEXT_HINT)
                  .margin({ top: 2 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)

              Row() {
                Text(this.isTestingAI ? '测试中' : '测试连接')
                  .fontSize(StudyTheme.FONT_XS)
                  .fontColor(StudyTheme.ACCENT)
                  .fontWeight(FontWeight.Medium)
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .border({ width: 1, color: StudyTheme.ACCENT })
                  .borderRadius(StudyTheme.RADIUS_SM)
              }
              .onClick(() => { this.handleTestAI() })
            }
            .width('100%')

            Row() {
              Text(`API Key: ${Constants.DEEPSEEK_API_KEY ? '已配置' : '未配置'}`)
                .fontSize(StudyTheme.FONT_XS)
                .fontColor(StudyTheme.TEXT_HINT)
              Text(`模型: ${Constants.DEEPSEEK_MODEL}`)
                .fontSize(StudyTheme.FONT_XS)
                .fontColor(StudyTheme.TEXT_HINT)
                .margin({ left: StudyTheme.SPACE_MD })
            }
            .width('100%')
            .margin({ top: StudyTheme.SPACE_SM })
          }
          .width('100%')
          .padding(StudyTheme.SPACE_LG)
          .backgroundColor(StudyTheme.CARD_BG)
          .borderRadius(StudyTheme.RADIUS_LG)
          .border({ width: 1, color: StudyTheme.CARD_BORDER })
          .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_MD })

          // Buttons
          Row() {
            Text('保存设置')
              .fontSize(StudyTheme.FONT_SM)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(StudyTheme.ACCENT)
          .borderRadius(StudyTheme.RADIUS_MD)
          .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL })
          .onClick(() => { this.handleSave() })

          Row() {
            Text('恢复默认')
              .fontSize(StudyTheme.FONT_SM)
              .fontColor(StudyTheme.TEXT_SECONDARY)
          }
          .width('100%')
          .height(40)
          .justifyContent(FlexAlign.Center)
          .margin({ top: StudyTheme.SPACE_MD })
          .onClick(() => { this.handleReset() })
        }
        .width('100%')
        .padding({ bottom: 40 })
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(StudyTheme.BG)
  }

  @Builder
  buildSettingItem(label: string, value: string, onChange: (v: string) => void) {
    Row() {
      Text(label)
        .fontSize(StudyTheme.FONT_SM)
        .fontColor(StudyTheme.TEXT_PRIMARY)
        .layoutWeight(1)
      TextInput({ text: value })
        .fontSize(StudyTheme.FONT_SM)
        .width(80)
        .textAlign(TextAlign.Center)
        .backgroundColor(StudyTheme.BG)
        .borderRadius(StudyTheme.RADIUS_SM)
        .padding({ top: 4, bottom: 4 })
        .onChange(onChange)
    }
    .width('100%')
    .padding({ top: StudyTheme.SPACE_SM, bottom: StudyTheme.SPACE_SM })
  }
}
