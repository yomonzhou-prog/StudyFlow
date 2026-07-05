/**
 * StudyFlow OS - 课程资料数据模型
 * 对应课程资料输入页的数据结构
 */

export interface CourseMaterial {
  id: string
  courseName: string
  title: string
  content: string
  type: 'ppt' | 'textbook' | 'notice' | 'homework' | 'exam' | 'wrong_question'
  createdAt: string
}
