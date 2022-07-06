<template>
	<view class="container">
		<image class="background-image" src="@/pages/TUIKit/assets/images/background.png"></image>
		<view class="counter-warp">
			<view class="header-content">
				<image src="@/pages/TUIKit/assets/images/im.png" class="icon"></image>
				<view class="text">
					<view class="text-header">登录 · 即时通信</view>
					<view class="text-content">体验群组聊天，视频对话等IM功能</view>
				</view>
			</view>
			<view class="box">
				<view class="list">
					<view class="list-item">
						<label class="list-item-label">用户ID</label>
						<input class="input" type="text" v-model="userID" placeholder="请输入用户名" @input="bindUserIDInput"
							placeholder-style="color:#BBBBBB;" />
					</view>
				</view>
				<view class="private-protocol-box">
					<view class="private-protocol-switch" @tap="onAgreePrivateProtocol">
						<image v-if="privateAgree" src="@/pages/TUIKit/assets/icon/selected.svg" lazy-load="true">
						</image>
						<!-- <view class="tui-normal-unchoose" v-else></view> -->
						<image v-else src="/pages/TUIKit/assets/icon/select.svg"></image>
					</view>
					<view class="text-box">
						<text>我已阅读并同意</text>
						<text class="link" @tap="linkToPrivacyTreaty">《隐私条例》</text>
						<text>和</text>
						<text class="link" @tap="linkToUserAgreement">《用户协议》</text>
					</view>
				</view>
				<view class="login"><button class="loginBtn" :disabled="!privateAgree" @tap="handleLogin">
						登录
					</button></view>
			</view>
		</view>
	</view>
</template>

<script lang="ts">
	// import { setTokenStorage } from '../../utils/token';
	import {
		genTestUserSig
	} from "../../../../debug/index.js";
	import {
		defineComponent,
		ref,
		toRefs,
		reactive
	} from "vue";
	import {
		onLoad
	} from "@dcloudio/uni-app";
	import store from "../../TUICore/store";

	export default defineComponent({
		setup(props: any) {
			const data = reactive({
				userID: "",
				hidden: false,
				btnValue: "获取验证码",
				btnDisabled: false,
				privateAgree: false,
				phone: "",
				code: "",
				sessionID: "",
				second: 60,
				path: "",
				lastTime: 0,
				countryIndicatorStatus: false,
				country: "86",
				indicatorValue: 46,
				// headerHeight: app.globalData.headerHeight,
				// statusBarHeight: app.globalData.statusBarHeight,
				showlogin: false,
			});
			// 获取页面参数
			onLoad((options) => {
				data.path = options && options.path;
				data.type = (options && options.type) || uni.$TUIKit.TIM.TYPES.CONV_C2C;
			});
			const loginWithToken = () => {
				uni.switchTab({
					url: "/pages/TUIKit/TUIPages/TUIConversation/index"
				});
			};
			// 输入userID
			const bindUserIDInput = (e) => {
				const val = e.detail.value;
				data.userID = val;
			};
			const onAgreePrivateProtocol = () => {
				data.privateAgree = !data.privateAgree;
			};
			const linkToPrivacyTreaty = () => {
				const url =
					"https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html";
				uni.navigateTo({
					url: `../TUIUserCenter/webview/webview?url=${url}&nav=Privacy-Protection`,
				});
			};
			const linkToUserAgreement = () => {
				const url =
					"https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html";
				uni.navigateTo({
					url: `../TUIUserCenter/webview/webview?url=${url}&nav=User-Agreement`,
				});
			};
			const handleLogin = () => {
				const userID = data.userID;
				const {
					userSig,
					sdkAppID: SDKAppID
				} = genTestUserSig(userID);
				// 集成本地项目可以去掉
				
// #ifdef  APP-PLUS
				uni.$aegis.reportEvent({
					name: 'platform',
					ext1: 'platform-APP',
					ext2: 'uniTuikitExternalVue3',
					ext3: `${SDKAppID}`,
				})
				// #endif
				
				// #ifdef MP-WEIXIN  
				uni.$aegis.reportEvent({
					name: 'platform',
					ext1: 'platform-MP-WEIXIN',
					ext2: 'uniTuikitExternalVue3',
					ext3: `${SDKAppID}`,
				})
				// #endif
				
				// #ifdef H5
				uni.$aegis.reportEvent({
					name: 'platform',
					ext1: 'platform-H5',
					ext2: 'uniTuikitExternalVue3',
					ext3: `${SDKAppID}`,
				})
       // #endif
				uni.setStorageSync("userInfo", {
					userSig,
					userID
				});
				uni.showLoading(); //  SDK 是否 Ready
				uni.$TUIKit.tim.login({
						userID: userID,
						userSig: userSig,
					})
					.then((res: any) => {
						uni.$aegis.reportEvent({
							name: 'login',
							ext1: 'login-success',
							ext2: 'uniTuikitExternalVue3',
							ext3: `${SDKAppID}`,
						})

						if (res.code === 0) {
							uni.showToast({
								title: "login success",
								icon: "loading",
							});
							uni.hideLoading();
							uni.setStorageSync("isLogin", true);
							store.commit("timStore/setLoginStatus", true);
							store.commit("timStore/setUserInfo", {
								userID
							});
							uni.switchTab({
								url: "/pages/TUIKit/TUIPages/TUIConversation/index",
							});
						} else {
							uni.setStorageSync("isLogin", false);
						}
					})
					.catch((error: any) => {
						uni.$aegis.reportEvent({
							name: 'login',
							ext1: `login-failed#error:${error}`,
							ext2: 'uniTuikitExternalVue3',
							ext3: `${SDKAppID}`,
						})
						uni.setStorageSync("isLogin", false);
						console.warn("login exception = ", error);
					});
				// 登录原生插件
				// #ifdef APP-PLUS
				if (typeof uni.$TUICalling == "undefined") {
					// uni.showToast({
					// 	title: '如果需要音视频功能，请集成插件使用真机运行并且自定义基座调试哦～',
					// 	icon: 'none',
					// 	duration: 3000
					// });
					console.error(
						"请使用真机运行并且自定义基座调试，否则影响音视频功能～ 插件地址：https://ext.dcloud.net.cn/plugin?id=7097 , 调试地址：https://nativesupport.dcloud.net.cn/NativePlugin/use/use"
					);
				} else {
					uni.$TUICalling.login({
							sdkAppID: SDKAppID,
							userID: userID,
							userSig: userSig,
						},
						(res) => {
							console.log(JSON.stringify(res.msg));
							// 开启悬浮窗
							uni.$TUICalling.enableFloatWindow(true);
							uni.showToast({
								title: "login",
								icon: "none",
							});
						}
					);
				}
				// #endif
			};

			return {
				...toRefs(data),
				loginWithToken,
				bindUserIDInput,
				onAgreePrivateProtocol,
				linkToPrivacyTreaty,
				linkToUserAgreement,
				handleLogin,
			};
		},
	});
</script>
<style scoped>
	@import "./login.css";
</style>
