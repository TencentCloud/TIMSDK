<template>
		<view class="TUI-message-input-container">
			<view class="TUI-message-input">
				<!-- #ifdef H5 -->
				<image class="TUI-icon" @tap="handleEmoji" src="/pages/TUIKit/assets/icon/emoji.svg"></image>
				<!-- #endif -->
				<!-- #ifndef H5 -->
				<image class="TUI-icon" @tap="handleSwitchAudio" src="../../../../assets/icon/audio.svg"></image>
				<!-- #endif -->
				<view v-if="!isAudio" class="TUI-message-input-main">
					<input
						class="TUI-message-input-area"
						:adjust-position="true"
						cursor-spacing="20"
						v-model="inputText"
						confirm-type="send" 
						confirm-hold="true"
						@confirm="handleSendTextMessage"
						maxlength="140"
						type="text"
						placeholder-class="input-placeholder"
						placeholder="说点什么呢~"
					/>
				</view>
				<view v-else class="TUI-message-input-main">
					<AudioMessage></AudioMessage>
				</view>
				<view class="TUI-message-input-functions" hover-class="none">
					<image class="TUI-icon" @tap="handleEmoji" src="/pages/TUIKit/assets/icon/emoji.svg"></image>
					<view @tap="handleExtensions" >
						<image class="TUI-icon" src="/pages/TUIKit/assets/icon/more.svg"></image>
					</view>
    		</view>
			</view>
			<view v-if="displayFlag === 'emoji'" class="TUI-Emoji-area">
				<Face :show="displayFlag === 'emoji'" @send="handleSend"  @handleSendEmoji="handleSendTextMessage"></Face>
			</view>
			<view v-if="displayFlag === 'extension'" class="TUI-Extensions">
				<!-- TODO: 这里功能还没实现
				<!       <camera device-position="back" flash="off" binderror="error" style="width: 100%; height: 300px;"></camera>-->
				<view class="TUI-Extension-slot" @tap="handleSendImageMessage('camera')">
					<image class="TUI-Extension-icon" src="/pages/TUIKit/assets/icon/take-photo.svg"></image>
					<view class="TUI-Extension-slot-name">拍照</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleSendImageMessage('album')">
					<image class="TUI-Extension-icon" src="/pages/TUIKit/assets/icon/send-img.svg"></image>
					<view class="TUI-Extension-slot-name">图片</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleSendVideoMessage('album')">
					<image class="TUI-Extension-icon" src="/pages/TUIKit/assets/icon/take-video.svg"></image>
					<view class="TUI-Extension-slot-name">视频</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleSendVideoMessage('camera')">
					<image class="TUI-Extension-icon" src="/pages/TUIKit/assets/icon/take-photo.svg"></image>
					<view class="TUI-Extension-slot-name">录像</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleCalling(1)">
					<image class="TUI-Extension-icon" src="/pages/TUIKit/assets/icon/audio-calling.svg"></image>
					<view class="TUI-Extension-slot-name">语音通话</view>
				</view>
				<view class="TUI-Extension-slot" @tap="handleCalling(2)">
					<image class="TUI-Extension-icon" src="/pages/TUIKit/assets/icon/take-video.svg"></image>
					<view class="TUI-Extension-slot-name">视频通话</view>
				</view>
			</view>
		</view>
</template>

<script lang="ts">
	
import { defineComponent, watchEffect, reactive, toRefs, onMounted, computed } from 'vue';
import Face from './message/face.vue';
import AudioMessage from './message/audio.vue'
import store from '../../../../TUICore/store'

const TUIChatInput =  defineComponent({
	 components: {
		Face,
		AudioMessage
	},
	props: {
	  text: {
	    type: String,
	    default: () => {
	      return '';
	    }
	  },
		conversationData: {
			type: Object,
			default: () => {
			  return '';
			}
		}
	},
	setup(props) {
		const TUIServer: any = uni.$TUIKit.TUIChatServer;
	  const data = reactive({
	    firstSendMessage: true,
	    inputText: '',
	    extensionArea: false,
	    sendMessageBtn: false,
	    displayFlag: '',
	    isAudio: false,
	    displayServiceEvaluation: false,
	    displayCommonWords: false,
	    displayOrderList: false,
			
			conversation: computed(() => store.state.timStore.conversation)
	  });
		
		watchEffect(()=>{
		  data.inputText = props.text;
		});
		
		const handleSwitchAudio = () => {
			    data.isAudio = !data.isAudio
		};
		
		const handleEmoji = () => {
			data.displayFlag = data.displayFlag === 'emoji' ? '' : 'emoji';
		};
		const handleExtensions = (e: any) => {
			data.displayFlag = data.displayFlag === 'extension' ? '' : 'extension';
		}
		
		// 发送消息
		const handleSendTextMessage = (e: any) => {
			if (data.inputText.trimEnd()) {
				uni.$TUIKit.TUIChatServer.sendTextMessage(JSON.parse(JSON.stringify(data.inputText)));
			}
			data.inputText = ' ';
		};

		// 处理需要合并的数据
		const handleSend = (emo: any) => {
			data.inputText += emo.name;
			// inputEle.value.focus();
		};
		
		const	handleSendImageMessage = (type: any)=> {
				uni.chooseImage({
					sourceType: [type],
					count: 1,
					success: res => {
						 uni.getImageInfo({
						      src: res.tempFilePaths[0],
						      success (image) {
						        console.error(image)
										TUIServer.sendImageMessage(res, image)
						      }
						    })
					}
				});
			};
	
			const handleSendVideoMessage=(type:any) => {
				uni.chooseVideo({
					sourceType: [type],
					// 来源相册或者拍摄
					maxDuration: 60,
					// 设置最长时间60s
					camera: 'back',
					// 后置摄像头
					success: res => {
						if (res) {
							console.error(res, '----linda')
							TUIServer.sendVideoMessage(res)
					}
				}
			});
		}
	
		const handleCalling = (value: any) => {
				// todo 目前支持单聊
				if (data.conversation.type === 'GROUP') {
					uni.showToast({
						title: '群聊暂不支持',
						icon: 'none'
					});
					return;
				}
				const { userID } = data.conversation.userProfile;
		
				// #ifdef APP-PLUS
				if(typeof(uni.$TUICalling) === 'undefined') {
						console.error('请使用真机运行并且自定义基座调试，可能影响音视频功能～ 插件地址：https://ext.dcloud.net.cn/plugin?id=7097 , 调试地址：https://nativesupport.dcloud.net.cn/NativePlugin/use/use');
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
				// #ifndef APP-PLUS
				uni.showToast({
					title: '暂不支持',
					icon: 'none'
				});
				// #endif
			}
		return {
			...toRefs(data),
			handleExtensions,
			handleSendImageMessage,
			handleSendTextMessage,
			handleSendVideoMessage,
			handleEmoji,
			handleSend,
			handleSwitchAudio,
			handleCalling
		}
	},
});
export default TUIChatInput	
</script>
<style lang="scss" scoped>
.TUI-message-input-container {
	background-color: #F1F1F1;
	padding-bottom: 20rpx;
}

.TUI-message-input {
	display: flex;
	padding: 16rpx;
	background-color: #F1F1F1;
	width: 100vw;
}

.TUI-commom-function {
	display: flex;
	flex-wrap: nowrap;
	width: 750rpx;
	height: 106rpx;
	background-color: #F1F1F1;
	align-items: center;
}

.TUI-commom-function-item {
	display: flex;
	width: 136rpx;
	justify-content: center;
	align-items: center;
	font-size: 24rpx;
	color: #FFFFFF;
	height: 48rpx;
	margin-left: 16rpx;
	border-radius: 24rpx;
	background-color: #00C8DC;
}

.TUI-commom-function-item:first-child {
	margin-left: 48rpx;
}

.TUI-message-input-functions {
	display: flex;
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

.TUI-message-input-area {
	width: 100%;
	height: 100%;
}

.TUI-icon {
	width: 56rpx;
	height: 56rpx;
	margin: 0 16rpx;
}

.TUI-Extensions {
	display: flex;
	flex-wrap: wrap;
	width: 100vw;
	height: 450rpx;
	margin-left: 14rpx;
	margin-right: 14rpx;
}

.TUI-Extension-slot {
	width: 128rpx;
	height: 170rpx;
	margin-left: 26rpx;
	margin-right: 26rpx;
	margin-top: 24rpx;
}

.TUI-Extension-icon {
	width: 128rpx;
	height: 128rpx;
}

.TUI-sendMessage-btn {
	display: flex;
	align-items: center;
	margin: 0 10rpx;
}

.TUI-Emoji-area {
	width: 100vw;
	height: 450rpx;
}

.TUI-Extension-slot-name {
	line-height: 34rpx;
	font-size: 24rpx;
	color: #333333;
	letter-spacing: 0;
	text-align: center;
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

.modal-title {
	text-align: center;
	color: #fff;
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
</style>
