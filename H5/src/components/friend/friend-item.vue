<template>
  <div>
    <el-row class="friend-item-container">
      <el-col :span="6">
        <avatar :src="friend.profile.avatar" />
      </el-col>
      <el-col :span="18">
        <div class="friend-name">{{friend.profile.nick||friend.userID}}</div>
      </el-col>
    </el-row>
  </div>
</template>

<script>
export default {
  props: {
    friend: {
      type: Object,
      required: true
    }
  },
  methods:{
    handleFriendClick() {
      this.tim.getConversationProfile(`C2C${this.friend.userID}`).then(({data})=>{
        this.$store.commit('updateCurrentConversation', data)
      })
    }
  }
}
</script>

<style lang="stylus" scoped>
</style>
