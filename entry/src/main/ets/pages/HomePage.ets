/**
 * StudyFlow OS - 首页：学习驾驶舱
 * 展示今日任务、三天内截止、薄弱知识点、今日复习卡片
 */

import { router } from '@kit.ArkUI'
import { CourseStore } from '../services/CourseStore'
import { PlanStore, WeakPoint } from '../services/PlanStore'
import { StudyTask } from '../models/StudyTask'
import { ReviewCard } from '../models/ReviewCard'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { PageHeader } from '../components/PageHeader'
import { LoadingView } from '../components/LoadingView'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'
import { MockBanner } from '../components/MockBanner'
import { SectionHeader } from '../components/SectionHeader'
import { StudyTaskCard } from '../components/StudyTaskCard'
import { EmptyState } from '../components/EmptyState'
import { PriorityTag } from '../components/PriorityTag'
import { DifficultyTag } from '../components/DifficultyTag'
import { DateUtils } from '../utils/DateUtils'

@Entry
@Component
struct HomePage {
  @State todayTasks: StudyTask[] = []
  @State urgentTasks: StudyTask[] = []
  @State weakPoints: WeakPoint[] = []
  @State todayCards: ReviewCard[] = []
  @State isLoading: boolean = true

  private courseStore: CourseStore = CourseStore.getInstance()
  private planStore: PlanStore = PlanStore.getInstance()

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
      PageHeader({ title: 'StudyFlow OS' })
        .padding({ top: Theme.SPACING_XL })

      if (this.isLoading) {
        LoadingView({ message: '加载中...' })
      } else {
        Scroll() {
          Column() {
            MockBanner({
              mockMessage: 'Mock 模式运行中 — 使用示例数据演示（概率论与数理统计）',
              apiMessage: 'DeepSeek AI 驱动 — 学习任务操作系统运行中'
            })

            this.buildStatsOverview()

            Column() {
              SectionHeader({ title: `📋 今日必须完成 (${this.todayTasks.length})`, actionLabel: '' })
              this.buildTodayTasks()
            }
            .margin({ top: Theme.SPACING_MD })

            Column() {
              SectionHeader({ title: `⏰ 三天内截止 (${this.urgentTasks.length})`, actionLabel: '' })
              this.buildUrgentTasks()
            }
            .margin({ top: Theme.SPACING_MD })

            Column() {
              SectionHeader({ title: `🎯 薄弱知识点 (${this.weakPoints.length})`, actionLabel: '' })
              this.buildWeakPoints()
            }
            .margin({ top: Theme.SPACING_MD })

            Column() {
              SectionHeader({ title: `📚 今日复习卡片 (${this.todayCards.length})`, actionLabel: '' })
              this.buildTodayCards()
            }
            .margin({ top: Theme.SPACING_MD })

            this.buildActionButtons()
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
  buildStatsOverview() {
    Row() {
      this.buildStatItem('📋', '今日任务', this.todayTasks.filter(t => t.status !== 'completed').length.toString())
      this.buildStatItem('⏰', '即将截止', this.urgentTasks.filter(t => t.status !== 'completed').length.toString())
      this.buildStatItem('🎯', '薄弱点', this.weakPoints.length.toString())
      this.buildStatItem('📚', '待复习', this.todayCards.filter(c => c.lastFeedbackStatus !== 'mastered').length.toString())
    }
    .width('100%')
    .padding(Theme.SPACING_MD)
    .backgroundColor(Theme.CARD_BG)
    .borderRadius(Theme.RADIUS_MD)
    .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }

  @Builder
  buildStatItem(icon: string, label: string, count: string) {
    Column() {
      Text(icon).fontSize(24)
      Text(count).fontSize(Theme.FONT_XL).fontColor(Theme.TEXT_PRIMARY).fontWeight(FontWeight.Bold).margin({ top: Theme.SPACING_XS })
      Text(label).fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).margin({ top: 2 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
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
      if (this.urgentTasks.length === 0) {
        EmptyState({ icon: '✅', message: '三天内没有截止任务' })
      } else {
        ForEach(this.urgentTasks, (task: StudyTask) => {
          Column() {
            StudyTaskCard({ task: task, onToggle: (taskId: string) => { this.handleTaskToggle(taskId) } })
          }
          .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
        })
      }
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

  @Builder
  buildActionButtons() {
    Column() {
      PrimaryButton({ label: '➕ 新建课程资料', onAction: () => { router.pushUrl({ url: 'pages/CourseInputPage' }) } })
      SecondaryButton({ label: '📋 查看复习计划', onAction: () => { router.pushUrl({ url: 'pages/PlanPage' }) } })
        .margin({ top: Theme.SPACING_MD })
    }
    .width('100%')
    .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_LG })
  }
}
