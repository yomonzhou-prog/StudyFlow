/**
 * StudyFlow OS — 学习教练页（场景三前端）
 *
 * 集成后端 /api/chat-planner 多轮对话。
 * AI 规划教练（严教授）风格：严厉、科学、数据驱动。
 * 当 AI 返回结构化每日计划时，渲染为打卡组件并静默写入 PlanStore。
 */

import { CoachAgent, CoachResult } from '../services/CoachAgent'
import { ApiClient, StudyTaskDTO, ChatHistoryItem, PlannerContext, PlannerChatResult } from '../services/ApiClient'
import { CoachMessage } from '../models/CoachMessage'
import { StudyTheme } from '../common/StudyTheme'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'
import { StudyPlanCard } from '../components/StudyPlanCard'

@Component
export struct CoachPage {
  @State messages: CoachMessage[] = []
  @State inputText: string = ''
  @State isLoading: boolean = false
  @State showPlanCard: boolean = false
  @State dailyTasks: StudyTaskDTO[] = []
  @State planSummary: string = ''
  @State sessionId: string = ''
  @State useBackendApi: boolean = true
  @State backendAvailable: boolean = false
  private coachAgent: CoachAgent = CoachAgent.getInstance()
  private apiClient: ApiClient = ApiClient.getInstance()
  private quickActions: string[] = [
    '帮我制定今日复习计划',
    '我的薄弱点有哪些',
    '推荐高效复习方法',
    '给我一些鼓励',
  ]

  aboutToAppear(): void {
    this.checkBackend()
    this.sessionId = IdUtils.generate()
    const welcomeMsg: CoachMessage = {
      id: IdUtils.generate(),
      role: 'coach',
      content: '你好，我是你的学习教练严教授。告诉我你的学习情况（课程、考试日期、每天可用时间），我帮你制定科学的复习策略。别想着偷懒，我会盯着你的进度。',
      timestamp: DateUtils.now(),
    }
    this.messages = [welcomeMsg]
  }

  async checkBackend(): Promise<void> {
    const available: boolean = await this.apiClient.healthCheck()
    this.backendAvailable = available
    this.useBackendApi = available
  }

  // ─── 发送消息 ───

  async handleSend(): Promise<void> {
    const text: string = this.inputText.trim()
    if (text.length === 0 || this.isLoading) { return }

    const userMsg: CoachMessage = {
      id: IdUtils.generate(),
      role: 'user',
      content: text,
      timestamp: DateUtils.now(),
    }
    this.messages.push(userMsg)
    this.inputText = ''
    this.isLoading = true

    if (this.useBackendApi && this.backendAvailable) {
      await this.handleBackendChat(text)
    } else {
      await this.handleLocalChat(text)
    }

    this.isLoading = false
  }

  // ─── 后端对话 ───

  async handleBackendChat(userText: string): Promise<void> {
    // 构建历史
    const history: ChatHistoryItem[] = []
    for (let i = 0; i < this.messages.length; i++) {
      const m: CoachMessage = this.messages[i]
      if (m.role === 'user' || m.role === 'coach') {
        const roleStr: string = m.role === 'coach' ? 'assistant' : 'user'
        const item: ChatHistoryItem = { role: roleStr, content: m.content }
        history.push(item)
      }
    }

    const context: PlannerContext = {
      courseName: '',
      examDate: '',
      availableDays: 0,
      dailyHours: 2,
      knownWeaknesses: [],
    }

    const result = await this.apiClient.chatPlanner(
      this.sessionId,
      userText,
      history,
      context,
    )

    if (result.success) {
      const data: PlannerChatResult = result.data
      const reply: string = data.reply.length > 0 ? data.reply : '（思考中...）'
      const coachMsg: CoachMessage = {
        id: IdUtils.generate(),
        role: 'coach',
        content: reply,
        timestamp: DateUtils.now(),
      }
      this.messages.push(coachMsg)

      if (data.dailyTasks.length > 0) {
        this.dailyTasks = data.dailyTasks
        this.planSummary = data.summary
        this.showPlanCard = true
      }
    } else {
      const fallbackMsg: CoachMessage = {
        id: IdUtils.generate(),
        role: 'coach',
        content: `[后端服务暂不可用，切换为本地模式]\n\n${result.errorMessage}`,
        timestamp: DateUtils.now(),
      }
      this.messages.push(fallbackMsg)
      this.useBackendApi = false
    }
  }

  // ─── 本地对话（兜底） ───

  async handleLocalChat(userText: string): Promise<void> {
    const result: CoachResult = await this.coachAgent.chat(userText, this.messages)
    const coachMsg: CoachMessage = {
      id: IdUtils.generate(),
      role: 'coach',
      content: result.content,
      timestamp: DateUtils.now(),
    }
    this.messages.push(coachMsg)
  }

  // ─── 快捷操作 ───

  handleQuickAction(action: string): void {
    this.inputText = action
    this.handleSend()
  }

  // ─── 构建 ───

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('学习教练')
          .fontSize(StudyTheme.FONT_LG)
          .fontColor(StudyTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        Row() {
          Circle({ width: 6, height: 6 })
            .fill(this.backendAvailable ? StudyTheme.SUCCESS : StudyTheme.WARNING)
            .margin({ right: 4 })
          Text(this.backendAvailable ? '在线' : '本地')
            .fontSize(10)
            .fontColor(StudyTheme.TEXT_HINT)
        }
        .padding({ left: 8, right: 8, top: 3, bottom: 3 })
        .backgroundColor(StudyTheme.BG)
        .borderRadius(StudyTheme.RADIUS_FULL)
      }
      .width('100%')
      .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_MD })

      // 聊天区域
      List() {
        if (this.messages.length <= 1) {
          ListItem() {
            Column() {
              Text('可以试着问我：')
                .fontSize(StudyTheme.FONT_SM)
                .fontColor(StudyTheme.TEXT_HINT)
                .margin({ bottom: StudyTheme.SPACE_MD })

              ForEach(this.quickActions, (action: string) => {
                Row() {
                  Text(action).fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_PRIMARY)
                }
                .width('100%')
                .padding(StudyTheme.SPACE_MD)
                .backgroundColor(StudyTheme.CARD_BG)
                .borderRadius(StudyTheme.RADIUS_MD)
                .border({ width: 1, color: StudyTheme.CARD_BORDER })
                .margin({ bottom: StudyTheme.SPACE_SM })
                .onClick(() => { this.handleQuickAction(action) })
              })
            }
            .width('100%')
            .padding(StudyTheme.SPACE_LG)
          }
        }

        ForEach(this.messages, (msg: CoachMessage) => {
          ListItem() {
            Row() {
              if (msg.role === 'user') { Blank() }
              Column() {
                Text(msg.content)
                  .fontSize(StudyTheme.FONT_SM)
                  .fontColor(msg.role === 'user' ? StudyTheme.TEXT_INVERSE : StudyTheme.TEXT_PRIMARY)
                  .lineHeight(22)
                  .padding(StudyTheme.SPACE_MD)
                  .backgroundColor(msg.role === 'user' ? StudyTheme.ACCENT : StudyTheme.CARD_BG)
                  .borderRadius({
                    topLeft: msg.role === 'coach' ? StudyTheme.RADIUS_SM : StudyTheme.RADIUS_LG,
                    topRight: msg.role === 'user' ? StudyTheme.RADIUS_SM : StudyTheme.RADIUS_LG,
                    bottomLeft: StudyTheme.RADIUS_LG,
                    bottomRight: StudyTheme.RADIUS_LG,
                  })
                  .border(msg.role === 'coach' ? { width: 1, color: StudyTheme.CARD_BORDER } : { width: 0 })
                  .constraintSize({ maxWidth: '80%' })
              }
              if (msg.role === 'coach') { Blank() }
            }
            .width('100%')
            .padding({ left: StudyTheme.SPACE_LG, right: StudyTheme.SPACE_LG, bottom: StudyTheme.SPACE_SM })
          }
        })

        if (this.showPlanCard && this.dailyTasks.length > 0) {
          ListItem() {
            Column() {
              Text('📋 学习计划')
                .fontSize(StudyTheme.FONT_MD)
                .fontColor(StudyTheme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: StudyTheme.SPACE_MD })
                .width('100%')

              StudyPlanCard({
                tasks: this.dailyTasks,
                summary: this.planSummary,
              })
            }
            .width('100%')
            .padding(StudyTheme.SPACE_LG)
          }
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部输入栏
      Row() {
        TextInput({ text: this.inputText, placeholder: '输入你的问题...' })
          .fontSize(StudyTheme.FONT_SM)
          .backgroundColor(StudyTheme.BG)
          .borderRadius(StudyTheme.RADIUS_FULL)
          .padding(StudyTheme.SPACE_MD)
          .layoutWeight(1)
          .onChange((value: string) => { this.inputText = value })
          .onSubmit(() => { this.handleSend() })

        Row() {
          Text('发送')
            .fontSize(StudyTheme.FONT_SM)
            .fontColor(StudyTheme.TEXT_INVERSE)
        }
        .padding({ left: StudyTheme.SPACE_LG, right: StudyTheme.SPACE_LG, top: StudyTheme.SPACE_SM, bottom: StudyTheme.SPACE_SM })
        .backgroundColor(this.inputText.trim().length > 0 && !this.isLoading ? StudyTheme.ACCENT : StudyTheme.TEXT_HINT)
        .borderRadius(StudyTheme.RADIUS_FULL)
        .margin({ left: StudyTheme.SPACE_SM })
        .onClick(() => { this.handleSend() })

        if (this.isLoading) {
          LoadingProgress()
            .width(24).height(24)
            .color(StudyTheme.ACCENT)
            .margin({ left: StudyTheme.SPACE_SM })
        }
      }
      .width('100%')
      .padding({ left: StudyTheme.SPACE_LG, right: StudyTheme.SPACE_LG, top: StudyTheme.SPACE_MD, bottom: StudyTheme.SPACE_LG })
      .backgroundColor(StudyTheme.CARD_BG)
      .border({ width: { top: 1 }, color: StudyTheme.BORDER })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(StudyTheme.BG)
  }
}
