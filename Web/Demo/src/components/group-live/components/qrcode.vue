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
      const streamID = `${this.user.sdkAppID}_${this.roomID}_${this.anchorID}_main`
      const flv = `https://tuikit.qcloud.com/live/${streamID}.flv`
      const hls = `https://tuikit.qcloud.com/live/${streamID}.m3u8` 
      this.playUrl = `https://webim-1252463788.cos.ap-shanghai.myqcloud.com/tweblivedemo/0.3.2-cdn-player/index.html?flv=${encodeURIComponent(flv)}&hls=${encodeURIComponent(hls)}&roomid=${this.roomID}`
      return QRCode.toDataURL(this.playUrl)
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
