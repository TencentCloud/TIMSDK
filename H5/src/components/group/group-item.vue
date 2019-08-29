<template>
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
</template>

<script>
export default {
  props: ['group'],
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
</style>
