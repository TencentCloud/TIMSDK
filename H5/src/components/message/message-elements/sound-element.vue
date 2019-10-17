<template>
<message-bubble :isMine=isMine>
  <div class="sound-element-wrapper" title="单击播放" @click="play">
    <i class="iconfont icon-voice"></i>
    {{ second + '"' }}
  </div>
</message-bubble>
</template>

<script>
import MessageBubble from '../message-bubble'
export default {
  name: 'SoundElement',
  props: {
    payload: {
      type: Object,
      required: true
    },
    isMine: {
      type: Boolean
    }
  },
  components: {
    MessageBubble
  },
  data() {
    return {
      amr: null
    }
  },
  computed: {
    url() {
      return this.payload.url
    },
    size() {
      return this.payload.size
    },
    second() {
      return this.payload.second
    }
  },
  methods: {
    play() {
      // 目前移动端的语音消息采用 aac 格式，以前用 amr 格式。默认先用 audio 标签播放，若无法播放则尝试 amr 格式播放。
      const audio = document.createElement('audio')
      audio.addEventListener('error', this.tryPlayAMR) // 播放出错，则尝试使用 AMR 播放
      audio.src = this.url
      const promise = audio.play()
      if (promise) {
        promise.catch(() => {})
      }
    },
    tryPlayAMR() {
      try {
        const isIE = /MSIE|Trident|Edge/.test(window.navigator.userAgent)
        // amr 播放组件库在 IE 不支持
        if (isIE) {
          this.$store.commit('showMessage', {
            message: '您的浏览器不支持该格式的语音消息播放，请尝试更换浏览器，建议使用：谷歌浏览器',
            type: 'warning'
          })
          return
        }
        // 动态插入 amr 播放组件库
        if (!window.BenzAMRRecorder) {
          const script = document.createElement('script')
          script.addEventListener('load', this.playAMR)
          script.src = './BenzAMRRecorder.js'
          const firstScript = document.getElementsByTagName('script')[0]
          firstScript.parentNode.insertBefore(script, firstScript)
          return
        }
        this.playAMR()
      } catch (error) {
        this.$store.commit('showMessage', {
          message: '您的浏览器不支持该格式的语音消息播放，请尝试更换浏览器，建议使用：谷歌浏览器',
          type: 'warning'
        })
      }
    },
    playAMR() {
      if (!this.amr && window.BenzAMRRecorder) {
        this.amr = new window.BenzAMRRecorder()
      }
      if (this.amr.isInit()) {
        this.amr.play()
        return
      }
      this.amr.initWithUrl(this.url).then(() => {
        this.amr.play()
      })
    }
  }
}
</script>

<style lang="stylus" scoped>
.sound-element-wrapper {
  padding: 0px 10px;
  cursor: pointer;
}
</style>
