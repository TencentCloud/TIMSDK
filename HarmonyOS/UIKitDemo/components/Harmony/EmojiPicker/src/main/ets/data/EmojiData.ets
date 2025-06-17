/**
 * 表情数据管理类
 * 从iOS plist格式转换为HarmonyOS ArkTS格式
 */

import { LocalizationUtils } from '../utils/LocalizationUtils';

/**
 * 表情数据接口
 */
export interface EmojiItem {
  id: string;
  name: string;
  imageFile: string;
  category: string;
}

/**
 * 表情分类接口
 */
export interface EmojiCategory {
  id: string;
  name: string;
  icon: string;
}

/**
 * 表情数据管理类
 */
export class EmojiDataManager {
  
  /**
   * 静态映射表：文件名 -> 表情名称
   * 全局只初始化一次
   */
  private static fileNameToEmojiNameMap: Map<string, string> | null = null;

  /**
   * 初始化文件名到表情名称的映射表
   */
  private static initFileNameMapping(): void {
    if (EmojiDataManager.fileNameToEmojiNameMap === null) {
      EmojiDataManager.fileNameToEmojiNameMap = new Map<string, string>();
      
      // 遍历所有表情，建立文件名到表情名称的映射
      EmojiDataManager.emojis.forEach(emoji => {
        // 移除文件扩展名，例如 emoji_34.png -> emoji_34
        const fileName = emoji.imageFile.replace('.png', '');
        EmojiDataManager.fileNameToEmojiNameMap!.set(fileName, emoji.name);
      });
      
      console.info(`[EmojiDataManager] 文件名映射表初始化完成，共 ${EmojiDataManager.fileNameToEmojiNameMap.size} 个表情`);
    }
  }

  /**
   * 根据文件名获取表情名称
   * @param fileName 文件名（不含扩展名），例如 "emoji_34"
   * @returns 表情名称，例如 "[TUIEmoji_Daemon]"，如果未找到返回 undefined
   */
  static getEmojiNameByFileName(fileName: string): string | undefined {
    // 确保映射表已初始化
    EmojiDataManager.initFileNameMapping();
    return EmojiDataManager.fileNameToEmojiNameMap!.get(fileName);
  }

  /**
   * 从资源字符串中提取文件名并获取表情名称
   * @param resourceStr 资源字符串，支持两种格式：
   *   - "resource:///emoji_34.png"
   *   - '{"id":-1,"type":-1,"params":["app.media.emoji_34"],"bundleName":"...","moduleName":"..."}'
   * @returns 表情名称，例如 "[TUIEmoji_Daemon]"，如果未找到返回 undefined
   */
  static getEmojiNameByResourceString(resourceStr: string): string | undefined {
    let extractedFileName = '';
    
    if (resourceStr.startsWith('resource:///')) {
      // 格式: resource:///emoji_34.png
      const fileName = resourceStr.replace('resource:///', '');
      extractedFileName = fileName.replace('.png', ''); // 移除扩展名，得到 emoji_34
    } else {
      // 尝试从 JSON 格式中提取
      try {
        const resourceObj: Record<string, Object> = JSON.parse(resourceStr) as Record<string, Object>;
        if (resourceObj.params && Array.isArray(resourceObj.params) && resourceObj.params.length > 0) {
          const paramStr: string = resourceObj.params[0] as string; // app.media.emoji_34
          extractedFileName = paramStr.replace('app.media.', ''); // 得到 emoji_34
        }
      } catch (e) {
        console.warn(`[EmojiDataManager] 无法解析资源对象: ${resourceStr}`);
        return undefined;
      }
    }
    
    if (extractedFileName) {
      return EmojiDataManager.getEmojiNameByFileName(extractedFileName);
    }
    
    return undefined;
  }

  /**
   * 获取映射表的大小（用于调试）
   */
  static getMappingSize(): number {
    EmojiDataManager.initFileNameMapping();
    return EmojiDataManager.fileNameToEmojiNameMap!.size;
  }

  /**
   * 表情分类数据
   */
  static readonly categories: EmojiCategory[] = [
    { id: 'recent', name: 'emoji_category_recent', icon: '🕒' },
    { id: 'all', name: 'emoji_category_all', icon: '😀' },
    { id: 'people', name: 'emoji_category_people', icon: '😊' },
    { id: 'nature', name: 'emoji_category_nature', icon: '🌿' },
    { id: 'food', name: 'emoji_category_food', icon: '🍎' },
    { id: 'activity', name: 'emoji_category_activity', icon: '⚽' },
    { id: 'travel', name: 'emoji_category_travel', icon: '🚗' },
    { id: 'objects', name: 'emoji_category_objects', icon: '💡' },
    { id: 'symbols', name: 'emoji_category_symbols', icon: '❤️' }
  ];

  /**
   * 完整表情数据 - 从emoji.plist转换而来
   */
  static readonly emojis: EmojiItem[] = [
    // 人物表情 (emoji_0 - emoji_29)
    {
      id: '001',
      name: '[TUIEmoji_Smile]',
      imageFile: 'emoji_0',
      category: 'people'
    },
    {
      id: '002',
      name: '[TUIEmoji_Expect]',
      imageFile: 'emoji_1',
      category: 'people'
    },
    {
      id: '003',
      name: '[TUIEmoji_Blink]',
      imageFile: 'emoji_2',
      category: 'people'
    },
    {
      id: '004',
      name: '[TUIEmoji_Guffaw]',
      imageFile: 'emoji_3',
      category: 'people'
    },
    {
      id: '005',
      name: '[TUIEmoji_KindSmile]',
      imageFile: 'emoji_4',
      category: 'people'
    },
    {
      id: '006',
      name: '[TUIEmoji_Haha]',
      imageFile: 'emoji_5',
      category: 'people'
    },
    {
      id: '007',
      name: '[TUIEmoji_Cheerful]',
      imageFile: 'emoji_6',
      category: 'people'
    },
    {
      id: '008',
      name: '[TUIEmoji_Speechless]',
      imageFile: 'emoji_7',
      category: 'people'
    },
    {
      id: '009',
      name: '[TUIEmoji_Amazed]',
      imageFile: 'emoji_8',
      category: 'people'
    },
    {
      id: '010',
      name: '[TUIEmoji_Sorrow]',
      imageFile: 'emoji_9',
      category: 'people'
    },
    {
      id: '011',
      name: '[TUIEmoji_Complacent]',
      imageFile: 'emoji_10',
      category: 'people'
    },
    {
      id: '012',
      name: '[TUIEmoji_Silly]',
      imageFile: 'emoji_11',
      category: 'people'
    },
    {
      id: '013',
      name: '[TUIEmoji_Lustful]',
      imageFile: 'emoji_12',
      category: 'people'
    },
    {
      id: '014',
      name: '[TUIEmoji_Giggle]',
      imageFile: 'emoji_13',
      category: 'people'
    },
    {
      id: '015',
      name: '[TUIEmoji_Kiss]',
      imageFile: 'emoji_14',
      category: 'people'
    },
    {
      id: '016',
      name: '[TUIEmoji_Wail]',
      imageFile: 'emoji_15',
      category: 'people'
    },
    {
      id: '017',
      name: '[TUIEmoji_TearsLaugh]',
      imageFile: 'emoji_16',
      category: 'people'
    },
    {
      id: '018',
      name: '[TUIEmoji_Trapped]',
      imageFile: 'emoji_17',
      category: 'people'
    },
    {
      id: '019',
      name: '[TUIEmoji_Mask]',
      imageFile: 'emoji_18',
      category: 'people'
    },
    {
      id: '020',
      name: '[TUIEmoji_Fear]',
      imageFile: 'emoji_19',
      category: 'people'
    },
    {
      id: '021',
      name: '[TUIEmoji_BareTeeth]',
      imageFile: 'emoji_20',
      category: 'people'
    },
    {
      id: '022',
      name: '[TUIEmoji_FlareUp]',
      imageFile: 'emoji_21',
      category: 'people'
    },
    {
      id: '023',
      name: '[TUIEmoji_Yawn]',
      imageFile: 'emoji_22',
      category: 'people'
    },
    {
      id: '024',
      name: '[TUIEmoji_Tact]',
      imageFile: 'emoji_23',
      category: 'people'
    },
    {
      id: '025',
      name: '[TUIEmoji_Stareyes]',
      imageFile: 'emoji_24',
      category: 'people'
    },
    {
      id: '026',
      name: '[TUIEmoji_ShutUp]',
      imageFile: 'emoji_25',
      category: 'people'
    },
    {
      id: '027',
      name: '[TUIEmoji_Sigh]',
      imageFile: 'emoji_26',
      category: 'people'
    },
    {
      id: '028',
      name: '[TUIEmoji_Hehe]',
      imageFile: 'emoji_27',
      category: 'people'
    },
    {
      id: '029',
      name: '[TUIEmoji_Silent]',
      imageFile: 'emoji_28',
      category: 'people'
    },
    {
      id: '030',
      name: '[TUIEmoji_Surprised]',
      imageFile: 'emoji_29',
      category: 'people'
    },

    // 符号表情 (emoji_30 - emoji_41)
    {
      id: '031',
      name: '[TUIEmoji_Askance]',
      imageFile: 'emoji_30',
      category: 'symbols'
    },
    {
      id: '032',
      name: '[TUIEmoji_Ok]',
      imageFile: 'emoji_31',
      category: 'symbols'
    },
    {
      id: '033',
      name: '[TUIEmoji_Shit]',
      imageFile: 'emoji_32',
      category: 'symbols'
    },
    {
      id: '034',
      name: '[TUIEmoji_Monster]',
      imageFile: 'emoji_33',
      category: 'symbols'
    },
    {
      id: '035',
      name: '[TUIEmoji_Daemon]',
      imageFile: 'emoji_34',
      category: 'symbols'
    },
    {
      id: '036',
      name: '[TUIEmoji_Rage]',
      imageFile: 'emoji_35',
      category: 'symbols'
    },
    {
      id: '037',
      name: '[TUIEmoji_Fool]',
      imageFile: 'emoji_36',
      category: 'symbols'
    },
    {
      id: '038',
      name: '[TUIEmoji_Pig]',
      imageFile: 'emoji_37',
      category: 'nature'
    },
    {
      id: '039',
      name: '[TUIEmoji_Cow]',
      imageFile: 'emoji_38',
      category: 'nature'
    },
    {
      id: '040',
      name: '[TUIEmoji_Ai]',
      imageFile: 'emoji_39',
      category: 'symbols'
    },
    {
      id: '041',
      name: '[TUIEmoji_Skull]',
      imageFile: 'emoji_40',
      category: 'symbols'
    },
    {
      id: '042',
      name: '[TUIEmoji_Bombs]',
      imageFile: 'emoji_41',
      category: 'symbols'
    },

    // 食物表情 (emoji_42 - emoji_46)
    {
      id: '043',
      name: '[TUIEmoji_Coffee]',
      imageFile: 'emoji_42',
      category: 'food'
    },
    {
      id: '044',
      name: '[TUIEmoji_Cake]',
      imageFile: 'emoji_43',
      category: 'food'
    },
    {
      id: '045',
      name: '[TUIEmoji_Beer]',
      imageFile: 'emoji_44',
      category: 'food'
    },
    {
      id: '046',
      name: '[TUIEmoji_Flower]',
      imageFile: 'emoji_45',
      category: 'nature'
    },
    {
      id: '047',
      name: '[TUIEmoji_Watermelon]',
      imageFile: 'emoji_46',
      category: 'food'
    },

    // 活动和物品表情 (emoji_47 - emoji_61)
    {
      id: '048',
      name: '[TUIEmoji_Rich]',
      imageFile: 'emoji_47',
      category: 'symbols'
    },
    {
      id: '049',
      name: '[TUIEmoji_Heart]',
      imageFile: 'emoji_48',
      category: 'symbols'
    },
    {
      id: '050',
      name: '[TUIEmoji_Moon]',
      imageFile: 'emoji_49',
      category: 'nature'
    },
    {
      id: '051',
      name: '[TUIEmoji_Sun]',
      imageFile: 'emoji_50',
      category: 'nature'
    },
    {
      id: '052',
      name: '[TUIEmoji_Star]',
      imageFile: 'emoji_51',
      category: 'nature'
    },
    {
      id: '053',
      name: '[TUIEmoji_RedPacket]',
      imageFile: 'emoji_52',
      category: 'objects'
    },
    {
      id: '054',
      name: '[TUIEmoji_Celebrate]',
      imageFile: 'emoji_53',
      category: 'activity'
    },
    {
      id: '055',
      name: '[TUIEmoji_Bless]',
      imageFile: 'emoji_54',
      category: 'symbols'
    },
    {
      id: '056',
      name: '[TUIEmoji_Fortune]',
      imageFile: 'emoji_55',
      category: 'symbols'
    },
    {
      id: '057',
      name: '[TUIEmoji_Convinced]',
      imageFile: 'emoji_56',
      category: 'symbols'
    },
    {
      id: '058',
      name: '[TUIEmoji_Prohibit]',
      imageFile: 'emoji_57',
      category: 'symbols'
    },
    {
      id: '059',
      name: '[TUIEmoji_666]',
      imageFile: 'emoji_58',
      category: 'symbols'
    },
    {
      id: '060',
      name: '[TUIEmoji_857]',
      imageFile: 'emoji_59',
      category: 'symbols'
    },
    {
      id: '061',
      name: '[TUIEmoji_Knife]',
      imageFile: 'emoji_60',
      category: 'objects'
    },
    {
      id: '062',
      name: '[TUIEmoji_Like]',
      imageFile: 'emoji_61',
      category: 'symbols'
    }
  ];

  /**
   * 获取所有表情
   */
  static getAllEmojis(): EmojiItem[] {
    return EmojiDataManager.emojis;
  }

  /**
   * 根据分类获取表情
   */
  static getEmojisByCategory(category: string): EmojiItem[] {
    if (category === 'all') {
      return EmojiDataManager.emojis;
    }
    return EmojiDataManager.emojis.filter(emoji => emoji.category === category);
  }

  /**
   * 根据ID获取表情
   */
  static getEmojiById(id: string): EmojiItem | undefined {
    return EmojiDataManager.emojis.find(emoji => emoji.id === id);
  }

  /**
   * 获取表情分类
   */
  static getCategories(): EmojiCategory[] {
    return EmojiDataManager.categories;
  }

  /**
   * 获取默认最近使用表情（前8个）
   */
  static getDefaultRecentEmojis(): EmojiItem[] {
    return EmojiDataManager.emojis.slice(0, 8);
  }

  /**
   * 获取表情图片资源路径
   */
  static getEmojiImageResource(imageFile: string): Resource {
    return $r(`app.media.${imageFile}`);
  }

  /**
   * 获取表情的本地化显示名称
   */
  static getEmojiDisplayName(emoji: EmojiItem): Resource {
    return $r(`app.string.${emoji.name}`);
  }

  /**
   * 获取分类的本地化名称
   */
  static getCategoryDisplayName(categoryId: string): Resource {
    const category = EmojiDataManager.categories.find(cat => cat.id === categoryId);
    if (category) {
      return $r(`app.string.${category.name}`);
    }
    return $r('app.string.emoji_category_all');
  }

  /**
   * 获取表情类型的本地化名称
   */
  static getEmojiTypeDisplayName(type: 'normal' | 'large'): Resource {
    return $r(`app.string.emoji_type_${type}`);
  }

  /**
   * 获取表情的本地化显示名称字符串
   * @param emoji 表情对象
   * @param context 上下文对象（可选）
   * @returns 本地化表情名称字符串
   */
  static getEmojiDisplayNameString(emoji: EmojiItem, context?: Context): string {
    return LocalizationUtils.getEmojiDisplayName(emoji.name, context);
  }

  /**
   * 获取分类的本地化名称字符串
   * @param categoryId 分类ID
   * @param context 上下文对象（可选）
   * @returns 本地化分类名称字符串
   */
  static getCategoryDisplayNameString(categoryId: string, context?: Context): string {
    const category = EmojiDataManager.categories.find(cat => cat.id === categoryId);
    if (category) {
      return LocalizationUtils.getCategoryDisplayName(category.name, context);
    }
    return LocalizationUtils.getCategoryDisplayName('emoji_category_all', context);
  }

  /**
   * 获取表情类型的本地化名称字符串
   * @param type 表情类型
   * @param context 上下文对象（可选）
   * @returns 本地化表情类型名称字符串
   */
  static getEmojiTypeDisplayNameString(type: 'normal' | 'large', context?: Context): string {
    return LocalizationUtils.getCategoryDisplayName(`emoji_type_${type}`, context);
  }
} 