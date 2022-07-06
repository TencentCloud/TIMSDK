<template>
  <view v-if="visible" class="dialog" @click="handleClose">
    <view
      class="dialog-container"
      :style="styleConfig"
    >
      <slot />
    </view>
  </view>
</template>

<script>
import { defineComponent, watchEffect, watch, reactive, toRefs } from 'vue';
export default defineComponent({
  name: 'dialog',
  props: {
    visible: {
      type: Boolean,
      default: () => {
        return false;
      }
    },
    styleConfig: {
      type: Object,
      default: () => {
        return {
          width: '240px',
          // height: '120px',
          padding: '16px',
          top: '10px',
          right: '10px',
        };
      }
    },
    handleClose: {
      type: Function,
      default: () => {}
    }
  },
  setup(props, context) {
  },
});
</script>

<style lang="scss" scoped>
	.dialog {
    position: fixed;
    width: 100%;
    height: 100%;
    z-index: 9999;
    top: 0px;
    left: 0;
    background-color: rgba(255, 255, 255, 0.1);
    top: 0;
    right: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    &-container {
      position: absolute;
      width: 120px;
      border-radius: 10px;
      box-shadow: 0 0 10px 0 rgba(0,0,0,0.21);
      background-color: rgba(255, 255, 255, 1);
    }
  }
</style>