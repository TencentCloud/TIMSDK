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

  
  static getAvatarLetter(title?: string): string {
    if (!title || title.trim().length === 0) {
      return '?';
    }
    return title.trim().charAt(0).toUpperCase();
  }

  
  static isValidUrl(url?: string): boolean {
    if (!url || url.trim().length === 0) {
      return false;
    }

    const trimmedUrl = url.trim();
    
    return trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://');
  }

  static getResourceString(resource: Resource): string {
    return getContext().getApplicationContext().resourceManager.getStringSync(resource);
  }
}