/**
 * StudyFlow OS — 每日学习计划打卡组件（场景三附属组件）
 *
 * 渲染后端 AI 规划教练返回的 StudyTaskDTO 列表，
 * 以天为单位分组展示，支持任务状态勾选/取消。
 */

import { StudyTheme } from '../common/StudyTheme'
import { StudyTaskDTO } from '../services/ApiClient'
import { PlanStore } from '../services/PlanStore'
import { StudyTask } from '../models/StudyTask'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

// ─── 按天分组 ───

interface DayGroup {
  dayIndex: number
  dateLabel: string
  tasks: StudyTaskDTO[]
}

function groupByDay(tasks: StudyTaskDTO[]): DayGroup[] {
  const map = new Map<number, StudyTaskDTO[]>()
  for (const t of tasks) {
    const list = map.get(t.day_index) || []
    list.push(t)
    map.set(t.day_index, list)
  }
  const groups: DayGroup[] = []
  const sorted = Array.from(map.keys()).sort((a, b) => a - b)
  for (const day of sorted) {
    const dayTasks = map.get(day) || []
    groups.push({
      dayIndex: day,
      dateLabel: dayTasks[0]?.date_label || `第${day}天`,
      tasks: dayTasks,
    })
  }
  return groups
}

// ─── 组件 ───

@Component
export struct StudyPlanCard {
  @Prop tasks: StudyTaskDTO[] = []
  @Prop summary: string = ''
  @State completedIds: Set<string> = new Set()
  @State expandedDay: number = 1  // 默认展开第一天
  private planStore: PlanStore = PlanStore.getInstance()

  aboutToAppear(): void {
    // 将 AI 返回的计划静默写入 PlanStore
    this.syncToStore()
  }

  // ─── 静默写入本地 Store ───

  syncToStore(): void {
    const storeTasks: StudyTask[] = []
    for (let i = 0; i < this.tasks.length; i++) {
      const dto: StudyTaskDTO = this.tasks[i]
      const task: StudyTask = {
        id: dto.id,
        title: dto.title,
        courseName: dto.course_name,
        description: dto.description,
        priority: dto.priority,
        estimatedMinutes: dto.estimated_minutes,
        deadline: DateUtils.daysLater(dto.day_index),
        status: 'pending',
        sourceType: 'planner',
        relatedKnowledgePointIds: dto.knowledge_points,
        createdAt: DateUtils.now(),
      }
      storeTasks.push(task)
    }

    for (let i = 0; i < storeTasks.length; i++) {
      this.planStore.addTask(storeTasks[i])
    }
  }

  // ─── 切换完成状态 ───

  toggleTask(taskId: string): void {
    if (this.completedIds.has(taskId)) {
      this.completedIds.delete(taskId)
    } else {
      this.completedIds.add(taskId)
    }
    // 强制重绘
    this.completedIds = new Set(this.completedIds)
  }

  isCompleted(taskId: string): boolean {
    return this.completedIds.has(taskId)
  }

  // ─── 天完成率 ───

  getDayProgress(tasks: StudyTaskDTO[]): number {
    if (tasks.length === 0) { return 0 }
    let doneCount: number = 0
    for (let i = 0; i < tasks.length; i++) {
      if (this.completedIds.has(tasks[i].id)) {
        doneCount = doneCount + 1
      }
    }
    return doneCount / tasks.length
  }

  // ─── 构建 ───

  build() {
    Column() {
      if (this.summary) {
        Text(this.summary)
          .fontSize(StudyTheme.FONT_SM)
          .fontColor(StudyTheme.ACCENT)
          .fontWeight(FontWeight.Medium)
          .padding(StudyTheme.SPACE_MD)
          .width('100%')
          .backgroundColor(StudyTheme.ACCENT_BG)
          .borderRadius(StudyTheme.RADIUS_MD)
          .margin({ bottom: StudyTheme.SPACE_LG })
      }

      if (this.tasks.length === 0) {
        Text('暂无规划任务，请与学习教练对话获取个性化计划')
          .fontSize(StudyTheme.FONT_SM)
          .fontColor(StudyTheme.TEXT_HINT)
          .textAlign(TextAlign.Center)
          .width('100%')
          .padding(StudyTheme.SPACE_XL)
      } else {
        // 按天分组展示
        ForEach(groupByDay(this.tasks), (group: DayGroup) => {
          Column() {
            // 天的标题栏
            Row() {
              Text(group.dateLabel)
                .fontSize(StudyTheme.FONT_MD)
                .fontColor(this.expandedDay === group.dayIndex ? StudyTheme.TEXT_PRIMARY : StudyTheme.TEXT_SECONDARY)
                .fontWeight(FontWeight.Medium)

              Blank()

              // 进度圆环
              Text(`${Math.round(this.getDayProgress(group.tasks) * 100)}%`)
                .fontSize(StudyTheme.FONT_XS)
                .fontColor(StudyTheme.TEXT_HINT)
                .margin({ right: StudyTheme.SPACE_SM })

              Image($r('sys.media.ohos_ic_public_arrow_down'))
                .width(14).height(14)
                .fillColor(StudyTheme.TEXT_HINT)
                .rotate({ angle: this.expandedDay === group.dayIndex ? 180 : 0 })
                .animation({ duration: 200 })
            }
            .width('100%')
            .padding({ left: StudyTheme.SPACE_MD, right: StudyTheme.SPACE_MD, top: StudyTheme.SPACE_SM, bottom: StudyTheme.SPACE_SM })
            .onClick(() => {
              this.expandedDay = this.expandedDay === group.dayIndex ? -1 : group.dayIndex
            })

            // 展开后的任务列表
            if (this.expandedDay === group.dayIndex) {
              Column() {
                ForEach(group.tasks, (task: StudyTaskDTO) => {
                  Row() {
                    // 勾选框
                    Column() {
                      if (this.isCompleted(task.id)) {
                        Text('✓')
                          .fontSize(12)
                          .fontColor('#FFFFFF')
                          .fontWeight(FontWeight.Bold)
                      }
                    }
                    .width(22).height(22)
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(this.isCompleted(task.id) ? StudyTheme.SUCCESS : StudyTheme.BG)
                    .borderRadius(StudyTheme.RADIUS_FULL)
                    .border({ width: 1.5, color: this.isCompleted(task.id) ? StudyTheme.SUCCESS : StudyTheme.BORDER })
                    .onClick(() => { this.toggleTask(task.id) })
                    .margin({ right: StudyTheme.SPACE_MD })

                    // 任务内容
                    Column() {
                      Text(task.title)
                        .fontSize(StudyTheme.FONT_SM)
                        .fontColor(this.isCompleted(task.id) ? StudyTheme.TEXT_HINT : StudyTheme.TEXT_PRIMARY)
                        .fontWeight(FontWeight.Medium)
                        .decoration({
                          type: this.isCompleted(task.id) ? TextDecorationType.LineThrough : TextDecorationType.None,
                        })
                        .margin({ bottom: 2 })

                      if (task.description) {
                        Text(task.description)
                          .fontSize(StudyTheme.FONT_XS)
                          .fontColor(StudyTheme.TEXT_HINT)
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .margin({ bottom: 4 })
                      }

                      Row() {
                        // 优先级标签
                        Text(task.priority === 'high' ? '高优' : task.priority === 'medium' ? '中优' : '低优')
                          .fontSize(9)
                          .fontColor(
                            task.priority === 'high' ? StudyTheme.PRIORITY_HIGH :
                            task.priority === 'medium' ? StudyTheme.PRIORITY_MEDIUM :
                            StudyTheme.PRIORITY_LOW
                          )
                          .padding({ left: 5, right: 5, top: 1, bottom: 1 })
                          .borderRadius(4)
                          .border({ width: 0.5, color: task.priority === 'high' ? StudyTheme.PRIORITY_HIGH : StudyTheme.BORDER })
                          .margin({ right: StudyTheme.SPACE_SM })

                        // 预计时间
                        Text(`${task.estimated_minutes}分钟`)
                          .fontSize(9)
                          .fontColor(StudyTheme.TEXT_HINT)
                          .margin({ right: StudyTheme.SPACE_SM })

                        // 知识点
                        if (task.knowledge_points && task.knowledge_points.length > 0) {
                          Text(task.knowledge_points[0])
                            .fontSize(9)
                            .fontColor(StudyTheme.ACCENT)
                            .maxLines(1)
                            .constraintSize({ maxWidth: 80 })
                        }
                      }
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding({ left: StudyTheme.SPACE_LG, right: StudyTheme.SPACE_MD, top: StudyTheme.SPACE_SM, bottom: StudyTheme.SPACE_SM })
                  .alignItems(VerticalAlign.Top)
                })
              }
              .width('100%')
            }
          }
          .width('100%')
          .backgroundColor(StudyTheme.CARD_BG)
          .borderRadius(StudyTheme.RADIUS_MD)
          .border({ width: 1, color: StudyTheme.BORDER })
          .margin({ bottom: StudyTheme.SPACE_SM })
        })

        // 底部提示
        if (this.tasks.length > 0) {
          Text('✓ 完成学习后点击勾选，进度将自动同步')
            .fontSize(StudyTheme.FONT_XS)
            .fontColor(StudyTheme.TEXT_HINT)
            .textAlign(TextAlign.Center)
            .width('100%')
            .margin({ top: StudyTheme.SPACE_MD })
        }
      }
    }
    .width('100%')
  }
}
