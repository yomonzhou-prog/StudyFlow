/**
 * StudyFlow OS - 学习教练页
 * 聊天式 AI 对话界面，支持快捷提问卡片
 */

import { router } from '@kit.ArkUI'
import { CoachAgent, CoachResult } from '../services/CoachAgent'
import { CoachMessage, CoachCard } from '../models/CoachMessage'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { PageHeader } from '../components/PageHeader'
import { LoadingView } from '../components/LoadingView'
import { PrimaryButton } from '../components/AppButton'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

@Component
export struct CoachPage {
  @State messages: CoachMessage[] = []
  @State inputText: string = ''
  @State isLoading: boolean = false
  @State showQuickCards: boolean = true

  private coachAgent: CoachAgent = CoachAgent.getInstance()

  private quickCards: CoachCard[] = [
    { id: 'qc-1', emoji: '📋', title: '帮我制定学习计划', prompt: '请帮我制定一个学习计划' },
    { id: 'qc-2', emoji: '📊', title: '查看学习进度', prompt: '我的学习进度怎么样' },
    { id: 'qc-3', emoji: '💡', title: '推荐学习方法', prompt: '有什么好的学习方法推荐' },
    { id: 'qc-4', emoji: '🌟', title: '鼓励我一下', prompt: '鼓励我一下' }
  ]

  aboutToAppear(): void {
    // 初始欢迎消息
    const welcomeMsg: CoachMessage = {
      id: IdUtils.generate(),
      role: 'coach',
      content: '👋 你好！我是你的学习教练。有什么学习方面的问题，尽管问我！',
      timestamp: DateUtils.now()
    }
    this.messages = [welcomeMsg]
  }

  async handleSend(): Promise<void> {
    const text = this.inputText.trim()
    if (!text || this.isLoading) return

    // 添加用户消息
    const userMsg: CoachMessage = {
      id: IdUtils.generate(),
      role: 'user',
      content: text,
      timestamp: DateUtils.now()
    }
    this.messages.push(userMsg)
    this.inputText = ''
    this.showQuickCards = false
    this.isLoading = true

    // 调用教练 Agent
    const result: CoachResult = await this.coachAgent.chat(text, this.messages)

    const coachMsg: CoachMessage = {
      id: IdUtils.generate(),
      role: 'coach',
      content: result.content,
      timestamp: DateUtils.now()
    }
    this.messages.push(coachMsg)
    this.isLoading = false
  }

  handleQuickCard(card: CoachCard): void {
    this.inputText = card.prompt
    this.handleSend()
  }

  build() {
    Column() {
      PageHeader({ title: '学习教练' })

      if (this.showQuickCards && this.messages.length <= 1) {
        // 快捷提问卡片
        Column() {
          Text('💡 你可以试着问我：')
            .fontSize(Theme.FONT_SM)
            .fontColor(Theme.TEXT_SECONDARY)
            .margin({ bottom: Theme.SPACING_MD })

          ForEach(this.quickCards, (card: CoachCard) => {
            Row() {
              Text(card.emoji).fontSize(20)
              Text(card.title)
                .fontSize(Theme.FONT_MD)
                .fontColor(Theme.TEXT_PRIMARY)
                .margin({ left: Theme.SPACING_SM })
            }
            .width('100%')
            .padding(Theme.SPACING_MD)
            .backgroundColor(Theme.CARD_BG)
            .borderRadius(Theme.RADIUS_MD)
            .margin({ bottom: Theme.SPACING_SM })
            .onClick(() => { this.handleQuickCard(card) })
          })
        }
        .width('100%')
        .padding(Theme.SPACING_LG)
      }

      // 消息列表
      List() {
        ForEach(this.messages, (msg: CoachMessage) => {
          ListItem() {
            Row() {
              if (msg.role === 'user') {
                Blank()
              }
              Column() {
                Text(msg.content)
                  .fontSize(Theme.FONT_SM)
                  .fontColor(msg.role === 'user' ? '#FFFFFF' : Theme.TEXT_PRIMARY)
                  .lineHeight(22)
                  .padding(Theme.SPACING_MD)
                  .backgroundColor(msg.role === 'user' ? Theme.PRIMARY : Theme.CARD_BG)
                  .borderRadius(Theme.RADIUS_LG)
                  .constraintSize({ maxWidth: '80%' })
              }
              if (msg.role === 'coach') {
                Blank()
              }
            }
            .width('100%')
            .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, bottom: Theme.SPACING_SM })
          }
        })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 输入栏
      Row() {
        TextInput({ text: this.inputText, placeholder: '输入你的问题...' })
          .fontSize(Theme.FONT_SM)
          .backgroundColor(Theme.BG)
          .borderRadius(Theme.RADIUS_XL)
          .padding(Theme.SPACING_MD)
          .layoutWeight(1)
          .onChange((value: string) => { this.inputText = value })
          .onSubmit(() => { this.handleSend() })

        Row() {
          Text('发送')
            .fontSize(Theme.FONT_SM)
            .fontColor('#FFFFFF')
        }
        .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
        .backgroundColor(this.inputText.trim() && !this.isLoading ? Theme.PRIMARY : Theme.TEXT_HINT)
        .borderRadius(Theme.RADIUS_XL)
        .margin({ left: Theme.SPACING_SM })
        .onClick(() => { this.handleSend() })

        if (this.isLoading) {
          LoadingProgress()
            .width(24).height(24)
            .color(Theme.PRIMARY)
            .margin({ left: Theme.SPACING_SM })
        }
      }
      .width('100%')
      .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD, bottom: Theme.SPACING_LG })
      .backgroundColor(Theme.CARD_BG)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }
}
