<template >
  <ul class="TUI-conversation-list" :class="[isH5 ? 'list-h5' : '']" @click="dialogID = ''" ref="dialog">
    <li
      class="TUI-conversation-item"
      :class="[currentID === item.conversationID && 'selected', item.isPinned && 'pinned']"
      v-for="(item, index) in data.list" :key="index"
      :id="item.conversationID"
      @click.prevent="handleListItem(item)"
      v-TUILongPress="handleLongItem"
      @click.prevent.right="handleItem(item, $event)">
      <aside class="left">
        <img class="avatar" :src="data.handleItemAvator(item)">
        <span class="num" v-if="item.unreadCount>0 && item.messageRemindType !== 'AcceptNotNotify'">
          {{item.unreadCount > 99 ? '99+' : item.unreadCount}}
        </span>
        <span class="num-notify" v-if="item.unreadCount>0 && item.messageRemindType === 'AcceptNotNotify'"></span>
      </aside>
      <div class="content">
        <div class="content-header">
          <label>
            <p class="name">{{data.handleItemName(item)}}</p>
          </label>
          <div class="middle-box">
              <span class="middle-box-at"  v-if="item.type === 'GROUP' && item.groupAtInfoList.length > 0">{{data.handleShowAt(item)}}</span>
              <p>{{data.handleShowMessage(item)}}</p>
          </div>
        </div>
        <div class="content-footer">
          <span class="time">{{data.handleItemTime(item.lastMessage.lastTime)}}</span>
          <img v-if="item.messageRemindType === 'AcceptNotNotify'" class="mute-icon" src="../../../../assets/icon/mute.svg">
          <i></i>
        </div>
      </div>
      <div class="dialog dialog-item"  v-if="item.conversationID===dialogID" >
        <p class="conversation-options" @click.stop="handleDeleteConversation('delete', dialogID)">{{$t('TUIConversation.删除会话')}}</p>
        <p class="conversation-options" v-if="!item.isPinned" @click.stop="handlePinConversation('ispinned', dialogID)">{{$t('TUIConversation.置顶会话')}}</p>
        <p class="conversation-options" v-if="item.isPinned" @click.stop="handlePinConversation('dispinned', dialogID)">{{$t('TUIConversation.取消置顶')}}</p>
        <p class="conversation-options" v-if="item.messageRemindType === '' || item.messageRemindType === 'AcceptAndNotify'" @click.stop="handleMuteConversation('mute', dialogID)">{{$t('TUIConversation.消息免打扰')}}</p>
        <p class="conversation-options" v-if="item.messageRemindType === 'AcceptNotNotify'" @click.stop="handleMuteConversation('notMute', dialogID)">{{$t('TUIConversation.取消免打扰')}}</p>
      </div>
    </li>
  </ul>

</template>
<script lang="ts">
import TUIAegis from '../../../../../utils/TUIAegis';
import { defineComponent, reactive, ref, toRefs, watchEffect } from 'vue';
import { onClickOutside } from '@vueuse/core';
const TUIConversationList:any = defineComponent({
  props: {
    data: {
      type: Object,
      default: () => ({}),
    },
    currentID: {
      type: String,
      default: () => '',
    },
    isH5: {
      type: Boolean,
      default: () => false,
    },
  },
  setup(props:any, ctx:any) {
    const obj = reactive({
      data: {},
      currentID: '',
      currentConversation: {},
      dialogID: '',
      currentuserID: '',
      conversationType: '',
      loop: 0,
    });

    const dialog:any = ref();
    const TUIServer:any = TUIConversationList?.TUIServer;

    onClickOutside(dialog, () => {
      obj.dialogID = '';
    });

    watchEffect(() => {
      obj.data = props.data;
      obj.currentID = props.currentID;
    });

    const handleListItem = (item: any) => {
      ctx.emit('handleItem', item);
    };

    const handleItem = (item:any, e:any) => {
      TUIAegis.getInstance().reportEvent({
        name: 'conversationOptions',
        ext1: 'conversationOptions',
      });
      e.target.oncontextmenu = function () {
        return false;
      };
      obj.currentConversation = item;
      obj.dialogID = item.conversationID;
      if  (item.type === 'C2C') {
        obj.currentuserID = item.userProfile.userID;
      } else if (item.type === 'GROUP') {
        obj.currentuserID = item.groupProfile.groupID;
      }
      obj.conversationType = item.type;
      // return obj.dialogID = '';
    };

    const handleLongItem  = (e:any) => {
      const target = (obj.data as any).list.filter((item:any) => item.conversationID === e.id)[0];
      if (!target || obj.dialogID !== target.conversationID) {
        return;
      }
      TUIAegis.getInstance().reportEvent({
        name: 'conversationOptions',
        ext1: 'conversationOptions',
      });
      obj.currentConversation = target;
      obj.dialogID = target.conversationID;
      if  (target.type === 'C2C') {
        obj.currentuserID = target.userProfile.userID;
      } else if (target.type === 'GROUP') {
        obj.currentuserID = target.groupProfile.groupID;
      }
      obj.conversationType = target.type;
    };

    const handleDeleteConversation = (type:string, dialogID:string) => {
      switch (type) {
        case 'delete':
          TUIServer.deleteConversation(dialogID).then((imResponse: any) => {
            TUIAegis.getInstance().reportEvent({
              name: 'conversationOptions',
              ext1: 'conversationDelete',
            });
            const { conversationID } = imResponse.data;
            const { conversation } = TUIServer.TUICore.getStore().TUIChat;
            // 删除会话，判断当前删除的会话是否为打开的会话
            // 若为打开的会话，通知 TUIChat 关闭当前会话
            // Delete session: judge whether the currently deleted session is an open session
            // If it is an open session, notify tuichat to close the current session
            if (conversation.conversationID === conversationID) {
              TUIServer.TUICore.getStore().TUIChat.conversation = {
                conversationID: '',
              };
            }
            obj.dialogID = '';
          });
          break;
      }
    };

    const handlePinConversation = (type:string, dialogID:string) => {
      switch (type) {
        case 'ispinned':
          if (type === 'ispinned') {
            const options:any = {
              conversationID: dialogID,
              isPinned: true,
            };
            TUIServer.pinConversation(options);
          }
          break;
        case 'dispinned':
          if (type === 'dispinned') {
            const options: any = {
              conversationID: dialogID,
              isPinned: false,
            };
            TUIServer.pinConversation(options);
          }
          break;
      }
      obj.dialogID = '';
    };

    const handleMuteConversation = (type:string) => {
      switch (type) {
        case 'mute':
          if (type === 'mute' && obj.conversationType === 'C2C')  {
            const options: any = {
              userIDList: [obj.currentuserID],
              messageRemindType: TUIServer.TUICore.TIM.TYPES.MSG_REMIND_ACPT_NOT_NOTE,
            };
            TUIServer.muteConversation(options);
          } else if (type === 'mute' && obj.conversationType === 'GROUP') {
            const options: any = {
              groupID: obj.currentuserID,
              messageRemindType: TUIServer.TUICore.TIM.TYPES.MSG_REMIND_ACPT_NOT_NOTE,
            };
            TUIServer.muteConversation(options);
          }
          break;
        case 'notMute':
          if (type === 'notMute' && obj.conversationType === 'C2C') {
            const options: any = {
              userIDList: [obj.currentuserID],
              messageRemindType: TUIServer.TUICore.TIM.TYPES.MSG_REMIND_ACPT_AND_NOTE,
            };
            TUIServer.muteConversation(options);
          } else if (type === 'notMute' && obj.conversationType === 'GROUP') {
            const options: any = {
              groupID: obj.currentuserID,
              messageRemindType: TUIServer.TUICore.TIM.TYPES.MSG_REMIND_ACPT_AND_NOTE,
            };
            TUIServer.muteConversation(options);
          }
          break;
      }
      obj.dialogID = '';
    };

    return {
      ...toRefs(obj),
      handleListItem,
      handleItem,
      handleDeleteConversation,
      handlePinConversation,
      handleMuteConversation,
      dialog,
      handleLongItem,
    };
  },
});
export default TUIConversationList;
</script>
<style lang="scss" scoped src="./style/conversationList.scss"></style>
