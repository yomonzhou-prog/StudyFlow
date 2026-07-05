/**
 * StudyFlow OS - 题库页
 * 展示题目列表，支持按课程/难度筛选
 */

import { router } from '@kit.ArkUI'
import { QuestionBankStore } from '../services/QuestionBankStore'
import { QuestionItem } from '../models/QuestionItem'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { PageHeader } from '../components/PageHeader'
import { LoadingView } from '../components/LoadingView'
import { PrimaryButton } from '../components/AppButton'
import { SectionHeader } from '../components/SectionHeader'
import { DifficultyTag } from '../components/DifficultyTag'
import { EmptyState } from '../components/EmptyState'

@Component
export struct QuestionBankPage {
  @State questions: QuestionItem[] = []
  @State courseNames: string[] = []
  @State selectedCourse: string = '全部'
  @State selectedDifficulty: string = '全部'
  @State isLoading: boolean = true
  @State showCourseFilter: boolean = false
  @State showDifficultyFilter: boolean = false

  private questionBankStore: QuestionBankStore = QuestionBankStore.getInstance()

  aboutToAppear(): void {
    this.questionBankStore.initMockData()
    this.courseNames = this.questionBankStore.getCourseNames()
    this.applyFilter()
    this.isLoading = false
  }

  applyFilter(): void {
    let result = this.questionBankStore.getQuestions()

    if (this.selectedCourse !== '全部') {
      result = result.filter(q => q.courseName === this.selectedCourse)
    }
    if (this.selectedDifficulty !== '全部') {
      result = result.filter(q => q.difficulty === this.selectedDifficulty)
    }

    this.questions = result
  }

  getCourseFilterOptions(): string[] {
    const options: string[] = ['全部']
    this.courseNames.forEach(name => options.push(name))
    return options
  }

  getDifficultyFilterOptions(): string[] {
    return ['全部', 'easy', 'medium', 'hard']
  }

  getDifficultyLabel(diff: string): string {
    if (diff === '全部') return '全部难度'
    return Constants.DIFFICULTY_LABELS[diff] || diff
  }

  getCourseLabel(name: string): string {
    if (name === '全部') return '全部课程'
    return name
  }

  build() {
    Column() {
      if (this.isLoading) {
        LoadingView({ message: '加载题库...' })
      } else {
        Column() {
          PageHeader({ title: '题库' })

          // 筛选栏
          Row() {
            Row() {
              Text(this.getCourseLabel(this.selectedCourse))
                .fontSize(Theme.FONT_SM)
                .fontColor(Theme.TEXT_PRIMARY)
              Image($r('sys.media.ohos_ic_public_arrow_down'))
                .width(16).height(16).fillColor(Theme.TEXT_HINT).margin({ left: 4 })
            }
            .padding({ left: Theme.SPACING_MD, right: Theme.SPACING_MD, top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
            .backgroundColor(Theme.CARD_BG)
            .borderRadius(Theme.RADIUS_XL)
            .onClick(() => { this.showCourseFilter = !this.showCourseFilter })

            Row() {
              Text(this.getDifficultyLabel(this.selectedDifficulty))
                .fontSize(Theme.FONT_SM)
                .fontColor(Theme.TEXT_PRIMARY)
              Image($r('sys.media.ohos_ic_public_arrow_down'))
                .width(16).height(16).fillColor(Theme.TEXT_HINT).margin({ left: 4 })
            }
            .padding({ left: Theme.SPACING_MD, right: Theme.SPACING_MD, top: Theme.SPACING_SM, bottom: Theme.SPACING_SM })
            .backgroundColor(Theme.CARD_BG)
            .borderRadius(Theme.RADIUS_XL)
            .margin({ left: Theme.SPACING_SM })
            .onClick(() => { this.showDifficultyFilter = !this.showDifficultyFilter })

            Blank()

            Text(`${this.questions.length} 题`)
              .fontSize(Theme.FONT_XS)
              .fontColor(Theme.TEXT_HINT)
          }
          .width('100%')
          .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, bottom: Theme.SPACING_MD })

          // 课程筛选下拉
          if (this.showCourseFilter) {
            Column() {
              ForEach(this.getCourseFilterOptions(), (option: string) => {
                Text(this.getCourseLabel(option))
                  .fontSize(Theme.FONT_SM)
                  .fontColor(this.selectedCourse === option ? Theme.PRIMARY : Theme.TEXT_PRIMARY)
                  .fontWeight(this.selectedCourse === option ? FontWeight.Bold : FontWeight.Regular)
                  .padding(Theme.SPACING_MD)
                  .width('100%')
                  .onClick(() => {
                    this.selectedCourse = option
                    this.showCourseFilter = false
                    this.applyFilter()
                  })
              })
            }
            .backgroundColor(Theme.CARD_BG)
            .borderRadius(Theme.RADIUS_MD)
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, bottom: Theme.SPACING_SM })
          }

          // 难度筛选下拉
          if (this.showDifficultyFilter) {
            Column() {
              ForEach(this.getDifficultyFilterOptions(), (option: string) => {
                Text(this.getDifficultyLabel(option))
                  .fontSize(Theme.FONT_SM)
                  .fontColor(this.selectedDifficulty === option ? Theme.PRIMARY : Theme.TEXT_PRIMARY)
                  .fontWeight(this.selectedDifficulty === option ? FontWeight.Bold : FontWeight.Regular)
                  .padding(Theme.SPACING_MD)
                  .width('100%')
                  .onClick(() => {
                    this.selectedDifficulty = option
                    this.showDifficultyFilter = false
                    this.applyFilter()
                  })
              })
            }
            .backgroundColor(Theme.CARD_BG)
            .borderRadius(Theme.RADIUS_MD)
            .margin({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, bottom: Theme.SPACING_SM })
          }

          // 题目列表
          if (this.questions.length === 0) {
            EmptyState({ icon: '📝', message: '暂无匹配的题目' })
          } else {
            List() {
              ForEach(this.questions, (question: QuestionItem) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(question.question)
                        .fontSize(Theme.FONT_MD)
                        .fontColor(Theme.TEXT_PRIMARY)
                        .fontWeight(FontWeight.Medium)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Row() {
                        Text(question.courseName)
                          .fontSize(Theme.FONT_XS)
                          .fontColor(Theme.TEXT_SECONDARY)
                        DifficultyTag({ difficulty: question.difficulty })
                          .margin({ left: Theme.SPACING_SM })
                      }
                      .margin({ top: Theme.SPACING_XS })
                    }
                    .layoutWeight(1)
                    Image($r('sys.media.ohos_ic_public_arrow_right'))
                      .width(20).height(20).fillColor(Theme.TEXT_HINT)
                  }
                  .width('100%')
                  .padding(Theme.SPACING_MD)
                  .backgroundColor(Theme.CARD_BG)
                  .borderRadius(Theme.RADIUS_MD)
                  .onClick(() => {
                    router.pushUrl({
                      url: 'pages/QuestionDetailPage',
                      params: { questionId: question.id }
                    })
                  })
                }
                .margin({ bottom: Theme.SPACING_SM })
              })
            }
            .layoutWeight(1)
            .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG })
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.BG)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }
}
