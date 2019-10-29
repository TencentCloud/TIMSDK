<template>
  <div class="container">
    <div class="group" v-for="item in groupList" :key="item.groupID" @click="startConversation(item)">
      <div class="avatar">
        <image class="img" :src="item.avatar || '/static/images/groups.png'"/>
      </div>
      <div class="name">
        {{item.name}}
      </div>
      <div class="type">
        {{item.type}}
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  data () {
    return {
    }
  },
  computed: {
    ...mapState({
      groupList: state => {
        return state.group.groupList
      }
    })
  },
  methods: {
    startConversation (item) {
      this.$store.commit('resetCurrentConversation')
      this.$store.commit('resetGroup')
      let conversationID = this.TIM.TYPES.CONV_GROUP + item.groupID
      wx.$app.setMessageRead({
        conversationID: conversationID
      })
      wx.$app.getConversationProfile(conversationID)
        .then((res) => {
          this.$store.commit('updateCurrentConversation', res.data.conversation)
          this.$store.dispatch('getMessageList', res.data.conversation.conversationID)
        })
      let url = `../chat/main?toAccount=${item.name}`
      wx.navigateTo({url})
    }
  }
}
</script>

<style lang='stylus' scoped>
.container
  background-color $background
  min-height 100vh
  .group
    height 50px
    background-color white
    box-sizing border-box
    border-bottom 1px solid $border-base
    display flex
    padding 10px 20px
    .avatar
      width 60px
      .img
        width 30px
        height 30px
.name
  line-height 30px
  width 50%
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
.type
  line-height 30px
</style>
