<template>
  <message-bubble :isMine="false">
    <div class="group-system-element-wrapper">
      {{ text }}
      <el-button v-if="isJoinGroupRequest" type="text" @click="showDialog = true">处理</el-button>
      <el-dialog title="处理加群申请" :visible.sync="showDialog" width="30%">
        <el-form ref="form" v-model="form" label-width="100px">
          <el-form-item label="处理结果：">
            <el-radio-group v-model="form.handleAction">
              <el-radio label="Agree">同意</el-radio>
              <el-radio label="Reject">拒绝</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="附言：">
            <el-input
              type="textarea"
              resize="none"
              :rows="3"
              placeholder="请输入附言"
              v-model="form.handleMessage"
            />
          </el-form-item>
        </el-form>
        <span slot="footer" class="dialog-footer">
          <el-button @click="showDialog = false">取 消</el-button>
          <el-button type="primary" @click="handleGroupApplication">确 定</el-button>
        </span>
      </el-dialog>
    </div>
  </message-bubble>
</template>

<script>
import { Dialog, Form, FormItem, RadioGroup, Radio } from 'element-ui'
import MessageBubble from '../message-bubble'
import { translateGroupSystemNotice } from '../../../utils/common'

export default {
  name: 'GroupSystemNoticeElement',
  props: {
    payload: {
      type: Object,
      required: true
    },
    message: {
      type: Object,
      required: false
    }
  },
  components: {
    ElDialog: Dialog,
    ElForm: Form,
    ElFormItem: FormItem,
    ElRadioGroup: RadioGroup,
    ElRadio: Radio,
    MessageBubble,
  },
  data() {
    return {
      showDialog: false,
      form: {
        handleAction: 'Agree',
        handleMessage: ''
      }
    }
  },
  computed: {
    text() {
      return translateGroupSystemNotice(this.message)
    },
    title() {
      if (this.message.type === this.TIM.TYPES.MSG_GRP_SYS_NOTICE) {
        return '群系统通知'
      }
      return '系统通知'
    },
    isJoinGroupRequest() {
      return this.payload.operationType === 1
    }
  },
  methods: {
    handleGroupApplication() {
      this.tim
        .handleGroupApplication({
          handleAction: this.form.handleAction,
          handleMessage: this.form.handleMessage,
          message: this.message
        })
        .then(() => {
          this.showDialog = false
        })
        .catch(() => {
          this.showDialog = false
        })
    }
  }
}
</script>

<style lang="stylus" scoped>
.card {
  background: #fff;
  padding: 12px;
  border-radius: 5px;
  width: 300px;

  .card-header {
    font-size: 18px;
  }

  .card-content {
    font-size: 14px;
  }
}
</style>
