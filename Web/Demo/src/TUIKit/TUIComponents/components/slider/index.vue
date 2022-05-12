<template>
  <div class="slider-box" :class="[open && 'slider-open']" @click="toggle">
    <span class="slider-block"></span>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs } from 'vue';

export default defineComponent({
  props: {
    open: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      open: false,
    });

    watchEffect(() => {
      data.open = props.open;
    });


    const toggle = () => {
      data.open = !data.open;
      ctx.emit('change', data.open);
    };

    return {
      ...toRefs(data),
      toggle,
    };
  },
});
</script>

<style lang="scss" scoped>
.slider {
  &-box {
    display: flex;
    align-items: center;
    width: 34px;
    height: 20px;
    border-radius: 10px;
    background: #E1E1E3;
  }
  &-open {
    background: #006EFF !important;
    justify-content: flex-end;
  }
  &-block {
    display: inline-block;
    width: 16px;
    height: 16px;
    border-radius: 8px;
    margin: 0 2px;
    background: #FFFFFF;
    border: 0 solid rgba(0,0,0,0.85);
    box-shadow: 0 2px 4px 0 #D1D1D1;
  }
}
</style>
