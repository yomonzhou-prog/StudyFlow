/**
 * StudyFlow OS - 复习计划页
 * 展示学习闭环中的"再规划"结果
 * 包含今日计划、明日建议、薄弱点强化、临考冲刺
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { CourseStore } from '../services/CourseStore'
import { PlanStore } from '../services/PlanStore'
import { StudyTask } from '../models/StudyTask'
import { LearningFeedback } from '../models/LearningFeedback'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { DateUtils } from '../utils/DateUtils'
import { PageHeader } from '../components/PageHeader'
import { LoadingView } from '../components/LoadingView'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'
import { SectionHeader } from '../components/SectionHeader'
import { StudyTaskCard } from '../components/StudyTaskCard'
import { PriorityTag } from '../components/PriorityTag'
import { EmptyState } from '../components/EmptyState'

@Entry
@Component
struct PlanPage {
  @State todayTasks: StudyTask[] = []
  @State tomorrowTasks: StudyTask[] = []
  @State weaknessTasks: StudyTask[] = []
  @State examTasks: StudyTask[] = []
  @State feedbackTasks: StudyTask[] = []
  @State recentFeedbacks: LearningFeedback[] = []
  @State isLoading: boolean = true
  @State selectedTab: number = 0

  private courseStore: CourseStore = CourseStore.getInstance()
  private planStore: PlanStore = PlanStore.getInstance()

  aboutToAppear(): void {
    this.loadData()
  }

  onPageShow(): void {
    this.refreshData()
  }

  loadData(): void {
    if (this.planStore.getTasks().length === 0) {
      this.courseStore.initMockData()
      this.planStore.initMockData()
    }

    this.refreshData()
    this.isLoading = false
  }

  refreshData(): void {
    const allTasks = this.planStore.getTasks()

    // 今日任务
    this.todayTasks = allTasks.filter(t =>
      t.status !== 'completed' && DateUtils.isToday(t.deadline)
    )

    // 明日建议（明天及之后的pending任务）
    const tomorrow = DateUtils.daysLater(1)
    this.tomorrowTasks = allTasks.filter(t =>
      t.status !== 'completed' &&
      !DateUtils.isToday(t.deadline) &&
      new Date(t.deadline) <= new Date(tomorrow)
    )

    // 薄弱点任务
    this.weaknessTasks = this.planStore.getWeaknessTasks()

    // 临考冲刺（高优先级pending任务）
    this.examTasks = allTasks.filter(t =>
      t.status !== 'completed' &&
      t.priority === 'high'
    )

    // 根据反馈生成的新任务（最近模糊/做错的）
    this.feedbackTasks = allTasks.filter(t =>
      t.sourceType === 'weakness' && t.status !== 'completed'
    )

    // 最近反馈
    this.recentFeedbacks = this.planStore.getFeedbacks().slice(0, 5)
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
      PageHeader({ title: '复习计划' })

      if (this.isLoading) {
        LoadingView({ message: '加载复习计划...' })
      } else {
        Scroll() {
          Column() {
            // 计划标题
            this.buildPlanSummary()

            // 反馈概览
            this.buildFeedbackOverview()

            // Tab切换 + 任务列表
            Tabs({ index: this.selectedTab }) {
              TabContent() { this.buildTaskListForTab(this.todayTasks, '今天没有任务，太棒了！') }
              TabContent() { this.buildTaskListForTab(this.tomorrowTasks.length > 0 ? this.tomorrowTasks : this.feedbackTasks, '明日暂无安排') }
              TabContent() { this.buildTaskListForTab(this.weaknessTasks, '没有薄弱点任务，继续保持！') }
              TabContent() { this.buildTaskListForTab(this.examTasks, '没有临考冲刺任务') }
            }
            .barMode(BarMode.Fixed)
            .vertical(false)
            .scrollable(true)
            .onChange((index: number) => { this.selectedTab = index })
            .width('100%')
            .backgroundColor(Theme.CARD_BG)
            .margin({ top: Theme.SPACING_MD })

            // 二次复习建议
            this.buildReviewAdvice()

            // 操作按钮
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
  buildPlanSummary() {
    Column() {
      Text('📋 学习任务操作系统 — 再规划')
        .fontSize(Theme.FONT_XL)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)

      Text(`基于${this.recentFeedbacks.length}条学习反馈，已优化您的复习计划`)
        .fontSize(Theme.FONT_SM)
        .fontColor(Theme.TEXT_HINT)
        .margin({ top: Theme.SPACING_XS })

      // 统计
      Row() {
        this.buildMiniStat('📋', '总任务', this.planStore.getTasks().length.toString())
        this.buildMiniStat('✅', '已完成', this.planStore.getTasksByStatus('completed').length.toString())
        this.buildMiniStat('⏳', '进行中', this.planStore.getTasksByStatus('in_progress').length.toString())
        this.buildMiniStat('🎯', '待完成', this.planStore.getTasksByStatus('pending').length.toString())
      }
      .width('100%')
      .margin({ top: Theme.SPACING_MD })
    }
    .width('100%')
    .padding(Theme.SPACING_LG)
    .backgroundColor(Theme.CARD_BG)
    .borderRadius(Theme.RADIUS_MD)
    .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildMiniStat(icon: string, label: string, count: string) {
    Column() {
      Text(icon).fontSize(20)
      Text(count).fontSize(Theme.FONT_LG).fontColor(Theme.TEXT_PRIMARY).fontWeight(FontWeight.Bold).margin({ top: 2 })
      Text(label).fontSize(Theme.FONT_XS).fontColor(Theme.TEXT_HINT).margin({ top: 1 })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildFeedbackOverview() {
    if (this.recentFeedbacks.length > 0) {
    Column() {
      SectionHeader({ title: '📊 最近反馈' })

      Scroll() {
        Row() {
          ForEach(this.recentFeedbacks, (fb: LearningFeedback) => {
            Row() {
              Text(this.getFeedbackEmoji(fb.status))
                .fontSize(14)

              Column() {
                Text(fb.knowledgePointTitle)
                  .fontSize(Theme.FONT_XS)
                  .fontColor(Theme.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Medium)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Text(Constants.FEEDBACK_LABELS[fb.status] || fb.status)
                  .fontSize(10)
                  .fontColor(this.getFeedbackColor(fb.status))
              }
              .margin({ left: Theme.SPACING_XS })
              .constraintSize({ maxWidth: 80 })
            }
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .backgroundColor(this.getFeedbackBg(fb.status))
            .borderRadius(Theme.RADIUS_XL)
            .margin({ right: Theme.SPACING_SM })
          })
        }
        .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .margin({ top: Theme.SPACING_MD })
    }
  }

  @Builder
  buildTaskListForTab(tasks: StudyTask[], emptyMessage: string) {
    Column() {
      if (tasks.length === 0) {
        EmptyState({ icon: '🎉', message: emptyMessage })
      } else {
        ForEach(tasks, (task: StudyTask) => {
          Column() {
            StudyTaskCard({ task: task, onToggle: (taskId: string) => { this.handleTaskToggle(taskId) } })
          }
          .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
        })
      }
    }
    .width('100%')
    .margin({ top: Theme.SPACING_SM })
  }

  @Builder
  buildReviewAdvice() {
    Column() {
      SectionHeader({ title: '💡 二次复习建议' })

      Column() {
        // 根据薄弱点生成建议
        if (this.planStore.getWeakKnowledgePoints().length > 0) {
          Row() {
            Text('🎯')
              .fontSize(20)
            Column() {
              Text('重点关注')
                .fontSize(Theme.FONT_SM)
                .fontColor(Theme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)

              Text(`${this.getWeakPointTitles()} 还需要加强复习`)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.TEXT_HINT)
                .margin({ top: 2 })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
        }

        Row() {
          Text('⏰')
            .fontSize(20)
          Column() {
            Text('时间安排')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)

            Text('建议每天投入2小时复习概率论，优先解决方差计算和协方差概念问题')
              .fontSize(Theme.FONT_XS)
              .fontColor(Theme.TEXT_HINT)
              .margin({ top: 2 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })

        Row() {
          Text('📈')
            .fontSize(20)
          Column() {
            Text('进度建议')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)

            Text('学完一章后立即用复习卡片自测，错题当天复习，模糊点次日巩固')
              .fontSize(Theme.FONT_XS)
              .fontColor(Theme.TEXT_HINT)
              .margin({ top: 2 })
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
      }
      .width('100%')
      .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
    }
    .width('100%')
    .backgroundColor(Theme.CARD_BG)
    .borderRadius(Theme.RADIUS_MD)
    .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }

  @Builder
  buildActionButtons() {
    Column() {
      PrimaryButton({
        label: '🃏 继续复习卡片',
        onAction: () => {
          router.pushUrl({ url: 'pages/ReviewCardPage' })
        }
      })

      SecondaryButton({
        label: '🏠 返回驾驶舱',
        onAction: () => {
          router.pushUrl({ url: 'pages/HomePage' })
        }
      })
    }
    .width('100%')
    .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_XL })
  }

  getWeakPointTitles(): string {
    return this.planStore.getWeakKnowledgePoints().map(w => w.title).join('、')
  }

  getFeedbackEmoji(status: string): string {
    switch (status) {
      case 'mastered': return '✅'
      case 'fuzzy': return '🤔'
      case 'wrong': return '❌'
      default: return ''
    }
  }

  getFeedbackColor(status: string): string {
    switch (status) {
      case 'mastered': return Theme.SUCCESS
      case 'fuzzy': return Theme.WARNING
      case 'wrong': return Theme.DANGER
      default: return Theme.TEXT_PRIMARY
    }
  }

  getFeedbackBg(status: string): string {
    switch (status) {
      case 'mastered': return Theme.SUCCESS_BG
      case 'fuzzy': return Theme.WARNING_BG
      case 'wrong': return Theme.DANGER_BG
      default: return Theme.BG
    }
  }
}
