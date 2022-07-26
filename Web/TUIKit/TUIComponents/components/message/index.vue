<template>
  <transition
    name="fade"
    @before-leave="onClose"
    @after-leave="$emit('destroy')"
  >
  <div class="message" :style="customStyle" v-show="visible" :class="[isH5 && 'message-h5']">
    <p v-if="!isH5">{{message}}</p>
    <span v-if="isH5">{{message}}</span>
  </div>
  </transition>
</template>
<script lang="ts">
import { useTimeoutFn } from '@vueuse/core';
import { computed, CSSProperties, defineComponent, onMounted, ref, watch } from 'vue';
export default defineComponent({
  name: 'TUIMessage',
  props: {
    message: {
      type: String,
      default: '',
    },
    duration: {
      type: Number,
      default: 3000,
    },
    repeatNum: {
      type: Number,
      default: 1,
    },
    id: {
      type: String,
      default: '',
    },
    onClose: {
      type: Function,
      required: false,
    },
    offset: {
      type: Number,
      default: 20,
    },
    zIndex: {
      type: Number,
      default: 0,
    },
    isH5: {
      type: Boolean,
      default: false,
    },
  },
  setup(props) {
    const visible = ref(false);

    let stopTimer: (() => void) | undefined = undefined;

    function startTimer() {
      if (props.duration > 0) {
        ({ stop: stopTimer } = useTimeoutFn(() => {
          if (visible.value) close();
        }, props.duration));
      }
    }

    function clearTimer() {
      stopTimer?.();
    }

    function close() {
      visible.value = false;
    }

    watch(
      () => props.repeatNum,
      () => {
        clearTimer();
        startTimer();
      },
    );


    const customStyle = computed<CSSProperties>(() => ({
      top: `${props.offset}px`,
      zIndex: props.zIndex,
    }));

    onMounted(() => {
      startTimer();
      visible.value = true;
    });

    return {
      visible,
      customStyle,
    };
  },
});
</script>
<style lang="scss" scoped>
.message {
  position: fixed;
  left: 0;
  right: 0;
  margin: 0 auto;
  max-width: 450px;
  display: flex;
  justify-content: center;
  align-items: center;
  p {
    background: #FFFFFF;
    box-shadow: 0 2px 12px 0 rgba(0,0,0, .2);
    border-radius: 3px;
    padding: 5px 10px;
  }
}
.message-h5 {
  position: absolute;
  top: 300px !important;
  margin: 0 auto;
  max-width: 450px;
  display: flex;
  justify-content: center;
  align-items: center;
  border-radius: 5px;
  span {
    font-family: PingFangSC-Regular;
    font-weight: 400;
    font-size: 14px;
    color: #999999;
    letter-spacing: 0;
  }
}
</style>
