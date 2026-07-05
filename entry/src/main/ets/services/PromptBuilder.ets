/**
 * StudyFlow OS - Prompt构建器
 * 为不同的AI任务构建结构化的System Prompt和User Message
 * 所有Prompt都要求DeepSeek输出严格JSON
 */

import { CourseMaterial } from '../models/CourseMaterial'
import { CourseProfile } from '../models/CourseProfile'
import { LearningFeedback } from '../models/LearningFeedback'
import { KnowledgePoint } from '../models/KnowledgePoint'

interface KpSummary {
  id: string
  title: string
  chapter: string
  explanation: string
  importance: string
  difficulty: string
  commonMistakes: string[]
}

export class PromptBuilder {
  /**
   * 课程解析系统提示
   */
  static courseAnalysisSystemPrompt(): string {
    return `你是一个专业的大学课程分析助手。你需要对输入的课程资料进行结构化解析。

你必须严格按照以下JSON格式输出，不要输出任何其他内容：

{
  "courseName": "课程名称",
  "summary": "100-200字的课程内容摘要",
  "chapters": [
    {
      "title": "章节标题",
      "order": 1,
      "summary": "该章节的核心内容描述",
      "knowledgePointIds": ["kp-1", "kp-2"]
    }
  ],
  "knowledgePoints": [
    {
      "id": "kp-1",
      "title": "知识点名称",
      "chapter": "所属章节标题",
      "explanation": "该知识点的详细解释",
      "importance": "critical|high|medium|low",
      "difficulty": "hard|medium|easy",
      "commonMistakes": ["常见错误1", "常见错误2"],
      "relatedKnowledgePointIds": [],
      "order": 1
    }
  ],
  "examFocuses": [
    {
      "topic": "考点名称",
      "importance": "critical|high|medium",
      "description": "考试重点描述和预测分值"
    }
  ],
  "homeworkTasks": [
    {
      "title": "作业任务标题",
      "deadline": "ISO格式日期",
      "description": "任务描述",
      "priority": "high|medium|low"
    }
  ],
  "riskWarnings": [
    {
      "level": "high|medium|low",
      "message": "学习风险描述",
      "suggestion": "改进建议"
    }
  ]
}

分析要求：
1. 知识点数量控制在5-12个之间
2. 重要程度标注要准确（核心考点 > 重要 > 一般 > 了解）
3. 常见错误要从学生角度出发
4. 风险提醒要具体、可操作
5. 所有文本使用中文`
  }

  /**
   * 构建课程解析用户消息
   */
  static buildCourseAnalysisUserMessage(material: CourseMaterial): string {
    return `请分析以下课程资料：

课程名称：${material.courseName}
资料标题：${material.title}
资料类型：${material.type}
资料内容：
${material.content}

请对该资料进行结构化解析，严格按照系统提示的JSON格式输出。`
  }

  /**
   * 复习卡片生成系统提示
   */
  static reviewCardSystemPrompt(): string {
    return `你是一个专业的学习测评助手。根据知识点列表，生成复习卡片和自测题。

你必须严格按照以下JSON格式输出：

{
  "reviewCards": [
    {
      "knowledgePointId": "对应的知识点ID",
      "knowledgePointTitle": "知识点标题",
      "knowledgePointExplanation": "知识点简要解释（50字以内）",
      "keyReminder": "该知识点最需要记住的一句话",
      "commonMistakes": ["常见错误1"],
      "quiz": {
        "question": "自测题目",
        "options": ["A. 选项A", "B. 选项B", "C. 选项C", "D. 选项D"],
        "correctAnswer": "正确选项字母",
        "explanation": "答案解析",
        "type": "choice"
      },
      "nextReviewSuggestion": "下次复习建议"
    }
  ]
}

出题要求：
1. 每题4个选项，单选题
2. 题目要有区分度，不能太简单
3. 答案解析要清楚说明为什么对、为什么错
4. 重点考察概念理解和应用能力
5. 不要出纯记忆题`
  }

  /**
   * 构建复习卡片生成用户消息
   */
  static buildReviewCardUserMessage(knowledgePoints: KnowledgePoint[]): string {
    const kpList: KpSummary[] = knowledgePoints.map((kp: KnowledgePoint): KpSummary => {
      const item: KpSummary = {
        id: kp.id,
        title: kp.title,
        chapter: kp.chapter,
        explanation: kp.explanation,
        importance: kp.importance,
        difficulty: kp.difficulty,
        commonMistakes: kp.commonMistakes
      }
      return item
    })

    return `请根据以下知识点列表生成复习卡片和自测题：

${JSON.stringify(kpList, null, 2)}

请为每个知识点生成一张复习卡片，严格按照系统提示的JSON格式输出。`
  }

  /**
   * 反馈分析系统提示
   */
  static feedbackAnalysisSystemPrompt(): string {
    return `你是一个学习反馈分析专家。根据学生的学习反馈，生成二次复习计划。

你必须严格按照以下JSON格式输出：

{
  "analysis": "对学习反馈的总体分析（50-100字）",
  "nextSteps": [
    {
      "knowledgePointId": "知识点ID",
      "action": "review|relearn|practice|skip",
      "reason": "采取此行动的原因",
      "suggestedDate": "建议复习日期（ISO格式）",
      "estimatedMinutes": 30
    }
  ],
  "newTasks": [
    {
      "title": "任务标题",
      "description": "任务描述",
      "priority": "high|medium|low",
      "estimatedMinutes": 45,
      "sourceType": "weakness",
      "relatedKnowledgePointIds": ["kp-id"]
    }
  ],
  "summary": "二次复习的总体建议（50字以内）"
}

分析要求：
1. 已掌握的知识点建议3-5天后简短回顾
2. 还模糊的知识点建议24小时内重新学习
3. 做错了的知识点建议立即重新学习全章
4. 生成的新任务要具体、可执行`
  }

  /**
   * 构建反馈分析用户消息
   */
  static buildFeedbackAnalysisUserMessage(feedbacks: LearningFeedback[]): string {
    return `请分析以下学习反馈并生成二次复习计划：

${JSON.stringify(feedbacks, null, 2)}

请严格按照系统提示的JSON格式输出二次复习计划。`
  }
}
