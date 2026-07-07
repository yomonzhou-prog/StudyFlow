/**
 * StudyFlow OS - 题库页
 * 题目列表，支持筛选和随机刷题
 */

import { router } from '@kit.ArkUI'
import { QuestionBankStore } from '../services/QuestionBankStore'
import { QuestionItem } from '../models/QuestionItem'
import { StudyTheme } from '../common/StudyTheme'
import { StatusBanner } from '../components/StatusBanner'

@Component
export struct QuestionBankPage {
  @State questions: QuestionItem[] = []
  @State courseNames: string[] = []
  @State selectedCourse: string = '全部'
  @State selectedDifficulty: string = '全部'
  @State isLoading: boolean = true

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
    const opts: string[] = ['全部']
    this.courseNames.forEach(n => opts.push(n))
    return opts
  }

  getDifficultyLabel(d: string): string {
    if (d === '全部') return '全部难度'
    if (d === 'easy') return '简单'
    if (d === 'hard') return '困难'
    return '中等'
  }

  getDiffColor(d: string): string {
    if (d === 'easy') return StudyTheme.DIFF_EASY
    if (d === 'hard') return StudyTheme.DIFF_HARD
    return StudyTheme.DIFF_MEDIUM
  }

  build() {
    Column() {
      Text('题库')
        .fontSize(StudyTheme.FONT_LG)
        .fontColor(StudyTheme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_SM })

      StatusBanner()

      // Start random review button
      Row() {
        Text('开始随机刷题')
          .fontSize(StudyTheme.FONT_SM)
          .fontColor(StudyTheme.TEXT_INVERSE)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(42)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(StudyTheme.ACCENT)
      .borderRadius(StudyTheme.RADIUS_MD)
      .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_MD })
      .onClick(() => { router.pushUrl({ url: 'pages/ImmersiveReviewPage' }) })

      // Filters
      Row() {
        ForEach(['全部', 'easy', 'medium', 'hard'], (d: string) => {
          Text(this.getDifficultyLabel(d))
            .fontSize(StudyTheme.FONT_XS)
            .fontColor(this.selectedDifficulty === d ? StudyTheme.ACCENT : StudyTheme.TEXT_HINT)
            .fontWeight(this.selectedDifficulty === d ? FontWeight.Medium : FontWeight.Regular)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(this.selectedDifficulty === d ? StudyTheme.ACCENT_BG : 'transparent')
            .borderRadius(StudyTheme.RADIUS_SM)
            .margin({ right: StudyTheme.SPACE_SM })
            .onClick(() => {
              this.selectedDifficulty = d
              this.applyFilter()
            })
        })
      }
      .width('100%')
      .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_MD })

      // Question list
      if (this.questions.length === 0) {
        Column() {
          Text('暂无匹配的题目')
            .fontSize(StudyTheme.FONT_MD)
            .fontColor(StudyTheme.TEXT_HINT)
            .margin({ top: 80 })
        }
        .width('100%').height('100%')
      } else {
        List() {
          ForEach(this.questions, (question: QuestionItem) => {
            ListItem() {
              Row() {
                Column() {
                  Text(question.question)
                    .fontSize(StudyTheme.FONT_SM)
                    .fontColor(StudyTheme.TEXT_PRIMARY)
                    .fontWeight(FontWeight.Medium)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Row() {
                    Text(question.courseName)
                      .fontSize(StudyTheme.FONT_XS)
                      .fontColor(StudyTheme.TEXT_HINT)
                    Text(this.getDifficultyLabel(question.difficulty))
                      .fontSize(StudyTheme.FONT_XS)
                      .fontColor(this.getDiffColor(question.difficulty))
                      .margin({ left: StudyTheme.SPACE_SM })
                  }
                  .margin({ top: StudyTheme.SPACE_XS })
                }
                .layoutWeight(1)
                Image($r('sys.media.ohos_ic_public_arrow_right'))
                  .width(20).height(20).fillColor(StudyTheme.TEXT_HINT)
              }
              .width('100%')
              .padding(StudyTheme.SPACE_MD)
              .backgroundColor(StudyTheme.CARD_BG)
              .borderRadius(StudyTheme.RADIUS_MD)
              .border({ width: 1, color: StudyTheme.CARD_BORDER })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/QuestionDetailPage',
                  params: { questionId: question.id }
                })
              })
            }
            .margin({ bottom: StudyTheme.SPACE_SM })
          })
        }
        .layoutWeight(1)
        .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(StudyTheme.BG)
  }
}
