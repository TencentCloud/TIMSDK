<template>
	<view :class="'text-message ' + (isMine ? 'my-text' : '')">
		<view v-for="(item, index) in renderDom" :key="index" class="message-body-span">
			<span class="message-body-span-text" v-if="item.name === 'span'">{{ item.text }}</span>
			<image v-if="item.name === 'img'" class="emoji-icon" :src="item.src"></image>
		</view>
	</view>
</template>

<script>
import { parseText } from '../../../base/message-facade';

export default {
	data() {
		return {
			renderDom: []
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
					renderDom: parseText(newVal)
				});
			},
			immediate: true,
			deep: true
		}
	},

	beforeMount() {
		// 在组件实例进入页面节点树时执行
	},

	destroyed() {
		// 在组件实例被从页面节点树移除时执行
	},

	methods: {}
};
</script>
<style>
@import './index.css';
</style>
