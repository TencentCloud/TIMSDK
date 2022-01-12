<template>
	<view>
		<view class="container">
			<view class="item">
				<view class="avatar" @tap.stop="changeAvatar">
					<text class="aside-left">头像</text>
					<image
						class="image_radius"
						:src="userInfo.avatar || 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/avatar_21.png'"
					></image>
					<image class="listimage" src="/static/static/assets/detail.svg"></image>
				</view>
			</view>
			<view class="item">
				<view class="nickname" @tap="handleEditToggle">
					<text class="aside-left">昵称</text>
					<text class="aside-right">{{ userInfo.nick ? userInfo.nick : '提莫' }}</text>
					<image class="listimage" src="/static/static/assets/detail.svg"></image>
				</view>
			</view>
		</view>
		<view class="popup-mask" v-if="popupToggle" @tap.stop="handleEditToggle">
			<view class="popup-main" @tap.stop="handleCatchTap">
				<view class="popup-main-header">
					<label class="popup-main-header-title">修改昵称</label>
					<button class="button" @tap.stop="handleEditSubmit" :disabled="!infoNick">确认</button>
				</view>
				<input class="popup-main-input" type="text" :value="infoNick" @input="bindEditInput" />
				<label class="text">仅限中文、字母、数字和下划线，2-20个字</label>
			</view>
		</view>
		<view class="popup-mask-avatar" v-if="popupToggleAvatar" @tap.stop="handleEditToggleAvatar">
			<view class="popup-main-avatar" @tap.stop="handleCatchTap">
				<view class="pop-main-header-avatar" :data-item="item">
					<label class="popup-main-header-title-avatar">设置头像</label>
					<label class="button-avatar" @tap.stop="handleEditSubmitAvatar">确认</label>
					<view class="image-list">
						<image
							v-for="(item, index) in avatarList"
							:key="index"
							:class="'image-avatar ' + (item.URL === avatar && 'image-avatar-active')"
							:src="item.URL"
							:data-value="item"
							@tap="click"
						></image>
					</view>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
// miniprogram/pages/TUI-personal/personal.js'
const app = getApp();

export default {
	data() {
		return {
			userInfo: {
				nick: '',
				avatarUrl: '',
				avatar: ''
			},
			config: {
				avatar: '',
				nick: '',
				phone: '',
				token: '',
				userId: '',
				userSig: ''
			},
			infoNick: '',
			avatar: '',
			avatarList: [
				{
					avatarname: '头像1',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_01.png'
				},
				{
					avatarname: '头像2',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_02.png'
				},
				{
					avatarname: '头像3',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_03.png'
				},
				{
					avatarname: '头像4',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_04.png'
				},
				{
					avatarname: '头像5',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_05.png'
				},
				{
					avatarname: '头像6',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_06.png'
				},
				{
					avatarname: '头像7',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_07.png'
				},
				{
					avatarname: '头像8',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_08.png'
				},
				{
					avatarname: '头像9',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_09.png'
				},
				{
					avatarname: '头像10',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_10.png'
				},
				{
					avatarname: '头像11',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_11.png'
				},
				{
					avatarname: '头像12',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_12.png'
				},
				{
					avatarname: '头像13',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_13.png'
				},
				{
					avatarname: '头像14',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_14.png'
				},
				{
					avatarname: '头像15',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_15.png'
				},
				{
					avatarname: '头像16',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_16.png'
				},
				{
					avatarname: '头像17',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_17.png'
				},
				{
					avatarname: '头像18',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_18.png'
				},
				{
					avatarname: '头像19',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_19.png'
				},
				{
					avatarname: '头像20',
					URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_20.png'
				}
			],
			popupToggle: false,
			popupToggleAvatar: false,
			imageSelected: false,
			imageTitle: '点击操作'
		};
	},

	components: {},
	props: {},

	/**
	 * 生命周期函数--监听页面加载
	 */
	onLoad() {
		this.setData({
			userInfo: app.globalData.userProfile
		});
		uni.setNavigationBarTitle({
			title: '个人中心'
		});
	},

	methods: {
		bindEditInput(e) {
			const val = e.detail.value;
			this.setData({
				infoNick: val ? val : ''
			});
		},

		// 修改昵称确认
		handleEditSubmit() {
			if (this.infoNick === app.globalData.userProfile.nick) {
				return;
			}
			this.setData({
				popupToggle: false
			});
			const promise = uni.$TUIKit.updateMyProfile({
				nick: this.infoNick
			});
			promise
				.then(imResponse => {
					this.setData({
						userInfo: imResponse.data,
						popupToggle: false
					});
				})
				.catch(imError => {
					this.setData({
						popupToggle: false
					});
					console.warn('updateMyProfile error:', imError); // 更新资料失败的相关信息
				});
		},

		handleEditToggle() {
			this.setData({
				popupToggle: !this.popupToggle,
				infoNick: this.userInfo.nick
			});
			console.log(this.infoNick, '999');
		},

		// 修改昵称 禁止冒泡
		handleCatchTap() {
			return;
		},

		// 修改头像
		changeAvatar() {
			this.setData({
				popupToggleAvatar: true
			});
		},

		click(e) {
			console.log(e.currentTarget.dataset.value);
			this.setData({
				avatar: e.currentTarget.dataset.value.URL
			});
		},

		// 修改头像确认
		handleEditSubmitAvatar() {
			uni.$TUIKit
				.updateMyProfile({
					avatar: this.avatar
				})
				.then(imResponse => {
					this.setData({
						userInfo: imResponse.data,
						popupToggleAvatar: !this.popupToggleAvatar
					});
				})
				.catch(() => {
					this.setData({
						popupToggleAvatar: !this.popupToggleAvatar
					});
				});
		},

		handleEditToggleAvatar() {
			this.setData({
				popupToggleAvatar: !this.popupToggleAvatar,
				avatar: this.avatar
			});
		}
	}
};
</script>
<style>
@import './personal.css';
</style>
