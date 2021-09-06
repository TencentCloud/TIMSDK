<template>
  <div class="header-container">
    <div v-show="showLiveInfo">
      <div class="anchor-info">
        <img class="anchor-avatar" :src="avatar">
        <div class="anchor-other">
          <p class="anchor-nick">{{nick}}</p>
          <p class="online-num">在线：{{onlineMemberCount}}</p>
        </div>
      </div>
      <div class="online-info">
        <p class="room-name">直播中</p>
        <img class="living-icon" src="../../../assets/image/living-icon.gif" />
        <span>{{` ${pusherTime}`}}</span>
      </div>
    </div>
    <div class="close-box" @click="closeLiveMask">
      <i class="el-icon-circle-close"></i>
    </div>
  </div>
</template>

<script>
 import { mapState } from 'vuex'
  export default {
    name: 'liveHeader',
    props: {
      fr: {
        type: String,
        requred: true
      },
      isPushingStream: {
        type: Boolean,
        default: false
      },
      stopPushStream: {
        type: Function
      },
      pusherTime: {
        type: String,
        default: ''
      }
    },
    data() {
      return {
        nick: '',
        avatar: 'https://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-2.png',
        onlineMemberCount: 0,
        timer: null,
        onlineList: []
      }
    },
    computed: {
      ...mapState({
        groupLiveInfo: state => state.groupLive.groupLiveInfo
      }),
      showLiveInfo() {
        return (this.fr === 'pusher' && this.isPushingStream) || this.fr === 'player'
      },
      roomName() {
        return this.groupLiveInfo.roomName || `${this.groupLiveInfo.anchorID}的直播`
      }
    },
    mounted() {
      this.getAnchorProfile()
      if (this.fr === 'player') {
        this.timer = setInterval(() => {
          this.getGroupOnlineMemberCount()
        }, 5000)
      }
    },
    beforeDestroy() {
      this.timer && clearInterval(this.timer)
    },
    methods: {
      closeLiveMask() {
        if (this.fr === 'pusher') {
          this.stopPushStream()
          return
        }
        this.$store.commit('updateGroupLiveInfo', { isNeededQuitRoom: 1 })
        this.$bus.$emit('close-group-live')
      },
      async getAnchorProfile() {
        const res = await this.tim.getUserProfile({userIDList: [this.groupLiveInfo.anchorID]})
        if (res.code === 0) {
          this.nick = res.data[0].nick || res.data[0].userID
          this.avatar = res.data[0].avatar || 'https://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-2.png'
        }
      },
      async getGroupOnlineMemberCount() {
        const res = await this.tim.getGroupOnlineMemberCount(this.groupLiveInfo.roomID)
        if (res.code === 0 && res.data) {
          this.onlineMemberCount = res.data.memberCount
        }
      }
    },
    watch: {
      isPushingStream: function(val) {
        if (val && this.fr === 'pusher') {
          this.timer = setInterval(() => {
            this.getGroupOnlineMemberCount()
          }, 5000)
        }
      }
    }
  }
</script>

<style lang="stylus" scoped>
 .header-container {
   position absolute
   left 0
   top 0
   width 100%
   height 100%
   box-sizing border-box
   z-index 99
   padding 10px 10px 10px 20px
  .anchor-info {
    position absolute
    top 50%
    transform translateY(-50%)
    width 200px
    height 50px
    background rgba(255, 255 ,255 ,0.1)
    border-radius 30px
    display flex
    align-items center
    .anchor-avatar {
      width 50px
      height 50px
      border-radius 50%
      margin 0 5px
    }
    .anchor-other {
      height 100%
      flex 1
      p {
        margin 0
      }
      .anchor-nick{
        max-width 140px
        margin 6px 0 0 0
        color: #ffffff
        font-weight 500
        word-break keep-all
        overflow hidden
        text-overflow ellipsis
        white-space nowrap
      }
      .online-num{
        font-size 14px
        font-weight 400
        color #d2cbcbad
      }
    }
  }
  .online-info {
    position absolute
    left 50%
    top 50%
    transform translate(-50%, -50%)
    height 50px
    color #fff
    display flex
    align-items center
    .room-name{
      display inline-block
      max-width 160px
      overflow hidden
      white-space nowrap
      text-overflow ellipsis
      margin 0
      padding 0 0 0 10px
    }
    .living-icon{
      position relative
      top -3px
      margin 0 5px
      width 25px
    }
    span {
      margin 2px 0 0 0
    }
  }
  .close-box {
    position absolute
    right 0
    top 0px
    width 70px
    height 70px
    color: #959798
    font-size 36px
    cursor pointer
    display flex
    align-items center
    justify-content center
  }
 }
</style>
