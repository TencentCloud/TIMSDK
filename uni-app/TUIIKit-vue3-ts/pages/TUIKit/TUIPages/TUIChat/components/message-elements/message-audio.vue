<template>
  <view class="message-audio" :class="['content content-' + message.flow]"  @click="handlePlay">
    <image v-if="message.flow==='in'" class="audio-icon audio-icon-in" src="../../../../assets/icon/audio-play.svg"></image>
		<view>{{data.second}}s</view>
		<image v-if="message.flow==='out'" class="audio-icon " src="../../../../assets/icon/audio-play.svg"></image>
<!-- 		<view class="play-icon" v-if="message.flow==='in' && !isPlay" ></view>
 -->  
 </view>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs, ref, onMounted } from 'vue';
const audio = uni.createInnerAudioContext();
const MessageAudio = defineComponent({
  props: {
    data: {
      type: Object,
      default: () => {
        return {};
      }
    },
		messageData: {
			type: Object,
			default: () => {
				return {};
			}
		}
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      data: {},
			message: {},
			isPlay: false,
    });
		
    watchEffect(()=>{
      data.data = props.data;
			data.message = props.messageData
    });
		
		onMounted(() => {
			audio.onPlay(() => {
				console.log('开始播放');
			});
			audio.onEnded(() => {
				console.log('停止播放');
			});
			audio.onError(e => {
				console.error(e, 'onError');
				// ios 音频播放无声，可能是因为系统开启了静音模式
				uni.showToast({
					icon: 'none',
					title: '该音频暂不支持播放'
				});
			});
			
		})
		
    const handlePlay = () => {
			if (audioUrl) {
				audio.src = audioUrl;
				audio.play();
			}
			data.isPlay = true
    };

    return {
      ...toRefs(data),
      audio,
      handlePlay
    };
  }
});
export default MessageAudio
</script>
<style lang="scss" scoped>
.message-audio {
  display: flex;
	width: 80px;
  align-items: center;
  position: relative;
  .icon {
    margin: 0 4px;
  }
	.audio-icon {
		width: 20px;
		height: 20px;
		padding: 0 5px;
	}
	.audio-icon-in {
		transform: rotate(180deg)
	}
	.play-icon {
		position: absolute;
		right: -7px;
		top: 1px;
		width: 6px;
		height: 6px;
		border-radius: 100%;
		background-color: #f73232;
	}
  audio {
    width: 0;
    height: 0;
  }
}
.reserve {
  flex-direction: row-reverse;
}
.mask {
  position: fixed;
  width: 100vw;
  height: 100vh;
  top: 0;
  left: 0;
  opacity: 0;
  z-index: 1;
}
.content {
		padding: 10px;
    &-in {
      background: #e1e1e1;
      border-radius: 0px 10px 10px 10px;
    }
    &-out {
      background: #DCEAFD;
      border-radius: 10px 0px 10px 10px;
    }
  }
</style>
