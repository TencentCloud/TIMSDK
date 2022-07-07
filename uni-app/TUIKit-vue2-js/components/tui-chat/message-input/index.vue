<template>
	<view>
		<view class="TUI-message-input-container">
			<view class="TUI-commom-function">
				<view v-for="(item, index) in commonFunction" :key="index" class="TUI-commom-function-item" :data-function="item" @tap="handleCommonFunctions">
					{{ item.name }}
				</view>
			</view>
			<view class="TUI-message-input">
				<image class="TUI-icon" @tap="switchAudio" :src="isAudio ? '/static/static/assets/keyboard.svg' : '/static/static/assets/audio.svg'"></image>
				<view v-if="!isAudio" class="TUI-message-input-main">
					<input
						class="TUI-message-input-area"
						:adjust-position="true"
						cursor-spacing="20"
						v-model="inputText"
						@input="onInputValueChange"
						maxlength="140"
						type="text"
						placeholder-class="input-placeholder"
						placeholder="说点什么呢~"
						@focus="inputBindFocus"
						@blur="inputBindBlur"
					/>
				</view>
				<view
					v-else
					class="TUI-message-input-main"
					@longpress="handleLongPress"
					@touchmove="handleTouchMove"
					@touchend="handleTouchEnd"
					style="display: flex; justify-content: center; font-size: 32rpx; font-family: PingFangSC-Regular;"
				>
					<text>{{ text }}</text>
				</view>
				<view class="TUI-message-input-functions" hover-class="none">
					<image class="TUI-icon" @tap="handleEmoji" src="/static/static/assets/face-emoji.svg"></image>
					<view v-if="!sendMessageBtn" @tap="handleExtensions"><image class="TUI-icon" src="/static/static/assets/more.svg"></image></view>
					<view v-else class="TUI-sendMessage-btn" @tap="sendTextMessage">发送</view>
				</view>
			</view>
			<view v-if="displayFlag === 'emoji'" class="TUI-Emoji-area"><TUI-Emoji @enterEmoji="appendMessage"></TUI-Emoji></view>
			<view v-if="displayFlag === 'extension'" class="TUI-Extensions">
				<!-- TODO: 这里功能还没实现 -->
				<!--        <camera device-position="back" flash="off" binderror="error" style="width: 100%; height: 300px;"></camera>-->
				<view class="TUI-Extension-slot" @tap="handleSendPicture">
					<image class="TUI-Extension-icon" src="/static/static/assets/take-photo.svg"></image>
					<view class="TUI-Extension-slot-name">拍摄照片</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleSendImage">
					<image class="TUI-Extension-icon" src="/static/static/assets/send-img.svg"></image>
					<view class="TUI-Extension-slot-name">发送图片</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleShootVideo">
					<image class="TUI-Extension-icon" src="/static/static/assets/take-video.svg"></image>
					<view class="TUI-Extension-slot-name">拍摄视频</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleSendVideo">
					<image class="TUI-Extension-icon" src="/static/static/assets/send-video.svg"></image>
					<view class="TUI-Extension-slot-name">发送视频</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleCalling(1)">
					<image class="TUI-Extension-icon" src="/static/static/assets/audio-calling.svg"></image>
					<view class="TUI-Extension-slot-name">语音通话</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleCalling(2)">
					<image class="TUI-Extension-icon" src="/static/static/assets/video-calling.svg"></image>
					<view class="TUI-Extension-slot-name">视频通话</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleServiceEvaluation">
					<image class="TUI-Extension-icon" src="/static/static/assets/service-assess.svg"></image>
					<view class="TUI-Extension-slot-name">服务评价</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleSendOrder">
					<image class="TUI-Extension-icon" src="/static/static/assets/send-order.svg"></image>
					<view class="TUI-Extension-slot-name">发送订单</view>
				</view>
			</view>
			<TUI-Common-Words class="tui-cards" :display="displayCommonWords" @sendMessage="$handleSendTextMessage" @close="$handleCloseCards"></TUI-Common-Words>
			<TUI-Order-List class="tui-cards" :display="displayOrderList" @sendCustomMessage="$handleSendCustomMessage" @close="$handleCloseCards"></TUI-Order-List>
			<TUI-Service-Evaluation
				class="tui-cards"
				:display="displayServiceEvaluation"
				@sendCustomMessage="$handleSendCustomMessage"
				@close="$handleCloseCards"
			></TUI-Service-Evaluation>
		</view>
		<view class="record-modal" v-if="popupToggle" @longpress="handleLongPress" @touchmove="handleTouchMove" @touchend="handleTouchEnd">
			<view class="wrapper"><view class="modal-loading"></view></view>
			<view class="modal-title">{{ title }}</view>
		</view>
	</view>
</template>

<script>
import TUIEmoji from '../message-elements/emoji/index';
import TUICommonWords from '../message-private/common-words/index';
import TUIOrderList from '../message-private/order-list/index';
import TUIServiceEvaluation from '../message-private/service-evaluation/index';

export default {
	data() {
		return {
			// todo  conversation
			// conversation: {},
			firstSendMessage: true,
			inputText: '',
			extensionArea: false,
			sendMessageBtn: false,
			displayFlag: '',
			isAudio: false,
			bottomVal: 0,
			startPoint: 0,
			popupToggle: false,
			isRecording: false,
			canSend: true,
			text: '按住说话',
			title: ' ',
			notShow: false,
			isShow: true,
			recordTime: 0,
			recordTimer: null,
			commonFunction: [
				{
					name: '常用语',
					key: '0'
				},
				{
					name: '发送订单',
					key: '1'
				},
				{
					name: '服务评价',
					key: '2'
				}
			],
			displayServiceEvaluation: false,
			displayCommonWords: false,
			displayOrderList: false
		};
	},

	components: {
		TUIEmoji,
		TUICommonWords,
		TUIOrderList,
		TUIServiceEvaluation
	},
	props: {
		conversation: {
			type: Object,
			default: () => {}
		}
	},
	watch: {
		conversation: {
			handler: function(newVal) {
				// todo 值会被改变
				// this.setData({
				//   conversation: newVal
				// });
			},
			immediate: true,
			deep: true
		}
	},

	beforeMount() {
		// 加载声音录制管理器
		this.recorderManager = uni.getRecorderManager();
		this.recorderManager.onStop(res => {
			clearInterval(this.recordTimer);
			// 兼容 uniapp 打包app，duration 和 fileSize 需要用户自己补充
			// 文件大小 ＝ (音频码率) x 时间长度(单位:秒) / 8
			let msg = {
				duration: res.duration ? res.duration : this.recordTime * 1000,
				tempFilePath: res.tempFilePath,
				fileSize: res.fileSize ? res.fileSize : ((48 * this.recordTime) / 8) * 1024
			};
			uni.hideLoading();
			// 兼容 uniapp 语音消息没有duration
			if (this.canSend) {
				if (msg.duration < 1000) {
					uni.showToast({
						title: '录音时间太短',
						icon: 'none'
					});
				} else {
					// res.tempFilePath 存储录音文件的临时路径
					const message = uni.$TUIKit.createAudioMessage({
						to: this.getToAccount(),
						conversationType: this.conversation.type,
						payload: {
							file: msg
						}
					});
					this.$sendTIMMessage(message);
				}
			}

			this.setData({
				startPoint: 0,
				popupToggle: false,
				isRecording: false,
				canSend: true,
				title: ' ',
				text: '按住说话'
			});
		});
	},

	methods: {
		switchAudio() {
			this.setData({
				isAudio: !this.isAudio,
				text: '按住说话'
			});
		},

		handleLongPress(e) {
			this.recorderManager.start({
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
			this.setData({
				startPoint: e.touches[0],
				title: '正在录音',
				// isRecording : true,
				// canSend: true,
				notShow: true,
				isShow: false,
				isRecording: true,
				popupToggle: true,
				recordTime: 0
			});
			this.recordTimer = setInterval(() => {
				this.recordTime++;
			}, 1000);
		},

		// 录音时的手势上划移动距离对应文案变化
		handleTouchMove(e) {
			if (this.isRecording) {
				if (this.startPoint.clientY - e.touches[e.touches.length - 1].clientY > 100) {
					this.setData({
						text: '抬起停止',
						title: '松开手指，取消发送',
						canSend: false
					});
				} else if (this.startPoint.clientY - e.touches[e.touches.length - 1].clientY > 20) {
					this.setData({
						text: '抬起停止',
						title: '上划可取消',
						canSend: true
					});
				} else {
					this.setData({
						text: '抬起停止',
						title: '正在录音',
						canSend: true
					});
				}
			}
		},

		// 手指离开页面滑动
		handleTouchEnd() {
			this.setData({
				isRecording: false,
				popupToggle: false
			});
			uni.hideLoading();
			this.recorderManager.stop();
		},
		handleEmoji() {
			let targetFlag = 'emoji';

			if (this.displayFlag === 'emoji') {
				targetFlag = '';
			}

			this.setData({
				displayFlag: targetFlag
			});
		},

		handleExtensions() {
			let targetFlag = 'extension';

			if (this.displayFlag === 'extension') {
				targetFlag = '';
			}

			this.setData({
				displayFlag: targetFlag
			});
		},

		error(e) {
			console.log(e.detail);
		},

		handleSendPicture() {
			this.sendImageMessage('camera');
		},

		handleSendImage() {
			this.sendImageMessage('album');
		},

		sendImageMessage(type) {
			uni.chooseImage({
				sourceType: [type],
				count: 1,
				success: res => {
					if (res) {
						const message = uni.$TUIKit.createImageMessage({
							to: this.getToAccount(),
							conversationType: this.conversation.type,
							payload: {
								file: res
							},
							onProgress: percent => {
								message.percent = percent;
							}
						});
						this.$sendTIMMessage(message);
					}
				}
			});
		},

		handleShootVideo() {
			this.sendVideoMessage('camera');
		},

		handleSendVideo() {
			this.sendVideoMessage('album');
		},

		sendVideoMessage(type) {
			uni.chooseVideo({
				sourceType: [type],
				// 来源相册或者拍摄
				maxDuration: 60,
				// 设置最长时间60s
				camera: 'back',
				// 后置摄像头
				success: res => {
					if (res) {
						const message = uni.$TUIKit.createVideoMessage({
							to: this.getToAccount(),
							conversationType: this.conversation.type,
							payload: {
								file: res
							},
							onProgress: percent => {
								message.percent = percent;
							}
						});
						this.$sendTIMMessage(message);
					}
				}
			});
		},

		handleCommonFunctions(e) {
			switch (e.target.dataset.function.key) {
				case '0':
					this.setData({
						displayCommonWords: true
					});
					break;

				case '1':
					this.setData({
						displayOrderList: true
					});
					break;

				case '2':
					this.setData({
						displayServiceEvaluation: true
					});
					break;

				default:
					break;
			}
		},

		handleSendOrder() {
			this.setData({
				displayOrderList: true
			});
		},

		appendMessage(e) {
			this.setData({
				inputText: this.inputText + e.detail.message,
				sendMessageBtn: true
			});
		},

		getToAccount() {
			if (!this.conversation || !this.conversation.conversationID) {
				return '';
			}

			switch (this.conversation.type) {
				case 'C2C':
					return this.conversation.conversationID.replace('C2C', '');

				case 'GROUP':
					return this.conversation.conversationID.replace('GROUP', '');

				default:
					return this.conversation.conversationID;
			}
		},
		handleCalling(value) {
			// todo 目前支持单聊
			if (this.conversation.type === 'GROUP') {
				uni.showToast({
					title: '群聊暂不支持',
					icon: 'none'
				});
				return;
			}
			const { userID } = this.conversation.userProfile;

			// #ifdef APP-PLUS
			if(typeof(uni.$TUICalling) === 'undefined') {
					logger.error('请使用真机运行并且自定义基座调试，可能影响音视频功能～ 插件地址：https://ext.dcloud.net.cn/plugin?id=7097 , 调试地址：https://nativesupport.dcloud.net.cn/NativePlugin/use/use');
					uni.showToast({
						title: '请使用真机运行并且自定义基座调试，可能影响音视频功能～ ',
						icon: 'none',
						duration: 3000
					});
			} else {
				uni.$TUICalling.call(
					{
						userID: userID,
						type: value
					},
					res => {
						console.log(JSON.stringify(res));
					}
				);
			}
			// #endif
			// #ifdef MP-WEIXIN
			uni.showToast({
				title: '微信小程序暂不支持',
				icon: 'none'
			});
			// uni.$wxTUICalling.call({userID, type: value})
			// #endif
		},
		sendTextMessage(msg, flag) {
			const to = this.getToAccount();
			const text = flag ? msg : this.inputText;
			const message = uni.$TUIKit.createTextMessage({
				to,
				conversationType: this.conversation.type,
				payload: {
					text
				}
			});
			this.setData({
				inputText: '',
				sendMessageBtn: false
			});
			this.$sendTIMMessage(message);
		},

		onInputValueChange(event) {
			if (event.detail.value) {
				this.setData({
					sendMessageBtn: true
				});
			} else {
				this.setData({
					sendMessageBtn: false
				});
			}
		},

		$handleSendTextMessage(event) {
			this.sendTextMessage(event.detail.message, true);
			this.setData({
				displayCommonWords: false
			});
		},

		$handleSendCustomMessage(e) {
			const message = uni.$TUIKit.createCustomMessage({
				to: this.getToAccount(),
				conversationType: this.conversation.type,
				payload: e.detail.payload
			});
			this.$sendTIMMessage(message);
			this.setData({
				displayOrderList: false
			});
		},

		$handleCloseCards(e) {
			switch (e.detail.key) {
				case '0':
					this.setData({
						displayCommonWords: false
					});
					break;

				case '1':
					this.setData({
						displayOrderList: false
					});
					break;

				case '2':
					this.setData({
						displayServiceEvaluation: false
					});
					break;

				default:
					break;
			}
		},

		$sendTIMMessage(message) {
			const SDKAppID = getApp().globalData.SDKAppID;
			this.$emit('sendMessage', {
				detail: {
					message
				}
			});
			uni.$TUIKit.sendMessage(message).then((res) => {
				if(this.firstSendMessage) {
					uni.$aegis.reportEvent({
					    name: 'sendMessage',
					    ext1: 'sendMessage-success',
					    ext2: 'uniTuikitExternal',
					    ext3: `${SDKAppID}`,
					})
				}
				this.firstSendMessage = false
			}).catch((error) => {
				uni.$aegis.reportEvent({
						name: 'sendMessage',
						ext1: `sendMessage-failed#error: ${error}`,
						ext2: 'uniTuikitExternal',
						ext3: `${SDKAppID}`,
			  })
			})
			this.setData({
				displayFlag: ''
			});
		},

		handleClose() {
			this.setData({
				displayFlag: ''
			});
		},

		handleServiceEvaluation() {
			this.setData({
				displayServiceEvaluation: true
			});
		},

		inputBindFocus() {
			console.log('占位：函数 inputBindFocus 未声明');
		},

		inputBindBlur() {
			console.log('占位：函数 inputBindBlur 未声明');
		}
	}
};
</script>
<style>
@import './index.css';
</style>
