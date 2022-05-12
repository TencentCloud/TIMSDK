<template>
  <a class="message-location" :href="data.href" target="_blank" title="点击查看详情">
    <span class="el-icon-location-outline">{{data.description}}</span>
    <img :src="data.url" />
  </a>
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
      data: {},
    });

    watchEffect(() => {
      data.data = props.data;
    });

    return {
      ...toRefs(data),
    };
  },
});
</script>
<style lang="scss" scoped>
.message-location {
  display: flex;
  flex-direction: column;
}
</style>
