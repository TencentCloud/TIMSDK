import { LoginStore } from 'chatengine';
import Prompt from '@system.prompt';
import { genTestUserSig, SDKAPPID } from '../signature/GenerateTestUserSig';
import router from '@ohos.router';
import { MMKV } from '@tencent/mmkv';
import { ImageSizeUtil, ThemeState, TimeUtil, Log, Toast } from 'atomic_x';
import DemoConstants from '../utils/DemoConstants';

@Entry
@Component
struct DevLoginPage {
  @State userID?: string = undefined;
  @State inLogin: boolean = false;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  private mmkv?: MMKV;

  aboutToAppear() {
    this.mmkv = MMKV.defaultMMKV();
    let userID = this.mmkv.decodeString(DemoConstants.LOGIN_USER_ID);
    if (userID && userID.length > 0) {
      this.userID = userID;
    }
  }

  build() {
    Column() {

      Image($r("app.media.demo_ic_logo"))
        .width("60%")
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Contain)

      Row({ space: 10 }) {
        Text($r("app.string.demo_dev_login_user_name"))
          .fontColor(this.themeState.colors.textColorPrimary)
          .fontSize($r("app.float.demo_dev_login_user_name_font_size"))

        TextInput({ placeholder: this.userID ?? $r("app.string.demo_dev_login_user_name") })
          .layoutWeight(1)
          .fontColor(this.themeState.colors.textColorPrimary)
          .fontSize($r("app.float.demo_dev_login_user_name_font_size"))
          .borderRadius(4)
          .onChange((str: string) => {
            this.userID = str;
          })
      }
      .width('100%')
      .margin({ top: 100 })

      Button($r("app.string.demo_login_button_name"), { stateEffect: true, type: ButtonType.Normal })
        .fontSize($r("app.float.demo_dev_login_user_name_font_size"))
        .fontColor(Color.White)
        .width('100%')
        .borderRadius(6)
        .padding(12)
        .enabled(!this.inLogin && (this.userID?.length ?? 0) > 0)
        .stateStyles({
          normal: {
            .opacity(1)
          },
          disabled: {
            .opacity(0.6)
          }
        })
        .margin({ top: 30 })
        .onClick(() => {
          this.login();
        })

    }
    .padding(16)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  login() {
    if (this.userID && this.userID.length > 0) {
      this.inLogin = true;
      let userSig = genTestUserSig(this.userID);
      this.mmkv?.encodeString(DemoConstants.LOGIN_USER_ID, this.userID);
      this.mmkv?.encodeString(DemoConstants.LOGIN_USER_SIG, userSig);
      this.mmkv?.encodeBool(DemoConstants.AUTO_LOGIN, true);
      LoginStore.createInstance().login(SDKAPPID, this.userID, userSig).then(() => {
        Log.i("DevLoginPage", "login success");
        this.inLogin = false;
        Toast.shortToast(`User ${LoginStore.createInstance().state.loginUserInfo?.userID} login success`);
        return router.replaceUrl({ url: "pages/MainPage" });
      }).catch((reason: Object) => {
        this.inLogin = false;
        Log.i("DevLoginPage", "login failed, " + reason);
      });
    }
  }
}