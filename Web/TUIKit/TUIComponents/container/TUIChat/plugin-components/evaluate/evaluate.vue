<template>
  <div class="evaluate">
      <i class="icon icon-evaluate" title="服务评价" @click="toggleShow"></i>
      <main class="evaluate-main"  v-if="show&&!isMute" ref="dialog">
        <header>{{$t('Evaluate.请对本次服务进行评价')}}</header>
        <div class="evaluate-content">
          <ul class="evaluate-list">
            <li class="evaluate-list-item" :class="[index < num && 'small-padding']" v-for="(item, index) in list" :key="index"  @click="select(item, index)">
              <i class="icon icon-star-light" v-if="index < num"></i>
              <i class="icon icon-star" v-else></i>
            </li>
          </ul>
          <textarea v-model="options.extension"></textarea>
          <div>
          <button class="btn" @click="submit">{{$t('Evaluate.提交评价')}}</button>
          </div>
        </div>
        <footer>{{$t('Evaluate.服务评价工具')}}（{{$t('Evaluate.使用')}}<a @click="openLink(Link.customMessage)">{{$t(`Evaluate.${Link.customMessage.label}`)}}</a>{{$t('Evaluate.搭建')}}）</footer>
      </main>
  </div>
</template>

<script lang="ts">
import { onClickOutside } from '@vueuse/core';
import { defineComponent, reactive, watchEffect, toRefs, ref } from 'vue';
import Link from '../../../../../utils/link';

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
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      link: 'https://web.sdk.qcloud.com/im/doc/zh-cn//SDK.html#createCustomMessage',
      list: 5,
      show: false,
      isMute: false,
      options: {
        data: 'evaluate',
        description: '',
        extension: '',
      },
      num: 0,
    });

    const dialog:any = ref();

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
          data: 'evaluate',
          description: '',
          extension: '',
        };
        data.num = 0;
      }
    };

    const select = (item:any, index:number) => {
      data.num = index + 1;
      data.options.description = `${data.num}`;
    };

    const submit = () => {
      Evaluate.TUIServer.sendCustomMessage(data.options);
      toggleShow();
    };
    const openLink = (type:any) => {
      window.open(type.url);
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

<style lang="scss" scoped>
.evaluate {
  display: inline-block;
  position: relative;
  cursor: pointer;
  .icon-evaluate {
     margin: 12px 10px 0;
  }
  &-main {
    position: absolute;
    z-index: 5;
    width: 315px;
    background: #ffffff;
    top: -275px;
    box-shadow: 0 2px 12px 0 rgba(0,0,0, .1);
    padding: 12px;
    display: flex;
    flex-direction: column;
    header {
      font-weight: 500;
      font-size: 12px;
      color: #1C1C1C;
      text-align: center;
    }
    footer {
      font-weight: 500;
      font-size: 12px;
      color: #999999;
      text-align: center;
      a {
        color: #006EFF;
      }
    }
  }
  &-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 12px 0;
    background: url('https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/im/assets/images/login-background.png') no-repeat;
    background-size: cover;
    background-position-x: 128px;
    background-position-y: 77px;
    textarea {
      box-sizing: border-box;
      width: 288px;
      height: 90px;
      margin: 12px 0;
      padding: 12px;
      background: #F8F8F8;
      border: 1px solid #ECECEC;
      border-radius: 2px;
      resize: none;
    }
    .btn {
      background: #3370FF;
      border: none;
      border-radius: 5px;
      font-weight: 400;
      font-size: 12px;
      color: #FFFFFF;
      text-align: center;
      line-height: 24px;
      padding: 2px 46px;
      cursor: pointer;
    }
  }
  &-list {
    flex: 1;
    display: flex;
    &-item {
      width: 24px;
      height: 24px;
      text-align: center;
      cursor: pointer;
      padding: 4px 0;
      font-weight: 400;
      font-size: 12px;
      color: #50545C;
      padding-right: 15px;
      &:last-child{
        padding-right: 0 !important;
      }
    }
  }
}
</style>
