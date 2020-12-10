<template>
  <div>
    <div class="share-content"  ref="shareCon" v-show="showShareContent">
      <p class="qrcode-tips">手机扫码观看或复制链接分享给好友</p>
      <qrcode ref="childQrcode"/>
      <button class="copy-link" @click="copyLink" v-clipboard="playUrl" v-clipboard:success="onCopySuccess" v-clipboard:error="onCopyError">复制链接</button>
    </div>
    <div class="share-btn" ref="shareBtn">
      <img class="share-icon" src="../../../assets/image/share-icon.png" alt=""/>
      分享直播
    </div>
  </div>
</template>

<script>
import qrcode from './qrcode'
export default {
  name: 'liveShare',
  data() {
    return {
      showShareContent: false,
      playUrl: '',
    }
  },
  computed: {},
  components: {
    qrcode
  },
  mounted() {
    const shareCon = this.$refs.shareCon
    const shareBtn = this.$refs.shareBtn
    shareBtn.addEventListener('mouseover', () => {
      this.showShareContent = true
    })
    shareBtn.addEventListener('mouseout', () => {
      this.showShareContent = false
    })
    shareCon.addEventListener('mouseover', () => {
      this.showShareContent = true
    })
    shareCon.addEventListener('mouseout', () => {
      this.showShareContent = false
    })
  },
  methods: {
    copyLink() {
      this.playUrl= this.$refs.childQrcode.playUrl
    },
    onCopySuccess() {
      this.$store.commit('showMessage', {
        type: 'success',
        message: '复制成功'
      })
    },
    onCopyError() {
      this.$store.commit('showMessage', {
        type: 'error',
        message: '复制失败'
      })
    }
  }
}
</script>
<style lang="stylus" scoped>
  .share-content {
    position absolute
    top -250px
    left 20px
    width 200px
    height 250px
    background #ffffff
    border-radius 5px 5px 0 0
    z-index 1
    padding 10px
    box-sizing border-box
    text-align center
    .qrcode-tips {
      margin 0 0 0 0
      color #a5b5c1
      text-align center
    }
    .copy-link{
      width 160px
      height 40px
      border hidden
      outline-style none
      background #5cadff
      color #fff
      font-size 16px
      border-radius 25px
      margin 20px 0
      cursor pointer
    }
  }
  .share-btn {
    position absolute
    bottom 0
    line-height 55px
    font-size 14px
    color #8a9099
    letter-spacing 0
    margin 0 0 0 20px
    box-sizing border-box
    display flex
    align-items center
    cursor pointer
    .share-icon {
      width 20px
      height 20px
      margin 0 5px 2px 0
    }
  }
</style>
