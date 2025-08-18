
export class LocalizationUtils {
  
  
  static async getStringFromResource(resource: Resource, context?: Context): Promise<string> {
    try {
      if (context) {
        const resourceManager = context.resourceManager;
        return await resourceManager.getStringValue(resource);
      } else {
        
        const globalContext = getContext();
        if (globalContext && globalContext.resourceManager) {
          return await globalContext.resourceManager.getStringValue(resource);
        }
      }
    } catch (error) {
      
    }
    
    
    return '';
  }

  
  static getStringFromResourceSync(resource: Resource, context?: Context): string {
    try {
      if (context) {
        const resourceManager = context.resourceManager;
        return resourceManager.getStringSync(resource);
      } else {
        
        const globalContext = getContext();
        if (globalContext && globalContext.resourceManager) {
          return globalContext.resourceManager.getStringSync(resource);
        }
      }
    } catch (error) {
      
    }
    
    
    return '';
  }

  
  static getEmojiDisplayName(emojiName: string, context?: Context): string {
    
    let actualEmojiName = emojiName;
    if (emojiName.startsWith('[') && emojiName.endsWith(']')) {
      actualEmojiName = emojiName.slice(1, -1); 
    }
    
    const resource = $r(`app.string.${actualEmojiName}`);
    const displayName = LocalizationUtils.getStringFromResourceSync(resource, context);
    
    
    if (!displayName) {
      return emojiName; 
    }
    
    return displayName;
  }

  
  static getCategoryDisplayName(categoryName: string, context?: Context): string {
    const resource = $r(`app.string.${categoryName}`);
    const displayName = LocalizationUtils.getStringFromResourceSync(resource, context);
    
    
    if (!displayName) {
      return categoryName;
    }
    
    return displayName;
  }
} 