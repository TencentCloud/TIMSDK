<template>
  <div class="dialog" :class="[isH5 ? 'dialog-h5' : '', center ? 'center' : '']" v-if="show" @click.self="toggleView">
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
    isH5: {
      type: Boolean,
      default: () => false,
    },
    center: {
      type: Boolean,
      default: () => false,
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
<style lang="scss" scoped src="./style/dialog.scss"></style>
