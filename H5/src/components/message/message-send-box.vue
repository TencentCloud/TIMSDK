<template>
  <div id="message-send-box-wrapper">
    <div class="send-header-bar">
      <el-popover placement="top" width="400" trigger="click">
        <div class="emojis">
          <div v-for="item in emojiName" class="emoji" :key="item" @click="chooseEmoji(item)">
            <img :src="emojiUrl + emojiMap[item]" style="width:25px;height:25px" />
          </div>
        </div>
        <i class="iconfont icon-face" slot="reference" title="发表情"></i>
      </el-popover>
      <i class="el-icon-picture-outline" title="发图片" @click="handleSendImageClick"></i>
      <i class="el-icon-folder" title="发文件" @click="handleSendFileClick"></i>
      <i class="iconfont icon-custom" title="发自定义消息" @click="sendCustomDialogVisible = true"></i>
      <i class="iconfont icon-dice" title="投骰子" @click="sendDice"></i>
    </div>
    <el-dialog title="发自定消息" :visible.sync="sendCustomDialogVisible">
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
    <el-popover trigger="manual" v-model="showAtGroupMember" placement="top" style="max-height:500px;overflow-y:scroll;">
      <el-radio-group
        v-model="atUserID"
        style="display:flex;flex-decoration: column;"
        v-for="member in memberList"
        :key="member.userID"
        @change="handleSelectAtUser"
      >
        <el-radio :label="member.userID">{{ member.nameCard || member.nick || member.userID }}</el-radio>
      </el-radio-group>
      <el-input
        slot="reference"
        type="textarea"
        :rows="4"
        resize="none"
        v-model="messageContent"
        class="text-input"
        @input="handleTextInput"
        @keydown.enter.native.prevent="handleEnter"
        @keydown.up.native.prevent="handleUp"
        @keydown.down.native.prevent="handleDown"
      />
    </el-popover>
    <input
      type="file"
      id="imagePicker"
      ref="imagePicker"
      accept=".jpg, .jpeg, .png, .gif"
      @change="sendImage"
      style="display:none"
    />
    <input type="file" id="filePicker" ref="filePicker" @change="sendFile" style="display:none" />
    <el-button size="small" class="btn-send" @click="sendTextMessage">发送(Enter)</el-button>
  </div>
</template>

<script>
import { mapGetters, mapState } from 'vuex'
import { Form, FormItem, Input, Dialog, Popover, RadioGroup, Radio } from 'element-ui'
import { emojiMap, emojiName, emojiUrl } from '../../utils/emojiMap'
export default {
  name: 'message-send-box',
  props: ['scrollMessageListToButtom'],
  components: {
    ElInput: Input,
    ElForm: Form,
    ElFormItem: FormItem,
    ElDialog: Dialog,
    ElPopover: Popover,
    ElRadioGroup: RadioGroup,
    ElRadio: Radio
  },
  data() {
    return {
      messageContent: '',
      isSendCustomMessage: false,
      sendCustomDialogVisible: false,
      form: {
        data: '',
        description: '',
        extension: ''
      },
      file: '',
      emojiMap: emojiMap,
      emojiName: emojiName,
      emojiUrl: emojiUrl,
      showAtGroupMember: false,
      atUserID: ''
    }
  },

  computed: {
    ...mapGetters(['toAccount', 'currentConversationType']),
    ...mapState({
      memberList: state => state.group.currentMemberList
    })
  },
  methods: {
    handleTextInput(event) {
      if (
        event.slice(-1) === '@' &&
        this.currentConversationType === this.TIM.TYPES.CONV_GROUP &&
        this.memberList.length > 0
      ) {
        this.atUserID = this.memberList[0].userID
        this.showAtGroupMember = true
      } else {
        this.showAtGroupMember = false
      }
    },
    handleSelectAtUser() {
      this.messageContent += this.atUserID + ' '
      this.showAtGroupMember = false
    },
    handleUp() {
      const index = this.memberList.findIndex(member => member.userID === this.atUserID)
      if (index - 1 < 0) {
        return
      }
      this.atUserID = this.memberList[index - 1].userID
    },
    handleDown() {
      const index = this.memberList.findIndex(member => member.userID === this.atUserID)
      if (index + 1 >= this.memberList.length) {
        return
      }
      this.atUserID = this.memberList[index + 1].userID
    },
    handleEnter() {
      if (this.showAtGroupMember) {
        this.handleSelectAtUser()
      } else {
        this.sendTextMessage()
      }
    },
    sendTextMessage() {
      if (this.messageContent === '' || this.messageContent.trim().length === 0) {
        this.messageContent = ''
        this.$message('不能发送空消息哦！')
        return
      }
      const message = this.tim.createTextMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: { text: this.messageContent }
      })
      this.$store.commit('pushCurrentMessageList', message)
      this.$bus.$emit('scroll-bottom')
      this.tim.sendMessage(message)
      this.messageContent = ''
    },
    sendCustomMessage() {
      if (this.form.data.length === 0 && this.form.description.length === 0 && this.form.extension.length === 0) {
        this.$message.warning('不能发送空消息')
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
      this.tim.sendMessage(message)
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
    sendDice() {
      const message = this.tim.createCustomMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: {
          data: 'dice',
          description: String(this.random(1, 6)),
          extension: ''
        }
      })
      this.$store.commit('pushCurrentMessageList', message)
      this.tim.sendMessage(message)
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
      this.tim.sendMessage(message).catch(imError => this.$message.error(imError.message))
      this.$refs.imagePicker.value = null
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
      this.tim.sendMessage(message).catch(imError => this.$message.error(imError.message))
      this.$refs.filePicker.value = null
    }
  }
}
</script>

<style>
#message-send-box-wrapper {
  position: relative;
  width: 100%;
  bottom: 0;
  left: 0;
  padding: 12px;
  box-sizing: border-box;
  border-top: 1px solid #dddddd;
}
.emojis {
  height: 160px;
  border-bottom: 1px solid #eeeeee;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  flex-wrap: wrap;
  overflow-x: scroll;
}
.emoji {
  height: 28px;
  width: 28px;
  padding: 2px 3px 3px 2px;
  box-sizing: border-box;
}
.btn-send {
  position: absolute;
  bottom: 20px;
  right: 40px;
}
.send-header-bar i {
  cursor: pointer;
  font-size: 2.0rem;
  color: gray;
  margin: 0 6px;
}
.send-header-bar i:hover {
  color: #000;
}
.text-input textarea {
  background-color: transparent;
  border: none;
}
</style>
