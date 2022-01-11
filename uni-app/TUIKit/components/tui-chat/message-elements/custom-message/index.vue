<template>
	<view>
		<view v-if="renderDom[0].type === 'order'" :class="'custom-message ' + (isMine ? 'my-custom' : '')">
			<image class="custom-image" :src="renderDom[0].imageUrl"></image>
			<view class="custom-content">
				<view class="custom-content-title">{{ renderDom[0].title }}</view>
				<view class="custom-content-description">{{ renderDom[0].description }}</view>
				<view class="custom-content-price">{{ renderDom[0].price }}</view>
			</view>
		</view>
		<view v-if="renderDom[0].type === 'consultion'" :class="'custom-message ' + (isMine ? 'my-custom' : '')">
			<view class="custom-content">
				<view class="custom-content-title">{{ renderDom[0].title }}</view>
				<view v-for="(item, index) in renderDom[0].item" :key="index" class="custom-content-description" :id="item.key">{{ item.key }}</view>
				<view class="custom-content-description">{{ renderDom[0].description }}</view>
			</view>
		</view>
		<view v-if="renderDom[0].type === 'evaluation'" :class="'custom-message ' + (isMine ? 'my-custom' : '')">
			<view class="custom-content">
				<view class="custom-content-title">{{ renderDom[0].title }}</view>
				<view class="custom-content-score">
					<image v-for="(item, index) in renderDom[0].score" :key="index" class="score-star" src="/static/static/images/star.png"></image>
				</view>
				<view class="custom-content-description">{{ renderDom[0].description }}</view>
			</view>
		</view>
		<view v-if="renderDom[0].type === 'group_create'" :class="'custom-message ' + (isMine ? 'my-custom' : '')">
			<view class="custom-content-text">{{ renderDom[0].text }}</view>
		</view>
		<view v-if="renderDom[0].type === 'c2cCalling' || renderDom[0].type === 'groupCalling'" :class="'custom-message ' + (isMine ? 'my-custom' : '')">
			<view class="custom-content-text">{{ renderDom[0].text }}</view>
		</view>
		<view v-if="renderDom[0].type === 'notSupport'" class="message-body-span text-message">
			<view class="message-body-span-text">{{ renderDom[0].text }}</view>
		</view>
	</view>
</template>

<script>
import { formateTime } from '../../../base/common.js';
export default {
	data() {
		return {};
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
					message: newVal,
					renderDom: this.parseCustom(newVal)
				});
			},
			immediate: true,
			deep: true
		}
	},
	methods: {
		// 解析音视频通话消息
		extractCallingInfoFromMessage(message) {
			const callingmessage = JSON.parse(message.payload.data);
			if (callingmessage.businessID !== 1) {
				return '';
			}
			const objectData = JSON.parse(callingmessage.data);
			switch (callingmessage.actionType) {
				case 1: {
					if (objectData.call_end >= 0 && !callingmessage.groupID) {
						return `通话时长：${formateTime(objectData.call_end)}`;
					}
					if (callingmessage.groupID) {
						return '结束群聊';
					}
					if (objectData.data && objectData.data.cmd === 'switchToAudio') {
						return '切换语音通话';
					}
					if (objectData.data && objectData.data.cmd === 'switchToVideo') {
						return '切换视频通话';
					}
					return '发起通话';
				}
				case 2:
					return '取消通话';
				case 3:
					if (objectData.data && objectData.data.cmd === 'switchToAudio') {
						return '切换语音通话';
					}
					if (objectData.data && objectData.data.cmd === 'switchToVideo') {
						return '切换视频通话';
					}
					return '已接听';
				case 4:
					return '拒绝通话';
				case 5:
					if (objectData.data && objectData.data.cmd === 'switchToAudio') {
						return '切换语音通话';
					}
					if (objectData.data && objectData.data.cmd === 'switchToVideo') {
						return '切换视频通话';
					}
					return '无应答';
				default:
					return '';
			}
		},
		parseCustom(message) {
			// 约定自定义消息的 data 字段作为区分，不解析的不进行展示
			if (message.payload.data === 'order') {
				const extension = JSON.parse(message.payload.extension);
				const renderDom = [
					{
						type: 'order',
						name: 'custom',
						title: extension.title || '',
						imageUrl: extension.imageUrl || '',
						price: extension.price || 0,
						description: message.payload.description
					}
				];
				return renderDom;
			} // 客服咨询

			if (message.payload.data === 'consultion') {
				const extension = JSON.parse(message.payload.extension);
				const renderDom = [
					{
						type: 'consultion',
						title: extension.title || '',
						item: extension.item || 0,
						description: extension.description
					}
				];
				return renderDom;
			} // 服务评价

			if (message.payload.data === 'evaluation') {
				const extension = JSON.parse(message.payload.extension);
				const renderDom = [
					{
						type: 'evaluation',
						title: message.payload.description,
						score: extension.score,
						description: extension.comment
					}
				];
				return renderDom;
			} // 群消息解析
			// 群消息解析
			if (message.payload.data === 'group_create') {
				const renderDom = [
					{
						type: 'group_create',
						text: message.payload.extension
					}
				];
				return renderDom;
			}
			// 音视频通话消息解析
			const callingmessage = JSON.parse(message.payload.data);

			if (callingmessage.businessID === 1) {
				if (message.conversationType === 'GROUP') {
					if (message.payload.data.actionType === 5) {
						message.nick = message.payload.data.inviteeList ? message.payload.data.inviteeList.join(',') : message.from;
					}
					const _text = this.extractCallingInfoFromMessage(message);
					const groupText = `${_text}`;
					const renderDom = [
						{
							type: 'groupCalling',
							text: groupText,
							userIDList: []
						}
					];
					return renderDom;
				}
				if (message.conversationType === 'C2C') {
					const c2cText = this.extractCallingInfoFromMessage(message);
					const renderDom = [
						{
							type: 'c2cCalling',
							text: c2cText
						}
					];
					return renderDom;
				}
			}

			if (message.payload.data === 'group_create') {
				const renderDom = [
					{
						type: 'group_create',
						text: message.payload.extension
					}
				];
				return renderDom;
			}

			return [
				{
					type: 'notSupport',
					text: '[自定义消息]'
				}
			];
		}
	}
};
</script>
<style>
@import './index.css';
</style>
