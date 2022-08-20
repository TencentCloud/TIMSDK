<template>
  <div
    class="read-receipt"
    :class="[isH5 ? 'read-receipt-H5' : '', isMenuOpen ? 'read-receipt-menu-open' : '']"
    v-if="show"
    ref="dialog"
  >
    <div class="header">
      <div class="header-title">
        <span>{{ $t('TUIChat.消息详情') }}</span>
      </div>
      <div class="header-close">
        <i class="icon icon-close" @click="toggleShow"></i>
      </div>
    </div>
    <div class="body">
      <div v-if="isH5" class="body-message">
        <div class="message">
          <div class="message-info">
            <span>{{ message.from }}</span>
            <span>{{ caculateTimeago(message.time * 1000) }}</span>
          </div>
          <div class="message-cont">
            <p>
              {{ showMessage() }}
            </p>
          </div>
        </div>
      </div>
      <div class="body-tab">
        <template v-for="(val, key) in readReceiptList">
          <div
            class="tab-item"
            :class="key === showListNow && 'tab-item-now'"
            v-if="val.show"
            :key="key"
            @click="showListNow = key"
          >
            <div class="tab-item-title">{{ val?.label }}</div>
            <div class="tab-item-count">{{ val?.count }}</div>
          </div>
        </template>
      </div>
      <div class="body-list">
        <ul>
          <li v-for="(item, index) in readReceiptList[showListNow].userList" :key="index" class="body-list-item">
            <img
              class="avatar"
              :src="item?.avatar || 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
              onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'"
            />
            <span class="name">{{ item?.nick || item?.userID }}</span>
          </li>
        </ul>
        <div class="more" v-if="!readReceiptList[showListNow].isCompleted" @click="getMoreList">查看更多</div>
      </div>
    </div>
  </div>
</template>
<script lang="ts">
import { defineComponent, reactive, watchEffect, toRefs, watch, ref } from 'vue';
import { onClickOutside } from '@vueuse/core';
import { caculateTimeago } from '../../../utils';
import { Message, userListItem } from '../../interface';
const ReadReceiptDialog = defineComponent({
  type: 'custom',
  props: {
    message: {
      type: Object,
      default: () => ({}),
    },
    isH5: {
      type: Boolean,
      default: false,
    },
    show: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props: any, ctx: any) {
    const { t } = (window as any).TUIKitTUICore.config.i18n.useI18n();
    const data = reactive({
      message: {} as Message,
      isGroup: false,
      show: false,
      isH5: false,
      readReceiptList: [
        {
          label: props.isH5 ? t('TUIChat.人已读') : t('TUIChat.已读'),
          count: 0,
          userList: [] as userListItem[],
          isCompleted: true,
          cursor: '',
          show: true,
        },
        {
          label: props.isH5 ? t('TUIChat.人未读') : t('TUIChat.未读'),
          count: 0,
          userList: [] as userListItem[],
          isCompleted: true,
          cursor: '',
          show: true,
        },
        {
          label: props.isH5 ? t('TUIChat.人关闭阅读状态') : t('TUIChat.关闭阅读状态'),
          count: 0,
          userList: [] as userListItem[],
          isCompleted: true,
          cursor: '',
          show: false,
        },
      ],
      showListNow: 0,
      isMenuOpen: true,
    });

    const dialog: any = ref();

    watchEffect(() => {
      data.show = props.show;
      data.isH5 = props.isH5;
    });

    watch(
      () => {
        props.message, data.show;
      },
      async () => {
        if (!data.show) return;
        handleDialogPosition();
        data.message = props.message;
        isGroup();
        data.readReceiptList[0].count = data.message?.readReceiptInfo?.readCount || data.readReceiptList[0].count;
        data.readReceiptList[1].count = data.message?.readReceiptInfo?.unreadCount || data.readReceiptList[1].count;
        getReadList();
        getUnreadList();
      },
      { deep: true }
    );

    const toggleShow = () => {
      data.show = !data.show;
      if (!data.show) {
        ctx.emit('closeDialog');
        close();
      }
    };

    onClickOutside(dialog, () => {
      data.show = false;
      ctx.emit('closeDialog');
      close();
    });

    const getReadList = async (more = false) => {
      if (!data.isGroup || !data.message || Object.keys(data.message).length === 0) return;
      const obj = await ReadReceiptDialog.TUIServer.getGroupReadMemberList(
        data.message,
        data.readReceiptList[0].cursor
      );
      data.readReceiptList[0].isCompleted = obj?.data?.isCompleted;
      data.readReceiptList[0].cursor = obj?.data?.cursor || '';
      const list = obj.data.readUserIDList;
      const readList: userListItem[] = await handleAvatarAndName(list);
      data.readReceiptList[0].userList = more
        ? ([...data.readReceiptList[0].userList, ...readList] as userListItem[])
        : readList;
    };

    const getUnreadList = async (more = false) => {
      if (!data.isGroup || !data.message || Object.keys(data.message).length === 0) return;
      const obj = await ReadReceiptDialog.TUIServer.getGroupUnreadMemberList(
        data.message,
        data.readReceiptList[1].cursor
      );
      data.readReceiptList[1].isCompleted = obj?.data.isCompleted;
      data.readReceiptList[1].cursor = obj?.data?.cursor || '';
      const list = obj.data.unreadUserIDList;
      const unreadList: userListItem[] = await handleAvatarAndName(list);
      data.readReceiptList[1].userList = more
        ? ([...data.readReceiptList[1].userList, ...unreadList] as userListItem[])
        : unreadList;
    };

    const handleAvatarAndName = async (list: any) => {
      const avatarAndNameList: userListItem[] = [];
      if (list.length && data.isGroup) {
        const obj = await ReadReceiptDialog.TUIServer.getUserProfile(list);
        const userProfileList = obj.data;
        userProfileList.forEach((item: any) => {
          avatarAndNameList.push({
            nick: item?.nick,
            avatar: item?.avatar,
            userID: item?.userID,
          });
        });
      }
      return avatarAndNameList;
    };

    const isGroup = () => {
      if (data.message?.conversationType === ReadReceiptDialog.TUIServer.TUICore.TIM.TYPES.CONV_GROUP) {
        data.isGroup = true;
      } else {
        data.isGroup = false;
      }
      return;
    };

    const getMoreList = () => {
      switch (data.showListNow) {
        case 0:
          getReadList(true);
          break;
        case 1:
          getUnreadList(true);
          break;
        default:
          break;
      }
    };

    const close = () => {
      data.message = {};
      data.readReceiptList = [
        {
          label: t('TUIChat.已读'),
          count: 0,
          userList: [] as userListItem[],
          isCompleted: true,
          cursor: '',
          show: true,
        },
        {
          label: t('TUIChat.未读'),
          count: 0,
          userList: [] as userListItem[],
          isCompleted: true,
          cursor: '',
          show: true,
        },
        {
          label: t('TUIChat.关闭阅读状态'),
          count: 0,
          userList: [] as userListItem[],
          isCompleted: true,
          cursor: '',
          show: false,
        },
      ];
      data.showListNow = 0;
    };

    const showMessage = () => {
      let messageForShow = '';
      if (!data.message) return messageForShow;
      switch ((data.message as any).type) {
        case ReadReceiptDialog.TUIServer.TUICore.TIM.TYPES.MSG_TEXT:
          messageForShow = (data.message as any).payload.text;
          return messageForShow;
        case ReadReceiptDialog.TUIServer.TUICore.TIM.TYPES.MSG_CUSTOM:
          messageForShow = t('TUIChat.自定义消息');
          return messageForShow;
        case ReadReceiptDialog.TUIServer.TUICore.TIM.TYPES.MSG_IMAGE:
          messageForShow = t('TUIChat.图片');
          return messageForShow;
        case ReadReceiptDialog.TUIServer.TUICore.TIM.TYPES.MSG_AUDIO:
          messageForShow = t('TUIChat.语音');
          return messageForShow;
        case ReadReceiptDialog.TUIServer.TUICore.TIM.TYPES.MSG_VIDEO:
          messageForShow = t('TUIChat.视频');
          return messageForShow;
        case ReadReceiptDialog.TUIServer.TUICore.TIM.TYPES.MSG_FILE:
          messageForShow = t('TUIChat.文件');
          return messageForShow;
        case ReadReceiptDialog.TUIServer.TUICore.TIM.TYPES.MSG_FACE:
          messageForShow = t('TUIChat.表情');
          return messageForShow;
      }
    };

    const handleDialogPosition = () => {
      data.isMenuOpen = !!document?.getElementsByClassName('home-menu')?.length;
    };

    return {
      ...toRefs(data),
      dialog,
      toggleShow,
      getReadList,
      getUnreadList,
      isGroup,
      handleAvatarAndName,
      close,
      getMoreList,
      showMessage,
      caculateTimeago,
      handleDialogPosition,
    };
  },
});
export default ReadReceiptDialog;
</script>
<style lang="scss" scoped src="./style/index.scss"></style>
