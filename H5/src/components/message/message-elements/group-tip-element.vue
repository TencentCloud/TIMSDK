<template>
  <div class="group-tip-element-wrapper">{{text}}</div>
</template>

<script>
  import {mapState} from 'vuex'
  export default {
  name: 'GroupTipElement',
  data() {
    return {
      callTips:256
    }
  },
  props: {
    payload: {
      type: Object,
      required: true
    },
    message: {
      type: Object,
      required: false
    }
  },

  computed: {
    ...mapState({
      currentUserProfile: state => state.user.currentUserProfile,
      userID: state => state.user.userID
    }),
    text() {
      return this.getGroupTipContent(this.message)
    }
  },
  methods: {
    getGroupTipContent(message) {
      // 群通话tips
      let nick = message.nick || ((message.from === this.userID) && this.currentUserProfile.nick) ||  message.from
      const userName = message.nick || message.payload.userIDList.join(',')
      switch (message.payload.operationType) {
        case this.TIM.TYPES.GRP_TIP_MBR_JOIN:
          return `群成员：${userName} 加入群组`
        case this.TIM.TYPES.GRP_TIP_MBR_QUIT:
          return `群成员：${userName} 退出群组`
        case this.TIM.TYPES.GRP_TIP_MBR_KICKED_OUT:
          return `群成员：${userName} 被${message.payload.operatorID}踢出群组`
        case this.TIM.TYPES.GRP_TIP_MBR_SET_ADMIN:
          return `群成员：${userName} 成为管理员`
        case this.TIM.TYPES.GRP_TIP_MBR_CANCELED_ADMIN:
          return `群成员：${userName} 被撤销管理员`
        case this.TIM.TYPES.GRP_TIP_GRP_PROFILE_UPDATED:
          return '群资料修改'
        case this.callTips:
          if(message.payload.text.indexOf('结束群聊')> -1) {
            return  `"${message.payload.text}"`
          }else {
            return  `"${nick}" ${message.payload.text}`
          }
        case this.TIM.TYPES.GRP_TIP_MBR_PROFILE_UPDATED:
          for (let member of message.payload.memberList) {
            if (member.muteTime > 0) {
              return `群成员：${member.userID}被禁言${member.muteTime}秒`
            } else {
              return `群成员：${member.userID}被取消禁言`
            }
          }
          break
        default:
          return '[群提示消息]'
      }
    },
}
}
</script>

<style lang="stylus" scoped>
.group-tip-element-wrapper
  background $white
  padding 4px 15px
  border-radius 3px
  color $secondary
  font-size 12px
  // text-shadow $secondary 0 0 0.05em
</style>
