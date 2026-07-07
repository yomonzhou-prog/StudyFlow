/**
 * StudyFlow OS - 知识点结构页
 * 使用章节分组 + 知识点卡片展示知识结构（非复杂图谱）
 */

import { router } from '@kit.ArkUI'
import { CourseStore } from '../services/CourseStore'
import { PlanStore } from '../services/PlanStore'
import { CourseProfile, ChapterStructure } from '../models/CourseProfile'
import { KnowledgePoint } from '../models/KnowledgePoint'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { SectionHeader } from '../components/SectionHeader'
import { KnowledgePointCard } from '../components/KnowledgePointCard'
import { EmptyState } from '../components/EmptyState'
import { MockData } from '../services/MockData'
import { PageHeader } from '../components/PageHeader'
import { LoadingView } from '../components/LoadingView'
import { MockBanner } from '../components/MockBanner'
import { ChipSelector, ChipOption } from '../components/ChipSelector'

@Entry
@Component
struct KnowledgeMapPage {
  @State profile: CourseProfile | null = null
  @State selectedChapter: string = 'all'
  @State isLoading: boolean = true

  private courseStore: CourseStore = CourseStore.getInstance()
  private planStore: PlanStore = PlanStore.getInstance()

  aboutToAppear(): void {
    this.loadData()
  }

  loadData(): void {
    // 确保存储已初始化
    if (this.courseStore.getProfiles().length === 0) {
      this.courseStore.initMockData()
      this.planStore.initMockData()
    }

    this.profile = this.courseStore.getCurrentProfile()

    // 如果当前没有profile，使用mock
    if (!this.profile) {
      const mockProfile = MockData.getSampleProfile_probability()
      this.courseStore.addProfile(mockProfile)
      this.courseStore.setCurrentProfile(mockProfile)
      this.profile = mockProfile
    }

    this.isLoading = false
  }

  getFilteredKnowledgePoints(): KnowledgePoint[] {
    if (!this.profile) return []
    if (this.selectedChapter === 'all') {
      return this.profile.knowledgePoints
    }
    return this.profile.knowledgePoints.filter(kp => kp.chapter === this.selectedChapter)
  }

  getChapters(): string[] {
    if (!this.profile) return []
    return ['all', ...this.profile.chapters.map(c => c.title)]
  }

  getChapterLabel(title: string): string {
    if (title === 'all') return '全部'
    return title
  }

  getChapterKnowledgePointCount(title: string): number {
    if (!this.profile) return 0
    if (title === 'all') return this.profile.knowledgePoints.length
    const chapter = this.profile.chapters.find(c => c.title === title)
    return chapter ? chapter.knowledgePointIds.length : 0
  }

  handleKpCardClick(kp: KnowledgePoint): void {
    // 跳转到复习卡片页
    router.pushUrl({ url: 'pages/ReviewCardPage' })
  }

  build() {
    Column() {
      PageHeader({ title: '知识点结构' })

      if (this.isLoading) {
        LoadingView({ message: '加载知识点...' })
      } else if (!this.profile || this.profile.knowledgePoints.length === 0) {
        Column() {
          EmptyState({ icon: '📭', message: '暂无知识点数据' })
        }
        .width('100%').height('100%').justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            MockBanner({ mockMessage: 'Mock模式 — 知识点结构（分组卡片）', apiMessage: '解析 — 知识点结构' })

            // 课程名
            Text(this.profile.courseName)
              .fontSize(Theme.FONT_XL)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
              .textAlign(TextAlign.Start)

            Text('知识结构（按章节分组）')
              .fontSize(Theme.FONT_XS)
              .fontColor(Theme.TEXT_HINT)
              .width('100%')
              .padding({ left: Theme.SPACING_LG })
              .textAlign(TextAlign.Start)

            ChipSelector({
              options: this.getChapters().map((ch: string): ChipOption => ({
                value: ch,
                label: this.getChapterLabel(ch),
                count: this.getChapterKnowledgePointCount(ch)
              })),
              selectedValue: this.selectedChapter,
              onSelect: (value: string) => { this.selectedChapter = value }
            })
              .margin({ top: Theme.SPACING_MD })

            // 知识点统计
            Row() {
              Text(`共 ${this.getFilteredKnowledgePoints().length} 个知识点`)
                .fontSize(Theme.FONT_SM)
                .fontColor(Theme.TEXT_SECONDARY)

              Blank()

              // 关键-核心考点统计
              Text(`核心: ${this.getFilteredKnowledgePoints().filter(k => k.importance === 'critical').length}`)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.IMPORTANCE_CRITICAL_COLOR)
                .backgroundColor('#2A2520')
                .borderRadius(Theme.RADIUS_SM)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })

              Text(`重要: ${this.getFilteredKnowledgePoints().filter(k => k.importance === 'high').length}`)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.IMPORTANCE_HIGH_COLOR)
                .backgroundColor(Theme.DANGER_BG)
                .borderRadius(Theme.RADIUS_SM)
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .margin({ left: Theme.SPACING_XS })
            }
            .width('100%')
            .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD, bottom: Theme.SPACING_SM })

            // 知识点卡片列表
            Column() {
              if (this.getFilteredKnowledgePoints().length === 0) {
                EmptyState({ icon: '🔍', message: '该章节暂无知识点' })
              } else {
                ForEach(this.getFilteredKnowledgePoints(), (kp: KnowledgePoint) => {
                  Column() {
                    KnowledgePointCard({
                      knowledgePoint: kp,
                      onCardClick: () => { this.handleKpCardClick(kp) }
                    })
                  }
                  .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
                })
              }
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
}
