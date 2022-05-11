<template>
  <div class="location">
    <i class="icon icon-location" @click="toggleShow"></i>
    <main class="location-main"  v-if="show">
      <ul class="location-list">
        <li  class="location-list-item">
          <label>{{$t('TUIChat.描述')}}</label>
          <input type="text" v-model="location.description">
        </li>
        <li  class="location-list-item">
          <label>{{$t('TUIChat.经度')}}</label>
          <input type="number" v-model="location.longitude">
        </li>
        <li  class="location-list-item">
          <label>{{$t('TUIChat.纬度')}}</label>
          <input type="number" v-model="location.latitude">
        </li>
      </ul>
      <ul class="location-footer">
        <button class="btn btn-cancel" @click="cancel">{{$t('取消')}}</button>
        <button
          class="btn btn-default"
          :disabled="!location.data && !location.description && location.extension"
          @click="submit">{{$t('发送')}}</button>
      </ul>
    </main>
    <div v-if="show" class="mask" @click.self="toggleShow"></div>
  </div>
</template>

<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs } from 'vue';

const Location = defineComponent({
  props: {
    show: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      show: false,
      location: {
        description: '深圳市深南大道10000号腾讯大厦',
        longitude: 113.941079,
        latitude: 22.546103,
      },
    });


    watchEffect(() => {
      data.show = props.show;
    });

    const toggleShow = () => {
      data.show = !data.show;
    };


    const cancel = () => {
      toggleShow();
    };

    const submit = () => {
      Location.TUIServer.sendLocationMessage(data.location);
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
export default Location;
</script>

<style lang="scss" scoped>
.location {
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
        &::-webkit-inner-spin-button {
          display: none;
        }
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
