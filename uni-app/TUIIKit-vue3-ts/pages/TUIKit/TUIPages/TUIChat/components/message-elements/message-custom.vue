<template>
  <view class="custom">
    <template v-if="isCustom === 'consultion'">
      <div>
        <h1>{{extension.title}}</h1>
        <ul>
          <li v-for="(item, index) in extension.item" :key="index">
            <a :href="item.value">{{item.key}}</a>
          </li>
        </ul>
        <article>{{extension.description}}</article>
      </div>
    </template>
    <template v-else-if="isCustom === 'evaluate'">
      <div class="evaluate">
        <h1>对本次服务评价</h1>
        <ul>
          <li class="evaluate-list-item" v-for="(item, index) in ~~payload.description" :key="index">
            <i class="icon icon-star-light"></i>
          </li>
        </ul>
        <article>{{data.custom}}</article>
      </div>
    </template>
    <template v-else>
      <span :class="['content content-' + message.flow]">{{data.custom}}</span>
    </template>
  </view>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';
const MessageCustom =  defineComponent({
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
      extension: {},
      isCustom: '',
      payload: {},
			message: {},
    });
    watchEffect(()=>{
      data.data = props.data;
			data.message = props.messageData;
      data.isCustom = props.data.message.payload.data;
      data.payload = props.data.message.payload;
      if (props.data.message.payload.data === 'consultion') {
        data.extension = JSON.parse(props.data.message.payload.extension);
      }
    });
    return {
      ...toRefs(data),
    };
  }
});
export default MessageCustom
</script>
<style lang="scss" scoped>
a {
  color: #679CE1;
}
.custom {
	padding: 12px 0;
	border-radius: 10px 0px 10px 10px;
  h1 {
    font-size: 0.75rem;
    color: #000000;
  }
  .evaluate {
    ul {
      display: flex;
      padding-top: 10px;
    }
  }
}
.content {
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
