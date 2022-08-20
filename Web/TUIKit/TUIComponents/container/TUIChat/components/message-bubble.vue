<template>
  <div class="message-bubble" :class="[message.flow === 'in' ? '' : 'reverse']" ref="htmlRefHook">
    <img
      class="avatar"
      :src="message?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
      onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
    />
    <main class="message-area">
      <label class="name" v-if="message.flow === 'in' && message.conversationType === 'GROUP'">
        {{ message.nameCard || message.nick || message.from }}
      </label>
      <div :class="['content content-' + message.flow]" @click.prevent.right="toggleDialog">
        <slot />
        <div v-if="dropdown" ref="dropdownRef" class="dropdown-inner" @click="toggleDialog">
          <div class="dialog" :class="[message.flow === 'in' ? '' : 'dialog-right']">
            <slot name="dialog" />
          </div>
        </div>
      </div>
    </main>
    <label class="message-label fail" v-if="message.status === 'fail'" @click="resendMessage(message)">!</label>
    <label
      class="message-label"
      :class="readReceiptStyle(message)"
      v-if="showReadReceiptTag(message)"
      @click="showReadReceiptDialog(message)"
    >
      <span>{{ readReceiptCont(message) }}</span>
    </label>
  </div>
  <div
    class="message-reference-area"
    :class="[message.flow === 'in' ? '' : 'message-reference-area-reverse']"
    v-if="message.cloudCustomData && referenceMessage"
    @click="jumpToAim(referenceMessage)"
  >
    <div
      v-if="referenceMessage?.messageID && allMessageID.indexOf(referenceMessage.messageID) !== -1"
      class="message-reference-area-show"
    >
      <p>{{ referenceForShow.nick || referenceForShow.from }}:</p>
      <div class="face-box" v-if="referenceMessage.messageType === type.typeText">
        <div v-for="(item, index) in face" :key="index">
          <span class="text-box" v-if="item.name === 'text'">{{ item.text }}</span>
          <img class="text-img" v-else-if="item.name === 'img'" :src="item.src" />
        </div>
      </div>
      <span v-if="referenceMessage.messageType === type.typeCustom">{{ referenceMessage.messageAbstract }}</span>
      <img
        v-if="referenceMessage.messageType === type.typeImage"
        class="message-img"
        :src="referenceForShow.payload.imageInfoArray[1].url"
      />
      <div
        v-if="referenceMessage.messageType === type.typeAudio"
        class="message-audio"
        :class="[message.flow === 'out' && 'reserve']"
      >
        <label>{{ referenceForShow.payload.second }}s</label>
        <i class="icon icon-voice"></i>
      </div>
      <div v-if="referenceMessage.messageType === type.typeVideo" class="message-video-cover">
        <img class="message-videoimg" :src="referenceForShow.payload.snapshotUrl" />
      </div>
      <img v-if="referenceMessage.messageType === type.typeFace" class="message-img" :src="url" />
    </div>
    <div v-else class="message-reference-area-show">
      <span>{{ referenceMessage?.messageSender }}</span>
      <span>{{ referenceMessage?.messageAbstract }}</span>
    </div>
  </div>
</template>

<script lang="ts">
import { decodeText } from '../utils/decodeText';
import constant from '../../constant';
import { defineComponent, watchEffect, reactive, toRefs, ref, nextTick } from 'vue';
import { onClickOutside, onLongPress, useElementBounding } from '@vueuse/core';
import { JSONToString } from '../utils/utils';
import { handleErrorPrompts } from '../../utils';
import TUIChat from '../index.vue';

const messageBubble = defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
    messagesList: {
      type: Object,
      default: () => ({}),
    },
    isH5: {
      type: Boolean,
      default: false,
    },
    needGroupReceipt: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['jumpID', 'resendMessage', 'showReadReceiptDialog'],
  setup(props: any, ctx: any) {
    const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
    const { TUIServer } = TUIChat;
    const data = reactive({
      message: {},
      messagesList: {},
      show: false,
      type: {},
      referenceMessage: {},
      referenceForShow: {},
      allMessageID: '',
      needGroupReceipt: false,
      face: [],
      url: '',
    });

    watchEffect(() => {
      data.type = constant;
      data.message = props.data;
      data.messagesList = props.messagesList;
      data.needGroupReceipt = props.needGroupReceipt;
      if ((data.message as any).cloudCustomData) {
        const messageIDList: any[] = [];
        const cloudCustomData = JSONToString((data.message as any).cloudCustomData);
        data.referenceMessage = cloudCustomData.messageReply ? cloudCustomData.messageReply : '';
        for (let index = 0; index < (data.messagesList as any).length; index++) {
          // To determine whether the referenced message is still in the message list, the corresponding field of the referenced message is displayed if it is in the message list. Otherwise, messageabstract/messagesender is displayed
          messageIDList.push((data.messagesList as any)[index].ID);
          (data as any).allMessageID = JSON.stringify(messageIDList);
          if ((data.messagesList as any)[index].ID === (data.referenceMessage as any)?.messageID) {
            data.referenceForShow = (data.messagesList as any)[index];
            if ((data.referenceMessage as any).messageType === constant.typeText) {
              (data as any).face = decodeText((data.referenceForShow as any).payload);
            }
            if ((data.referenceMessage as any).messageType === constant.typeFace) {
              (data as any).url = `https://web.sdk.qcloud.com/im/assets/face-elem/${
                (data.referenceForShow as any).payload.data
              }@2x.png`;
            }
          }
        }
      }
    });

    const htmlRefHook = ref<HTMLElement | null>(null);
    const dropdown = ref(false);
    const dropdownRef = ref(null);

    const toggleDialog = (e: any) => {
      dropdown.value = !dropdown.value;
      if (dropdown.value) {
        nextTick(() => {
          const { top } = useElementBounding(htmlRefHook);
          const ParentEle = (htmlRefHook?.value?.offsetParent as any)?.offsetParent;
          const ParentBound = useElementBounding(ParentEle);
          let T = top.value - ParentBound.top.value - 20;
          if (props.isH5) {
            T = top.value - 90;
          }
          const H = (dropdownRef as any).value.children[0].clientHeight;
          if (T <= H) {
            (dropdownRef as any).value.children[0].style.top = '100%';
          } else {
            (dropdownRef as any).value.children[0].style.bottom = '100%';
          }
        });
      }
    };

    const jumpToAim = (message: any) => {
      if (
        (data.referenceMessage as any)?.messageID
        && data.allMessageID.includes((data.referenceMessage as any)?.messageID)
      ) {
        ctx.emit('jumpID', (data.referenceMessage as any).messageID);
      } else {
        const message = t('TUIChat.无法定位到原消息');
        handleErrorPrompts(message, props);
      }
    };

    onClickOutside(dropdownRef, () => {
      dropdown.value = false;
    });

    onLongPress(htmlRefHook, toggleDialog);

    const resendMessage = (message: any) => {
      ctx.emit('resendMessage', message);
    };

    const showReadReceiptTag = (message: any) => {
      if (data.needGroupReceipt && message.flow === 'out' && message.status === 'success' && message.needReadReceipt) return true;
      return false;
    };

    const readReceiptStyle = (message: any) => {
      if (message.isPeerRead || message.readReceiptInfo.unreadCount === 0) {
        return '';
      }
      return 'unRead';
    };

    const readReceiptCont = (message: any) => {
      switch (message.conversationType) {
        case TUIServer.TUICore.TIM.TYPES.CONV_C2C:
          if (message.isPeerRead) {
            return t('TUIChat.已读');
          }
          return t('TUIChat.未读');
        case TUIServer.TUICore.TIM.TYPES.CONV_GROUP:
          if (message.readReceiptInfo.unreadCount === 0) {
            return t('TUIChat.全部已读');
          }
          if (
            message.readReceiptInfo.readCount === 0
            || (message.readReceiptInfo.unreadCount === undefined && message.readReceiptInfo.readCount === undefined)
          ) {
            return t('TUIChat.未读');
          }
          return `${message.readReceiptInfo.readCount + t('TUIChat.人已读')}`;
        default:
          return '';
      }
    };

    const showReadReceiptDialog = (message: any) => {
      ctx.emit('showReadReceiptDialog', message);
    };

    return {
      ...toRefs(data),
      toggleDialog,
      htmlRefHook,
      jumpToAim,
      dropdown,
      dropdownRef,
      resendMessage,
      showReadReceiptTag,
      readReceiptStyle,
      readReceiptCont,
      showReadReceiptDialog,
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
  padding-bottom: 5px;
}
.line-left {
  border: 1px solid rgba(0, 110, 255, 0.5);
}
.message-reference-area {
  display: flex;
  background: #f2f2f2;
  border-radius: 0.5rem;
  border-radius: 0.63rem;
  align-self: start;
  margin-left: 44px;
  margin-right: 8px;
  &-show {
    width: 100%;
    display: flex;
    flex-direction: inherit;
    justify-content: center;
    padding: 6px;
    p {
      font-family: PingFangSC-Regular;
      font-weight: 400;
      font-size: 0.88rem;
      color: #999999;
      letter-spacing: 0;
      word-break: keep-all
    }
    span {
      height: 1.25rem;
      font-family: PingFangSC-Regular;
      font-weight: 400;
      font-size: 0.88rem;
      color: #999999;
      letter-spacing: 0;
      display: inline-block;
      padding-left: 10px;
    }
  }
}
.message-reference-area-reverse {
  align-self: end;
  margin-right: 44px;
  margin-left: 8px;
}
.message-img {
  max-width: min(calc(100vw - 180px), 300px);
  max-height: min(calc(100vw - 180px), 300px);
}
.message-video-cover {
  display: inline-block;
  position: relative;
  &::before {
    position: absolute;
    z-index: 1;
    content: '';
    width: 0px;
    height: 0px;
    border: 15px solid transparent;
    border-left: 20px solid #ffffff;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    margin: auto;
  }
}
.message-videoimg {
  max-width: min(calc(100vw - 160px), 300px);
  max-height: min(calc(100vw - 160px), 300px);
}
.face-box {
  display: flex;
  align-items: center;
}
.text-img {
  width: 20px;
  height: 20px;
}
.message-audio {
  padding-left: 10px;
  display: flex;
  align-items: center;
  position: relative;
  .icon {
    margin: 0 4px;
  }
  audio {
    width: 0;
    height: 0;
  }
}
.reserve {
  flex-direction: row-reverse;
}
.message-area {
  max-width: calc(100% - 54px);
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
  .reference-content {
    padding: 12px;
    font-weight: 400;
    font-size: 14px;
    color: burlywood;
    letter-spacing: 0;
    word-wrap: break-word;
    word-break: break-all;
    animation: reference 800ms;
  }
  @-webkit-keyframes reference {
    from {
      opacity: 1;
    }
    50% {
      background-color: #ff9c19;
    }
    to {
      opacity: 1;
    }
  }
  @keyframes reference {
    from {
      opacity: 1;
    }
    50% {
      background-color: #ff9c19;
    }
    to {
      opacity: 1;
    }
  }
  .content {
    padding: 12px;
    font-weight: 400;
    font-size: 14px;
    color: #000000;
    letter-spacing: 0;
    word-wrap: break-word;
    word-break: break-all;
    &-in {
      background: #fbfbfb;
      border-radius: 0px 10px 10px 10px;
    }
    &-out {
      background: #dceafd;
      border-radius: 10px 0px 10px 10px;
    }
  }
}
.message-label {
  align-self: flex-end;
  font-family: PingFangSC-Regular;
  font-weight: 400;
  font-size: 12px;
  color: #b6b8ba;
  word-break: keep-all;
}
.fail {
  width: 15px;
  height: 15px;
  border-radius: 15px;
  background: red;
  color: #ffffff;
  display: flex;
  justify-content: center;
  align-items: center;
}
.unRead {
  color: #679ce1;
}
.dropdown-inner {
  position: absolute;
  width: 100%;
  height: 100%;
  left: 0;
  top: 0;
}
.dialog {
  position: absolute;
  z-index: 1;
  margin: 10px 0;
  &-right {
    right: 0;
  }
}
</style>
