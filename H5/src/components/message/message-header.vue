<template>
  <div class="from" :style="{ textAlign: isMine ? 'right' : 'left', color: 'gray', fontSize: '14px' }">
    <span class="name text-ellipsis">{{ from }}</span>
    <span style="margin-left:12px">{{ date }}</span>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { getFullDate } from '../../utils/date'
export default {
  name: 'MessageHeader',
  props: {
    message: {
      type: Object,
      required: true
    }
  },
  computed: {
    ...mapState({
      currentConversation: state => state.conversation.currentConversation,
      currentUserProfile: state => state.user.currentUserProfile
    }),
    date() {
      return getFullDate(new Date(this.message.time * 1000))
    },
    from() {
      if (this.currentConversation.type === 'C2C') {
        if (this.message.flow === 'out') {
          return this.currentUserProfile.nick || this.currentUserProfile.userID
        }
        return this.currentConversation.userProfile.nick || this.currentConversation.userProfile.userID
      }
      const member = this.currentConversation.groupProfile.memberList.find(item => item.userID === this.message.from)
      if (member) {
        return member.nameCard || member.nick || member.userID
      }
      return this.message.from
    },
    isMine() {
      return this.message.flow === 'out'
    }
  }
}
</script>

<style scoped>
.from {
  display: flex;
  align-items: center;
}
.name {
  display: inline-block;
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>
