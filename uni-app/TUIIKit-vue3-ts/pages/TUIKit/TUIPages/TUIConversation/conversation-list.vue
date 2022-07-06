<template>
	<view class="TUI-conversation-list" @click="dialogID = ''">
		<view v-for="(item, index) in conversationList" :key="index">
			<view class="TUI-conversation-item"
				:class="[dialogID === item.conversationID && 'selected', item.isPinned && 'pinned']"
				@click="handleGotoItem(item)" @longpress="handleItemLongpress(item)">
				<aside class="left">
					<img class="avatar" :src="handleItemAvator(item)">
					<span class="num" v-if="item.unreadCount>0 && item.messageRemindType !== 'AcceptNotNotify'">
						{{item.unreadCount > 99 ? '99+' : item.unreadCount}}
					</span>
					<span class="num-notNotify"
						v-if="item.unreadCount>0 && item.messageRemindType === 'AcceptNotNotify'"></span>
				</aside>
				<main class="content">
					<header class="content-header">
						<label>
							<p class="name">{{handleItemName(item)}}</p>
						</label>
					</header>
					<footer class="content-footer">
						<span class="content-footer-unread"
							v-if="item.unreadCount>0 && item.messageRemindType === 'AcceptNotNotify'">[{{item.unreadCount > 99 ? '99+' : item.unreadCount}}条]</span>
						<span class="message-text">{{handleItemMessage(item.lastMessage)}}</span>
						<view class="conversation-line"></view>
					</footer>
					<view class="item-footer">
						<span class="time">{{handleItemTime(item.lastMessage.lastTime)}}</span>
						<image class="mute-icon" v-if="item.messageRemindType === 'AcceptNotNotify'"
							src="/pages/TUIKit/assets/icon/mute.svg"></image>
					</view>
				</main>
				<view class="dialog-box dialog-item" v-if="item.conversationID===dialogID">
					<view class="conversation-options" @click.stop="handleConversation('delete', dialogID)">删除会话</view>
					<view class="conversation-options" v-if="!item.isPinned"
						@tap.stop="handleConversation('ispinned', dialogID)">置顶会话</view>
					<view class="conversation-options" v-if="item.isPinned"
						@click.stop="handleConversation('dispinned', dialogID)">取消置顶</view>
					<view class="conversation-options"
						v-if="item.messageRemindType === '' || item.messageRemindType === 'AcceptAndNotify'"
						@click.stop="handleConversation('mute', dialogID)">消息免打扰</view>
					<view class="conversation-options" v-if="item.messageRemindType === 'AcceptNotNotify'"
						@click.stop="handleConversation('notMute', dialogID)">取消免打扰</view>
				</view>
			</view>
		</view>
	</view>
</template>
<script lang="ts">
	import {
		defineComponent,
		reactive,
		toRefs,
		watchEffect
	} from 'vue';
	import {
		caculateTimeago
	} from '../../utils/date';
	const TUIConversationList = defineComponent({
		props: {
			conversationList: {
				type: Array,
				default: () => {
					return [];
				}
			},
			currentID: {
				type: String,
				default: () => {
					return '';
				}
			},

		},

		setup(props: any, ctx: any) {
			const obj = reactive({
				conversationList: [],
				currentID: '',
				isOpened: 'none',
				currentConversation: {},
				dialogID: '',
			});

			watchEffect(() => {
				obj.conversationList = props.conversationList;
				obj.currentID = props.currentID;
			});

			// 处理头像
			const handleItemAvator = (item: any) => {
				let avatar = '';
				switch (item.type) {
					case uni.$TUIKit.TIM.TYPES.CONV_C2C:
						avatar = item?.userProfile?.avatar ||
							'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png';
						break;
					case uni.$TUIKit.TIM.TYPES.CONV_GROUP:
						avatar = item?.groupProfile?.avatar ||
							'https://web.sdk.qcloud.com/component/TUIKit/assets/group_avatar.png';
						break;
					case uni.$TUIKit.TIM.TYPES.CONV_SYSTEM:
						avatar = item?.groupProfile?.avatar ||
							'https://web.sdk.qcloud.com/component/TUIKit/assets/group_avatar.png';
						break;
				}
				return avatar;
			};
			// 处理昵称
			const handleItemName = (item: any) => {
				let name = '';
				switch (item.type) {
					case uni.$TUIKit.TIM.TYPES.CONV_C2C:
						name = item?.userProfile.nick || item?.userProfile?.userID || '';
						break;
					case uni.$TUIKit.TIM.TYPES.CONV_GROUP:
						name = item.groupProfile.name || item?.groupProfile?.groupID || '';
						break;
					case uni.$TUIKit.TIM.TYPES.CONV_SYSTEM:
						name = '系统通知';
						break;
				}
				return name;
			};
			// 处理时间
			const handleItemTime = (time: number) => {
				if (time > 0) {
					return caculateTimeago(time * 1000);
				}
				return '';
			};
			// 处理lastMessage
			const handleItemMessage = (message: any) => {
				switch (message.type) {
					case uni.$TUIKit.TIM.TYPES.MSG_TEXT:
						return message.payload.text;
					default:
						return message.messageForShow;
				};
			};

			const handleGotoItem = (item: any) => {
				ctx.emit('handleGotoItem', item);
			};

			const handleItemLongpress = (item: any) => {
				obj.currentConversation = item;
				obj.dialogID = item.conversationID;
				if (item.type === 'C2C') {
					obj.currentuserID = item.userProfile.userID;
				} else if (item.type === 'GROUP') {
					obj.currentuserID = item.groupProfile.groupID;
				}
				obj.conversationType = item.type;
			};
			// todo
			const handlerIsOpened = (item: any) => {
				if (item.conversationID === obj.doalogID) {
					return 'right'
				} else {
					return 'none'
				}
			};

			// 删除会话,后续TODO,置顶聊天,消息免打扰
			const handleConversation = (type: string) => {
				switch (type) {
					case 'delete':
						uni.$TUIKit.TUIConversationServer.deleteConversation(obj.dialogID).then((imResponse:
							any) => {
							const {
								conversationID
							} = imResponse.data;
						});
						obj.dialogID = '';
						break;
					case 'ispinned':
						if (type === 'ispinned') {
							const options: any = {
								conversationID: obj.dialogID,
								isPinned: true,
							};
							uni.$TUIKit.TUIConversationServer.pinConversation(options).then((imResponse:
								any) => {
									console.log(imResponse);
								});
						}
						obj.dialogID = '';
						break;
					case 'dispinned':
						if (type === 'dispinned') {
							const options: any = {
								conversationID: obj.dialogID,
								isPinned: false,
							};
							uni.$TUIKit.TUIConversationServer.pinConversation(options).then((imResponse:
								any) => {});
						}
						obj.dialogID = '';
						break;
					case 'mute':
						if (type === 'mute' && obj.conversationType === 'C2C') {
							const options: any = {
								userIDList: [obj.currentuserID],
								messageRemindType: uni.$TUIKit.TIM.TYPES.MSG_REMIND_ACPT_NOT_NOTE
							};
							uni.$TUIKit.TUIConversationServer.muteConversation(options).then((imResponse:
								any) => {
									console.log(imResponse);
								});
						} else if (type === 'mute' && obj.conversationType === 'GROUP') {
							const options: any = {
								groupID: obj.currentuserID,
								messageRemindType: uni.$TUIKit.TIM.TYPES.MSG_REMIND_ACPT_NOT_NOTE
							};
							uni.$TUIKit.TUIConversationServer.muteConversation(options).then((imResponse:
								any) => {
									console.log(imResponse);
								});
						}
						obj.dialogID = '';
						break;
					case 'notMute':
						if (type === 'notMute' && obj.conversationType === 'C2C') {
							const options: any = {
								userIDList: [obj.currentuserID],
								messageRemindType: uni.$TUIKit.TIM.TYPES.MSG_REMIND_ACPT_AND_NOTE,
							};
							uni.$TUIKit.TUIConversationServer.muteConversation(options).then((imResponse:
								any) => {
									console.log(imResponse);
								});
						} else if (type === 'notMute' && obj.conversationType === 'GROUP') {
							const options: any = {
								groupID: obj.currentuserID,
								messageRemindType: uni.$TUIKit.TIM.TYPES.MSG_REMIND_ACPT_AND_NOTE
							};
							uni.$TUIKit.TUIConversationServer.muteConversation(options).then((imResponse:
								any) => {
									console.log(imResponse);
								});
						}
						obj.dialogID = '';
						break;
				}
			};
			return {
				...toRefs(obj),
				handleGotoItem,
				handleItemAvator,
				handleItemTime,
				handleItemMessage,
				handleItemName,
				handleItemLongpress,
				handleConversation,
				handlerIsOpened,
			};
		}
	});
	export default TUIConversationList;
</script>
<style lang="scss" scoped>
	.TUI-conversation {
		font-family: PingFangSC-Regular;
		font-weight: 400;
		letter-spacing: 0;

		&-list {
			list-style: none;
		}

		&-item {
			position: relative;
			padding: 12px;
			display: flex;
			align-items: center;

			.left {
				position: relative;

				.num {
					font-family: PingFangSC-Regular;
					position: absolute;
					display: inline-block;
					right: -8px;
					top: -8px;
					background: red;
					width: 20px;
					height: 20px;
					font-size: 11px;
					text-align: center;
					line-height: 20px;
					border-radius: 50%;
					color: #ffffff;
					font-weight: 600;
					letter-spacing: 0;
				}

				.num-notNotify {
					position: absolute;
					display: inline-block;
					right: -4px;
					top: -4px;
					background: red;
					width: 11px;
					height: 11px;
					border-radius: 50%;
					color: #ffffff;
				}

				.avatar {
					width: 48px;
					height: 48px;
					border-radius: 6px;
				}
			}

			.content {
				flex: 1;
				padding-left: 10px;
				position: relative;

				p {
					width: 200px;
					overflow: hidden;
					text-overflow: ellipsis;
					white-space: nowrap;
					font-weight: 400;
					font-size: 14px;
					color: #999999;
					letter-spacing: 0;
					line-height: 19px;
					font-family: PingFangSC-Regular;
				}

				 .conversation-line{
					position: absolute;
					display: block;
					left: 0;
					right: -12px;
					height: 0.5px;
					transform: scaleY(0.3);
					background: #B0B0B0;
					/* padding-top: 10px; */
					bottom: -15px;

				}

				.name {
					font-weight: 400;
					font-size: 16px;
					color: #000000;
					letter-spacing: 0;
					margin-bottom: 5px;
					font-family: PingFangSC-Regular
				}

				&-header {
					display: flex;
					justify-content: space-between;
					align-items: center;

					label {
						flex: 1;
						font-size: 14px;
						color: #000000;

						.name {
							width: 110px;
							overflow: hidden;
							text-overflow: ellipsis;
							white-space: nowrap;
						}
					}

					.time {
						font-size: 12px;
						color: #B0B0B0;
						line-height: 16px;
						display: inline-block;
						max-width: 75px;
						font-weight: 400;
					}
				}

				&-footer {
					color: #999999;
					line-height: 16px;
					display: flex;

					.message-text {
						margin-left: 4px;
						display: block;
						width: 240px;
						overflow: hidden;
						text-overflow: ellipsis;
						white-space: nowrap
					}
				}

				.item-footer {
					position: absolute;
					right: 0;
					top: 0;
					justify-items: center;
					display: flex;
					flex-direction: column;
					align-items: flex-end;

					.time {
						font-size: 12px;
						color: #B0B0B0;
						line-height: 16px;
						display: inline-block;
						max-width: 75px;
						font-weight: 400;
						margin-bottom: 5px;
					}

					.mute-icon {
						display: block;
						width: 20px;
						height: 20px;
					}
				}
			}

			.dialog-box {
				position: absolute;
				z-index: 5;
				background: #fff;
				border: 1px solid #dddddd;
				padding: 15px 20px;
				right: 15px;
				top: 30px;

				&-item {
					top: 60px;
					right: 40px;
					box-shadow: 0 11px 20px 0 rgb(0 0 0 / 30%);
					background: #FFFFFF;
					border: 1px solid #E0E0E0;
					box-shadow: 0 -4px 12px 0 rgb(0 0 0 / 6%);
					border-radius: 8px;
				}

				.conversation-options {
					height: 35px;
					font-family: PingFangSC-Regular;
					font-weight: 400;
					font-size: 14px;
					color: #4F4F4F;
					letter-spacing: 0;
					line-height: 35px;
				}
			}
		}
	}
	.selected {
		background: #EDF0F5;
	}
	
	.pinned {
		background: #EEF0F3;
	}
</style>
