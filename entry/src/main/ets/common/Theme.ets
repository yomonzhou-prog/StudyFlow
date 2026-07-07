/**
 * StudyFlow OS — 全局主题定义
 * 不背单词风格：暗色模式 + 暖金主色 + 毛玻璃质感
 */

export class Theme {
  // ═══ 主色调（暖金，替代 navy #1F3A5F）═══
  static readonly PRIMARY: string = '#C8A96E'
  static readonly PRIMARY_LIGHT: string = '#D4BC8A'
  static readonly PRIMARY_BG: string = '#2A2520'

  // ═══ 语义色（暗色模式适配）═══
  static readonly SUCCESS: string = '#5BAA70'
  static readonly SUCCESS_BG: string = '#1A2A1E'
  static readonly WARNING: string = '#D4A84B'
  static readonly WARNING_BG: string = '#2A2418'
  static readonly DANGER: string = '#D4695A'
  static readonly DANGER_BG: string = '#2A1E1C'

  // ═══ 文字（暖白系）═══
  static readonly TEXT_PRIMARY: string = '#E8E3DC'
  static readonly TEXT_SECONDARY: string = '#B8B0A5'
  static readonly TEXT_HINT: string = '#7A7368'
  static readonly TEXT_INVERSE: string = '#1B1A1F'

  // ═══ 背景（暗色暖底）═══
  static readonly BG: string = '#1B1A1F'
  static readonly CARD_BG: string = '#232127'
  static readonly DIVIDER: string = '#2E2B35'

  // ═══ 边框 ═══
  static readonly BORDER: string = '#36313C'

  // ═══ 优先级颜色 ═══
  static readonly PRIORITY_HIGH_COLOR: string = '#C8A96E'
  static readonly PRIORITY_MEDIUM_COLOR: string = '#D4A84B'
  static readonly PRIORITY_LOW_COLOR: string = '#7A7368'

  // ═══ 难度颜色 ═══
  static readonly DIFFICULTY_HARD_COLOR: string = '#D4695A'
  static readonly DIFFICULTY_MEDIUM_COLOR: string = '#D4A84B'
  static readonly DIFFICULTY_EASY_COLOR: string = '#5BAA70'

  // ═══ 重要度颜色 ═══
  static readonly IMPORTANCE_CRITICAL_COLOR: string = '#C8A96E'
  static readonly IMPORTANCE_HIGH_COLOR: string = '#D4695A'
  static readonly IMPORTANCE_MEDIUM_COLOR: string = '#D4A84B'
  static readonly IMPORTANCE_LOW_COLOR: string = '#7A7368'

  // ═══ 反馈颜色 ═══
  static readonly FEEDBACK_MASTERED_COLOR: string = '#5BAA70'
  static readonly FEEDBACK_FUZZY_COLOR: string = '#D4A84B'
  static readonly FEEDBACK_WRONG_COLOR: string = '#D4695A'

  // ═══ 间距 ═══
  static readonly SPACING_XS: number = 4
  static readonly SPACING_SM: number = 8
  static readonly SPACING_MD: number = 12
  static readonly SPACING_LG: number = 16
  static readonly SPACING_XL: number = 20
  static readonly SPACING_XXL: number = 24
  static readonly SPACING_XXXL: number = 36

  // ═══ 圆角 ═══
  static readonly RADIUS_SM: number = 8
  static readonly RADIUS_MD: number = 14
  static readonly RADIUS_LG: number = 20
  static readonly RADIUS_XL: number = 28

  // ═══ 字体 ═══
  static readonly FONT_XS: number = 11
  static readonly FONT_SM: number = 13
  static readonly FONT_MD: number = 15
  static readonly FONT_LG: number = 17
  static readonly FONT_XL: number = 20
  static readonly FONT_XXL: number = 24
  static readonly FONT_TITLE: number = 28
  static readonly FONT_DISPLAY: number = 36
  static readonly FONT_HERO: number = 48

  // ═══ 行高 ═══
  static readonly LINE_HEIGHT_TIGHT: number = 1.4
  static readonly LINE_HEIGHT_NORMAL: number = 1.7
  static readonly LINE_HEIGHT_RELAXED: number = 2.0

  // ═══ 阴影（暗色模式）═══
  static readonly SHADOW_CARD: string = '0 4px 20px rgba(0,0,0,0.40)'
  static readonly SHADOW_ELEVATED: string = '0 8px 32px rgba(0,0,0,0.55)'
}
