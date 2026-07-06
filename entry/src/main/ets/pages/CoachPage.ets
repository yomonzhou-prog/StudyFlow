/**
 * StudyFlow OS - 学习教练页
 * 学习策略建议面板
 */

import { CoachAgent, CoachResult } from '../services/CoachAgent'
import { CoachMessage } from '../models/CoachMessage'
import { StudyTheme } from '../common/StudyTheme'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

@Component
export struct CoachPage {
  @State messages: CoachMessage[] = []
  @State inputText: string = ''
  @State isLoading: boolean = false
  private coachAgent: CoachAgent = CoachAgent.getInstance()
  private quickActions: string[] = [
    '帮我制定今日复习计划',
    '我的薄弱点有哪些',
    '推荐高效复习方法',
    '给我一些鼓励'
  ]

  aboutToAppear(): void {
    this.messages = [{
      id: IdUtils.generate(), role: 'coach',
      content: '你好，我是你的学习教练。告诉我你的学习情况，我帮你制定复习策略。',
      timestamp: DateUtils.now()
    }]
  }

  async handleSend(): Promise<void> {
    const text = this.inputText.trim()
    if (!text || this.isLoading) return
    this.messages.push({ id: IdUtils.generate(), role: 'user', content: text, timestamp: DateUtils.now() })
    this.inputText = ''
    this.isLoading = true
    const result: CoachResult = await this.coachAgent.chat(text, this.messages)
    this.messages.push({ id: IdUtils.generate(), role: 'coach', content: result.content, timestamp: DateUtils.now() })
    this.isLoading = false
  }

  handleQuickAction(action: string): void {
    this.inputText = action
    this.handleSend()
  }

  build() {
    Column() {
      Text('学习教练').fontSize(StudyTheme.FONT_LG).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium)
        .width('100%').textAlign(TextAlign.Center).padding({ top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_MD })
      if (this.messages.length <= 1) {
        Column() {
          Text('可以试着问我：').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_HINT).margin({ bottom: StudyTheme.SPACE_MD })
          ForEach(this.quickActions, (action: string) => {
            Row() { Text(action).fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_PRIMARY) }
            .width('100%').padding(StudyTheme.SPACE_MD).backgroundColor(StudyTheme.CARD_BG).borderRadius(StudyTheme.RADIUS_MD).border({ width: 1, color: StudyTheme.CARD_BORDER }).margin({ bottom: StudyTheme.SPACE_SM })
            .onClick(() => { this.handleQuickAction(action) })
          })
        }.width('100%').padding(StudyTheme.SPACE_LG)
      }
      List() {
        ForEach(this.messages, (msg: CoachMessage) => {
          ListItem() {
            Row() {
              if (msg.role === 'user') Blank()
              Column() {
                Text(msg.content).fontSize(StudyTheme.FONT_SM).fontColor(msg.role === 'user' ? '#FFFFFF' : StudyTheme.TEXT_PRIMARY).lineHeight(22).padding(StudyTheme.SPACE_MD)
                .backgroundColor(msg.role === 'user' ? StudyTheme.ACCENT : StudyTheme.CARD_BG).borderRadius(StudyTheme.RADIUS_LG)
                .border(msg.role === 'coach' ? { width: 1, color: StudyTheme.CARD_BORDER } : { width: 0 }).constraintSize({ maxWidth: '80%' })
              }
              if (msg.role === 'coach') Blank()
            }
            .width('100%').padding({ left: StudyTheme.SPACE_LG, right: StudyTheme.SPACE_LG, bottom: StudyTheme.SPACE_SM })
          }
        })
      }
      .layoutWeight(1).scrollBar(BarState.Off)
      Row() {
        TextInput({ text: this.inputText, placeholder: '输入你的问题...' }).fontSize(StudyTheme.FONT_SM).backgroundColor(StudyTheme.BG).borderRadius(StudyTheme.RADIUS_FULL).padding(StudyTheme.SPACE_MD).layoutWeight(1)
        .onChange((value: string) => { this.inputText = value }).onSubmit(() => { this.handleSend() })
        Row() { Text('发送').fontSize(StudyTheme.FONT_SM).fontColor('#FFFFFF') }
        .padding({ left: StudyTheme.SPACE_LG, right: StudyTheme.SPACE_LG, top: StudyTheme.SPACE_SM, bottom: StudyTheme.SPACE_SM })
        .backgroundColor(this.inputText.trim() && !this.isLoading ? StudyTheme.ACCENT : StudyTheme.TEXT_HINT).borderRadius(StudyTheme.RADIUS_FULL).margin({ left: StudyTheme.SPACE_SM })
        .onClick(() => { this.handleSend() })
        if (this.isLoading) { LoadingProgress().width(24).height(24).color(StudyTheme.ACCENT).margin({ left: StudyTheme.SPACE_SM }) }
      }
      .width('100%').padding({ left: StudyTheme.SPACE_LG, right: StudyTheme.SPACE_LG, top: StudyTheme.SPACE_MD, bottom: StudyTheme.SPACE_LG })
      .backgroundColor(StudyTheme.CARD_BG).border({ width: { top: 1 }, color: StudyTheme.BORDER })
    }
    .width('100%').height('100%').backgroundColor(StudyTheme.BG)
  }
}
