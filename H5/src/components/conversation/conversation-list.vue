<template>
  <div id="conversation-list" class="list-container">
    <conversation-item
      :conversation="item"
      v-for="item in conversationList"
      :key="item.conversationID"
      :class="{ 'current-conversation-item': item.conversationID === currentConversation.conversationID }"
    />

    <el-button
      class="bottom-circle-btn create-conversation"
      @click="handleAddButtonClick"
      icon="el-icon-plus"
      circle
      title="发起会话"
    ></el-button>
    <el-button
      class="bottom-circle-btn refresh"
      type="primary"
      @click="handleRefresh"
      icon="el-icon-refresh-right"
      circle
    ></el-button>
    <el-dialog title="快速发起会话" :visible.sync="showDialog">
      <el-input placeholder="请输入用户ID" v-model="userID" />
      <span slot="footer" class="dialog-footer">
        <el-button @click="showDialog = false">取 消</el-button>
        <el-button type="primary" @click="handleConfirm">确 定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import ConversationItem from './conversation-item'
import { mapState } from 'vuex'
export default {
  name: 'ConversationList',
  components: { ConversationItem },
  data() {
    return {
      showDialog: false,
      userID: ''
    }
  },
  computed: {
    ...mapState({
      conversationList: state => state.conversation.conversationList,
      currentConversation: state => state.conversation.currentConversation
    })
  },
  methods: {
    handleRefresh() {
      this.tim.getConversationList()
    },
    handleAddButtonClick() {
      this.showDialog = true
    },
    handleConfirm() {
      this.$store.dispatch('checkoutConversation', `C2C${this.userID}`).then(() => {
        this.showDialog = false
      })
    }
  }
}
</script>

<style>
#conversation-box {
  margin-top: 24px;
}

#conversation-container {
  display: inline-block;
  width: 30vw;
}

.conversation-item-container {
  width: 100%;
}
.current-conversation-item {
  background: #c8c8c8;
}

.conversation-item-container > .conversation-item {
  position: relative;
  width: 27vw;
}

.bottom-circle-btn {
  position: absolute;
  bottom: 20px;
  right: 20px;
}

.create-conversation {
  bottom: 70px;
}
</style>
