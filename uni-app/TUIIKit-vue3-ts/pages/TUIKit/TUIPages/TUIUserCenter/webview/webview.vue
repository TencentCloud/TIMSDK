<template>
  <view class="page">
    <web-view class="web-view" :src="url"></web-view>
  </view>
</template>

<script>
import { defineComponent, reactive, toRefs } from 'vue';
import { onLoad } from '@dcloudio/uni-app';

export default defineComponent({
  setup(props) {
    const data = reactive({
      url: '',
      title: '',
    });

    onLoad((options) => {
      data.url = options && options.url || '';
      data.title = options && options.nav || '';
    });

    return {
      ...toRefs(data),
    }
  }
});
</script>
<style>
@import "./webview.css";
</style>