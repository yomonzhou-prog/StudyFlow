/**
 * StudyFlow OS - 考试倒计时管理页
 * 查看考试倒计时，支持粘贴考试安排文本
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { ExamStore } from '../services/ExamStore'
import { ExamSchedule } from '../models/ExamSchedule'
import { StudyTheme } from '../common/StudyTheme'
import { StatusBanner } from '../components/StatusBanner'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

@Entry
@Component
struct ExamSchedulePage {
  @State exams: ExamSchedule[] = []
  @State showInput: boolean = false
  @State inputText: string = ''
  @State isParsing: boolean = false

  private examStore: ExamStore = ExamStore.getInstance()

  aboutToAppear(): void {
    this.examStore.initMockData()
    this.exams = this.examStore.getExamsByPriority()
  }

  handleParseExamText(): void {
    const text = this.inputText.trim()
    if (!text) {
      promptAction.showToast({ message: '请输入考试安排文本', duration: 1500 })
      return
    }

    this.isParsing = true

    // Parse locally: simple line-by-line extraction
    // Format: CourseName YYYY-MM-DD HH:MM-HH:MM [Location]
    const lines = text.split('\n').filter(l => l.trim())
    for (const line of lines) {
      const parts = line.trim().split(/\s+/)
      if (parts.length >= 2) {
        const courseName = parts[0]
        const dateStr = parts[1]
        const timeStr = parts.length >= 3 ? parts[2] : '09:00-11:00'
        const location = parts.length >= 4 ? parts.slice(3).join(' ') : ''

        // Calculate days left dynamically
        const daysLeft = ExamStore.getDaysLeft(dateStr)

        const exam: ExamSchedule = {
          id: IdUtils.generate(),
          courseName: courseName,
          examDate: dateStr,
          examTime: timeStr,
          location: location,
          daysLeft: daysLeft,
          priority: daysLeft <= 3 ? 'high' : daysLeft <= 7 ? 'medium' : 'low',
          topics: '',
          suggestedFocus: daysLeft <= 7 ? '优先复习老师强调的重点和错题本中的内容' : '按复习计划正常推进',
          createdAt: DateUtils.now()
        }
        this.exams.push(exam)
      }
    }

    this.isParsing = false
    this.showInput = false
    this.inputText = ''
    promptAction.showToast({ message: `已识别 ${lines.length} 门考试`, duration: 1500 })
  }

  getCountdownText(days: number): string {
    if (days === 0) return '今天考试'
    if (days === 1) return '明天考试'
    return `还剩 ${days} 天`
  }

  getPriorityLabel(priority: string): string {
    if (priority === 'high') return '临近'
    if (priority === 'medium') return '适中'
    return '充裕'
  }

  getPriorityColor(priority: string): string {
    if (priority === 'high') return StudyTheme.DANGER
    if (priority === 'medium') return StudyTheme.WARNING
    return StudyTheme.TEXT_HINT
  }

  build() {
    Column() {
      // Header
      Row() {
        Image($r('sys.media.ohos_ic_public_arrow_left'))
          .width(24).height(24)
          .fillColor(StudyTheme.TEXT_PRIMARY)
          .onClick(() => { router.back() })

        Text('考试倒计时')
          .fontSize(StudyTheme.FONT_LG)
          .fontColor(StudyTheme.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('添加')
          .fontSize(StudyTheme.FONT_SM)
          .fontColor(StudyTheme.ACCENT)
          .onClick(() => { this.showInput = !this.showInput })
      }
      .width('100%')
      .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_MD })

      StatusBanner()

      Scroll() {
        Column() {
          // Input area
          if (this.showInput) {
            Column() {
              Text('粘贴考试安排文本')
                .fontSize(StudyTheme.FONT_SM)
                .fontColor(StudyTheme.TEXT_SECONDARY)
                .margin({ bottom: StudyTheme.SPACE_SM })

              Text('示例格式：\n概率论与数理统计 2026-07-10 09:00-11:00 教学楼A201\n数据结构 2026-07-13 14:30-16:30 实验楼B102')
                .fontSize(StudyTheme.FONT_XS)
                .fontColor(StudyTheme.TEXT_HINT)
                .margin({ bottom: StudyTheme.SPACE_MD })
                .lineHeight(18)

              TextArea({ text: this.inputText, placeholder: '请粘贴从截图识别的考试安排文字...' })
                .height(120)
                .fontSize(StudyTheme.FONT_SM)
                .backgroundColor(StudyTheme.BG)
                .borderRadius(StudyTheme.RADIUS_MD)
                .padding(StudyTheme.SPACE_MD)
                .onChange((value: string) => { this.inputText = value })

              Row() {
                Row() {
                  Text('取消')
                    .fontSize(StudyTheme.FONT_SM)
                    .fontColor(StudyTheme.TEXT_SECONDARY)
                    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                }
                .onClick(() => { this.showInput = false })

                Row() {
                  Text(this.isParsing ? '解析中...' : '确认添加')
                    .fontSize(StudyTheme.FONT_SM)
                    .fontColor('#FFFFFF')
                    .padding({ left: 20, right: 20, top: 8, bottom: 8 })
                    .backgroundColor(this.isParsing ? StudyTheme.TEXT_HINT : StudyTheme.ACCENT)
                    .borderRadius(StudyTheme.RADIUS_FULL)
                }
                .onClick(() => { this.handleParseExamText() })
                .margin({ left: StudyTheme.SPACE_MD })

                Blank()
              }
              .width('100%')
              .margin({ top: StudyTheme.SPACE_MD })

              Text('当前版本支持粘贴截图中的文字内容，OCR 拍照识别功能开发中')
                .fontSize(StudyTheme.FONT_XS)
                .fontColor(StudyTheme.TEXT_HINT)
                .margin({ top: StudyTheme.SPACE_MD })
            }
            .width('100%')
            .padding(StudyTheme.SPACE_LG)
            .backgroundColor(StudyTheme.CARD_BG)
            .borderRadius(StudyTheme.RADIUS_LG)
            .border({ width: 1, color: StudyTheme.CARD_BORDER })
            .margin({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, bottom: StudyTheme.SPACE_LG })
          }

          // Exam list
          if (this.exams.length === 0) {
            Text('暂无考试安排')
              .fontSize(StudyTheme.FONT_MD)
              .fontColor(StudyTheme.TEXT_HINT)
              .margin({ top: 80 })
          }

          ForEach(this.exams, (exam: ExamSchedule) => {
            Column() {
              Row() {
                // Countdown
                Column() {
                  Text(this.getCountdownText(ExamStore.getDaysLeft(exam.examDate)))
                    .fontSize(StudyTheme.FONT_LG)
                    .fontColor(StudyTheme.TEXT_PRIMARY)
                    .fontWeight(FontWeight.Bold)
                  Text(exam.examDate)
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.TEXT_HINT)
                    .margin({ top: 2 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Column() {
                  Text(this.getPriorityLabel(exam.priority))
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(this.getPriorityColor(exam.priority))
                    .fontWeight(FontWeight.Medium)
                }
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .border({ width: 1, color: this.getPriorityColor(exam.priority) })
                .borderRadius(StudyTheme.RADIUS_SM)
              }
              .width('100%')

              Text(exam.courseName)
                .fontSize(StudyTheme.FONT_MD)
                .fontColor(StudyTheme.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .margin({ top: StudyTheme.SPACE_SM })

              Row() {
                Text(exam.examTime)
                  .fontSize(StudyTheme.FONT_XS)
                  .fontColor(StudyTheme.TEXT_HINT)
                if (exam.location) {
                  Text(`· ${exam.location}`)
                    .fontSize(StudyTheme.FONT_XS)
                    .fontColor(StudyTheme.TEXT_HINT)
                }
              }
              .margin({ top: 4 })

              if (exam.suggestedFocus) {
                Text(exam.suggestedFocus)
                  .fontSize(StudyTheme.FONT_XS)
                  .fontColor(StudyTheme.TEXT_SECONDARY)
                  .margin({ top: StudyTheme.SPACE_SM })
                  .maxLines(2)
              }
            }
            .width('100%')
            .padding(StudyTheme.SPACE_LG)
            .backgroundColor(StudyTheme.CARD_BG)
            .borderRadius(StudyTheme.RADIUS_LG)
            .border({ width: 1, color: StudyTheme.CARD_BORDER })
            .margin({
              left: StudyTheme.PAGE_PAD,
              right: StudyTheme.PAGE_PAD,
              bottom: StudyTheme.SPACE_MD
            })
          })

          Column().height(40)
        }
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(StudyTheme.BG)
  }
}
