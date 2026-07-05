/**
 * StudyFlow OS - 课程状态管理
 * 管理课程资料和课程画像的本地存储
 */

import { CourseMaterial } from '../models/CourseMaterial'
import { CourseProfile } from '../models/CourseProfile'
import { MockData } from './MockData'

export class CourseStore {
  private static instance: CourseStore

  private materials: CourseMaterial[] = []
  private profiles: CourseProfile[] = []
  private currentProfile: CourseProfile | null = null
  private isMockMode: boolean = true

  static getInstance(): CourseStore {
    if (!CourseStore.instance) {
      CourseStore.instance = new CourseStore()
    }
    return CourseStore.instance
  }

  /**
   * 初始化示例数据
   */
  initMockData(): void {
    this.materials = MockData.getAllSampleMaterials()
    this.profiles = [MockData.getSampleProfile_probability()]
    this.isMockMode = true
  }

  /**
   * 添加课程资料
   */
  addMaterial(material: CourseMaterial): void {
    this.materials.unshift(material)
  }

  /**
   * 获取所有课程资料
   */
  getMaterials(): CourseMaterial[] {
    return this.materials
  }

  /**
   * 根据ID获取课程资料
   */
  getMaterialById(id: string): CourseMaterial | undefined {
    return this.materials.find(m => m.id === id)
  }

  /**
   * 获取所有资料类型列表
   */
  getMaterialTypes(): string[] {
    const types = new Set(this.materials.map(m => m.type))
    return Array.from(types)
  }

  /**
   * 添加课程画像
   */
  addProfile(profile: CourseProfile): void {
    // 如果已存在同materialId的profile，替换
    const idx = this.profiles.findIndex(p => p.materialId === profile.materialId)
    if (idx >= 0) {
      this.profiles[idx] = profile
    } else {
      this.profiles.unshift(profile)
    }
    this.currentProfile = profile
  }

  /**
   * 获取所有课程画像
   */
  getProfiles(): CourseProfile[] {
    return this.profiles
  }

  /**
   * 根据ID获取课程画像
   */
  getProfileById(id: string): CourseProfile | undefined {
    return this.profiles.find(p => p.id === id)
  }

  /**
   * 根据materialId获取课程画像
   */
  getProfileByMaterialId(materialId: string): CourseProfile | undefined {
    return this.profiles.find(p => p.materialId === materialId)
  }

  /**
   * 设置当前查看的课程画像
   */
  setCurrentProfile(profile: CourseProfile): void {
    this.currentProfile = profile
  }

  /**
   * 获取当前课程画像
   */
  getCurrentProfile(): CourseProfile | null {
    return this.currentProfile
  }

  /**
   * 是否Mock模式
   */
  isMock(): boolean {
    return this.isMockMode
  }

  /**
   * 设置Mock模式
   */
  setMockMode(mock: boolean): void {
    this.isMockMode = mock
  }

  /**
   * 清除所有数据
   */
  clear(): void {
    this.materials = []
    this.profiles = []
    this.currentProfile = null
  }
}
