<template>
  <div class="words">
      <i class="icon icon-words" title="快速回复" @click="toggleShow"></i>
      <main class="words-main"  v-if="show&&!isMute" ref="dialog">
        <header>{{$t('Words.常用语-快捷回复工具')}}（{{$t('Words.使用')}}<a  @click="openLink(Link.customMessage)">{{$t(`Words.${Link.customMessage.label}`)}}</a>{{$t('Words.搭建')}}）</header>
        <ul class="words-list">
          <li class="words-list-item" v-for="(item, index) in list" :key="index"  @click="select(item)">
            {{item.value}}
          </li>
        </ul>
      </main>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs, watch, ref } from 'vue';
import { useI18nLocale  } from '../../../../../TUIPlugin/TUIi18n';
import { onClickOutside } from '@vueuse/core';
import Link from '../../../../../utils/link';

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
      link: 'https://web.sdk.qcloud.com/im/doc/zh-cn//SDK.html#createCustomMessage',
      list: [],
      show: false,
      isMute: false,
      locale: useI18nLocale(),
    });

    const dialog:any = ref();

    onClickOutside(dialog, () => {
      data.show = false;
    });

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

    const select = (item:any, index?:number) => {
      const options:any = {
        data: 'words',
        description: item.value,
        extension: item.value,
      };
      toggleShow();
      Words.TUIServer.sendCustomMessage(options);
    };
    const openLink = (type:any) => {
      window.open(type.url);
    };
    return {
      ...toRefs(data),
      toggleShow,
      select,
      dialog,
      Link,
      openLink,
    };
  },
});
export default Words;
</script>

<style lang="scss" scoped>
.words {
  display: inline-block;
  position: relative;
  cursor: pointer;
  .icon {
    margin: 12px 10px 0;
  }
  &-main {
    position: absolute;
    z-index: 5;
    width: 315px;
    background: #ffffff;
    top: -200px;
    box-shadow: 0 2px 12px 0 rgba(0,0,0, .1);
    padding: 12px;
    display: flex;
    flex-direction: column;
    width: 19.13rem;
    height: 12.44rem;
    overflow-y: auto;
    header {
      font-weight: 500;
      font-size: 12px;
      color: #000000;
      padding-bottom: 4px;
      a {
        color: #006EFF;
      }
    }
  }
  &-list {
    flex: 1;
    display: flex;
    flex-direction: column;
    &-item {
      cursor: pointer;
      padding: 4px 0;
      font-weight: 400;
      font-size: 12px;
      color: #50545C;
      &:hover {
        color: #006EFF;
      }
    }
  }
}
</style>
