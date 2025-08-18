import Prompt from '@system.prompt'
import bundleManager from '@ohos.bundle.bundleManager'
import HttpManager from '../network/HttpManager'
import { ImageSizeUtil, ThemeState, TimeUtil, Log, Toast, TextUtils } from 'atomic_x';
import { MMKV } from '@tencent/mmkv';
import router from '@ohos.router';
import web_webview from '@ohos.web.webview'
import DemoConstants from '../utils/DemoConstants';
import { LoginStore } from 'chatengine';

@Observed
class ImageVerificationJsBridge {
  ticket?: string = undefined;
  captchaAppID?: string = undefined;
  sessionID?: string = undefined;
  randStr?: string = undefined;
  phoneNumber?: string = undefined;
  verifyCode?: string = undefined;
  showWeb: boolean = false;

  verifySuccess(ticket: string, randStr: string): void {
    this.ticket = ticket;
    this.randStr = randStr;

    HttpManager.getSms(this.captchaAppID, this.ticket, this.randStr, this.phoneNumber)
      .then((sessionResponse) => {
        this.sessionID = sessionResponse?.data.data.sessionId;
      })
      .catch((reason: Object) => {
        Log.e("LoginPage", "failed, " + reason);
      });
    this.showWeb = false;
  }

  verifyError(errorCode: number, errorMsg: string): void {
    Toast.shortToast(`verify failed ${errorCode} ${errorMsg}`);
    this.showWeb = false;
  }

  getLanguage(): string {
    return "en";
  }

  getCaptchaAppID(): string | undefined {
    return this.captchaAppID;
  }
}

@Entry
@Component
struct LoginPage {
  @State showDebugLogin: boolean = false;
  @State inLogin: boolean = false;
  @State imageVerificationJsBridge: ImageVerificationJsBridge = new ImageVerificationJsBridge();
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  private controller: web_webview.WebviewController = new web_webview.WebviewController();

  aboutToAppear() {
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      let buildType = bundleInfo.appInfo.appProvisionType;
      if (buildType === "debug") {
        this.showDebugLogin = true;
      }
    }).catch((reason: Object) => {
      Log.e("LoginPage", "get buildType failed, " + reason);
    })
  }

  build() {
    Column() {
      Column({ space: 10 }) {

        TextInput({ placeholder: this.imageVerificationJsBridge.phoneNumber?.toString() ?? "PhoneNumber" })
          .type(InputType.PhoneNumber)
          .borderRadius(4)
          .onChange((str) => {
            this.imageVerificationJsBridge.phoneNumber = str;
          });

        Button("Get VerifyCode")
          .fontColor(Color.White)
          .padding(8)
          .type(ButtonType.Normal)
          .borderRadius(6)
          .stateStyles({
            normal: {.opacity(1)
            },
            disabled: {.opacity(0.6)
            }
          })
          .enabled((!this.inLogin) && !TextUtils.isEmpty(this.imageVerificationJsBridge.phoneNumber))
          .onClick(() => {
            HttpManager.getCaptchaAppID()
              .then((captchaAppID) => {
                this.imageVerificationJsBridge.captchaAppID = captchaAppID?.toString();
                this.imageVerificationJsBridge.showWeb = true;
              })
              .catch((reason: Object) => {
                Log.e("LoginPAge", "get verify code failed, " + reason);
              })
          })

        TextInput({ placeholder: "VerifyCode" })
          .type(InputType.Number)
          .borderRadius(4)
          .onChange((str) => {
            this.imageVerificationJsBridge.verifyCode = str;
          });

        Button($r("app.string.demo_login_button_name"), { stateEffect: true, type: ButtonType.Normal })
          .fontSize($r("app.float.demo_dev_login_user_name_font_size"))
          .fontColor(Color.White)
          .width('100%')
          .borderRadius(6)
          .stateStyles({
            normal: {.opacity(1)
            },
            disabled: {.opacity(0.6)
            }
          })
          .padding(12)
          .enabled((!this.inLogin) && !TextUtils.isEmpty(this.imageVerificationJsBridge.phoneNumber) &&
            !TextUtils.isEmpty(this.imageVerificationJsBridge.verifyCode))
          .margin({ top: 30 })
          .onClick(() => {
            this.login();
          })

        if (this.showDebugLogin) {
          Button("开发者登录", { stateEffect: true, type: ButtonType.Normal })
            .width('90%')
            .padding(6)
            .borderRadius(6)
            .fontColor(Color.White)
            .onClick(() => {
              router.replaceUrl({ url: "pages/DevLoginPage" });
            })
        }
      }

      Column() {
        if (this.imageVerificationJsBridge.showWeb) {
          Web({ src: $rawfile("verification.html"), controller: this.controller })
            .javaScriptAccess(true)
            .javaScriptProxy({
              object: this.imageVerificationJsBridge,
              name: "imageVerificationJsBridge",
              methodList: ["verifySuccess", "verifyError", "getCaptchaAppID", "getLanguage"],
              controller: this.controller
            })
        }
      }
    }.width('100%')
    .height('100%')
  }

  login() {
    if (this.imageVerificationJsBridge.phoneNumber && this.imageVerificationJsBridge.verifyCode &&
    this.imageVerificationJsBridge.sessionID) {
      this.inLogin = true;
      HttpManager.login(this.imageVerificationJsBridge.phoneNumber, this.imageVerificationJsBridge.verifyCode,
        this.imageVerificationJsBridge.sessionID)
        .then((loginInfo) => {
          let mmkv = MMKV.defaultMMKV();
          mmkv.encodeString(DemoConstants.LOGIN_USER_ID, loginInfo.data.data.userId);
          mmkv.encodeString(DemoConstants.LOGIN_USER_SIG, loginInfo.data.data.userSig);
          mmkv.encodeBool(DemoConstants.AUTO_LOGIN, true);
          return LoginStore.createInstance()
            .login(loginInfo.data.data.sdkAppId, loginInfo.data.data.userId, loginInfo.data.data.userSig);
        })
        .then(() => {
          Log.i("DevLoginPage", "login success");
          this.inLogin = false;
          Toast.shortToast(`User ${LoginStore.createInstance().state?.loginUserInfo?.userID} login success`);
          return router.replaceUrl({ url: "pages/MainPage" });
        })
        .catch((reason: Object) => {
          this.inLogin = false;
          Log.i("LoginPage", "login failed, " + reason);
        });
    }
  }
}