<template>
	<view class="TUI-Create-conversation-container">
		<view class="tui-navigatorbar">
			<image class="tui-navigatorbar-back" @tap="goBack" src="/static/static/assets/ic_back_white.svg"></image>
			<view class="conversation-title">加入群聊</view>
		</view>
		<view class="tui-search-area">
			<view class="tui-search-bar">
				<image class="tui-searchcion" src="/static/static/assets/serach-icon.svg"></image>
				<input
					class="tui-search-bar-input"
					:value="groupID"
					placeholder="请输入群ID"
					@input="groupIDInput"
					@confirm="searchGroupByID"
					@blur="searchGroupByID"
				/>
			</view>
		</view>
		<view class="tui-person-to-invite" v-if="searchGroup.groupID">
			<image
				@tap="handleChoose"
				class="tui-normal-choose"
				:src="isChoose ? '/static/static/assets/single-choice-hover.svg' : '/static/static/assets/single-choice-normal.svg'"
			></image>
			<view class="tui-person-profile">
				<image class="tui-person-profile-avatar" :src="groupAvatar || '/static/static/assets/gruopavatar.svg'"></image>
				<view>
					<view class="tui-person-profile-nick">{{ searchGroup.name }}</view>
					<view class="tui-person-profile-userID">群ID：{{ searchGroup.groupID }}</view>
				</view>
			</view>
		</view>
		<view class="tui-confirm-btn" @tap="bindConfirmJoin">确认加入</view>
	</view>
</template>

<script>
import logger from '../../../utils/logger';

export default {
	data() {
		return {
			groupID: '',
			searchGroup: {
				groupID: '',
				name: ''
			},
			isChoose: false,
			groupAvatar: ''
		};
	},

	components: {},
	props: {},
	methods: {
		goBack() {
			uni.navigateBack({
				delta: 1
			});
		},

		groupIDInput(e) {
			this.setData({
				groupID: e.detail.value
			});
		},

		searchGroupByID() {
			uni.$TUIKit
				.searchGroupByID(this.groupID)
				.then(imResponse => {
					if (imResponse.data.group.groupID !== '') {
						this.setData({
							searchGroup: imResponse.data.group,
							groupAvatar: imResponse.data.group.avatar
						});
					}
				})
				.catch(imError => {
					uni.hideLoading();

					if (imError.code === 10007) {
						uni.showToast({
							title: '讨论组类型群不允许申请加群',
							icon: 'none'
						});
					} else {
						uni.showToast({
							title: '未找到该群组',
							icon: 'none'
						});
					}
				});
		},

		handleChoose() {
			this.isChoose = !this.isChoose;
			this.setData({
				searchGroup: this.searchGroup
			});
		},

		bindConfirmJoin() {
			logger.log(`TUI-Group | join-group | bindConfirmJoin | groupID: ${this.groupID}`);
			uni.$TUIKit
				.joinGroup({
					groupID: this.groupID,
					type: this.searchGroup.type
				})
				.then(imResponse => {
					switch (imResponse.data.status) {
						case uni.$TUIKitTIM.TYPES.JOIN_STATUS_WAIT_APPROVAL:
							// 等待管理员同意
							break;

						case uni.$TUIKitTIM.TYPES.JOIN_STATUS_SUCCESS:
							// 加群成功
							console.log(imResponse.data.group); // 加入的群组资料

							break;

						case uni.$TUIKitTIM.TYPES.JOIN_STATUS_ALREADY_IN_GROUP:
							// 已经在群中
							break;

						default:
							break;
					}
				})
				.catch(imError => {
					console.warn('joinGroup error:', imError); // 申请加群失败的相关信息
				});

			if (this.isChoose) {
				uni.navigateTo({
					url: `../../TUI-Chat/chat?conversationID=GROUP${this.searchGroup.groupID}`
				});
			} else {
				uni.showToast({
					title: '请选择相关群聊',
					icon: 'error'
				});
			}
		}
	}
};
</script>
<style>
@import './join.css';
</style>
