<template>
<message-bubble :isMine=isMine :message=message>
  <div class="custom-element-wrapper">
    <div class="survey"  v-if="this.payload.data === 'survey'">
      <div class="title">对IM DEMO的评分和建议</div>
      <el-rate
          v-model="rate"
          disabled
          show-score
          text-color="#ff9900"
          score-template="{value}">
      </el-rate>
      <div class="suggestion">{{this.payload.extension}}</div>
    </div>
    <span class="text" title="您可以自行解析自定义消息" v-else>
      <template v-if="text.isFromGroupLive && text.isFromGroupLive === 1">
        <message-group-live-status :liveInfo='text' />
      </template>
      <template v-else>{{text}}</template>
    </span>
  </div>
</message-bubble>
</template>

<script>
import { mapState } from 'vuex'
import MessageBubble from '../message-bubble'
import { Rate } from 'element-ui'
import MessageGroupLiveStatus from '../message-group-live-status'

export default {
  name: 'CustomElement',
  props: {
    payload: {
      type: Object,
      required: true
    },
    message: {
      type: Object,
      required: true
    },
    isMine: {
      type: Boolean
    }
  },
  components: {
    MessageBubble,
    ElRate: Rate,
    MessageGroupLiveStatus
  },
  computed: {
    ...mapState({
      currentUserProfile: state => state.user.currentUserProfile
    }),
    text() {
      return this.translateCustomMessage(this.payload)
    },
    rate() {
      return parseInt(this.payload.description)
    }
  },
  methods: {
    translateCustomMessage(payload) {
      let videoPayload = {}
      try{
        videoPayload = JSON.parse(payload.data)
      } catch(e) {
        videoPayload = {}
      }
      if (payload.data === 'group_create') {
        return `${payload.extension}`
      }
      if (videoPayload.roomId) {
        videoPayload.roomId = videoPayload.roomId.toString()
        videoPayload.isFromGroupLive = 1
        return videoPayload
      }
      if(payload.text) {
        return payload.text
      }else{
        return '[自定义消息]'
      }
    }
  }
}
</script>

<style lang="stylus" scoped>
.text
  font-weight bold
.title
  font-size 16px
  font-weight 600
  padding-bottom 10px
.survey
  background-color white
  color black
  padding 20px
  display flex
  flex-direction column
.suggestion
  padding-top 10px
  font-size 14px
</style>
