/**
 * StudyFlow OS - 全局主题定义
 */

export class Theme {
  // 主色调
  static readonly PRIMARY: string = '#1E40AF'        // 深蓝主色
  static readonly PRIMARY_LIGHT: string = '#3B82F6'  // 浅蓝
  static readonly PRIMARY_BG: string = '#EFF6FF'     // 蓝底

  // 功能色
  static readonly SUCCESS: string = '#059669'
  static readonly SUCCESS_BG: string = '#ECFDF5'
  static readonly WARNING: string = '#D97706'
  static readonly WARNING_BG: string = '#FFFBEB'
  static readonly DANGER: string = '#DC2626'
  static readonly DANGER_BG: string = '#FEF2F2'

  // 中性色
  static readonly TEXT_PRIMARY: string = '#111827'
  static readonly TEXT_SECONDARY: string = '#6B7280'
  static readonly TEXT_HINT: string = '#9CA3AF'
  static readonly BORDER: string = '#E5E7EB'
  static readonly BG: string = '#F9FAFB'
  static readonly CARD_BG: string = '#FFFFFF'
  static readonly DIVIDER: string = '#F3F4F6'

  // 优先级色
  static readonly PRIORITY_HIGH_COLOR: string = '#EF4444'
  static readonly PRIORITY_MEDIUM_COLOR: string = '#F59E0B'
  static readonly PRIORITY_LOW_COLOR: string = '#6B7280'

  // 难度色
  static readonly DIFFICULTY_HARD_COLOR: string = '#DC2626'
  static readonly DIFFICULTY_MEDIUM_COLOR: string = '#D97706'
  static readonly DIFFICULTY_EASY_COLOR: string = '#059669'

  // 重要程度色
  static readonly IMPORTANCE_CRITICAL_COLOR: string = '#7C3AED'
  static readonly IMPORTANCE_HIGH_COLOR: string = '#EF4444'
  static readonly IMPORTANCE_MEDIUM_COLOR: string = '#F59E0B'
  static readonly IMPORTANCE_LOW_COLOR: string = '#6B7280'

  // 反馈状态色
  static readonly FEEDBACK_MASTERED_COLOR: string = '#059669'
  static readonly FEEDBACK_FUZZY_COLOR: string = '#D97706'
  static readonly FEEDBACK_WRONG_COLOR: string = '#DC2626'

  // 间距
  static readonly SPACING_XS: number = 4
  static readonly SPACING_SM: number = 8
  static readonly SPACING_MD: number = 12
  static readonly SPACING_LG: number = 16
  static readonly SPACING_XL: number = 20
  static readonly SPACING_XXL: number = 24

  // 圆角
  static readonly RADIUS_SM: number = 6
  static readonly RADIUS_MD: number = 10
  static readonly RADIUS_LG: number = 16
  static readonly RADIUS_XL: number = 24

  // 字号
  static readonly FONT_XS: number = 11
  static readonly FONT_SM: number = 13
  static readonly FONT_MD: number = 15
  static readonly FONT_LG: number = 17
  static readonly FONT_XL: number = 20
  static readonly FONT_XXL: number = 24
  static readonly FONT_TITLE: number = 28

  // 阴影
  static readonly SHADOW_CARD: string = '0 2px 8px rgba(0,0,0,0.06)'
  static readonly SHADOW_ELEVATED: string = '0 4px 16px rgba(0,0,0,0.1)'
}
