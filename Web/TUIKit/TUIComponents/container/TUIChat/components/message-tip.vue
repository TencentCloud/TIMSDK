<template>
    <div class="message-tip">{{message.text}}</div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';

export default defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      message: {},
    });

    watchEffect(() => {
      data.message = props.data;
    });

    return {
      ...toRefs(data),
    };
  },
});
</script>
<style lang="scss" scoped>
.message-tip {
  margin: 0 auto;
  color: #999999;
  font-size: 14px;
}
</style>
