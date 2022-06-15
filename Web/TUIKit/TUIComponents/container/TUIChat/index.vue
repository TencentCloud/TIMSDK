<template>
  <div class="TUIChat" :class="[env.isH5 ? 'TUIChat-H5' : '']" v-if="conversationType === 'chat'">
    <header class="TUIChat-header">
      <i class="icon icon-back" @click="back" v-if="env.isH5"></i>
      <h1>{{ conversationName }}</h1>
      <aside class="setting">
        <Manage
          v-if="conversation.groupProfile"
          :conversation="conversation"
          :userInfo="userInfo"
          :isH5="env.isH5"
        />
      </aside>
    </header>
    <div
      class="TUIChat-main"
      @click="setMessageRead(conversation.conversationID)"
    >
      <ul
        class="TUI-message-list"
        @click="dialogID = ''"
        ref="messageEle"
        id="messageEle"
      >
        <p
          class="message-more"
          @click="getHistoryMessageList"
          v-if="!isCompleted"
        >
          {{ $t("TUIChat.查看更多") }}
        </p>
        <li v-for="(item, index) in messages" :key="index" id="messageAimID" ref="messageAimID" >
          <MessageTip
            v-if="item.type === types.MSG_GRP_TIP"
            :data="handleTipMessageShowContext(item)"
          />
          <MessageBubble v-else-if="!item.isRevoked" :data="item" :messagesList="messages" @jumpID="jumpID" >
            <MessageText
              v-if="item.type === types.MSG_TEXT"
              :data="handleTextMessageShowContext(item)"
            />
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
            <MessageAudio
              v-if="item.type === types.MSG_AUDIO"
              :data="handleAudioMessageShowContext(item)"
            />
            <MessageFile
              v-if="item.type === types.MSG_FILE"
              :data="handleFileMessageShowContext(item)"
            />
            <MessageFace
              v-if="item.type === types.MSG_FACE"
              :data="handleFaceMessageShowContext(item)"
            />
            <MessageLocation
              v-if="item.type === types.MSG_LOCATION"
              :data="handleLocationMessageShowContext(item)"
            />
            <MessageCustom
              v-if="item.type === types.MSG_CUSTOM"
              :data="handleCustomMessageShowContext(item)"
            />
            <MessageMerger
              v-if="item.type === types.MSG_MERGER"
              :data="handleMergerMessageShowContext(item)"
            />
            <template #dialog>
              <ul class="dialog-item">
                <li
                  v-if="
                    item.type === types.MSG_FILE ||
                    item.type === types.MSG_VIDEO ||
                    item.type === types.MSG_IMAGE
                  "
                  @click="openMessage(item)"
                >
                  <i class="icon icon-msg-copy"></i>
                  <span>{{ $t("TUIChat.打开") }}</span>
                </li>
                <li
                  v-if="item.status === 'success'"
                  @click="handleMseeage(item, 'forward')"
                >
                  <i class="icon icon-msg-forward"></i>
                  <span>{{ $t("TUIChat.转发") }}</span>
                </li>
                <li
                  v-if="item.status === 'success'"
                  @click="handleMseeage(item, 'reply')"
                >
                  <i class="icon icon-msg-reply"></i>
                  <span>{{ $t("TUIChat.回复") }}</span>
                </li>
                <li
                  v-if="item.flow === 'out' && item.status === 'success'"
                  @click="handleMseeage(item, 'revoke')"
                >
                  <i class="icon icon-msg-revoke"></i>
                  <span>{{ $t("TUIChat.撤回") }}</span>
                </li>
                <li
                  v-if="item.status === 'success'"
                  @click="handleMseeage(item, 'delete')"
                >
                  <i class="icon icon-msg-del"></i>
                  <span>{{ $t("TUIChat.删除") }}</span>
                </li>
                <li
                  v-if="item.flow === 'out' && item.status === 'fail'"
                  @click="handleMseeage(item, 'resend')"
                >
                  <i class="icon icon-msg-resend"></i>
                  <span>{{ $t("TUIChat.重新发送") }}</span>
                </li>


              </ul>
            </template>
          </MessageBubble>
          <MessageRevoked
            v-else
            :isEdit="item.type === types.MSG_TEXT"
            :data="item"
            @edit="handleEdit(item)"
          />
        </li>
      </ul>
      <div
        class="dialog dialog-conversation"
        v-if="forwardStatus && messageComponents.Forward"
      >
        <component
          :is="'Forward'"
          :list="conversationData.list"
          :message="currentMessage"
          :show="forwardStatus"
          :isH5="env.isH5"
          @update:show="(e) => (forwardStatus = e)"
        >
          <template #item="{ data }">
            <img class="avatar" :src="conversationData.handleAvatar(data)" />
            <label class="name">{{ conversationData.handleName(data) }}</label>
          </template>
        </component>
      </div>
    </div>
    <div
      class="TUIChat-footer"
      :class="[isMute && 'disabled', env.isH5 && 'TUIChat-H5-footer']"
      @click="setMessageRead(conversation.conversationID)"
    >
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
      <div class="input">
        <div class="memberList" v-if="showGroupMemberList">
          <ul class="memberList-box" ref="dialog">
            <header class="memberList-box-title" v-if="env.isH5">
              <h1>选择提醒的人</h1>
              <span class="close" @click="toggleshowGroupMemberList">关闭</span>
            </header>
            <li class="memberList-box-header" @click="selectAt('allMember', allMember)" >
              <img src="../../assets/icon/at.svg" alt="">
              <span>{{allMember[0].allText}}</span>
              <span>({{allMemberList.length}})</span>
            </li>
            <li class="memberList-box-body" v-for="(item, index) in allMemberList" :key="index" @click="selectAt('oneMember', item)">
              <img :src="item.avatar" alt="">
              <span>{{item.nick? item.nick: item.userID}}</span>
            </li>
          </ul>
        </div>
        <div class="reference">
        <div class="reference-box" v-if="showReference">
          <i></i>
          <div class="reference-box-show">
            <span>{{referenceMessage.nick? referenceMessage.nick: referenceMessage.from}}</span>
            <span>{{referenceMessageForShow}}</span>
          </div>
          <label class="icon icon-cancel" @click="showReference = false"></label>
        </div>
      </div>
        <textarea
          ref="inputEle"
          @paste="pasting"
          v-if="!isMute && !env.isH5"
          v-model="text"
          :placeholder="$t('TUIChat.请输入消息')"
          data-type="text"
          @input="inputChange"
          @keyup.enter="sendMseeage"
          @keyup.delete="deleteAt"
          @keypress="geeks"
        ></textarea>
        <input type="text"
          ref="inputEle"
          @paste="pasting"
          v-if="!isMute && env.isH5"
          v-model="text"
          :placeholder="$t('TUIChat.请输入消息')"
          data-type="text"
          enterkeyhint="send"
          @input="inputChange"
          @keyup.enter="sendMseeage"
          @keypress="geeks">
        <p v-if="isMute">{{ $t(`TUIChat.${muteText}`) }}</p>
        <button
          v-if="!isMute"
          class="input-btn"
          data-type="text"
          :disabled="!text"
          @click="sendMseeage"
        >
          <p class="input-btn-hover">
            {{ $t("TUIChat.按Enter发送，Ctrl+Enter换行") }}
          </p>
          {{ $t("发送") }}
        </button>
      </div>
    </div>
  </div>
  <div class="TUIChat" v-else-if="conversationType === 'system'">
    <header class="TUIChat-header">
      <h1>{{ conversationName }}</h1>
    </header>
    <MessageSystem
      :data="messages"
      :types="types"
      @application="handleApplication"
    />
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
} from './untils/untis';

import { getComponents } from './index';
import TUIMessage from '../../components/message';

import { useStore } from 'vuex';
import TUIAegis from '../../../utils/TUIAegis';
import Error from '../error';
import constant from '../constant';

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

  setup(props) {
    const { TUIServer } = TUIChat;
    const GroupServer = TUIServer?.TUICore?.TUIServer?.TUIGroup;
    const ProfileServer = TUIServer?.TUICore?.TUIServer?.TUIProfile;
    const data = reactive({
      messageList: [
        {
          progress: 0,
        },
      ],
      conversation: {},
      text: '',
      atText: '',
      types: TUIServer.TUICore.TIM.TYPES,
      currentMessage: {},
      dialogID: '',
      forwardStatus: false,
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
      referenceMessage: {},
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
    });

    const slotDefault = !!useSlots().default;

    // 调用 TUIConversation 模块的 setMessageRead 方法
    // 消息已读
    // Using the setmessageread method of the tuiconversion module
    const setMessageRead = (conversationID: string) => {
      TUIServer?.TUICore?.TUIServer?.TUIConversation?.setMessageRead(conversationID);
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

    TUIServer.bind(data);

    const VuexStore = useStore();

    const conversationData = {
      list: [],
      handleAvatar,
      handleName,
    };

    const dialog:any = ref();

    onClickOutside(dialog, () => {
      data.showGroupMemberList = false;
    });

    const conversationType = computed(() => {
      const { conversation }: any = data;
      if (!conversation?.conversationID) {
        return '';
      }
      if (conversation?.type === TUIServer.TUICore.TIM.TYPES.CONV_SYSTEM) {
        return 'system';
      }
      return 'chat';
    });

    const isMute = computed(() => {
      const { conversation }: any = data;
      if (conversation?.type === TUIServer.TUICore.TIM.TYPES.CONV_GROUP) {
        const userRole = conversation?.groupProfile?.selfInfo.role;
        const isMember = userRole === TUIServer.TUICore.TIM.TYPES.GRP_MBR_ROLE_MEMBER;
        if (isMember && conversation?.groupProfile?.muteAllMembers) {
          return true;
        }
        const time: number = new Date().getTime();
        if ((data.selfInfo as any)?.muteUntil * 1000 - time > 0) {
          return true;
        }
      }
      return false;
    });

    watch(isMute, (newVal: any, oldVal: any) => {
      const { conversation }: any = data;
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


    const messages = computed(() => data.messageList.filter((item: any) => !item.isDeleted));


    watch(
      messages,
      (newVal: any, oldVal: any) => {
        nextTick(() => {
          const isTheSameMessage = newVal[newVal.length - 1]?.ID === oldVal[oldVal.length - 1]?.ID;
          if (newVal.length === 0 || isTheSameMessage) {
            return;
          }
          messageEle?.value?.lastElementChild?.scrollIntoView(false);
          getImgLoad(messageEle?.value, 'message-img', (res: any) => {
            messageEle?.value?.lastElementChild?.scrollIntoView(false);
          });
          data.isFirstRender = false;
        });
        if (data.historyReference) {
          for (let index = 0; index < messages.value.length; index++) {
            if ((messages.value[index] as any).ID === data.referenceID) {
              (messageAimID.value[index]).scrollIntoView(false);
              messageAimID.value[index].getElementsByClassName('content')[0].classList.add('reference-content');
            }
          }
          data.historyReference = false;
        }
      },
      { deep: true },
    );


    const handleSend = (emo: any) => {
      data.text += emo.name;
      if (!data.env.isH5) {
        inputEle.value.focus();
      }
    };


    const sendMseeage = async () => {
      let messageReply: any = {};
      const text = data.text.trimEnd();
      data.text = '';
      if (data.showReference) {
        messageReply =  { messageReply: {
          messageAbstract: data.referenceMessageForShow,
          messageSender: (data.referenceMessage as any).nick ||  (data.referenceMessage as any).from,
          messageID: (data.referenceMessage as any).ID,
          messageType: data.referenceMessageType,
          version: 1,
        } };
        try {
          await TUIServer.sendTextMessage(JSON.parse(JSON.stringify(text)), messageReply);
        } catch (error: any) {
          TUIMessage({ message: Error[error.code] || error });
        }
      }
      if (text && data.atType.length === 0 && data.showReference === false) {
        try {
          await TUIServer.sendTextMessage(JSON.parse(JSON.stringify(text)));
          data.showReference = false;
          if (data.isFirstSend) {
            TUIAegis.getInstance().reportEvent({
              name: 'time',
              ext1: 'firstSendmessageTime',
            });
            data.isFirstSend = false;
          }
        } catch (error: any) {
          TUIMessage({ message: Error[error.code] || error });
          TUIAegis.getInstance().reportEvent({
            name: 'sendMessage',
            ext1: error,
          });
        }
      }
      if (data.atType.length > 0) {
        const options:any = {
          to: (data.conversation as any).groupProfile.groupID,
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
      data.showReference = false;
      VuexStore.commit('handleTask', 0);
      return data.atType = [];
    };


    const handleItem = (item: any) => {
      data.currentMessage = item;
      data.dialogID = item.ID;
    };


    const handleMseeage = async (message: any, type: string) => {
      switch (type) {
        case 'revoke':
          try {
            await TUIServer.revokeMessage(message);
            VuexStore.commit('handleTask', 1);
          } catch (error) {
            TUIMessage({ message: error });
          }
          data.dialogID = '';
          break;
        case 'delete':
          await TUIServer.deleteMessage([message]);
          data.dialogID = '';
          break;
        case 'resend':
          await TUIServer.resendMessage(message);
          data.dialogID = '';
          break;
        case 'forward':
          data.currentMessage = message;
          data.dialogID = '';
          conversationData.list = TUIServer.TUICore.getStore().TUIConversation.conversationList;
          data.forwardStatus = true;
          break;
        case 'reply':
          data.showReference = true;
          data.referenceMessage = message;
          switch (message.type) {
            case data.types.MSG_TEXT:
              data.referenceMessageForShow = message.payload.text;
              data.referenceMessageType = constant.typeText;
              break;
            case data.types.MSG_CUSTOM:
              data.referenceMessageForShow = '[自定义消息]';
              data.referenceMessageType = constant.typeCustom;
              break;
            case data.types.MSG_IMAGE:
              data.referenceMessageForShow = '[图片]';
              data.referenceMessageType = constant.typeImage;
              break;
            case data.types.MSG_AUDIO:
              data.referenceMessageForShow = '[语音]';
              data.referenceMessageType = constant.typeAudio;
              break;
            case data.types.MSG_VIDEO:
              data.referenceMessageForShow = '[视频]';
              data.referenceMessageType = constant.typeVideo;
              break;
            case data.types.MSG_FILE:
              data.referenceMessageForShow = '[文件]';
              data.referenceMessageType = constant.typeFile;
              break;
            case data.types.MSG_FACE:
              data.referenceMessageForShow = '[表情]';
              data.referenceMessageType = constant.typeFace;
              break;
          }
      }
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
      if (e.keyCode === 13 && e.ctrlKey) {
        e.target.value += '\n';
      }
    };

    const inputChange = (e:any) => {
      if (e.data === constant.at && (data.conversation as any).type === constant.group) {
        const options: any = {
          groupID: (data.conversation as any).groupProfile.groupID,
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


    const getHistoryMessageList = () => {
      TUIServer.getHistoryMessageList();
    };

    const selectAt = async (type: string, item: any) => {
      let atName = '';
      switch (type) {
        case 'allMember':
          data.atText = constant.all;
          data.text = `${data.text}${constant.all}`;
          inputEle.value.focus();
          data.showGroupMemberList = false;
          (data.atType as any).push(TUIServer.TUICore.TIM.TYPES.MSG_AT_ALL) ;
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

    const deleteAt = (e:any) => {
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

    const jumpID =  (messageID: string) => {
      data.referenceID = messageID;
      const list:any = [];
      // If the referenced message is in the current messageList, you can jump directly. Otherwise, you need to pull the historical message
      for (let index = 0; index < messages.value.length; index++) {
        list.push((messages.value[index] as any).ID);
        if (list.indexOf(messageID) !== -1 && (messages.value[index] as any).ID === messageID) {
          (messageAimID.value[index]).scrollIntoView(false);
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

    return {
      ...toRefs(data),
      conversationType,
      messages,
      messageEle,
      inputEle,
      messageAimID,
      conversationData,
      conversationName,
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
      selectAt,
      inputChange,
      dialog,
      jumpID,
      back,
      slotDefault,
      toggleshowGroupMemberList,
    };
  },
});
export default TUIChat;
</script>

<style lang="scss" scoped src="./style/index.scss"></style>
