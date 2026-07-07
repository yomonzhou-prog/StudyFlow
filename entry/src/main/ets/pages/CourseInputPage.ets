/**
 * StudyFlow OS - 课程资料输入页
 * 支持文本输入、示例资料导入、智能解析
 */

import { router } from '@kit.ArkUI'
import { promptAction } from '@kit.ArkUI'
import { CourseStore } from '../services/CourseStore'
import { CourseMaterial } from '../models/CourseMaterial'
import { Constants } from '../common/Constants'
import { Theme } from '../common/Theme'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'
import { MockData } from '../services/MockData'
import { CourseParserAgent } from '../services/CourseParserAgent'
import { PageHeader } from '../components/PageHeader'
import { PrimaryButton } from '../components/AppButton'
import { SecondaryButton } from '../components/AppButton'
import { MockBanner } from '../components/MockBanner'
import { SectionHeader } from '../components/SectionHeader'

interface SelectOption {
  value: string
  label: string
}

@Entry
@Component
struct CourseInputPage {
  @State courseName: string = ''
  @State materialTitle: string = ''
  @State materialType: string = 'textbook'
  @State content: string = ''
  @State showErrors: boolean = false
  @State courseNameError: string = ''
  @State titleError: string = ''
  @State contentError: string = ''
  @State isSubmitting: boolean = false

  private courseStore: CourseStore = CourseStore.getInstance()
  private materialTypes: string[] = Constants.MATERIAL_TYPES

  aboutToAppear(): void {
    this.ensureStoreInitialized()
  }

  ensureStoreInitialized(): void {
    if (this.courseStore.getMaterials().length === 0) {
      this.courseStore.initMockData()
    }
  }

  validate(): boolean {
    let valid = true
    this.courseNameError = ''
    this.titleError = ''
    this.contentError = ''

    if (!this.courseName.trim()) {
      this.courseNameError = '请输入课程名称'
      valid = false
    }
    if (!this.materialTitle.trim()) {
      this.titleError = '请输入资料标题'
      valid = false
    }
    if (!this.content.trim()) {
      this.contentError = '请输入课程资料内容'
      valid = false
    }

    this.showErrors = true
    return valid
  }

  async submitMaterial(): Promise<void> {
    if (!this.validate()) {
      return
    }

    this.isSubmitting = true

    const material: CourseMaterial = {
      id: IdUtils.generate(),
      courseName: this.courseName.trim(),
      title: this.materialTitle.trim(),
      content: this.content.trim(),
      type: this.materialType as 'ppt' | 'textbook' | 'notice' | 'homework' | 'exam' | 'wrong_question',
      createdAt: DateUtils.now()
    }

    this.courseStore.addMaterial(material)

    promptAction.showToast({
      message: '正在整理课程资料...',
      duration: 2000
    })

    // 调用 CourseParserAgent 进行AI解析
    const parserAgent = CourseParserAgent.getInstance()
    const parseResult = await parserAgent.parseCourse(material)

    if (parseResult.data) {
      this.courseStore.addProfile(parseResult.data)
      this.courseStore.setCurrentProfile(parseResult.data)

      const modeLabel = parseResult.isMock ? 'Mock兜底' : '解析完成'
      promptAction.showToast({
        message: `${modeLabel}完成！生成${parseResult.data.knowledgePoints.length}个知识点`,
        duration: 2000
      })
    }

    this.isSubmitting = false

    // 跳转到课程解析页
    router.pushUrl({
      url: 'pages/CourseAnalysisPage',
      params: {
        materialId: material.id
      }
    })
  }

  loadSampleMaterial(): void {
    const sample = MockData.getSampleMaterial_probability()
    this.courseName = sample.courseName
    this.materialTitle = sample.title
    this.materialType = sample.type
    this.content = sample.content
    this.showErrors = false

    promptAction.showToast({
      message: '已加载示例课程资料',
      duration: 1500
    })
  }

  build() {
    Column() {
      PageHeader({ title: '课程资料输入' })

      Scroll() {
        Column() {
          MockBanner({
            mockMessage: '演示模式 — 可直接使用示例资料',
            apiMessage: '在线模式 — 输入课程资料后开始整理'
          })

          // 课程名称
          this.buildInputSection(
            '课程名称 *',
            '例如：概率论与数理统计',
            this.courseName,
            (value: string) => { this.courseName = value },
            this.courseNameError
          )

          // 资料标题
          this.buildInputSection(
            '资料标题 *',
            '例如：第四章 随机变量的数字特征',
            this.materialTitle,
            (value: string) => { this.materialTitle = value },
            this.titleError
          )

          // 资料类型
          this.buildTypeSelector()

          // 资料内容
          Column() {
            Text('课程资料内容 *')
              .fontSize(Theme.FONT_SM)
              .fontColor(Theme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: Theme.SPACING_SM })

            TextArea({ text: this.content, placeholder: '请粘贴课程资料文本，支持PPT讲义、教材内容、老师通知、作业要求、考试范围、错题记录等...' })
              .height(180)
              .fontSize(Theme.FONT_SM)
              .backgroundColor(Theme.BG)
              .borderRadius(Theme.RADIUS_MD)
              .padding(Theme.SPACING_MD)
              .onChange((value: string) => {
                this.content = value
              })

            if (this.showErrors && this.contentError) {
              Text(this.contentError)
                .fontSize(Theme.FONT_XS)
                .fontColor(Theme.DANGER)
                .margin({ top: Theme.SPACING_XS })
            }
          }
          .width('100%')
          .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })

          // 操作按钮
          Column() {
            SecondaryButton({ label: '📥 使用示例资料', onAction: () => { this.loadSampleMaterial() } })
            PrimaryButton({
              label: this.isSubmitting ? '解析中...' : '📋 开始整理',
              isEnabled: !this.isSubmitting,
              onAction: () => { this.submitMaterial() }
            })
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
    .width('100%')
    .height('100%')
    .backgroundColor(Theme.BG)
  }

  @Builder
  buildInputSection(label: string, placeholder: string, value: string, onChange: (value: string) => void, errorMsg: string) {
    Column() {
      Text(label)
        .fontSize(Theme.FONT_SM)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: Theme.SPACING_SM })

      TextInput({ text: value, placeholder: placeholder })
        .fontSize(Theme.FONT_MD)
        .backgroundColor(Theme.BG)
        .borderRadius(Theme.RADIUS_MD)
        .padding(Theme.SPACING_MD)
        .onChange(onChange)

      if (this.showErrors && errorMsg) {
        Text(errorMsg)
          .fontSize(Theme.FONT_XS)
          .fontColor(Theme.DANGER)
          .margin({ top: Theme.SPACING_XS })
      }
    }
    .width('100%')
    .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }

  @Builder
  buildTypeSelector() {
    Column() {
      Text('资料类型 *')
        .fontSize(Theme.FONT_SM)
        .fontColor(Theme.TEXT_PRIMARY)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: Theme.SPACING_SM })

      Select(this.materialTypes.map((t: string): SelectOption => {
        const opt: SelectOption = { value: t, label: Constants.MATERIAL_TYPE_LABELS[t] || t }
        return opt
      }))
        .value(this.materialType)
        .selected(this.materialType === this.materialTypes[0] ? 0 : undefined)
        .onSelect((index: number) => {
          this.materialType = this.materialTypes[index]
        })
        .backgroundColor(Theme.BG)
        .borderRadius(Theme.RADIUS_MD)
        .width('100%')
    }
    .width('100%')
    .padding({ left: Theme.SPACING_LG, right: Theme.SPACING_LG, top: Theme.SPACING_MD })
  }
}
