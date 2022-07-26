<template >
  <ul class="TUI-conversation-list" :class="[isH5 ? 'list-h5' : '']" ref="list" @mousewheel="scrollChange" @scroll="scrollChange">
    <LiteItem
      :isH5="isH5"
      v-for="(item, index) in data.list"
      :key="index"
      :currentID="currentID"
      :conversation="item"
      :toggleID="toggleID"
      :handleConversation="{
        avator: data.handleItemAvator,
        name: data.handleItemName,
        showAt: data.handleShowAt,
        showMessage: data.handleShowMessage,
        time: data.handleItemTime
      }"
      @toggle="handleToggleListItem"
      @open="handleListItem"
      @handle="handleItem"/>
  </ul>

</template>
<script lang="ts">
import TUIAegis from '../../../../../utils/TUIAegis';
import { defineComponent, reactive, ref, toRefs, watchEffect } from 'vue';
import LiteItem from '../list-item';
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
  components: { LiteItem },
  setup(props:any, ctx:any) {
    const obj = reactive({
      data: {},
      currentID: '',
      toggleID: '',
    });
    const TUIServer:any = TUIConversationList?.TUIServer;
    const list:any = ref();

    watchEffect(() => {
      obj.data = props.data;
      obj.currentID = props.currentID;
    });

    const handleListItem = (item: any) => {
      ctx.emit('handleItem', item);
    };

    const handleItem = (params:any) => {
      const { name, conversation } = params;
      TUIAegis.getInstance().reportEvent({
        name: 'conversationOptions',
        ext1: 'conversationOptions',
      });
      switch (name) {
        case 'delete':
          handleDeleteConversation(conversation);
          break;
        case 'ispinned':
          handlePinConversation(name, conversation);
          break;
        case 'dispinned':
          handlePinConversation(name, conversation);
          break;
        case 'mute':
          handleMuteConversation(name, conversation);
          break;
        case 'notMute':
          handleMuteConversation(name, conversation);
          break;
      }
    };

    const handleDeleteConversation = (conversation:any) => {
      TUIServer.deleteConversation(conversation.conversationID).then((imResponse: any) => {
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
      });
    };

    const handlePinConversation = (type:string, conversation:any) => {
      const options:any = {
        conversationID: conversation.conversationID,
        isPinned: true,
      };

      if (type === 'dispinned') {
        options.isPinned = false;
      }
      console.log('dispinned', options);
      TUIServer.pinConversation(options);
    };

    const handleMuteConversation = (type:string, conversation:any) => {
      const options:any = {
        messageRemindType: TUIServer.TUICore.TIM.TYPES.MSG_REMIND_ACPT_NOT_NOTE,
      };

      if  (conversation.type === TUIServer.TUICore.TIM.TYPES.CONV_C2C) {
        options.userIDList = [conversation.userProfile.userID];
      } else if (conversation.type === TUIServer.TUICore.TIM.TYPES.CONV_GROUP) {
        options.groupID = conversation.groupProfile.groupID;
      }

      if (type === 'notMute') {
        options.messageRemindType = TUIServer.TUICore.TIM.TYPES.MSG_REMIND_ACPT_AND_NOTE;
      }

      TUIServer.muteConversation(options);
    };

    const handleToggleListItem = (conversationID:string) => {
      obj.toggleID = conversationID;
    };

    const scrollChange = () => {
      obj.toggleID && (obj.toggleID = '');
    };

    return {
      ...toRefs(obj),
      handleListItem,
      handleItem,
      handleToggleListItem,
      list,
      scrollChange,
    };
  },
});
export default TUIConversationList;
</script>
<style lang="scss" scoped src="./style/index.scss"></style>
