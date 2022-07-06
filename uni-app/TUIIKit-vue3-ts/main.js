  import App from './App'
	import { SDKAPPID } from './debug'
	import { TUICore } from './pages/TUIKit'
	import store from './pages/TUIKit/TUICore/store';
	import Vuex from "vuex";
	// aegis 是数据统计相关，在自己的项目中集成可以去掉
	// #ifdef APP-PLUS
	import Aegis from 'aegis-weex-sdk';
	// #endif
	
	// #ifdef MP-WEIXIN
	import Aegis from 'aegis-mp-sdk';
	// #endif
	
	// #ifdef H5
	import Aegis from 'aegis-web-sdk';
	// #endif
	
	// aegis 是数据统计相关，在自己的项目中集成可以去掉
	const aegis = new Aegis({
		id: 'iHWefAYqmGKHeAqvDB', // 项目key
		reportApiSpeed: true, // 接口测速
	});
	uni.$aegis = aegis;
	// 首先需要通过 uni.requireNativePlugin("ModuleName") 获取 module
	// #ifdef APP-PLUS
	const TUICalling = uni.requireNativePlugin('TUICallingUniPlugin-TUICallingModule');
	console.log(`| app |  TUICallingUniPlugin-TUICallingModule | TUICalling: ${TUICalling}`);
	if (typeof(TUICalling) == 'undefined') {
		console.error(
			'如果需要音视频功能，请集成原生插件，使用真机运行并且自定义基座调试哦～ 插件地址：https://ext.dcloud.net.cn/plugin?id=7097 , 调试地址：https://nativesupport.dcloud.net.cn/NativePlugin/use/use'
			);
	}
	// #endif
	// 将原生插件挂载在 uni 上
	// #ifdef APP-PLUS
	uni.$TUICalling = TUICalling;
	// #endif

	// #ifdef VUE3
	import {
		createSSRApp
	} from 'vue'
	
	uni.$TUIKit = TUICore.init({
			SDKAppID: SDKAPPID,
	})

	export function createApp() {
		const app = createSSRApp(App)
		app.use(store)
		return {
			app,
		}
	}
	// #endif
