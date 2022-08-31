<template>
  <template v-for="(item, index) in data.text" :key="index">
    <span class="text-box" v-if="item.name === 'text'">{{ item.text }}</span>
    <img class="text-img" v-else-if="item.name === 'img'" :src="item.src" />
  </template>
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
.text-box {
  white-space: pre-wrap;
}
</style>
