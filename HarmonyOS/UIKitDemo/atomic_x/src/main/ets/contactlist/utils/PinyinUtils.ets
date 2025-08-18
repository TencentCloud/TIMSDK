
import { i18n } from '@kit.LocalizationKit';

export class PinyinUtils {
  private static transliterator: i18n.Transliterator | null = null;
  private static asciiTransliterator: i18n.Transliterator | null = null;

  
  private static initTransliterators(): void {
    if (!PinyinUtils.transliterator) {
      try {
        
        PinyinUtils.transliterator = i18n.Transliterator.getInstance('Any-Latn');
        
        PinyinUtils.asciiTransliterator = i18n.Transliterator.getInstance('Latin-ASCII');
      } catch (error) {
        
      }
    }
  }

  
  static toPinyinWithTone(text: string): string {
    if (!text) return '';
    
    PinyinUtils.initTransliterators();
    
    if (!PinyinUtils.transliterator) {
      
      return text;
    }

    try {
      return PinyinUtils.transliterator.transform(text);
    } catch (error) {
      
      return text;
    }
  }

  
  static toPinyin(text: string): string {
    if (!text) return '';
    
    const pinyinWithTone = PinyinUtils.toPinyinWithTone(text);
    
    if (!PinyinUtils.asciiTransliterator) {
      
      return pinyinWithTone;
    }

    try {
      return PinyinUtils.asciiTransliterator.transform(pinyinWithTone);
    } catch (error) {
      
      return pinyinWithTone;
    }
  }

  
  static getFirstLetters(text: string): string {
    if (!text) return '';
    
    const pinyin = PinyinUtils.toPinyin(text);
    const words = pinyin.split(' ');
    
    return words.map(word => {
      const firstChar = word.charAt(0).toUpperCase();
      
      if (/^[A-Z]$/.test(firstChar)) {
        return firstChar;
      }
      return '#'; 
    }).join('');
  }

  
  static getFirstLetter(char: string): string {
    if (!char) return '#';
    
    const firstChar = char.charAt(0);
    
    
    if (/^[A-Za-z]$/.test(firstChar)) {
      return firstChar.toUpperCase();
    }
    
    
    if (/^[0-9]$/.test(firstChar)) {
      return '#';
    }
    
    
    const pinyin = PinyinUtils.toPinyin(firstChar);
    if (pinyin && pinyin.length > 0) {
      const firstLetter = pinyin.charAt(0).toUpperCase();
      if (/^[A-Z]$/.test(firstLetter)) {
        return firstLetter;
      }
    }
    
    return '#';
  }

  
  static getSortLetter(name: string): string {
    if (!name) return '#';
    
    
    const firstChar = name.charAt(0);
    return PinyinUtils.getFirstLetter(firstChar);
  }

  
  static batchGetFirstLetters(texts: string[]): string[] {
    return texts.map(text => PinyinUtils.getFirstLetter(text));
  }

  
  static isChineseChar(char: string): boolean {
    if (!char) return false;
    const charCode = char.charCodeAt(0);
    
    return charCode >= 0x4e00 && charCode <= 0x9fa5;
  }

  
  static getChinesePinyinMap(text: string): Record<string, string> {
    const result: Record<string, string> = {};
    
    for (let i = 0; i < text.length; i++) {
      const char = text.charAt(i);
      if (PinyinUtils.isChineseChar(char) && !result[char]) {
        result[char] = PinyinUtils.toPinyin(char);
      }
    }
    
    return result;
  }
} 