<template>
  <h1>{{ title === '对方正在输入' ? $t('TUIChat.对方正在输入') : title }}</h1>
</template>

<script lang="ts">
import { defineComponent, watchEffect, watch, reactive, toRefs, computed, nextTick } from 'vue';
import { handleName, JSONToString, isTypingMessage } from '../../utils/utils';
import TUIAegis from '../../../../../utils/TUIAegis';
import constant from '../../../constant';
const TypingHeader = defineComponent({
  props: {
    needTyping: {
      type: Boolean,
      default: false,
    },
    conversation: {
      type: Object,
      default: () => ({}),
    },
    messageList: {
      type: Array,
      default: () => [],
    },
    inputText: {
      type: String,
      default: '',
    },
    inputBlur: {
      type: Boolean,
      default: true,
    },
    inputCompositionCont: {
      type: String,
      default: '',
    },
  },
  setup(props: any, ctx: any) {
    const data = reactive({
      messageList: [],
      conversation: {},
      inputText: '',
      inputBlur: true,
      inputCompositionCont: '',
      title: '',
      timeValid: 0,
      myTypingStatus: 0,
      otherTypingStatus: 0,
      needTyping: false,
      lastOtherMessageTime: 0,
      lastMyTypingTime: 0,
      lastOtherTypingTime: 0,
      options: {
        data: {
          businessID: constant.typeUserTyping,
          typingStatus: 0,
          version: 1,
          userAction: 0,
          actionParam: constant.typeInputStatusEnd,
        },
        description: '',
        extension: '',
      },
    });

    watchEffect(() => {
      data.messageList = props.messageList;
      data.conversation = props.conversation;
      data.inputText = props.inputText;
      data.inputBlur = props.inputBlur;
      data.inputCompositionCont = props.inputCompositionCont;
      data.needTyping = props.needTyping;
    });
    const conversationID = computed(() => {
      const { conversation }: any = data;
      return conversation?.conversationID ? conversation.conversationID : '';
    });
    const conversationName = computed(() => {
      const { conversation }: any = data;
      return handleName(conversation);
    });
    const conversationType = computed(() => {
      const { conversation }: any = data;
      return conversation?.type ? conversation?.type : '';
    });

    const title = computed(() => {
      if (data.needTyping && data.otherTypingStatus) {
        return '对方正在输入';
      }
      return conversationName?.value;
    });

    const inputChange = computed(() => ({
      inputText: data.inputText,
      inputBlur: data.inputBlur,
      inputCompositionCont: data.inputCompositionCont,
    }));

    watch(
      inputChange,
      (newVal: any, oldVal: any) => {
        if (!newVal || !data.needTyping || conversationType.value !== 'C2C') return;
        if (new Date().getTime() / 1000 - data.lastOtherMessageTime < 30) {
          data.timeValid = 1;
        }
        if (!data.timeValid) return;
        if (newVal.inputText === `${oldVal.inputText}\n`) return;
        if ((newVal.inputText || newVal.inputCompositionCont) && !newVal.inputBlur) {
          data.myTypingStatus = 1;
          const now = new Date().getTime();
          if (now - data.lastMyTypingTime > 4000) {
            data.lastMyTypingTime = now;
            sendTypingMessage(data.myTypingStatus);
          }
        } else {
          data.myTypingStatus = 0;
          data.lastMyTypingTime = 0;
          sendTypingMessage(data.myTypingStatus);
        }
      },
      { deep: true },
    );

    watch(conversationID, (newVal: any, oldVal: any) => {
      if (newVal === oldVal) return;
      data.needTyping = false;
      data.timeValid = 0;
    });

    watch(
      () => data.needTyping,
      (newVal: any, oldVal: any) => {
        if (!newVal) {
          data.myTypingStatus = 0;
          data.otherTypingStatus = 0;
          data.lastOtherMessageTime = 0;
        }
      },
    );

    watch(
      () => data.messageList,
      (newVal: any, oldVal: any) => {
        nextTick(() => {
          if (newVal.length === 0 || conversationType.value !== 'C2C') {
            return;
          }
          data.lastOtherMessageTime = getLastOtherMessageTime(newVal);
          if (newVal[newVal.length - 1]?.flow === 'in') {
            if (!isTypingMessage(newVal[newVal.length - 1])) {
              data.lastOtherMessageTime = newVal[newVal.length - 1]?.time;
              data.otherTypingStatus = 0;
            } else {
              data.otherTypingStatus = handleTypingMessageStatus(newVal[newVal.length - 1]);
              waitTypingEnd();
            }
          }
        });
      },
      { deep: true },
    );

    const handleTypingMessageStatus = (item: any) => {
      try {
        const { typingStatus, actionParam }: any = JSONToString(item?.payload?.data);
        if (typingStatus === 1 && actionParam === constant.typeInputStatusIng) {
          return 1;
        }
        return 0;
      } catch {
        return 0;
      }
    };

    const sendTypingMessage = (isTyping: any) => {
      data.options = {
        data: {
          businessID: constant.typeUserTyping,
          typingStatus: isTyping ? 1 : 0,
          version: 1,
          userAction: isTyping ? 14 : 0,
          actionParam: isTyping ? constant.typeInputStatusIng : constant.typeInputStatusEnd,
        },
        description: '',
        extension: '',
      };
      TypingHeader.TUIServer.sendTypingMessage(data.options);
      TUIAegis.getInstance().reportEvent({
        name: 'messageType',
        ext1: 'typeCustom',
      });
      return;
    };

    const getLastOtherMessageTime = (messageList: any) => {
      if (!messageList) return 0;
      for (let i = messageList.length - 1; i >= 0; i--) {
        if (!isTypingMessage(messageList[i]) && messageList[i].flow === 'in') {
          return messageList[i].time;
        }
      }
      return 0;
    };

    const debounce = (func: any, wait = 2000) => {
      let timer: any;
      return function () {
        if (timer) clearTimeout(timer);
        timer = setTimeout(func, wait);
      };
    };

    const waitTypingEnd = debounce(() => {
      data.otherTypingStatus = 0;
    }, 5000);

    return {
      ...toRefs(data),
      conversationID,
      conversationName,
      conversationType,
      title,
      isTypingMessage,
      sendTypingMessage,
      handleTypingMessageStatus,
      getLastOtherMessageTime,
      debounce,
      waitTypingEnd,
    };
  },
});
export default TypingHeader;
</script>
