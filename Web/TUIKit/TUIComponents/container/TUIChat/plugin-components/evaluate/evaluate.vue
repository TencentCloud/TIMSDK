<template>
  <div class="evaluate" :class="[isH5 && 'evaluate-H5']">
    <i class="icon icon-evaluate" title="服务评价" @click.stop="toggleShow"></i>
    <main class="evaluate-main" v-if="show && !isMute">
      <div class="evaluate-main-content" ref="dialog">
        <header>
          <aside>
            <h1>{{ $t('Evaluate.请对本次服务进行评价') }}</h1>
            <p v-if="isH5">
              {{ $t('Evaluate.服务评价工具') }}（{{ $t('Evaluate.使用')
              }}<a @click="openLink(Link.customMessage)">{{ $t(`Evaluate.${Link.customMessage.label}`) }}</a
              >{{ $t('Evaluate.搭建') }}）
            </p>
          </aside>
          <span v-if="isH5" class="close" @click.stop="toggleShow">关闭</span>
        </header>
        <div class="evaluate-content">
          <ul class="evaluate-list">
            <li
              class="evaluate-list-item"
              :class="[index < num && 'small-padding', isH5 && 'evaluate-item']"
              v-for="(item, index) in list"
              :key="index"
              @click.stop="select(item, index)"
            >
              <i class="icon icon-star-light" v-if="index < num"></i>
              <i class="icon icon-star" v-else></i>
            </li>
          </ul>
          <textarea v-model="options.data.comment"></textarea>
          <div class="evaluate-main-footer">
            <button class="btn" @click="submit">{{ $t('Evaluate.提交评价') }}</button>
          </div>
        </div>
        <footer v-if="!isH5">
          {{ $t('Evaluate.服务评价工具') }}（{{ $t('Evaluate.使用')
          }}<a @click="openLink(Link.customMessage)">{{ $t(`Evaluate.${Link.customMessage.label}`) }}</a
          >{{ $t('Evaluate.搭建') }}）
        </footer>
      </div>
    </main>
  </div>
</template>

<script lang="ts">
import TUIAegis from '../../../../../utils/TUIAegis';
import { onClickOutside } from '@vueuse/core';
import { defineComponent, reactive, watchEffect, toRefs, ref } from 'vue';
import Link from '../../../../../utils/link';
import constant from '../../../constant';
import { handleOptions } from '../../utils/utils';

const Evaluate = defineComponent({
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
  setup(props: any, ctx: any) {
    const data = reactive({
      link: 'https://web.sdk.qcloud.com/im/doc/zh-cn//SDK.html#createCustomMessage',
      list: 5,
      show: false,
      isMute: false,
      options: {
        data: {
          businessID: constant.typeEvaluate,
          version: 1,
          score: '',
          comment: '',
        },
        description: '对本次的服务评价',
        extension: '对本次的服务评价',
      },
      num: 0,
    });

    const dialog: any = ref();

    onClickOutside(dialog, () => {
      data.show = false;
    });

    watchEffect(() => {
      data.show = props.show;
      data.isMute = props.isMute;
    });

    const toggleShow = () => {
      data.show = !data.show;
      if (data.show) {
        data.options = {
          data: {
            ...handleOptions(constant.typeEvaluate, 1, { score: '', comment: '' }),
          },
          description: '对本次的服务评价',
          extension: '对本次的服务评价',
        };
        data.num = 0;
      }
    };

    const select = (item: any, index: number) => {
      data.num = index + 1;
      (data.options.data as any).score = `${data.num}`;
    };

    const submit = () => {
      Evaluate.TUIServer.sendCustomMessage(data.options);
      TUIAegis.getInstance().reportEvent({
        name: 'messageType',
        ext1: 'typeCustom',
      });
      toggleShow();
    };
    const openLink = (type: any) => {
      window.open(type.url);
      TUIAegis.getInstance().reportEvent({
        name: 'openLink',
        ext1: type.label,
      });
    };
    return {
      ...toRefs(data),
      toggleShow,
      select,
      submit,
      dialog,
      Link,
      openLink,
    };
  },
});
export default Evaluate;
</script>

<style lang="scss" scoped src="./style/index.scss"></style>
