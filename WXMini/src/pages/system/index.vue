<template>
  <div class="container">
    <i-modal title="处理申请" :visible="applyModalVisible" @ok="handleApply" @cancel="modal">
      <div class="input-wrapper">
        <i-radio-group :current="action" @change="handleChange">
          <i-radio value="Agree">同意</i-radio>
          <i-radio value="Reject">不同意</i-radio>
        </i-radio-group>
        <input type="text" class="input" placeholder="输入回复" v-model.lazy:value="text"/>
      </div>
    </i-modal>
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
          <button type="button" class="button" @click="handleApplyModal(message)">处理</button>
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
  data () {
    return {
      action: 'Agree',
      message: {},
      text: '',
      applyModalVisible: false
    }
  },
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
    handleChange (e) {
      this.action = e.target.value
    },
    handleApplyModal (message) {
      this.message = message
      this.modal()
    },
    modal () {
      this.applyModalVisible = !this.applyModalVisible
    },
    handleApply () {
      wx.$app.handleGroupApplication({
        handleAction: this.action,
        handleMessage: this.text,
        message: this.message
      }).then(() => {
        this.$store.commit('showToast', {
          title: '处理完成'
        })
      }).catch((err) => {
        console.log(err)
        this.modal()
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
