<template>
  <img class="qrcode-img" v-if="qrcodeUrl" :src="qrcodeUrl"/>
</template>

<script>
import { mapState } from 'vuex'
import QRCode from 'qrcode'
export default {
  props: {
    url: String
  },
  data() {
    return {
      qrcodeUrl: '',
      playUrl: '',
    }
  },
  computed: {
    ...mapState({
      user: state => state.user,
      roomID: state => state.groupLive.groupLiveInfo.roomID,
      anchorID: state => state.groupLive.groupLiveInfo.anchorID,
    }),
  },
  async mounted() {
    this.qrcodeUrl = await this.generateQRcode()
  },
  methods: {
    generateQRcode() {
      // 群直播暂时没有分享二维码功能，以下代码注释，避免lint error
      // const streamID = `${this.user.sdkAppID}_${this.roomID}_${this.anchorID}_main`
      // const flv = `https://tuikit.qcloud.com/live/${streamID}.flv`
      // const hls = `https://tuikit.qcloud.com/live/${streamID}.m3u8` 
      // this.playUrl = ''
      return QRCode.toDataURL('')
    }
  }
}
</script>
<style lang="stylus" scoped>
  .qrcode-img {
    display block
    width 120px
    height  120px
    margin 0 auto
  }
</style>
