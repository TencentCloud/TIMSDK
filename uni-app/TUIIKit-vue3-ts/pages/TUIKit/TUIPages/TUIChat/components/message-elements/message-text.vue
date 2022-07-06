<template>
	<view  :class="['content content-' + message.flow]">
		<view v-for="(item, index) in data.text" :key="index">
		  <view  v-if="item.name === 'text'">{{ item.text }}</view>
		  <img class="text-img" v-else-if="item.name === 'img'" :src="item.src"/>
		</view>
	</view>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';

const MessageText =  defineComponent({
  props: {
    data: {
      type: Object,
      default: () => {
        return {};
      }
    },
		messageData: {
			type: Object,
			default: () => {
				return {};
			}
		}
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      data: {},
			message: {}
    });

    watchEffect(()=>{
      data.data = props.data;
			data.message = props.messageData;
    });
    return {
      ...toRefs(data),
    };
  }
});
export default MessageText
</script>
<style lang="scss" scoped>
.text-img {
  width: 20px;
  height: 20px;
}
.content {
		display: flex;
		flex-wrap: wrap;
		padding: 10px;
    &-in {
      background: #e1e1e1;
      border-radius: 0px 10px 10px 10px;
    }
    &-out {
      background: #DCEAFD;
      border-radius: 10px 0px 10px 10px;
    }
  }
</style>
