/**
 * StudyFlow OS — 知识图谱拓扑视图（场景二前端）
 *
 * 递归渲染多层级知识树，点击节点展开发散复习卡片。
 */

import { router } from '@kit.ArkUI'
import { StudyTheme } from '../common/StudyTheme'
import { ApiClient, GraphNodeDTO, GraphEdgeDTO, QuestionCardDTO } from '../services/ApiClient'
import { QuestionCardStore } from '../services/QuestionCardStore'
import { QuestionCard } from '../models/QuestionCard'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

// ─── 节点布局数据结构 ───

interface LayoutNode {
  id: string
  label: string
  level: number
  parentId: string
  importance: string
  isHighlight: boolean
  summary: string
  divergentCards: QuestionCardDTO[]
  x: number
  y: number
  radius: number
  children: LayoutNode[]
}

// ─── 树形布局算法 ───

function countLeaves(node: LayoutNode): number {
  if (node.children.length === 0) { return 1 }
  let sum: number = 0
  for (let i = 0; i < node.children.length; i++) {
    sum = sum + countLeaves(node.children[i])
  }
  return sum
}

function layoutRecursive(
  node: LayoutNode,
  depth: number,
  startX: number,
  levelSpacing: number,
  siblingSpacing: number,
  depthCounter: Map<number, number>,
): number {
  const y: number = 80 + depth * levelSpacing
  const radius: number = Math.max(14, 30 - depth * 4)

  if (node.children.length === 0) {
    const cnt: number = depthCounter.get(depth) ?? 0
    const x: number = startX + cnt * siblingSpacing + 60
    node.x = x
    node.y = y
    node.radius = radius
    depthCounter.set(depth, cnt + 1)
    return x + siblingSpacing
  }

  let childStartX: number = startX
  let maxChildRight: number = startX
  for (let i = 0; i < node.children.length; i++) {
    const child: LayoutNode = node.children[i]
    const childRight: number = layoutRecursive(child, depth + 1, childStartX, levelSpacing, siblingSpacing, depthCounter)
    if (childRight > maxChildRight) { maxChildRight = childRight }
    childStartX = childRight
  }

  let sumX: number = 0
  for (let i = 0; i < node.children.length; i++) {
    sumX = sumX + node.children[i].x
  }
  node.x = sumX / node.children.length
  node.y = y
  node.radius = radius
  return maxChildRight
}

function buildTree(nodes: GraphNodeDTO[], edges: GraphEdgeDTO[]): LayoutNode | null {
  let rootDTO: GraphNodeDTO | null = null
  for (let i = 0; i < nodes.length; i++) {
    if (nodes[i].level === 0) {
      rootDTO = nodes[i]
      break
    }
  }
  if (rootDTO === null) { return null }

  const nodeMap: Map<string, LayoutNode> = new Map()
  for (let i = 0; i < nodes.length; i++) {
    const n: GraphNodeDTO = nodes[i]
    const layoutNode: LayoutNode = {
      id: n.id,
      label: n.label,
      level: n.level,
      parentId: n.parent_id,
      importance: n.importance,
      isHighlight: n.is_highlight,
      summary: n.summary,
      divergentCards: n.divergent_cards,
      x: 0, y: 0, radius: 0,
      children: [],
    }
    nodeMap.set(n.id, layoutNode)
  }

  for (let i = 0; i < edges.length; i++) {
    const edge: GraphEdgeDTO = edges[i]
    const parent: LayoutNode | undefined = nodeMap.get(edge.target_id)
    const child: LayoutNode | undefined = nodeMap.get(edge.source_id)
    if (parent !== undefined && child !== undefined && edge.relation === 'child') {
      parent.children.push(child)
    }
  }

  const root: LayoutNode | undefined = nodeMap.get(rootDTO.id)
  if (root === undefined) { return null }

  layoutRecursive(root, 0, 0, 180, 80, new Map())
  root.radius = 36
  return root
}

// ─── 页面组件 ───

@Entry
@Component
struct KnowledgeGraphPage {
  @State rootNode: LayoutNode | null = null
  @State selectedNode: LayoutNode | null = null
  @State showDetailPanel: boolean = false
  @State isLoading: boolean = true
  @State errorMessage: string = ''
  @State courseName: string = ''
  @State inputTextbook: string = ''
  @State inputHighlights: string = ''
  @State inputCourse: string = ''
  private apiClient: ApiClient = ApiClient.getInstance()
  private cardStore: QuestionCardStore = QuestionCardStore.getInstance()

  aboutToAppear(): void {
    // 初始状态：显示输入界面
    this.isLoading = false
  }

  // ─── 生成图谱 ───

  async handleGenerateGraph(): Promise<void> {
    const trimmed: string = this.inputTextbook.trim()
    if (trimmed.length === 0) {
      this.errorMessage = '请粘贴教材内容或考纲文本'
      return
    }

    this.isLoading = true
    this.errorMessage = ''

    const result = await this.apiClient.generateGraph(
      this.inputTextbook,
      this.inputHighlights,
      this.inputCourse,
    )

    if (result.success) {
      this.courseName = result.data.courseName
      const root: LayoutNode | null = buildTree(result.data.nodes, result.data.edges)
      if (root !== null) {
        this.rootNode = root
      } else {
        this.errorMessage = '图谱构建失败：未能识别知识树结构'
      }
    } else {
      this.errorMessage = result.errorMessage
    }

    this.isLoading = false
  }

  // ─── 节点点击 ───

  handleNodeTap(node: LayoutNode): void {
    this.selectedNode = node
    this.showDetailPanel = true
  }

  // ─── 导入发散题卡 ───

  handleImportDivergentCards(node: LayoutNode): void {
    if (node.divergentCards.length === 0) { return }

    const newCards: QuestionCard[] = []
    for (let i = 0; i < node.divergentCards.length; i++) {
      const dto: QuestionCardDTO = node.divergentCards[i]
      let difficulty: 'easy' | 'medium' | 'hard' = 'medium'
      if (dto.difficulty === 'hard') { difficulty = 'hard' }
      else if (dto.difficulty === 'easy') { difficulty = 'easy' }

      const card: QuestionCard = {
        id: IdUtils.generate(),
        courseName: this.courseName.length > 0 ? this.courseName : '知识图谱',
        question: dto.question,
        options: dto.options,
        answer: dto.answer,
        explanation: dto.explanation,
        relatedKnowledge: dto.related_knowledge,
        difficulty: difficulty,
        commonMistake: dto.common_mistake,
        sourcePaperId: dto.source_paper_id,
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now(),
      }
      newCards.push(card)
    }

    this.cardStore.addCards(newCards)
    this.showDetailPanel = false
    router.pushUrl({ url: 'pages/ImmersiveReviewPage' })
  }

  // ─── 节点颜色 ───

  getNodeColor(node: LayoutNode): string {
    if (node.isHighlight) { return '#D4695A' }
    if (node.level === 0) { return '#C8A96E' }
    if (node.level === 1) { return '#B8956A' }
    if (node.level === 2) { return '#9E8964' }
    return '#8A7A5E'
  }

  // ─── 递归渲染节点 ───

  @Builder
  RenderNode(node: LayoutNode) {
    Column() {
      Column() {
        Circle({ width: node.radius * 2, height: node.radius * 2 })
          .fill(this.getNodeColor(node))
          .stroke(node.isHighlight ? '#D4695A' : StudyTheme.TEXT_PRIMARY)
          .strokeWidth(node.isHighlight ? 3 : 1.5)
          .shadow({
            radius: node.isHighlight ? 8 : 4,
            color: node.isHighlight ? '#D4695A44' : '#C8A96E22',
            offsetX: 0,
            offsetY: 2,
          })

        Text(node.label)
          .fontSize(node.level <= 1 ? StudyTheme.FONT_SM : StudyTheme.FONT_XS)
          .fontColor(StudyTheme.TEXT_PRIMARY)
          .fontWeight(node.level <= 1 ? FontWeight.Bold : FontWeight.Normal)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
          .width(80)
          .margin({ top: 4 })

        if (node.isHighlight) {
          Text('★ 重点')
            .fontSize(10)
            .fontColor('#D4695A')
            .padding({ left: 4, right: 4, top: 1, bottom: 1 })
            .backgroundColor('#D4695A15')
            .borderRadius(4)
            .margin({ top: 2 })
        }
      }
      .alignItems(HorizontalAlign.Center)
      .onClick(() => { this.handleNodeTap(node) })

      if (node.children.length > 0) {
        Row() {
          Line()
            .width(1)
            .height(20)
            .backgroundColor(this.getNodeColor(node))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Row() {
          ForEach(node.children, (child: LayoutNode) => {
            Column() {
              this.RenderNode(child)
            }
            .margin({ left: 6, right: 6 })
          })
        }
        .justifyContent(FlexAlign.Center)
        .padding({ top: 0 })
      }
    }
    .alignItems(HorizontalAlign.Center)
  }

  // ─── 详情面板 ───

  @Builder
  DetailPanel(node: LayoutNode | null) {
    Column() {
      Column().width('100%').layoutWeight(1).onClick(() => { this.showDetailPanel = false })

      Column() {
        if (node !== null) {
          Row() {
            Text(node.label)
              .fontSize(StudyTheme.FONT_LG)
              .fontColor(StudyTheme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Bold)
              .layoutWeight(1)
            Text('✕')
              .fontSize(StudyTheme.FONT_LG)
              .fontColor(StudyTheme.TEXT_HINT)
              .onClick(() => { this.showDetailPanel = false })
          }
          .width('100%')
          .margin({ bottom: StudyTheme.SPACE_MD })

          if (node.summary.length > 0) {
            Text(node.summary)
              .fontSize(StudyTheme.FONT_SM)
              .fontColor(StudyTheme.TEXT_SECONDARY)
              .lineHeight(22)
              .margin({ bottom: StudyTheme.SPACE_LG })
          }

          if (node.isHighlight && node.divergentCards.length > 0) {
            Text(`发散复习题 (${node.divergentCards.length}道)`)
              .fontSize(StudyTheme.FONT_SM)
              .fontColor(StudyTheme.TEXT_PRIMARY)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: StudyTheme.SPACE_MD })

            ForEach(node.divergentCards, (card: QuestionCardDTO, index: number) => {
              Column() {
                Text(`题${index + 1}: ${card.question}`)
                  .fontSize(StudyTheme.FONT_XS)
                  .fontColor(StudyTheme.TEXT_PRIMARY)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ bottom: 4 })
                Text(`难度: ${card.difficulty}`)
                  .fontSize(10)
                  .fontColor(StudyTheme.TEXT_HINT)
              }
              .width('100%')
              .padding(StudyTheme.SPACE_SM)
              .backgroundColor(StudyTheme.BG)
              .borderRadius(StudyTheme.RADIUS_SM)
              .margin({ bottom: StudyTheme.SPACE_SM })
            }, (card: QuestionCardDTO, index: number) => `detail_card_${index}`)

            Row() {
              Text(`导入 ${node.divergentCards.length} 道发散题并开始复习`)
                .fontSize(StudyTheme.FONT_SM)
                .fontColor(StudyTheme.TEXT_INVERSE)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .height(48)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(StudyTheme.ACCENT)
            .borderRadius(StudyTheme.RADIUS_MD)
            .margin({ top: StudyTheme.SPACE_MD })
            .onClick(() => {
              if (node !== null) { this.handleImportDivergentCards(node) }
            })
          } else if (!node.isHighlight) {
            Text('此知识点未命中教师重点，无发散题卡。')
              .fontSize(StudyTheme.FONT_SM)
              .fontColor(StudyTheme.TEXT_HINT)
          }
        }
      }
      .width('100%')
      .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_LG, bottom: StudyTheme.SPACE_XXL })
      .backgroundColor(StudyTheme.CARD_BG)
      .borderRadius({ topLeft: StudyTheme.RADIUS_LG, topRight: StudyTheme.RADIUS_LG })
      .border({ width: { top: 1 }, color: StudyTheme.BORDER })
    }
    .width('100%')
    .height('100%')
  }

  // ─── 构建 ───

  build() {
    Stack() {
      Column() {
        // 顶部栏
        Row() {
          Image($r('sys.media.ohos_ic_public_arrow_left'))
            .width(22).height(22)
            .fillColor(StudyTheme.TEXT_HINT)
            .onClick(() => { router.back() })
          Text('知识图谱')
            .fontSize(StudyTheme.FONT_LG)
            .fontColor(StudyTheme.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          Row().width(22).height(22)
        }
        .width('100%')
        .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_XL, bottom: StudyTheme.SPACE_MD })

        if (this.rootNode === null) {
          // ── 输入界面 ──
          Scroll() {
            Column() {
              Text('粘贴教材内容或考纲，自动生成知识拓扑图谱。命中教师重点的知识点将额外标注并附带发散复习题。')
                .fontSize(StudyTheme.FONT_XS)
                .fontColor(StudyTheme.TEXT_HINT)
                .lineHeight(18)
                .margin({ bottom: StudyTheme.SPACE_LG })

              Text('课程名称')
                .fontSize(StudyTheme.FONT_SM)
                .fontColor(StudyTheme.TEXT_SECONDARY)
                .margin({ bottom: StudyTheme.SPACE_SM })
                .width('100%')
              TextInput({ text: this.inputCourse, placeholder: '如：电路分析基础' })
                .fontSize(StudyTheme.FONT_MD)
                .backgroundColor(StudyTheme.CARD_BG)
                .borderRadius(StudyTheme.RADIUS_MD)
                .border({ width: 1, color: StudyTheme.BORDER })
                .padding(StudyTheme.SPACE_MD)
                .width('100%')
                .margin({ bottom: StudyTheme.SPACE_LG })
                .onChange((v: string) => { this.inputCourse = v })

              Text('教材内容 / 考纲')
                .fontSize(StudyTheme.FONT_SM)
                .fontColor(StudyTheme.TEXT_SECONDARY)
                .margin({ bottom: StudyTheme.SPACE_SM })
                .width('100%')
              TextArea({ text: this.inputTextbook, placeholder: '粘贴教材目录、章节摘要或考纲内容...' })
                .fontSize(StudyTheme.FONT_SM)
                .backgroundColor(StudyTheme.CARD_BG)
                .borderRadius(StudyTheme.RADIUS_MD)
                .border({ width: 1, color: StudyTheme.BORDER })
                .padding(StudyTheme.SPACE_MD)
                .height(160)
                .width('100%')
                .margin({ bottom: StudyTheme.SPACE_LG })
                .onChange((v: string) => { this.inputTextbook = v })

              Text('教师标注重点（可选）')
                .fontSize(StudyTheme.FONT_SM)
                .fontColor(StudyTheme.TEXT_SECONDARY)
                .margin({ bottom: StudyTheme.SPACE_SM })
                .width('100%')
              TextArea({ text: this.inputHighlights, placeholder: '粘贴老师划的重点、考点提示...' })
                .fontSize(StudyTheme.FONT_SM)
                .backgroundColor(StudyTheme.CARD_BG)
                .borderRadius(StudyTheme.RADIUS_MD)
                .border({ width: 1, color: StudyTheme.BORDER })
                .padding(StudyTheme.SPACE_MD)
                .height(100)
                .width('100%')
                .margin({ bottom: StudyTheme.SPACE_LG })
                .onChange((v: string) => { this.inputHighlights = v })

              if (this.errorMessage.length > 0) {
                Text(this.errorMessage)
                  .fontSize(StudyTheme.FONT_XS)
                  .fontColor(StudyTheme.DANGER)
                  .margin({ bottom: StudyTheme.SPACE_MD })
              }

              Row() {
                if (this.isLoading) {
                  LoadingProgress().width(20).height(20).color(StudyTheme.TEXT_INVERSE).margin({ right: StudyTheme.SPACE_SM })
                }
                Text(this.isLoading ? '正在构建知识图谱...' : '生成知识图谱')
                  .fontSize(StudyTheme.FONT_MD)
                  .fontColor(StudyTheme.TEXT_INVERSE)
                  .fontWeight(FontWeight.Medium)
              }
              .width('100%')
              .height(52)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(this.inputTextbook.trim().length > 0 && !this.isLoading ? StudyTheme.ACCENT : StudyTheme.TEXT_HINT)
              .borderRadius(StudyTheme.RADIUS_MD)
              .onClick(() => {
                if (this.inputTextbook.trim().length > 0 && !this.isLoading) { this.handleGenerateGraph() }
              })
            }
            .width('100%')
            .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        } else {
          // ── 图谱视图 ──
          Scroll() {
            Scroll() {
              Column() {
                Text(this.courseName)
                  .fontSize(StudyTheme.FONT_LG)
                  .fontColor(StudyTheme.TEXT_PRIMARY)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: StudyTheme.SPACE_XS })
                  .textAlign(TextAlign.Center)

                Text('点击节点查看详情 · 红色标注为教师重点')
                  .fontSize(StudyTheme.FONT_XS)
                  .fontColor(StudyTheme.TEXT_HINT)
                  .margin({ bottom: StudyTheme.SPACE_XL })
                  .textAlign(TextAlign.Center)

                if (this.rootNode !== null) {
                  this.RenderNode(this.rootNode)
                }
              }
              .width('100%')
              .padding({ left: StudyTheme.PAGE_PAD, right: StudyTheme.PAGE_PAD, top: StudyTheme.SPACE_MD, bottom: 120 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(StudyTheme.BG)

      // ── 底部详情面板 ──
      if (this.showDetailPanel) {
        this.DetailPanel(this.selectedNode)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(StudyTheme.BG)
  }
}
