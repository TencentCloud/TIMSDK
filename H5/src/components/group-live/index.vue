<template>
  <div class="group-live-mask" v-if="groupLiveVisible">
        <div class="live-container">
            <div class="video-wrap">
              <template v-if="channel === 3 && userID !== anchorID">
                <live-player />
              </template>
              <template v-else>
                <live-pusher />
              </template>
            </div>
            <div class="chat-wrap">
              <live-chat v-if="groupLiveVisible" />
            </div>
        </div>
    </div>
</template>

<script>
import { mapState } from 'vuex'
import livePusher from './components/live-pusher'
import livePlayer from './components/live-player'
import liveChat from './components/live-chat'

export default {
  name: 'groupLive',
  data() {
    return {
      groupLiveVisible: false,
      channel: 1 // 进入直播间渠道：1 群组内直播 2 群组外直播 3 点击消息卡片
    }
  },
  computed: {
    ...mapState({
      userID: state => state.user.userID,
      groupID: state => state.groupLive.groupLiveInfo.groupID,
      roomID: state => state.groupLive.groupLiveInfo.roomID,
      anchorID: state => state.groupLive.groupLiveInfo.anchorID,
    }),
  },
  mounted() {
    this.$bus.$on('open-group-live', (options) => {
      this.channel = options.channel
      this.groupLiveVisible = true
    })
    this.$bus.$on('close-group-live', () => {
      this.groupLiveVisible = false
      this.$store.commit('clearAvChatRoomMessageList')
    })
  },
  beforeDestroy() {
    this.$bus.$off('open-group-live')
    this.$bus.$off('close-group-live')
  },
  components: {
      livePusher,
      livePlayer,
      liveChat,
  },
  methods: {}
}
</script>
<style lang="stylus" scoped>
    .group-live-mask{
      position absolute
      top 8vh
      width 80vw
      height 80vh
      max-width: 1280px
      background: #fff
      z-index 999
    }
    .live-container {
        width 100%
        height 100%
        display flex
        .video-wrap {
          position relative
          flex 1
          min-width 500px
          height 100%
          background url('../../assets/image/video-bg.png') center no-repeat
        }
        .chat-wrap {
          width 375px
          height 100%
          background #f5f5f5
        }
    }
</style>