import { EmojiPicker } from '../../../../../Index';
import { LocalizationUtils } from '../utils/LocalizationUtils';
export interface EmojiItem {
  id: string;
  name: string;
  imageFile: string;
  category: string;
}
export interface EmojiCategory {
  id: string;
  name: string;
  icon: string;
}
export class EmojiDataManager {
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
  static readonly emojis: EmojiItem[] = [

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
  private static fileNameToEmojiNameMap: Map<string, string> | null = null;

  static getEmojiNameByFileName(fileName: string): string | undefined {

    EmojiDataManager.initFileNameMapping();
    return EmojiDataManager.fileNameToEmojiNameMap!.get(fileName);
  }

  static getEmojiNameByResourceString(resourceStr: string): string | undefined {
    let extractedFileName = '';

    if (resourceStr.startsWith('resource://RAWFILE/')) {
      // rawfile : resource://RAWFILE/emojipicker/emoji_34.png
      const filePath = resourceStr.replace('resource://RAWFILE/', '');
      const parts = filePath.split('/');
      extractedFileName = parts[parts.length - 1].replace('.png', ''); // get emoji_34
    } else if (resourceStr.startsWith('resource:///')) {
      // old style : resource:///emoji_34.png
      const fileName = resourceStr.replace('resource:///', '');
      extractedFileName = fileName.replace('.png', '');
    } else {
      try {
        const resourceObj: Record<string, Object> = JSON.parse(resourceStr) as Record<string, Object>;
        if (resourceObj.params && Array.isArray(resourceObj.params) && resourceObj.params.length > 0) {
          const paramStr: string = resourceObj.params[0] as string;
          if (paramStr.startsWith('app.media.')) {
            extractedFileName = paramStr.replace('app.media.', '');
          } else if (paramStr.includes('/')) {
            const parts = paramStr.split('/');
            extractedFileName = parts[parts.length - 1].replace('.png', '');
          } else {
            extractedFileName = paramStr.replace('.png', '');
          }
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

  static getMappingSize(): number {
    EmojiDataManager.initFileNameMapping();
    return EmojiDataManager.fileNameToEmojiNameMap!.size;
  }

  static getAllEmojis(): EmojiItem[] {
    return EmojiDataManager.emojis;
  }

  static getEmojisByCategory(category: string): EmojiItem[] {
    if (category === 'all') {
      return EmojiDataManager.emojis;
    }
    return EmojiDataManager.emojis.filter(emoji => emoji.category === category);
  }

  static getEmojiById(id: string): EmojiItem | undefined {
    return EmojiDataManager.emojis.find(emoji => emoji.id === id);
  }

  static getCategories(): EmojiCategory[] {
    return EmojiDataManager.categories;
  }

  static getDefaultRecentEmojis(): EmojiItem[] {
    return EmojiDataManager.emojis.slice(0, 8);
  }

  static getEmojiImageResource(imageFile: string): Resource {
    return $rawfile(`emojipicker/${imageFile}.png`);
  }

  static getEmojiDisplayName(emoji: EmojiItem): Resource {
    return $r(`app.string.${emoji.name}`);
  }

  static getCategoryDisplayName(categoryId: string): Resource {
    const category = EmojiDataManager.categories.find(cat => cat.id === categoryId);
    if (category) {
      return $r(`app.string.${category.name}`);
    }
    return $r('app.string.emoji_category_all');
  }

  static getEmojiTypeDisplayName(type: 'normal' | 'large'): Resource {
    return $r(`app.string.emoji_type_${type}`);
  }

  static getEmojiDisplayNameString(emoji: EmojiItem, context?: Context): string {
    return LocalizationUtils.getEmojiDisplayName(emoji.name, context);
  }

  static getCategoryDisplayNameString(categoryId: string, context?: Context): string {
    const category = EmojiDataManager.categories.find(cat => cat.id === categoryId);
    if (category) {
      return LocalizationUtils.getCategoryDisplayName(category.name, context);
    }
    return LocalizationUtils.getCategoryDisplayName('emoji_category_all', context);
  }

  static getEmojiTypeDisplayNameString(type: 'normal' | 'large', context?: Context): string {
    return LocalizationUtils.getCategoryDisplayName(`emoji_type_${type}`, context);
  }

  private static initFileNameMapping(): void {
    if (EmojiDataManager.fileNameToEmojiNameMap === null) {
      EmojiDataManager.fileNameToEmojiNameMap = new Map<string, string>();
      EmojiDataManager.emojis.forEach(emoji => {

        const fileName = emoji.imageFile.replace('.png', '');
        EmojiDataManager.fileNameToEmojiNameMap!.set(fileName, emoji.name);
      });

      
    }
  }
} 