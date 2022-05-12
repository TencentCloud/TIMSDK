<template >
  <ul class="TUI-conversation-list" @click="dialogID = ''" ref="dialog">
    <li  class="TUI-conversation-item" :class="[currentID === item.conversationID && 'selected']" v-for="(item, index) in data.list" :key="index"  @click="handleListItem(item)"  @click.prevent.right="handleItem(item, $event)">
      <aside class="left">
        <img class="avatar" :src="data.handleItemAvator(item)">
        <span class="num" v-if="item.unreadCount>0">
          {{item.unreadCount > 99 ? '99+' : item.unreadCount}}
        </span>
      </aside>
      <main class="content">
        <header class="content-header">
          <label>
            <p class="name">{{data.handleItemName(item)}}</p>
          </label>
          <span class="time">{{data.handleItemTime(item.lastMessage.lastTime)}}</span>
        </header>
        <footer class="content-footer">
          <p>{{data.handleItemMessage(item.lastMessage)}}</p>
          <i></i>
        </footer>
      </main>
      <div class="dialog dialog-item"  v-if="item.conversationID===dialogID" >
        <p class="conversation-options" @click="handleConversation('delete', dialogID)">{{$t('TUIConversation.删除会话')}}</p>
      </div>
    </li>
  </ul>

</template>
<script lang="ts">
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

  },

  setup(props:any, ctx:any) {
    const obj = reactive({
      data: {},
      currentID: '',
      currentConversation: {},
      dialogID: '',
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
      e.target.oncontextmenu = function () {
        return false;
      };
      obj.currentConversation = item;
      obj.dialogID = item.conversationID;
    };

    // 删除会话,后续TODO,置顶聊天,消息免打扰
    const handleConversation = (type:string, dialogID:string) => {
      switch (type) {
        case 'delete':
          TUIServer.deleteConversation(dialogID).then((imResponse: any) => {
            const { conversationID } = imResponse.data;
            const { conversation } = TUIServer.TUICore.getStore().TUIChat;
            // 删除会话，判断当前删除的会话是否为打开的会话
            // 若为打开的会话，通知 TUIChat 关闭当前会话
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
    return {
      ...toRefs(obj),
      handleListItem,
      handleItem,
      handleConversation,
      dialog,
    };
  },
});
export default TUIConversationList;
</script>
<style lang="scss" scoped>
.TUI-conversation {
  font-family: PingFangSC-Regular;
  font-weight: 400;
  letter-spacing: 0;
  &-list {
    list-style: none;
  }
  &-item {
    position: relative;
    padding: 12px;
    display: flex;
    align-items: center;
    cursor: pointer;
    &:hover {
      background: rgba(0,110,255,0.10);
    }
    .left {
      position: relative;
      width: 36px;
      height: 36px;
      .num {
        position: absolute;
        display: inline-block;
        right: -4px;
        top: -8px;
        background: red;
        width: 15px;
        height: 15px;
        font-size: 10px;
        text-align: center;
        line-height: 15px;
        border-radius: 65%;
        color: #ffffff;
      }
      .avatar {
        width: 30px;
        height: 30px;
        border-radius: 5px;
      }
    }
    .content {
      flex: 1;
      padding-left: 8px;
      p {
        width: 200px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
        font-weight: 400;
        font-size: 12px;
        color: #999999;
        letter-spacing: 0;
        line-height: 16px;
      }
      .name {
        font-weight: 400;
        font-size: 14px;
        color: #000000;
        letter-spacing: 0;
      }
      &-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        label {
          flex: 1;
          font-size: 14px;
          color: #000000;
          .name {
            width: 110px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
          }
        }
        .time {
          font-size: 12px;
          color: #BBBBBB;
          line-height: 16px;
          display: inline-block;
          max-width: 75px;
        }
      }
      &-footer {
        color: #999999;
        line-height: 16px;
      }
    }
  }
  .selected {
    background: rgba(0,110,255,0.10);
  }
  .dialog{
     position: absolute;
    z-index: 5;
    background: #fff;
    border: 1px solid #dddddd;
    padding: 15px 20px;
    &-item {
    top: 30px;
    left: 164px;
    box-shadow: 0 11px 20px 0 rgba(0,0,0,.3);
    background: #FFFFFF;
    border: 1px solid #E0E0E0;
    box-shadow: 0 -4px 12px 0 rgba(0,0,0,.06);
    border-radius: 8px;
  }
  .conversation-options {
    width: 48px;
    height: 17px;
    font-family: PingFangSC-Regular;
    font-weight: 400;
    font-size: 12px;
    color: #4F4F4F;
    letter-spacing: 0;
    line-height: 17px;
  }
  }
}
</style>
