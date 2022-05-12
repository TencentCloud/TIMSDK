<template>
  <div class="TUIChat" v-if="conversationType === 'chat'">
    <header class="TUIChat-header">
      <h1>{{ conversationName }}</h1>
      <Manage
        class="setting"
        v-if="conversation.groupProfile"
        :conversation="conversation"
        :userInfo="userInfo"
      />
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
        <li v-for="(item, index) in messages" :key="index">
          <MessageTip
            v-if="item.type === types.MSG_GRP_TIP"
            :data="handleTipMessageShowContext(item)"
          />
          <MessageBubble v-else-if="!item.isRevoked" :data="item">
            <MessageText
              v-if="item.type === types.MSG_TEXT"
              :data="handleTextMessageShowContext(item)"
            />
            <MessageImage
              v-if="item.type === types.MSG_IMAGE"
              :data="handleImageMessageShowContext(item)"
            />
            <MessageVideo
              v-if="item.type === types.MSG_VIDEO"
              :data="handleVideoMessageShowContext(item)"
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
                <p
                  v-if="
                    item.type === types.MSG_FILE ||
                    item.type === types.MSG_VIDEO ||
                    item.type === types.MSG_IMAGE
                  "
                  @click="openMessage(item)"
                >
                  {{ $t("TUIChat.打开") }}
                </p>
                <p
                  v-if="item.status === 'success'"
                  @click="handleMseeage(item, 'forward')"
                >
                  {{ $t("TUIChat.转发") }}
                </p>
                <p
                  v-if="item.flow === 'out' && item.status === 'success'"
                  @click="handleMseeage(item, 'revoke')"
                >
                  {{ $t("TUIChat.撤回") }}
                </p>
                <p
                  v-if="item.status === 'success'"
                  @click="handleMseeage(item, 'delete')"
                >
                  {{ $t("TUIChat.删除") }}
                </p>
                <p
                  v-if="item.flow === 'out' && item.status === 'fail'"
                  @click="handleMseeage(item, 'resend')"
                >
                  {{ $t("TUIChat.重新发送") }}
                </p>
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
      :class="[isMute && 'disabled']"
      @click="setMessageRead(conversation.conversationID)"
    >
      <div class="func">
        <component
          v-for="(item, index) in pluginComponentList"
          :key="index"
          :isMute="isMute"
          :is="item"
          @send="handleSend"
        ></component>
      </div>
      <div class="input">
        <textarea
          ref="inputEle"
          @paste="pasting"
          v-if="!isMute"
          v-model="text"
          :placeholder="$t('TUIChat.请输入消息')"
          data-type="text"
          @keyup.enter="sendMseeage"
          @keypress="geeks"
        ></textarea>
        <p v-else>{{ $t(`TUIChat.${muteText}`) }}</p>
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
  <slot v-else />
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

import TUIAegis from '../../../utils/TUIAegis';
import Error from '../error';

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
    const data = reactive({
      messageList: [
        {
          progress: 0,
        },
      ],
      conversation: {},
      text: '',
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
    });

    // 调用 TUIConversation 模块的 setMessageRead 方法
    // 消息已读
    const setMessageRead = (conversationID: string) => {
      TUIServer?.TUICore?.TUIServer?.TUIConversation?.setMessageRead(conversationID);
    };

    // 配置发送消息功能区功能
    const pluginComponentList: any = [];
    Object.keys(getComponents('send')).forEach((name: any) => {
      pluginComponentList.push(name);
    });

    // 用户管理模块绑定TUIServer
    Manage.TUIServer = TUIServer;
    Manage.GroupServer = TUIServer?.TUICore?.TUIServer?.TUIGroup;

    const messageEle = ref();
    const inputEle: any = ref();

    // TUIChat的数据绑定到TUIServer上，保证数据唯一性
    TUIServer.bind(data);

    // 当前会话资料
    const conversationData = {
      list: [],
      // 处理头像
      handleAvatar,
      // 处理昵称
      handleName,
    };

    // 判断当前会话类型：无/系统会话/正常C2C、群聊
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
          // eslint-disable-next-line vue/no-side-effects-in-computed-properties
          data.muteText = '管理员开启全员禁言';
          return true;
        }
        const time: number = new Date().getTime();
        if ((data.selfInfo as any)?.muteUntil * 1000 - time > 0) {
          // eslint-disable-next-line vue/no-side-effects-in-computed-properties
          data.muteText = '您已被管理员禁言';
          return true;
        }
      }
      return false;
    });

    // 展示会话名称: 系统通知/C2C-对方用户ID或昵称/群聊-群名称或群ID
    const conversationName = computed(() => {
      const { conversation } = data;
      return handleName(conversation);
    });

    // 不展示已删除消息
    const messages = computed(() => data.messageList.filter((item: any) => !item.isDeleted));

    // 监听数据初次渲染，展示最新一条消息
    watch(
      messages,
      (newVal: any, oldVal: any) => {
        nextTick(() => {
          messageEle?.value?.lastElementChild?.scrollIntoView(false);
          getImgLoad(messageEle?.value, 'message-img', (res: any) => {
            messageEle?.value?.lastElementChild?.scrollIntoView(false);
          });
        });
      },
      { deep: true },
    );

    // 处理需要合并的数据
    const handleSend = (emo: any) => {
      data.text += emo.name;
      inputEle.value.focus();
    };

    // 发送消息
    const sendMseeage = async () => {
      const text = data.text.trimEnd();
      data.text = '';
      if (text) {
        try {
          await TUIServer.sendTextMessage(JSON.parse(JSON.stringify(text)));
          TUIAegis.getInstance().reportEvent({
            name: 'time',
            ext1: 'firstSendmessageTime',
          });
        } catch (error: any) {
          TUIMessage({ message: Error[error.code] || error });
          TUIAegis.getInstance().reportEvent({
            name: 'sendMessage',
            ext1: error,
          });
        }
      }
    };

    // 右键消息，展示处理功能
    const handleItem = (item: any) => {
      data.currentMessage = item;
      data.dialogID = item.ID;
    };

    // 处理消息
    const handleMseeage = async (message: any, type: string) => {
      switch (type) {
        case 'revoke':
          try {
            await TUIServer.revokeMessage(message);
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
      }
    };

    // 重新编辑
    const handleEdit = (item: any) => {
      data.text = item.payload.text;
    };

    // 显示/隐藏 用户信息列表
    const toggleUserList = () => {
      data.userInfoView = !data.userInfoView;
    };

    // 系统信息 -- 处理/拒绝加群申请
    const handleApplication = (options: any) => {
      TUIServer.handleGroupApplication(options);
    };

    const closeDialog = () => {
      toggleUserList();
    };

    // 打开视频、图片、文件
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

    const pasting = (e: any) => {
      if (e.clipboardData.files[0]) {
        TUIServer.sendImageMessage(e.clipboardData.files[0]);
      }
    };

    // 查看更多
    const getHistoryMessageList = () => {
      TUIServer.getHistoryMessageList();
    };

    return {
      ...toRefs(data),
      conversationType,
      messages,
      messageEle,
      inputEle,
      conversationData,
      conversationName,
      sendMseeage,
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
    };
  },
});
export default TUIChat;
</script>

<style lang="scss" scoped>
@import "../../styles/TUIChat.scss";
</style>
