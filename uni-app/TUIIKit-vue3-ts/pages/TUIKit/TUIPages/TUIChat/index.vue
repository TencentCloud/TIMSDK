<template>
	<view class="TUIChat" v-if="conversationType === 'chat'">
		<!-- #ifdef MP-WEIXIN -->
		<view class="more-btn" v-if="conversation?.type === 'GROUP'" @click="handleGetProfile"> 更多</view>
		<!-- #endif -->
		<view class="TUIChat-container">
			<scroll-view class="TUIChat-main" scroll-y="true" :scroll-with-animation="true"
				:refresher-triggered="triggered" :refresher-enabled="true" @refresherrefresh="handleRefresher"
				:scroll-top="scrollTop">
				<view class="TUI-message-list" @touchstart="handleTouchStart" @click="dialogID = ''">
					<view class="loading-text" v-if="isCompleted">没有更多</view>
					<view v-for="(item, index) in messages" :key="item.ID" :id="'view' + item.ID">
						<view class="time-container" v-if="item.showTime">{{ caculateTimeago(item.time * 1000) }}</view>
						<MessageTip v-if="!item.isRevoked && item.type === types.MSG_GRP_TIP"
							:data="handleTipMessageShowContext(item)" />
						<!-- <MessageTip v-if="item.type === types.MSG_GRP_SYS_NOTICE" /> -->
						<MessageBubble v-if="!item.isRevoked && item.type !== types.MSG_GRP_TIP" :data="item">
							<Message-Operate v-if="dialogID === item.ID" :data="item" class="dialog dialog-item"
								:style="{ 'top': dialogPosition.top + 'px', 'right': dialogPosition.right + 'px', 'left': dialogPosition.left + 'px' }">
							</Message-Operate>
							<MessageText :id="item.flow + '-' + item.ID" v-if="item.type === types.MSG_TEXT"
								:data="handleTextMessageShowContext(item)" :messageData="item"
								@longpress="handleItem($event, item)"></MessageText>
							<MessageImage :id="item.flow + '-' + item.ID" v-if="item.type === types.MSG_IMAGE"
								:data="handleImageMessageShowContext(item)" :messageData="item"
								@longpress="handleItem($event, item)"></MessageImage>
							<MessageVideo :id="item.flow + '-' + item.ID" v-if="item.type === types.MSG_VIDEO"
								:data="handleVideoMessageShowContext(item)" :messageData="item"
								@longpress="handleItem($event, item)" />
							<MessageAudio :id="item.flow + '-' + item.ID" v-if="item.type === types.MSG_AUDIO"
								:data="handleAudioMessageShowContext(item)" :messageData="item"
								@longpress="handleItem($event, item)" />
							<MessageFace :id="item.flow + '-' + item.ID" v-if="item.type === types.MSG_FACE"
								:data="handleFaceMessageShowContext(item)" :messageData="item"
								@longpress="handleItem($event, item)" />
							<MessageCustom :id="item.flow + '-' + item.ID" v-if="item.type === types.MSG_CUSTOM"
								:data="handleCustomMessageShowContext(item)" :messageData="item"
								@longpress="handleItem($event, item)" />
						</MessageBubble>
						<MessageRevoked v-if="item.isRevoked" :data="item" @edit="handleEdit(item)" />
					</view>
				</view>
			</scroll-view>
		</view>
		<TUIChatInput :text="text" :conversationData="conversation"></TUIChatInput>
	</view>
	<view class="TUIChat" v-if="conversationType === 'system'">
		<MessageSystem :data="messages" :types="types" />
	</view>
</template>
<script lang="ts">
	import {
		defineComponent,
		reactive,
		toRefs,
		ref,
		computed,
		nextTick,
		watch,
		onMounted,
		onBeforeUnmount
	} from 'vue';
	import {
		onShow,
		onReady,
		onLoad,
		onNavigationBarButtonTap
	} from '@dcloudio/uni-app'

	// 消息元素组件
	import MessageBubble from './components/message-elements/message-bubble.vue'
	import MessageText from './components/message-elements/message-text.vue';
	import MessageImage from './components/message-elements/message-image.vue';
	import MessageOperate from './components/message-elements/message-operate.vue';
	import MessageVideo from './components/message-elements/message-video.vue';
	import MessageAudio from './components/message-elements/message-audio.vue';
	import MessageFace from './components/message-elements/message-face.vue';
	import MessageCustom from './components/message-elements/message-custom.vue';
	import MessageTip from './components/message-elements/message-tip.vue';
	import MessageRevoked from './components/message-elements/message-revoked.vue';
	import MessageSystem from './components/message-elements/message-system.vue';
	// 底部消息发送组件
	import TUIChatInput from './components/message-input'
	import store from '../../TUICore/store'
	import {
		handleAvatar,
		handleTextMessageShowContext,
		handleImageMessageShowContext,
		handleVideoMessageShowContext,
		handleAudioMessageShowContext,
		handleFileMessageShowContext,
		handleFaceMessageShowContext,
		handleLocationMessageShowContext,
		handleMergerMessageShowContext,
		handleTipMessageShowContext,
		handleCustomMessageShowContext
	} from "../../utils/untis";

	import {
		caculateTimeago
	} from '../../utils/date';
	import Vuex from 'vuex';

	export default defineComponent({
		name: "TUIChat",
		components: {
			MessageText,
			MessageImage,
			MessageVideo,
			MessageAudio,
			MessageFace,
			MessageCustom,
			MessageBubble,
			MessageTip,
			MessageRevoked,
			MessageSystem,
			TUIChatInput,
			MessageOperate,
		},

		setup(props) {
			const timStore = store.state.timStore;
			const TUIServer: any = uni.$TUIKit.TUIChatServer;
			const left: number | null = 0;
			const right: number | null = 0;
			const defaultDialogPosition = {
				top: -70,
				left,
				right,
			};

			const data = reactive({
				messageList: computed(() => timStore.messageList),
				conversation: computed(() => timStore.conversation),
				triggered: false,
				scrollTop: 9999,
				text: '',
				types: uni.$TUIKit.TIM.TYPES,
				currentMessage: {},
				dialogID: '',
				forwardStatus: false,
				imageFlag: false,
				isCompleted: false,
				oldMessageTime: 0,
				dialogPosition: defaultDialogPosition,
			});

			// 判断当前会话类型：无/系统会话/正常C2C、群聊
			const conversationType = computed(() => {
				const conversation: any = data.conversation;
				if (!conversation?.conversationID) {
					return '';
				}
				if (conversation?.type === uni.$TUIKit.TIM.TYPES.CONV_SYSTEM) {
					return 'system';
				}
				return 'chat';
			});

			// 不展示已删除消息
			const messages = computed(() => {
				// console.error(data.messageList, '----data.messageList.length')
				if (data.messageList.length > 0) {
					data.oldMessageTime = data.messageList[0].time;
					return data.messageList.filter((item: any) => {
						return !item.isDeleted;
					});
				}

			})
			// 获取页面参数
			onLoad((options) => {
				uni.setNavigationBarTitle({
					title: options && options.conversationName
				});
			});

			// 监听数据渲染，展示最新一条消息
			watch(messages, (newVal: any, oldVal: any) => {
				// 下拉刷新不滑动 todo 优化
				nextTick(() => {
					const newLastMessage = newVal[newVal.length - 1];
					const oldLastMessage = oldVal ? oldVal[oldVal.length - 1] : {};
					data.oldMessageTime = messages.value[0].time;
					handleShowTime();
					if (oldVal && newLastMessage.ID !== oldLastMessage.ID) {
						handleScrollBottom() // 非从conversationList 首次进入
					}
				});
			});
			// 监听数据初次渲染，展示最新一条消息
			// TODO app 中获取不到DOM 元素
			onReady(() => {
				// 延时 300 ，能完成更新 ！！！  首次进入回话，滑动到底部优化 安卓出现抖动
				// data.scrollTop = 9999;
				setTimeout(() => {
					data.scrollTop = 9999;
				}, 500);

			});

			onMounted(() => {
				handleShowTime();
				// 监听回退，已读上报
				uni.addInterceptor('navigateBack', {
					success() {
						// 小程序无效 官网链接：https://uniapp.dcloud.io/api/interceptor.html
						uni.$TUIKit.TUIConversationServer.setMessageRead(data.conversation
							.conversationID);
					}
				})
			})

			// 
			onNavigationBarButtonTap(() => {
				if (data.conversation?.type === uni.$TUIKit.TIM.TYPES.CONV_GROUP) {
					uni.navigateTo({
						url: '../TUIGroupManage/index'
					});
				} else {
					uni.showToast({
						title: '暂无信息'
					})
				}
			})
			const handleGetProfile = () => {
				uni.navigateTo({
					url: '../TUIGroupManage/index'
				});
			}
			const handleShowTime = () => {
				if (messages.value) {
					Array.from(messages.value).forEach((item) => {
						if (item.time - data.oldMessageTime > 5 * 60) {
							data.oldMessageTime = item.time;
							item.showTime = true;
						} else {
							item.showTime = false;
						}
					})
				}
			};
			const handleScrollBottom = () => {
				uni.createSelectorQuery().select(".TUI-message-list").boundingClientRect((
					res) => {
					const scrollH = res.height;
					data.scrollTop = scrollH;
				}).exec()
			}

			// 需要自实现下拉加载
			const handleScroll = (e: any) => {
				data.triggered = 'restore'; // 需要重置  
			}

			const handleRefresher = () => {
				data.triggered = true;
				if (!data.isCompleted) {
					TUIServer.getHistoryMessageList().then((res) => {
						console.error(data.isCompleted, '----data.isCompleted')
						data.triggered = false;
						data.isCompleted = res.isCompleted;
					})
				}
				setTimeout(() => {
					data.triggered = false;
				}, 500)
			}

			// 处理需要合并的数据
			const handleSend = (emo: any) => {
				data.text += emo.name;
				// inputEle.value.focus();

			};

			// 发送消息
			const handleSendTextMessage = (e: any) => {
				if (data.text.trimEnd()) {
					TUIServer.sendTextMessage(JSON.parse(JSON.stringify(data.text)));
				}
				data.text = ' ';
			};
			// 右键消息，展示处理功能
			const handleItem = (event: any, item: any) => {
				const {
					flow
				} = item;
				// const { height, top } = event.target.getBoundingClientRect();
				try {
					const query = uni.createSelectorQuery(); // .in(this)
					query.select(`#${item.flow + '-' + item.ID}`).boundingClientRect((res: any) => {
						const {
							height,
							top
						} = res;
						// 弹框在下面显示，60--弹框高度；44--导航栏高度；20--弹框离信息间距
						if (top < (60 + 20)) {
							data.dialogPosition = {
								...data.dialogPosition,
								top: height + 10, // 在下面展示弹框 + 10px 间隔
							};
							data.dialogPosition = {
								...data.dialogPosition,
								right: flow === 'out' ? 0 : null, // 发出去的消息（弹框 right 都是 0）
								left: flow === 'in' ? 0 : null, // 接收的消息（弹框 left 都是 0）
							};
						} else {
							data.dialogPosition = {
								...defaultDialogPosition,
								right: flow === 'out' ? 0 : null, // 发出去的消息（弹框 right 都是 0）
								left: flow === 'in' ? 0 : null, // 接收的消息（弹框 left 都是 0）
							};
						}
					}).exec((res: any) => {
						data.currentMessage = item;
						data.dialogID = item.ID;
					});
				} catch (error) {
					data.currentMessage = item;
					data.dialogID = item.ID;
				}
			};

			// 滑动触发时，失焦收起键盘
			const handleTouchStart = () => {
				uni.hideKeyboard()
			};
			// 重新编辑
			const handleEdit = (item: any) => {
				data.text = item.payload.text;
			};

			return {
				...toRefs(data),
				conversationType,
				messages,
				handleShowTime,
				handleTouchStart,
				handleRefresher,
				handleScroll,
				handleScrollBottom,
				handleSendTextMessage,
				handleItem,
				handleEdit,
				handleTextMessageShowContext,
				handleImageMessageShowContext,
				handleVideoMessageShowContext,
				handleAudioMessageShowContext,
				handleFileMessageShowContext,
				handleFaceMessageShowContext,
				handleLocationMessageShowContext,
				handleMergerMessageShowContext,
				handleTipMessageShowContext,
				handleCustomMessageShowContext,
				handleSend,
				caculateTimeago,
				handleGetProfile,
			};
		},
	});
</script>
<style lang="scss" scoped>
	@import '../styles/TUIChat.scss';
</style>
