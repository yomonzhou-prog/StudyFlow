/**
 * StudyFlow OS - DeepSeek API 客户端
 * 底层HTTP通信，不直接被页面调用，必须通过Agent服务层访问
 */

import { http } from '@kit.NetworkKit'
import { Constants } from '../common/Constants'

export interface DeepSeekMessage {
  role: 'system' | 'user' | 'assistant'
  content: string
}

export interface DeepSeekRequest {
  messages: DeepSeekMessage[]
  temperature?: number
  max_tokens?: number
}

export interface DeepSeekResponse {
  success: boolean
  content: string
  errorMessage: string
  isMockFallback: boolean
  errorType?: 'mock' | 'api_error' | 'network_error'
}

export interface DeepSeekChatOptions {
  responseFormat?: 'json' | 'text'
}

// Internal typed interfaces for API request/response
interface DeepSeekApiMessage {
  role: string
  content: string
}

interface DeepSeekResponseFormat {
  type: string
}

interface DeepSeekApiRequest {
  model: string
  messages: DeepSeekApiMessage[]
  temperature: number
  max_tokens: number
  response_format?: DeepSeekResponseFormat
}

interface DeepSeekApiChoiceMessage {
  content: string
}

interface DeepSeekApiChoice {
  message: DeepSeekApiChoiceMessage
}

interface DeepSeekApiResponse {
  choices: DeepSeekApiChoice[]
}

export class DeepSeekClient {
  private static instance: DeepSeekClient

  static getInstance(): DeepSeekClient {
    if (!DeepSeekClient.instance) {
      DeepSeekClient.instance = new DeepSeekClient()
    }
    return DeepSeekClient.instance
  }

  /**
   * 多轮对话 - 带历史消息的聊天请求
   * 页面层不得直接调用此方法，必须通过Agent服务层
   */
  async chatWithHistory(systemPrompt: string, messages: DeepSeekMessage[], options?: DeepSeekChatOptions): Promise<DeepSeekResponse> {
    // 检查API Key
    if (!Constants.DEEPSEEK_API_KEY || Constants.DEEPSEEK_API_KEY.length === 0) {
      return {
        success: false,
        content: '',
        errorMessage: 'DeepSeek API Key 未配置，自动切换 MockData',
        isMockFallback: true,
        errorType: 'mock'
      }
    }

    // 检查Mock模式
    if (Constants.USE_MOCK) {
      return {
        success: false,
        content: '',
        errorMessage: 'Mock模式启用中',
        isMockFallback: true,
        errorType: 'mock'
      }
    }

    try {
      const httpRequest = http.createHttp()

      // Build API messages: system prompt first, then conversation history
      const apiMessages: DeepSeekApiMessage[] = [
        { role: 'system', content: systemPrompt },
        ...messages.map(m => ({ role: m.role, content: m.content } as DeepSeekApiMessage))
      ]

      // Build request body - only include response_format for JSON mode
      const fmt: 'json' | 'text' = options?.responseFormat || 'json'
      const responseFmt: DeepSeekResponseFormat = { type: 'json_object' }
      const requestBody: DeepSeekApiRequest = {
        model: Constants.DEEPSEEK_MODEL,
        messages: apiMessages,
        temperature: 0.3,
        max_tokens: 4096
      }
      if (fmt === 'json') {
        requestBody.response_format = responseFmt
      }

      const response = await httpRequest.request(
        Constants.DEEPSEEK_API_URL,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${Constants.DEEPSEEK_API_KEY}`
          },
          extraData: JSON.stringify(requestBody),
          expectDataType: http.HttpDataType.STRING,
          connectTimeout: 30000,
          readTimeout: 60000
        }
      )

      httpRequest.destroy()

      if (response.responseCode === 200) {
        const responseBody: DeepSeekApiResponse = JSON.parse(response.result as string) as DeepSeekApiResponse
        const content: string = responseBody.choices?.[0]?.message?.content || ''

        return {
          success: true,
          content: content,
          errorMessage: '',
          isMockFallback: false
        }
      } else {
        return {
          success: false,
          content: '',
          errorMessage: `API返回错误: HTTP ${response.responseCode}`,
          isMockFallback: true,
          errorType: 'api_error'
        }
      }
    } catch (error) {
      console.error('DeepSeekClient.chatWithHistory error:', JSON.stringify(error))
      return {
        success: false,
        content: '',
        errorMessage: `网络请求失败: ${JSON.stringify(error)}`,
        isMockFallback: true,
        errorType: 'network_error'
      }
    }
  }

  /**
   * 单轮对话 - 发送聊天请求（兼容旧接口）
   */
  async chat(systemPrompt: string, userMessage: string, options?: DeepSeekChatOptions): Promise<DeepSeekResponse> {
    return this.chatWithHistory(systemPrompt, [{ role: 'user', content: userMessage }], options)
  }

  /**
   * 检查API是否可用
   */
  isAvailable(): boolean {
    return Constants.DEEPSEEK_API_KEY.length > 0 && !Constants.USE_MOCK
  }
}
