<template>
    <div class="message-bubble" :class="[message.flow === 'in' ? '' : 'reverse']">
      <img
        class="avatar"
        :src="message?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
        onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
      <main class="message-area">
        <label class="name" v-if="message.flow === 'in'&& message.conversationType === 'GROUP'">
          {{message.nameCard || message.nick || message.from}}
        </label>
        <div :class="['content content-' + message.flow]" @click.prevent.right="toggleDialog">
          <slot />
        </div>
      </main>
      <label class="message-label fail" v-if="message.status === 'fail'">!</label>
      <label class="message-label" :class="[!message.isPeerRead && 'unRead']" v-if="message.conversationType === 'C2C' && message.flow !== 'in' && message.status === 'success'">
        <span v-if="!message.isPeerRead">{{$t('TUIChat.未读')}}</span>
        <template v-else>
          <template v-if="message.conversationType === 'GROUP'">
            {{message.readReceiptInfo.readCount + '人' + $t('TUIChat.已读')}}
          </template>
          <span v-else>{{$t('TUIChat.已读')}}</span>
        </template>
      </label>
      <div class="dialog" v-show="show" ref="dialog">
        <div class="dialog-main" @click="toggleDialog">
          <slot name="dialog" />
        </div>
        <div class="mask" @click="show=false" @click.prevent.right="show=false"></div>
      </div>
    </div>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs, ref } from 'vue';
import { useMouse } from '@vueuse/core';

const messageBubble = defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
  },
  setup(props:any, ctx:any) {
    const data = reactive({
      message: {},
      show: false,
    });

    const dialog:any = ref();

    const { x, y } = useMouse();

    watchEffect(() => {
      data.message = props.data;
    });

    const toggleDialog = (e:any) => {
      dialog.value.style.top = `${y.value}px`;
      dialog.value.style.left = `${x.value}px`;
      data.show = !data.show;
    };
    return {
      ...toRefs(data),
      toggleDialog,
      dialog,
    };
  },
});
export default messageBubble;
</script>
<style lang="scss" scoped>
.reverse {
  flex-direction: row-reverse;
  justify-content: flex-start;
}
.avatar {
  width: 36px;
  height: 36px;
  border-radius: 5px;
}
.message-bubble {
  width: 100%;
  display: flex;
}
.message-area {
  max-width: calc(100% - 67px);
  position: relative;
  display: flex;
  flex-direction: column;
  padding: 0 8px;
  .name {
    padding-bottom: 4px;
    font-weight: 400;
    font-size: 0.8rem;
    color: #999999;
    letter-spacing: 0;
  }
  .content {
    padding: 12px;
    font-weight: 400;
    font-size: 14px;
    color: #000000;
    letter-spacing: 0;
    word-wrap:break-word;
    word-break:break-all;
    &-in {
      background: #FBFBFB;
      border-radius: 0px 10px 10px 10px;
    }
    &-out {
      background: #DCEAFD;
      border-radius: 10px 0px 10px 10px;
    }
  }
}
.message-label {
  align-self: flex-end;
  font-family: PingFangSC-Regular;
  font-weight: 400;
  font-size: 12px;
  color: #B6B8BA;
  word-break: keep-all;
}
.fail {
  width: 15px;
  height: 15px;
  border-radius: 15px;
  background: red;
  color: #FFFFFF;
  display: flex;
  justify-content: center;
  align-items: center;
}
.unRead{
  color: #679CE1;
}
.dialog {
  position: fixed;
  background: #FFFFFF;
  border: 1px solid #dddddd;
  display: flex;
  border-radius: 8px;
  word-break: keep-all;
  z-index: 2;
  &-main {
    position: absolute;
    z-index: 5;
  }
  .mask {
    position: fixed;
    width: 100vw;
    height: 100vh;
    left: 0;
    top: 0;
  }
}
</style>
