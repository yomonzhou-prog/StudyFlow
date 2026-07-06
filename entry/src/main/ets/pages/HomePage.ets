/**
 * StudyFlow OS — 极简复习首页
 * 只保留：问好 + 考试倒计时 + 开始复习 + 优先级 + 统计
 * 新建任务统一收敛到右下角 FAB → 底部半屏面板
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
import { StatusBanner } from '../components/StatusBanner'

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
  getStatusText(): string {
    const p = this.todayCardCount - this.reviewedCount
    return p > 0 ? `还有 ${p} 张卡片等你复习` : '复习已完成，很棒'
  }

  // ─── 半屏面板内容 ───

  @Builder
  SheetContent() {
    Column() {
      // 拖拽指示条
      Row()
        .width(36).height(4)
        .backgroundColor('#FFFFFF30')
        .borderRadius(2)
        .margin({ top: 12, bottom: 24 })

      Text('新建复习任务')
        .fontSize(20)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 24 })

      // 场景一：上传题库 PDF
      Row() {
        Column() {
          Text('📄').fontSize(28)
        }
        .width(52).height(52)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FFFFFF10')
        .borderRadius(14)
        .margin({ right: 16 })

        Column() {
          Text('上传题库 PDF').fontSize(16).fontColor('#FFFFFF').fontWeight(FontWeight.Medium).margin({ bottom: 2 })
          Text('老师发了试卷/题库，AI 拆解成一题一卡').fontSize(12).fontColor('#FFFFFF60').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(18).height(18).fillColor('#FFFFFF40')
      }
      .width('100%').padding(16)
      .backgroundColor('#FFFFFF08').borderRadius(16)
      .margin({ bottom: 10 })
      .onClick(() => {
        this.showSheet = false
        router.pushUrl({ url: 'pages/FileImportPage' })
      })

      // 场景二：划重点 → 知识图谱
      Row() {
        Column() {
          Text('📝').fontSize(28)
        }
        .width(52).height(52)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FFFFFF10')
        .borderRadius(14)
        .margin({ right: 16 })

        Column() {
          Text('老师画了重点').fontSize(16).fontColor('#FFFFFF').fontWeight(FontWeight.Medium).margin({ bottom: 2 })
          Text('粘贴知识点 + 重点范围，生成知识图谱和题卡').fontSize(12).fontColor('#FFFFFF60').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(18).height(18).fillColor('#FFFFFF40')
      }
      .width('100%').padding(16)
      .backgroundColor('#FFFFFF08').borderRadius(16)
      .margin({ bottom: 10 })
      .onClick(() => {
        this.showSheet = false
        router.pushUrl({ url: 'pages/KnowledgeGraphPage' })
      })

      // 场景三：只有范围 → AI 规划
      Row() {
        Column() {
          Text('🤖').fontSize(28)
        }
        .width(52).height(52)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#FFFFFF10')
        .borderRadius(14)
        .margin({ right: 16 })

        Column() {
          Text('只有考试范围').fontSize(16).fontColor('#FFFFFF').fontWeight(FontWeight.Medium).margin({ bottom: 2 })
          Text('告诉 AI 教练考试信息，自动制定每日复习计划').fontSize(12).fontColor('#FFFFFF60').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1).alignItems(HorizontalAlign.Start)

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(18).height(18).fillColor('#FFFFFF40')
      }
      .width('100%').padding(16)
      .backgroundColor('#FFFFFF08').borderRadius(16)
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

  // ─── 构建 ───

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
              StatusBanner()

              // ═══ 问好 ═══
              Column() {
                Text(this.getGreeting())
                  .fontSize(14).fontColor(StudyTheme.TEXT_HINT).fontWeight(FontWeight.Normal)
                Row() {
                  Text(`${this.getUserName()}，`)
                    .fontSize(26).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
                  Text(this.getStatusText())
                    .fontSize(14).fontColor(StudyTheme.TEXT_HINT).layoutWeight(1).maxLines(1)
                }
                .width('100%').margin({ top: 2 }).alignItems(VerticalAlign.Bottom)
              }
              .width('100%').alignItems(HorizontalAlign.Start)
              .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: 24 })

              // ═══ 考试倒计时（居中强化）═══
              if (this.nearestExam) {
                Column() {
                  Text(ExamStore.getDaysLeft(this.nearestExam.examDate).toString())
                    .fontSize(56).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                  Text('天')
                    .fontSize(14).fontColor(StudyTheme.TEXT_HINT)
                    .margin({ top: 4, bottom: 16 })
                  Text(this.nearestExam.courseName)
                    .fontSize(18).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
                  Text(`${this.nearestExam.examDate} · ${this.nearestExam.examTime}`)
                    .fontSize(12).fontColor(StudyTheme.TEXT_HINT)
                    .margin({ top: 4 })
                }
                .width('100%')
                .padding({ top: 32, bottom: 32 })
                .alignItems(HorizontalAlign.Center)
                .onClick(() => { router.pushUrl({ url: 'pages/ExamSchedulePage' }) })
                .margin({ bottom: 8 })
              }

              // ═══ 今日复习数据（紧凑型）═══
              Row() {
                Column() {
                  Text(this.todayCardCount.toString()).fontSize(32).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                  Text('待复习').fontSize(11).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
                }.layoutWeight(1).alignItems(HorizontalAlign.Center)
                Column() {
                  Text(this.reviewedCount.toString()).fontSize(32).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                  Text('已完成').fontSize(11).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
                }.layoutWeight(1).alignItems(HorizontalAlign.Center)
                Column() {
                  Text(this.wrongCount.toString()).fontSize(32).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                  Text('错题').fontSize(11).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
                }.layoutWeight(1).alignItems(HorizontalAlign.Center)
                Column() {
                  Text(`${this.streakDays}`).fontSize(32).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                  Text('连续天数').fontSize(11).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
                }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
              .backgroundColor('#FFFFFF06')
              .borderRadius(StudyTheme.RADIUS_LG)
              .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: 4 })

              // ═══ 居中「开始今日复习」════
              Row() {
                Column() {
                  Text('开始今日复习')
                    .fontSize(20).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                  Text(`${this.todayCardCount} 张卡片 · 预计 ${Math.round(this.todayCardCount * 2)} 分钟`)
                    .fontSize(12).fontColor('#FFFFFF60')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Center)
              }
              .width('100%').height(72)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(StudyTheme.ACCENT)
              .borderRadius(StudyTheme.RADIUS_LG)
              .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: 32 })
              .onClick(() => { router.pushUrl({ url: 'pages/ImmersiveReviewPage' }) })

              // ═══ 复习优先级 ═══
              Column() {
                Row() {
                  Text('复习优先级')
                    .fontSize(13).fontColor(StudyTheme.TEXT_HINT).fontWeight(FontWeight.Medium)
                    .layoutWeight(1)
                }
                .width('100%').margin({ bottom: 12 })

                if (this.priorities.length === 0) {
                  Text('暂无 — 通过下方 [+] 导入课程资料')
                    .fontSize(12).fontColor(StudyTheme.TEXT_HINT)
                    .width('100%').padding({ top: 8, bottom: 8 })
                } else {
                  ForEach(this.priorities.slice(0, 3), (item: ReviewPriority) => {
                    Row() {
                      Column() {
                        Text(item.level === 'high' ? '高' : item.level === 'medium' ? '中' : '低')
                          .fontSize(10).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                      }
                      .width(22).height(22).borderRadius(11)
                      .backgroundColor(
                        item.level === 'high' ? StudyTheme.PRIORITY_HIGH :
                        item.level === 'medium' ? StudyTheme.PRIORITY_MEDIUM :
                        StudyTheme.PRIORITY_LOW
                      )
                      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
                      .margin({ right: 12 })

                      Column() {
                        Text(item.knowledgeTitle)
                          .fontSize(15).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium)
                          .margin({ bottom: 1 })
                        Text(item.courseName)
                          .fontSize(11).fontColor(StudyTheme.TEXT_HINT)
                      }
                      .layoutWeight(1).alignItems(HorizontalAlign.Start)
                    }
                    .width('100%')
                    .padding({ top: 12, bottom: 12 })
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

      // ════════════════════════════════
      // FAB 悬浮按钮（毛玻璃质感）
      // ════════════════════════════════
      Column() {
        Column() {
          Text('+')
            .fontSize(28).fontColor('#FFFFFF').fontWeight(FontWeight.Lighter)
        }
        .width(56).height(56)
        .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .backgroundColor('#1F3A5FCC')
        .borderRadius(28)
        .backdropBlur(12)
        .shadow({ radius: 16, color: '#00000040', offsetX: 0, offsetY: 4 })
        .onClick(() => { this.showSheet = true })
        .bindSheet($$this.showSheet, this.SheetContent(), {
          height: SheetSize.MEDIUM,
          backgroundColor: '#1A1A2E',
          showClose: false,
          dragBar: false,
        })
      }
      .width('100%').height('100%')
      .alignItems(HorizontalAlign.End).justifyContent(FlexAlign.End)
      .padding({ right: 20, bottom: 24 })
      .hitTestBehavior(HitTestMode.None)
    }
    .width('100%').height('100%')
    .backgroundColor(StudyTheme.BG)
  }
}
