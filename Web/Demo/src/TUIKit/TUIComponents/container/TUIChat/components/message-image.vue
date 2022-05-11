<template>
  <div class="message-image">
    <img class="message-img" :src="data.url"  @click="toggleShow" />
    <div class="progress"  v-if="data.progress">
      <progress :value="data.progress" max="1"></progress>
    </div>
    <div class="dialog" v-if="show" @click.self="toggleShow">
      <header><i class="icon icon-close" @click.stop="toggleShow"></i></header>
      <div class="dialog-box" @click.self="toggleShow">
        <img :src="data.message.payload.imageInfoArray[0].url">
      </div>
    </div>
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

    const toggleShow = () => {
      if (!data.data.progress) {
        data.show = !data.show;
      }
    };

    return {
      ...toRefs(data),
      toggleShow,
    };
  },
});
</script>
<style lang="scss" scoped>
.message-image {
  position: relative;
  img {
    max-width: 200px;
    max-height: 300px;
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
    img {
      max-width: 100%;
      max-height: 100%;
    }
  }
}
</style>
