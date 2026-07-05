/**
 * StudyFlow OS - 学习驾驶舱
 * 嵌入 MainPage 的"学习"Tab
 * 展示：问候+连续天数、统计数据、快捷入口、今日任务、复习卡片、薄弱知识点
 */

import { router } from '@kit.ArkUI'
import { CourseStore } from '../services/CourseStore'
import { PlanStore, WeakPoint } from '../services/PlanStore'
import { AuthStore } from '../services/AuthStore'
import { StudyTask } from '../models/StudyTask'
import { ReviewCard } from '../models/ReviewCard'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { LoadingView } from '../components/LoadingView'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'
import { MockBanner } from '../components/MockBanner'
import { SectionHeader } from '../components/SectionHeader'
import { StudyTaskCard } from '../components/StudyTaskCard'
import { EmptyState } from '../components/EmptyState'
import { DifficultyTag } from '../components/DifficultyTag'
import { DateUtils } from '../utils/DateUtils'

@Component
export struct HomePage {
  @State todayTasks: StudyTask[] = []
  @State urgentTasks: StudyTask[] = []
  @State weakPoints: WeakPoint[] = []
  @State todayCards: ReviewCard[] = []
  @State totalCards: number = 0
  @State masteredCount: number = 0
  @State isLoading: boolean = true

  private courseStore: CourseStore = CourseStore.getInstance()
  private planStore: PlanStore = PlanStore.getInstance()
  private authStore: AuthStore = AuthStore.getInstance()

  aboutToAppear(): void { this.initData() }
  onPageShow(): void { this.refreshData() }

  initData(): void {
    this.courseStore.initMockData()
    this.planStore.initMockData()
    this.refreshData()
    this.isLoading = false
  }

  refreshData(): void {
    this.todayTasks = this.planStore.getTodayTasks()
    this.urgentTasks = this.planStore.getUrgentTasks()
    this.weakPoints = this.planStore.getWeakKnowledgePoints()
    this.todayCards = this.planStore.getTodayReviewCards()

    const allCards = this.planStore.getReviewCards()
    this.totalCards = allCards.length
    this.masteredCount = allCards.filter(c => c.lastFeedbackStatus === 'mastered').length
  }

  getGreeting(): string {
    const hour = new Date().getHours()
    if (hour < 12) return '早上好'
    if (hour < 18) return '下午好'
    return '晚上好'
  }

  getProgressPercent(): number {
    if (this.totalCards === 0) return 0
    return Math.round((this.masteredCount / this.totalCards) * 100)
  }

  getPendingTaskCount(): number {
    return this.todayTasks.filter(t => t.status !== 'completed').length
  }

  getPendingCardCount(): number {
    return this.todayCards.filter(c => c.lastFeedbackStatus !== 'mastered').length
  }

  handleTaskToggle(taskId: string): void {
    const task = this.planStore.getTasks().find(t => t.id === taskId)
    if (task) {
      const newStatus = task.status === 'completed' ? 'pending' : 'completed'
      this.planStore.updateTaskStatus(taskId, newStatus)
      this.refreshData()
    }
  }

  build() {
    Column() {
      if (this.isLoading) {
        LoadingView({ message: '加载中...' })
      } else {
        Scroll() {
          Column() {
            MockBanner({
              mockMessage: 'Mock 模式运行中 — 使用示例数据演示（概率论与数理统计）',
              apiMessage: 'DeepSeek AI 驱动 — 学习任务操作系统运行中'
            })

            // 问候卡片
            this.buildGreetingCard()

            // 数据统计栏
            this.buildStatsOverview()

            // 快捷入口
            this.buildQuickActions()

            // 今日任务
            Column() {
              SectionHeader({ title: `📋 今日任务 (${this.getPendingTaskCount()})`, actionLabel: '' })
              this.buildTodayTasks()
            }
            .margin({ top: Theme.SPACING_MD })

            // 今日复习卡片
            Column() {
              SectionHeader({ title: `🃏 待复习卡片 (${this.getPendingCardCount()})`, actionLabel: '' })
              this.buildTodayCards()
            }
            .margin({ top: Theme.SPACING_MD })

            // 薄弱知识点
            Column() {
              SectionHeader({ title: `🎯 薄弱知识点 (${this.weakPoints.length})`, actionLabel: '' })
              this.buildWeakPoints()
            }
            .margin({ top: Theme.SPACING_MD })

            // 即将截止
            if (this.urgentTasks.length > 0) {
              Column() {
                SectionHeader({ title: `⏰ 即将截止 (${this.urgentTasks.length})`, actionLabel: '' })
                this.buildUrgentTasks()
              }
              .margin({ top: Theme.SPACING_MD })
            }
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
  buildGreetingCard() {
    Row() {
      Column() {
        Text(`${this.getGreeting()}！`)
          .fontSize(Theme.FONT_SM)
          .fontColor(Theme.TEXT_SECONDARY)
        Text(this.authStore.isLoggedIn() ?
          (this.authStore.getCurrentUser()?.username || '同学') :
          '同学')
          .fontSize(Theme.FONT_XXL)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)
          .margin({ top: Theme.SPACING_XS })

        Row() {
          Text('🔥')
            .fontSize(14)
          Text(`连续学习 ${this.authStore.getCurrentUser()?.streak || 0} 天`)
            .fontSize(Theme.FONT_XS)
            .fontColor(Theme.WARNING)
        }
        .margin({ top: Theme.SPACING_XS })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // Progress ring placeholder
      Column() {
        Stack() {
          // Background circle
          Circle()
            .width(64)
            .height(64)
            .fill(Theme.BORDER)
          // Progress arc (simplified as a colored circle)
          Circle()
            .width(56)
            .height(56)
            .fill(this.getProgressPercent() > 0 ? Theme.PRIMARY_BG : Theme.CARD_BG)
          Column() {
            Text(`${this.getProgressPercent()}%`)
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.PRIMARY)
              .fontWeight(FontWeight.Bold)
            Text('掌握率')
              .fontSize(9)
              .fontColor(Theme.TEXT_HINT)
          }
          .alignItems(HorizontalAlign.Center)
        }
      }
    }
    .width('100%')
    .padding(Theme.SPACING_LG)
    .backgroundColor(Theme.CARD_BG)
    .borderRadius(Theme.RADIUS_LG)
    .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }

  @Builder
  buildStatsOverview() {
    Row() {
      this.buildStatItem('📋', '今日任务', this.getPendingTaskCount().toString(), Theme.PRIMARY)
      this.buildStatItem('🃏', '待复习', this.getPendingCardCount().toString(), Theme.WARNING)
      this.buildStatItem('✅', '已掌握', this.masteredCount.toString(), Theme.SUCCESS)
      this.buildStatItem('🎯', '薄弱点', this.weakPoints.length.toString(), Theme.DANGER)
    }
    .width('100%')
    .padding(Theme.SPACING_MD)
    .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }

  @Builder
  buildStatItem(emoji: string, label: string, count: string, color: string) {
    Column() {
      Text(emoji).fontSize(20)
      Text(count).fontSize(Theme.FONT_XL).fontColor(color).fontWeight(FontWeight.Bold).margin({ top: 2 })
      Text(label).fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).margin({ top: 1 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .padding(Theme.SPACING_SM)
    .backgroundColor(Theme.CARD_BG)
    .borderRadius(Theme.RADIUS_MD)
    .margin({ left: 3, right: 3 })
  }

  @Builder
  buildQuickActions() {
    Row() {
      Row() {
        Text('➕').fontSize(16)
        Text('录入资料').fontSize(Theme.FONT_SM).fontColor(Theme.TEXT_PRIMARY).margin({ left: 4 })
      }
      .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
      .backgroundColor(Theme.CARD_BG)
      .borderRadius(Theme.RADIUS_XL)
      .layoutWeight(1)
      .onClick(() => { router.pushUrl({ url: 'pages/CourseInputPage' }) })

      Row() {
        Text('📋').fontSize(16)
        Text('复习计划').fontSize(Theme.FONT_SM).fontColor(Theme.TEXT_PRIMARY).margin({ left: 4 })
      }
      .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
      .backgroundColor(Theme.CARD_BG)
      .borderRadius(Theme.RADIUS_XL)
      .layoutWeight(1)
      .margin({ left: Theme.SPACING_SM })
      .onClick(() => { router.pushUrl({ url: 'pages/PlanPage' }) })

      Row() {
        Text('🗺️').fontSize(16)
        Text('知识地图').fontSize(Theme.FONT_SM).fontColor(Theme.TEXT_PRIMARY).margin({ left: 4 })
      }
      .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
      .backgroundColor(Theme.CARD_BG)
      .borderRadius(Theme.RADIUS_XL)
      .layoutWeight(1)
      .margin({ left: Theme.SPACING_SM })
      .onClick(() => { router.pushUrl({ url: 'pages/KnowledgeMapPage' }) })
    }
    .width('100%')
    .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }

  @Builder
  buildTodayTasks() {
    Column() {
      if (this.todayTasks.length === 0) {
        EmptyState({ icon: '🎉', message: '今天没有任务，太棒了！' })
      } else {
        ForEach(this.todayTasks, (task: StudyTask) => {
          Column() {
            StudyTaskCard({ task: task, onToggle: (taskId: string) => { this.handleTaskToggle(taskId) } })
          }
          .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
        })
      }
    }
  }

  @Builder
  buildUrgentTasks() {
    Column() {
      ForEach(this.urgentTasks, (task: StudyTask) => {
        Column() {
          StudyTaskCard({ task: task, onToggle: (taskId: string) => { this.handleTaskToggle(taskId) } })
        }
        .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
      })
    }
  }

  @Builder
  buildWeakPoints() {
    Column() {
      if (this.weakPoints.length === 0) {
        EmptyState({ icon: '💪', message: '没有薄弱知识点！继续保持！' })
      } else {
        ForEach(this.weakPoints, (point: WeakPoint) => {
          Column() {
            Row() {
              Column() {
                Text(point.title).fontSize(Theme.FONT_MD).fontColor(Theme.TEXT_PRIMARY).fontWeight(FontWeight.Medium)
                Text(`最近反馈: ${Constants.FEEDBACK_LABELS[point.lastFeedback] || point.lastFeedback}`)
                  .fontSize(Theme.FONT_XS)
                  .fontColor(point.lastFeedback === 'wrong' ? Theme.DANGER : Theme.WARNING)
                  .margin({ top: Theme.SPACING_XS })
              }
              .layoutWeight(1)
              DifficultyTag({ difficulty: point.difficulty })
            }
            .width('100%').padding(Theme.SPACING_MD).backgroundColor(Theme.CARD_BG).borderRadius(Theme.RADIUS_MD).margin({ bottom: Theme.SPACING_SM })
          }
          .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
        })
      }
    }
  }

  @Builder
  buildTodayCards() {
    Column() {
      if (this.todayCards.length === 0) {
        EmptyState({ icon: '📭', message: '今天没有需要复习的卡片' })
      } else {
        ForEach(this.todayCards, (card: ReviewCard) => {
          Column() {
            Row() {
              Column() {
                Text(card.knowledgePointTitle).fontSize(Theme.FONT_MD).fontColor(Theme.TEXT_PRIMARY).fontWeight(FontWeight.Medium)
                Text(card.keyReminder).fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: Theme.SPACING_XS })
              }
              .layoutWeight(1)
              Image($r('sys.media.ohos_ic_public_arrow_right')).width(20).height(20).fillColor(Theme.TEXT_HINT)
            }
            .width('100%').padding(Theme.SPACING_MD).backgroundColor(Theme.CARD_BG).borderRadius(Theme.RADIUS_MD).margin({ bottom: Theme.SPACING_SM })
            .onClick(() => { router.pushUrl({ url: 'pages/ReviewCardPage' }) })
          }
          .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
        })
      }
    }
  }
}
