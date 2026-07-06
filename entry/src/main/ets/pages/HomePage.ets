/**
 * StudyFlow OS - 期末复习首页
 * 三大复习场景入口 + 考试倒计时 + 今日复习 + 优先级 + 统计
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
        allKps
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
  getStatusLine(): string {
    const p = this.todayCardCount - this.reviewedCount
    return p > 0 ? `今天还有 ${p} 张卡片待复习` : '今天的复习已完成'
  }


  build() {
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

            // ═══ 问候语 ═══
            Column() {
              Text(this.getGreeting()).fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_HINT)
              Row() {
                Text(`${this.getUserName()}，`).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
                Text(this.getStatusLine()).fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_SECONDARY).layoutWeight(1).maxLines(1)
              }
              .width('100%').margin({ top: StudyTheme.SPACE_XS }).alignItems(VerticalAlign.Bottom)
            }
            .width('100%').alignItems(HorizontalAlign.Start)
            .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_LG })

            // ══════════════════════════════════════
            // 三大复习场景入口
            // ══════════════════════════════════════
            Column() {
              Text('选择你的复习起点')
                .fontSize(StudyTheme.FONT_SM)
                .fontColor(StudyTheme.TEXT_HINT)
                .fontWeight(FontWeight.Medium)
                .width('100%')
                .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_MD })

              // ── 场景一：有题库 ──
              Row() {
                // 左侧图标区
                Column() {
                  Text('📄')
                    .fontSize(32)
                    .width(56).height(56)
                    .textAlign(TextAlign.Center)
                    .backgroundColor('#E8F0FE')
                    .borderRadius(16)
                }
                .margin({ right: StudyTheme.SPACE_MD })

                // 中间文字
                Column() {
                  Text('有考试题库')
                    .fontSize(StudyTheme.FONT_MD)
                    .fontColor(StudyTheme.TEXT_PRIMARY)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 2 })
                  Text('老师发了明确的复习题或试卷，拍下来/上传 PDF，AI 自动拆成一题一卡')
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.TEXT_SECONDARY)
                    .lineHeight(18)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                // 右侧箭头
                Text('→')
                  .fontSize(20)
                  .fontColor(StudyTheme.ACCENT)
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .padding(StudyTheme.SPACE_MD)
              .backgroundColor(StudyTheme.CARD_BG)
              .borderRadius(StudyTheme.RADIUS_LG)
              .border({ width: 1.5, color: '#D0E0F5' })
              .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_SM })
              .onClick(() => { router.pushUrl({ url: 'pages/FileImportPage' }) })

              // ── 场景二：有重点 ──
              Row() {
                Column() {
                  Text('📝')
                    .fontSize(32)
                    .width(56).height(56)
                    .textAlign(TextAlign.Center)
                    .backgroundColor('#E8F5E9')
                    .borderRadius(16)
                }
                .margin({ right: StudyTheme.SPACE_MD })

                Column() {
                  Text('老师画了重点')
                    .fontSize(StudyTheme.FONT_MD)
                    .fontColor(StudyTheme.TEXT_PRIMARY)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 2 })
                  Text('上传课本或知识点总结 + 告诉 AI 老师划的重点，生成知识图谱和发散题卡')
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.TEXT_SECONDARY)
                    .lineHeight(18)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Text('→')
                  .fontSize(20)
                  .fontColor('#2E7D32')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .padding(StudyTheme.SPACE_MD)
              .backgroundColor(StudyTheme.CARD_BG)
              .borderRadius(StudyTheme.RADIUS_LG)
              .border({ width: 1.5, color: '#C8E6C9' })
              .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_SM })
              .onClick(() => { router.pushUrl({ url: 'pages/KnowledgeGraphPage' }) })

              // ── 场景三：只有范围 ──
              Row() {
                Column() {
                  Text('🤖')
                    .fontSize(32)
                    .width(56).height(56)
                    .textAlign(TextAlign.Center)
                    .backgroundColor('#FFF3E0')
                    .borderRadius(16)
                }
                .margin({ right: StudyTheme.SPACE_MD })

                Column() {
                  Text('只有考试范围')
                    .fontSize(StudyTheme.FONT_MD)
                    .fontColor(StudyTheme.TEXT_PRIMARY)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 2 })
                  Text('老师只说了考什么范围。告诉 AI 教练课程和考试时间，帮你制定每日复习计划')
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.TEXT_SECONDARY)
                    .lineHeight(18)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Text('→')
                  .fontSize(20)
                  .fontColor('#E65100')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .padding(StudyTheme.SPACE_MD)
              .backgroundColor(StudyTheme.CARD_BG)
              .borderRadius(StudyTheme.RADIUS_LG)
              .border({ width: 1.5, color: '#FFE0B2' })
              .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_LG })
              .onClick(() => { router.pushUrl({ url: 'pages/CoachPlannerPage' }) })
            }
            .width('100%')

            // ═══ 考试倒计时 ═══
            if (this.nearestExam) {
              Column() {
                Row() {
                  Column() {
                    Text(ExamStore.getDaysLeft(this.nearestExam.examDate).toString()).fontSize(36).fontColor(StudyTheme.ACCENT).fontWeight(FontWeight.Bold)
                    Text('天').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
                  }
                  .width(72).height(72).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
                  .border({ width: 2, color: StudyTheme.ACCENT }).borderRadius(StudyTheme.RADIUS_FULL)
                  Column() {
                    Text(this.nearestExam.courseName).fontSize(StudyTheme.FONT_LG).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium)
                    Text(`${this.nearestExam.examDate} ${this.nearestExam.examTime}`).fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 4 })
                    Text(this.nearestExam.suggestedFocus).fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_SECONDARY).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).margin({ top: 6 })
                  }
                  .layoutWeight(1).margin({ left: StudyTheme.SPACE_LG }).alignItems(HorizontalAlign.Start)
                }
                .width('100%').padding(StudyTheme.SPACE_LG).backgroundColor(StudyTheme.CARD_BG).borderRadius(StudyTheme.RADIUS_LG).border({ width: 1, color: StudyTheme.CARD_BORDER })
              }
              .width('100%').padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD }).margin({ bottom: StudyTheme.SPACE_MD })
              .onClick(() => { router.pushUrl({ url: 'pages/ExamSchedulePage' }) })
            }

            // ═══ 开始今日复习 ═══
            Row() {
              Column() {
                Text('开始今日复习').fontSize(StudyTheme.FONT_XL).fontColor(StudyTheme.TEXT_INVERSE).fontWeight(FontWeight.Bold)
                Text(`${this.todayCardCount} 张卡片 · 约 ${Math.round(this.todayCardCount * 2)} 分钟`).fontSize(StudyTheme.FONT_SM).fontColor('#D0D6E0').margin({ top: 4 })
              }
              .layoutWeight(1).alignItems(HorizontalAlign.Start)
              Text('>').fontSize(24).fontColor('#FFFFFF').opacity(0.7)
            }
            .width('100%').height(80).padding({ left: StudyTheme.SPACE_XL, right: StudyTheme.SPACE_XL })
            .backgroundColor(StudyTheme.ACCENT).borderRadius(StudyTheme.RADIUS_LG).alignItems(VerticalAlign.Center)
            .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_XL })
            .onClick(() => { router.pushUrl({ url: 'pages/ImmersiveReviewPage' }) })

            // ═══ 复习优先级 ═══
            Column() {
              Text('复习优先级').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_HINT).fontWeight(FontWeight.Medium).margin({ bottom: StudyTheme.SPACE_MD })
              if (this.priorities.length === 0) {
                Text('暂无数据，导入课程资料后自动生成').fontSize(StudyTheme.FONT_SM).fontColor(StudyTheme.TEXT_HINT).padding(StudyTheme.SPACE_XL)
              } else {
                ForEach(this.priorities.slice(0, 3), (item: ReviewPriority) => {
                  Column() {
                    Row() {
                      Column() {
                        Text(item.knowledgeTitle).fontSize(StudyTheme.FONT_MD).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Medium)
                        Text(item.courseName).fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
                      }
                      .layoutWeight(1).alignItems(HorizontalAlign.Start)
                      Column() {
                        Text(item.level === 'high' ? '高' : item.level === 'medium' ? '中' : '低')
                          .fontSize(StudyTheme.FONT_XS).fontColor('#FFFFFF').fontWeight(FontWeight.Bold)
                      }
                      .width(28).height(28).borderRadius(14)
                      .backgroundColor(item.level === 'high' ? StudyTheme.PRIORITY_HIGH : item.level === 'medium' ? StudyTheme.PRIORITY_MEDIUM : StudyTheme.PRIORITY_LOW)
                      .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
                    }
                    .width('100%')
                    if (item.reasons.length > 0) {
                      Row() {
                        Text(item.reasons.join(' · ')).fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_SECONDARY)
                        Text(item.suggestedAction).fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ left: StudyTheme.SPACE_SM })
                      }
                      .width('100%').margin({ top: StudyTheme.SPACE_SM })
                    }
                  }
                  .width('100%').padding(StudyTheme.SPACE_MD).backgroundColor(StudyTheme.CARD_BG).borderRadius(StudyTheme.RADIUS_MD).border({ width: 1, color: StudyTheme.CARD_BORDER }).margin({ bottom: StudyTheme.SPACE_SM })
                })
              }
            }
            .width('100%').padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD }).margin({ bottom: StudyTheme.SPACE_XL })

            // ═══ 统计 ═══
            Row() {
              Column() {
                Text(this.reviewedCount.toString()).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
                Text('已复习').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              Column() {
                Text(this.wrongCount.toString()).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
                Text('错题').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
              Column() {
                Text(`${this.streakDays}`).fontSize(StudyTheme.FONT_XXL).fontColor(StudyTheme.TEXT_PRIMARY).fontWeight(FontWeight.Bold)
                Text('连续天数').fontSize(StudyTheme.FONT_XS).fontColor(StudyTheme.TEXT_HINT).margin({ top: 2 })
              }.layoutWeight(1).alignItems(HorizontalAlign.Center)
            }
            .width('100%').padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD })
            Column().height(40)
          }
          .width('100%')
        }
        .scrollBar(BarState.Off).layoutWeight(1)
      }
    }
    .width('100%').height('100%').backgroundColor(StudyTheme.BG)
  }
}
