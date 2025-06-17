import { AbilityConstant, UIAbility, Want, Configuration } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { MMKV } from '@tencent/mmkv';
import { ThemeManager } from 'basecomponent';
import { i18n } from '@kit.LocalizationKit';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    MMKV.initialize(this.context.getApplicationContext());
    this.initTheme();
  }

  initTheme() {
    // 初始化时将颜色模式保存到AppStorage
    AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);
    ThemeManager.getInstance().checkCurrentColorMode();

    let mmkv = MMKV.defaultMMKV();
    let initTheme = mmkv.decodeString("initTheme", "system");
    ThemeManager.getInstance().changeTheme(initTheme ?? "system");
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/SplashScreenPage', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * 配置更新时调用（如深浅色模式变化）
   * @param newConfig 新配置信息
   */
  onConfigurationUpdate(newConfig: Configuration): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onConfigurationUpdate');

    // 更新AppStorage中的颜色模式
    AppStorage.setOrCreate('currentColorMode', newConfig.colorMode);
    ThemeManager.getInstance().checkCurrentColorMode();
    this.context.config = newConfig;
    hilog.info(DOMAIN, 'testTag', 'colorMode: %{public}s', JSON.stringify(AppStorage.get('currentColorMode')) ?? '');

    AppStorage.setOrCreate('currentLanguage', newConfig.language);
  }
}
