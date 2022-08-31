<template>
  <div class="message-video">
    <div
      class="message-video-box"
      :class="[!data.progress && data.message.status === 'success' && 'message-video-cover']"
      @click="toggleShow"
    >
      <img
        class="message-img"
        :class="[isWidth ? 'isWidth' : 'isHeight']"
        :src="data.snapshotUrl"
        alt=""
        v-if="data.snapshotUrl && !data.progress"
      />
      <video v-else :src="data.url"></video>
      <div class="progress" v-if="data.progress">
        <progress :value="data.progress" max="1"></progress>
      </div>
    </div>
    <div class="dialog-video" v-if="show" @click.self="toggleShow">
      <header v-if="!isH5">
        <i class="icon icon-close" @click.stop="toggleShow"></i>
      </header>
      <div class="dialog-video-box" :class="[isH5 ? 'dialog-video-h5' : '']" @click.self="toggleShow">
        <video :class="[isWidth ? 'isWidth' : 'isHeight']" :src="data.url" controls autoplay></video>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs, computed } from 'vue';

export default defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
    isH5: {
      type: Boolean,
      default: false,
    },
  },
  setup(props: any, ctx: any) {
    const data = reactive({
      data: {},
      show: false,
    });

    watchEffect(() => {
      data.data = props.data;
    });

    const isWidth = computed(() => {
      const { snapshotWidth = 0, snapshotHeight = 0 } = (data.data as any)?.message?.payload;
      return snapshotWidth >= snapshotHeight;
    });

    const toggleShow = () => {
      if (!(data.data as any).progress) {
        data.show = !data.show;
      }
    };

    return {
      ...toRefs(data),
      toggleShow,
      isWidth,
    };
  },
});
</script>
<style lang="scss" scoped>
.message-video {
  position: relative;
  &-box {
    max-width: min(calc(100vw - 180px), 300px);
    video {
      max-width: min(calc(100vw - 180px), 300px);
      max-height: min(calc(100vw - 180px), 300px);
    }
    img {
      max-width: min(calc(100vw - 180px), 300px);
      max-height: min(calc(100vw - 180px), 300px);
    }
  }
  &-cover {
    display: inline-block;
    position: relative;
    &::before {
      position: absolute;
      z-index: 1;
      content: '';
      width: 0px;
      height: 0px;
      border: 15px solid transparent;
      border-left: 20px solid #ffffff;
      top: 0;
      left: 0;
      bottom: 0;
      right: 0;
      margin: auto;
    }
    video {
      max-width: 300px;
    }
  }

  .progress {
    position: absolute;
    box-sizing: border-box;
    width: 100%;
    height: 100%;
    padding: 0 20px;
    left: 0;
    top: 0;
    background: rgba(#000000, 0.5);
    display: flex;
    align-items: center;
    progress {
      color: #006eff;
      appearance: none;
      border-radius: 0.25rem;
      background: rgba(#ffffff, 1);
      width: 100%;
      height: 0.5rem;
      &::-webkit-progress-value {
        background-color: #006eff;
        border-radius: 0.25rem;
      }
      &::-webkit-progress-bar {
        border-radius: 0.25rem;
        background: rgba(#ffffff, 1);
      }
      &::-moz-progress-bar {
        color: #006eff;
        background: #006eff;
        border-radius: 0.25rem;
      }
    }
  }
}
.dialog-video {
  position: fixed;
  z-index: 12;
  width: 100vw;
  height: calc(100vh - 62px);
  background: rgba(#000000, 0.3);
  top: 62px;
  left: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  header {
    display: flex;
    justify-content: flex-end;
    background: rgba(0, 0, 0, 0.49);
    width: 100%;
    box-sizing: border-box;
    padding: 10px 10px;
  }
  &-box {
    display: flex;
    flex: 1;
    max-height: 100%;
    padding: 6rem;
    box-sizing: border-box;
    justify-content: center;
    align-items: center;
    video {
      max-width: 100%;
      max-height: 100%;
    }
  }
}
.dialog-video-h5 {
  width: 100%;
  height: 100%;
  background: #000000;
  padding: 30px 0;
}

.isWidth {
  width: 100%;
}
.isHeight {
  height: 100%;
}
</style>
