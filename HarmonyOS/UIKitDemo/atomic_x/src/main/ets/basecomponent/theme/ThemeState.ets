import { SemanticColorScheme, LightSemanticScheme, DarkSemanticScheme } from './Colors'
import { FontScheme, SemanticFontScheme } from './Fonts'
import { RadiusScheme, SemanticRadiusScheme } from './Radius'
import { SpacingScheme, SemanticSpacingScheme } from './Spacing'
import { ConfigurationConstant } from '@kit.AbilityKit'
import { window } from '@kit.ArkUI'
import common from '@ohos.app.ability.common'
import { AppBuilderConfig } from '../Index'
import { MMKV } from '@tencent/mmkv'
import { ContextProvider, getAppContext } from '../utils/ContextProvider'

export enum ThemeMode {
  system = 'system',
  light = 'light',
  dark = 'dark'
}

export interface ThemeConfig {
  mode: ThemeMode;
  primaryColor?: string;
}

@Observed
export class ThemeState {
  private static instance: ThemeState;
  colors: SemanticColorScheme = new LightSemanticScheme();
  windowStage: window.Window | null = null
  private themeMap: Map<string, SemanticColorScheme> = new Map()
  private customThemes: Map<string, SemanticColorScheme> = new Map();
  private subscribers: Array<(theme: SemanticColorScheme) => void> = [];
  private currentTheme: ThemeConfig = { mode: ThemeMode.system };
  private isDarkMode: boolean = false;
  private cachedColorScheme: SemanticColorScheme | null = null;
  private cachedThemeConfig: ThemeConfig | null = null;

  private constructor() {
    this.themeMap.set('light', new LightSemanticScheme())
    this.themeMap.set('dark', new DarkSemanticScheme())
    this.loadTheme();
    this.checkCurrentColorMode();
  }


  get availableThemeTypes(): ThemeMode[] {
    return [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
  }

  get fonts(): SemanticFontScheme {
    return FontScheme;
  }


  get radius(): SemanticRadiusScheme {
    return RadiusScheme;
  }

  get spacing(): SemanticSpacingScheme {
    return SpacingScheme;
  }

  get currentMode(): ThemeMode {
    return this.currentTheme.mode;
  }

  get currentPrimaryColor(): string | undefined {
    return this.currentTheme.primaryColor;
  }

  get hasCustomPrimaryColor(): boolean {
    return this.currentTheme.primaryColor !== undefined;
  }

  static getInstance(): ThemeState {
    if (!ThemeState.instance) {
      ThemeState.instance = new ThemeState();
    }
    return ThemeState.instance;
  }

  static getCurrentTheme(): SemanticColorScheme {
    return ThemeState.getInstance().getCurrentTheme();
  }

  setThemeMode(mode: ThemeMode): void {
    this.clearCache();
    this.currentTheme = {
      mode: mode,
      primaryColor: this.currentTheme.primaryColor
    };
    this.saveTheme();
    this.applyTheme();
  }

  setPrimaryColor(hexColor: string): void {
    const hexPattern = /^#[0-9A-Fa-f]{6}$/;
    if (!hexPattern.test(hexColor)) {
      console.warn(`Warning: Invalid hex color format: ${hexColor}`);
      return;
    }

    this.clearCache();
    this.currentTheme = {
      mode: this.currentTheme.mode,
      primaryColor: hexColor
    };
    this.saveTheme();
    this.applyTheme();
  }

  clearPrimaryColor(): void {
    this.clearCache();
    this.currentTheme = {
      mode: this.currentTheme.mode,
      primaryColor: undefined
    };
    this.saveTheme();
    this.applyTheme();
  }

  setTheme(theme: ThemeConfig): void {
    this.clearCache();
    this.currentTheme = theme;
    this.saveTheme();
    this.applyTheme();
  }

  checkCurrentColorMode(): void {
    try {
      const currentMode = AppStorage.get<number>('currentColorMode');
      if (currentMode !== undefined) {
        const newIsDarkMode = currentMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
        if (this.isDarkMode !== newIsDarkMode) {
          this.clearCache();
          this.isDarkMode = newIsDarkMode;
        }
        this.applyTheme();
        setTimeout(() => {
          this.settingStatusBarAuto();
        }, 100);
      }
    } catch (error) {

    }
  }


  getCurrentThemeType(): ThemeMode {
    return this.currentTheme.mode;
  }


  subscribe(callback: (theme: SemanticColorScheme) => void): void {
    this.subscribers.push(callback);
  }


  unsubscribe(callback: (theme: SemanticColorScheme) => void): void {
    this.subscribers = this.subscribers.filter(cb => cb !== callback);
  }


  getCurrentTheme(): SemanticColorScheme {
    if (this.cachedColorScheme && this.cachedThemeConfig && 
        this.isThemeConfigEqual(this.cachedThemeConfig, this.currentTheme)) {
      return this.cachedColorScheme;
    }

    const newColorScheme = this.calculateColorScheme();
    this.cachedColorScheme = newColorScheme;
    this.cachedThemeConfig = {
      mode: this.currentTheme.mode,
      primaryColor: this.currentTheme.primaryColor
    };
    this.colors = newColorScheme;

    return newColorScheme;
  }


  registerCustomTheme(themeName: string, theme: SemanticColorScheme): void {
    if (this.customThemes.has(themeName)) {
      console.warn(`Theme ${themeName} already exists, it will be overwritten`);
    }
    this.customThemes.set(themeName, theme);
  }


  removeCustomTheme(themeName: string): void {
    this.customThemes.delete(themeName);
  }


  async getWindowStage() {
    if (this.windowStage) {
      return this.windowStage
    } else {
      const context = getAppContext();
      if (context) {
        return await window.getLastWindow(context)
      } else {
        throw new Error('Context not initialized, please call ContextProvider.init() first');
      }
    }
  }

  settingStatusBarAuto() {
    this.settingStatusBar({

      statusBarColor: this.colors.bgColorOperate,
      statusBarContentColor: this.colors.textColorPrimary,
      navigationBarContentColor: this.colors.textColorPrimary,
      navigationBarColor: this.colors.bgColorOperate,
    })
  }


  settingStatusBar(config: window.SystemBarProperties) {
    this.getWindowStage()
      .then((windowStage: window.Window) => {
        windowStage.setWindowSystemBarProperties(config)
        windowStage.setWindowBackgroundColor(this.colors.bgColorOperate);
      })
  }


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


  disableFullScreen() {
    this.getWindowStage()
      .then((windowStage: window.Window) => {
        windowStage.setWindowLayoutFullScreen(false)
        AppStorage.setOrCreate('topHeight', 0)
        AppStorage.setOrCreate('bottomHeight', 0)
      })
  }


  private applyTheme(): void {
    this.colors = this.calculateColorScheme();
    this.settingStatusBarAuto();
    this.subscribers.forEach(cb => cb(this.colors));
  }

  private calculateColorScheme(): SemanticColorScheme {
    const effectiveMode = this.getEffectiveMode();

    if (this.currentTheme.primaryColor) {
      const baseScheme = effectiveMode === ThemeMode.light ?
        new LightSemanticScheme() : new DarkSemanticScheme();
      return this.getCustomScheme(effectiveMode === ThemeMode.light, baseScheme, this.currentTheme.primaryColor);
    } else {
      return this.getSystemScheme(effectiveMode);
    }
  }

  private clearCache(): void {
    this.cachedColorScheme = null;
    this.cachedThemeConfig = null;
  }

  private isThemeConfigEqual(config1: ThemeConfig, config2: ThemeConfig): boolean {
    return config1.mode === config2.mode && config1.primaryColor === config2.primaryColor;
  }


  private getEffectiveMode(): ThemeMode {
    switch (this.currentTheme.mode) {
      case ThemeMode.system:
        return this.isDarkMode ? ThemeMode.dark : ThemeMode.light;
      case ThemeMode.light:
      case ThemeMode.dark:
        return this.currentTheme.mode;
      default:
        return ThemeMode.light;
    }
  }


  private getSystemScheme(mode: ThemeMode): SemanticColorScheme {
    switch (mode) {
      case ThemeMode.light:
        return this.themeMap.get('light') as SemanticColorScheme;
      case ThemeMode.dark:
        return this.themeMap.get('dark') as SemanticColorScheme;
      default:
        return new LightSemanticScheme();
    }
  }

  private getCustomScheme(isLight: boolean, baseScheme: SemanticColorScheme, hexColor: string): SemanticColorScheme {
    // 生成颜色调色板
    const lightPalette = ThemeColorGenerator.generateColorPalette(hexColor, 'light');
    const darkPalette = ThemeColorGenerator.generateColorPalette(hexColor, 'dark');

    const themeLight1 = lightPalette[0];
    const themeLight2 = lightPalette[1];
    const themeLight5 = lightPalette[4];
    const themeLight6 = lightPalette[5];
    const themeLight7 = lightPalette[6];
    const themeDark2 = darkPalette[1];
    const themeDark5 = darkPalette[4];
    const themeDark6 = darkPalette[5];
    const themeDark7 = darkPalette[6];


    let customScheme: SemanticColorScheme;

    if (baseScheme instanceof LightSemanticScheme) {
      customScheme = new LightSemanticScheme();
    } else if (baseScheme instanceof DarkSemanticScheme) {
      customScheme = new DarkSemanticScheme();
    } else {
      customScheme = new LightSemanticScheme();
    }


    customScheme.textColorLink = isLight ? themeLight6 : themeDark6;
    customScheme.textColorLinkHover = isLight ? themeLight5 : themeDark5;
    customScheme.textColorLinkActive = isLight ? themeLight7 : themeDark7;
    customScheme.textColorLinkDisabled = isLight ? themeLight2 : themeDark2;
    customScheme.bgColorBubbleOwn = isLight ? themeLight2 : themeDark7;
    customScheme.bgColorAvatar = isLight ? themeLight2 : themeDark7;
    customScheme.listColorFocused = isLight ? themeLight1 : themeDark2;
    customScheme.buttonColorPrimaryDefault = isLight ? themeLight6 : themeDark6;
    customScheme.buttonColorPrimaryHover = isLight ? themeLight5 : themeDark5;
    customScheme.buttonColorPrimaryActive = isLight ? themeLight7 : themeDark7;
    customScheme.buttonColorPrimaryDisabled = isLight ? themeLight2 : themeDark2;
    customScheme.dropdownColorActive = isLight ? themeLight1 : themeDark2;
    customScheme.checkboxColorSelected = isLight ? themeLight6 : themeDark5;
    customScheme.toastColorDefault = isLight ? themeLight1 : themeDark2;
    customScheme.tagColorLevel2 = baseScheme.tagColorLevel2;
    customScheme.switchColorOn = isLight ? themeLight6 : themeDark5;
    customScheme.sliderColorFilled = isLight ? themeLight6 : themeDark5;
    customScheme.tabColorSelected = isLight ? themeLight2 : themeDark5;
    return customScheme;
  }


  private saveTheme(): void {
    try {
      const themeData = JSON.stringify(this.currentTheme);
      AppStorage.setOrCreate('BaseComponentThemeKey', themeData);
      try {
        const mmkv = MMKV.defaultMMKV();
        mmkv.encodeString('BaseComponentThemeKey', themeData);
      } catch (mmkvError) {
        console.warn('Failed to save theme to MMKV:', mmkvError);
      }
    } catch (error) {
      console.error('Failed to save theme:', error);
    }
  }


  private loadTheme(): void {
    try {
      let themeData = AppStorage.get<string>('BaseComponentThemeKey');

      if (!themeData) {
        try {
          const mmkv = MMKV.defaultMMKV();
          themeData = mmkv.decodeString('BaseComponentThemeKey');
        } catch (mmkvError) {
          console.warn('Failed to load theme from MMKV:', mmkvError);
        }
      }

      if (themeData) {
        const theme = JSON.parse(themeData) as ThemeConfig;
        this.currentTheme = theme;
        console.info('Theme loaded successfully:', theme);
      } else {
        this.loadFromAppBuilderConfig();
      }
    } catch (error) {
      console.error('Failed to load theme:', error);
      this.currentTheme = { mode: ThemeMode.system };
    }

    this.applyTheme();
  }

  private loadFromAppBuilderConfig(): void {
    try {
      const config = AppBuilderConfig.getInstance();
      let mode: ThemeMode = ThemeMode.system;

      switch (config.themeMode) {
        case ThemeMode.system:
          mode = ThemeMode.system;
          break;
        case ThemeMode.light:
          mode = ThemeMode.light;
          break;
        case ThemeMode.dark:
          mode = ThemeMode.dark;
          break;
        default:
          mode = ThemeMode.system;
          break;
      }

      let primaryColor: string | undefined = undefined;

      if (config.primaryColor && config.primaryColor.trim() !== '') {
        const hexPattern = /^#[0-9A-Fa-f]{6}$/;
        if (hexPattern.test(config.primaryColor)) {
          primaryColor = config.primaryColor;
        } else {
          console.warn(`Invalid primary color format in AppBuilderConfig: ${config.primaryColor}`);
        }
      }

      this.currentTheme = { mode: mode, primaryColor: primaryColor };
      console.info('Theme loaded from AppBuilderConfig:', this.currentTheme);

      // this.saveTheme();
    } catch (error) {
      console.error('Failed to load theme from AppBuilderConfig:', error);
      this.currentTheme = { mode: ThemeMode.system };
      console.info('Using fallback default theme: system');
    }
  }
}

interface HSLColor {
  h: number;
  s: number;
  l: number;
}

interface HSLAdjustment {
  s: number;
  l: number;
}

interface PaletteInfo {
  palette: Record<string, string[]>;
  baseColor: string;
}

interface DistanceInfo {
  palette: Record<string, string[]>;
  distance: number;
}

class ThemeColorGenerator {
  private static readonly BLUE_PALETTE: Record<string, string[]> = {
    'light': [
      '#ebf3ff', '#cce2ff', '#adcfff', '#7aafff', '#4588f5',
      '#1c66e5', '#0d49bf', '#033099', '#001f73', '#00124d'
    ],
    'dark': [
      '#1c2333', '#243047', '#2f4875', '#305ba6', '#2b6ad6',
      '#4086ff', '#5c9dff', '#78b0ff', '#9cc7ff', '#c2deff'
    ]
  };
  private static readonly GREEN_PALETTE: Record<string, string[]> = {
    'light': [
      '#dcfae9', '#b6f0d1', '#84e3b5', '#5ad69e', '#3cc98c',
      '#0abf77', '#09a768', '#078f59', '#067049', '#044d37'
    ],
    'dark': [
      '#1a2620', '#22352c', '#2f4f3f', '#377355', '#368f65',
      '#38a673', '#62b58b', '#8bc7a9', '#a9d4bd', '#c8e5d5'
    ]
  };
  private static readonly RED_PALETTE: Record<string, string[]> = {
    'light': [
      '#ffe7e6', '#fcc9c7', '#faaeac', '#f58989', '#e86666',
      '#e54545', '#c93439', '#ad2934', '#8f222d', '#6b1a27'
    ],
    'dark': [
      '#2b1c1f', '#422324', '#613234', '#8a4242', '#c2544e',
      '#e6594c', '#e57a6e', '#f3a599', '#facbc3', '#fae4de'
    ]
  };
  private static readonly ORANGE_PALETTE: Record<string, string[]> = {
    'light': [
      '#ffeedb', '#ffd6b2', '#ffbe85', '#ffa455', '#ff8b2b',
      '#ff7200', '#e05d00', '#bf4900', '#8f370b', '#662200'
    ],
    'dark': [
      '#211a19', '#35231a', '#462e1f', '#653c21', '#96562a',
      '#e37f32', '#e39552', '#eead72', '#f7cfa4', '#f9e9d1'
    ]
  };
  private static readonly HSL_ADJUSTMENTS: Record<string, Record<number, HSLAdjustment>> = {
    'light': {
      1: { s: -40, l: 45 },
      2: { s: -30, l: 35 },
      3: { s: -20, l: 25 },
      4: { s: -10, l: 15 },
      5: { s: -5, l: 5 },
      6: { s: 0, l: 0 },
      7: { s: 5, l: -10 },
      8: { s: 10, l: -20 },
      9: { s: 15, l: -30 },
      10: { s: 20, l: -40 }
    },
    'dark': {
      1: { s: -60, l: -35 },
      2: { s: -50, l: -25 },
      3: { s: -40, l: -15 },
      4: { s: -30, l: -5 },
      5: { s: -20, l: 5 },
      6: { s: 0, l: 0 },
      7: { s: -10, l: 15 },
      8: { s: -20, l: 30 },
      9: { s: -30, l: 45 },
      10: { s: -40, l: 60 }
    }
  };

  static generateColorPalette(baseColor: string, theme: string): string[] {
    if (ThemeColorGenerator.isStandardColor(baseColor)) {
      const palette = ThemeColorGenerator.getClosestPalette(baseColor);
      const targetColors = palette[theme] || palette['light'];
      return targetColors;
    }
    return ThemeColorGenerator.generateDynamicColorVariations(baseColor, theme);
  }

  private static getClosestPalette(color: string): Record<string, string[]> {
    const hsl = ThemeColorGenerator.hexToHSL(color);
    const colorDistance = (c1: HSLColor, c2: HSLColor): number => {
      const dh = Math.min(Math.abs(c1.h - c2.h), 360 - Math.abs(c1.h - c2.h));
      const ds = c1.s - c2.s;
      const dl = c1.l - c2.l;
      return Math.sqrt(dh * dh + ds * ds + dl * dl);
    };

    const bluePaletteInfo: PaletteInfo =
      { palette: ThemeColorGenerator.BLUE_PALETTE, baseColor: ThemeColorGenerator.BLUE_PALETTE['light'][5] };
    const greenPaletteInfo: PaletteInfo =
      { palette: ThemeColorGenerator.GREEN_PALETTE, baseColor: ThemeColorGenerator.GREEN_PALETTE['light'][5] };
    const redPaletteInfo: PaletteInfo =
      { palette: ThemeColorGenerator.RED_PALETTE, baseColor: ThemeColorGenerator.RED_PALETTE['light'][5] };
    const orangePaletteInfo: PaletteInfo =
      { palette: ThemeColorGenerator.ORANGE_PALETTE, baseColor: ThemeColorGenerator.ORANGE_PALETTE['light'][5] };

    const palettes: PaletteInfo[] = [
      bluePaletteInfo,
      greenPaletteInfo,
      redPaletteInfo,
      orangePaletteInfo
    ];

    const distances: DistanceInfo[] = palettes.map(paletteInfo => {
      const distanceInfo: DistanceInfo = {
        palette: paletteInfo.palette,
        distance: colorDistance(hsl, ThemeColorGenerator.hexToHSL(paletteInfo.baseColor))
      };
      return distanceInfo;
    });

    distances.sort((a, b) => a.distance - b.distance);
    return distances[0].palette;
  }

  private static isStandardColor(color: string): boolean {
    const standardColors = [
      ThemeColorGenerator.BLUE_PALETTE['light'][5],
      ThemeColorGenerator.GREEN_PALETTE['light'][5],
      ThemeColorGenerator.RED_PALETTE['light'][5],
      ThemeColorGenerator.ORANGE_PALETTE['light'][5]
    ];

    const inputHsl = ThemeColorGenerator.hexToHSL(color);
    return standardColors.some(standardColor => {
      const standardHsl = ThemeColorGenerator.hexToHSL(standardColor);
      const dh = Math.min(Math.abs(inputHsl.h - standardHsl.h), 360 - Math.abs(inputHsl.h - standardHsl.h));
      return dh < 15 && Math.abs(inputHsl.s - standardHsl.s) < 15 && Math.abs(inputHsl.l - standardHsl.l) < 15;
    });
  }

  private static adjustColor(color: string, adjustment: HSLAdjustment): string {
    const hsl = ThemeColorGenerator.hexToHSL(color);
    const newS = Math.max(0, Math.min(100, hsl.s + adjustment.s));
    const newL = Math.max(0, Math.min(100, hsl.l + adjustment.l));
    return ThemeColorGenerator.hslToHex(hsl.h, newS, newL);
  }

  private static generateDynamicColorVariations(baseColor: string, theme: string): string[] {
    const variations: string[] = [];
    const adjustments = ThemeColorGenerator.HSL_ADJUSTMENTS[theme] || ThemeColorGenerator.HSL_ADJUSTMENTS['light'];
    const baseHsl = ThemeColorGenerator.hexToHSL(baseColor);

    const saturationFactor = baseHsl.s > 70 ? 0.8 : baseHsl.s < 30 ? 1.2 : 1.0;
    const lightnessFactor = baseHsl.l > 70 ? 0.8 : baseHsl.l < 30 ? 1.2 : 1.0;

    for (let i = 1; i <= 10; i++) {
      const adjustment: HSLAdjustment = adjustments[i] || { s: 0, l: 0 };
      const adjustedS = adjustment.s * saturationFactor;
      const adjustedL = adjustment.l * lightnessFactor;
      const finalAdjustment: HSLAdjustment = { s: adjustedS, l: adjustedL };
      variations.push(ThemeColorGenerator.adjustColor(baseColor, finalAdjustment));
    }

    return variations;
  }

  private static hexToHSL(hex: string): HSLColor {
    const cleanHex = hex.replace('#', '');
    const r = parseInt(cleanHex.substr(0, 2), 16) / 255;
    const g = parseInt(cleanHex.substr(2, 2), 16) / 255;
    const b = parseInt(cleanHex.substr(4, 2), 16) / 255;

    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h = 0;
    let s = 0;
    const l = (max + min) / 2;

    if (max !== min) {
      const d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

      switch (max) {
        case r:
          h = (g - b) / d + (g < b ? 6 : 0);
          break;
        case g:
          h = (b - r) / d + 2;
          break;
        case b:
          h = (r - g) / d + 4;
          break;
      }
      h /= 6;
    }

    return { h: h * 360, s: s * 100, l: l * 100 };
  }

  private static hslToHex(h: number, s: number, l: number): string {
    h = h / 360;
    s = s / 100;
    l = l / 100;

    const c = (1 - Math.abs(2 * l - 1)) * s;
    const x = c * (1 - Math.abs((h * 6) % 2 - 1));
    const m = l - c / 2;

    let r = 0, g = 0, b = 0;

    const hueSegment = Math.floor(h * 6);
    switch (hueSegment) {
      case 0:
        r = c;
        g = x;
        b = 0;
        break;
      case 1:
        r = x;
        g = c;
        b = 0;
        break;
      case 2:
        r = 0;
        g = c;
        b = x;
        break;
      case 3:
        r = 0;
        g = x;
        b = c;
        break;
      case 4:
        r = x;
        g = 0;
        b = c;
        break;
      case 5:
        r = c;
        g = 0;
        b = x;
        break;
    }

    const red = Math.round((r + m) * 255);
    const green = Math.round((g + m) * 255);
    const blue = Math.round((b + m) * 255);

    return `#${red.toString(16).padStart(2, '0')}${green.toString(16).padStart(2, '0')}${blue.toString(16)
      .padStart(2, '0')}`.toUpperCase();
  }
}

class PredefinedPalettes {
  static readonly BLUE_PALETTE: Record<string, string[]> = {
    'light': [
      '#ebf3ff', '#cce2ff', '#adcfff', '#7aafff', '#4588f5',
      '#1c66e5', '#0d49bf', '#033099', '#001f73', '#00124d'
    ],
    'dark': [
      '#1c2333', '#243047', '#2f4875', '#305ba6', '#2b6ad6',
      '#4086ff', '#5c9dff', '#78b0ff', '#9cc7ff', '#c2deff'
    ]
  };
  static readonly GREEN_PALETTE: Record<string, string[]> = {
    'light': [
      '#dcfae9', '#b6f0d1', '#84e3b5', '#5ad69e', '#3cc98c',
      '#0abf77', '#09a768', '#078f59', '#067049', '#044d37'
    ],
    'dark': [
      '#1a2620', '#22352c', '#2f4f3f', '#377355', '#368f65',
      '#38a673', '#62b58b', '#8bc7a9', '#a9d4bd', '#c8e5d5'
    ]
  };
  static readonly RED_PALETTE: Record<string, string[]> = {
    'light': [
      '#ffe7e6', '#fcc9c7', '#faaeac', '#f58989', '#e86666',
      '#e54545', '#c93439', '#ad2934', '#8f222d', '#6b1a27'
    ],
    'dark': [
      '#2b1c1f', '#422324', '#613234', '#8a4242', '#c2544e',
      '#e6594c', '#e57a6e', '#f3a599', '#facbc3', '#fae4de'
    ]
  };
  static readonly ORANGE_PALETTE: Record<string, string[]> = {
    'light': [
      '#ffeedb', '#ffd6b2', '#ffbe85', '#ffa455', '#ff8b2b',
      '#ff7200', '#e05d00', '#bf4900', '#8f370b', '#662200'
    ],
    'dark': [
      '#211a19', '#35231a', '#462e1f', '#653c21', '#96562a',
      '#e37f32', '#e39552', '#eead72', '#f7cfa4', '#f9e9d1'
    ]
  };

  static getClosestPalette(hexColor: string): Record<string, string[]> {

    const hue = PredefinedPalettes.getHueFromHex(hexColor);

    if (hue >= 200 && hue <= 260) {
      return PredefinedPalettes.BLUE_PALETTE;
    } else if (hue >= 90 && hue <= 150) {
      return PredefinedPalettes.GREEN_PALETTE;
    } else if (hue >= 0 && hue <= 30 || hue >= 330 && hue <= 360) {
      return PredefinedPalettes.RED_PALETTE;
    } else if (hue >= 30 && hue <= 60) {
      return PredefinedPalettes.ORANGE_PALETTE;
    } else {
      return PredefinedPalettes.BLUE_PALETTE;
    }
  }

  static getHueFromHex(hex: string): number {
    const cleanHex = hex.replace('#', '');
    const r = parseInt(cleanHex.substr(0, 2), 16) / 255;
    const g = parseInt(cleanHex.substr(2, 2), 16) / 255;
    const b = parseInt(cleanHex.substr(4, 2), 16) / 255;

    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h = 0;

    if (max !== min) {
      const d = max - min;
      switch (max) {
        case r:
          h = (g - b) / d + (g < b ? 6 : 0);
          break;
        case g:
          h = (b - r) / d + 2;
          break;
        case b:
          h = (r - g) / d + 4;
          break;
      }
      h /= 6;
    }

    return h * 360;
  }
}

export { LightSemanticScheme, DarkSemanticScheme, SemanticColorScheme, PredefinedPalettes, ThemeColorGenerator };
