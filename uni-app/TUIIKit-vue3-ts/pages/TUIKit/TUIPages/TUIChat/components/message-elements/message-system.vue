<template>
 <view v-for="(item, index) in messageList" :key="index">
 	<view v-if="item.payload.operationType === 1" class="card handle">
 		<view>
 			<view class="time">{{ caculateTimeago(item.time * 1000) }}</view>
 			{{ translateGroupSystemNotice(item) }}
 		</view>
 		<view class="choose"><view class="button" @tap="handleClick">处理</view></view>
 	</view>
 	<view class="card" v-else>
 		<view class="time">{{ caculateTimeago(item.time * 1000) }}</view>
 		{{translateGroupSystemNotice(item)}}
 	</view>
 </view>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';
import { translateGroupSystemNotice } from "@/pages/TUIKit/utils/untis";
import { caculateTimeago } from '@/pages/TUIKit/utils/date';
const MessageSystem = defineComponent({
  props: {
    data: {
      type: Array,
      default: () => {
        return [];
      }
    },
    types: {
      type: Object,
      default: () => {
        return {};
      }
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      messageList: [],
      types: {}
    });

    watchEffect(()=>{
      data.messageList = props.data;
      data.types = props.types;
    });

   const handleApplication = () => {
    	uni.showActionSheet({
    		itemList: ['同意', '拒绝'],
    		success: res => {
    			const option = {
    				handleAction: 'Agree',
    				handleMessage: '欢迎进群',
    				message: this.message
    			};
    
    			if (res.tapIndex === 1) {
    				option.handleAction = 'Reject';
    				option.handleMessage = '拒绝申请';
    			}
    
    			uni.$TUIKit.tim.handleGroupApplication(option)
    				.then(() => {
    					uni.showToast({
    						title: option.handleAction === 'Agree' ? '已同意申请' : '已拒绝申请'
    					});
    				})
    				.catch(error => {
    					uni.showToast({
    						title: error.message || '处理失败',
    						icon: 'none'
    					});
    				});
    		}
    	});
    }
    // const handleApplication = (handleAction:string, message:any) => {
    //   const options:any = {
    //     handleAction,
    //     message,
    //   };
    //   ctx.emit('application', options);
    // };

    return {
      ...toRefs(data),
      translateGroupSystemNotice,
      handleApplication,
			caculateTimeago,
    };
  }
});
export default MessageSystem
</script>
<style lang="scss" scoped>
.container {
	width: 100%;
	height: 200rpx;
}

.handle {
	display: flex;
	justify-content: space-between;
}

.card {
	font-size: 14px;
	margin: 20px;
	padding: 20px;
	box-sizing: border-box;
	border: 1px solid #abdcff;
	background-color: #f0faff;
	border-radius: 12px;
}

.time {}

.button {
	color: blue;
	border-radius: 8px;
	line-height: 30px;
	font-size: 16px;
	width: 70px;
}

</style>
