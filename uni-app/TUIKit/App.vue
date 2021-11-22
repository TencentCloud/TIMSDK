<script>
  import TIM from 'tim-wx-sdk';
  import COS from "cos-wx-sdk-v5";
  import logger from './utils/logger'; // app.js
  import { genTestUserSig } from './debug/GenerateTestUserSig.js'

export default {
  onLaunch() {
    uni.setStorageSync('islogin', false);
    // 重点注意： 为了 uni-app 更好地接入使用 tim，快速定位和解决问题，请勿修改 uni.$TUIKit 命名。
    // 如果您已经接入 tim ，请将 uni.tim 修改为 uni.$TUIKit。
    uni.$TUIKit = TIM.create({
      SDKAppID: genTestUserSig('').sdkAppID
    });
    uni.$TUIKit.registerPlugin({
      'cos-wx-sdk': COS
    });
    uni.$TUIKitTIM = TIM;
    uni.$TUIKitEvent = TIM.EVENT;
    uni.$TUIKitVersion = TIM.VERSION;
    uni.$TUIKitTypes = TIM.TYPES; // 监听系统级事件
    uni.$resetLoginData = this.resetLoginData()

    uni.$TUIKit.on(uni.$TUIKitEvent.SDK_NOT_READY, this.onSdkNotReady);
    uni.$TUIKit.on(uni.$TUIKitEvent.KICKED_OUT, this.onKickedOut);
    uni.$TUIKit.on(uni.$TUIKitEvent.ERROR, this.onTIMError);
    uni.$TUIKit.on(uni.$TUIKitEvent.NET_STATE_CHANGE, this.onNetStateChange);
    uni.$TUIKit.on(uni.$TUIKitEvent.SDK_RELOAD, this.onSDKReload);
    uni.$TUIKit.on(uni.$TUIKitEvent.SDK_READY, this.onSDKReady);
  },
  globalData: {
    // userInfo: userID userSig token phone
    userInfo: null,
    // 个人信息
    userProfile: null,
    headerHeight: 0,
    statusBarHeight: 0,
  },
  methods: {
    // TODO:
    resetLoginData() {
      this.globalData.expiresIn = '';
      this.globalData.sessionID = '';
      this.globalData.userInfo = {
        userID: '',
        userSig: '',
        token: '',
        phone: ''
      };
      this.globalData.userProfile = null;
      logger.log(`| app |  resetLoginData | globalData: ${this.globalData}`);
    },
    onTIMError() {},
    onNetStateChange() {},
    onSDKReload() {},
    onSDKReady() {},
    onSdkNotReady() {},
    onKickedOut() {
      uni.showToast({
        title: '您被踢下线',
        icon: 'error'
      });
      uni.navigateTo({
        url: './pages/TUI-Login/login'
      });
    },

  }
};
</script>
<style>
@import "./app.css";
</style>
