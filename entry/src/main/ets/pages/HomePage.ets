/**
 * StudyFlow OS — 极简复习首页
 * 不背单词风格：暗色暖底 + 暖金点缀 + 大量留白
 */

import { router } from '@kit.ArkUI'
import { CourseStore } from '../services/CourseStore'
import { PlanStore } from '../services/PlanStore'
import { AuthStore } from '../services/AuthStore'
import { ExamStore } from '../services/ExamStore'
import { ReviewPriorityEngine, KnowledgeRef } from '../services/ReviewPriorityEngine'
import { ExamSchedule } from '../models/ExamSchedule'
import { ReviewPriority } from '../models/ReviewPriority'
import { StudyTheme } from '../common/StudyTheme'

@Component
export struct HomePage {
  @State nearestExam: ExamSchedule | null = null
  @State priorities: ReviewPriority[] = []
  @State todayCardCount: number = 12
  @State reviewedCount: number = 5
  @State wrongCount: number = 3
  @State streakDays: number = 0
  @State isLoading: boolean = true
  @State showSheet: boolean = false

  private courseStore: CourseStore = CourseStore.getInstance()
  private planStore: PlanStore = PlanStore.getInstance()
  private authStore: AuthStore = AuthStore.getInstance()
  private examStore: ExamStore = ExamStore.getInstance()
  private priorityEngine: ReviewPriorityEngine = ReviewPriorityEngine.getInstance()

  aboutToAppear(): void { this.initData() }
  onPageShow(): void { this.refreshData() }

  initData(): void {
    this.courseStore.initMockData()
    this.planStore.initMockData()
    this.examStore.initMockData()
    this.refreshData()
    this.isLoading = false
  }

  refreshData(): void {
    this.nearestExam = this.examStore.getNearestExam()
    const allKps: KnowledgeRef[] = []
    const profile = this.courseStore.getCurrentProfile()
    if (profile) {
      for (const kp of profile.knowledgePoints) {
        allKps.push({ title: kp.title, courseName: profile.courseName, difficulty: kp.difficulty })
      }
    }
    if (allKps.length === 0) {
      this.priorities = this.priorityEngine.getMockPriorities()
    } else {
      this.priorities = this.priorityEngine.calculatePriorities(
        ['最大似然估计', '方差计算', '协方差'],
        ['方差计算', '协方差', '二叉树遍历'],
        this.nearestExam ? ExamStore.getDaysLeft(this.nearestExam.examDate) : 14,
        allKps,
      )
    }
    const cards = this.planStore.getReviewCards()
    this.reviewedCount = cards.filter(c => c.lastFeedbackStatus !== '').length
    this.wrongCount = cards.filter(c => c.lastFeedbackStatus === 'wrong').length
    this.todayCardCount = Math.max(8, cards.length - this.reviewedCount)
    this.streakDays = this.authStore.getCurrentUser()?.streak || 3
  }

  getGreeting(): string {
    const h = new Date().getHours()
    if (h < 12) return '早上好'
    if (h < 18) return '下午好'
    return '晚上好'
  }
  getUserName(): string {
    return this.authStore.isLoggedIn() ? this.authStore.getCurrentUser()?.username || '同学' : '同学'
  }

  // ═══════════════════════════════════════
  // 半屏面板 — 新建复习任务
  // ═══════════════════════════════════════

  @Builder
  SheetContent() {
    Column() {
      // 拖拽指示条
      Row()
        .width(36).height(4)
        .backgroundColor(StudyTheme.TEXT_HINT + '30')
        .borderRadius(2)
        .margin({ top: 12, bottom: 28 })

      Text('新建复习任务')
        .fontSize(20)
        .fontColor(StudyTheme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 28 })

      // ── 上传题库 PDF ──
      Row() {
        Column() {
          Text('📄').fontSize(24)
        }
        .width(52).height(52)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(StudyTheme.TEXT_PRIMARY + '08')
        .borderRadius(14)
        .margin({ right: 16 })

        Column() {
          Text('上传题库 PDF')
            .fontSize(16).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium).margin({ bottom: 2 })
          Text('老师发了试卷或题库，拆解成复习卡片')
            .fontSize(12).fontColor(StudyTheme.TEXT_SECONDARY).maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(18).height(18).fillColor(StudyTheme.TEXT_HINT)
      }
      .width('100%').padding(16)
      .backgroundColor(StudyTheme.TEXT_PRIMARY + '06')
      .borderRadius(16).border({ width: 1, color: StudyTheme.BORDER })
      .margin({ bottom: 10 })
      .onClick(() => {
        this.showSheet = false
        router.pushUrl({ url: 'pages/FileImportPage' })
      })

      // ── 老师画了重点 ──
      Row() {
        Column() {
          Text('📝').fontSize(24)
        }
        .width(52).height(52)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(StudyTheme.TEXT_PRIMARY + '08')
        .borderRadius(14)
        .margin({ right: 16 })

        Column() {
          Text('老师画了重点')
            .fontSize(16).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium).margin({ bottom: 2 })
          Text('粘贴知识点与重点范围，生成知识图谱和题卡')
            .fontSize(12).fontColor(StudyTheme.TEXT_SECONDARY).maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(18).height(18).fillColor(StudyTheme.TEXT_HINT)
      }
      .width('100%').padding(16)
      .backgroundColor(StudyTheme.TEXT_PRIMARY + '06')
      .borderRadius(16).border({ width: 1, color: StudyTheme.BORDER })
      .margin({ bottom: 10 })
      .onClick(() => {
        this.showSheet = false
        router.pushUrl({ url: 'pages/KnowledgeGraphPage' })
      })

      // ── 只有考试范围 ──
      Row() {
        Column() {
          Text('📅').fontSize(24)
        }
        .width(52).height(52)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(StudyTheme.TEXT_PRIMARY + '08')
        .borderRadius(14)
        .margin({ right: 16 })

        Column() {
          Text('只有考试范围')
            .fontSize(16).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium).margin({ bottom: 2 })
          Text('填写考试信息，自动生成每日复习计划')
            .fontSize(12).fontColor(StudyTheme.TEXT_SECONDARY).maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(18).height(18).fillColor(StudyTheme.TEXT_HINT)
      }
      .width('100%').padding(16)
      .backgroundColor(StudyTheme.TEXT_PRIMARY + '06')
      .borderRadius(16).border({ width: 1, color: StudyTheme.BORDER })
      .margin({ bottom: 30 })
      .onClick(() => {
        this.showSheet = false
        router.pushUrl({ url: 'pages/CoachPlannerPage' })
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
    .alignItems(HorizontalAlign.Center)
  }

  // ═══════════════════════════════════════
  // 主页面构建
  // ═══════════════════════════════════════

  build() {
    Stack() {
      Column() {
        if (this.isLoading) {
          Column() {
            LoadingProgress().width(32).height(32).color(StudyTheme.ACCENT)
          }
          .width('100%').height('100%').justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              // ═══ 问好 ═══
              Column() {
                Text(this.getGreeting())
                  .fontSize(14).fontColor(StudyTheme.TEXT_HINT).fontWeight(FontWeight.Normal)
                  .margin({ bottom: 6 })
                Text(`${this.getUserName()}，`)
                  .fontSize(28).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
              }
              .width('100%').alignItems(HorizontalAlign.Start)
              .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XXXL, bottom: 8 })

              // ═══ 考试倒计时（暖金 + 毛玻璃卡片）═══
              if (this.nearestExam) {
                Column() {
                  Row() {
                    Text(ExamStore.getDaysLeft(this.nearestExam.examDate).toString())
                      .fontSize(42).fontColor(StudyTheme.ACCENT).fontWeight(FontWeight.Bold)
                    Text(' 天')
                      .fontSize(16).fontColor(StudyTheme.TEXT_HINT)
                  }
                  .margin({ bottom: 12 })

                  Text(this.nearestExam.courseName)
                    .fontSize(16).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium)
                    .margin({ bottom: 4 })
                  Text(`${this.nearestExam.examDate} · ${this.nearestExam.examTime}`)
                    .fontSize(12).fontColor(StudyTheme.TEXT_HINT)
                }
                .width('100%')
                .padding({ top: 28, bottom: 28 })
                .alignItems(HorizontalAlign.Center)
                .backgroundColor(StudyTheme.TEXT_PRIMARY + '06')
                .backdropBlur(16)
                .border({ width: 1, color: StudyTheme.BORDER })
                .borderRadius(StudyTheme.RADIUS_XL)
                .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: 24 })
                .onClick(() => { router.pushUrl({ url: 'pages/ExamSchedulePage' }) })
              }

              // ═══ 今日数据（单行标签式）═══
              Row() {
                Text(`待复习 ${this.todayCardCount}`)
                  .fontSize(13).fontColor(StudyTheme.TEXT_SECONDARY).fontWeight(FontWeight.Medium)
                Text(' · ').fontSize(13).fontColor(StudyTheme.TEXT_HINT)
                Text(`已完成 ${this.reviewedCount}`)
                  .fontSize(13).fontColor(StudyTheme.TEXT_SECONDARY)
                Text(' · ').fontSize(13).fontColor(StudyTheme.TEXT_HINT)
                Text(`错题 ${this.wrongCount}`)
                  .fontSize(13).fontColor(StudyTheme.TEXT_SECONDARY)
                Text(' · ').fontSize(13).fontColor(StudyTheme.TEXT_HINT)
                Text(`连续 ${this.streakDays} 天`)
                  .fontSize(13).fontColor(StudyTheme.TEXT_SECONDARY)
              }
              .width('100%')
              .padding({ top: 6, bottom: 6 })
              .justifyContent(FlexAlign.Center)
              .margin({ bottom: 28 })

              // ═══ 开始今日复习（暖金按钮，居中 + 窄）═══
              Row() {
                Text('开始今日复习')
                  .fontSize(18).fontColor(StudyTheme.TEXT_INVERSE).fontWeight(FontWeight.Bold)
              }
              .width('80%').height(56)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(StudyTheme.ACCENT)
              .borderRadius(StudyTheme.RADIUS_LG)
              .shadow({ radius: 16, color: '#C8A96E40', offsetX: 0, offsetY: 4 })
              .margin({ bottom: 36 })
              .onClick(() => { router.pushUrl({ url: 'pages/ImmersiveReviewPage' }) })

              // ═══ 复习优先级 ═══
              Column() {
                Row() {
                  Text('复习优先级')
                    .fontSize(12).fontColor(StudyTheme.TEXT_HINT).fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                }
                .width('100%').margin({ bottom: 16 })

                if (this.priorities.length === 0) {
                  Text('暂无 — 通过右下角 [+] 导入课程资料')
                    .fontSize(12).fontColor(StudyTheme.TEXT_HINT)
                    .width('100%').padding({ top: 8, bottom: 8 })
                } else {
                  ForEach(this.priorities.slice(0, 3), (item: ReviewPriority) => {
                    Row() {
                      // 空心圆点指示器
                      Column()
                        .width(10).height(10)
                        .borderRadius(5)
                        .border({ width: 2, color: item.level === 'high' ? StudyTheme.PRIORITY_HIGH :
                          item.level === 'medium' ? StudyTheme.PRIORITY_MEDIUM : StudyTheme.PRIORITY_LOW })
                        .backgroundColor(item.level === 'high' ? StudyTheme.PRIORITY_HIGH + '30' :
                          item.level === 'medium' ? StudyTheme.PRIORITY_MEDIUM + '30' : StudyTheme.PRIORITY_LOW + '30')
                        .margin({ right: 14 })

                      Column() {
                        Text(item.knowledgeTitle)
                          .fontSize(16).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium)
                          .margin({ bottom: 2 })
                        Text(item.courseName)
                          .fontSize(11).fontColor(StudyTheme.TEXT_HINT)
                      }
                      .layoutWeight(1).alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .padding({ top: 14, bottom: 14 })
                  })
                }
              }
              .width('100%')
              .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: 120 })
            }
            .width('100%')
          }
          .scrollBar(BarState.Off).layoutWeight(1)
        }
      }
      .width('100%').height('100%').backgroundColor(StudyTheme.BG)

      // ═══════════════════════════════════
      // FAB 悬浮按钮（暖金毛玻璃）
      // ═══════════════════════════════════
      Column() {
        Column() {
          Text('+')
            .fontSize(28).fontColor(StudyTheme.TEXT_INVERSE).fontWeight(FontWeight.Lighter)
        }
        .width(56).height(56)
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .backgroundColor('#C8A96ECC')
        .borderRadius(28)
        .backdropBlur(12)
        .shadow({ radius: 24, color: '#00000060', offsetX: 0, offsetY: 6 })
        .onClick(() => { this.showSheet = true })
        .bindSheet($$this.showSheet, this.SheetContent(), {
          height: SheetSize.MEDIUM,
          backgroundColor: StudyTheme.OVERLAY_BG,
          showClose: false,
          dragBar: false,
        })
      }
      .width('100%').height('100%')
      .alignItems(HorizontalAlign.End).justifyContent(FlexAlign.End)
      .padding({ right: 20, bottom: 24 })
      .hitTestBehavior(HitTestMode.Transparent)
    }
    .width('100%').height('100%')
    .backgroundColor(StudyTheme.BG)
  }
}
