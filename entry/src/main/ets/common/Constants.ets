/**
 * StudyFlow OS - 全局常量定义
 */

export class Constants {
  // DeepSeek API
  static readonly DEEPSEEK_API_URL: string = 'https://api.deepseek.com/v1/chat/completions'
  static readonly DEEPSEEK_MODEL: string = 'deepseek-chat'
  static readonly DEEPSEEK_API_KEY: string = 'sk-7b9291e6c67942baa11b6748eb09a32b' // 用户自行填入

  // 应用配置
  static readonly APP_NAME: string = 'StudyFlow OS'
  static readonly APP_VERSION: string = '1.0.0'

  // 资料类型
  static readonly MATERIAL_TYPES: string[] = [
    'ppt', 'textbook', 'notice', 'homework', 'exam', 'wrong_question'
  ]

  static readonly MATERIAL_TYPE_LABELS: Record<string, string> = {
    'ppt': 'PPT课件',
    'textbook': '教材',
    'notice': '通知',
    'homework': '作业',
    'exam': '考试范围',
    'wrong_question': '错题'
  }

  // 优先级
  static readonly PRIORITY_HIGH: string = 'high'
  static readonly PRIORITY_MEDIUM: string = 'medium'
  static readonly PRIORITY_LOW: string = 'low'

  static readonly PRIORITY_LABELS: Record<string, string> = {
    'high': '高优先级',
    'medium': '中优先级',
    'low': '低优先级'
  }

  // 难度
  static readonly DIFFICULTY_HARD: string = 'hard'
  static readonly DIFFICULTY_MEDIUM: string = 'medium'
  static readonly DIFFICULTY_EASY: string = 'easy'

  static readonly DIFFICULTY_LABELS: Record<string, string> = {
    'hard': '困难',
    'medium': '中等',
    'easy': '简单'
  }

  // 重要程度
  static readonly IMPORTANCE_CRITICAL: string = 'critical'
  static readonly IMPORTANCE_HIGH: string = 'high'
  static readonly IMPORTANCE_MEDIUM: string = 'medium'
  static readonly IMPORTANCE_LOW: string = 'low'

  static readonly IMPORTANCE_LABELS: Record<string, string> = {
    'critical': '核心考点',
    'high': '重要',
    'medium': '一般',
    'low': '了解'
  }

  // 反馈状态
  static readonly FEEDBACK_MASTERED: string = 'mastered'
  static readonly FEEDBACK_FUZZY: string = 'fuzzy'
  static readonly FEEDBACK_WRONG: string = 'wrong'

  static readonly FEEDBACK_LABELS: Record<string, string> = {
    'mastered': '已掌握',
    'fuzzy': '还模糊',
    'wrong': '做错了'
  }

  // 任务状态
  static readonly TASK_PENDING: string = 'pending'
  static readonly TASK_IN_PROGRESS: string = 'in_progress'
  static readonly TASK_COMPLETED: string = 'completed'

  // Mock模式
  static readonly USE_MOCK: boolean = false
}
