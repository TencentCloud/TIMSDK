<template>
  <div class="custom">
    <template v-if="isCustom === 'consultion'">
      <div>
        <h1>
          <label>{{extension.title}}</label>
          <a v-if="extension.hyperlinks_text" :href="extension.hyperlinks_text.value" target="view_window">{{extension.hyperlinks_text.key}}</a>
        </h1>
        <ul v-if="extension.item && extension.item.length>0">
          <li v-for="(item, index) in extension.item" :key="index">
            <a v-if="isUrl(item.value)" :href="item.value" target="view_window">{{item.key}}</a>
            <p v-else>{{item.key}}</p>
          </li>
        </ul>
        <article>{{extension.description}}</article>
      </div>
    </template>
    <template v-else-if="isCustom === 'evaluate'">
      <div class="evaluate">
        <h1>{{$t('message.custom.对本次服务评价')}}</h1>
        <ul>
          <li class="evaluate-list-item" v-for="(item, index) in ~~payload.description" :key="index">
            <i class="icon icon-star-light"></i>
          </li>
        </ul>
        <article>{{data.custom}}</article>
      </div>
    </template>
    <template v-else>
      <span v-html="data.custom"></span>
    </template>
  </div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';
import { isUrl } from '../untils/untis';

export default defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      data: {},
      extension: {},
      isCustom: '',
      payload: {},
    });

    watchEffect(() => {
      data.data = props.data;
      data.isCustom = props.data.message.payload.data;
      data.payload = props.data.message.payload;
      if (props.data.message.payload.data === 'consultion') {
        data.extension = JSON.parse(props.data.message.payload.extension);
      }
    });
    return {
      ...toRefs(data),
      isUrl,
    };
  },
});
</script>
<style lang="scss" scoped>
a {
  color: #679CE1;
}
.custom {
  font-size: 14px;
  h1 {
    font-size: 14px;
    color: #000000;
  }
  h1,a,p {
    font-size: 14px;
  }
  .evaluate {
    ul {
      display: flex;
      padding-top: 10px;
    }
  }
}
</style>
