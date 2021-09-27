<template>
  <div id="message-send-box-wrapper" :style="focus ? {'backgroundColor': 'white'} : {}" @drop="dropHandler">
    <div class="send-header-bar">
      <el-popover placement="top" width="400" trigger="click">
        <div class="emojis">
          <div v-for="item in emojiName" class="emoji" :key="item" @click="chooseEmoji(item)">
            <img :src="emojiUrl + emojiMap[item]" style="width:30px;height:30px" />
          </div>
        </div>
        <i class="iconfont icon-smile" slot="reference" title="发表情"></i>
      </el-popover>
      <i class="iconfont icon-tupian" title="发图片" @click="handleSendImageClick"></i>
      <i class="el-icon-camera" title="发视频" @click="handleSendVideoClick"></i>
      <i class="iconfont icon-wenjian" title="发文件" @click="handleSendFileClick"></i>
      <i class="iconfont icon-zidingyi" title="发自定义消息" @click="sendCustomDialogVisible = true"></i>
      <i class="iconfont icon-diaocha" title="小调查" @click="surveyDialogVisible = true"></i>
      <el-dropdown>
      <span class="el-dropdown-link">
      <i class="el-icon-phone-outline" v-if="toAccount !== userID" title="语音通话"></i>
      </span>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item  @click.native="trtcCalling('video')">视频通话</el-dropdown-item>
          <el-dropdown-item  @click.native="trtcCalling('audio')">语音通话</el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
      <div class="group-live-icon-box" v-if="currentConversationType === TIM.TYPES.CONV_GROUP && groupProfile.type !== 'AVChatRoom'" title="群直播" @click="groupLive">
        <i class="group-live-icon"></i>
        <i class="group-live-icon-hover"></i>
      </div>
    </div>
    <el-dialog title="发自定义消息" :visible.sync="sendCustomDialogVisible" width="30%">
      <el-form label-width="100px">
        <el-form-item label="data">
          <el-input v-model="form.data"></el-input>
        </el-form-item>
        <el-form-item label="description">
          <el-input v-model="form.description"></el-input>
        </el-form-item>
        <el-form-item label="extension">
          <el-input v-model="form.extension"></el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="sendCustomDialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="sendCustomMessage">确 定</el-button>
      </span>
    </el-dialog>
    <el-dialog title="对IM Web demo的建议和使用感受" :visible.sync="surveyDialogVisible" width="30%">
      <el-form label-width="100px">
        <el-form-item label="评分">
          <div class="block">
            <el-rate v-model="rate" :colors="colors" show-text></el-rate>
          </div>
        </el-form-item>
        <el-form-item label="建议">
          <el-input
            type="textarea"
            :rows="2"
            placeholder="请输入内容"
            resize="none"
            v-model="suggestion"
          ></el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="surveyDialogVisible = false">取 消</el-button>
        <el-button type="primary" @click="sendSurvey">确 定</el-button>
      </span>
    </el-dialog>
    <div class="bottom">
      <textarea
        ref="text-input"
        rows="4"
        resize="false"
        v-model="messageContent"
        class="text-input"
        @focus="focus = true"
        @blur="focus = false"
        @input="inputChange"
        @keydown.enter.exact.prevent="handleEnter"
        @keyup.ctrl.enter.prevent.exact="handleLine"
        @keydown.up.stop="handleUp"
        @keydown.down.stop="handleDown"
      >
      </textarea>
      <el-tooltip
        class="item"
        effect="dark"
        content="按Enter发送消息，Ctrl+Enter换行"
        placement="left-start"
      >
        <div class="btn-send" @click="sendTextMessage">
          <div class="tim-icon-send"></div>
        </div>
      </el-tooltip>
    </div>
    <input
      type="file"
      id="imagePicker"
      ref="imagePicker"
      accept=".jpg, .jpeg, .png, .gif, .bmp"
      @change="sendImage"
      style="display:none"
    />
    <input type="file" id="filePicker" ref="filePicker" @change="sendFile" style="display:none" />
    <input type="file" id="videoPicker" ref="videoPicker" @change="sendVideo" style="display:none" accept=".mp4"/>
    <div class="calling-member-list" v-if="currentConversationType === TIM.TYPES.CONV_GROUP && showCallingMember">
      <calling-member-list @getList="getList" :type="listTpye"></calling-member-list>
      <div class="calling-list-btn">
        <span class="calling-btn" @click="cancelCalling">取消</span>
        <span class="calling-btn" @click="callingHandler">确定</span>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapState } from 'vuex'
import callingMemberList from './trtc-calling/group-member-list'
import {
  Form,
  FormItem,
  Input,
  Dialog,
  Popover,
  Tooltip,
  Rate
} from 'element-ui'
import { emojiMap, emojiName, emojiUrl } from '../../utils/emojiMap'

export default {
  name: 'message-send-box',
  props: ['scrollMessageListToButtom'],
  components: {
    callingMemberList: callingMemberList,
    ElInput: Input,
    ElForm: Form,
    ElFormItem: FormItem,
    ElDialog: Dialog,
    ElPopover: Popover,
    ElTooltip: Tooltip,
    ElRate: Rate
  },
  data() {
    return {
      callingList: [],
      groupAtList: [],
      listTpye:'',
      callingType: '',
      groupAt:false,
      showCallingMember: false,
      colors: ['#99A9BF', '#F7BA2A', '#FF9900'],
      messageContent: '',
      isSendCustomMessage: false,
      sendCustomDialogVisible: false,
      surveyDialogVisible: false,
      form: {
        data: '',
        description: '',
        extension: ''
      },
      rate: 5, // 评分
      suggestion: '', // 建议
      file: '',
      emojiMap: emojiMap,
      emojiName: emojiName,
      emojiUrl: emojiUrl,
      showAtGroupMember: false,
      atUserID: '',
      focus: false,
      popoverVisible: false,
      faceUrl: 'https://web.sdk.qcloud.com/im/assets/face-elem/',
      emojiShow: true,
      bigEmojiShow: false,
      bigEmojiList: [
        {
          icon: 'yz00',
          list: ['yz00', 'yz01', 'yz02', 'yz03', 'yz04', 'yz05', 'yz06', 'yz07', 'yz08', 'yz09', 'yz10', 'yz11', 'yz12', 'yz13', 'yz14', 'yz15', 'yz16', 'yz17']
        },
        {
          icon: 'ys00',
          list: ['ys00', 'ys01', 'ys02', 'ys03', 'ys04', 'ys05', 'ys06', 'ys07', 'ys08', 'ys09', 'ys10', 'ys11', 'ys12', 'ys13', 'ys14', 'ys15']
        },
        {
          icon: 'gcs00',
          list: ['gcs00', 'gcs01', 'gcs02', 'gcs03', 'gcs04', 'gcs05', 'gcs06', 'gcs07', 'gcs08', 'gcs09', 'gcs10', 'gcs11', 'gcs12', 'gcs13', 'gcs14', 'gcs15', 'gcs16']
        }
      ],
      curItemIndex: 0,
      curBigEmojiItemList: []
    }
  },
  computed: {
    ...mapGetters(['toAccount', 'currentConversationType']),
    ...mapState({
      memberList: state => state.group.currentMemberList,
      userID: state => state.user.userID,
      groupProfile: state => state.conversation.currentConversation.groupProfile
    })
  },
  mounted() {
    this.$refs['text-input'].addEventListener('paste', this.handlePaste)
    this.$bus.$on('reEditMessage', this.reEditMessage)
  },
  beforeDestroy() {
    this.$refs['text-input'].removeEventListener('paste', this.handlePaste)
  },
  methods: {
    getList(value) {
      this.callingList = value.map((item) => {
        let obj = JSON.parse(item)
        return obj.userID
      })
      this.groupAtList = value.map((item) => {
        let data = JSON.parse(item)
        return data.nick
      })
    },
    cancelCalling() {
      this.showCallingMember = false
    },
    callingHandler() {
      if (this.callingList.length < 1) {
        this.$store.commit('showMessage', {
          type: 'warning',
          message: '请选择成员'
        })
        return
      }
      if (this.listTpye === 'groupAt') {
        this.groupAtList.forEach((item, index) => {
          if(index===0) {
            this.messageContent += `${item} `
          }else{
            this.messageContent += `@${item} `
          }
        })
        this.showCallingMember = false
        this.$refs['text-input'].focus()
        return
      }
      if (this.listTpye === 'calling') {
        let callingData = {
          memberList:this.callingList,
          type:this.TIM.TYPES.CONV_GROUP
        }
        this.$store.commit('setCallingList',callingData)
        if (this.callingType === 'video') {
          this.$bus.$emit('video-call')
        }
        if (this.callingType === 'audio') {
          this.$bus.$emit('audio-call')
        }
        this.showCallingMember = false
      }

    },
    trtcCalling(type) {
      this.listTpye = 'calling'
      if (type === 'video') {
        this.callingType = 'video'
      }
      if (type === 'audio') {
        this.callingType = 'audio'
      }
      // 呼叫方设置
      if(this.currentConversationType === 'C2C') {
        let member = [this.toAccount]
        let callingData = {
          memberList:member,
          type:'C2C'
        }
        this.$store.commit('setCallingList',callingData)
        this.$bus.$emit(`${type}-call`)
        return
      }
      if(this.currentConversationType === this.TIM.TYPES.CONV_GROUP) {
        this.showCallingMember = true
      }
      // this.$store.commit('pushCurrentMessageList', true)
    },
    handleEmojiShow () {
      this.emojiShow = true
      this.bigEmojiShow = false
    },
    handleBigEmojiShow(index) {
      let elm = document.getElementById('bigEmojiBox')
      elm && (elm.scrollTop = 0)
      this.curItemIndex = index
      this.curBigEmojiItemList = this.bigEmojiList[index].list
      this.emojiShow = false
      this.bigEmojiShow = true
    },
    chooseBigEmoji(item) {
      this.popoverVisible = false
      let message = this.tim.createFaceMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: {
          index: this.curItemIndex + 1,
          data: `${item}@2x`
        }
      })
      this.$store.commit('pushCurrentMessageList', message)
      this.$bus.$emit('scroll-bottom')
      this.tim.sendMessage(message).catch(error => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
    },
    reEditMessage(payload) {
      this.messageContent = payload
    },
    handleUp() {
      const index = this.memberList.findIndex(
        member => member.userID === this.atUserID
      )
      if (index - 1 < 0) {
        return
      }
      this.atUserID = this.memberList[index - 1].userID
    },
    handleDown() {
      const index = this.memberList.findIndex(
        member => member.userID === this.atUserID
      )
      if (index + 1 >= this.memberList.length) {
        return
      }
      this.atUserID = this.memberList[index + 1].userID
    },
    handleEnter() {
      this.sendTextMessage()
    },
    inputChange(value) {
      if (this.currentConversationType === this.TIM.TYPES.CONV_GROUP && value.data === '@') {
        this.groupAt = true
        this.listTpye = 'groupAt'
        this.showCallingMember = true
      }
      if (value.data === ' ' && this.messageContent.indexOf('@ ') !== -1) {
        this.groupAt = false
        this.listTpye = ''
        this.showCallingMember = false
      }
    },
    handleLine() {
      this.messageContent += '\n'
    },
    handlePaste(e) {
      let clipboardData = e.clipboardData
      let file
      if (
        clipboardData &&
        clipboardData.files &&
        clipboardData.files.length > 0
      ) {
        file = clipboardData.files[0]
      }

      if (typeof file === 'undefined') {
        return
      }
      // 1. 创建消息实例，接口返回的实例可以上屏
      let message = this.tim.createImageMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: {
          file: file
        },
        onProgress: percent => {
          this.$set(message, 'progress', percent) // 手动给message 实例加个响应式属性: progress
        }
      })
      this.$store.commit('pushCurrentMessageList', message)

      // 2. 发送消息
      let promise = this.tim.sendMessage(message)
      promise.catch(error => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
    },
    dropHandler(e) {
      e.preventDefault()
      let file = e.dataTransfer.files[0]
      let message = {}
      if (file.type === 'video/mp4') {
        message = this.tim.createVideoMessage({
          to: this.toAccount,
          conversationType: this.currentConversationType,
          payload: {
            file: file
          },
          onProgress: percent => {
            this.$set(message, 'progress', percent) // 手动给message 实例加个响应式属性: progress
          }
        })
      } else {
        message = this.tim.createFileMessage({
          to: this.toAccount,
          conversationType: this.currentConversationType,
          payload: {
            file: file
          },
          onProgress: percent => {
            this.$set(message, 'progress', percent) // 手动给message 实例加个响应式属性: progress
          }
        })
      }
      this.$store.commit('pushCurrentMessageList', message)
      this.tim
        .sendMessage(message)
        .then(() => {
          this.$refs.videoPicker.value = null
        })
        .catch(imError => {
          this.$store.commit('showMessage', {
            message: imError.message,
            type: 'error'
          })
        })
    },
    sendTextMessage() {
      if (
        this.messageContent === '' ||
        this.messageContent.trim().length === 0
      ) {
        this.messageContent = ''
        this.$store.commit('showMessage', {
          message: '不能发送空消息哦！',
          type: 'info'
        })
        return
      }
      if (this.currentConversationType === this.TIM.TYPES.CONV_GROUP && this.groupAt) {
        let message = this.tim.createTextAtMessage({
          to: this.toAccount,
          conversationType: this.TIM.TYPES.CONV_GROUP,
          payload: {
            text: this.messageContent,
            atUserList: this.callingList // 'denny' 'lucy' 都是 userID，而非昵称
          }
        })
        this.$store.commit('pushCurrentMessageList', message)
        this.$bus.$emit('scroll-bottom')
        this.tim.sendMessage(message).catch(error => {
          this.$store.commit('showMessage', {
            type: 'error',
            message: error.message
          })
        })
        this.messageContent = ''
        this.groupAt = false
        return
      }
      const message = this.tim.createTextMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: { text: this.messageContent }
      })
      this.$store.commit('pushCurrentMessageList', message)
      this.$bus.$emit('scroll-bottom')
      this.tim.sendMessage(message).catch(error => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
      this.messageContent = ''
    },
    sendCustomMessage() {
      if (
        this.form.data.length === 0 &&
        this.form.description.length === 0 &&
        this.form.extension.length === 0
      ) {
        this.$store.commit('showMessage', {
          message: '不能发送空消息',
          type: 'info'
        })
        return
      }
      const message = this.tim.createCustomMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: {
          data: this.form.data,
          description: this.form.description,
          extension: this.form.extension
        }
      })
      this.$store.commit('pushCurrentMessageList', message)
      this.tim.sendMessage(message).catch(error => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
      Object.assign(this.form, {
        data: '',
        description: '',
        extension: ''
      })
      this.sendCustomDialogVisible = false
    },
    random(min, max) {
      return Math.floor(Math.random() * (max - min + 1) + min)
    },
    sendSurvey() {
      const message = this.tim.createCustomMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: {
          data: 'survey',
          description: String(this.rate),
          extension: this.suggestion
        }
      })
      this.$store.commit('pushCurrentMessageList', message)
      Object.assign(this.form, {
        data: '',
        description: '',
        extension: ''
      })
      this.tim
        .sendMessage(message)
        .then(() => {
          Object.assign(this, {
            rate: 5,
            suggestion: ''
          })
        })
        .catch(error => {
          this.$store.commit('showMessage', {
            type: 'error',
            message: error.message
          })
        })
      this.surveyDialogVisible = false
    },
    chooseEmoji(item) {
      this.messageContent += item
    },
    handleSendImageClick() {
      this.$refs.imagePicker.click()
    },
    handleSendFileClick() {
      this.$refs.filePicker.click()
    },
    handleSendVideoClick() {
      this.$refs.videoPicker.click()
    },
    groupLive() {
      this.$store.commit('updateGroupLiveInfo', {
        groupID: this.toAccount,
        anchorID: this.userID,
      })
      this.$bus.$emit('open-group-live', { channel: 1 })
    },
    sendImage() {
      const message = this.tim.createImageMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: {
          file: document.getElementById('imagePicker') // 或者用event.target
        },
        onProgress: percent => {
          this.$set(message, 'progress', percent) // 手动给message 实例加个响应式属性: progress
        }
      })
      this.$store.commit('pushCurrentMessageList', message)
      this.tim
        .sendMessage(message)
        .then(() => {
          this.$refs.imagePicker.value = null
        })
        .catch(imError => {
          this.$store.commit('showMessage', {
            message: imError.message,
            type: 'error'
          })
        })
    },
    sendFile() {
      const message = this.tim.createFileMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: {
          file: document.getElementById('filePicker') // 或者用event.target
        },
        onProgress: percent => {
          this.$set(message, 'progress', percent) // 手动给message 实例加个响应式属性: progress
        }
      })
      this.$store.commit('pushCurrentMessageList', message)
      this.tim
        .sendMessage(message)
        .then(() => {
          this.$refs.filePicker.value = null
        })
        .catch(imError => {
          this.$store.commit('showMessage', {
            message: imError.message,
            type: 'error'
          })
        })
    },
    sendVideo() {
      const message = this.tim.createVideoMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: {
          file: document.getElementById('videoPicker') // 或者用event.target
        },
        onProgress: percent => {
          this.$set(message, 'progress', percent) // 手动给message 实例加个响应式属性: progress
        }
      })
      this.$store.commit('pushCurrentMessageList', message)
      this.tim
        .sendMessage(message)
        .then(() => {
          this.$refs.videoPicker.value = null
        })
        .catch(imError => {
          this.$store.commit('showMessage', {
            message: imError.message,
            type: 'error'
          })
        })
    }
  }
}
</script>
<style lang="stylus" scoped>
#message-send-box-wrapper {
  box-sizing: border-box;
  overflow: hidden;
  padding: 3px 20px 20px 20px;
}

.emojis {
  height: 160px;
  box-sizing: border-box;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  overflow-y: scroll;
}

.emoji {
  height: 40px;
  width: 40px;
  box-sizing: border-box;
}

.send-header-bar {
  box-sizing: border-box;
  padding: 3px 0 0 0;
}

.send-header-bar i {
  cursor: pointer;
  font-size: 24px;
  color: gray;
  margin: 0 12px 0 0;
}

.send-header-bar i:hover {
  color: $black;
}

textarea {
  resize: none;
}

.text-input {
  font-size: 16px;
  width: 100%;
  box-sizing: box-sizing;
  border: none;
  outline: none;
  background-color: transparent;
}

.block {
  padding: 10px 0;
  display: flex;
  align-items: center;
}

.bottom {
  padding-top: 10px;
  position: relative;

  .btn-send {
    cursor: pointer;
    position: absolute;
    color: $primary;
    font-size: 30px;
    right: 0;
    bottom: -5px;
    padding: 6px 6px 4px 4px;
    border-radius: 50%;
  }
}
.group-live-icon-box {
    display inline-block
    position relative
    top 3px
    width 25px
    height 25px
    margin-right 12px
    .group-live-icon {
      display inline-block
      position absolute
      top 0
      left 0
      width 25px
      height 25px
      background url('../../assets/image/live-icon.png') center no-repeat
      background-size cover
      z-index 2
    }
    .group-live-icon-hover {
      display inline-block
      position absolute
      top 0
      left 0
      width 25px
      height 25px
      background url('../../assets/image/live-icon-hover.png') center no-repeat
      background-size cover
      z-index 1
    }
}
.group-live-icon-box:hover {
  .group-live-icon {
    z-index 1
  }
  .group-live-icon-hover{
    z-index 2
  }
}
.calling-member-list {
  position absolute
  top 50px
  background #fff
  margin-right 20px
  .calling-list-btn {
    width 140px
    display flex
    float right
    margin 10px 0
    .calling-btn {
      cursor pointer
      padding 6px 12px
      background #00A4FF
      color #ffffff
      font-size 14px
      border-radius 20px
      margin-left 13px
    }
  }
}
.el-popover {
  padding: 12px 0 0 0 !important;
}
</style>
