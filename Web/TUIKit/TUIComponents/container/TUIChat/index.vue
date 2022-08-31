<template>
  <div class="TUIChat" :class="[env.isH5 ? 'TUIChat-H5' : '']" v-if="conversationType === 'chat'">
    <header class="TUIChat-header">
      <i class="icon icon-back" @click="back" v-if="env.isH5"></i>
      <typing-header
        :needTyping="needTyping"
        :conversation="conversation"
        :messageList="messageList"
        :inputText="text"
        :inputBlur="inputBlur"
        :inputCompositionCont="inputCompositionCont"
      />
      <aside class="setting">
        <Manage v-if="conversation.groupProfile" :conversation="conversation" :userInfo="userInfo" :isH5="env.isH5" />
      </aside>
    </header>
    <div class="TUIChat-main">
      <div class="TUIChat-safe-tips">
        <span>
          {{ $t('TUIChat.安全提示') }}
        </span>
        <a @click="openLink(Link.complaint)">{{ $t('TUIChat.点此投诉') }}</a>
      </div>
      <ul class="TUI-message-list" @click="dialogID = ''" ref="messageEle" id="messageEle">
        <p class="message-more" @click="getHistoryMessageList" v-if="!isCompleted">
          {{ $t('TUIChat.查看更多') }}
        </p>
        <li v-for="(item, index) in messages" :key="index" :id="item?.ID" ref="messageAimID">
          <MessageTip v-if="item.type === types.MSG_GRP_TIP" :data="handleTipMessageShowContext(item)" />
          <MessageBubble
            v-else-if="!item.isRevoked"
            :isH5="env.isH5"
            :data="item"
            :messagesList="messages"
            :needGroupReceipt="needGroupReceipt"
            @jumpID="jumpID"
            @resendMessage="resendMessage"
            @showReadReceiptDialog="showReadReceiptDialog"
          >
            <MessageText v-if="item.type === types.MSG_TEXT" :data="handleTextMessageShowContext(item)" />
            <MessageImage
              v-if="item.type === types.MSG_IMAGE"
              :data="handleImageMessageShowContext(item)"
              :isH5="env.isH5"
            />
            <MessageVideo
              v-if="item.type === types.MSG_VIDEO"
              :data="handleVideoMessageShowContext(item)"
              :isH5="env.isH5"
            />
            <MessageAudio v-if="item.type === types.MSG_AUDIO" :data="handleAudioMessageShowContext(item)" />
            <MessageFile v-if="item.type === types.MSG_FILE" :data="handleFileMessageShowContext(item)" />
            <MessageFace v-if="item.type === types.MSG_FACE" :data="handleFaceMessageShowContext(item)" />
            <MessageLocation v-if="item.type === types.MSG_LOCATION" :data="handleLocationMessageShowContext(item)" />
            <MessageCustom v-if="item.type === types.MSG_CUSTOM" :data="handleCustomMessageShowContext(item)" />
            <MessageMerger v-if="item.type === types.MSG_MERGER" :data="handleMergerMessageShowContext(item)" />
            <template #dialog>
              <ul class="dialog-item">
                <li
                  v-if="
                    (item.type === types.MSG_FILE || item.type === types.MSG_VIDEO || item.type === types.MSG_IMAGE) &&
                    !env.isH5
                  "
                  @click="openMessage(item)"
                >
                  <i class="icon icon-msg-copy"></i>
                  <span>{{ $t('TUIChat.打开') }}</span>
                </li>
                <li v-if="item.type === types.MSG_TEXT" @click="handleMseeage(item, constant.handleMessage.copy)">
                  <i class="icon icon-msg-copy"></i>
                  <span>{{ $t('TUIChat.复制') }}</span>
                </li>
                <li v-if="item.status === 'success'" @click="handleMseeage(item, constant.handleMessage.forward)">
                  <i class="icon icon-msg-forward"></i>
                  <span>{{ $t('TUIChat.转发') }}</span>
                </li>
                <li v-if="item.status === 'success'" @click="handleMseeage(item, 'reply')">
                  <i class="icon icon-msg-quote"></i>
                  <span>{{ $t('TUIChat.引用') }}</span>
                </li>
                <li
                  v-if="item.flow === 'out' && item.status === 'success'"
                  @click="handleMseeage(item, constant.handleMessage.revoke)"
                >
                  <i class="icon icon-msg-revoke"></i>
                  <span>{{ $t('TUIChat.撤回') }}</span>
                </li>
                <li v-if="item.status === 'success'" @click="handleMseeage(item, constant.handleMessage.delete)">
                  <i class="icon icon-msg-del"></i>
                  <span>{{ $t('TUIChat.删除') }}</span>
                </li>
              </ul>
            </template>
          </MessageBubble>
          <MessageRevoked v-else :isEdit="item.type === types.MSG_TEXT" :data="item" @edit="handleEdit(item)" />
        </li>
        <div class="to-bottom-tip" v-if="needToBottom" @click="scrollToTarget('bottom')">
          <i class="icon icon-bottom-double"></i>
          <div class="to-bottom-tip-cont">
            <span>{{ toBottomTipCont }}</span>
          </div>
        </div>
      </ul>
      <div class="dialog dialog-conversation" v-if="forwardStatus && messageComponents.Forward">
        <component
          :is="'Forward'"
          :list="conversationData.list"
          :message="currentMessage"
          :show="forwardStatus"
          :isH5="env.isH5"
          @update:show="(e: any) => (forwardStatus = e)"
        >
          <template #left="{ data }">
            <img class="avatar" :src="conversationData.handleAvatar(data)" />
            <label class="name">{{ conversationData.handleName(data) }}</label>
          </template>
          <template #right="{ data }">
            <img class="avatar" :src="conversationData.handleAvatar(data)" />
            <label class="name" v-if="!env.isH5">{{ conversationData.handleName(data) }}</label>
          </template>
        </component>
      </div>
      <div class="dialog dialog-conversation" v-if="needGroupReceipt">
        <ReadReceiptDialog
          :message="currentMessage"
          :conversation="conversation"
          :show="receiptDialogStatus"
          :isH5="env.isH5"
          @closeDialog="closeReadReceiptDialog"
          ref="readReceiptDialog"
        />
      </div>
    </div>
    <div class="TUIChat-footer" :class="[isMute && 'disabled', env.isH5 && 'TUIChat-H5-footer']">
      <div class="func" id="func">
        <main class="func-main">
          <component
            v-for="(item, index) in pluginComponentList"
            :key="index"
            :isMute="isMute"
            :is="item"
            :isH5="env.isH5"
            parentID="func"
            @send="handleSend"
          ></component>
        </main>
      </div>
      <div class="memberList" v-if="showGroupMemberList">
        <ul class="memberList-box" ref="dialog">
          <header class="memberList-box-title" v-if="env.isH5">
            <h1>选择提醒的人</h1>
            <span class="close" @click="toggleshowGroupMemberList">关闭</span>
          </header>
          <li class="memberList-box-header" @click="selectAt('allMember', allMember)">
            <img src="../../assets/icon/at.svg" alt="" />
            <span>{{ allMember[0].allText }}</span>
            <span>({{ allMemberList.length }})</span>
          </li>
          <li
            class="memberList-box-body"
            v-for="(item, index) in allMemberList"
            :key="index"
            @click="selectAt('oneMember', item)"
          >
            <img :src="item.avatar" alt="" />
            <span>{{ item.nick ? item.nick : item.userID }}</span>
          </li>
        </ul>
      </div>
      <div class="reference">
        <div class="reference-box" v-if="showReference">
          <i></i>
          <div class="reference-box-show">
            <span>{{ referenceMessage.nick ? referenceMessage.nick : referenceMessage.from }}</span>
            <span>{{ referenceMessageForShow }}</span>
          </div>
          <label class="icon icon-cancel" @click="showReference = false"></label>
        </div>
      </div>
      <div class="input">
        <textarea
          ref="inputEle"
          @paste="pasting"
          v-model="text"
          :placeholder="$t('TUIChat.请输入消息')"
          data-type="text"
          @input="inputChange"
          @keyup.enter="sendMseeage"
          @keyup.delete="deleteAt"
          @keypress="geeks"
          @blur="inputBlur = true"
          @focus="inputBlur = false"
          @compositionstart="inputComposition = true"
          @compositionend="compositionEnd"
          rows="1"
        ></textarea>
        <p v-if="isMute">{{ $t(`TUIChat.${muteText}`) }}</p>
        <button v-if="!isMute" class="input-btn" data-type="text" :disabled="!text" @click="sendMseeage">
          <p class="input-btn-hover">
            {{ $t('TUIChat.按Enter发送，Ctrl+Enter换行') }}
          </p>
          {{ $t('发送') }}
        </button>
      </div>
    </div>
    <div v-show="showResend" class="mask" @click="showResend = false">
      <div class="mask-main">
        <header>{{ $t('TUIChat.确认重发该消息？') }}</header>
        <footer>
          <p @click="showResend = false">{{ $t('TUIChat.取消') }}</p>
          <i></i>
          <p @click="submit">{{ $t('TUIChat.确定') }}</p>
        </footer>
      </div>
    </div>
  </div>
  <div class="TUIChat" v-else-if="conversationType === 'system'">
    <header class="TUIChat-header">
      <h1>{{ conversationName }}</h1>
    </header>
    <MessageSystem :data="messages" :types="types" @application="handleApplication" />
  </div>
  <slot v-else-if="slotDefault" />
</template>
<script lang="ts">
import {
  defineComponent,
  reactive,
  toRefs,
  ref,
  computed,
  nextTick,
  watch,
  useSlots,
  onMounted,
  watchEffect,
} from 'vue';
import {
  MessageText,
  MessageImage,
  MessageVideo,
  MessageAudio,
  MessageFile,
  MessageFace,
  MessageLocation,
  MessageMerger,
  MessageCustom,
  MessageBubble,
  MessageTip,
  MessageRevoked,
  MessageSystem,
} from './components';
import { onClickOutside } from '@vueuse/core';
import { Manage } from './manage-components';

import {
  handleAvatar,
  handleName,
  handleTextMessageShowContext,
  handleImageMessageShowContext,
  handleVideoMessageShowContext,
  handleAudioMessageShowContext,
  handleFileMessageShowContext,
  handleFaceMessageShowContext,
  handleLocationMessageShowContext,
  handleMergerMessageShowContext,
  handleTipMessageShowContext,
  handleCustomMessageShowContext,
  getImgLoad,
  isTypingMessage,
  deepCopy,
} from './utils/utils';

import { getComponents } from './index';

import { useStore } from 'vuex';
import TUIAegis from '../../../utils/TUIAegis';
import constant from '../constant';
import { handleErrorPrompts } from '../utils';
import Link from '../../../utils/link';
import useClipboard from 'vue-clipboard3';
import { Message } from './interface';
import { Conversation } from '../TUIConversation/interface';

const TUIChat: any = defineComponent({
  name: 'TUIChat',
  components: {
    MessageText,
    MessageImage,
    MessageVideo,
    MessageAudio,
    MessageFile,
    MessageFace,
    MessageLocation,
    MessageMerger,
    MessageCustom,
    MessageBubble,
    MessageTip,
    MessageRevoked,
    MessageSystem,
    Manage,
  },
  props: {
    isSupportGroupReceipt: {
      type: Boolean,
      default: false,
    },
  },
  setup(props) {
    const { TUIServer } = TUIChat;
    const GroupServer = TUIServer?.TUICore?.TUIServer?.TUIGroup;
    const ProfileServer = TUIServer?.TUICore?.TUIServer?.TUIProfile;
    const VuexStore = useStore();
    const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
    const data = reactive({
      messageList: [] as Message[],
      conversation: {} as Conversation,
      text: '',
      atText: '',
      types: TUIServer.TUICore.TIM.TYPES,
      currentMessage: {} as Message,
      dialogID: '',
      forwardStatus: false,
      receiptDialogStatus: false,
      isCompleted: false,
      userInfoView: false,
      userInfo: {
        isGroup: false,
        list: [],
      },
      selfInfo: {},
      messageComponents: getComponents('message'),
      isShow: false,
      muteText: '您已被管理员禁言',
      isFirstSend: true,
      isFirstRender: true,
      showGroupMemberList: false,
      showReference: false,
      referenceMessage: {} as Message,
      referenceMessageForShow: '',
      referenceMessageType: 0,
      historyReference: false,
      referenceID: '',
      allMemberList: [],
      atType: [],
      atAllText: '',
      atOneText: [],
      allMember: [
        {
          allText: '所有人',
          type: TUIServer.TUICore.TIM.TYPES.MSG_AT_ALL,
        },
      ],
      env: TUIServer.TUICore.TUIEnv,
      showResend: false,
      resendMessage: {},
      inputBlur: false,
      inputComposition: false,
      inputCompositionCont: '',
      needTyping: true,
      needReadReceipt: VuexStore.state.needReadReceipt,
      peerNeedReceipt: false,
      needToBottom: false,
      toBottomTipCont: '',
      messageInView: [] as Message[],
      readSet: new Set(),
      isUserAction: false,
      scroll: {
        scrollTop: 0,
        scrollHeight: 0,
        scrollTopMin: Infinity,
        scrollTopMax: 0,
      },
      isSupportGroupReceipt: false,
    });

    const slotDefault = !!useSlots().default;
    // 调用 TUIConversation 模块的 setMessageRead 方法
    // 消息已读
    // Using the setMessageRead method of the TUIConversion module
    const setMessageRead = async (conversationID: string | undefined) => {
      if (!conversationID) return;
      await TUIServer?.TUICore?.TUIServer?.TUIConversation?.setMessageRead(conversationID);
      return;
    };

    const sendMessageReadReceipt = async (messageList: Message[]) => {
      const needReceiptMessageList = messageList.filter((item: Message) => item?.flow === 'in' && item?.needReadReceipt && !data.readSet.has(item?.ID));
      if (needReceiptMessageList.length) {
        await TUIServer?.sendMessageReadReceipt(needReceiptMessageList).then(() => {
          needReceiptMessageList.forEach((item: Message) => data.readSet.add(item?.ID));
        });
        await setMessageRead(data?.conversation?.conversationID);
      }
    };

    const pluginComponentList: any = [];
    Object.keys(getComponents('send')).forEach((name: any) => {
      pluginComponentList.push(name);
    });

    Manage.TUIServer = TUIServer;
    Manage.GroupServer = TUIServer?.TUICore?.TUIServer?.TUIGroup;

    const messageEle = ref();
    const inputEle: any = ref();
    const messageAimID = ref();
    const readReceiptDialog = ref();

    TUIServer.bind(data);

    const conversationData = {
      list: [],
      handleAvatar,
      handleName,
    };

    const dialog: any = ref();

    onClickOutside(dialog, () => {
      data.showGroupMemberList = false;
    });

    const conversationType = computed(() => {
      const { conversation } = data;
      if (!conversation?.conversationID) {
        return '';
      }
      if (conversation?.type === TUIServer.TUICore.TIM.TYPES.CONV_SYSTEM) {
        return 'system';
      }
      return 'chat';
    });

    const isMute = computed(() => {
      const { conversation } = data;
      if (conversation?.type === TUIServer.TUICore.TIM.TYPES.CONV_GROUP) {
        const userRole = conversation?.groupProfile?.selfInfo.role;
        const isMember = userRole === TUIServer.TUICore.TIM.TYPES.GRP_MBR_ROLE_MEMBER;
        if (isMember && conversation?.groupProfile?.muteAllMembers) {
          // data.muteText = "管理员开启全员禁言";
          return true;
        }
        const time: number = new Date().getTime();
        if ((data.selfInfo as any)?.muteUntil * 1000 - time > 0) {
          // data.muteText = "您已被管理员禁言";
          return true;
        }
      }
      return false;
    });

    watchEffect(() => {
      data.isSupportGroupReceipt = props.isSupportGroupReceipt;
    });

    watch(
      () => VuexStore.state.needReadReceipt,
      (newVal: boolean) => {
        data.needReadReceipt = newVal;
      },
    );

    watch(
      () => data?.conversation?.conversationID,
      (newVal: () => string | undefined, oldVal: () => string | undefined) => {
        if (newVal === oldVal) return;
        data.scroll.scrollTop = 0;
        data.scroll.scrollHeight = 0;
        data.scroll.scrollTopMin = Infinity;
        data.scroll.scrollTopMax = 0;
      },
      {
        deep: true,
      },
    );

    watch(isMute, (newVal: any, oldVal: any) => {
      const { conversation } = data;
      if (newVal && conversation?.type === TUIServer.TUICore.TIM.TYPES.CONV_GROUP) {
        const userRole = conversation?.groupProfile?.selfInfo.role;
        const isMember = userRole === TUIServer.TUICore.TIM.TYPES.GRP_MBR_ROLE_MEMBER;
        if (isMember && conversation?.groupProfile?.muteAllMembers) {
          data.muteText = '管理员开启全员禁言';
        }
        const time: number = new Date().getTime();
        if ((data.selfInfo as any)?.muteUntil * 1000 - time > 0) {
          data.muteText = '您已被管理员禁言';
        }
      }
    });

    const conversationName = computed(() => {
      const { conversation } = data;
      return handleName(conversation);
    });

    const messages = computed(() => data.messageList.filter((item: any) => !item.isDeleted && !isTypingMessage(item)));

    const needGroupReceipt = computed(() => {
      const { conversation, isSupportGroupReceipt } = data;
      if (conversation?.type === TUIServer.TUICore.TIM.TYPES.CONV_C2C || isSupportGroupReceipt) {
        return true;
      }
      return false;
    });

    watch(
      messages,
      (newVal: Array<Message>, oldVal: Array<Message>) => {
        nextTick(() => {
          const isTheSameMessage = newVal[newVal.length - 1]?.ID === oldVal[oldVal.length - 1]?.ID;
          if (newVal.length === 0 || isTheSameMessage) {
            return;
          }
          handleScroll();
        });
        if (data.currentMessage) {
          const messageID = data.currentMessage?.ID;
          const message = newVal.find((item: any) => item.ID === messageID);
          if (message) {
            data.currentMessage = deepCopy(message);
          }
        }
        if (data.historyReference) {
          for (let index = 0; index < messages.value.length; index++) {
            if (messages?.value[index]?.ID === data?.referenceID) {
              scrollToTarget('target', messageAimID.value[index]);
              messageAimID.value[index].getElementsByClassName('content')[0].classList.add('reference-content');
            }
          }
          data.historyReference = false;
        }
      },
      { deep: true },
    );

    watch(
      () => data.scroll.scrollTop,
      (newVal: number) => {
        setTimeout(() => {
          // scrolling end
          if (newVal === messageEle?.value?.scrollTop) {
            if (data.scroll.scrollTopMin !== Infinity && data.scroll.scrollTopMax !== 0) {
              sendMessageReadInView('scroll');
            }
            data.scroll.scrollTopMin = Infinity;
            data.scroll.scrollTopMax = 0;
          }
        }, 20);
      },
      { deep: true },
    );

    onMounted(() => {
      watch(
        () => messageEle?.value,
        () => {
          if (messageEle?.value) {
            messageEle.value.addEventListener('scroll', onScrolling);
          }
        },
        {
          deep: true,
        },
      );
    });

    const handleSend = (emo: any) => {
      data.text += emo.name;
      if (!data.env.isH5) {
        inputEle.value.focus();
      }
    };

    const sendMseeage = async (event: any) => {
      if (event.keyCode === 13 && event.ctrlKey) return;
      const text = data.text.trimEnd();
      const cloudCustomData: any = {};
      data.text = '';
      if (data.needTyping) {
        cloudCustomData.messageFeature = {
          needTyping: 1,
          version: 1,
        };
      }
      if (data.showReference) {
        cloudCustomData.messageReply = {
          messageAbstract: data.referenceMessageForShow,
          messageSender: data.referenceMessage.nick || data.referenceMessage.from,
          messageID: data.referenceMessage.ID,
          messageType: data.referenceMessageType,
          version: 1,
        };
        try {
          await TUIServer.sendTextMessage(JSON.parse(JSON.stringify(text)), cloudCustomData);
        } catch (error: any) {
          handleErrorPrompts(error, data.env);
        }
      }
      if (text && data.atType.length === 0 && data.showReference === false) {
        try {
          if (data.needTyping) {
            await TUIServer.sendTextMessage(JSON.parse(JSON.stringify(text)), cloudCustomData);
          } else {
            await TUIServer.sendTextMessage(JSON.parse(JSON.stringify(text)));
          }
          data.showReference = false;
          TUIAegis.getInstance().reportEvent({
            name: 'messageType',
            ext1: 'typeText',
          });
        } catch (error: any) {
          handleErrorPrompts(error, data.env);
        }
      }
      if (data.atType.length > 0) {
        const options: any = {
          to: data?.conversation?.groupProfile?.groupID,
          conversationType: TUIServer.TUICore.TIM.TYPES.CONV_GROUP,
          payload: {
            text,
            atUserList: data.atType,
          },
        };
        try {
          await TUIServer.sendTextAtMessage({
            text: options.payload.text,
            atUserList: options.payload.atUserList,
          });
          data.showGroupMemberList = false;
        } catch (error) {
          console.log(error);
        }
      }
      if (data.isFirstSend) {
        TUIAegis.getInstance().reportEvent({
          name: 'sendMessage',
          ext1: 'sendMessage-success',
        });
        data.isFirstSend = false;
      }
      data.showReference = false;
      VuexStore.commit('handleTask', 0);
      return (data.atType = []);
    };

    const handleItem = (item: any) => {
      data.currentMessage = item;
      data.dialogID = item.ID;
    };

    const handleMseeage = async (message: Message, type: string) => {
      switch (type) {
        case constant.handleMessage.revoke:
          try {
            await TUIServer.revokeMessage(message);
            TUIAegis.getInstance().reportEvent({
              name: 'messageOptions',
              ext1: 'messageRevoke',
            });
            VuexStore.commit('handleTask', 1);
          } catch (error) {
            handleErrorPrompts(error, data.env);
          }
          data.dialogID = '';
          break;
        case constant.handleMessage.copy:
          try {
            if (message?.type === data.types.MSG_TEXT && message?.payload?.text) {
              const { toClipboard } = useClipboard();
              await toClipboard(message?.payload?.text);
            }
          } catch (error) {
            handleErrorPrompts(error, data.env);
          }
          break;
        case constant.handleMessage.delete:
          await TUIServer.deleteMessage([message]);
          TUIAegis.getInstance().reportEvent({
            name: 'messageOptions',
            ext1: 'messageDelete',
          });
          data.dialogID = '';
          break;
        case constant.handleMessage.forward:
          TUIAegis.getInstance().reportEvent({
            name: 'messageOptions',
            ext1: 'messageForward',
          });
          data.currentMessage = message;
          data.dialogID = '';
          conversationData.list = TUIServer.TUICore.getStore().TUIConversation.conversationList;
          data.forwardStatus = true;
          break;
        case constant.handleMessage.reply:
          data.showReference = true;
          data.referenceMessage = message;
          switch (message.type) {
            case data.types.MSG_TEXT:
              data.referenceMessageForShow = message?.payload?.text;
              data.referenceMessageType = 1;
              break;
            case data.types.MSG_CUSTOM:
              data.referenceMessageForShow = '[自定义消息]';
              data.referenceMessageType = 2;
              break;
            case data.types.MSG_IMAGE:
              data.referenceMessageForShow = '[图片]';
              data.referenceMessageType = 3;
              break;
            case data.types.MSG_AUDIO:
              data.referenceMessageForShow = '[语音]';
              data.referenceMessageType = 4;
              break;
            case data.types.MSG_VIDEO:
              data.referenceMessageForShow = '[视频]';
              data.referenceMessageType = 5;
              break;
            case data.types.MSG_FILE:
              data.referenceMessageForShow = '[文件]';
              data.referenceMessageType = 6;
              break;
            case data.types.MSG_FACE:
              data.referenceMessageForShow = '[表情]';
              data.referenceMessageType = 8;
              break;
          }
      }
    };

    const resendMessage = (message: Message) => {
      if (data.env.isH5) {
        data.showResend = true;
        data.resendMessage = message;
      } else {
        TUIServer.resendMessage(message).catch((error: any) => {
          handleErrorPrompts(error, data.env);
        });
        TUIAegis.getInstance().reportEvent({
          name: 'messageOptions',
          ext1: 'messageResend',
        });
      }
    };

    const submit = () => {
      TUIServer.resendMessage(data.resendMessage)
        .then(() => {
          data.showResend = false;
        })
        .catch((error: any) => {
          handleErrorPrompts(error, data.env);
          data.showResend = false;
        });
      TUIAegis.getInstance().reportEvent({
        name: 'messageOptions',
        ext1: 'messageResend',
      });
    };

    const handleEdit = (item: any) => {
      data.text = item.payload.text;
    };

    const toggleUserList = () => {
      data.userInfoView = !data.userInfoView;
    };

    const handleApplication = (options: any) => {
      TUIServer.handleGroupApplication(options);
    };

    const closeDialog = () => {
      toggleUserList();
    };

    const openMessage = (item: any) => {
      let url = '';
      switch (item.type) {
        case data.types.MSG_FILE:
          url = item.payload.fileUrl;
          break;
        case data.types.MSG_VIDEO:
          url = item.payload.remoteVideoUrl;
          break;
        case data.types.MSG_IMAGE:
          url = item.payload.imageInfoArray[0].url;
          break;
      }
      window.open(url, '_blank');
    };

    const geeks = (e: any) => {
      if (e.keyCode === 13) {
        e.preventDefault();
        if (e.ctrlKey) {
          e.target.value += '\n';
          data.text += '\n';
        }
      }
    };

    const inputChange = (e: any) => {
      if (data.inputComposition) {
        data.inputCompositionCont = e?.data ? e.data : '';
      }
      if (e.data === constant.at && data?.conversation?.type === constant.group) {
        const options: any = {
          groupID: data?.conversation?.groupProfile?.groupID,
          count: 100,
          offset: 0,
        };
        data.showGroupMemberList = true;
        GroupServer.getGroupMemberList(options).then((res: any) => {
          res.data.memberList = res.data.memberList.filter((item: any) => item.userID !== ProfileServer.currentStore.profile.userID);
          data.allMemberList = res.data.memberList;
        });
      }
      // 输入@和空格，默认值不是@人
      // input @ and Space，Default is not @ person
      if (e.data === ' ' && data.text.indexOf(constant.at) !== -1) {
        data.showGroupMemberList = false;
      }
    };
    const pasting = (e: any) => {
      if (e.clipboardData.files[0]) {
        TUIServer.sendImageMessage(e.clipboardData.files[0]);
      }
    };

    const getHistoryMessageList = async () => {
      await TUIServer.getHistoryMessageList().then(() => {
        scrollToTarget('target', messageEle?.value?.firstElementChild);
      });
    };

    const selectAt = async (type: string, item: any) => {
      let atName = '';
      switch (type) {
        case 'allMember':
          data.atText = constant.all;
          data.text = `${data.text}${constant.all}`;
          inputEle.value.focus();
          data.showGroupMemberList = false;
          (data.atType as any).push(TUIServer.TUICore.TIM.TYPES.MSG_AT_ALL);
          (data.atOneText as any).push({ name: constant.all, userID: TUIServer.TUICore.TIM.TYPES.MSG_AT_ALL });
          break;
        case 'oneMember':
          atName = item.nameCard || item.nick || item.userID;
          data.text += `${item.nameCard || item.nick || item.userID}`;
          // 为后续删除的@成员创建存储数组。
          // Create a stored array for subsequent deleted @ members.
          (data.atOneText as any).push({ name: atName, userID: item.userID });
          inputEle.value.focus();
          data.showGroupMemberList = false;
          (data.atType as any).push(item.userID);
          break;
      }
    };

    const deleteAt = (e: any) => {
      const array = data.atOneText;
      for (let index = 0; index < array.length; index++) {
        // 判断输入框中是否有@+尼克/名片/用户名字符串。
        // Judge whether there is a string of @ + Nick / namecard / userid in the input box.
        const flagName = `${constant.at}${(array[index] as any).name}`;
        if (data.text.indexOf(flagName) === -1) {
          const { userID } = array[index] as any;
          data.atType.splice((data.atType as any).indexOf(userID), 1);
          data.atOneText = [];
        }
      }
      return data.atType;
    };

    const jumpID = (messageID: string) => {
      data.referenceID = messageID;
      const list: any = [];
      // If the referenced message is in the current messageList, you can jump directly. Otherwise, you need to pull the historical message
      for (let index = 0; index < messages.value.length; index++) {
        list.push(messages?.value[index]?.ID);
        if (list.indexOf(messageID) !== -1 && messages.value[index]?.ID === messageID) {
          scrollToTarget('target', messageAimID.value[index]);
          messageAimID.value[index].getElementsByClassName('content')[0].classList.add('reference-content');
        }
      }
      if (list.indexOf(messageID) === -1) {
        TUIServer.getHistoryMessageList().then(() => {
          data.historyReference = true;
        });
      }
    };

    const toggleshowGroupMemberList = () => {
      data.showGroupMemberList = !data.showGroupMemberList;
    };

    const back = () => {
      TUIServer.TUICore.TUIServer.TUIConversation.handleCurrentConversation();
    };

    const openLink = (type: any) => {
      window.open(type.url);
      TUIAegis.getInstance().reportEvent({
        name: 'openLink',
        ext1: type.label,
      });
    };

    const compositionEnd = () => {
      data.inputComposition = false;
      data.inputCompositionCont = '';
    };

    const showReadReceiptDialog = async (message: any) => {
      if (
        message.conversationType !== TUIServer.TUICore.TIM.TYPES.CONV_GROUP
        || message.readReceiptInfo?.unreadCount === 0
      ) {
        return;
      }
      data.currentMessage = message;
      data.receiptDialogStatus = true;
    };

    const closeReadReceiptDialog = () => {
      data.currentMessage = {};
      data.receiptDialogStatus = false;
    };

    const handleScroll = () => {
      if (data.isFirstRender) {
        data.needToBottom = false;
        scrollToTarget('bottom');
        data.isFirstRender = false;
        return;
      }
      if (messageEle.value) {
        const { scrollHeight, scrollTop, clientHeight } = messageEle.value;
        if (
          scrollHeight - (scrollTop + clientHeight) <= clientHeight
          || messages.value[messages.value.length - 1]?.flow === 'out'
        ) {
          scrollToTarget('bottom');
        } else {
          handleToBottomTip(true);
        }
      }
    };

    const scrollToTarget = (type: string, targetElement?: HTMLElement) => {
      messageEle.value.removeEventListener('scroll', onScrolling);
      data.isUserAction = true;
      switch (type) {
        case constant.scrollType.toBottom:
          data.needToBottom = false;
          messageEle?.value?.lastElementChild.scrollIntoView(false);
          getImgLoad(messageEle?.value, 'message-img', async () => {
            messageEle?.value?.lastElementChild?.scrollIntoView(false);
            messageEle.value.addEventListener('scroll', onScrolling);
            await sendMessageReadInView('page');
          });
          break;
        case constant.scrollType.toTarget:
          targetElement?.scrollIntoView(false);
          getImgLoad(messageEle?.value, 'message-img', async () => {
            targetElement?.scrollIntoView(false);
            messageEle.value.addEventListener('scroll', onScrolling);
            await sendMessageReadInView('page');
          });
          break;
        default:
          break;
      }
    };

    const onScrolling = () => {
      const { scrollHeight, scrollTop, clientHeight } = messageEle.value;
      if (needGroupReceipt.value) {
        data.scroll.scrollHeight = scrollHeight;
        data.scroll.scrollTop = scrollTop;
        data.scroll.scrollTopMin = data.isUserAction
          ? data.scroll.scrollTopMin
          : Math.min(data.scroll.scrollTopMin, data.scroll.scrollTop);
        data.scroll.scrollTopMax = data.isUserAction
          ? data.scroll.scrollTopMax
          : Math.max(data.scroll.scrollTopMax, data.scroll.scrollTop);
      }
      if (scrollHeight - (scrollTop + clientHeight) > clientHeight) {
        handleToBottomTip(true);
      } else {
        handleToBottomTip(false);
      }
      data.isUserAction = false;
    };

    const handleToBottomTip = (needToBottom: boolean) => {
      switch (needToBottom) {
        case true:
          data.needToBottom = true;
          if (data?.conversation?.unreadCount && data?.conversation?.unreadCount > 0) {
            data.toBottomTipCont = `${data?.conversation?.unreadCount} ${t('TUIChat.条新消息')}`;
          } else {
            data.toBottomTipCont = t('TUIChat.回到最新位置');
          }
          break;
        case false:
          data.needToBottom = false;
          break;
        default:
          data.needToBottom = false;
          break;
      }
    };

    const sendMessageReadInView = async (type: string) => {
      if (!needGroupReceipt.value) {
        setMessageRead(data?.conversation?.conversationID);
        return;
      }
      if (data.messageInView.length) data.messageInView = [] as Message[];
      let start = 0;
      let end = 0;
      switch (type) {
        case constant.inViewType.page:
          start = data.scroll.scrollTop;
          end = data.scroll.scrollTop + messageEle?.value?.clientHeight;
          break;
        case constant.inViewType.scroll:
          start = data.scroll.scrollTopMin;
          end = data.scroll.scrollTopMax + messageEle?.value?.clientHeight;
          break;
        default:
          break;
      }
      for (let i = 0; i < messageAimID?.value?.length; i++) {
        if (isInView(type, messageAimID?.value[i], start, end)) {
          const message = messages.value[i];
          data.messageInView.push(message);
        }
      }
      await sendMessageReadReceipt(data.messageInView);
    };

    const isInView = (type: string, dom: HTMLElement, viewStart: number, viewEnd: number) => {
      const containerTop = messageEle.value.getBoundingClientRect().top;
      const containerBottom = messageEle.value.getBoundingClientRect().bottom;
      const { top, bottom } = dom.getBoundingClientRect();
      const { offsetTop, clientHeight } = dom;
      switch (type) {
        case constant.inViewType.page:
          return Math.round(top) >= Math.round(containerTop) && Math.round(bottom) <= Math.round(containerBottom);
        case constant.inViewType.scroll:
          return (
            Math.round(offsetTop) >= Math.round(viewStart)
            && Math.round(offsetTop + clientHeight) <= Math.round(viewEnd)
          );
        default:
          return false;
      }
    };

    return {
      ...toRefs(data),
      conversationType,
      messages,
      messageEle,
      inputEle,
      messageAimID,
      conversationData,
      conversationName,
      constant,
      sendMseeage,
      deleteAt,
      handleItem,
      handleMseeage,
      handleEdit,
      getHistoryMessageList,
      toggleUserList,
      handleApplication,
      handleTextMessageShowContext,
      handleImageMessageShowContext,
      handleVideoMessageShowContext,
      handleAudioMessageShowContext,
      handleFileMessageShowContext,
      handleFaceMessageShowContext,
      handleLocationMessageShowContext,
      handleMergerMessageShowContext,
      handleTipMessageShowContext,
      handleCustomMessageShowContext,
      pluginComponentList,
      handleSend,
      closeDialog,
      isMute,
      openMessage,
      geeks,
      pasting,
      setMessageRead,
      sendMessageReadReceipt,
      selectAt,
      inputChange,
      dialog,
      jumpID,
      back,
      slotDefault,
      toggleshowGroupMemberList,
      resendMessage,
      submit,
      Link,
      openLink,
      compositionEnd,
      showReadReceiptDialog,
      readReceiptDialog,
      closeReadReceiptDialog,
      scrollToTarget,
      needGroupReceipt,
    };
  },
});
export default TUIChat;
</script>

<style lang="scss" scoped src="./style/index.scss"></style>
