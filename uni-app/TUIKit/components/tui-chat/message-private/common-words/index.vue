<template>
	<view v-show="display" class="tui-common-words-container">
		<view class="tui-common-words-box">
			<view class="tui-common-words-title">
				<view>请选择你要发送的常用语</view>
				<view style="color: #006EFF; font-family: PingFangSC-Regular;" class="tui-common-words-close" @tap="handleClose">关闭</view>
			</view>
			<view class="tui-search-bar">
				<image class="tui-searchcion" src="/static/static/assets/serach-icon.svg"></image>
				<input class="tui-search-bar-input" :value="words" placeholder="请输入您想要提出的问题" @input="wordsInput" />
			</view>
			<scroll-view class="tui-common-words-list" scroll-y="true" enable-flex="true">
				<view v-for="(item, index) in commonWordsMatch" :key="index" class="tui-common-words-item" @tap="sendMessage" :data-words="item">{{ item }}</view>
			</scroll-view>
		</view>
	</view>
</template>

<script>
const commonWordsList = [
	'什么时候发货',
	'发什么物流',
	'为什么物流一直没更新',
	'最新优惠',
	'包邮吗',
	'修改地址信息',
	'修改收件人信息',
	'物流一直显示正在揽收',
	'问题A',
	'问题B'
];

export default {
	data() {
		return {
			words: '',
			commonWordsMatch: commonWordsList
		};
	},

	components: {},
	props: {
		display: {
			type: Boolean,
			default: false
		}
	},
	watch: {
		display: {
			handler: function(newVal) {
				// this.setData({
				//   display: newVal
				// });
			},
			immediate: true
		}
	},
	methods: {
		handleClose() {
			this.$emit('close', {
				detail: {
					key: '0'
				}
			});
		},

		wordsInput(e) {
			(this.commonWordsMatch = []),
				commonWordsList.forEach(item => {
					if (item.indexOf(e.detail.value) > -1) {
						this.commonWordsMatch.push(item);
					}
				});
			this.setData({
				words: e.detail.value,
				commonWordsMatch: this.commonWordsMatch
			});
		},

		sendMessage(e) {
			this.$emit('sendMessage', {
				detail: {
					message: e.currentTarget.dataset.words
				}
			});
		}
	}
};
</script>
<style>
@import './index.css';
</style>
