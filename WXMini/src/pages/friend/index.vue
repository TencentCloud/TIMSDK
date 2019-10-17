<template>
  <div class="container">
    <div class="item">
      <i-row>
        <i-col span="7" offset="1">
          <div class="avatar">
            用户ID:
          </div>
        </i-col>
        <i-col span="15">
          <input type="text" class="input" placeholder="输入接收者ID" v-model="id"/>
        </i-col>
      </i-row>
      <i-row>
        <i-col span="7" offset="1">
          <div class="avatar">
            内容：
          </div>
        </i-col>
        <i-col span="15">
          <input type="text" class="input" placeholder="输入你要发送的内容" v-model="content"/>
        </i-col>
      </i-row>
      <i-row>
        <i-col span="16" offset="4">
          <i-button @click="createConversation()" type="primary" long="true" shape="circle">发起会话</i-button>
        </i-col>
      </i-row>
  </div>
</div>
</template>

<script>
export default {
  data () {
    return {
      id: '',
      content: ''
    }
  },
  computed: {
    username () {
      return this.$store.state.user.userProfile.to
    }
  },
  methods: {
    // 发起会话
    createConversation () {
      if (this.content !== '' && this.id !== '') {
        let option = {
          userIDList: [this.id]
        }
        wx.$app.getUserProfile(option).then((res) => {
          if (res.data.length > 0) {
            const message = wx.$app.createTextMessage({
              to: this.id,
              conversationType: this.TIM.TYPES.CONV_C2C,
              payload: { text: this.content }
            })
            wx.$app.sendMessage(message).then(() => {
              let conversationID = this.TIM.TYPES.CONV_C2C + this.id
              wx.$app.getConversationProfile(conversationID).then((res) => {
                this.$store.commit('resetCurrentConversation')
                this.$store.commit('resetGroup')
                this.$store.commit('updateCurrentConversation', res.data.conversation)
                this.$store.dispatch('getMessageList', conversationID)
                this.content = ''
                this.id = ''
                let url = `../chat/main?toAccount=${res.data.conversation.userProfile.nick || res.data.conversation.userProfile.userID}`
                wx.navigateTo({ url })
              }).catch(error => {
                console.log(error)
              })
            }).catch(() => {
              this.$store.commit('showToast', {
                title: '输入内容有误',
                icon: 'none',
                duration: 1000
              })
            })
          } else {
            this.$store.commit('showToast', {
              title: '用户不存在',
              icon: 'none',
              duration: 1000
            })
            this.id = ''
            this.content = ''
          }
        }).catch(() => {
          this.$store.commit('showToast', {
            title: '用户不存在',
            icon: 'none',
            duration: 1000
          })
          this.id = ''
          this.content = ''
        })
      }
    }
  }
}
</script>

<style lang='stylus' scoped>
.item
  padding-top 40px
.input
  text-align center
  height 32px
  background-color white
  border-radius 8px
  border 1px solid $border-light
  font-size 16px
.card
  border-bottom 1px solid $border-light
.avatar
  padding 10px
.right
  box-sizing border-box
  height 100px
  padding 10px
  display flex
  flex-direction column
  justify-content space-around
.username
  font-weight 600
  font-size 18px
  color $base
.account
  font-size 14px
  color $secondary
._i-row
  margin-top 20rpx
  display block
</style>
