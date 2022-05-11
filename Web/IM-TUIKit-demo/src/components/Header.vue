<template>
  <header class="header">
    <aside class="left">
      <slot name="left" />
    </aside>
    <main class="content">
      <slot name="content" />
    </main>
    <aside class="right">
      <slot name="right" />
    </aside>
  </header>
</template>

<script lang="ts">
import { defineComponent, reactive, toRefs, watchEffect } from 'vue';

export default defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
  },

  setup(props:any, ctx:any) {
    const obj = reactive({
      data: {},
    });

    watchEffect(() => {
      obj.data = props.data;
    });

    const handleListItem = (item: any) => {
      ctx.emit('handleItem', item);
    };


    return {
      ...toRefs(obj),
      handleListItem,
    };
  },
});
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: #ffffff;
  box-sizing: border-box;
  padding: 20px 34px;
}
</style>
