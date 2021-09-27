<template>
  <div class="blacklist-item-wrapper" @click="resetContent">
    <avatar :src="profile.avatar" />
    <div class="item">{{profile.nick||profile.userID}}</div>
    <div  class="cancel-btn" @click="removeFromBlacklist">取消</div>
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
        .catch(error => {
          this.$store.commit('showMessage', {
            type: 'error',
            message: error.message
          })
        })
    },
    resetContent() {
      this.$store.commit('resetCurrentConversation')
      this.$store.commit('resetFriendContent')
      this.$store.commit('resetApplicationContent')
    }
  }
}
</script>

<style lang="stylus" scoped>
.item {
  padding-left: 20px;
  width: 100%;
  color: $white;
  box-sizing: border-box;
  word-wrap: break-word;
  overflow: hidden;
  text-overflow: ellipsis;
}

.blacklist-item-wrapper {
  padding-top 15px
  padding-bottom 15px
  display flex
  align-items center
  justify-content flex-start
  position relative
  &:hover {
    background-color $background
  }
  .cancel-btn {
    position absolute
    right 5px
    width 40px
    height 24px
    font-size 13px
    color #ffffff
    border-radius 12px
    line-height 24px
    text-align center
    background-color #00a4ff
  }
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  flex-shrink: 0
  box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
}
</style>
