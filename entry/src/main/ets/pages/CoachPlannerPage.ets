/**
 * StudyFlow OS — 学习规划教练独立页面
 * 场景三入口："只有考试范围，需要制定复习计划"
 */

import { CoachPage } from './CoachPage'

@Entry
@Component
struct CoachPlannerPage {
  build() {
    Column() {
      CoachPage()
    }
    .width('100%').height('100%')
  }
}
