<template>
  <!-- <context-menu :visible="visible"> -->
  <div @click="handleGroupClick">
    <el-row class="group-item-container">
      <el-col :span="6">
        <avatar :src="group.avatar" text="G" />
      </el-col>
      <el-col :span="18">
        <div class="group-name">{{ group.name }}</div>
      </el-col>
    </el-row>
  </div>
  <!-- </context-menu> -->
</template>

<script>
import Avatar from '../avatar.vue'
export default {
  props: ['group'],
  components: {
    Avatar
  },
  data() {
    return {
      visible: false,
      options: [
        {
          text: '退出群组',
          handler: this.quitGroup
        }
      ]
    }
  },
  methods: {
    handleGroupClick() {
      const conversationID = `GROUP${this.group.groupID}`
      this.tim.getConversationProfile(conversationID).then(({ data: { conversation } }) => {
        this.$store.commit('updateCurrentConversation', conversation)
        this.$store.dispatch('getMessageList', conversation.conversationID)
      })
    },
    quitGroup() {
      this.tim.quitGroup(this.group.groupID)
    }
  }
}
</script>

<style>
.group-item-container {
  display: flex;
  justify-content: space-between;
  padding: 6px 12px;
}
.group-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
}

.group-avatar-default {
  background: gray;
  text-align: center;
  line-height: 30px;
}
</style>
