<template>
  <div class="message-image">
    <img class="message-img" :src="data.url" />
  </div>
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
  setup(props: any, ctx: any) {
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
.text-img {
  width: 20px;
  height: 20px;
}
.message-img {
  max-width: min(calc(100vw - 180px), 300px);
  max-height: min(calc(100vw - 180px), 300px);
}
</style>
