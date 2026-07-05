/**
 * StudyFlow OS - 认证状态管理
 * 管理用户登录、注册和游客模式
 * 当前为 Mock 登录流程
 */

import { UserProfile } from '../models/UserProfile'
import { IdUtils } from '../utils/IdUtils'
import { DateUtils } from '../utils/DateUtils'

export interface LoginResult {
  success: boolean
  message: string
  user?: UserProfile
}

export interface RegisterResult {
  success: boolean
  message: string
  user?: UserProfile
}

export interface UserStats {
  streak?: number
  totalStudyMinutes?: number
  totalCards?: number
  totalMastered?: number
}

export class AuthStore {
  private static instance: AuthStore

  private currentUser: UserProfile | null = null
  private users: UserProfile[] = []

  static getInstance(): AuthStore {
    if (!AuthStore.instance) {
      AuthStore.instance = new AuthStore()
    }
    return AuthStore.instance
  }

  /**
   * 初始化 Mock 用户数据
   */
  initMockData(): void {
    // 预置一个演示账号
    const demoUser: UserProfile = {
      id: 'user-demo-001',
      username: 'demo',
      email: 'demo@studyflow.cn',
      avatar: '📚',
      streak: 7,
      totalStudyMinutes: 320,
      totalCards: 48,
      totalMastered: 23,
      lastStudyDate: DateUtils.now(),
      createdAt: '2026-01-15T00:00:00.000Z',
      isLoggedIn: true,
      isGuest: false
    }
    this.users = [demoUser]
  }

  /**
   * Mock 登录
   * 用户名 demo + 密码任意6位以上即可登录
   */
  async login(username: string, password: string): Promise<LoginResult> {
    // 模拟网络延迟
    await this.delay(600)

    const emptyResult: LoginResult = { success: false, message: '' }

    if (!username.trim()) {
      emptyResult.message = '请输入用户名'
      return emptyResult
    }
    if (!password || password.length < 6) {
      emptyResult.message = '密码至少6位'
      return emptyResult
    }

    if (this.users.length === 0) {
      this.initMockData()
    }

    const foundUser = this.users.find(u => u.username === username.trim())
    if (foundUser) {
      foundUser.isLoggedIn = true
      foundUser.isGuest = false
      foundUser.lastStudyDate = DateUtils.now()
      this.currentUser = foundUser
      const result: LoginResult = { success: true, message: '登录成功', user: foundUser }
      return result
    }

    // 新用户直接用输入的用户名登录（Mock 模式）
    const newUser: UserProfile = {
      id: IdUtils.generate(),
      username: username.trim(),
      email: '',
      avatar: '📚',
      streak: 0,
      totalStudyMinutes: 0,
      totalCards: 0,
      totalMastered: 0,
      lastStudyDate: DateUtils.now(),
      createdAt: DateUtils.now(),
      isLoggedIn: true,
      isGuest: false
    }
    this.users.push(newUser)
    this.currentUser = newUser
    const result: LoginResult = { success: true, message: '登录成功（新用户）', user: newUser }
    return result
  }

  /**
   * Mock 注册
   */
  async register(username: string, email: string, password: string): Promise<RegisterResult> {
    await this.delay(800)

    const emptyResult: RegisterResult = { success: false, message: '' }

    if (!username.trim()) {
      emptyResult.message = '请输入用户名'
      return emptyResult
    }
    if (username.trim().length < 2) {
      emptyResult.message = '用户名至少2个字符'
      return emptyResult
    }
    if (!password || password.length < 6) {
      emptyResult.message = '密码至少6位'
      return emptyResult
    }

    if (this.users.length === 0) {
      this.initMockData()
    }

    const exists = this.users.find(u => u.username === username.trim())
    if (exists) {
      emptyResult.message = '该用户名已被注册'
      return emptyResult
    }

    const newUser: UserProfile = {
      id: IdUtils.generate(),
      username: username.trim(),
      email: email.trim(),
      avatar: this.getRandomAvatar(),
      streak: 0,
      totalStudyMinutes: 0,
      totalCards: 0,
      totalMastered: 0,
      lastStudyDate: DateUtils.now(),
      createdAt: DateUtils.now(),
      isLoggedIn: true,
      isGuest: false
    }

    this.users.push(newUser)
    this.currentUser = newUser
    const result: RegisterResult = { success: true, message: '注册成功！', user: newUser }
    return result
  }

  /**
   * 游客模式登录
   */
  loginAsGuest(): void {
    const guestUser: UserProfile = {
      id: `guest-${IdUtils.shortId()}`,
      username: '游客',
      email: '',
      avatar: '🎒',
      streak: 0,
      totalStudyMinutes: 0,
      totalCards: 0,
      totalMastered: 0,
      lastStudyDate: DateUtils.now(),
      createdAt: DateUtils.now(),
      isLoggedIn: true,
      isGuest: true
    }
    this.currentUser = guestUser
  }

  /**
   * 登出
   */
  logout(): void {
    if (this.currentUser) {
      this.currentUser.isLoggedIn = false
    }
    this.currentUser = null
  }

  /**
   * 获取当前用户
   */
  getCurrentUser(): UserProfile | null {
    return this.currentUser
  }

  /**
   * 是否已登录
   */
  isLoggedIn(): boolean {
    return this.currentUser !== null && this.currentUser.isLoggedIn
  }

  /**
   * 是否首次使用（需要显示引导页）
   */
  isFirstLaunch(): boolean {
    return this.users.length <= 1 && (this.currentUser === null || this.currentUser.streak === 0)
  }

  /**
   * 更新用户统计
   */
  updateStats(stats: UserStats): void {
    if (this.currentUser) {
      if (stats.streak !== undefined) {
        this.currentUser.streak = stats.streak
      }
      if (stats.totalStudyMinutes !== undefined) {
        this.currentUser.totalStudyMinutes = stats.totalStudyMinutes
      }
      if (stats.totalCards !== undefined) {
        this.currentUser.totalCards = stats.totalCards
      }
      if (stats.totalMastered !== undefined) {
        this.currentUser.totalMastered = stats.totalMastered
      }
      this.currentUser.lastStudyDate = DateUtils.now()
    }
  }

  /**
   * 清空数据
   */
  clear(): void {
    this.currentUser = null
    this.users = []
  }

  private getRandomAvatar(): string {
    const avatars: string[] = ['📚', '📖', '🎓', '💡', '🚀', '📝', '🎯', '💪']
    const index: number = Math.floor(Math.random() * avatars.length)
    return avatars[index]
  }

  private delay(ms: number): Promise<void> {
    const executor = (resolve: () => void): void => {
      setTimeout(resolve, ms)
    }
    return new Promise<void>(executor)
  }
}
