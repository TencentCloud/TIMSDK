<template>
	<view v-if="display" class="tui-cards-container">
		<view class="tui-cards-box">
			<view class="tui-cards-title">
				<view>请选择你要发送的订单</view>
				<view style="color: #006EFF; font-family: PingFangSC-Regular;" class="tui-cards-close" @tap="handleClose">关闭</view>
			</view>
			<view class="tui-search-bar">
				<image class="tui-searchcion" src="/static/static/assets/serach-icon.svg"></image>
				<input class="tui-search-bar-input" :value="words" placeholder="搜索" @input="wordsInput" />
			</view>
			<scroll-view class="tui-order-list" scroll-y="true" enable-flex="true">
				<view v-for="(item, index) in orderMatch" :key="index" class="tui-order-item">
					<view class="order-title">
						<view class="order-number">订单编号: {{ item.orderNum }}</view>
						<view class="order-time">{{ item.time }}</view>
					</view>
					<view class="order-info">
						<image class="order-image" :src="item.imageUrl"></image>
						<view class="order-content">
							<view class="order-content-title">{{ item.title }}</view>
							<view class="order-content-description">{{ item.description }}</view>
							<view style="display: flex; flex-wrap: no-wrap; justify-content: space-between;">
								<view class="order-content-price">{{ item.price }}</view>
								<view class="btn-send-order" :data-order="item" @tap.stop="sendMessage"><text class="btn-send-text">发送此订单</text></view>
							</view>
						</view>
					</view>
				</view>
			</scroll-view>
		</view>
	</view>
</template>

<script>
const orderList = [
	{
		orderNum: 1,
		time: '2021-7-20 20:45',
		title: '[天博检验]新冠核酸检测/预约',
		description: '专业医学检测，电子报告',
		imageUrl: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/miles.jpeg',
		price: '80元'
	},
	{
		orderNum: 2,
		time: '2021-7-20 22:45',
		title: '[路边]新冠核酸检测/预约',
		description: '专业医学检测，电子报告',
		imageUrl: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/miles.jpeg',
		price: '7000元'
	}
];

export default {
	data() {
		return {
			words: '',
			orderMatch: orderList
		};
	},

	components: {},
	props: {
		display: {
			type: Boolean,
			default: false
		},
		conversation: {
			type: Object,
			default: () => {}
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
		},
		conversation: {
			handler: function(newVal) {
				this.setData({
					conversation: newVal
				});
			},
			immediate: true,
			deep: true
		}
	},
	methods: {
		handleClose() {
			this.$emit('close', {
				detail: {
					key: '1'
				}
			});
		},

		wordsInput(e) {
			(this.orderMatch = []),
				orderList.forEach(item => {
					if (item.title.indexOf(e.detail.value) > -1 || item.orderNum === ~~e.detail.value) {
						this.orderMatch.push(item);
					}
				});
			this.setData({
				words: e.detail.value,
				orderMatch: this.orderMatch
			});
		},

		sendMessage(e) {
			const { order } = e.currentTarget.dataset;
			this.$emit('sendCustomMessage', {
				detail: {
					payload: {
						// data 字段作为表示，可以自定义
						data: 'order',
						description: order.description,
						// 获取骰子点数
						extension: JSON.stringify({
							title: order.title,
							imageUrl: order.imageUrl,
							price: order.price
						})
					}
				}
			});
		}
	}
};
</script>
<style>
@import './index.css';
</style>
