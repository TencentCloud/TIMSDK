<template>
	<view :class="'audio-message ' + (isMine ? 'my-audio' : '')">
		<image class="audio-icon" src="../../../../static/static/images/audio-msg.png"></image>
		<view class="audio " @click="handlePlayAudioMessage" :style="'width: ' + 120 + 'rpx'">{{ '" ' + message.payload.second }}</view>
	</view>
</template>

<script>
export default {
	data() {
		return {
			audio: {}
		};
	},

	components: {},
	props: {
		message: {
			type: Object,
			default: () => {}
		},
		isMine: {
			type: Boolean,
			default: true
		}
	},
	watch: {
		message: {
			handler: function(newVal) {
				this.setData({
					message: newVal
				});
			},
			immediate: true,
			deep: true
		}
	},

	beforeMount() {
		this.audio = uni.createInnerAudioContext();
		this.audio.onPlay(() => {
			console.log('开始播放');
		});
		this.audio.onEnded(() => {
			console.log('停止播放');
		});
		this.audio.onError(e => {
			console.error(e, 'onError');
			// ios 音频播放无声，可能是因为系统开启了静音模式
			uni.showToast({
				icon: 'none',
				title: '该音频暂不支持播放'
			});
		});
	},

	methods: {
		handlePlayAudioMessage() {
			this.audio.src = this.message.payload.url;
			this.audio.play();
		}
	}
};
</script>
<style>
@import './index.css';
</style>
