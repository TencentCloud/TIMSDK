// import { Log, TitleBar, V2TIMManager, V2TIMUserFullInfo, BaseComponent, UserData, MMKV, Toast } from 'timcommon'
import { MMKV } from '@tencent/mmkv';
import { LoginStore, UserInfo } from 'chatengine';
import { ImageSizeUtil, ThemeState, TimeUtil, Log, Toast, TextUtils, ToastType, } from 'atomic_x';

import Prompt from '@system.prompt';
import router from '@ohos.router';
import DemoConstants from '../utils/DemoConstants';
import { i18n } from '@kit.LocalizationKit';
import systemDateTime from '@ohos.systemDateTime';
import { Configuration, LengthMetrics } from '@kit.ArkUI';
import { BaseComponent } from 'atomic_x';
import { UserData } from 'atomic_x'
import { it } from '@ohos/hypium';
import { Want, common } from '@kit.AbilityKit';
import { ThemeMode } from 'atomic_x';

@Component
@Preview
@Entry
export struct ProfilePage {
  private static readonly LARGE_TITLE_HEIGHT: number = 52;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    Column() {
      // TitleBar({ propTitle: "", title: $r('app.string.demo_profile_tab_name'), canBack: false })
      this.LargeTitleBuilder();
      Scroll() {
        Column() {
          SelfInfoView()
          SettingItemView()
          Column() {
            Button($r("app.string.demo_logout_button_name"), { type: ButtonType.Normal, stateEffect: true })
              .fontColor(Color.White)
              .backgroundColor(this.themeState.colors.buttonColorPrimaryDefault)
              .width('90%')
              .borderRadius(8)
              .height(56)
              .margin({ top: 16, bottom: 38 })
              .onClick(() => {
                LoginStore.createInstance().logout().then(() => {
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
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  LargeTitleBuilder() {
    Row() {
      Text($r('app.string.setting_title'))
        .fontSize(34)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.colors.textColorPrimary)
        .fontFamily('PingFang HK')
        .layoutWeight(1)
    }
    .width('100%')
    .height(ProfilePage.LARGE_TITLE_HEIGHT)
    .padding({ left: 16, right: 16 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }
}

@Component
struct SelfInfoView {
  @State selfInfo: UserData | undefined = undefined;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  aboutToAppear() {
    // this.selfInfo.
    let info = LoginStore.createInstance().state.loginUserInfo;
    if (LoginStore.createInstance().state.loginUserInfo) {
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
        .borderRadius(4)
        .alt($r('app.media.app_icon'))
        .alignRules({
          start: { anchor: "__container__", align: HorizontalAlign.Start },
        })

      Text(this.selfInfo?.displayName)
        .id("userName")
        .fontSize($r("app.float.demo_profile_name_font_size"))
        .fontColor(this.themeState.colors.textColorPrimary)
        .fontWeight(FontWeight.Medium)
        .margin({
          left: 16
        })
        .alignRules({
          left: { anchor: "faceUrl", align: HorizontalAlign.End },
          top: { anchor: "faceUrl", align: VerticalAlign.Top }
        })

      Row() {
        Text("ID:")
          .id("userIDLabel")
          .fontColor(this.themeState.colors.textColorPrimary)
          .fontSize($r("app.float.demo_profile_id_font_size"))

        Text(this.selfInfo?.ID)
          .id("userID")
          .fontColor(this.themeState.colors.textColorPrimary)
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
        .fontColor(this.themeState.colors.textColorPrimary)
        .fontSize($r("app.float.demo_profile_id_font_size"))
        .margin({ top: 10 })
        .alignRules({
          left: { anchor: "idRow", align: HorizontalAlign.Start },
          top: { anchor: "idRow", align: VerticalAlign.Bottom }
        })

      Text(this.selfInfo?.signature)
        .id("signature")
        .fontColor(this.themeState.colors.textColorPrimary)
        .fontSize($r("app.float.demo_profile_id_font_size"))
        .alignRules({
          left: { anchor: "signatureLabel", align: HorizontalAlign.End },
          top: { anchor: "signatureLabel", align: VerticalAlign.Top }
        })

      Image($rawfile("basecomponent/common_forward_icon.svg"))
        .id("forwardIcon")
        .width(14)
        .height(14)
        .objectFit(ImageFit.Contain)
        .alignRules({
          right: { anchor: "__container__", align: HorizontalAlign.End },
          center: { anchor: "idRow", align: VerticalAlign.Center }
        })
    }
    .backgroundColor(this.themeState.colors.bgColorBubbleReciprocal)
    .id("selfInfoSettings")
    .width('100%')
    .height('auto')
    .padding({
      top: $r("app.float.demo_profile_face_image_margin_top"),
      bottom: $r("app.float.demo_profile_face_image_margin_top"),
      left: 16,
      right: 16
    })
    .borderRadius(12)
    .margin({ top: 16, left: 16, right: 16 })
    .onClick(() => {
      Toast.show("Set Profile", ToastType.Loading, this.getUIContext(), 3000)
    })
  }
}

@Component
struct SettingItemView {
  @State themeSelectVisible: boolean = false;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ThemeSelectDialog({
      onClose: () => {
        this.themeSelectVisible = false;
      },
      onSelectTheme: (theme: string) => {
        switch (theme) {
          case 'light':
            this.themeState.setThemeMode(ThemeMode.light);
            break;
          case 'dark':
            this.themeState.setThemeMode(ThemeMode.dark);
            break;
          case 'system':
            this.themeState.setThemeMode(ThemeMode.system);
            break;
          case 'custom':
            this.themeState.setPrimaryColor(this.generateRandomColor())
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
    maskColor: 'rgba(0, 0, 0, 0.6)'
  });

  aboutToAppear() {
  }

  build() {
    Column() {
      SettingItem({ text: $r("app.string.demo_theme_button_name") })
        .onClick(() => {
          this.dialogController.open();
          this.themeSelectVisible = true;
        })

      Divider().height(0.4).color(this.themeState.colors.strokeColorPrimary).width('100%')

      SettingItem({ text: $r("app.string.demo_switch_language_button_name") })
        .onClick(() => {
          let appContext = getContext().getApplicationContext();

          let mmkv = MMKV.defaultMMKV();

          let currentLanguage = mmkv.decodeString("currentLanguage") ?? Configuration.getLocale().language;
          let preferredLanguage = i18n.System.getAppPreferredLanguage();
          if (preferredLanguage && preferredLanguage.length > 0) {

            currentLanguage = preferredLanguage;
          } else {

            currentLanguage = Configuration.getLocale().language;
          }

          let targetLanguage = '';
          let targetLanguageName = '';


          if (currentLanguage.startsWith('zh')) {
            targetLanguage = 'en-US';
            targetLanguageName = 'English';
          } else if (currentLanguage.startsWith('en')) {
            targetLanguage = 'zh-CN';
            targetLanguageName = '中文';
          } else {

            targetLanguage = 'zh-CN';
            targetLanguageName = '中文';
          }

          mmkv.encodeString("currentLanguage", targetLanguage);


          try {

            appContext.setLanguage(targetLanguage);
            i18n.System.setAppPreferredLanguage(targetLanguage);
            console.info("Configuration.getLocale().language ", Configuration.getLocale().language);
            console.info(`App preferred language set to: ${targetLanguage}`);

            this.restartApplication();

          } catch (error) {
            console.error('Failed to set app preferred language:', error);
          }
        })

      Divider().height(0.4).color(this.themeState.colors.strokeColorPrimary).width('100%')

      SettingItem({ text: $r("app.string.demo_about_button_name") })
        .onClick(() => {
          Toast.shortToast(getContext().resourceManager.getStringSync($r("app.string.demo_title")));
        })

      Divider().height(0.4).color(this.themeState.colors.strokeColorPrimary).width('100%')
    }
    .width('100%')
    .backgroundColor(this.themeState.colors.bgColorBubbleReciprocal)
    .borderRadius(12)
    .margin({ top: 16, left: 16, right: 16 })
  }

  private generateRandomColor(): string {

    const colorPalettes = [

      '#1E88E5', '#2196F3', '#42A5F5', '#64B5F6', '#0D47A1', '#1565C0',

      '#43A047', '#4CAF50', '#66BB6A', '#81C784', '#2E7D32', '#388E3C',

      '#E53935', '#F44336', '#EF5350', '#E57373', '#C62828', '#D32F2F',

      '#FB8C00', '#FF9800', '#FFA726', '#FFB74D', '#E65100', '#F57C00',

      '#8E24AA', '#9C27B0', '#AB47BC', '#BA68C8', '#6A1B9A', '#7B1FA2',

      '#00ACC1', '#00BCD4', '#26C6DA', '#4DD0E1', '#006064', '#00838F',

      '#00695C', '#00796B', '#26A69A', '#4DB6AC', '#004D40', '#00695C',

      '#3F51B5', '#5C6BC0', '#7986CB', '#9FA8DA', '#283593', '#303F9F'
    ];
    const randomIndex = Math.floor(Math.random() * colorPalettes.length);
    return colorPalettes[randomIndex];
  }

  private restartApplication() {
    try {
      const context = getContext() as common.UIAbilityContext;


      setTimeout(() => {

        context.terminateSelf().then(() => {
          console.info('Application terminated successfully');

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
          this.fallbackRestart();
        });
      }, 500);

    } catch (error) {
      console.error('Error during application restart:', error);
      this.fallbackRestart();
    }
  }

  private fallbackRestart() {
    try {

      router.clear();


      router.replaceUrl({
        url: 'pages/SplashScreenPage'
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
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    Column() {
      Row() {
        Text(this.text)
          .fontSize(17)
          .fontColor(this.themeState.colors.textColorPrimary)
          .layoutWeight(1)
          .margin({ left: 16 })
          .fontFamily('PingFang HK')

        Image($rawfile("basecomponent/common_forward_icon.svg"))
          .id("forwardIcon")
          .width(14)
          .height(14)
          .objectFit(ImageFit.Contain)
          .margin({ right: 16 })
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
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();

  build() {
    Column() {
      // Title
      Text($r('app.string.theme_select_title'))
        .fontSize(18)
        .fontColor(this.themeState.colors.textColorPrimary)
        .fontWeight(FontWeight.Medium)
        .margin({ top: 16, bottom: 16 })
        .width('100%')
        .textAlign(TextAlign.Center)


      Column() {

        Row() {
          Text($r('app.string.theme_light'))
            .fontSize(17)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .layoutWeight(1)

          if (this.themeState.getCurrentThemeType() === 'light') {
            Image($r('app.media.ic_public_check'))
              .width(24)
              .height(24)
              .fillColor(this.themeState.colors.buttonColorPrimaryDefault)
          }
        }
        .width('100%')
        .height(ThemeSelectDialog.BUTTON_HEIGHT)
        .padding({ start: LengthMetrics.vp(16), end: LengthMetrics.vp(16) })
        .onClick(() => {
          this.onSelectTheme?.('light');
          this.controller?.close();
        })

        Divider().height(0.4).color(this.themeState.colors.strokeColorPrimary).width('100%')


        Row() {
          Text($r('app.string.theme_dark'))
            .fontSize(17)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .layoutWeight(1)

          if (this.themeState.getCurrentThemeType() === 'dark') {
            Image($r('app.media.ic_public_check'))
              .width(24)
              .height(24)
              .fillColor(this.themeState.colors.buttonColorPrimaryDefault)
          }
        }
        .width('100%')
        .height(ThemeSelectDialog.BUTTON_HEIGHT)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.onSelectTheme?.('dark');
          this.controller?.close();
        })

        Divider().height(0.4).color(this.themeState.colors.strokeColorPrimary).width('100%')


        Row() {
          Text($r('app.string.theme_system'))
            .fontSize(17)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .layoutWeight(1)

          if (this.themeState.getCurrentThemeType() === 'system') {
            Image($r('app.media.ic_public_check'))
              .width(24)
              .height(24)
              .fillColor(this.themeState.colors.buttonColorPrimaryDefault)
          }
        }
        .width('100%')
        .height(ThemeSelectDialog.BUTTON_HEIGHT)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.onSelectTheme?.('system');
          this.controller?.close();
        })

        Divider().height(0.4).color(this.themeState.colors.strokeColorPrimary).width('100%')


        Row() {
          Text('随机颜色')
            .fontSize(17)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .layoutWeight(1)
        }
        .width('100%')
        .height(ThemeSelectDialog.BUTTON_HEIGHT)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.onSelectTheme?.('custom');
          this.controller?.close();
        })
      }
      .width('100%')
      .backgroundColor(this.themeState.colors.bgColorBubbleReciprocal)
      .borderRadius(12)


      Button($r('app.string.cancel'))
        .width('100%')
        .height(ThemeSelectDialog.BUTTON_HEIGHT)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.colors.buttonColorPrimaryDefault)
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .borderRadius(ThemeSelectDialog.BOTTOM_RADIUS)
        .margin({ top: 12, bottom: 38 })
        .onClick(() => {
          this.onClose?.();
          this.controller?.close();
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }
}