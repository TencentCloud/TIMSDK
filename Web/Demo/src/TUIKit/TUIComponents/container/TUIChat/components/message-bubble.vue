<template>
    <div class="message-bubble" :class="[message.flow === 'in' ? '' : 'reverse']" ref="htmlRefHook">
      <img
        class="avatar"
        :src="message?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
        onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'">
      <main class="message-area">
        <label class="name" v-if="message.flow === 'in'&& message.conversationType === 'GROUP'">
          {{message.nameCard || message.nick || message.from}}
        </label>
        <div :class="['content content-' + message.flow]" @click.prevent.right="toggleDialog">
          <div class="message-reference-area" v-if="message.cloudCustomData && referenceMessage" @click="jumpToAim(referenceMessage)">
            <i class="line-left"></i>
            <div v-if="referenceMessage?.messageID && allMessageID.indexOf(referenceMessage.messageID) !== -1" class="message-reference-area-show">
              <span>{{referenceForShow.nick || referenceForShow.from}}</span>
              <div class="face-box" v-if="referenceMessage.messageType ===  type.typeText">
                <div  v-for="(item, index) in face" :key="index">
                  <span class="text-box" v-if="item.name === 'text'">{{ item.text }}</span>
                  <img class="text-img" v-else-if="item.name === 'img'" :src="item.src"/>
                </div>
              </div>
              <span v-if="referenceMessage.messageType ===  type.typeCustom">{{referenceMessage.messageAbstract}}</span>
              <img v-if="referenceMessage.messageType === type.typeImage" class="message-img" :src="referenceForShow.payload.imageInfoArray[1].url" />
              <div v-if="referenceMessage.messageType === type.typeAudio" class="message-audio" :class="[message.flow === 'out' && 'reserve']">
                <label>{{referenceForShow.payload.second}}s</label>
                <i class="icon icon-voice" ></i>
              </div>
              <div v-if="referenceMessage.messageType === type.typeVideo" class="message-video-cover">
              <img  class="message-videoimg" :src="referenceForShow.payload.snapshotUrl" >
              </div>
              <img v-if="referenceMessage.messageType === type.typeFace"  :src="url" />
            </div>
            <div v-else class="message-reference-area-show">
              <span>{{referenceMessage?.messageSender}}</span>
              <span>{{referenceMessage?.messageAbstract}}</span>
            </div>
          </div>
          <slot />
          <div v-if="dropdown" ref="dropdownRef" class="dropdown-inner" @click="toggleDialog">
            <div class="dialog" :class="[message.flow === 'in' ? '' : 'dialog-right']">
              <slot name="dialog" />
            </div>
          </div>
        </div>
      </main>
      <label class="message-label fail" v-if="message.status === 'fail'" @click="resendMessage(message)">!</label>
      <label class="message-label" :class="[!message.isPeerRead && 'unRead']" v-if="message.conversationType === 'C2C' && message.flow !== 'in' && message.status === 'success'">
        <span v-if="!message.isPeerRead">{{$t('TUIChat.未读')}}</span>
        <template v-else>
          <template v-if="message.conversationType === 'GROUP'">
            {{message.readReceiptInfo.readCount + '人' + $t('TUIChat.已读')}}
          </template>
          <span v-else>{{$t('TUIChat.已读')}}</span>
        </template>
      </label>
    </div>
</template>

<script lang="ts">
import { decodeText } from '../utils/decodeText';
import constant from '../../constant';
import { defineComponent, watchEffect, reactive, toRefs, ref, nextTick } from 'vue';
import { onClickOutside, onLongPress, useElementBounding } from '@vueuse/core';
import { JSONToString } from '../utils/utils';
import { handleErrorPrompts } from '../../utils';

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
  },
  setup(props:any, ctx:any) {
    const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
    const data = reactive({
      message: {},
      messagesList: {},
      show: false,
      type: {},
      referenceMessage: {},
      referenceForShow: {},
      allMessageID: '',
      face: [],
      url: '',
    });

    watchEffect(() => {
      data.type = constant;
      data.message = props.data;
      data.messagesList = props.messagesList;
      if ((data.message as any).cloudCustomData) {
        const messageIDList:any[] = [];
        const cloudCustomData  = JSONToString((data.message as any).cloudCustomData);
        data.referenceMessage = cloudCustomData.messageReply ? cloudCustomData.messageReply :  '';
        for (let index = 0; index < (data.messagesList as any).length ; index++) {
          // To determine whether the referenced message is still in the message list, the corresponding field of the referenced message is displayed if it is in the message list. Otherwise, messageabstract/messagesender is displayed
          messageIDList.push((data.messagesList as any)[index].ID);
          (data as any).allMessageID = JSON.stringify(messageIDList);
          if ((data.messagesList as any)[index].ID === (data.referenceMessage as any)?.messageID) {
            data.referenceForShow = (data.messagesList as any)[index];
            if ((data.referenceMessage as any).messageType === constant.typeText) {
              (data as any).face = decodeText((data.referenceForShow as any).payload);
            }
            if ((data.referenceMessage as any).messageType === constant.typeFace) {
              (data as any).url = `https://web.sdk.qcloud.com/im/assets/face-elem/${(data.referenceForShow as any).payload.data}@2x.png`;
            }
          }
        }
      }
    });

    const htmlRefHook = ref<HTMLElement | null>(null);
    const dropdown = ref(false);
    const dropdownRef = ref(null);

    const toggleDialog = (e:any) => {
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

    const jumpToAim = (message:any) => {
      if ((data.referenceMessage as any)?.messageID && data.allMessageID.includes((data.referenceMessage as any)?.messageID)) {
        ctx.emit('jumpID', (data.referenceMessage as any).messageID);
      } else {
        const message = t('TUIChat.无法定位到原消息');
        handleErrorPrompts(message, props);
      }
    };

    onClickOutside(
      dropdownRef,
      () => {
        dropdown.value = false;
      },
    );

    onLongPress(htmlRefHook, toggleDialog);

    const resendMessage = (message:any) => {
      ctx.emit('resendMessage', message);
    };

    return {
      ...toRefs(data),
      toggleDialog,
      htmlRefHook,
      jumpToAim,
      dropdown,
      dropdownRef,
      resendMessage,
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
.line-left{
  border: 1px solid rgba(0,110,255,0.50);

}
.message-reference-area{
  display: flex;
  padding-left: 4px;
  &-show {
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding-left: 6px;
    span {
      height: 1.25rem;
      font-family: PingFangSC-Regular;
      font-weight: 400;
      font-size: 0.88rem;
      color: #BFC1C5;
      letter-spacing: 0;
    }
  }
}
.message-img {
  max-width: 100px;
  max-height: 100px;
}
.message-video-cover{
    display: inline-block;
    position: relative;
    &::before {
      position: absolute;
      z-index: 1;
      content: "";
      width: 0px;
      height: 0px;
      border: 15px solid transparent;
      border-left: 20px solid #FFFFFF;
      top: 0;
      left: 0;
      bottom: 0;
      right: 0;
      margin: auto;
    }
  }
.message-videoimg {
  max-width: 300px;
  max-height: 300px;
}
.face-box{
  display: flex;
}
.text-img {
  width: 20px;
  height: 20px;
}
.message-audio {
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
    word-wrap:break-word;
    word-break:break-all;
    animation: reference 800ms;
  }
@-webkit-keyframes reference {
    from {
        opacity: 1.0;
    }
    50% {
        background-color: #FF9C19;
    }
    to {
        opacity: 1.0;
    }
}
@keyframes reference {
    from {
        opacity: 1.0;
    }
    50% {
        background-color: #FF9C19;
    }
    to {
        opacity: 1.0;
    }
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
