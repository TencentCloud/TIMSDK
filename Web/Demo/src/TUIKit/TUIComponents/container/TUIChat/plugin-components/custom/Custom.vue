<template>
  <div class="custom">
    <i class="icon icon-custom" @click="toggleShow"></i>
    <main class="custom-main"  v-if="show">
      <ul class="custom-list">
        <li  class="custom-list-item">
          <label>data</label>
          <input type="text" v-model="custom.data">
        </li>
        <li  class="custom-list-item">
          <label>description</label>
          <input type="text" v-model="custom.description">
        </li>
        <li  class="custom-list-item">
          <label>extension</label>
          <input type="text" v-model="custom.extension">
        </li>
      </ul>
      <ul class="custom-footer">
        <button class="btn btn-cancel" @click="cancel">{{$t('取消')}}</button>
        <button
          class="btn btn-default"
          :disabled="!custom.data && !custom.description && custom.extension"
          @click="submit">{{$t('发送')}}</button>
      </ul>
    </main>
    <div v-if="show" class="mask" @click.self="toggleShow"></div>
  </div>
</template>

<script lang="ts">
import TUIAegis from '../../../../../utils/TUIAegis';
import { defineComponent, reactive, watchEffect, toRefs } from 'vue';

const Custom = defineComponent({
  props: {
    show: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      show: false,
      custom: {
        data: '',
        description: '',
        extension: '',
      },
      TUIServer: null,
    });

    data.TUIServer = Custom.TUIServer;

    watchEffect(() => {
      data.show = props.show;
    });

    const toggleShow = () => {
      data.show = !data.show;
    };

    const cancel = () => {
      data.custom = {
        data: '',
        description: '',
        extension: '',
      };
      toggleShow();
    };

    const submit = () => {
      Custom.TUIServer.sendCustomMessage(data.custom);
      TUIAegis.getInstance().reportEvent({
        name: 'messageType',
        ext1: 'typeCustom',
      });
      cancel();
    };


    return {
      ...toRefs(data),
      toggleShow,
      cancel,
      submit,
    };
  },
});
export default Custom;
</script>

<style lang="scss" scoped>
.custom {
  display: inline-block;
  position: relative;
  &-main {
    position: absolute;
    z-index: 5;
    width: 315px;
    background: #ffffff;
    top: -180px;
    box-shadow: 0 2px 12px 0 rgba(0,0,0, .1);
    padding: 10px;
    display: flex;
    flex-direction: column;
  }
  &-list {
    flex: 1;
    display: flex;
    flex-direction: column;
    &-item {
      padding-bottom: 15px;
      label {
        width: 88px;
        font-size: 18px;
        padding: 0 20px;
        display: inline-block;
      }
      input {
        flex: 1;
        height: 24px;
        padding: 0 10px;
        border: 1px solid #dddddd;
        border-radius: 5px;
      }
    }
  }
  &-footer {
    display: flex;
    align-items: center;
    justify-content: space-around;
  }
}
.btn {
  padding: 8px 20px;
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
}
.mask {
  position: fixed;
  width: 100vw;
  height: 100vh;
  top: 0;
  left: 0;
  opacity: 0;
  z-index: 1;
}
</style>
