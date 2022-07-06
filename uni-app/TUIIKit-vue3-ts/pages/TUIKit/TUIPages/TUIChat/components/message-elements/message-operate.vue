<template>
 <view class="dialog-container">
 	<view  class="item-box"  v-if="message.flow === 'out' && message.status==='success'" @click="handleMseeage('revoke')">
		<image class="item-icon" src="/pages/TUIKit/assets/icon/revoked.svg"></image>
		<view>撤回</view>
 	</view>
 	<view class="item-box" v-if="message.status==='success'" @click="handleMseeage('delete')">
		<image class="item-icon"  src="/pages/TUIKit/assets/icon/delete.svg"/>
		<view>删除</view>
	</view>
<!-- 	<view class="item-box" v-if="message.status==='success'" @click="handleMseeage('forward')">
		<img class="item-icon"  src="/pages/TUIKit/assets/icon/forword.svg">
		<view>转发</view>
	</view> -->
 	<view class="item-box" v-if="message.flow === 'out' && message.status==='fail'" @click="handleMseeage('resend')">
		<image class="item-icon"  src="/pages/TUIKit/assets/icon/forword.svg"/>
		<view>重发</view>
 	</view>
	<!-- <view v-if="message.type === types.MSG_FILE || item.type === types.MSG_VIDEO || item.type === types.MSG_IMAGE"
 		@click="openMessage(item)">打开</view> -->
 </view>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';
const MessageOperate = defineComponent({
  props: {
    data: {
      type: Object,
      default: () => {
        return {};
      }
    },
  },
  setup(props:any, ctx:any) {
		const TUIServer: any = uni.$TUIKit.TUIChatServer;
    const data = reactive({
      message: {},
    });

    watchEffect(()=>{
      data.message = props.data;
    });
		// 处理消息
		const handleMseeage = async (type: string) => {
			switch (type) {
				case 'revoke':
					await TUIServer.revokeMessage(data.message).catch((error) => {
						if (error.code = 20016)
						uni.showToast({
							title: '消息超过了 2 分钟',
							icon: 'error'
						})
					})
					data.dialogID = '';
					break;
				case 'delete':
					await TUIServer.deleteMessage([data.message]);
					data.dialogID = '';
					break;
				case 'resend':
					await TUIServer.resendMessage(data.message);
					data.dialogID = '';
					break;
				case 'forward':
					data.dialogID = '';
					// conversationData.list = uni.$TUIKit.tim.getStore()['TUIConversation'].conversationList;
					// data.forwardStatus = true;
					break;
			}
		};
    return {
      ...toRefs(data),
			handleMseeage,
    };
  }
});
export default  MessageOperate;
</script>
<style lang="scss" scoped>
	.dialog-container {
		display: flex;
		justify-content: space-around;
		padding: 10px;
	}
	.item-box {
		display: inline-flex;
		font-size: 12px;
		flex-direction: column;
		line-height: 16px;
		width: 40px;
		height: 28px;
		font-family: PingFangSC-Regular;
		font-weight: 400;
		color: #4F4F4F;
		letter-spacing: 0;
	}
	.item-icon {
		flex-shrink: 0;
		display: inline-block;
		width: 22px;
		height: 22px;
		margin-bottom: 5px;
	}
</style>
