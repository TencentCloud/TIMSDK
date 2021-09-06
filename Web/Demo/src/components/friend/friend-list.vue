<template>
  <div class="friend-list-container" :class="{'default': !hasFriend}">
    <div v-if="hasFriend">
      <friend-item v-for="friend in friendList" :key="friend.userID" :friend="friend" />
    </div>
    <div style="color:gray;" v-else>暂无好友</div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import FriendItem from './friend-item.vue'
export default {
  components: {
    FriendItem
  },
  computed: {
    ...mapState({
      friendList: state => state.friend.friendList
    }),
    hasFriend() {
      return this.friendList.length > 0
    }
  }
}
</script>

<style lang="stylus" scpoed>
.default {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  overflow-y: scroll;
}
</style>
