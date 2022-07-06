<template>
	<view class="TUI-message-input-main" @longpress="handleLongPress" @touchmove="handleTouchMove"
		@touchend="handleTouchEnd">
		<text>{{ text }}</text>
		<view class="record-modal" v-if="popupToggle" @longpress="handleLongPress" @touchmove="handleTouchMove"
			@touchend="handleTouchEnd">
			<view class="wrapper">
				<view class="modal-loading"></view>
			</view>
			<view class="modal-title">{{ title }}</view>
		</view>
	</view>
</template>

<script lang="ts">
	import {
		defineComponent,
		watchEffect,
		reactive,
		toRefs,
		onMounted
	} from 'vue';
	// #ifndef H5
	const recorderManager = uni.getRecorderManager();
	// #endif
	const AudioMessage = defineComponent({
		props: {
			show: {
				type: Boolean,
				default: () => {
					return false;
				}
			},
		},
		setup(props: any, ctx: any) {
			const data = reactive({
				popupToggle: false,
				isRecording: false,
				canSend: true,
				text: '按住说话',
				recorderManager: null,
				title: ' ',
				recordTime: 0,
				recordTimer: null,
			});

			onMounted(() => {
				// 加载声音录制管理器
				recorderManager.onStop(res => {
					clearInterval(data.recordTimer);
					// 兼容 uniapp 打包app，duration 和 fileSize 需要用户自己补充
					// 文件大小 ＝ (音频码率) x 时间长度(单位:秒) / 8
					let msg = {
						duration: res.duration ? res.duration : data.recordTime * 1000,
						tempFilePath: res.tempFilePath,
						fileSize: res.fileSize ? res.fileSize : ((48 * data.recordTime) / 8) *
							1024
					};
					uni.hideLoading();
					// 兼容 uniapp 语音消息没有duration
					if (data.canSend) {
						if (msg.duration < 1000) {
							uni.showToast({
								title: '录音时间太短',
								icon: 'none'
							});
						} else {
							// res.tempFilePath 存储录音文件的临时路径
							uni.$TUIKit.TUIChatServer.sendAudioMessage(msg)
						}
					}
					data.popupToggle = false;
					data.isRecording = false;
					data.canSend = true;
					data.title = ' ';
					data.text = '按住说话'
				});
			});


			const handleLongPress = (e: any) => {
				data.popupToggle = true,
					recorderManager.start({
						duration: 60000,
						// 录音的时长，单位 ms，最大值 600000（10 分钟）
						sampleRate: 44100,
						// 采样率
						numberOfChannels: 1,
						// 录音通道数
						encodeBitRate: 192000,
						// 编码码率
						format: 'aac' // 音频格式，选择此格式创建的音频消息，可以在即时通信 IM 全平台（Android、iOS、微信小程序和Web）互通
					});
				data.startPoint = e.target,
					data.title = '正在录音',
					data.isRecording = true,
					data.recordTime = 0
				data.recordTimer = setInterval(() => {
					data.recordTime++;
				}, 1000);
			};

			// 录音时的手势上划移动距离对应文案变化
			const handleTouchMove = (e: any) => {
				if (data.isRecording) {
					if (e.currentTarget.offsetTop - e.changedTouches[e.changedTouches.length - 1].clientY >
						100) {
						data.text = '抬起停止';
						data.title = '松开手指，取消发送';
						data.canSend = false;
					} else if (e.currentTarget.offsetTop - e.changedTouches[e.changedTouches.length - 1]
						.clientY > 20) {
						data.text = '抬起停止';
						data.title = '上划可取消';
						data.canSend = true;
					} else {
						data.text = '抬起停止';
						data.title = '正在录音';
						data.canSend = true;
					}
				}
			};

			// 手指离开页面滑动
			const handleTouchEnd = () => {
				data.isRecording = false;
				data.popupToggle = false;
				data.text = '按住说话';
				uni.hideLoading();
				recorderManager.stop();
			};
			// 发送需要上传的消息：视频
			const sendUploadMessage = (e: any) => {
				Video.TUIServer.sendVideoMessage(e.target);
			};

			return {
				...toRefs(data),
				sendUploadMessage,
				handleLongPress,
				handleTouchEnd,
				handleTouchMove
			};
		},
	});
	export default AudioMessage;
</script>

<style lang="scss" scoped>
	.audio-contain {
		display: flex;
		justify-content: center;
		font-size: 32rpx;
		font-family: PingFangSC-Regular;
	}

	.TUI-message-input-main {
		background-color: #fff;
		flex: 1;
		height: 66rpx;
		margin: 0 10rpx;
		padding: 0 5rpx;
		border-radius: 5rpx;
		display: flex;
		align-items: center;
	}

	.record-modal {
		height: 300rpx;
		width: 60vw;
		background-color: #000;
		opacity: 0.8;
		position: fixed;
		top: 670rpx;
		z-index: 9999;
		left: 20vw;
		border-radius: 24rpx;
		display: flex;
		flex-direction: column;
	}

	.record-modal .wrapper {
		display: flex;
		height: 200rpx;
		box-sizing: border-box;
		padding: 10vw;
	}

	.record-modal .wrapper .modal-loading {
		opacity: 1;
		width: 40rpx;
		height: 16rpx;
		border-radius: 4rpx;
		background-color: #006fff;
		animation: loading 2s cubic-bezier(0.17, 0.37, 0.43, 0.67) infinite;
	}

	@keyframes loading {
		0% {
			transform: translate(0, 0)
		}

		50% {
			transform: translate(30vw, 0);
			background-color: #f5634a;
			width: 40px;
		}

		100% {
			transform: translate(0, 0);
		}
	}

	.modal-title {
		text-align: center;
		color: #fff;
	}
</style>
