/**
 * StudyFlow OS - MockData
 * 提供完整的示例数据，确保无DeepSeek API也能完整演示
 * 包含：概率论与数理统计（主示例）、数据结构（副示例）
 */

import { CourseMaterial } from '../models/CourseMaterial'
import { CourseProfile } from '../models/CourseProfile'
import { KnowledgePoint } from '../models/KnowledgePoint'
import { StudyTask } from '../models/StudyTask'
import { ReviewCard } from '../models/ReviewCard'
import { QuizItem } from '../models/QuizItem'
import { LearningFeedback } from '../models/LearningFeedback'
import { QuestionItem } from '../models/QuestionItem'
import { WrongQuestion } from '../models/WrongQuestion'
import { DateUtils } from '../utils/DateUtils'

export class MockData {
  // ========== 示例课程资料 ==========

  static getSampleMaterial_probability(): CourseMaterial {
    return {
      id: 'mat-prob-001',
      courseName: '概率论与数理统计',
      title: '第四章：随机变量的数字特征',
      content: `第四章 随机变量的数字特征

4.1 数学期望
数学期望是随机变量取值的加权平均，反映随机变量的"平均"大小。
- 离散型随机变量的数学期望：E(X) = Σ x_i · p_i
- 连续型随机变量的数学期望：E(X) = ∫ x · f(x) dx
- 数学期望的性质：线性性 E(aX + b) = aE(X) + b

4.2 方差
方差衡量随机变量与其均值的偏离程度。
- 定义：D(X) = E[(X - E(X))²]
- 计算公式：D(X) = E(X²) - [E(X)]²
- 标准差：σ = √D(X)
- 性质：D(aX + b) = a²D(X)

4.3 协方差与相关系数
协方差描述两个随机变量的线性相关关系。
- 定义：Cov(X,Y) = E[(X - E(X))(Y - E(Y))]
- 相关系数：ρ_XY = Cov(X,Y) / (σ_X · σ_Y)
- |ρ| ≤ 1，|ρ| = 1 时 X 与 Y 完全线性相关
- ρ > 0 正相关，ρ < 0 负相关，ρ = 0 不相关

4.4 矩与协方差矩阵
- k阶原点矩：E(X^k)
- k阶中心矩：E[(X - E(X))^k]
- 协方差矩阵在多维随机变量中的应用

重点题型：
1. 求离散型/连续型随机变量的数学期望和方差
2. 利用期望和方差的性质简化计算
3. 计算协方差和相关系数，判断线性相关性
4. 常见分布（二项、泊松、均匀、指数、正态）的期望和方差

常见错误：
- 混淆方差定义公式和计算公式
- 忽略常数倍方差的性质 D(aX) = a²D(X)
- 相关系数为0只能说明不线性相关，不能说明独立`,
      type: 'textbook',
      createdAt: DateUtils.daysAgo(3)
    }
  }

  static getSampleMaterial_dataStructure(): CourseMaterial {
    return {
      id: 'mat-ds-001',
      courseName: '数据结构',
      title: '第三章：树与二叉树',
      content: `第三章 树与二叉树

3.1 树的基本概念
- 树是n个节点的有限集合
- 根节点、子树、父节点、子节点、叶子节点
- 节点的度、树的度、树的深度

3.2 二叉树
- 每个节点最多有两个子树
- 满二叉树：深度为k时有2^k - 1个节点
- 完全二叉树：按层序编号与满二叉树一一对应
- 性质：第i层最多2^(i-1)个节点

3.3 二叉树的遍历
- 前序遍历：根 → 左 → 右
- 中序遍历：左 → 根 → 右
- 后序遍历：左 → 右 → 根
- 层序遍历：按层从上到下，每层从左到右

3.4 二叉搜索树（BST）
- 左子树所有节点值 < 根节点值
- 右子树所有节点值 > 根节点值
- 查找、插入、删除的平均时间复杂度O(log n)

3.5 平衡二叉树（AVL）
- 任意节点左右子树高度差不超过1
- 四种旋转：LL、RR、LR、RL
- 平衡因子 = 左子树高度 - 右子树高度

重点题型：
1. 根据遍历序列还原二叉树
2. BST的插入和删除操作
3. AVL树的平衡旋转
4. 树与二叉树的转换

常见错误：
- 混淆不同遍历顺序
- BST删除节点时遗漏重建
- AVL旋转方向判断错误`,
      type: 'textbook',
      createdAt: DateUtils.daysAgo(5)
    }
  }

  static getSampleMaterial_english(): CourseMaterial {
    return {
      id: 'mat-eng-001',
      courseName: '大学英语',
      title: 'Unit 5: Academic Writing - Essay Structure',
      content: `Unit 5: Academic Writing - Essay Structure

5.1 The Three-Part Structure
- Introduction: Hook + Background + Thesis Statement
- Body Paragraphs: Topic Sentence + Evidence + Analysis + Transition
- Conclusion: Restate Thesis + Summarize + Final Thought

5.2 Thesis Statement Writing
- Must be arguable and specific
- Avoid: "This essay will discuss..."
- Better: "The implementation of AI grading systems threatens academic integrity by..."

5.3 Paragraph Development
- P.E.E.L method: Point, Evidence, Explanation, Link
- Each paragraph must support the thesis
- Use transition words: Furthermore, However, Consequently

5.4 Common Academic Vocabulary
- Analyze, Argue, Compare, Contrast, Demonstrate
- Illustrate, Indicate, Suggest, Validate
- Avoid informal expressions

5.5 Citation Basics (APA Style)
- In-text: (Author, Year)
- Reference list format
- Avoiding plagiarism

常见错误：
- 主题句不明确
- 段落缺乏统一性
- 混用正式和非正式表达`,
      type: 'textbook',
      createdAt: DateUtils.daysAgo(7)
    }
  }

  // ========== 示例课程画像（模拟AI解析结果） ==========

  static getSampleProfile_probability(): CourseProfile {
    const kpIds = [
      'kp-prob-001', 'kp-prob-002', 'kp-prob-003', 'kp-prob-004',
      'kp-prob-005', 'kp-prob-006', 'kp-prob-007', 'kp-prob-008'
    ]

    return {
      id: 'prof-prob-001',
      materialId: 'mat-prob-001',
      courseName: '概率论与数理统计',
      summary: '本章核心内容是随机变量的数字特征，包括数学期望、方差、协方差和相关系数。数学期望描述随机变量的"中心位置"，方差描述离散程度，协方差和相关系数描述两个随机变量的线性关系。本章是后续统计推断和回归分析的基础，考试占比约25%，必须牢固掌握。',
      chapters: [
        {
          title: '4.1 数学期望',
          order: 1,
          summary: '数学期望的定义、性质和计算方法',
          knowledgePointIds: ['kp-prob-001', 'kp-prob-002']
        },
        {
          title: '4.2 方差',
          order: 2,
          summary: '方差的定义、计算和性质',
          knowledgePointIds: ['kp-prob-003', 'kp-prob-004']
        },
        {
          title: '4.3 协方差与相关系数',
          order: 3,
          summary: '协方差和相关系数的定义、计算及含义',
          knowledgePointIds: ['kp-prob-005', 'kp-prob-006']
        },
        {
          title: '4.4 矩与协方差矩阵',
          order: 4,
          summary: '矩的概念及协方差矩阵的应用',
          knowledgePointIds: ['kp-prob-007', 'kp-prob-008']
        }
      ],
      knowledgePoints: [
        {
          id: 'kp-prob-001',
          profileId: 'prof-prob-001',
          title: '数学期望的定义',
          chapter: '4.1 数学期望',
          explanation: '数学期望（Expected Value）是随机变量取值的概率加权平均，反映随机变量的平均取值水平。离散型用求和Σ x_i·p_i，连续型用积分∫ x·f(x)dx。',
          importance: 'critical',
          difficulty: 'medium',
          commonMistakes: [
            '忘记乘以对应的概率/密度',
            '积分区间取错（应该取概率密度非零的区域）',
            '混淆离散型和连续型的计算公式'
          ],
          relatedKnowledgePointIds: ['kp-prob-002', 'kp-prob-003'],
          order: 1
        },
        {
          id: 'kp-prob-002',
          profileId: 'prof-prob-001',
          title: '数学期望的性质',
          chapter: '4.1 数学期望',
          explanation: '期望具有线性性：E(aX + b) = aE(X) + b；两个随机变量和的期望等于期望的和：E(X+Y) = E(X) + E(Y)；独立时乘积的期望等于期望的乘积。',
          importance: 'critical',
          difficulty: 'medium',
          commonMistakes: [
            '误认为E(XY) = E(X)E(Y)总是成立（仅在独立时成立）',
            '忽略常数项对期望的影响'
          ],
          relatedKnowledgePointIds: ['kp-prob-001', 'kp-prob-005'],
          order: 2
        },
        {
          id: 'kp-prob-003',
          profileId: 'prof-prob-001',
          title: '方差的定义与计算',
          chapter: '4.2 方差',
          explanation: '方差D(X)衡量随机变量偏离期望的程度。定义式：D(X)=E[(X-E(X))²]；计算式：D(X)=E(X²)-[E(X)]²。计算式更实用。标准差σ=√D(X)与原始数据量纲一致。',
          importance: 'critical',
          difficulty: 'hard',
          commonMistakes: [
            '混淆方差定义式和计算式',
            '忘记方差开根号得到标准差',
            '计算E(X²)时积分/求和出错'
          ],
          relatedKnowledgePointIds: ['kp-prob-001', 'kp-prob-004'],
          order: 3
        },
        {
          id: 'kp-prob-004',
          profileId: 'prof-prob-001',
          title: '方差的性质',
          chapter: '4.2 方差',
          explanation: 'D(aX+b) = a²D(X)，常数对方差无影响；独立时D(X±Y) = D(X)+D(Y)；一般情况D(X±Y) = D(X)+D(Y)±2Cov(X,Y)。',
          importance: 'high',
          difficulty: 'medium',
          commonMistakes: [
            '误以为D(aX) = aD(X)（漏掉了平方）',
            '独立和不独立时方差加法公式混淆'
          ],
          relatedKnowledgePointIds: ['kp-prob-003', 'kp-prob-005'],
          order: 4
        },
        {
          id: 'kp-prob-005',
          profileId: 'prof-prob-001',
          title: '协方差',
          chapter: '4.3 协方差与相关系数',
          explanation: 'Cov(X,Y)=E[(X-E(X))(Y-E(Y))]，衡量两个随机变量的线性相关方向。Cov>0正相关，Cov<0负相关。计算式：Cov(X,Y)=E(XY)-E(X)E(Y)。',
          importance: 'high',
          difficulty: 'hard',
          commonMistakes: [
            '协方差和相关系数概念混淆',
            '用计算式时E(XY)算错',
            'Cov=0不能推出独立'
          ],
          relatedKnowledgePointIds: ['kp-prob-006', 'kp-prob-002'],
          order: 5
        },
        {
          id: 'kp-prob-006',
          profileId: 'prof-prob-001',
          title: '相关系数',
          chapter: '4.3 协方差与相关系数',
          explanation: 'ρ_XY = Cov(X,Y)/(σ_X·σ_Y)，是无量纲的标准化指标。|ρ|≤1，|ρ|=1表示完全线性相关。ρ>0正相关，ρ<0负相关，ρ=0不线性相关。',
          importance: 'high',
          difficulty: 'medium',
          commonMistakes: [
            'ρ=0误认为X和Y独立（只是不线性相关）',
            '相关系数绝对值大小代表什么判断不准'
          ],
          relatedKnowledgePointIds: ['kp-prob-005'],
          order: 6
        },
        {
          id: 'kp-prob-007',
          profileId: 'prof-prob-001',
          title: '矩的概念',
          chapter: '4.4 矩与协方差矩阵',
          explanation: 'k阶原点矩E(X^k)，1阶原点矩即期望。k阶中心矩E[(X-E(X))^k]，2阶中心矩即方差。矩是描述分布形状的工具。',
          importance: 'medium',
          difficulty: 'medium',
          commonMistakes: [
            '混淆原点矩和中心矩的定义'
          ],
          relatedKnowledgePointIds: ['kp-prob-001', 'kp-prob-003'],
          order: 7
        },
        {
          id: 'kp-prob-008',
          profileId: 'prof-prob-001',
          title: '常见分布的期望与方差',
          chapter: '4.4 矩与协方差矩阵',
          explanation: '二项分布B(n,p)：E=np, D=np(1-p)；泊松分布P(λ)：E=λ, D=λ；均匀分布U(a,b)：E=(a+b)/2, D=(b-a)²/12；指数分布：E=1/λ, D=1/λ²；正态分布N(μ,σ²)：E=μ, D=σ²。',
          importance: 'critical',
          difficulty: 'easy',
          commonMistakes: [
            '各分布的参数记混',
            '二项分布方差忘记乘(1-p)'
          ],
          relatedKnowledgePointIds: ['kp-prob-001', 'kp-prob-003'],
          order: 8
        }
      ],
      examFocuses: [
        {
          topic: '离散型随机变量期望与方差计算',
          importance: 'critical',
          description: '给定分布律，求E(X)、D(X)。占比约15分，必考。'
        },
        {
          topic: '连续型随机变量期望与方差计算',
          importance: 'critical',
          description: '给定密度函数，用积分求E(X)、D(X)。占比约15分，必考。'
        },
        {
          topic: '协方差与相关系数',
          importance: 'high',
          description: '已知联合分布，计算Cov(X,Y)和ρ_XY，判断相关性。占比约10分。'
        },
        {
          topic: '常用分布的期望方差',
          importance: 'high',
          description: '熟记6种常见分布的期望和方差，考试占比约8分。'
        }
      ],
      homeworkTasks: [
        {
          title: '完成第四章课后习题1-15题',
          deadline: DateUtils.daysLater(2),
          description: '重点做第3、7、12、15题（期望和方差的综合计算）',
          priority: 'high'
        },
        {
          title: '复习协方差公式推导',
          deadline: DateUtils.daysLater(3),
          description: '独立推导Cov(X,Y)=E(XY)-E(X)E(Y)的展开过程',
          priority: 'medium'
        }
      ],
      riskWarnings: [
        {
          level: 'high',
          message: '方差计算错误率高',
          suggestion: '建议反复练习定义式和计算式的转换，重点做课后第3、7题'
        },
        {
          level: 'medium',
          message: '相关系数概念理解不清',
          suggestion: '注意区分"不相关"和"独立"的区别，阅读教材70-72页'
        },
        {
          level: 'low',
          message: '常见分布参数容易混淆',
          suggestion: '制作记忆卡片，每天复习一遍6种常见分布的E和D'
        }
      ],
      createdAt: DateUtils.daysAgo(3),
      isMockData: true
    }
  }

  // ========== 示例复习卡片 ==========

  static getSampleReviewCards_probability(): ReviewCard[] {
    return [
      {
        id: 'rc-prob-001',
        profileId: 'prof-prob-001',
        knowledgePointId: 'kp-prob-001',
        knowledgePointTitle: '数学期望的定义',
        knowledgePointExplanation: '数学期望是随机变量取值的概率加权平均。离散型：E(X)=Σx_i·p_i；连续型：E(X)=∫x·f(x)dx。',
        keyReminder: '注意离散用求和，连续用积分！积分区间是密度非零的区域。',
        commonMistakes: ['忘记乘以概率', '积分区间取错'],
        quiz: {
          id: 'qz-prob-001',
          question: '设离散型随机变量X的分布律为：P(X=1)=0.3, P(X=2)=0.5, P(X=3)=0.2，求E(X)。',
          options: ['A. 1.5', 'B. 1.9', 'C. 2.0', 'D. 2.1'],
          correctAnswer: 'B',
          explanation: 'E(X) = 1×0.3 + 2×0.5 + 3×0.2 = 0.3 + 1.0 + 0.6 = 1.9。选项B正确。',
          type: 'choice'
        },
        nextReviewSuggestion: '掌握良好，3天后复习',
        reviewCount: 0,
        lastFeedbackStatus: ''
      },
      {
        id: 'rc-prob-002',
        profileId: 'prof-prob-001',
        knowledgePointId: 'kp-prob-003',
        knowledgePointTitle: '方差的定义与计算',
        knowledgePointExplanation: 'D(X)=E[(X-E(X))²]=E(X²)-[E(X)]²。推荐用计算式D(X)=E(X²)-[E(X)]²更简便。',
        keyReminder: '计算式D(X)=E(X²)-[E(X)]²比定义式更方便！先算E(X)，再算E(X²)。',
        commonMistakes: ['混淆两种公式', '计算E(X²)出错'],
        quiz: {
          id: 'qz-prob-002',
          question: '已知随机变量X满足E(X)=3，E(X²)=13，求D(X)和标准差σ。',
          options: ['A. D=4, σ=2', 'B. D=10, σ=√10', 'C. D=4, σ=16', 'D. D=3, σ=√3'],
          correctAnswer: 'A',
          explanation: 'D(X)=E(X²)-[E(X)]²=13-9=4，σ=√D=2。选项A正确。',
          type: 'choice'
        },
        nextReviewSuggestion: '明天再次测试方差计算',
        reviewCount: 1,
        lastFeedbackStatus: 'fuzzy'
      },
      {
        id: 'rc-prob-003',
        profileId: 'prof-prob-001',
        knowledgePointId: 'kp-prob-005',
        knowledgePointTitle: '协方差',
        knowledgePointExplanation: 'Cov(X,Y)=E[(X-E(X))(Y-E(Y))]=E(XY)-E(X)E(Y)。描述两变量线性关系。',
        keyReminder: '协方差受量纲影响，看方向不看大小！要比较强度用相关系数。',
        commonMistakes: ['与相关系数混淆', 'Cov=0误以为独立'],
        quiz: {
          id: 'qz-prob-003',
          question: '若Cov(X,Y)=0，下列说法正确的是？',
          options: [
            'A. X与Y一定独立',
            'B. X与Y一定不独立',
            'C. X与Y不存在线性关系',
            'D. X与Y的方差都为0'
          ],
          correctAnswer: 'C',
          explanation: 'Cov=0只说明没有线性相关关系，不能推出独立（可能存在非线性关系）。选项C正确。',
          type: 'choice'
        },
        nextReviewSuggestion: '重点复习，明天再次测试',
        reviewCount: 1,
        lastFeedbackStatus: 'wrong'
      },
      {
        id: 'rc-prob-004',
        profileId: 'prof-prob-001',
        knowledgePointId: 'kp-prob-008',
        knowledgePointTitle: '常见分布的期望与方差',
        knowledgePointExplanation: '二项B(n,p): E=np, D=np(1-p)；泊松P(λ): E=λ, D=λ；均匀U(a,b): E=(a+b)/2, D=(b-a)²/12；指数Exp(λ): E=1/λ, D=1/λ²；正态N(μ,σ²): E=μ, D=σ²。',
        keyReminder: '正态分布的参数μ就是期望，σ²就是方差！这是最重要的分布。',
        commonMistakes: ['参数记混', '二项方差忘(1-p)'],
        quiz: {
          id: 'qz-prob-004',
          question: '设X~B(10, 0.4)，求E(X)和D(X)。',
          options: ['A. E=4, D=2.4', 'B. E=4, D=4', 'C. E=10, D=2.4', 'D. E=0.4, D=2.4'],
          correctAnswer: 'A',
          explanation: '二项分布：E(X)=np=10×0.4=4，D(X)=np(1-p)=10×0.4×0.6=2.4。选项A正确。',
          type: 'choice'
        },
        nextReviewSuggestion: '5天后复习常见分布',
        reviewCount: 2,
        lastFeedbackStatus: 'mastered'
      }
    ]
  }

  // ========== 示例学习任务 ==========

  static getSampleTasks(): StudyTask[] {
    return [
      {
        id: 'task-001',
        title: '完成第四章课后习题1-15题',
        courseName: '概率论与数理统计',
        description: '重点做第3、7、12、15题（期望和方差的综合计算）',
        priority: 'high',
        estimatedMinutes: 90,
        deadline: DateUtils.daysLater(2),
        status: 'pending',
        sourceType: 'homework',
        relatedKnowledgePointIds: ['kp-prob-001', 'kp-prob-002', 'kp-prob-003'],
        createdAt: DateUtils.daysAgo(1)
      },
      {
        id: 'task-002',
        title: '复习数学期望的性质',
        courseName: '概率论与数理统计',
        description: '推导E(aX+b)=aE(X)+b的证明过程',
        priority: 'medium',
        estimatedMinutes: 30,
        deadline: DateUtils.today(),
        status: 'in_progress',
        sourceType: 'review',
        relatedKnowledgePointIds: ['kp-prob-002'],
        createdAt: DateUtils.daysAgo(1)
      },
      {
        id: 'task-003',
        title: '方差计算专项练习',
        courseName: '概率论与数理统计',
        description: '针对方差定义式和计算式，做10道专项练习题',
        priority: 'high',
        estimatedMinutes: 60,
        deadline: DateUtils.today(),
        status: 'pending',
        sourceType: 'weakness',
        relatedKnowledgePointIds: ['kp-prob-003', 'kp-prob-004'],
        createdAt: DateUtils.daysAgo(1)
      },
      {
        id: 'task-004',
        title: '二叉树遍历练习题',
        courseName: '数据结构',
        description: '完成前序、中序、后序遍历各5道题',
        priority: 'medium',
        estimatedMinutes: 45,
        deadline: DateUtils.daysLater(1),
        status: 'pending',
        sourceType: 'homework',
        relatedKnowledgePointIds: [],
        createdAt: DateUtils.daysAgo(2)
      },
      {
        id: 'task-005',
        title: '背诵学术英语词汇表',
        courseName: '大学英语',
        description: '背诵Unit 5的20个核心学术词汇',
        priority: 'low',
        estimatedMinutes: 20,
        deadline: DateUtils.daysLater(3),
        status: 'pending',
        sourceType: 'homework',
        relatedKnowledgePointIds: [],
        createdAt: DateUtils.daysAgo(2)
      },
      {
        id: 'task-006',
        title: '协方差与相关系数复习',
        courseName: '概率论与数理统计',
        description: '根据自测反馈，重新学习协方差概念，完成3道补充题',
        priority: 'high',
        estimatedMinutes: 45,
        deadline: DateUtils.today(),
        status: 'pending',
        sourceType: 'weakness',
        relatedKnowledgePointIds: ['kp-prob-005', 'kp-prob-006'],
        createdAt: DateUtils.today()
      }
    ]
  }

  // ========== 示例学习反馈 ==========

  static getSampleFeedbacks(): LearningFeedback[] {
    return [
      {
        id: 'fb-001',
        reviewCardId: 'rc-prob-002',
        knowledgePointId: 'kp-prob-003',
        knowledgePointTitle: '方差的定义与计算',
        status: 'fuzzy',
        timestamp: DateUtils.daysAgo(1),
        note: '计算式会用，但定义式的含义理解不够'
      },
      {
        id: 'fb-002',
        reviewCardId: 'rc-prob-003',
        knowledgePointId: 'kp-prob-005',
        knowledgePointTitle: '协方差',
        status: 'wrong',
        timestamp: DateUtils.daysAgo(1),
        note: '混淆了协方差和相关系数的概念'
      },
      {
        id: 'fb-003',
        reviewCardId: 'rc-prob-004',
        knowledgePointId: 'kp-prob-008',
        knowledgePointTitle: '常见分布的期望与方差',
        status: 'mastered',
        timestamp: DateUtils.daysAgo(2),
        note: '6种分布全部记熟'
      }
    ]
  }

  // ========== 示例课程资料列表 ==========

  static getAllSampleMaterials(): CourseMaterial[] {
    return [
      MockData.getSampleMaterial_probability(),
      MockData.getSampleMaterial_dataStructure(),
      MockData.getSampleMaterial_english()
    ]
  }

  // ========== 示例题库 ==========

  static getSampleQuestions(): QuestionItem[] {
    return [
      {
        id: 'q-001',
        courseName: '概率论与数理统计',
        chapter: '4.1 数学期望',
        knowledgePointId: 'kp-prob-001',
        question: '掷一枚均匀骰子，设X为出现的点数，则E(X)等于？',
        options: ['A. 3', 'B. 3.5', 'C. 4', 'D. 6'],
        correctAnswer: 'B',
        explanation: 'E(X)=1×(1/6)+2×(1/6)+3×(1/6)+4×(1/6)+5×(1/6)+6×(1/6)=21/6=3.5',
        type: 'choice',
        difficulty: 'easy',
        source: '课后习题',
        createdAt: DateUtils.daysAgo(3),
        attemptCount: 0,
        wrongCount: 0
      },
      {
        id: 'q-002',
        courseName: '概率论与数理统计',
        chapter: '4.1 数学期望',
        knowledgePointId: 'kp-prob-002',
        question: '已知E(X)=5，则E(2X+3)等于？',
        options: ['A. 10', 'B. 13', 'C. 16', 'D. 8'],
        correctAnswer: 'B',
        explanation: '利用期望的线性性质：E(2X+3)=2E(X)+3=2×5+3=13',
        type: 'choice',
        difficulty: 'easy',
        source: '课堂测试',
        createdAt: DateUtils.daysAgo(3),
        attemptCount: 0,
        wrongCount: 0
      },
      {
        id: 'q-003',
        courseName: '概率论与数理统计',
        chapter: '4.2 方差',
        knowledgePointId: 'kp-prob-003',
        question: '设随机变量X满足E(X)=3，E(X²)=13，则D(X)等于？',
        options: ['A. 4', 'B. 10', 'C. 13', 'D. 16'],
        correctAnswer: 'A',
        explanation: 'D(X)=E(X²)-[E(X)]²=13-9=4',
        type: 'choice',
        difficulty: 'easy',
        source: '历年真题',
        createdAt: DateUtils.daysAgo(2),
        attemptCount: 0,
        wrongCount: 0
      },
      {
        id: 'q-004',
        courseName: '概率论与数理统计',
        chapter: '4.2 方差',
        knowledgePointId: 'kp-prob-004',
        question: '设X~B(10, 0.3)，则D(X)等于？',
        options: ['A. 3', 'B. 2.1', 'C. 7', 'D. 0.21'],
        correctAnswer: 'B',
        explanation: '二项分布的方差D(X)=np(1-p)=10×0.3×0.7=2.1',
        type: 'choice',
        difficulty: 'medium',
        source: '课后习题',
        createdAt: DateUtils.daysAgo(2),
        attemptCount: 0,
        wrongCount: 0
      },
      {
        id: 'q-005',
        courseName: '概率论与数理统计',
        chapter: '4.3 协方差与相关系数',
        knowledgePointId: 'kp-prob-005',
        question: '若X与Y相互独立，则Cov(X,Y)等于？',
        options: ['A. 1', 'B. E(XY)', 'C. 0', 'D. D(X)'],
        correctAnswer: 'C',
        explanation: 'X与Y独立时，E(XY)=E(X)E(Y)，因此Cov(X,Y)=E(XY)-E(X)E(Y)=0',
        type: 'choice',
        difficulty: 'medium',
        source: '课堂测试',
        createdAt: DateUtils.daysAgo(2),
        attemptCount: 0,
        wrongCount: 0
      },
      {
        id: 'q-006',
        courseName: '概率论与数理统计',
        chapter: '4.3 协方差与相关系数',
        knowledgePointId: 'kp-prob-006',
        question: '相关系数ρ_XY的取值范围是？',
        options: ['A. [0, 1]', 'B. (-∞, +∞)', 'C. [-1, 1]', 'D. [0, +∞)'],
        correctAnswer: 'C',
        explanation: '相关系数标准化后取值范围为[-1, 1]，|ρ|=1表示完全线性相关，ρ=0表示不线性相关',
        type: 'choice',
        difficulty: 'medium',
        source: '历年真题',
        createdAt: DateUtils.daysAgo(1),
        attemptCount: 0,
        wrongCount: 0
      },
      {
        id: 'q-007',
        courseName: '概率论与数理统计',
        chapter: '4.4 矩与协方差矩阵',
        knowledgePointId: 'kp-prob-008',
        question: '设X~P(λ)（泊松分布），则E(X)和D(X)分别等于？',
        options: ['A. E=λ, D=λ²', 'B. E=λ, D=λ', 'C. E=1/λ, D=1/λ', 'D. E=λ, D=1/λ'],
        correctAnswer: 'B',
        explanation: '泊松分布的期望和方差都等于参数λ，这是泊松分布的重要特征',
        type: 'choice',
        difficulty: 'hard',
        source: '期末考试',
        createdAt: DateUtils.daysAgo(1),
        attemptCount: 0,
        wrongCount: 0
      },
      {
        id: 'q-008',
        courseName: '概率论与数理统计',
        chapter: '4.1 数学期望',
        knowledgePointId: 'kp-prob-001',
        question: '设连续型随机变量X的概率密度为f(x)=2x (0<x<1)，则E(X)等于？',
        options: ['A. 1/3', 'B. 2/3', 'C. 1/2', 'D. 1'],
        correctAnswer: 'B',
        explanation: 'E(X)=∫₀¹ x·2x dx = 2∫₀¹ x² dx = 2·(1/3) = 2/3',
        type: 'choice',
        difficulty: 'hard',
        source: '历年真题',
        createdAt: DateUtils.daysAgo(1),
        attemptCount: 0,
        wrongCount: 0
      }
    ]
  }

  static getSampleWrongQuestions(): WrongQuestion[] {
    return [
      {
        id: 'wq-001',
        questionId: 'q-003',
        question: '设随机变量X满足E(X)=3，E(X²)=13，则D(X)等于？',
        options: ['A. 4', 'B. 10', 'C. 13', 'D. 16'],
        correctAnswer: 'A',
        userAnswer: 'B',
        explanation: 'D(X)=E(X²)-[E(X)]²=13-9=4',
        courseName: '概率论与数理统计',
        chapter: '4.2 方差',
        knowledgePointId: 'kp-prob-003',
        knowledgePointTitle: '方差的定义与计算',
        wrongTime: DateUtils.daysAgo(1),
        reviewCount: 0,
        isMastered: false
      },
      {
        id: 'wq-002',
        questionId: 'q-005',
        question: '若X与Y相互独立，则Cov(X,Y)等于？',
        options: ['A. 1', 'B. E(XY)', 'C. 0', 'D. D(X)'],
        correctAnswer: 'C',
        userAnswer: 'B',
        explanation: 'X与Y独立时，E(XY)=E(X)E(Y)，因此Cov(X,Y)=E(XY)-E(X)E(Y)=0',
        courseName: '概率论与数理统计',
        chapter: '4.3 协方差与相关系数',
        knowledgePointId: 'kp-prob-005',
        knowledgePointTitle: '协方差',
        wrongTime: DateUtils.daysAgo(1),
        reviewCount: 1,
        isMastered: false
      }
    ]
  }
}
