<script>
import TIM from 'tim-wx-sdk';
import COS from 'cos-wx-sdk-v5';
import logger from './utils/logger'; // app.js
import { genTestUserSig } from './debug/GenerateTestUserSig.js';
// 首先需要通过 uni.requireNativePlugin("ModuleName") 获取 module
// #ifdef APP-PLUS
const TUICalling = uni.requireNativePlugin('TUICallingUniPlugin-TUICallingModule');
logger.log(`| app |  TUICallingUniPlugin-TUICallingModule | TUICalling: ${TUICalling}`);
// #endif
export default {
	onLaunch() {
		uni.setStorageSync('islogin', false);
		const SDKAppID = genTestUserSig('').sdkAppID;
		uni.setStorageSync(`TIM_${SDKAppID}_isTUIKit`, true);
		// 重点注意： 为了 uni-app 更好地接入使用 tim，快速定位和解决问题，请勿修改 uni.$TUIKit 命名。
		// 如果您已经接入 tim ，请将 uni.tim 修改为 uni.$TUIKit。
		uni.$TUIKit = TIM.create({
			SDKAppID: SDKAppID
		});
		uni.$TUIKit.registerPlugin({
			'cos-wx-sdk': COS
		});
		// 将原生插件挂载在 uni 上
		// #ifdef APP-PLUS
		uni.$TUICalling = TUICalling;
		// #endif
		// 如果您已创建了 tim，请将 tim 实例挂载在 wx 上，且不可以修改 wx.$TIM（修改变量可能导致 TUICalling 组件无法正常使用）, 完成 TUICalling 初始化，
		// 如果您没有创建，可以不传
		// #ifdef MP-WEIXIN
		wx.$TIM = uni.$TUIKit;
		// #endif
		uni.$TUIKitTIM = TIM;
		uni.$TUIKitEvent = TIM.EVENT;
		uni.$TUIKitVersion = TIM.VERSION;
		uni.$TUIKitTypes = TIM.TYPES; // 监听系统级事件
		uni.$resetLoginData = this.resetLoginData();

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
		isTUIKit: true,
		headerHeight: 0,
		statusBarHeight: 0,
		SDKAppID: genTestUserSig('').sdkAppID
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
		}
	}
};
</script>
<style>
@import './app.css';
</style>
