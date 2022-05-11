import { createI18n, useI18n } from 'vue-i18n';
import messages from '../../locales';

class TUIi18n {
  public messages = {
    en: {},
    zh_cn: {},
  };
  public i18n: any;
  static instance: TUIi18n;
  constructor(messages:any) {
    this.messages = messages;
  }

  /**
   * 获取 TUIi18n 实例
   *
   * @returns {TUIi18n}
   */
  static getInstance() {
    if (!TUIi18n.instance) {
      TUIi18n.instance = new TUIi18n(messages);
    }
    return TUIi18n.instance;
  }

  /**
   * 注入需要国际化的词条
   *
   * @param {Object} messages 数据对象
   * @returns {messages} 全部国际化词条
   */
  public provideMessage(messages: any) {
    this.messages.en = { ...this.messages.en, ...messages.en };
    this.messages.zh_cn = { ...this.messages.zh_cn, ...messages.zh_cn };
    return this.messages;
  }

  /**
   * 使用国际化
   *
   * @returns {useI18n} 国际化使用函数
   */
  public useI18n() {
    return useI18n();
  }

  /**
   * 挂载到 vue 实例的上
   *
   * @param {app} app vue的实例
   */
  static install(app: any) {
    const that = TUIi18n.getInstance();
    // const lang = navigator.language.substr(0, 2);
    const lang = 'zh';
    that.i18n = createI18n({
      legacy: false, // 使用Composition API，这里必须设置为false
      globalInjection: true,
      global: true,
      locale: lang === 'zh' ? 'zh_cn' : lang,
      fallbackLocale: 'zh_cn', // 默认语言
      messages: that.messages,
    });
    app.use(that.i18n);
  }

  /**
   * 挂载到 TUICore
   *
   * @param {TUICore} TUICore TUICore实例
   */
  static plugin(TUICore:any) {
    TUICore.config.i18n = TUIi18n.getInstance();
  }
}

/**
 * 国际化标识
 *
 * @returns {locale} 国际化标识
 */
export function useI18nLocale() {
  return TUIi18n.getInstance().i18n.global.locale;
}

export default TUIi18n;

