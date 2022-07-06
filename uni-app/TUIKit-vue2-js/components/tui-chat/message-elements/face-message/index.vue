<template>
	<view class="TUI-faceMessage" @tap="previewImage"><image class="face-message" :src="renderDom.src"></image></view>
</template>

<script>
export default {
	data() {
		return {
			renderDom: [],
			percent: 0,
			faceUrl: 'https://web.sdk.qcloud.com/im/assets/face-elem/'
		};
	},

	components: {},
	props: {
		message: {
			type: Object
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
					renderDom: this.parseFace(newVal)
				});
			},
			immediate: true,
			deep: true
		}
	},
	methods: {
		// 解析face 消息
		parseFace(message) {
			const renderDom = {
				src: `${this.faceUrl + message.payload.data}@2x.png`
			};
			return renderDom;
		},

		previewImage() {
			uni.previewImage({
				current: this.renderDom[0].src,
				// 当前显示图片的http链接
				urls: [this.renderDom[0].src]
			});
		}
	}
};
</script>
<style>
@import './index.css';
</style>
