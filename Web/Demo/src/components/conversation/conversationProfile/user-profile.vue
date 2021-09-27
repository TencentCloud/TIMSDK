<template>
  <div class="profile-user">
    <avatar :title=userProfile.userID :src="userProfile.avatar" />
    <div class="nick-name text-ellipsis">
      <span v-if="userProfile.nick" :title=userProfile.nick>
        {{ userProfile.nick }}
      </span>
      <span v-else class="anonymous" title="该用户未设置昵称">
        [Anonymous]
      </span>
    </div>
    <div class="gender" v-if="genderClass">
      <span :title="gender" class="iconfont" :class="genderClass"></span>
    </div>
    <el-button
      title="将该用户加入黑名单"
      type="text"
      @click="addToBlackList"
      v-if="!isInBlacklist && userProfile.userID !== myUserID"
      class="btn-add-blacklist"
      >加入黑名单</el-button
    >
    <el-button title="将该用户移出黑名单" type="text" @click="removeFromBlacklist" v-else-if="isInBlacklist">移出黑名单</el-button>
    <el-button title="删除好友" type="text" @click="removeFromFriendList" v-if="isFriend">删除好友</el-button>
    <el-button
          title="加好友"
          type="text"
          @click="dialogAddFriendVisible = true"
          v-if="!isFriend"
          class="btn-add-friend"
    >添加好友</el-button>
    <el-dialog title="添加好友" :visible.sync="dialogAddFriendVisible" width="600px">
      <el-form :model="addInfo">
        <el-form-item label="" :label-width="formLabelWidth">
          <div class="add-item">
            <img
                    class="avatar"
                    :src="userProfile.avatar ? userProfile.avatar : 'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-2.png'"
            />
            <div  class="item-nick">{{userProfile.nick||userProfile.userID}}</div>
          </div>
        </el-form-item>
        <el-form-item label="请输入验证信息" :label-width="formLabelWidth">
          <el-input
                  type="textarea"
                  :rows="2"
                  placeholder="请输入内容"
                  v-model="addInfo.wording">
          </el-input>
        </el-form-item>
        <el-form-item label="分组" :label-width="formLabelWidth">
          <el-select v-model="addInfo.groupName" placeholder="">
            <el-option label="选择分组" value=""></el-option>
            <el-option  v-for="name in friendGroupNameList" :key="name" :label="name" :value="name"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="备注" :label-width="formLabelWidth">
          <el-input v-model="addInfo.remark" autocomplete="off"></el-input>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click="dialogAddFriendVisible = false">取 消</el-button>
        <el-button type="primary" @click="addFriend">确 定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { Select, Option, Form ,FormItem, Input} from 'element-ui'

// import FriendItem from './friend-item.vue'
export default {
  props: {
    userProfile: {
      type: Object,
      required: true
    }
  },
  components: {
    ElSelect: Select,
    ElOption: Option,
    ElForm: Form,
    ElFormItem: FormItem,
    ElInput: Input,
  },
  data() {
    return {
      addInfo: {
        remark: '',
        groupName: '',
        wording: '',
        type: this.TIM.TYPES.SNS_ADD_TYPE_BOTH,
      },
      formLabelWidth: '120px',
      dialogAddFriendVisible: false,
    }
  },
  computed: {
    ...mapState({
      blacklist: state => state.blacklist.blacklist,
      friendList: state => state.friend.friendList,
      myUserID: state => state.user.currentUserProfile.userID,
      friendGroupList: state => state.friend.friendGroupList
    }),
    isInBlacklist() {
      return this.blacklist.findIndex(item => item.userID === this.userProfile.userID) >= 0
    },
    isFriend() {
      return this.friendList.findIndex(item => item.userID === this.userProfile.userID) >= 0
    },
    friendGroupNameList() {
      return this.friendGroupList.map((item) => {return item.name})
    },
    gender() {
      switch (this.userProfile.gender) {
        case this.TIM.TYPES.GENDER_MALE:
          return '男'
        case this.TIM.TYPES.GENDER_FEMALE:
          return '女'
        default:
          return '未设置'
      }
    },
    genderClass() {
      switch (this.userProfile.gender) {
        case this.TIM.TYPES.GENDER_MALE:
          return 'icon-male'
        case this.TIM.TYPES.GENDER_FEMALE:
          return 'icon-female'
        default:
          return ''
      }
    }
  },
  created() {
  },
  methods: {
    addToBlackList() {
      this.tim
        .addToBlacklist({ userIDList: [this.userProfile.userID] })
        .then(() => {
          this.$store.dispatch('getBlacklist')
        })
        .catch(imError => {
          this.$store.commit('showMessage', {
            message: imError.message,
            type: 'error'
          })
        })
    },
    addFriend() {
      this.tim.addFriend({
        to: this.userProfile.userID,
        remark: this.addInfo.remark,
        groupName: this.addInfo.groupName,
        wording: this.addInfo.wording,
        source: 'AddSource_Type_Web',
        type: this.addInfo.type
      }).then((res) => {
          // console.log(res)
        if (res.data.code === 30539) {
          this.$store.commit('showMessage', {
            message: res.data.message,
            type: 'warning'
          })
        }
      })
        .catch(error => {
          this.$store.commit('showMessage', {
            message: error.message,
            type: 'warning'
          })
        })
      this.dialogAddFriendVisible = false
      this.addInfo = {
        remark: '',
        groupName: '',
        wording: '',
      }
    },
    removeFromFriendList() {
      let options = {
        userIDList: [this.userProfile.userID],
        type: this.TIM.TYPES.SNS_DELETE_TYPE_BOTH
      }
      this.tim.deleteFriend(options).then(() => {
      }).catch(error => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
    },
    removeFromBlacklist() {
      this.tim.removeFromBlacklist({ userIDList: [this.userProfile.userID] }).then(() => {
        this.$store.commit('removeFromBlacklist', this.userProfile.userID)
      })
      .catch(error => {
          this.$store.commit('showMessage', {
            type: 'error',
            message: error.message
          })
        })
    }
  }
}
</script>

<style lang="stylus" scoped>
.profile-user
  width 100%
  text-align center
  padding 0 20px
  .avatar
    width 160px
    height 160px
    border-radius 50%
    margin 30px auto
  .nick-name
    width 100%
    color $base
    font-size 20px
    font-weight bold
    text-shadow $font-dark 0 0 0.1em
    .anonymous
      color $first
      text-shadow none
  .gender
    padding 5px 0 10px 0
    border-bottom 1px solid $border-base
  .btn-add-blacklist
    color $danger
  .el-select
    margin-left -248px
  .add-item
    display flex
    .avatar
      display block
      width 48px
      height 48px
      border-radius 50%
      margin 0
    .item-nick
      line-height 48px
      margin-left  20px



</style>
