<template>
	<view class="dialog-video" >
	  <video  class="video-box" v-if="show" :src="videoData"  id="videoEle"  controls autoplay >
			<!-- 	<cover-view  class="video-close">
					<cover-image class="video-icon"  @tap="toggleClose" src="/pages/TUIKit/assets/icon/close.svg"></cover-image>
					<cover-image class="video-icon" src="/pages/TUIKit/assets/icon/save.svg"></cover-image>
				</cover-view> -->
		</video>

	</view>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';
	import {
		onLoad,
		onShow,
		onReady,
		onNavigationBarButtonTap
	} from '@dcloudio/uni-app'
export default defineComponent({
	name: "videoPlay",
  setup(props:any) {
    const data = reactive({
			videoData: '',
      show: false,
			videoContext: null,
			direction: 0
    });
		onLoad((option) => {
			data.videoData = option && option.videoMessage
			data.show = true
		})
	
		onReady(() => {
			data.videoContext = uni.createVideoContext('videoEle');
		 })
		const toggleClose = () => {
			data.show = false
			uni.navigateBack({
				delta: 1
			});
		}
    return {
      ...toRefs(data),
			toggleClose
    };
  }
});
</script>
<style lang="scss" scoped>
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
 justify-content: center;
 align-items: center;
	.video-box {
		position: absolute;
		width: 100vw;
		height: 100vh;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
	}
	.video-close {
		z-index: 999;
		width: 90%;
		color: antiquewhite;
		position: absolute;
		display: flex;
		justify-content:space-between;
		bottom: 50px;
		left: 10px;
		right: 0;
		margin: 0 auto;
	.video-icon	{
		display: block;
		width: 30px;
		height: 30px;
	}
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
