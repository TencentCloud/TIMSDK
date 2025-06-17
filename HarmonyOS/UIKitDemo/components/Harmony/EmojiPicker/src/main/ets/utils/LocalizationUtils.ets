/**
 * 本地化工具类
 * 用于处理Resource类型的字符串获取
 */

/**
 * 本地化工具类
 */
export class LocalizationUtils {
  
  /**
   * 获取Resource类型的字符串值
   * @param resource Resource类型的字符串资源
   * @param context 上下文对象
   * @returns 本地化字符串
   */
  static async getStringFromResource(resource: Resource, context?: Context): Promise<string> {
    try {
      if (context) {
        const resourceManager = context.resourceManager;
        return await resourceManager.getStringValue(resource);
      } else {
        // 如果没有提供context，使用全局context
        const globalContext = getContext();
        if (globalContext && globalContext.resourceManager) {
          return await globalContext.resourceManager.getStringValue(resource);
        }
      }
    } catch (error) {
      console.error('[LocalizationUtils] 获取本地化字符串失败:', error);
    }
    
    // 如果获取失败，返回默认值
    return '';
  }

  /**
   * 同步获取Resource类型的字符串值
   * @param resource Resource类型的字符串资源
   * @param context 上下文对象
   * @returns 本地化字符串
   */
  static getStringFromResourceSync(resource: Resource, context?: Context): string {
    try {
      if (context) {
        const resourceManager = context.resourceManager;
        return resourceManager.getStringSync(resource);
      } else {
        // 如果没有提供context，使用全局context
        const globalContext = getContext();
        if (globalContext && globalContext.resourceManager) {
          return globalContext.resourceManager.getStringSync(resource);
        }
      }
    } catch (error) {
      console.error('[LocalizationUtils] 同步获取本地化字符串失败:', error);
    }
    
    // 如果获取失败，返回默认值
    return '';
  }

  /**
   * 获取表情的本地化显示名称
   * @param emojiName 表情名称（格式：[TUIEmoji_Smile] 或 TUIEmoji_Smile）
   * @param context 上下文对象
   * @returns 本地化表情名称
   */
  static getEmojiDisplayName(emojiName: string, context?: Context): string {
    // 提取括号内的实际表情名称
    let actualEmojiName = emojiName;
    if (emojiName.startsWith('[') && emojiName.endsWith(']')) {
      actualEmojiName = emojiName.slice(1, -1); // 移除首尾的方括号
    }
    
    const resource = $r(`app.string.${actualEmojiName}`);
    const displayName = LocalizationUtils.getStringFromResourceSync(resource, context);
    
    // 如果获取失败，返回原始的带括号格式
    if (!displayName) {
      return emojiName; // 直接返回原始名称（已包含括号）
    }
    
    return displayName;
  }

  /**
   * 获取分类的本地化名称
   * @param categoryName 分类名称
   * @param context 上下文对象
   * @returns 本地化分类名称
   */
  static getCategoryDisplayName(categoryName: string, context?: Context): string {
    const resource = $r(`app.string.${categoryName}`);
    const displayName = LocalizationUtils.getStringFromResourceSync(resource, context);
    
    // 如果获取失败，返回默认值
    if (!displayName) {
      return categoryName;
    }
    
    return displayName;
  }
} 