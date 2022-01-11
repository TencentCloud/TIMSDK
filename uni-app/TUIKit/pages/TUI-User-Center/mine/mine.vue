<template>
	<view>
		<view class="contain">
			<!-- 第一部分 -->
			<view class="view">
				<view class="view-image-text" @tap="personal">
					<image
						class="image-radius"
						:src="config.avatar ? config.avatar : 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/avatar_21.png'"
					></image>
					<view class="text-container">
						<view class="name">
							{{ config.nick ? config.nick : '提莫' }}
							<text class="hasname" v-if="hasname">(暂无昵称)</text>
						</view>
						<view class="ID">userID:{{ config.userID }}</view>
					</view>
				</view>
			</view>
		</view>
		<view class="box">
			<block v-for="(item, index) in userListInfo" :key="index">
				<view class="list" :data-item="item" @tap="handleRouter">
					<image class="list-URL" :src="item.iconUrl"></image>
					<view class="list-name">
						<view>{{ item.name }}</view>
					</view>
					<image class="listimage" src="/static/static/assets/detail.svg"></image>
				</view>
			</block>
		</view>
		<view class="quit-main"><view class="quit-main-text" @tap="quit">退出登录</view></view>
		<view class="pop-mask" v-if="popupToggle">
			<view class="pop-box">
				<text class="text-title">《IM-免责声明》</text>
				<text class="pop-box-text">
					IM（“本产品”）是由腾讯云提供的一款测试产品，腾讯云享有本产品的著作权和所有权。本产品仅用于功能体验，不得用于任何商业用途。为配合相关部门监管要求，本产品音视频互动全程均有录音录像存档，严禁在使用中有任何色情、辱骂、暴恐、涉政等违法内容传播。
				</text>
				<view class="agree"><button class="pop-agree" @tap="Agree">我已知晓</button></view>
			</view>
		</view>
	</view>
</template>

<script>
import logger from '../../../utils/logger';
const app = getApp();

export default {
	data() {
		return {
			// 页面初始信息
			userListInfo: [
				{
					extra: 1,
					name: '隐私条例',
					path: 'https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html',
					nav: 'Privacy-Protection',
					iconUrl: '/static/static/assets/Privacyregulations.svg'
				},
				{
					extra: 1,
					name: '用户协议',
					path: 'https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html',
					nav: 'User-Agreement',
					iconUrl: '/static/static/assets/Useragreement.svg'
				},
				{
					extra: 3,
					name: '免责声明',
					iconUrl: '/static/static/assets/Disclaimers.svg'
				},
				{
					extra: 2,
					name: '关于',
					url: '../about/about',
					iconUrl: '/static/static/assets/about.svg'
				},
				{
					extra: 1,
					name: '联系我们',
					path: 'https://cloud.tencent.com/document/product/269/20043',
					iconUrl: '/static/static/assets/contact.svg'
				}
			],
			config: {
				nick: '',
				userID: ''
			},
			hasname: true,
			popupToggle: false
		};
	},

	components: {},
	props: {},

	onShow() {
		uni.$TUIKit
			.getMyProfile()
			.then(imResponse => {
				this.setData({
					config: imResponse.data
				});
				app.globalData.userProfile = imResponse.data;

				if (imResponse.data.nick) {
					this.setData({
						hasname: false
					});
				}
			})
			.catch(imError => {
				console.warn('getMyProfile error:', imError); // 获取个人资料失败的相关信息
			});
	},

	methods: {
		onload() {},

		personal() {
			// TUIKit xxxx | mine | personal | xxxx
			uni.navigateTo({
				url: '../personal/personal'
			});
		},

		quit() {
			// TUIKit xxxx | mine | quit | xxxx
			logger.log('| TUI-User-Center | mine  | quit-logout ');
			uni.$TUIKit.logout().then(() => {
				uni.clearStorage();
				uni.redirectTo({
					url: '../../TUI-Login/login',
					success: () => {
						uni.showToast({
							title: '退出成功',
							icon: 'none'
						});
					}
				});
			});
		},

		handleRouter(event) {
			const data = event.currentTarget.dataset.item;

			if (data.url) {
				uni.navigateTo({
					url: `${data.url}`
				});
			} else if (data.name === '免责声明') {
				this.setData({
					popupToggle: true
				});
			} else {
				uni.navigateTo({
					url: `../webview/webview?url=${data.path}&nav=${data.nav}`
				});
			}
		},

		Agree() {
			this.setData({
				popupToggle: false
			});
		}
	}
};
</script>
<style>
@import './mine.css';
</style>
