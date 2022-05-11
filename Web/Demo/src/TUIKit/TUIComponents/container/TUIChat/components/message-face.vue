<template>
  <img class="message-image" :src="data.url">
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
.text-img {
  width: 20px;
  height: 20px;
}
</style>
