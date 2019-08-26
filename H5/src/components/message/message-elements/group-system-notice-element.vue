<template>
  <div class="group-system-element-wrapper">
    {{ text }}
    <el-button v-if="isJoinGroupRequest" type="text" @click="showDialog = true">处理</el-button>
    <!-- <el-button type="text" style="color:red;" @click="deleteGroupSystemNotice">删除</el-button> -->
    <el-dialog title="处理加群申请" :visible.sync="showDialog">
      <el-form ref="form" v-model="form" label-width="100px">
        <el-form-item label="处理结果：">
          <el-radio-group v-model="form.handleAction">
            <el-radio label="Agree">同意</el-radio>
            <el-radio label="Reject">拒绝</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="附言：">
          <el-input type="textarea" resize="none" :rows="3" placeholder="请输入附言" v-model="form.handleMessage" />
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="showDialog = false">取 消</el-button>
        <el-button type="primary" @click="handleGroupApplication">确 定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { Dialog, Form, FormItem, RadioGroup, Radio } from 'element-ui'
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
    ElRadio: Radio
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
      return this.translateGroupSystemNotice(this.payload)
    },
    isJoinGroupRequest() {
      return this.payload.operationType === 1
    }
  },
  methods: {
    translateGroupSystemNotice(payload) {
      const groupName = payload.groupProfile.groupName || payload.groupProfile.groupID
      switch (payload.operationType) {
        case 1:
          return `${payload.operatorID} 申请加入群组：${groupName}`
        case 2:
          return `成功加入群组：${groupName}`
        case 3:
          return `申请加入群组：${groupName}被拒绝`
        case 4:
          return `被管理员${payload.operatorID}踢出群组：${groupName}`
        case 5:
          return `群：${groupName} 已被${payload.operatorID}解散`
        case 6:
          return `${payload.operatorID}创建群：${groupName}`
        case 7:
          return `${payload.operatorID}邀请你加群：${groupName}`
        case 8:
          return `你退出群组：${groupName}`
        case 9:
          return `你被${payload.operatorID}设置为群：${groupName}的管理员`
        case 10:
          return `你被${payload.operatorID}撤销群：${groupName}的管理员身份`
        case 255:
          return '自定义群系统通知'
      }
    },
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

<style></style>
