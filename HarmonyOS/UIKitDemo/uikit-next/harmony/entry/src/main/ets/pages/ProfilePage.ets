// import { Log, TitleBar, V2TIMManager, V2TIMUserFullInfo, BaseComponent, UserData, MMKV, Toast } from 'timcommon'
import { MMKV } from '@tencent/mmkv';
import { ChatEngine, UserInfo } from 'chatengine';
import { ImageSizeUtil, ThemeManager, TimeUtil, Log, Toast, TextUtils } from 'basecomponent';

import Prompt from '@system.prompt';
import router from '@ohos.router';
import DemoConstants from '../utils/DemoConstants';
import { i18n } from '@kit.LocalizationKit';
import systemDateTime from '@ohos.systemDateTime';
import { Configuration, LengthMetrics } from '@kit.ArkUI';
import BaseComponent from 'basecomponent/src/main/ets/pages/BaseComponent';
import UserData from 'messagelist/src/main/ets/datas/UserData'
import { it } from '@ohos/hypium';
import { Want, common } from '@kit.AbilityKit';

@Component
@Preview
@Entry
export struct ProfilePage {
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();

  build() {
    Column() {
      // TitleBar({ propTitle: "", title: $r('app.string.demo_profile_tab_name'), canBack: false })

      Scroll() {
        Column() {
          SelfInfoView()
          SettingItemView()
          Column() {
            Button($r("app.string.demo_logout_button_name"), { type: ButtonType.Normal, stateEffect: true })
              .fontColor(Color.White)
              .backgroundColor(this.themeManager.currentTheme.buttonColorPrimaryDefault)
              .width('90%')
              .borderRadius(8)
              .height(56)
              .margin({ top: 16, bottom: 38 })
              .onClick(() => {
                ChatEngine.getInstance().logout().then(() => {
                  let mmkv = MMKV.defaultMMKV();
                  mmkv.removeValueForKey(DemoConstants.AUTO_LOGIN);
                  mmkv.removeValueForKey(DemoConstants.LOGIN_USER_SIG);
                  return router.replaceUrl({ url: "pages/DevLoginPage" });
                }).catch((reason: Object) => {
                  Log.e("Profile", "logout failed, " + reason);
                })
              })
          }
          .width('100%')
          .margin({ top: "10vp" })
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.TopStart)
    }
    .width('100%')
    .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
  }
}

@Component
struct SelfInfoView {
  @State selfInfo: UserData | undefined = undefined;
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();

  aboutToAppear() {
    // this.selfInfo.
    let info = ChatEngine.getInstance().currentUserInfo;
    if (ChatEngine.getInstance().currentUserInfo) {
      this.selfInfo = UserData.parseUserData(info);
    }
  }

  build() {
    RelativeContainer() {
      Image(this.selfInfo?.faceUrl)
        .id("faceUrl")
        .width($r("app.float.demo_profile_face_size"))
        .height($r("app.float.demo_profile_face_size"))
        .objectFit(ImageFit.Contain)
        .interpolation(ImageInterpolation.Medium)
        .borderRadius(BaseComponent.imageRadius())
        .alt($r('app.media.app_icon'))
        .alignRules({
          start: { anchor: "__container__", align: HorizontalAlign.Start },
        })

      Text(this.selfInfo?.displayName)
        .id("userName")
        .fontSize($r("app.float.demo_profile_name_font_size"))
        .fontColor(this.themeManager.currentTheme.textColorPrimary)
        .fontWeight(FontWeight.Medium)
        .margin({
          left: BaseComponent.paddingStartEnd()
        })
        .alignRules({
          left: { anchor: "faceUrl", align: HorizontalAlign.End },
          top: { anchor: "faceUrl", align: VerticalAlign.Top }
        })

      Row() {
        Text("ID:")
          .id("userIDLabel")
          .fontColor(this.themeManager.currentTheme.textColorPrimary)
          .fontSize($r("app.float.demo_profile_id_font_size"))

        Text(this.selfInfo?.ID)
          .id("userID")
          .fontColor(this.themeManager.currentTheme.textColorPrimary)
          .fontSize($r("app.float.demo_profile_id_font_size"))
      }
      .id("idRow")
      .margin({ top: 10 })
      .alignRules({
        left: { anchor: "userName", align: HorizontalAlign.Start },
        top: { anchor: "userName", align: VerticalAlign.Bottom },
      })

      Text($r("app.string.demo_profile_signature_label"))
        .id("signatureLabel")
        .fontColor(this.themeManager.currentTheme.textColorPrimary)
        .fontSize($r("app.float.demo_profile_id_font_size"))
        .margin({ top: 10 })
        .alignRules({
          left: { anchor: "idRow", align: HorizontalAlign.Start },
          top: { anchor: "idRow", align: VerticalAlign.Bottom }
        })

      Text(this.selfInfo?.signature)
        .id("signature")
        .fontColor(this.themeManager.currentTheme.textColorPrimary)
        .fontSize($r("app.float.demo_profile_id_font_size"))
        .alignRules({
          left: { anchor: "signatureLabel", align: HorizontalAlign.End },
          top: { anchor: "signatureLabel", align: VerticalAlign.Top }
        })

      Image(BaseComponent.forwardIcon())
        .id("forwardIcon")
        .width($r("app.float.demo_profile_forward_button_size"))
        .height($r("app.float.demo_profile_forward_button_size"))
        .objectFit(ImageFit.Contain)
        .alignRules({
          right: { anchor: "__container__", align: HorizontalAlign.End },
          center: { anchor: "idRow", align: VerticalAlign.Center }
        })
    }
    .backgroundColor(this.themeManager.currentTheme.bgColorBubbleReciprocal)
    .id("selfInfoSettings")
    .width('100%')
    .height('auto')
    .padding({
      top: $r("app.float.demo_profile_face_image_margin_top"),
      bottom: $r("app.float.demo_profile_face_image_margin_top"),
      left: BaseComponent.paddingStartEnd(),
      right: BaseComponent.paddingStartEnd()
    })
    .borderRadius(12)
    .margin({ top: 16, left: 16, right: 16 })
    .onClick(() => {
      Toast.shortToast("Set Profile")
    })
  }
}

@Component
struct SettingItemView {
  @State themeSelectVisible: boolean = false;
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ThemeSelectDialog({
      onClose: () => {
        this.themeSelectVisible = false;
      },
      onSelectTheme: (theme: string) => {
        let mmkv = MMKV.defaultMMKV();
        // 设置主题
        switch (theme) {
          case 'light':
            this.themeManager.changeTheme('light');
            mmkv.encodeString("initTheme", "light");
            break;
          case 'dark':
            this.themeManager.changeTheme('dark');
            mmkv.encodeString("initTheme", "dark");
            break;
          case 'system':
            this.themeManager.changeTheme('system');
            mmkv.encodeString("initTheme", "system");
            break;
        }
        this.themeSelectVisible = false;
      }
    }),
    cancel: () => {
      this.themeSelectVisible = false;
    },
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    customStyle: true,
    maskColor: 'rgba(0, 0, 0, 0.6)' // 半透明黑色背景
  });

  build() {
    Column() {
      SettingItem({ text: $r("app.string.demo_theme_button_name") })
        .onClick(() => {
          this.dialogController.open();
          this.themeSelectVisible = true;
        })

      Divider().height(0.4).color(this.themeManager.currentTheme.strokeColorPrimary).width('100%')

      SettingItem({ text: $r("app.string.demo_switch_language_button_name") })
        .onClick(() => {
          let appContext = getContext().getApplicationContext();

          let mmkv = MMKV.defaultMMKV();

          let currentLanguage = mmkv.decodeString("currentLanguage") ?? Configuration.getLocale().language;
          let preferredLanguage = i18n.System.getAppPreferredLanguage();
          //
          if (preferredLanguage && preferredLanguage.length > 0) {
            // 如果有偏好语言，使用偏好语言
            currentLanguage = preferredLanguage;
          } else {
            // 如果没有偏好语言，使用系统语言
            currentLanguage = Configuration.getLocale().language;
          }

          let targetLanguage = '';
          let targetLanguageName = '';

          // 在中英文之间切换
          if (currentLanguage.startsWith('zh')) {
            targetLanguage = 'en-US';
            targetLanguageName = 'English';
          } else if (currentLanguage.startsWith('en')) {
            targetLanguage = 'zh-CN';
            targetLanguageName = '中文';
          } else {
            // 其他语言默认切换到中文
            targetLanguage = 'zh-CN';
            targetLanguageName = '中文';
          }

          mmkv.encodeString("currentLanguage", targetLanguage);
          console.info(`当前语言: ${currentLanguage}, 切换到: ${targetLanguage}`);

          try {
            // 设置应用语言
            appContext.setLanguage(targetLanguage);
            i18n.System.setAppPreferredLanguage(targetLanguage);
            console.info("Configuration.getLocale().language ", Configuration.getLocale().language);
            console.info(`App preferred language set to: ${targetLanguage}`);
            // 设置完成后重启应用
            this.restartApplication();

          } catch (error) {
            console.error('Failed to set app preferred language:', error);
          }
        })

      Divider().height(0.4).color(this.themeManager.currentTheme.strokeColorPrimary).width('100%')

      SettingItem({ text: $r("app.string.demo_about_button_name") })
        .onClick(() => {
          Toast.shortToast(getContext().resourceManager.getStringSync($r("app.string.demo_title")));
        })
    }
    .width('100%')
    .backgroundColor(this.themeManager.currentTheme.bgColorBubbleReciprocal)
    .borderRadius(12)
    .margin({ top: 16, left: 16, right: 16 })
  }

  /**
   * 重启应用方法
   */
  private restartApplication() {
    try {
      const context = getContext() as common.UIAbilityContext;

      // 延迟一小段时间确保设置生效，然后重启应用
      setTimeout(() => {
        // 方法1: 终止当前应用并重新启动
        context.terminateSelf().then(() => {
          console.info('Application terminated successfully');
          // 重新启动应用
          context.startAbility({
            bundleName: context.applicationInfo.name,
            abilityName: 'EntryAbility'
          }).then(() => {
            console.info('Application restarted successfully');
          }).catch((error: Error) => {
            console.error('Failed to restart application:', error);
          });
        }).catch((error: Error) => {
          console.error('Failed to terminate application:', error);
          // 如果终止失败，尝试路由重启
          this.fallbackRestart();
        });
      }, 500);

    } catch (error) {
      console.error('Error during application restart:', error);
      this.fallbackRestart();
    }
  }

  /**
   * 备用重启方法 - 清空路由栈并重新加载
   */
  private fallbackRestart() {
    try {
      // 清空所有路由栈
      router.clear();

      // 重新加载到主页面
      router.replaceUrl({
        url: 'pages/SplashScreenPage' // 使用您的启动页面
      }).then(() => {
        console.info('Page reloaded successfully');
      }).catch((error: Error) => {
        console.error('Failed to reload page:', error);
      });

    } catch (error) {
      console.error('Fallback restart failed:', error);
    }
  }
}

@Component
struct SettingItem {
  text: string | Resource = "";
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();

  build() {
    Column() {
      Row() {
        Text(this.text)
          .fontSize(17)
          .fontColor(this.themeManager.currentTheme.textColorPrimary)
          .layoutWeight(1)
          .margin({ left: BaseComponent.paddingStartEnd() })
          .fontFamily('PingFang HK')

        Image(BaseComponent.forwardIcon())
          .id("forwardIcon")
          .width($r("app.float.demo_profile_forward_button_size"))
          .height($r("app.float.demo_profile_forward_button_size"))
          .objectFit(ImageFit.Contain)
          .margin({ right: BaseComponent.paddingStartEnd() })
      }
      .width('100%')
      .height(56)
      .padding({
        top: 8,
        bottom: 8
      })
    }
  }
}

@CustomDialog
struct ThemeSelectDialog {
  private static readonly BUTTON_HEIGHT: number = 56;
  private static readonly BOTTOM_RADIUS: number = 14;
  controller?: CustomDialogController;
  onClose?: () => void;
  onSelectTheme?: (theme: string) => void;
  @StorageLink('themeManager') themeManager: ThemeManager = ThemeManager.getInstance();

  build() {
    Column() {
      // 标题
      Text($r('app.string.theme_select_title'))
        .fontSize(18)
        .fontColor(this.themeManager.currentTheme.textColorPrimary)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 16 })
        .width('100%')
        .textAlign(TextAlign.Center)

      // 选项列表
      Column() {
        // 明亮主题
        Row() {
          Text($r('app.string.theme_light'))
            .fontSize(17)
            .fontColor(this.themeManager.currentTheme.textColorPrimary)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .layoutWeight(1)

          if (this.themeManager.getCurrentThemeType() === 'light') {
            Image($r('app.media.ic_public_check'))
              .width(24)
              .height(24)
              .fillColor(this.themeManager.currentTheme.buttonColorPrimaryDefault)
          }
        }
        .width('100%')
        .height(ThemeSelectDialog.BUTTON_HEIGHT)
        .padding({ start: LengthMetrics.vp(16), end: LengthMetrics.vp(16) })
        .onClick(() => {
          this.onSelectTheme?.('light');
          this.controller?.close();
        })

        Divider().height(0.4).color(this.themeManager.currentTheme.strokeColorPrimary).width('100%')

        // 暗黑主题
        Row() {
          Text($r('app.string.theme_dark'))
            .fontSize(17)
            .fontColor(this.themeManager.currentTheme.textColorPrimary)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .layoutWeight(1)

          if (this.themeManager.getCurrentThemeType() === 'dark') {
            Image($r('app.media.ic_public_check'))
              .width(24)
              .height(24)
              .fillColor(this.themeManager.currentTheme.buttonColorPrimaryDefault)
          }
        }
        .width('100%')
        .height(ThemeSelectDialog.BUTTON_HEIGHT)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.onSelectTheme?.('dark');
          this.controller?.close();
        })

        Divider().height(0.4).color(this.themeManager.currentTheme.strokeColorPrimary).width('100%')

        // 跟随系统
        Row() {
          Text($r('app.string.theme_system'))
            .fontSize(17)
            .fontColor(this.themeManager.currentTheme.textColorPrimary)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .layoutWeight(1)

          if (this.themeManager.getCurrentThemeType() === 'system') {
            Image($r('app.media.ic_public_check'))
              .width(24)
              .height(24)
              .fillColor(this.themeManager.currentTheme.buttonColorPrimaryDefault)
          }
        }
        .width('100%')
        .height(ThemeSelectDialog.BUTTON_HEIGHT)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.onSelectTheme?.('system');
          this.controller?.close();
        })
      }
      .width('100%')
      .backgroundColor(this.themeManager.currentTheme.bgColorBubbleReciprocal)
      .borderRadius(12)

      // 取消按钮
      Button($r('app.string.cancel'))
        .width('100%')
        .height(ThemeSelectDialog.BUTTON_HEIGHT)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeManager.currentTheme.buttonColorPrimaryDefault)
        .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
        .borderRadius(ThemeSelectDialog.BOTTOM_RADIUS)
        .margin({ top: 12, bottom: 38 })
        .onClick(() => {
          this.onClose?.();
          this.controller?.close();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeManager.currentTheme.bgColorOperate)
  }
}