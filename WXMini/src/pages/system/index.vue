<template>
  <div class="container">
    <div v-if="currentMessageList.length === 0">
      <div class="card">
        暂无系统消息
      </div>
    </div>
    <div v-for="message in currentMessageList" :key="message.ID">
      <div v-if="message.payload.operationType === 1" class="card handle">
        <div>
          <div class="time">{{message.newtime}}</div>
          {{message.virtualDom[0].text}}
        </div>
        <div class="choose">
          <button type="button" class="button" @click="handleClick(message)">处理</button>
        </div>
      </div>
      <div class="card" v-else>
        <div class="time">{{message.newtime}}</div>
        {{message.virtualDom[0].text}}
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  onUnload () {
    this.$store.commit('resetCurrentConversation')
    this.$store.commit('resetGroup')
  },
  computed: {
    ...mapState({
      currentMessageList: state => {
        return [...state.conversation.currentMessageList].reverse()
      }
    })
  },
  onShow () {
    let interval = setInterval(() => {
      if (this.currentMessageList.length !== 0) {
        wx.pageScrollTo({
          scrollTop: 99999
        })
        clearInterval(interval)
      }
    }, 600)
  },
  methods: {
    handleClick (message) {
      wx.showActionSheet({
        itemList: ['同意', '拒绝'],
        success: res => {
          const option = {
            handleAction: 'Agree',
            handleMessage: '欢迎进群',
            message
          }
          if (res.tapIndex === 1) {
            option.handleAction = 'Reject'
            option.handleMessage = '拒绝申请'
          }
          wx.$app.handleGroupApplication(option)
            .then(() => {
              wx.showToast({ title: option.handleAction === 'Agree' ? '已同意申请' : '已拒绝申请' })
              this.$store.commit('removeMessage', message)
            }).catch((error) => {
              wx.showToast({
                title: error.message || '处理失败',
                icon: 'none'
              })
            })
        }
      })
    }
  }
}
</script>

<style lang='stylus' scoped>
.handle
  display flex
  justify-content space-between
.card
  font-size 14px
  margin 20px
  padding 20px
  box-sizing border-box
  border 1px solid #abdcff
  background-color #f0faff
  border-radius 12px
  .time
    font-weight 600
    color $base
.button
  color white
  background-color $primary
  border-radius 8px
  line-height 30px
  font-size 16px
  width 70px
.delete
  background-color $danger
.choose
  display flex
  flex-direction column
  justify-content space-between
  height 100%
.input
  text-align center
  height 32px
  background-color white
  border-radius 8px
  border 1px solid $border-light
  font-size 16px
  margin 10px 20px
</style>
