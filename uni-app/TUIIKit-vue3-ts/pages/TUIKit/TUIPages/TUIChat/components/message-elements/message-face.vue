<template>
  <image class="message-image" :src="data.url"></image>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';

const MessageFace =  defineComponent({
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
      data: {}
    });

    watchEffect(()=>{
      data.data = props.data;
    });
    return {
      ...toRefs(data),
    };
  }
});
export default MessageFace
</script>
<style lang="scss" scoped>
.text-img {
  width: 20px;
  height: 20px;
}
.message-image {
	width: 80px;
	height: 80px;
}
</style>
