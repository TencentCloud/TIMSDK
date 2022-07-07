<template>
	<view class="tui-cards-container" v-if="display">
		<view class="service-evaluation">
			<view class="header">
				<label class="header-label">请对本次服务进行评价</label>
				<view class="btn-close" @tap="handleClose">关闭</view>
			</view>
			<view class="main">
				<view class="main-evaluation-score">
					<image
						v-for="(item, index) in scoreList"
						:key="index"
						class="score-star"
						:data-score="item"
						:src="'/static/static/images/star' + (item > score ? '-grey' : '') + '.png'"
						@tap="handleScore"
					></image>
				</view>
				<textarea
					class="main-textarea"
					cols="30"
					rows="10"
					@input="bindTextAreaInput"
					placeholder="请输入评语"
					placeholder-style="textarea-placeholder"
				></textarea>
			</view>
			<view class="footer"><view class="btn" @tap="sendMessage" :disabled="score === 0 && !comment">提交评价</view></view>
		</view>
	</view>
</template>

<script>
export default {
	data() {
		return {
			scoreList: [1, 2, 3, 4, 5],
			score: 5,
			comment: ''
		};
	},

	components: {},
	props: {
		display: {
			type: Boolean,
			default: ''
		}
	},
	watch: {
		display: {
			handler: function(newVal) {},
			immediate: true
		}
	},

	onPageShow() {
		this.setData({
			score: 0,
			comment: ''
		});
	},

	methods: {
		handleClose() {
			this.$emit('close', {
				detail: {
					key: '2'
				}
			});
		},

		handleScore(e) {
			let { score } = e.currentTarget.dataset;

			if (score === this.score) {
				score = 0;
			}

			this.setData({
				score
			});
		},

		bindTextAreaInput(e) {
			this.setData({
				comment: e.detail.value
			});
		},

		sendMessage() {
			this.$emit('sendCustomMessage', {
				detail: {
					payload: {
						// data 字段作为表示，可以自定义
						data: 'evaluation',
						description: '对本次服务的评价',
						// 获取骰子点数
						extension: JSON.stringify({
							score: this.score,
							comment: this.comment
						})
					}
				}
			});
			this.setData({
				score: 0,
				comment: ''
			});
			this.handleClose();
		}
	}
};
</script>
<style>
@import './index.css';
</style>
