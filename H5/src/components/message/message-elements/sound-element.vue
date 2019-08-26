<template>
  <div class="sound-element-wrapper" @click="play">
    <i class="iconfont icon-voice"></i>
    {{ second + '"' }}
  </div>
</template>

<script>
export default {
  name: 'SoundElement',
  props: {
    payload: {
      type: Object,
      required: true
    }
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
      try {
        if (!this.amr) {
          const BenzAMRRecorder = require('benz-amr-recorder')
          this.amr = new BenzAMRRecorder()
        }
        if (this.amr.isInit()) {
          this.amr.play()
          return
        }
        this.amr.initWithUrl(this.url).then(() => {
          this.amr.play()
        })
      } catch (error) {
        this.$message.warn('您的浏览器不支持amr格式的语音播放')
      }
    }
  }
}
</script>

<style>
.sound-element-wrapper {
  width: 100px;
  background: #fff;
  padding: 3px 6px;
  border-radius: 3px;
  cursor: pointer;
}
</style>
