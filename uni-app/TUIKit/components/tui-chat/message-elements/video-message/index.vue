<template>
	<view :class="'video-box ' + (isMine ? 'my-video' : '')" @click="playerHander">
		<image class="video-icon" src="../../../../static/static/images/video-play.png"></image>
	</view>
</template>

<script>
import videoIcon from '../../../../static/static/images/video-play.png';
export default {
	data() {
		return {
			isPlay: false,
			videoIcon: videoIcon
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
	methods: {
		playerHander() {
			uni.$emit('videoPlayerHandler', {
				isPlay: true,
				message: this.message
			});
		},
		stopHander() {
			this.isPlay = false;
		}
	}
};
</script>
<style>
@import './index.css';
</style>
