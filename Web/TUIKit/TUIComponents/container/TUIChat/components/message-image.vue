<template>
  <div class="message-image">
    <img class="message-img" :class="[isWidth ? 'isWidth' : 'isHeight']" :src="data.url"  @click="toggleShow" />
    <div class="progress"  v-if="data.progress">
      <progress :value="data.progress" max="1"></progress>
    </div>
    <div class="dialog" v-if="show" @click.self="toggleShow">
      <header v-if="!isH5"><i class="icon icon-close" @click.stop="toggleShow"></i></header>
      <div class="dialog-box" :class="[isH5 ? 'dialog-box-h5' : '']" @click.self="toggleShow">
        <img :class="[isWidth ? 'isWidth' : 'isHeight']"  :src="data.message.payload.imageInfoArray[0].url" @click.self="toggleShow">
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
  setup(props:any, ctx:any) {
    const data = reactive({
      data: {
        progress: 0,
      },
      show: false,
    });

    watchEffect(() => {
      data.data = props.data;
    });

    const isWidth = computed(() => {
      const { width = 0, height = 0 } = (data.data as any)?.message?.payload?.imageInfoArray[0];
      return width >= height;
    });

    const toggleShow = () => {
      if (!data.data.progress) {
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
.message-image {
  position: relative;
  .message-img{
    max-width: 300px;
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
      width: 100%;
    }
  }
}
.dialog {
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
    background: rgba(0,0,0,0.49);
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
  }
}
.dialog-box-h5 {
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
