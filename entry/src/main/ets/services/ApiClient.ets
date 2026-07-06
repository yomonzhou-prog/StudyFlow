/**
 * StudyFlow OS — 后端 API 通信客户端
 * 统一封装所有后端接口调用，供页面层使用
 */

import { http } from '@kit.NetworkKit'
import { fileIo } from '@kit.CoreFileKit'
import { util } from '@kit.ArkTS'

// ─── 后端服务地址（开发环境） ───
const API_BASE: string = 'http://10.0.2.2:8000/api'

// ─── 通用 JSON 响应 ───

interface RawApiResponse {
  success: boolean
  error_message: string
}

// ─── 场景一：试卷解析 ───

export interface ParseDocumentResult {
  courseName: string
  cards: QuestionCardDTO[]
  totalCount: number
}

export interface QuestionCardDTO {
  id: string
  course_name: string
  question: string
  options: string[]
  answer: string
  explanation: string
  related_knowledge: string[]
  difficulty: string
  common_mistake: string
  source_paper_id: string
  created_at: string
}

interface ParseDocumentRaw extends RawApiResponse {
  course_name: string
  cards: QuestionCardDTO[]
  total_count: number
}

// ─── 场景二：知识图谱 ───

export interface GraphNodeDTO {
  id: string
  label: string
  level: number
  parent_id: string
  importance: string
  is_highlight: boolean
  summary: string
  divergent_cards: QuestionCardDTO[]
}

export interface GraphEdgeDTO {
  source_id: string
  target_id: string
  relation: string
}

export interface KnowledgeGraphResult {
  courseName: string
  nodes: GraphNodeDTO[]
  edges: GraphEdgeDTO[]
}

interface KnowledgeGraphRaw extends RawApiResponse {
  course_name: string
  nodes: GraphNodeDTO[]
  edges: GraphEdgeDTO[]
}

// ─── 场景三：学习规划 ───

export interface StudyTaskDTO {
  id: string
  day_index: number
  date_label: string
  title: string
  description: string
  course_name: string
  estimated_minutes: number
  priority: string
  knowledge_points: string[]
  status: string
  tip: string
}

export interface PlannerChatResult {
  sessionId: string
  reply: string
  dailyTasks: StudyTaskDTO[]
  summary: string
}

interface PlannerChatRaw extends RawApiResponse {
  session_id: string
  reply: string
  daily_tasks: StudyTaskDTO[]
  summary: string
}

// ─── 历史消息 ───

export interface ChatHistoryItem {
  role: string
  content: string
}

// ─── 规划上下文 ───

export interface PlannerContext {
  courseName: string
  examDate: string
  availableDays: number
  dailyHours: number
  knownWeaknesses: string[]
}

// ─── 上传请求体 ───

interface UploadRequestBody {
  file_name: string
  file_content_base64: string
  course_name: string
}

// ─── 图谱请求体 ───

interface GraphRequestBody {
  textbook_content: string
  teacher_highlights: string
  course_name: string
}

// ─── 规划请求体 ───

interface PlannerRequestBody {
  session_id: string
  message: string
  course_name: string
  exam_date: string
  available_days: number
  daily_hours: number
  known_weaknesses: string[]
  history: ChatHistoryItem[]
}

// ─── 公共响应 ───

export interface ApiResponse<T> {
  success: boolean
  data: T
  errorMessage: string
}

// ─── 客户端类 ───

export class ApiClient {
  private static instance: ApiClient

  static getInstance(): ApiClient {
    if (!ApiClient.instance) {
      ApiClient.instance = new ApiClient()
    }
    return ApiClient.instance
  }

  // ─── 底层 POST JSON ───

  private async postJson(path: string, body: object): Promise<string> {
    const req = http.createHttp()
    const resp = await req.request(
      API_BASE + path,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        extraData: JSON.stringify(body),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 30000,
        readTimeout: 120000,
      }
    )
    req.destroy()

    if (resp.responseCode === 200) {
      return resp.result as string
    }
    return ''
  }

  // ─── 解析 JSON ───

  private parseRaw(raw: string): RawApiResponse {
    if (raw.length === 0) {
      const empty: RawApiResponse = { success: false, error_message: '服务器无响应' }
      return empty
    }
    const obj = JSON.parse(raw) as Record<string, Object>
    const success: boolean = (obj['success'] as boolean) || false
    const error_message: string = (obj['error_message'] as string) || ''
    const result: RawApiResponse = { success: success, error_message: error_message }
    return result
  }

  // ─── 场景一：解析试卷 ───

  async parseDocument(fileUri: string, fileName: string, courseName: string): Promise<ApiResponse<ParseDocumentResult>> {
    try {
      // 读取文件
      const file: fileIo.File = fileIo.openSync(fileUri, fileIo.OpenMode.READ_ONLY)
      const stat: fileIo.Stat = fileIo.statSync(fileUri)
      const buf = new ArrayBuffer(stat.size)
      fileIo.readSync(file.fd, buf)
      fileIo.closeSync(file)

      // base64 编码
      const base64Helper = new util.Base64Helper()
      const base64Content: string = base64Helper.encodeToStringSync(new Uint8Array(buf))

      const body: UploadRequestBody = {
        file_name: fileName,
        file_content_base64: base64Content,
        course_name: courseName,
      }

      const rawStr: string = await this.postJson('/parse-document-json', body)
      const rawResp: RawApiResponse = this.parseRaw(rawStr)

      if (!rawResp.success) {
        const failResult: ApiResponse<ParseDocumentResult> = {
          success: false,
          data: { courseName: '', cards: [], totalCount: 0 },
          errorMessage: rawResp.error_message,
        }
        return failResult
      }

      const obj = JSON.parse(rawStr) as Record<string, Object>
      const raw: ParseDocumentRaw = {
        success: true,
        error_message: '',
        course_name: (obj['course_name'] as string) || '',
        cards: (obj['cards'] as QuestionCardDTO[]) || [],
        total_count: (obj['total_count'] as number) || 0,
      }

      const data: ParseDocumentResult = {
        courseName: raw.course_name,
        cards: raw.cards,
        totalCount: raw.total_count,
      }
      const result: ApiResponse<ParseDocumentResult> = { success: true, data: data, errorMessage: '' }
      return result

    } catch (error) {
      const failResult: ApiResponse<ParseDocumentResult> = {
        success: false,
        data: { courseName: '', cards: [], totalCount: 0 },
        errorMessage: `文件处理失败: ${JSON.stringify(error)}`,
      }
      return failResult
    }
  }

  // ─── 场景二：生成知识图谱 ───

  async generateGraph(textbookContent: string, teacherHighlights: string, courseName: string): Promise<ApiResponse<KnowledgeGraphResult>> {
    try {
      const body: GraphRequestBody = {
        textbook_content: textbookContent,
        teacher_highlights: teacherHighlights,
        course_name: courseName,
      }

      const rawStr: string = await this.postJson('/generate-graph', body)
      const rawResp: RawApiResponse = this.parseRaw(rawStr)

      if (!rawResp.success) {
        const failResult: ApiResponse<KnowledgeGraphResult> = {
          success: false,
          data: { courseName: '', nodes: [], edges: [] },
          errorMessage: rawResp.error_message,
        }
        return failResult
      }

      const obj = JSON.parse(rawStr) as Record<string, Object>
      const raw: KnowledgeGraphRaw = {
        success: true,
        error_message: '',
        course_name: (obj['course_name'] as string) || '',
        nodes: (obj['nodes'] as GraphNodeDTO[]) || [],
        edges: (obj['edges'] as GraphEdgeDTO[]) || [],
      }

      const data: KnowledgeGraphResult = {
        courseName: raw.course_name,
        nodes: raw.nodes,
        edges: raw.edges,
      }
      const result: ApiResponse<KnowledgeGraphResult> = { success: true, data: data, errorMessage: '' }
      return result

    } catch (error) {
      const failResult: ApiResponse<KnowledgeGraphResult> = {
        success: false,
        data: { courseName: '', nodes: [], edges: [] },
        errorMessage: `图谱生成失败: ${JSON.stringify(error)}`,
      }
      return failResult
    }
  }

  // ─── 场景三：学习规划对话 ───

  async chatPlanner(
    sessionId: string,
    message: string,
    history: ChatHistoryItem[],
    context: PlannerContext,
  ): Promise<ApiResponse<PlannerChatResult>> {
    try {
      const body: PlannerRequestBody = {
        session_id: sessionId,
        message: message,
        course_name: context.courseName,
        exam_date: context.examDate,
        available_days: context.availableDays,
        daily_hours: context.dailyHours,
        known_weaknesses: context.knownWeaknesses,
        history: history,
      }

      const rawStr: string = await this.postJson('/chat-planner', body)
      const rawResp: RawApiResponse = this.parseRaw(rawStr)

      if (!rawResp.success) {
        const failResult: ApiResponse<PlannerChatResult> = {
          success: false,
          data: { sessionId: '', reply: '', dailyTasks: [], summary: '' },
          errorMessage: rawResp.error_message,
        }
        return failResult
      }

      const obj = JSON.parse(rawStr) as Record<string, Object>
      const raw: PlannerChatRaw = {
        success: true,
        error_message: '',
        session_id: (obj['session_id'] as string) || '',
        reply: (obj['reply'] as string) || '',
        daily_tasks: (obj['daily_tasks'] as StudyTaskDTO[]) || [],
        summary: (obj['summary'] as string) || '',
      }

      const data: PlannerChatResult = {
        sessionId: raw.session_id,
        reply: raw.reply,
        dailyTasks: raw.daily_tasks,
        summary: raw.summary,
      }
      const result: ApiResponse<PlannerChatResult> = { success: true, data: data, errorMessage: '' }
      return result

    } catch (error) {
      const failResult: ApiResponse<PlannerChatResult> = {
        success: false,
        data: { sessionId: '', reply: '', dailyTasks: [], summary: '' },
        errorMessage: `对话失败: ${JSON.stringify(error)}`,
      }
      return failResult
    }
  }

  // ─── 健康检查 ───

  async healthCheck(): Promise<boolean> {
    try {
      const req = http.createHttp()
      const resp = await req.request(
        API_BASE + '/health',
        { method: http.RequestMethod.GET, connectTimeout: 5000, readTimeout: 5000 }
      )
      req.destroy()
      return resp.responseCode === 200
    } catch (err) {
      return false
    }
  }
}
