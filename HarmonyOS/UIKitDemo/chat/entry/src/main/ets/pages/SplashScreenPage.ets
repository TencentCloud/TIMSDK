import router from '@ohos.router';
import hilog from '@ohos.hilog';
import { genTestUserSig, SDKAPPID } from '../signature/GenerateTestUserSig';
import Prompt from '@system.prompt';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { ImageSizeUtil, ThemeState, TimeUtil, Log, Toast, TextUtils } from 'atomic_x';
import { MMKV } from '@tencent/mmkv';
import DemoConstants from '../utils/DemoConstants';
import { LoginStore, UserInfo } from 'chatengine';
import { AppBuilderConfig, AppBuilderHelper } from 'atomic_x';

@Entry
@Component
struct SplashScreenPage {
  aboutToAppear() {
    let mmkv = MMKV.defaultMMKV();
    let autoLogin = mmkv.decodeBool(DemoConstants.AUTO_LOGIN, false);
    if (autoLogin) {
      let userID = mmkv.decodeString(DemoConstants.LOGIN_USER_ID);
      let userSig = mmkv.decodeString(DemoConstants.LOGIN_USER_SIG);
      LoginStore.createInstance()
        .login(SDKAPPID, userID!!, userSig!!, getContext().getApplicationContext())
        .then(() => {
          return router.replaceUrl({ url: "pages/MainPage" });
        })
        .catch((reason: Object) => {
          Log.e("SplashScreenPage", "auto login failed, " + reason);
          router.replaceUrl({ url: "pages/LoginPage" });
        });
    } else {
      router.replaceUrl({ url: "pages/LoginPage" })
    }
  }

  build() {
    Column() {
      Image($r("app.media.demo_ic_logo"))
        .width($r("app.float.demo_splash_icon_width"))
        .width($r("app.float.demo_splash_icon_height"))
        .interpolation(ImageInterpolation.High)
        .objectFit(ImageFit.Contain)

      Text($r('app.string.demo_title'))
        .fontColor(Color.Black)
        .fontSize($r("app.float.demo_splash_title_font_size"))
        .fontWeight(FontWeight.Bold)
        .margin({ top: $r("app.float.demo_splash_title_margin_top") })
    }
    .alignItems(HorizontalAlign.Center)
    .align(Alignment.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}
