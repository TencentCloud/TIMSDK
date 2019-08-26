<template>
  <div class="conversation-profile-wrapper">
    <group-profile
      v-if="currentConversation.type==='GROUP'"
      :groupProfile="currentConversation.groupProfile"
    />
    <user-profile v-else-if="currentConversation.type === 'C2C'" :userProfile="currentConversation.userProfile"/>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import GroupProfile from './conversationProfile/group-profile.vue'
import UserProfile from './conversationProfile/user-profile.vue'
export default {
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
