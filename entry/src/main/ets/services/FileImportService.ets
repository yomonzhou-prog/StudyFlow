/**
 * StudyFlow OS — 文件导入服务
 *
 * 职责：系统文件选择 → multipart 上传后端 → 解析 JSON → 返回 QuestionCard[]
 * 页面层只调用此服务，不直接操作文件或 HTTP。
 */

import { http } from '@kit.NetworkKit'
import { fileIo, picker } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'
import { QuestionCard } from '../models/QuestionCard'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

// ═══════════════════════════════════════════════════
// 类型定义
// ═══════════════════════════════════════════════════

export interface ImportResult {
  success: boolean
  cards: QuestionCard[]
  courseName: string
  totalCount: number
  errorMessage: string
}

export interface FilePickResult {
  uri: string
  fileName: string
}

// ═══════════════════════════════════════════════════
// 后端地址
// ═══════════════════════════════════════════════════

const API_HOST: string = 'http://10.0.2.2:8000'

// ═══════════════════════════════════════════════════
// 单例服务
// ═══════════════════════════════════════════════════

export class FileImportService {
  private static instance: FileImportService

  static getInstance(): FileImportService {
    if (!FileImportService.instance) {
      FileImportService.instance = new FileImportService()
    }
    return FileImportService.instance
  }

  // ─── 第一步：系统文件选择器 ───

  async pickFile(): Promise<FilePickResult | null> {
    try {
      const docPicker = new picker.DocumentViewPicker()
      const uris: string[] = await docPicker.select({ maxSelectNumber: 1 })

      if (uris.length === 0) {
        return null
      }

      const uri: string = uris[0]
      const parts: string[] = uri.split('/')
      const fileName: string = parts[parts.length - 1]
      const result: FilePickResult = { uri: uri, fileName: fileName }
      return result
    } catch (err) {
      return null
    }
  }

  // ─── 第二步：multipart 上传 + 解析 ───

  async uploadAndParse(
    fileUri: string,
    fileName: string,
    courseName: string,
  ): Promise<ImportResult> {
    const isPdf: boolean = fileName.toLowerCase().endsWith('.pdf')
    const endpoint: string = isPdf ? '/api/upload-pdf' : '/api/upload-text'

    try {
      // 读取文件内容
      const file: fileIo.File = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY)
      const stat: fileIo.Stat = fileIo.statSync(fileUri)
      const fileBuf = new ArrayBuffer(stat.size)
      fileIo.readSync(file.fd, fileBuf)
      fileIo.closeSync(file)

      // 构建 multipart/form-data 请求体
      const boundary: string = '----StudyFlowBoundary' + Date.now().toString()
      const CRLF: string = '\r\n'

      // 将文件二进制转为 UTF-16 兼容的字节数组
      const fileBytes = new Uint8Array(fileBuf)
      const encoder = new util.TextEncoder()

      // 手动拼接 multipart body
      const parts: Uint8Array[] = []

      // Part 1: course_name 字段
      let header = `--${boundary}${CRLF}`
      header += `Content-Disposition: form-data; name="course_name"${CRLF}${CRLF}`
      header += `${courseName}${CRLF}`
      parts.push(encoder.encodeInto(header))

      // Part 2: file 字段
      const mimeType: string = isPdf ? 'application/pdf' : 'text/plain'
      let fileHeader = `--${boundary}${CRLF}`
      fileHeader += `Content-Disposition: form-data; name="file"; filename="${fileName}"${CRLF}`
      fileHeader += `Content-Type: ${mimeType}${CRLF}${CRLF}`
      parts.push(encoder.encodeInto(fileHeader))
      parts.push(fileBytes)

      // 结束边界
      parts.push(encoder.encodeInto(`${CRLF}--${boundary}--${CRLF}`))

      // 合并所有 part
      let totalLen: number = 0
      for (let i = 0; i < parts.length; i++) {
        totalLen += parts[i].length
      }
      const body = new Uint8Array(totalLen)
      let offset: number = 0
      for (let i = 0; i < parts.length; i++) {
        body.set(parts[i], offset)
        offset += parts[i].length
      }

      // HTTP POST
      const req = http.createHttp()
      const resp = await req.request(
        API_HOST + endpoint,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': `multipart/form-data; boundary=${boundary}`,
            'Accept': 'application/json',
          },
          extraData: body.buffer as ArrayBuffer,
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: 30000,
          readTimeout: 120000,
        },
      )
      req.destroy()

      if (resp.responseCode !== 200) {
        return {
          success: false,
          cards: [],
          courseName: '',
          totalCount: 0,
          errorMessage: `服务器返回 HTTP ${resp.responseCode}`,
        }
      }

      const jsonStr: string = resp.result as string
      if (jsonStr.length === 0) {
        return {
          success: false,
          cards: [],
          courseName: '',
          totalCount: 0,
          errorMessage: '服务器返回空内容',
        }
      }

      return this.parseResponseJson(jsonStr)

    } catch (err) {
      return {
        success: false,
        cards: [],
        courseName: '',
        totalCount: 0,
        errorMessage: `上传失败: ${JSON.stringify(err)}`,
      }
    }
  }

  // ─── JSON 解析 ───

  private parseResponseJson(jsonStr: string): ImportResult {
    const jsonObj: Record<string, Object> = JSON.parse(jsonStr) as Record<string, Object>
    const success: boolean = (jsonObj['success'] as boolean) || false

    if (!success) {
      return {
        success: false,
        cards: [],
        courseName: '',
        totalCount: 0,
        errorMessage: (jsonObj['error_message'] as string) || '未知错误',
      }
    }

    const courseNameResult: string = (jsonObj['course_name'] as string) || ''
    const rawCards: object[] = (jsonObj['cards'] as object[]) || []

    const cards: QuestionCard[] = []
    for (let i = 0; i < rawCards.length; i++) {
      const item: Record<string, Object> = rawCards[i] as Record<string, Object>

      let difficulty: 'easy' | 'medium' | 'hard' = 'medium'
      const diffStr: string = (item['difficulty'] as string) || 'medium'
      if (diffStr === 'hard') { difficulty = 'hard' }
      else if (diffStr === 'easy') { difficulty = 'easy' }

      const card: QuestionCard = {
        id: IdUtils.generate(),
        courseName: courseNameResult,
        question: (item['question'] as string) || '',
        options: (item['options'] as string[]) || [],
        answer: (item['answer'] as string) || '',
        explanation: (item['explanation'] as string) || '',
        relatedKnowledge: (item['related_knowledge'] as string[]) || [],
        difficulty: difficulty,
        commonMistake: (item['common_mistake'] as string) || '',
        sourcePaperId: (item['source_paper_id'] as string) || '',
        isWrong: false,
        reviewedCount: 0,
        lastResult: '',
        createdAt: DateUtils.now(),
      }
      cards.push(card)
    }

    return {
      success: true,
      cards: cards,
      courseName: courseNameResult,
      totalCount: cards.length,
      errorMessage: '',
    }
  }
}
