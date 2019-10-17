<template>
  <div>
    <el-input v-model="userID" placeholder="输入userID后 按回车键" @keydown.enter.native="addGroupMember"></el-input>
  </div>
</template>

<script>
import { Input } from 'element-ui'
import { mapState } from 'vuex'
export default {
  components: {
    ElInput: Input
  },
  data() {
    return {
      userID: ''
    }
  },
  computed: {
    ...mapState({
      currentConversation: state => state.conversation.currentConversation
    })
  },
  methods: {
    addGroupMember() {
      this.tim
        .addGroupMember({
          groupID: this.currentConversation.conversationID.replace('GROUP', ''),
          userIDList: [this.userID]
        })
        .then(imResponse => {
          const { successUserIDList, failureUserIDList, existedUserIDList } = imResponse.data
          if (successUserIDList.length > 0) {
            this.$store.commit('showMessage', {
              message: `群成员：${successUserIDList.join(',')}，加群成功`,
              type: 'success'
            })
          }
          if (failureUserIDList.length > 0) {
            this.$store.commit('showMessage', {
              message: `群成员：${failureUserIDList.join(',')}，添加失败！`,
              type: 'error'
            })
          }
          if (existedUserIDList.length > 0) {
            this.$store.commit('showMessage', {
              message: `群成员：${existedUserIDList.join(',')}，已在群中`
            })
          }
        })
    }
  }
}
</script>

<style lang="stylus" scoped></style>
