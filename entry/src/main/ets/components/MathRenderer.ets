/**
 * StudyFlow OS — LaTeX 数学公式渲染组件
 *
 * 将含 $...$（行内）和 $$...$$（独立）的文本渲染为格式化数学内容。
 * 在当前 HarmonyOS NEXT 版本中，由于缺少 WebView/Canvas 的完整 LaTeX 库，
 * 本组件采用"解析+Unicode映射+分段Text"的渐进式方案：
 *
 *   - 行内公式 `$...$` → 蓝色斜体 Text span
 *   - 独立公式 `$$...$$` → 居中卡片 + 蓝色等宽 Text
 *   - 普通文本 → 默认样式 Text span
 *
 * 未来可升级为 WebView + KaTeX 方案以获得真正的 LaTeX 排版效果。
 */

import { StudyTheme } from '../common/StudyTheme'

// ─── LaTeX → Unicode 常用符号映射 ───

const LATEX_UNICODE_MAP: Record<string, string> = {
  // 希腊字母
  '\\alpha': 'α', '\\beta': 'β', '\\gamma': 'γ', '\\delta': 'δ',
  '\\epsilon': 'ε', '\\zeta': 'ζ', '\\eta': 'η', '\\theta': 'θ',
  '\\iota': 'ι', '\\kappa': 'κ', '\\lambda': 'λ', '\\mu': 'μ',
  '\\nu': 'ν', '\\xi': 'ξ', '\\pi': 'π', '\\rho': 'ρ',
  '\\sigma': 'σ', '\\tau': 'τ', '\\upsilon': 'υ', '\\phi': 'φ',
  '\\chi': 'χ', '\\psi': 'ψ', '\\omega': 'ω',
  '\\Gamma': 'Γ', '\\Delta': 'Δ', '\\Theta': 'Θ', '\\Lambda': 'Λ',
  '\\Xi': 'Ξ', '\\Pi': 'Π', '\\Sigma': 'Σ', '\\Phi': 'Φ',
  '\\Psi': 'Ψ', '\\Omega': 'Ω',
  // 运算符
  '\\times': '×', '\\cdot': '·', '\\pm': '±', '\\mp': '∓',
  '\\div': '÷', '\\ast': '∗', '\\star': '⋆', '\\circ': '∘',
  '\\bullet': '•', '\\oplus': '⊕', '\\ominus': '⊖', '\\otimes': '⊗',
  '\\odot': '⊙', '\\oslash': '⊘',
  // 关系符
  '\\leq': '≤', '\\geq': '≥', '\\neq': '≠', '\\approx': '≈',
  '\\equiv': '≡', '\\sim': '∼', '\\propto': '∝', '\\ll': '≪',
  '\\gg': '≫', '\\doteq': '≐',
  // 集合
  '\\subset': '⊂', '\\supset': '⊃', '\\subseteq': '⊆', '\\supseteq': '⊇',
  '\\cap': '∩', '\\cup': '∪', '\\in': '∈', '\\notin': '∉',
  '\\forall': '∀', '\\exists': '∃', '\\emptyset': '∅',
  // 箭头
  '\\rightarrow': '→', '\\Rightarrow': '⇒', '\\leftarrow': '←',
  '\\Leftarrow': '⇐', '\\leftrightarrow': '↔', '\\mapsto': '↦',
  // 积分/求和/乘积
  '\\int': '∫', '\\iint': '∬', '\\iiint': '∭', '\\oint': '∮',
  '\\sum': '∑', '\\prod': '∏', '\\coprod': '∐',
  // 微积分
  '\\partial': '∂', '\\nabla': '∇', '\\infty': '∞',
  '\\lim': 'lim', '\\max': 'max', '\\min': 'min', '\\sup': 'sup', '\\inf': 'inf',
  // 其他
  '\\angle': '∠', '\\triangle': '△', '\\square': '□',
  '\\ldots': '…', '\\cdots': '⋯', '\\vdots': '⋮', '\\ddots': '⋱',
  '\\therefore': '∴', '\\because': '∵',
  '\\degree': '°', '\\prime': '′',
}

// ─── 解析结果分段 ───

export enum MathSegmentType {
  TEXT = 'text',
  INLINE_MATH = 'inline_math',
  DISPLAY_MATH = 'display_math',
}

export interface MathSegment {
  type: MathSegmentType
  content: string
}

// ─── 解析器 ───

function parseLatexSegments(text: string): MathSegment[] {
  const segments: MathSegment[] = []
  // 正则匹配 $$...$$（独立）和 $...$（行内）
  const regex = /(\$\$[\s\S]*?\$\$|\$[^$\n]+?\$)/g
  let lastIndex = 0
  let match: RegExpExecArray | null

  while ((match = regex.exec(text)) !== null) {
    // 前面的普通文本
    if (match.index > lastIndex) {
      const before = text.substring(lastIndex, match.index)
      if (before) segments.push({ type: MathSegmentType.TEXT, content: before })
    }

    const raw = match[0]
    if (raw.startsWith('$$') && raw.endsWith('$$')) {
      const inner = raw.slice(2, -2).trim()
      segments.push({ type: MathSegmentType.DISPLAY_MATH, content: inner })
    } else {
      const inner = raw.slice(1, -1).trim()
      segments.push({ type: MathSegmentType.INLINE_MATH, content: inner })
    }

    lastIndex = match.index + match[0].length
  }

  // 剩余的普通文本
  if (lastIndex < text.length) {
    const after = text.substring(lastIndex)
    if (after) segments.push({ type: MathSegmentType.TEXT, content: after })
  }

  // 如果没有匹配到任何公式，整体作为纯文本
  if (segments.length === 0 && text.length > 0) {
    segments.push({ type: MathSegmentType.TEXT, content: text })
  }

  return segments
}

// ─── LaTeX 符号转 Unicode ───

function translateLatexToUnicode(latex: string): string {
  let result = latex
  // 按长度降序排序，优先匹配长命令
  const keys = Object.keys(LATEX_UNICODE_MAP).sort((a, b) => b.length - a.length)
  for (const key of keys) {
    // 使用全局替换
    const escaped = key.replace(/\\/g, '\\\\')
    result = result.replace(new RegExp(escaped, 'g'), LATEX_UNICODE_MAP[key])
  }
  // 去除花括号
  result = result.replace(/[{}]/g, '')
  // 处理下标 _{} 和上标 ^{}
  result = result.replace(/_\{([^}]+)\}/g, '₍$1₎')
  result = result.replace(/\^\{([^}]+)\}/g, '⁽$1⁾')
  // 处理简单下标 _x 和上标 ^x（单个字符）
  result = result.replace(/_(\d|[a-zA-Z])/g, (_m: string, c: string) => {
    const subscripts: Record<string, string> = {
      '0': '₀','1':'₁','2':'₂','3':'₃','4':'₄','5':'₅','6':'₆','7':'₇','8':'₈','9':'₉',
      'a':'ₐ','e':'ₑ','i':'ᵢ','o':'ₒ','u':'ᵤ','x':'ₓ','n':'ₙ','k':'ₖ','m':'ₘ',
    }
    return subscripts[c] || `_${c}`
  })
  result = result.replace(/\^(\d|[a-zA-Z+\-])/g, (_m: string, c: string) => {
    const superscripts: Record<string, string> = {
      '0':'⁰','1':'¹','2':'²','3':'³','4':'⁴','5':'⁵','6':'⁶','7':'⁷','8':'⁸','9':'⁹',
      '+':'⁺','-':'⁻','n':'ⁿ','i':'ⁱ',
    }
    return superscripts[c] || `^${c}`
  })
  // 处理分数 \frac{a}{b}
  result = result.replace(/\\frac\{([^}]+)\}\{([^}]+)\}/g, '($1)/($2)')
  // 处理根号 \sqrt{x}
  result = result.replace(/\\sqrt\{([^}]+)\}/g, '√($1)')
  // 处理 \bar, \hat, \vec, \dot
  result = result.replace(/\\bar\{([^}]+)\}/g, '$1̄')
  result = result.replace(/\\hat\{([^}]+)\}/g, '$1̂')
  result = result.replace(/\\vec\{([^}]+)\}/g, '$1⃗')
  result = result.replace(/\\dot\{([^}]+)\}/g, '$1̇')
  return result
}

// ─── 组件 ───

@Component
export struct MathRenderer {
  @Prop text: string = ''
  @Prop fontSize: number = StudyTheme.FONT_MD
  @Prop fontColor: string = StudyTheme.TEXT_PRIMARY
  @Prop lineHeight: number = 24

  build() {
    Column() {
      if (this.text.length === 0) {
        // 空文本不渲染
      } else {
        ForEach(parseLatexSegments(this.text), (seg: MathSegment, index: number) => {
          if (seg.type === MathSegmentType.DISPLAY_MATH) {
            // 独立公式：居中卡片
            Row() {
              Text(translateLatexToUnicode(seg.content))
                .fontSize(this.fontSize + 2)
                .fontColor(StudyTheme.ACCENT)
                .fontFamily('monospace')
                .lineHeight(this.lineHeight + 4)
                .width('100%')
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding({ top: StudyTheme.SPACE_MD, bottom: StudyTheme.SPACE_MD })
            .margin({ top: StudyTheme.SPACE_SM, bottom: StudyTheme.SPACE_SM })
            .backgroundColor(StudyTheme.ACCENT_BG)
            .borderRadius(StudyTheme.RADIUS_SM)
          } else if (seg.type === MathSegmentType.INLINE_MATH) {
            // 行内公式：蓝色斜体
            Text(translateLatexToUnicode(seg.content))
              .fontSize(this.fontSize)
              .fontColor(StudyTheme.ACCENT)
              .fontStyle(FontStyle.Italic)
              .lineHeight(this.lineHeight)
          } else {
            // 普通文本
            Text(seg.content)
              .fontSize(this.fontSize)
              .fontColor(this.fontColor)
              .lineHeight(this.lineHeight)
          }
        }, (seg: MathSegment, index: number) => `math_seg_${index}_${seg.type}`)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

// ─── 便捷函数：纯文本中的 LaTeX 渲染 ───

@Builder
export function MathText(text: string, fontSize: number, fontColor?: string) {
  MathRenderer({
    text: text,
    fontSize: fontSize,
    fontColor: fontColor || StudyTheme.TEXT_PRIMARY,
  })
}

// ─── 便捷函数：判断文本是否包含 LaTeX ───

export function hasLatex(text: string): boolean {
  return /\$[^$\n]+?\$|\$\$[\s\S]*?\$\$/.test(text)
}
