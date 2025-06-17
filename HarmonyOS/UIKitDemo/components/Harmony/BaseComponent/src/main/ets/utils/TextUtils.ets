export default class TextUtils {
  static isEmpty(text: string | undefined | null) {
    if (!text) {
      return true;
    }
    if (text.length === 0) {
      return true;
    }
    return false;
  }

  static equals(text1: string | undefined | null, text2: string | null | undefined) {
    if (!text1 || !text2) {
      return false;
    }
    return text1 === text2;
  }

  /**
   * 获取标题首字母作为头像
   */
  static getAvatarLetter(title?: string): string {
    if (!title || title.trim().length === 0) {
      return '?';
    }
    return title.trim().charAt(0).toUpperCase();
  }

  /**
   * 验证是否为有效的URL
   */
  static isValidUrl(url?: string): boolean {
    if (!url || url.trim().length === 0) {
      return false;
    }

    const trimmedUrl = url.trim();
    // 检查是否以http://或https://开头
    return trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://');
  }
}