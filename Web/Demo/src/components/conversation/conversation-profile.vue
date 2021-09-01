<template>
  <div class="conversation-profile-wrapper">
    <user-profile
      v-if="currentConversation.type === TIM.TYPES.CONV_C2C"
      :userProfile="currentConversation.userProfile"
    />
    <group-profile
      v-else-if="currentConversation.type === TIM.TYPES.CONV_GROUP"
      :groupProfile="currentConversation.groupProfile"
    />
  </div>
</template>

<script>
import { mapState } from 'vuex'
import GroupProfile from './conversationProfile/group-profile.vue'
import UserProfile from './conversationProfile/user-profile.vue'
export default {
  name: 'ConversationProfile',
  components: {
    GroupProfile,
    UserProfile
  },
  data() {
    return {}
  },
  computed: {
    ...mapState({
      currentConversation: state => state.conversation.currentConversation
    })
  }
}
</script>

<style lang="stylus" scoped>
.conversation-profile-wrapper 
  background-color $white
  height 100%
  overflow-y scroll

/* 设置滚动条的样式 */
::-webkit-scrollbar {
  width: 0px;
  height: 0px;
}
</style>
