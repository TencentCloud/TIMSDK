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

<style scoped>
.conversation-profile-wrapper {
  background: rgb(255, 255, 255);
  padding: 12px;
  width: 200px;
  min-width: 200px;
  overflow-y: scroll;
}
</style>
