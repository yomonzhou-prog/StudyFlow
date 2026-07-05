/**
 * StudyFlow OS - 主页面（底部 Tab 导航）
 * 4个Tab：学习 / 题库 / 学习教练 / 我的
 */

import { router } from '@kit.ArkUI'
import { Theme } from '../common/Theme'
import { HomePage } from './HomePage'
import { QuestionBankPage } from './QuestionBankPage'
import { CoachPage } from './CoachPage'
import { ProfilePage } from './ProfilePage'

interface TabItem {
  label: string
  emoji: string
}

@Entry
@Component
struct MainPage {
  @State currentTab: number = 0
  private tabController: TabsController = new TabsController()

  private tabs: TabItem[] = [
    { label: '学习', emoji: '📋' },
    { label: '题库', emoji: '📝' },
    { label: '教练', emoji: '💬' },
    { label: '我的', emoji: '👤' }
  ]

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
      TabContent() {
        HomePage()
      }
      .tabBar(this.buildTabBar(0))

      TabContent() {
        QuestionBankPage()
      }
      .tabBar(this.buildTabBar(1))

      TabContent() {
        CoachPage()
      }
      .tabBar(this.buildTabBar(2))

      TabContent() {
        ProfilePage()
      }
      .tabBar(this.buildTabBar(3))
    }
    .barHeight(56)
    .barMode(BarMode.Fixed)
    .onChange((index: number) => {
      this.currentTab = index
    })
    .width('100%')
    .height('100%')
  }

  @Builder
  buildTabBar(index: number) {
    Column() {
      Text(this.tabs[index].emoji)
        .fontSize(22)
      Text(this.tabs[index].label)
        .fontSize(10)
        .fontColor(this.currentTab === index ? Theme.PRIMARY : Theme.TEXT_HINT)
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}
