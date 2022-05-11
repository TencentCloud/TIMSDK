<template>
  <div class="dialog" v-if="show" @click.self="toggleView">
    <main class="dialog-main" :style="!background && {'background': 'none'}">
      <header v-if="isHeaderShow">
        <h1>{{title}}</h1>
        <i class="icon icon-close" @click="toggleView"></i>
      </header>
      <div class="dialog-main-content">
        <slot />
      </div>
      <footer v-if="isFooterShow">
        <button class="btn btn-cancel" @click="toggleView">{{$t('component.取消')}}</button>
        <button class="btn btn-default" @click="submit">{{$t('component.确定')}}</button>
      </footer>
    </main>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs } from 'vue';

export default defineComponent({
  props: {
    show: {
      type: Boolean,
      default: () => false,
    },
    isHeaderShow: {
      type: Boolean,
      default: () => true,
    },
    isFooterShow: {
      type: Boolean,
      default: () => true,
    },
    background: {
      type: Boolean,
      default: () => true,
    },
    title: {
      type: String,
      default: () => '',
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      show: false,
      isHeaderShow: true,
      isFooterShow: true,
      background: true,
      title: '',
    });

    watchEffect(() => {
      data.show = props.show;
      data.title = props.title;
      data.isHeaderShow = props.isHeaderShow;
      data.isFooterShow = props.isFooterShow;
      data.background = props.background;
    });

    const toggleView = () => {
      data.show = !data.show;
      ctx.emit('update:show', data.show);
    };

    const submit = () => {
      ctx.emit('submit');
      toggleView();
    };

    return {
      ...toRefs(data),
      toggleView,
      submit,
    };
  },
});
</script>

<style lang="scss" scoped>
.dialog {
  position: fixed;
  width: 100vw;
  height: calc(100vh - 62px);
  top: 62px;
  left: 0;
  background: rgba(0 ,0, 0, .3);
  z-index: 1;
  display: flex;
  justify-content: center;
  align-items: center;
  header {
    h1 {
      font-family: PingFangSC-Medium;
      font-weight: 500;
      font-size: 16px;
      color: #333333;
      line-height: 30px;
    }
  }
  &-main {
    min-width: 368px;
    background: #FFFFFF;
    border-radius: 10px;
    padding: 20px 30px;
    header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-weight: 500;
      font-size: 16px;
      color: #333333;
      line-height: 30px;
    }
    &-content {
      padding: 20px 0 40px;
      font-weight: 400;
      font-size: 14px;
      color: #333333;
    }
    footer {
      display: flex;
      justify-content: flex-end;
    }
  }
}
.btn {
  padding: 8px 20px;
  margin: 0 6px;
  border-radius: 4px;
  border: none;
  font-weight: 400;
  font-size: 14px;
  color: #FFFFFF;
  letter-spacing: 0;
  text-align: center;
  line-height: 20px;
  &-cancel {
    border: 1px solid #dddddd;
    color: #666666;
  }
  &-default {
    background: #006EFF;
    border: 1px solid #006EFF;
  }
  &:disabled {
    opacity: 0.3;
  }
  &:last-child {
    margin-right: 0;
  }
}
</style>
