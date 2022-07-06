<template>
	<view class="tip-message">
		<view class="text-message">{{ renderDom[0].text }}</view>
	</view>
</template>

<script>
import { parseGroupTip } from '../../../base/message-facade';

export default {
	data() {
		return {};
	},

	components: {},
	props: {
		message: {
			type: Object
		}
	},
	watch: {
		message: {
			handler: function(newVal) {
				this.setData({
					renderDom: parseGroupTip(newVal)
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
