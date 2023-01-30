<template>
	<view class="container">
		<image class="background-image" src="/static/static/assets/background.svg"></image>
		<view class="counter-warp">
			<view class="header-content">
				<image src="/static/static/images/im.png" class="icon"></image>
				<view class="text">
					<view class="text-header">登录 · 即时通信</view>
					<view class="text-content">体验群组聊天，视频对话等IM功能</view>
				</view>
			</view>
			<view class="box">
				<view class="list">
					<view class="list-item">
						<label class="list-item-label">用户ID</label>
						<input class="input" type="text" placeholder="请输入用户名" @input="bindUserIDInput" placeholder-style="color:#BBBBBB;" />
					</view>
				</view>
				<view class="private-protocol-box">
					<view class="private-protocol-switch" @tap="onAgreePrivateProtocol">
						<image v-if="privateAgree" src="/static/static/images/selected.png" lazy-load="true"></image>
						<image v-else src="/static/static/images/select.png" lazy-load="true"></image>
					</view>
					<view class="text-box">
						<text>我已阅读并同意</text>
						<text class="link" @tap="linkToPrivacyTreaty">《隐私条例》</text>
						<text>和</text>
						<text class="link" @tap="linkToUserAgreement">《用户协议》</text>
					</view>
				</view>
				<view class="login"><button class="loginBtn" :disabled="!privateAgree" @tap="login">登录</button></view>
			</view>
		</view>
	</view>
</template>

<script>
import { setTokenStorage } from '../../utils/token';
import logger from '../../utils/logger';
import { genTestUserSig } from '../../debug/GenerateTestUserSig.js';
const { getTokenStorage } = require('../../utils/token.js');
const app = getApp();

export default {
	data() {
		return {
			userID: '',
			hidden: false,
			btnValue: '获取验证码',
			btnDisabled: false,
			privateAgree: false,
			phone: '',
			code: '',
			sessionID: '',
			second: 60,
			path: '',
			lastTime: 0,
			countryIndicatorStatus: false,
			country: '86',
			indicatorValue: 46,
			headerHeight: app.globalData.headerHeight,
			statusBarHeight: app.globalData.statusBarHeight,
			showlogin: false
		};
	},

	components: {},
	props: {},

	onLoad(option) {
		const that = this;
		this.setData({
			path: option.path
		});
		uni.getStorage({
			// 获取本地缓存
			key: 'sessionID',
			success(res) {
				that.setData({
					sessionID: res.data
				});
			}
		});
		uni.setStorage({
			key: 'path',
			data: option.path
		});
	},

	onShow() {},

	methods: {
		loginWithToken() {
			uni.switchTab({
				url: '../TUI-Index/index'
			});
		},

		onBack() {
			uni.navigateTo({
				url: '../TUI-Index/TUI-Index'
			});
		},

		// 输入userID
		bindUserIDInput(e) {
			const val = e.detail.value;
			this.setData({
				userID: val
			});
		},

		onAgreePrivateProtocol() {
			this.setData({
				privateAgree: !this.privateAgree
			});
		},

		linkToPrivacyTreaty() {
			const url = 'https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html';
			uni.navigateTo({
				url: `../TUI-User-Center/webview/webview?url=${url}&nav=Privacy-Protection`
			});
		},

		linkToUserAgreement() {
			const url = 'https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html';
			uni.navigateTo({
				url: `../TUI-User-Center/webview/webview?url=${url}&nav=User-Agreement`
			});
		},

		login() {
			const userID = this.userID;
			const userSig = genTestUserSig(userID).userSig;
			const SDKAppID = app.globalData.SDKAppID;
			logger.log(`TUI-login | login  | userSig:${userSig} userID:${userID}`);
			// #ifdef  APP-PLUS
			uni.$aegis.reportEvent({
			    name: 'platform',
			    ext1: 'platform-APP',
			    ext2: 'uniTuikitExternal',
			    ext3: `${SDKAppID}`,
			})
			// #endif
			// #ifdef MP-WEIXIN  
			uni.$aegis.reportEvent({
			    name: 'platform',
			    ext1: 'platform-MP-WEIXIN',
			    ext2: 'uniTuikitExternal',
			    ext3: `${SDKAppID}`,
			})
			// #endif
			// #ifdef H5
			uni.$aegis.reportEvent({
			    name: 'platform',
			    ext1: 'platform-H5',
			    ext2: 'uniTuikitExternal',
			    ext3: `${SDKAppID}`,
			})
			uni.showToast({
				title: 'TUIKit 暂不支持 H5 / web ，请使用者自己完成兼容哦～ ',
				icon: 'none',
				duration: 3000
			});
			// #endif
			app.globalData.userInfo = {
				userSig,
				userID
			};
			setTokenStorage({
				userInfo: app.globalData.userInfo
			});
			wx.setStorageSync(`TIM_${getApp().SDKAppID}_isTUIKit`, true);
			uni.$TUIKit.login({
				userID: userID,
				userSig: userSig
			}).then(() => {
				uni.$aegis.reportEvent({
				    name: 'login',
				    ext1: 'login-success',
				    ext2: 'uniTuikitExternal',
				    ext3: `${SDKAppID}`,
				})
			}).catch((error) => {
				uni.$aegis.reportEvent({
				    name: 'login',
				    ext1: `login-failed#error:${error}`,
				    ext2: 'uniTuikitExternal',
				    ext3: `${SDKAppID}`,
				})
			})
			
			// 登录原生插件
			// #ifdef APP-PLUS
			if(typeof(uni.$TUICallKit) == 'undefined') {
				uni.showToast({
					title: '如果需要音视频功能，请集成插件使用真机运行并且自定义基座调试哦～',
					icon: 'none',
					duration: 3000
				});
				logger.error('请使用真机运行并且自定义基座调试，否则影响音视频功能～ 插件地址：https://ext.dcloud.net.cn/plugin?id=9035 , 调试地址：https://nativesupport.dcloud.net.cn/NativePlugin/use/use');
			} else {
				uni.$TUICallKit.login(
					{
						SDKAppID: SDKAppID,
						userID: userID,
						userSig: userSig
					},
					res => {
						console.log(JSON.stringify(res.msg));
						uni.showToast({
							title: 'login',
							icon: 'none'
						});
					}
				);
			}
			
			// #endif
			if (this.path && this.path !== 'undefined') {
				uni.redirectTo({
					url: this.path
				});
			} else {
				uni.switchTab({
					url: '../TUI-Index/index'
				});
			}
		}
	}
};
</script>
<style scoped>
@import './login.css';
</style>
