<template>
	<view class="container">
		<tuicalling ref="TUICalling" id="TUICalling-component" :config="config"></tuicalling>
		<view class="input-container">
			<label class="list-item-label" style="margin-bottom: 10px;">呼叫用户ID:<span
					style="color:#C0C0C0;margin-left: 8px;">user1;user2(“;”为英文分号)</span></label>
			<input class="input-box" v-model="callUserID" maxlength="140" type="text" placeholder="输入userID"
				placeholder-style="color:#BBBBBB;">
		</view>
		<view class="guide-box">
			<view class="single-box" :id="index" @click="callingHandle(item.type)" v-for="(item, index) in entryInfos"
				:key="index">
				<image class="icon" mode="aspectFit" :src="item.icon" role="img"></image>

				<view class="single-content">
					<view class="label">{{ item.title }}</view>
					<view class="desc">{{ item.desc }}</view>
				</view>
			</view>
		</view>
		<view class="login" style="width: 70%; margin: 15px auto 0;">
			<button class="loginBtn" @click="logoutHandler">登出</button>
		</view>
	</view>
</template>
<script>
	export default {
		data() {
			return {
				entryInfos: [{
						icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/audio-card.png',
						title: '语音通话',
						desc: '丢包率70%仍可正常语音通话',
						type: 1
					},
					{
						icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/video-card.png',
						title: '视频通话',
						desc: '丢包率50%仍可正常视频通话',
						type: 2
					}
				],
				callUserID: '',
				config: {
					sdkAppID: '',
					userID: '',
					userSig: '',
					type: 1,
					tim: null,
				},
			}
		},
		onLoad() {
			this.config = {
				sdkAppID: getApp().globalData.SDKAppID,
				userID: getApp().globalData.userID,
				userSig: getApp().globalData.userSig
			}
			console.log(this.$refs.TUICalling, 'TUICalling | ok')
			this.$nextTick(() => {
				this.$refs.TUICalling.init()
			})

		},

		onUnload() {
			this.$refs.TUICalling.destroyed();
		},
		methods: {
			callingHandle(type) {
				const userIDs = this.callUserID.split(";");
				if (this.callUserID === '') {
					uni.showToast({
						title: '请在上方输入userID',
						icon: "none"
					})
					return
				}

				uni.$TUIKit.getUserProfile({
						userIDList: userIDs
					})
					.then((res) => {
						if (res.data.length < userIDs.length) {
							uni.showToast({
								title: '该用户不存在，请重新输入userID',
								icon: "none"
							})
							return
						}
						if (res.data.length == 1) {
							this.$refs.TUICalling.call({
								userID: userIDs[0],
								type
							})
						}
						if (res.data.length > 1) {
							this.$refs.TUICalling.groupCall({
								userIDList: userIDs,
								type: type
							})
						}
					})
					.catch(() => {
						uni.showToast({
							title: '失败',
							icon: "none"
						})
					})
			},
			logoutHandler() {
				this.callUserID = '';
				uni.$TUIKit.logout()
				uni.navigateBack({
					delta: 1
				})
			},
		}
	}
</script>
<style scoped>
	.container {
		width: 100vw;
		height: 100vh;
		background-color: #F4F5F9;
		position: fixed;
		top: 0;
		right: 0;
		left: 0;
		bottom: 0;
	}

	.counter-warp {
		position: absolute;
		top: 0;
		right: 0;
		left: 0;
		width: 100%;
		height: 100%;
		display: flex;
		flex-direction: column;
		align-items: center;
	}

	.background-image {
		width: 100%;
	}

	.header-content {
		display: flex;
		width: 100vw;
		padding: 50px 20px 10px;
		box-sizing: border-box;
		top: 100rpx;
		align-items: center;
	}

	.icon-box {
		width: 56px;
		height: 56px;
	}

	.text-header {
		height: 72rpx;
		font-size: 48rpx;
		line-height: 72rpx;
		color: #FFFFFF;
		margin: 40px auto;
	}

	.text-content {
		height: 36rpx;
		font-size: 24rpx;
		line-height: 36rpx;
		color: #FFFFFF;
	}

	.box {
		width: 80%;
		height: 50vh;
		position: relative;
		background: #ffffff;
		border-radius: 4px;
		border-radius: 4px;
		display: flex;
		flex-direction: column;
		justify-content: left;
		padding: 30px 20px;
	}

	.input-box {
		flex: 1;
		display: flex;
		font-family: PingFangSC-Regular;
		font-size: 14px;
		color: rgba(0, 0, 0, 0.8);
		letter-spacing: 0;
	}

	.login {
		display: flex;
		box-sizing: border-box;
		margin-top: 15px;
		width: 100%;
	}

	.login button {
		background: rgba(0, 110, 255, 1);
		border-radius: 30px;
		font-size: 16px;
		color: #FFFFFF;
		letter-spacing: 0;
		/* text-align: center; */
		font-weight: 500;
	}

	.loginBtn {
		margin-top: 64px;
		background-color: white;
		border-radius: 24px;
		border-radius: 24px;
		/* display: flex;
	  justify-content: center; */
		width: 100% !important;
		font-family: PingFangSC-Regular;
		font-size: 16px;
		color: #FFFFFF;
		letter-spacing: 0;
	}

	.list-item {
		display: flex;
		flex-direction: column;
		font-family: PingFangSC-Medium;
		font-size: 14px;
		color: #333333;
		border-bottom: 1px solid #EEF0F3;
	}

	.input-container {
		width: 90%;
		margin: 50px auto 0;
		display: flex;
		flex-direction: column;
		font-family: PingFangSC-Medium;
		font-size: 14px;
		color: #333333;
		border-bottom: 1px solid #EEF0F3;
	}

	/* 	.input-box {
		height: 20px;
		padding: 5px;
		width: 100%;
		border: 1px solid #999999;
	} */
	.list-item .list-item-label {
		font-weight: 500;
		padding: 10px 0;
	}

	.guide-box {
		width: 100vw;
		box-sizing: border-box;
		padding: 16px;
		display: flex;
		flex-direction: column;
	}

	.single-box {
		flex: 1;
		border-radius: 10px;
		background-color: #ffffff;
		margin-bottom: 16px;
		display: flex;
		align-items: center;
	}

	.icon {
		display: block;
		width: 180px;
		height: 144px;
	}

	.single-content {
		padding: 36px 30px 36px 20px;
		color: #333333;
	}

	.label {
		display: block;
		font-size: 18px;
		color: #333333;
		letter-spacing: 0;
		font-weight: 500;
	}

	.desc {
		display: block;
		font-size: 14px;
		color: #333333;
		letter-spacing: 0;
		font-weight: 500;
	}

	.logo-box {
		position: absolute;
		width: 100vw;
		bottom: 36rpx;
		text-align: center;
	}
</style>
