<template>
  <div class="blacklist-item-wrapper">
    <img class="avatar" :src="profile.avatar ? profile.avatar : 'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-2.png'"/>
    <div class="item">{{profile.nick||profile.userID}}</div>
    <el-button type="text" @click="removeFromBlacklist">取消拉黑</el-button>
  </div>
</template>

<script>
export default {
  name: 'BlacklistItem',
  props: {
    profile: {
      type: Object,
      required: true
    }
  },
  methods: {
    removeFromBlacklist() {
      this.tim
        .removeFromBlacklist({ userIDList: [this.profile.userID] })
        .then(() => {
          this.$store.commit('removeFromBlacklist', this.profile.userID)
        })
    }
  }
}
</script>

<style lang="stylus" scoped>
.item
  padding-left 20px
  width 100%
  color $white
  box-sizing border-box
  word-wrap break-word
  overflow hidden
  text-overflow ellipsis
.blacklist-item-wrapper {
  padding-bottom: 15px;
  display: flex;
  align-items: center;
  justify-content: flex-start;
}
.avatar
  width 48px
  height 48px
  border-radius 50%
</style>
