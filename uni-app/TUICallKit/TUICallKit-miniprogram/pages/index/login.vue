<template>
	<view class="container">
		<image class="background-image" src="../../static/background.svg"></image>
		<view class="counter-warp">
			<view class="header-content">
				<image src="../../static/calling-logo.png" class="icon-box" />
				<view class="text-header">腾讯云音视频插件</view>
			</view>
			<view class="box">
				<view class="list-item">
					<label class="list-item-label">用户ID</label>
					<input class="input-box" type="text" v-model="userID" placeholder="请输入用户ID" placeholder-style="color:#BBBBBB;" />
				</view>
				<view class="login"><button class="loginBtn" @click="loginHandler">登录</button></view>
			</view>
		</view>
	</view>
</template>
<script>
import { genTestUserSig } from '../../debug/GenerateTestUserSig.js';
export default {
	data() {
		return {
			userID: ''
		};
	},
	onshow() {},
	methods: {
		loginHandler() {
			const userID = this.userID;
			const userSig = genTestUserSig(userID).userSig;
			uni.$TUIKit.login({
				userID: userID,
				userSig: userSig
			});
			getApp().globalData.userID = userID;
			getApp().globalData.userSig = userSig;
			uni.navigateTo({
				url: './index'
			});
		}
	}
};
</script>
<style scoped>
.container {
	width: 100vw;
	height: 100vh;
	background-color: #f4f5f9;
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
	color: #ffffff;
	margin: 40px auto;
}

.text-content {
	height: 36rpx;
	font-size: 24rpx;
	line-height: 36rpx;
	color: #ffffff;
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
	color: #ffffff;
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
	color: #ffffff;
	letter-spacing: 0;
}

.list-item {
	display: flex;
	flex-direction: column;
	font-family: PingFangSC-Medium;
	font-size: 14px;
	color: #333333;
	border-bottom: 1px solid #eef0f3;
}

.input-container {
	width: 90%;
	margin: 50px auto 0;
	display: flex;
	flex-direction: column;
	font-family: PingFangSC-Medium;
	font-size: 14px;
	color: #333333;
	border-bottom: 1px solid #eef0f3;
}

/* 	.input-box {
		height: 20px;
		padding: 5px;
		width: 100%;
		border: 1px solid #999999;;	
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
