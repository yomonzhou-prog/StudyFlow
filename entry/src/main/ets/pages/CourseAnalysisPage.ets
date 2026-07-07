/**
 * StudyFlow OS - 课程解析结果页
 * 展示DeepSeek对课程资料的结构化理解结果
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { CourseStore } from '../services/CourseStore'
import { PlanStore } from '../services/PlanStore'
import { CourseProfile, ChapterStructure, ExamFocus, HomeworkTask, RiskWarning } from '../models/CourseProfile'
import { KnowledgePoint } from '../models/KnowledgePoint'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { SectionHeader } from '../components/SectionHeader'
import { ImportanceTag } from '../components/ImportanceTag'
import { PriorityTag } from '../components/PriorityTag'
import { EmptyState } from '../components/EmptyState'
import { MockData } from '../services/MockData'
import { CourseParserAgent } from '../services/CourseParserAgent'
import { ReviewPlannerAgent } from '../services/ReviewPlannerAgent'
import { PageHeader } from '../components/PageHeader'
import { LoadingView } from '../components/LoadingView'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'
import { MockBanner } from '../components/MockBanner'
import { SectionCard } from '../components/SectionCard'

@Entry
@Component
struct CourseAnalysisPage {
  @State profile: CourseProfile | null = null
  @State isLoading: boolean = true
  @State showAllChapters: boolean = false
  @State showAllKnowledgePoints: boolean = false

  private courseStore: CourseStore = CourseStore.getInstance()
  private planStore: PlanStore = PlanStore.getInstance()
  private materialId: string = ''

  aboutToAppear(): void {
    this.ensureStoreInitialized()

    // 获取路由参数
    const params = router.getParams() as Record<string, Object>
    if (params && params['materialId']) {
      this.materialId = params['materialId'] as string
    }

    this.loadProfile()
  }

  ensureStoreInitialized(): void {
    if (this.courseStore.getMaterials().length === 0) {
      this.courseStore.initMockData()
      this.planStore.initMockData()
    }
  }

  async loadProfile(): Promise<void> {
    // 根据materialId找courseProfile
    let profile = this.courseStore.getProfileByMaterialId(this.materialId)

    if (!profile) {
      // 尝试从material做按需解析
      const material = this.courseStore.getMaterialById(this.materialId)
      if (material) {
        const parseResult = await CourseParserAgent.getInstance().parseCourse(material)
        if (parseResult.data) {
          profile = parseResult.data
          this.courseStore.addProfile(profile)
          this.courseStore.setCurrentProfile(profile)
        }
      }

      // 最终还是没数据，用Mock兜底
      if (!profile) {
        profile = MockData.getSampleProfile_probability()
        this.courseStore.addProfile(profile)
      }
    }

    this.profile = profile
    this.isLoading = false
  }

  async generateReviewCards(): Promise<void> {
    if (!this.profile) return

    const plannerAgent = ReviewPlannerAgent.getInstance()
    const cardResult = await plannerAgent.generateReviewCards(this.profile)
    const taskResult = await plannerAgent.generateStudyTasks(this.profile)

    if (cardResult.data) {
      this.planStore.setReviewCards(cardResult.data)

      const modeLabel = cardResult.isMock ? '本地' : '云端'
      promptAction.showToast({
        message: `${modeLabel}生成 ${cardResult.data.length} 张复习卡片`,
        duration: 2000
      })
    }

    if (taskResult.data) {
      this.planStore.addTasks(taskResult.data)
    }

    router.pushUrl({ url: 'pages/ReviewCardPage' })
  }

  build() {
    Column() {
      PageHeader({ title: '课程解析结果' })

      if (this.isLoading) {
        LoadingView({ message: '正在解析课程资料...' })
      } else if (!this.profile) {
        this.buildNoProfile()
      } else {
        Scroll() {
          Column() {
            // Mock提示
            MockBanner({ mockMessage: '解析结果（演示模式）', apiMessage: '智能解析结果' })

            // 课程名称与摘要
            this.buildSummary()

            // 章节结构
            this.buildChapters()

            // 核心知识点
            this.buildKnowledgePoints()

            // 考试重点
            this.buildExamFocuses()

            // 作业任务
            this.buildHomeworkTasks()

            // 学习风险提醒
            this.buildRiskWarnings()

            // 操作按钮
            Column() {
              PrimaryButton({ label: '🃏 生成复习卡片', onAction: () => { this.generateReviewCards() } })

              SecondaryButton({ label: '🧠 查看知识点结构', onAction: () => { router.pushUrl({ url: 'pages/KnowledgeMapPage' }) } })
                .margin({ top: Theme.SPACING_MD })
            }
            .width('100%')
            .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_XL })
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
  buildSummary() {
    SectionCard({
      content: () => {
        Text(this.profile!.courseName)
          .fontSize(Theme.FONT_XXL)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Bold)

        Text('📖 课程摘要')
          .fontSize(Theme.FONT_MD)
          .fontColor(Theme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .margin({ top: Theme.SPACING_LG })

        Text(this.profile!.summary)
          .fontSize(Theme.FONT_SM)
          .fontColor(Theme.TEXT_SECONDARY)
          .lineHeight(22)
          .margin({ top: Theme.SPACING_SM })
      }
    })
  }

  @Builder
  buildChapters() {
    Column() {
      SectionHeader({ title: '📑 章节结构' })

      Column() {
        ForEach(this.getDisplayChapters(), (chapter: ChapterStructure) => {
          Row() {
            Text(`${chapter.order}. `)
              .fontSize(Theme.FONT_MD)
              .fontColor(Theme.PRIMARY)
              .fontWeight(FontWeight.Bold)

            Column() {
              Text(chapter.title)
                .fontSize(Theme.FONT_MD)
                .fontColor(Theme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)

              Text(chapter.summary)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.TEXT_HINT)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 2 })
            }
            .layoutWeight(1)

            Text(`${chapter.knowledgePointIds.length}个知识点`)
              .fontSize(Theme.FONT_XS)
              .fontColor(Theme.PRIMARY_LIGHT)
              .backgroundColor(Theme.PRIMARY_BG)
              .borderRadius(Theme.RADIUS_SM)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          }
          .width('100%')
          .padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
        })

        if (this.profile!.chapters.length > 3) {
          Text(this.showAllChapters ? '收起' : `查看全部 ${this.profile!.chapters.length} 个章节`)
            .fontSize(Theme.FONT_SM)
            .fontColor(Theme.PRIMARY_LIGHT)
            .margin({ top: Theme.SPACING_SM })
            .onClick(() => { this.showAllChapters = !this.showAllChapters })
        }
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
  buildKnowledgePoints() {
    Column() {
      SectionHeader({
        title: '🧠 核心知识点',
        actionLabel: '查看知识结构 →',
        onAction: () => {
          router.pushUrl({ url: 'pages/KnowledgeMapPage' })
        }
      })

      Column() {
        ForEach(this.getDisplayKnowledgePoints(), (kp: KnowledgePoint) => {
          Row() {
            Column() {
              Text(kp.title)
                .fontSize(Theme.FONT_MD)
                .fontColor(Theme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)

              Text(kp.chapter)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.TEXT_HINT)
                .margin({ top: 2 })
            }
            .layoutWeight(1)

            ImportanceTag({ importance: kp.importance })
          }
          .width('100%')
          .padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
        })

        if (this.profile!.knowledgePoints.length > 4) {
          Text(this.showAllKnowledgePoints ? '收起' : `查看全部 ${this.profile!.knowledgePoints.length} 个知识点`)
            .fontSize(Theme.FONT_SM)
            .fontColor(Theme.PRIMARY_LIGHT)
            .margin({ top: Theme.SPACING_SM })
            .onClick(() => { this.showAllKnowledgePoints = !this.showAllKnowledgePoints })
        }
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
  buildExamFocuses() {
    Column() {
      SectionHeader({ title: '🎯 考试重点' })

      Column() {
        ForEach(this.profile!.examFocuses, (focus: ExamFocus) => {
          Row() {
            ImportanceTag({ importance: focus.importance })

            Column() {
              Text(focus.topic)
                .fontSize(Theme.FONT_MD)
                .fontColor(Theme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .margin({ left: Theme.SPACING_SM })

              Text(focus.description)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.TEXT_HINT)
                .margin({ left: Theme.SPACING_SM, top: 2 })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
        })
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
  buildHomeworkTasks() {
    Column() {
      SectionHeader({ title: '📝 作业任务' })

      Column() {
        ForEach(this.profile!.homeworkTasks, (task: HomeworkTask) => {
          Row() {
            Column() {
              Text(task.title)
                .fontSize(Theme.FONT_MD)
                .fontColor(Theme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)

              Text(task.description)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.TEXT_HINT)
                .margin({ top: 2 })
            }
            .layoutWeight(1)

            PriorityTag({ priority: task.priority })
          }
          .width('100%')
          .padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
        })
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
  buildRiskWarnings() {
    Column() {
      SectionHeader({ title: '⚠ 学习风险提醒' })

      Column() {
        ForEach(this.profile!.riskWarnings, (risk: RiskWarning) => {
          Row() {
            Text(this.getRiskIcon(risk.level))
              .fontSize(20)

            Column() {
              Text(`${risk.message}`)
                .fontSize(Theme.FONT_SM)
                .fontColor(this.getRiskColor(risk.level))
                .fontWeight(FontWeight.Medium)
                .margin({ left: Theme.SPACING_SM })

              Text(`💡 ${risk.suggestion}`)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.TEXT_HINT)
                .margin({ left: Theme.SPACING_SM, top: 2 })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
        })
      }
      .width('100%')
      .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
    }
    .width('100%')
    .backgroundColor(Theme.CARD_BG)
    .borderRadius(Theme.RADIUS_MD)
    .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }

  getDisplayChapters(): ChapterStructure[] {
    if (!this.profile) return []
    return this.showAllChapters
      ? this.profile.chapters
      : this.profile.chapters.slice(0, 3)
  }

  getDisplayKnowledgePoints(): KnowledgePoint[] {
    if (!this.profile) return []
    return this.showAllKnowledgePoints
      ? this.profile.knowledgePoints
      : this.profile.knowledgePoints.slice(0, 4)
  }

  getRiskIcon(level: string): string {
    switch (level) {
      case 'high': return '🔴'
      case 'medium': return '🟡'
      case 'low': return '🟢'
      default: return '⚪'
    }
  }

  getRiskColor(level: string): string {
    switch (level) {
      case 'high': return Theme.DANGER
      case 'medium': return Theme.WARNING
      case 'low': return Theme.SUCCESS
      default: return Theme.TEXT_SECONDARY
    }
  }

  @Builder
  buildNoProfile() {
    Column() {
      EmptyState({ icon: '🔍', message: '未找到课程画像，请先输入课程资料并进行解析' })

      Button('返回输入')
        .fontSize(Theme.FONT_MD)
        .fontColor(Theme.TEXT_INVERSE)
        .backgroundColor(Theme.PRIMARY)
        .borderRadius(Theme.RADIUS_MD)
        .margin({ top: Theme.SPACING_LG })
        .onClick(() => { router.pushUrl({ url: 'pages/CourseInputPage' }) })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
