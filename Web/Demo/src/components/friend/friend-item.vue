<template>
  <div class="friendList-item-wrapper" :id="'friend-'+name+'-'+index" @click="selectedItem">
    <avatar :src="friend.profile.avatar" />
    <div class="item-nick text-ellipsis">{{friend.remark || friend.profile.nick||friend.profile.userID}}</div>
  </div>
</template>

<script>
  export default {
  props: ['friend','friendGroupNameList','type','groupName','index'],
  data() {
    return {
      addInfo: {
        name: '',
        userList: ''
      },
    }
  },
  computed: {
    name() {
      if(this.groupName) {
        return this.groupName
      }else {
        return ''
      }
    }
  },

  methods:{
    selectedItem() {
      this.$store.commit('resetCurrentConversation')
      this.$store.dispatch('setFriendContent', {
        friend: this.friend,
        groupName: this.groupName,
        type: this.type
      })
    },
    handleFriendClick() {
      this.tim.getConversationProfile(`C2C${this.friend.userID}`).then(({data})=>{
        this.$store.commit('updateCurrentConversation', data)
      })
      .catch(error => {
          this.$store.commit('showMessage', {
            type: 'error',
            message: error.message
          })
        })
    },
    handleCommand(value) {
      this.tim.addToFriendGroup({name: value, userIDList: [this.friend.profile.userID]}).then(() => {
        this.$store.commit('showMessage', {
          message: '添加成功',
          type: 'success'
        })
      }).catch((error) => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
    },
    removeFromFriendList(data) {
      this.tim.deleteFriend({
        userIDList: [data.userID],
        type: 'Delete_Type_Both'
      }).then(() => {
      }).catch(error => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
    },
    removeFromFriendGroup(userID,name) {
      this.tim.removeFromFriendGroup({
        name: name,
        userIDList: [userID],
      }).then(() => {
      }).catch(() => {
      })
    },
  }
}
</script>

<style lang="stylus" scoped>
  .item-nick {
    padding-left: 20px;
    width: 100%;
    color: $white;
    box-sizing: border-box;
    word-wrap: break-word;
    overflow: hidden;
    text-overflow: ellipsis;
    font-size 16px
  }

  .friendList-item-wrapper {
    cursor pointer
    padding 0 40px
    padding-bottom: 15px;
    display: flex;
    align-items: center;
    justify-content: flex-start;
  }
  .group-friend-btn {
    position absolute
    right 13px
  }
  .unread-count {
    padding-left 10px
    flex-shrink 0
    color $font-dark
    font-size 12px
  }
  .badge {
    vertical-align bottom
    background-color $danger
    border-radius 10px
    color #FFF
    display inline-block
    font-size 12px
    height 18px
    max-width 40px
    line-height 18px
    padding 0 6px
    text-align center
    white-space nowrap
    }
  .avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    flex-shrink: 0
    box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
  }
  .el-icon-chat-dot-round:before {
    color #dddddd
  }
</style>
