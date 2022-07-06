<template>
    <div class="message-tip">{{message.text}}</div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';

const MessageTip =  defineComponent({
  props: {
    data: {
      type: Object,
      default: () => {
        return {};
      }
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      message: {},
    });

    watchEffect(()=>{
      data.message = props.data;
    });

    return {
      ...toRefs(data),
    };
  }
});
export default MessageTip
</script>
<style lang="scss" scoped>
.message-tip {
  margin: 8px auto 0;
  color: #999999;
	font-size: 13px;
	text-align: center;
}
</style>
