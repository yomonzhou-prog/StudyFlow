/**
 * StudyFlow OS - 设置状态管理
 * 管理用户学习偏好和应用设置
 */

import { StudySettings } from '../models/StudySettings'

export class SettingsStore {
  private static instance: SettingsStore

  private settings: StudySettings

  static getInstance(): SettingsStore {
    if (!SettingsStore.instance) {
      SettingsStore.instance = new SettingsStore()
    }
    return SettingsStore.instance
  }

  private constructor() {
    this.settings = this.getDefaultSettings()
  }

  /**
   * 获取所有设置
   */
  getSettings(): StudySettings {
    return this.settings
  }

  /**
   * 更新设置
   */
  updateSettings(partial: Partial<StudySettings>): void {
    if (partial.dailyStudyGoal !== undefined) {
      this.settings.dailyStudyGoal = partial.dailyStudyGoal
    }
    if (partial.dailyNewCards !== undefined) {
      this.settings.dailyNewCards = partial.dailyNewCards
    }
    if (partial.dailyReviewCards !== undefined) {
      this.settings.dailyReviewCards = partial.dailyReviewCards
    }
    if (partial.reminderTime !== undefined) {
      this.settings.reminderTime = partial.reminderTime
    }
    if (partial.reminderEnabled !== undefined) {
      this.settings.reminderEnabled = partial.reminderEnabled
    }
    if (partial.showMockBanner !== undefined) {
      this.settings.showMockBanner = partial.showMockBanner
    }
    if (partial.themeMode !== undefined) {
      this.settings.themeMode = partial.themeMode
    }
  }

  /**
   * 重置为默认设置
   */
  resetDefaults(): void {
    this.settings = this.getDefaultSettings()
  }

  private getDefaultSettings(): StudySettings {
    return {
      dailyStudyGoal: 60,
      dailyNewCards: 10,
      dailyReviewCards: 20,
      reminderTime: '09:00',
      reminderEnabled: true,
      showMockBanner: true,
      themeMode: 'light'
    }
  }
}
