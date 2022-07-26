<template>
  <div class="words" :class="[isH5 ? 'words-H5' : '']">
      <i class="icon icon-words" title="快速回复" @click="toggleShow"></i>
      <main class="words-main" :class="[isH5 ? 'words-H5-main' : '']" v-show="show&&!isMute">
        <div class="words-main-content" ref="dialog">
          <header>
            <aside>
              <h1>{{$t('Words.常用语-快捷回复工具')}}</h1>
            </aside>
            <span v-if="isH5" class="close" @click="toggleShow">关闭</span>
          </header>
          <ul class="words-list">
            <li class="words-list-item" v-for="(item, index) in list" :key="index"  @click="select(item)">
              <label>{{item.value}}</label>
            </li>
          </ul>
        </div>
      </main>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs, watch, ref } from 'vue';
import { useI18nLocale  } from '../../../../../TUIPlugin/TUIi18n';
import { onClickOutside } from '@vueuse/core';

const Words = defineComponent({
  type: 'custom',
  props: {
    show: {
      type: Boolean,
      default: () => false,
    },
    isMute: {
      type: Boolean,
      default: () => false,
    },
    isH5: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props:any, ctx:any) {
    const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
    const list:any = [
      {
        value: '在吗？在吗？在吗？重要的话说三遍。',
      },
      {
        value: '好久没聊天了，快来和我说说话～',
      },
      {
        value: '好的，就这么说定了。',
      },
      {
        value: '感恩的心，感谢有你。',
      },
      {
        value: '糟糕！是心动的感觉！',
      },
      {
        value: '心疼地抱抱自己，我太难了！',
      },
      {
        value: '没关系，别在意，事情过去就过去了。',
      },
      {
        value: '早上好，今天也是让人期待的一天呢！',
      },
      {
        value: '熬夜有什么用，又没人陪你聊天，早点休息吧。',
      },
    ];
    const data = reactive({
      list: [],
      show: false,
      isMute: false,
      locale: useI18nLocale(),
    });

    const dialog:any = ref();

    watch(() => data.locale, (newVal:any, oldVal:any) => {
      data.list = list.map((item:any) => ({
        value: t(`Words.${item.value}`),
      }));
    });

    watchEffect(() => {
      data.show = props.show;
      data.isMute = props.isMute;
    });

    const toggleShow = () => {
      data.show = !data.show;
      if (data.show) {
        data.list = list.map((item:any) => ({
          value: t(`Words.${item.value}`),
        }));
      }
    };

    onClickOutside(dialog, () => {
      data.show = false;
    });

    const select = (item:any, index?:number) => {
      const text = item.value;
      toggleShow();
      Words.TUIServer.sendTextMessage(text);
    };
    return {
      ...toRefs(data),
      toggleShow,
      select,
      dialog,
    };
  },
});
export default Words;
</script>
<style lang="scss" scoped src="./style/index.scss"></style>
