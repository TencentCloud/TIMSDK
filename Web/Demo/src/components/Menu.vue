<template>
  <div class="menu">
    <slot name="header" />
    <slot name="main" />
    <slot name="footer" />
  </div>
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

    return {
      ...toRefs(obj),
    };
  },
});
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="scss">
.menu {
  display: flex;
  flex-direction: column;
  background: #FFFFFF;
  box-shadow: 10px 20px 30px 0 rgba(56,73,90,0.09);
}
</style>
