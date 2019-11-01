<template>
  <div class="my-profile-wrapper">
    <el-dialog title="编辑个人资料" :visible.sync="showEditMyProfile" width="30%">
      <el-form v-model="form" label-width="100px">
        <el-form-item label="头像">
          <el-input v-model="form.avatar" placeholder="头像地址(URL)" />
        </el-form-item>
        <el-form-item label="昵称">
          <el-input v-model="form.nick" placeholder="昵称" />
        </el-form-item>
        <el-form-item label="性别">
          <el-radio-group v-model="form.gender">
            <el-radio :label="TIM.TYPES.GENDER_MALE">男</el-radio>
            <el-radio :label="TIM.TYPES.GENDER_FEMALE">女</el-radio>
            <el-radio :label="TIM.TYPES.GENDER_UNKNOWN">不显示</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="showEditMyProfile = false">取 消</el-button>
        <el-button type="primary" @click="editMyProfile">确 定</el-button>
      </span>
    </el-dialog>
    <el-popover :width="200" trigger="click" placement="right" class="popover">
      <profile-card :profile="currentUserProfile" />
      <i class="el-icon-setting edit-my-profile" @click="handleEdit"></i>
      <avatar
        slot="reference"
        :src="currentUserProfile.avatar"
        class="my-avatar"
      />
    </el-popover>
  </div>
</template>

<script>
import { Popover, Form, FormItem, RadioGroup, Radio } from 'element-ui'
import { mapState } from 'vuex'
import ProfileCard from './profile-card'
export default {
  name: 'MyProfile',
  components: {
    ElPopover: Popover,
    ProfileCard,
    ElForm: Form,
    ElFormItem: FormItem,
    ElRadioGroup: RadioGroup,
    ElRadio: Radio
  },
  data() {
    return {
      showEditMyProfile: false,
      form: { avatar: '', nick: '', gender: '' }
    }
  },
  computed: {
    ...mapState({
      currentUserProfile: state => state.user.currentUserProfile,
      currentConversation: state => state.conversation.currentConversation
    }),
    gender() {
      switch (this.currentUserProfile.gender) {
        case this.TIM.TYPES.GENDER_MALE:
          return '男'
        case this.TIM.TYPES.GENDER_FEMALE:
          return '女'
        default:
          return '暂无'
      }
    }
  },
  methods: {
    editMyProfile() {
      if (this.form.avatar && this.form.avatar.indexOf('http') === -1) {
        this.$store.commit('showMessage', {
          message: '头像应该是 Url 地址',
          type: 'warning'
        })
        this.form.avatar = ''
        return
      }
      const options = {}
      // 过滤空串
      Object.keys(this.form).forEach(key => {
        if (this.form[key]) {
          options[key] = this.form[key]
        }
      })
      this.tim
        .updateMyProfile(options)
        .then(() => {
          this.$store.commit('showMessage', {
            message: '修改成功'
          })
          this.showEditMyProfile = false
        })
        .catch(imError => {
          this.$store.commit('showMessage', {
            message: imError.message,
            type: 'error'
          })
        })
    },
    handleEdit() {
      const { avatar, nick, gender } = this.currentUserProfile
      Object.assign(this.form, { avatar, nick, gender })
      this.showEditMyProfile = true
    }
  }
}
</script>

<style lang="stylus" scoped>
.my-profile-wrapper
  width 50px
  height 50px
  margin 15px
  &>span
    display: block;
    width: 100%;
    height: 100%;
  .popover
    padding none 
    border none 
    border-radius 30px
.my-avatar
  cursor pointer
  border-radius: 50%;

.edit-my-profile
  position absolute
  top 10px
  right 10px
  cursor pointer
</style>
