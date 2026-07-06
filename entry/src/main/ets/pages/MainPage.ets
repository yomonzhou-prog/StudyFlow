/**
 * StudyFlow OS - 主页面（底部 Tab 导航）
 * 4个Tab：复习 / 题库 / 教练 / 我的
 */

import { StudyTheme } from '../common/StudyTheme'
import { HomePage } from './HomePage'
import { QuestionBankPage } from './QuestionBankPage'
import { CoachPage } from './CoachPage'
import { ProfilePage } from './ProfilePage'

interface TabItem {
  label: string
}

@Entry
@Component
struct MainPage {
  @State currentTab: number = 0
  private tabController: TabsController = new TabsController()

  private tabs: TabItem[] = [
    { label: '复习' },
    { label: '题库' },
    { label: '教练' },
    { label: '我的' }
  ]

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
      TabContent() { HomePage() }
      .tabBar(this.buildTabBar(0))
      TabContent() { QuestionBankPage() }
      .tabBar(this.buildTabBar(1))
      TabContent() { CoachPage() }
      .tabBar(this.buildTabBar(2))
      TabContent() { ProfilePage() }
      .tabBar(this.buildTabBar(3))
    }
    .barHeight(52)
    .barMode(BarMode.Fixed)
    .onChange((index: number) => { this.currentTab = index })
    .width('100%').height('100%')
  }

  @Builder
  buildTabBar(index: number) {
    Column() {
      Text(this.tabs[index].label)
        .fontSize(12)
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentTab === index ? StudyTheme.ACCENT : StudyTheme.TEXT_HINT)
    }
    .alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
    .width('100%').height('100%')
  }
}
