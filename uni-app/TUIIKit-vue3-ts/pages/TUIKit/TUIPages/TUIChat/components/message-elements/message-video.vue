<template>
 <div class="message-video">
    <div class="message-video-box" :class="[!video.progress && 'message-video-cover']" @tap="toggleShow">
     <image :src="video.snapshotUrl"  class="message-video-box" :class="['content-' + message.flow]"></image>
		 <image src="../../../../assets/icon/play_normal@2x.png"  class="video-play"></image>
    </div>
	</div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';

export default defineComponent({
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
      video: {},
			message: {},
      show: false,
			videoContext: null
    });

    watchEffect(()=>{
      data.video = props.data;
			data.message = props.messageData
    });

    const toggleShow = () => {
			uni.navigateTo({
				url:`./components/message-elements/video-play?videoMessage=${data.video.url}`
			})
    };
    return {
      ...toRefs(data),
      toggleShow,
    };
  }
});
</script>
<style lang="scss" scoped>
.message-video {
  position: relative;
  &-box {
		width: 120px;
    max-width: 120px;
		background-color: rgba(#000000, 0.3);
		border-radius: 6px;
		height: 200px;   // todo 优化高度动态获取
    video {
      // max-width: 300px;
    }
  }
  &-cover {
    display: inline-block;
    position: relative;
		.video-play {
			position: absolute;
			top: 0;
			right: 0;
			left: 0;
			bottom: 0;
			z-index: 3;
			width: 35px;
			height: 35px;
			margin: auto;
		}
    // video {
    //   max-width: 300px;
    // }
  }

  .progress {
    position: absolute;
    box-sizing: border-box;
    width: 100%;
    height: 100%;
    padding: 0 20px;
    left: 0;
    top: 0;
    background: rgba(#000000, 0.5);
    display: flex;
    align-items: center;
    progress {
      width: 100%;
    }
  }
}
.dialog-video {
  position: fixed;
  z-index: 999;
  width: 100vw;
  height: 100vh;
  background: rgba(#000000, 0.6);
  top: 0;
  left: 0;
	right: 0;
	bottom: 0;
  display: flex;
	flex-direction: column;
  justify-content: center;
  align-items: center;
	.video-box {
		position: absolute;
		width: 100vw;
		height: 90vh;
		top: 100px;
		left: 0;
		right: 0;
		bottom: 20px;
	}
	.video-close {
		color: antiquewhite;
		position: absolute;
		bottom: 0;
		
	}
}
.content {
		&-in {
			border-radius: 6px;
		}
		&-out {
			border-radius: 6px;
		}
 }
</style>
