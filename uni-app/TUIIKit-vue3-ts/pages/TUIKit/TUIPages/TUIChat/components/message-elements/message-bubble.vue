<template>
  <view class="message-bubble" :class="[message.flow === 'in' ? '' : 'reverse']">
    <image class="avatar" :src="message?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
      alt=""></image>
    <view class="message-area">
      <label class="name" v-if="message.flow === 'in'">{{ message.nick }}</label>
      <div :class="['content content-' + message.flow]">
        <slot />
      </div>
    </view>
    <view class="message-label fail" v-if="message.status === 'fail'">!</view>
    <view class="message-label" :class="[!message.isPeerRead && 'unRead']"
      v-if="message.conversationType === 'C2C' && message.flow == 'out' && message.status !== 'fail'">
      <span v-if="!message.isPeerRead">未读</span>
      <span v-else>已读</span>
    </view>
  </view>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs, computed } from 'vue';

const messageBubble = defineComponent({
  props: {
    data: {
      type: Object,
      default: () => {
        return {};
      }
    },
  },
  setup(props: any, ctx: any) {
    const data = reactive({
      message: {},
      show: false,
    });

    watchEffect(() => {
      data.message = props.data;
    });

    const toggleDialog = () => {
      data.show = !data.show;
    };

    return {
      ...toRefs(data),
      toggleDialog,
    };
  }
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
  padding: 8px;
  box-sizing: border-box;
}

.message-area {
	max-width: 74%;
  display: flex;
  flex-direction: column;
  padding: 0 8px;
  word-break: break-all;

  .name {
    font-weight: 400;
    font-size: 12px;
    color: #999999;
    letter-spacing: 0;
  }

  .content {
    // padding: 12px;
    font-weight: 400;
    font-size: 14px;
    color: #000000;
    letter-spacing: 0;
    position: relative;
    font-family: PingFangSC-Regular;

    &-in {
      // background: #FBFBFB;
      border-radius: 0px 10px 10px 10px;
    }

    &-out {
      // background: #DCEAFD;
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

.unRead {
  color: #679CE1;
}
</style>
