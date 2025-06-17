import { ColorScheme, LightColorTheme, DarkColorTheme, BlueTheme } from './ColorScheme'
import { ConfigurationConstant } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'

// 主题颜色用法：
//  import { ThemeManager } from 'basecomponent/src/main/ets/utils/ThemeManager';
//  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
//  this.themeManager.currentTheme.bgColorOperate
@Observed
export class ThemeManager {
  // 单例实例
  private static instance: ThemeManager;
  // 当前主题
  currentTheme: ColorScheme = new LightColorTheme();
  // 窗口
  windowStage: window.Window | null = null
  // 预存主题
  private themeMap: Map<string, ColorScheme> = new Map()
  // 自定义主题存储
  private customThemes: Map<string, ColorScheme> = new Map();
  // 主题变更回调
  private subscribers: Array<(theme: ColorScheme) => void> = [];
  // 当前主题模式：'light'(明亮)、'dark'(暗黑)、'system'(跟随系统)
  private currentThemeType: string = 'light';
  // 是否深色模式的缓存
  private isDarkMode: boolean = false;

  // 私有构造
  private constructor() {
    // 初始化时预缓存所有主题
    this.themeMap.set('light', new LightColorTheme())
    this.themeMap.set('dark', new DarkColorTheme())
    this.themeMap.set('blue', new BlueTheme())

    // 初始化主题（设置为亮色主题）
    this.changeTheme('light');

    // 初始化时检查当前系统颜色模式
    this.checkCurrentColorMode();
  }

  // 获取单例
  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  // 获取当前主题
  static getCurrentTheme(): ColorScheme {
    return ThemeManager.getInstance().getCurrentTheme();
  }

  /**
   * 根据当前系统颜色模式初始化
   */
  checkCurrentColorMode(): void {
    try {
      // 从AppStorage获取当前颜色模式
      const currentMode = AppStorage.Get<number>('currentColorMode');
      if (currentMode !== undefined) {
        this.isDarkMode = currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;

        // 如果当前是跟随系统模式，则更新主题
        if (this.currentThemeType === 'system') {
          this.applySystemTheme();
        }
      }
    } catch (error) {
      console.error(`初始化颜色模式失败: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  // 获取当前主题类型
  getCurrentThemeType(): string {
    return this.currentThemeType;
  }

  // 切换主题
  changeTheme(theme: 'light' | 'dark' | 'blue' | 'system' | ColorScheme | string): void {
    if (theme === 'system') {
      // 设置为跟随系统模式
      this.currentThemeType = 'system';
      this.applySystemTheme();
      return;
    }

    // 更新当前主题类型（不是系统模式时）
    if (typeof theme === 'string') {
      this.currentThemeType = theme;
    }

    // 更新实际主题
    this.changeThemeInternal(theme);
  }

  // 订阅主题变化
  subscribe(callback: (theme: ColorScheme) => void): void {
    this.subscribers.push(callback);
  }

  // 取消订阅
  unsubscribe(callback: (theme: ColorScheme) => void): void {
    this.subscribers = this.subscribers.filter(cb => cb !== callback);
  }

  // 获取当前主题
  getCurrentTheme(): ColorScheme {
    return this.currentTheme;
  }

  /**
   * 注册自定义主题
   * @param themeName 主题名称
   * @param theme 主题对象
   */
  registerCustomTheme(themeName: string, theme: ColorScheme): void {
    if (this.customThemes.has(themeName)) {
      console.warn(`Theme ${themeName} already exists, it will be overwritten`);
    }
    this.customThemes.set(themeName, theme);
  }

  /**
   * 移除自定义主题
   * @param themeName 主题名称
   */
  removeCustomTheme(themeName: string): void {
    this.customThemes.delete(themeName);
  }

  // 状态栏设置
  async getWindowStage() {
    if (this.windowStage) {
      return this.windowStage
    } else {
      return await window.getLastWindow(getContext())
    }
  }

  settingStatusBarAuto() {
    this.settingStatusBar({
      //状态栏背景色
      statusBarColor: this.currentTheme.bgColorOperate,
      statusBarContentColor: this.currentTheme.textColorPrimary,
      navigationBarContentColor: this.currentTheme.textColorPrimary,
      navigationBarColor: this.currentTheme.bgColorOperate,
    })
  }

  /**
   * 设置状态栏。
   * @param {window.SystemBarProperties} config 窗口系统栏属性配置。
   */
  settingStatusBar(config: window.SystemBarProperties) {
    this.getWindowStage()
      .then((windowStage: window.Window) => {
        windowStage.setWindowSystemBarProperties(config)
      })
  }

  /**
   * 启用全屏模式
   */
  enableFullScreen() {
    this.getWindowStage()
      .then((windowStage: window.Window) => {
        windowStage.setWindowLayoutFullScreen(true)
        const topArea = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        AppStorage.setOrCreate('topHeight', px2vp(topArea.topRect.height))
        const bottomArea = windowStage.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR)
        AppStorage.setOrCreate('bottomHeight', px2vp(bottomArea.bottomRect.height))
      })
  }

  /**
   * 禁用全屏模式
   */
  disableFullScreen() {
    this.getWindowStage()
      .then((windowStage: window.Window) => {
        windowStage.setWindowLayoutFullScreen(false)
        AppStorage.setOrCreate('topHeight', 0)
        AppStorage.setOrCreate('bottomHeight', 0)
      })
  }

  /**
   * 根据当前系统深色模式状态应用对应主题
   */
  private applySystemTheme(): void {
    if (this.isDarkMode) {
      this.changeThemeInternal('dark');
    } else {
      this.changeThemeInternal('light');
    }
  }

  /**
   * 内部主题更新实现
   */
  private changeThemeInternal(theme: 'light' | 'dark' | 'blue' | ColorScheme | string): void {
    if (typeof theme === 'string') {
      switch (theme) {
        case 'light':
          this.currentTheme = this.themeMap.get('light') as ColorScheme
          break;
        case 'dark':
          this.currentTheme = this.themeMap.get('dark') as ColorScheme
          break;
        case 'blue':
          this.currentTheme = this.themeMap.get('blue') as ColorScheme
          break;
        default:
          if (this.customThemes.has(theme)) {
            this.currentTheme = this.customThemes.get(theme)!;
          } else {
            console.error(`Theme ${theme} not found`);
            this.currentTheme = new LightColorTheme();
          }
      }
    } else {
      this.currentTheme = theme;
    }

    // 设置状态栏颜色
    this.settingStatusBarAuto();
    // 通知所有订阅者
    this.subscribers.forEach(cb => cb(this.currentTheme));
  }
}

export { LightColorTheme, DarkColorTheme, ColorScheme };
