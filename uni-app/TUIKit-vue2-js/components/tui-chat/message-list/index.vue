<template>
	<scroll-view
		class="message-list-container"
		scroll-y="true"
		:scroll-into-view="scrollView"
		:refresher-enabled="true"
		@refresherrefresh="refresh"
		:scroll-top="scrollTop"
		:refresher-triggered="triggered"
	>
		<view id="message-scroll" style="width:100%">
			<view class="no-message" v-if="isCompleted">没有更多啦</view>
			<view v-for="item in messageList" :key="item.ID" class="t-message">
				<view v-if="conversation.type !== '@TIM#SYSTEM'" :id="item.ID">
					<view class="t-message-item">
						<TUI-TipMessage v-if="item.type === 'TIMGroupTipElem'" :message="item"></TUI-TipMessage>
						<view v-if="item.type !== 'TIMGroupTipElem'" :class="item.flow === 'out' ? 't-self-message' : 't-recieve-message'">
							<image
								class="t-message-avatar"
								v-if="item.flow === 'in'"
								:src="item.avatar || 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/avatar_21.png'"
							></image>
							<view class="read-receipts" v-if="conversation.type === 'C2C' && item.flow === 'out'">
								<view v-if="item.isPeerRead">已读</view>
								<view v-else>未读</view>
							</view>
							<view>
								<TUI-TextMessage v-if="item.type === 'TIMTextElem'" :message="item" :isMine="item.flow === 'out'"></TUI-TextMessage>
								<TUI-ImageMessage v-if="item.type === 'TIMImageElem'" :message="item" :isMine="item.flow === 'out'"></TUI-ImageMessage>
								<TUI-VideoMessage v-if="item.type === 'TIMVideoFileElem'" :message="item" :isMine="item.flow === 'out'"></TUI-VideoMessage>
								<TUI-AudioMessage v-if="item.type === 'TIMSoundElem'" :message="item" :isMine="item.flow === 'out'"></TUI-AudioMessage>
								<TUI-CustomMessage v-if="item.type === 'TIMCustomElem'" :message="item" :isMine="item.flow === 'out'"></TUI-CustomMessage>
								<TUI-FaceMessage v-if="item.type === 'TIMFaceElem'" :message="item" :isMine="item.flow === 'out'"></TUI-FaceMessage>
								<TUI-FileMessage v-if="item.type === 'TIMFileElem'" :message="item" :isMine="item.flow === 'out'"></TUI-FileMessage>
							</view>
							<image
								class="t-message-avatar"
								v-if="item.flow === 'out'"
								:src="item.avatar || 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/avatar_21.png'"
							></image>
						</view>
					</view>
				</view>
				<view v-else :id="item.ID" :data-value="item.ID"><TUI-SystemMessage :message="item"></TUI-SystemMessage></view>
			</view>
		</view>
	</scroll-view>
</template>

<script>
import TUITextMessage from '../message-elements/text-message/index';
import TUIImageMessage from '../message-elements/image-message/index';
import TUIVideoMessage from '../message-elements/video-message/index';
import TUIAudioMessage from '../message-elements/audio-message/index';
import TUICustomMessage from '../message-elements/custom-message/index';
import TUITipMessage from '../message-elements/tip-message/index';
import TUISystemMessage from '../message-elements/system-message/index';
import TUIFaceMessage from '../message-elements/face-message/index';
import TUIFileMessage from '../message-elements/file-message/index';

export default {
	data() {
		return {
			avatar: '',
			userID: '',
			// 当前会话
			messageList: [],
			// 自己的 ID 用于区分历史消息中，哪部分是自己发出的
			scrollView: '',
			scrollTop: 0,
			triggered: true,
			nextReqMessageID: '',
			// 下一条消息标志
			isCompleted: false // 当前会话消息是否已经请求完毕
		};
	},

	components: {
		TUITextMessage,
		TUIImageMessage,
		TUIVideoMessage,
		TUIAudioMessage,
		TUICustomMessage,
		TUITipMessage,
		TUISystemMessage,
		TUIFaceMessage,
		TUIFileMessage
	},
	props: {
		conversation: {
			type: Object,
			default: () => {}
		}
	},
	watch: {
		conversation: {
			handler: function(newVal) {
				if (!newVal.conversationID) return;
				this.setData(
					{
						conversation: newVal
					},
					() => {
						this.getMessageList(newVal);
					}
				);
			},
			immediate: true,
			deep: true
		}
	},
	mounted() {
		uni.$TUIKit.getMyProfile().then(res => {
			this.avatar = res.data.avatar;
			this.userID = res.data.userID;
		});
		uni.$TUIKit.on(uni.$TUIKitEvent.MESSAGE_RECEIVED, this.$onMessageReceived, this);
		uni.$TUIKit.on(uni.$TUIKitEvent.MESSAGE_READ_BY_PEER, this.$onMessageReadByPeer, this);
	},

	destroyed() {
		// 一定要解除相关的事件绑定
		uni.$TUIKit.off(uni.$TUIKitEvent.MESSAGE_RECEIVED, this.$onMessageReceived);
	},
	methods: {
		refresh() {
			if (this.isCompleted) {
				this.setData({
					isCompleted: true,
					triggered: false
				});
				return;
			}
			this.getMessageList(this.conversation);
			setTimeout(() => {
				this.setData({
					triggered: false
				});
			}, 2000);
		},

		getMessageList(conversation) {
			if (!this.isCompleted) {
				uni.$TUIKit
					.getMessageList({
						conversationID: conversation.conversationID,
						nextReqMessageID: this.nextReqMessageID,
						count: 15
					})
					.then(res => {
						const { messageList } = res.data; // 消息列表。
						this.nextReqMessageID = res.data.nextReqMessageID; // 用于续拉，分页续拉时需传入该字段。
						this.isCompleted = res.data.isCompleted; // 表示是否已经拉完所有消息。
						this.messageList = [...messageList, ...this.messageList];
						this.$handleMessageRender(this.messageList, messageList);
					});
			}
		},

		// 自己的消息上屏
		updateMessageList(msg) {
			this.messageList = [...this.messageList, msg];
			this.scrollToButtom();
		},

		// 消息已读更新
		$onMessageReadByPeer() {
			this.setData({
				messageList: this.messageList
			});
		},
		scrollToButtom() {
			const query = uni.createSelectorQuery().in(this);
			let nodesRef = query.select('#message-scroll');
			nodesRef
				.boundingClientRect(res => {
					this.$nextTick(() => {
						//进入页面滚动到底部
						this.scrollTop = res.height;
					});
				})
				.exec();
		},
		// 收到的消息
		$onMessageReceived(value) {
			// 若需修改消息，需将内存的消息复制一份，不能直接更改消息，防止修复内存消息，导致其他消息监听处发生消息错误
			const event = value;
			const list = [];
			event.data.forEach(item => {
				if (item.conversationID === this.conversation.conversationID) {
					list.push(Object.assign(item));
				}
			});
			this.messageList = this.messageList.concat(list);
			this.scrollToButtom();
		},

		// 历史消息渲染
		$handleMessageRender(messageList) {
			if (messageList.length > 0) {
				this.setData(
					{
						messageList
					},
					() => {}
				);
				this.$nextTick(() => {
					//进入页面滚动到底部
					this.scrollTop = 9999;
				});
			}
		}
	}
};
</script>
<style>
@import './index.css';
</style>
