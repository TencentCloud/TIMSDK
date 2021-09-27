<template>
  <div class="friend-container">
    <div class="add-friend" @click="handleAddButtonClick">
      <i class="tim-icon-friend-add" style="font-size: 28px"></i>
      <span style="margin-left: 6px">加好友</span>
    </div>
    <el-dialog title="快速搜索好友" :visible.sync="showDialog" width="400px">
      <el-input placeholder="请输入用户ID" v-model="userID" @keydown.enter.native="addFriendConfirm">
        <el-button slot="append" icon="el-icon-search" @click="addFriendConfirm"></el-button>
        </el-input>
      <el-divider></el-divider>
      <div class="search-item" v-if="searchShow">
        <avatar :src="profile.avatar" />
        <div   class="item-nick">{{profile.nick||profile.userID}}</div>
        <img  class="add-friend-icon" src="../../assets/image/add-friend.png" @click="addFriendPopClick"/>
      </div>
    </el-dialog>
<!--    添加好友-->
    <el-dialog title="添加好友" :visible.sync="dialogAddFriendVisible" width="600px">
        <el-form :model="addForm">
          <el-form-item label="" :label-width="formLabelWidth">
            <div class="search-item">
              <avatar :src="profile.avatar" />
              <div  class="item-nick">{{profile.nick||profile.userID}}</div>
            </div>
          </el-form-item>
          <el-form-item label="请输入验证信息" :label-width="formLabelWidth">
            <el-input
                    type="textarea"
                    :rows="2"
                    placeholder="请输入验证信息"
                    v-model="addForm.wording">
            </el-input>
          </el-form-item>
          <el-form-item label="分组" :label-width="formLabelWidth">
            <el-select v-model="addForm.groupName" placeholder="">
              <el-option label="选择分组" value=""></el-option>
              <el-option  v-for="name in friendGroupNameList" :key="name" :label="name" :value="name"></el-option>
            </el-select>
          </el-form-item>
          <el-form-item label="备注" :label-width="formLabelWidth">
            <el-input v-model="addForm.remark" autocomplete="off"></el-input>
          </el-form-item>
        </el-form>
        <div slot="footer" class="dialog-footer">
          <el-button @click="dialogAddFriendVisible = false">取 消</el-button>
          <el-button type="primary" @click="addFriend">确 定</el-button>
        </div>
      </el-dialog>
    <el-dialog title="新增好友分组" :visible.sync="dialogAddGroup" width="400px">
      <el-input placeholder="请输入分组名称" v-model="groupName" @keydown.enter.native="addGroupConfirm"/>
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogAddGroup = false">取 消</el-button>
        <el-button type="primary" @click="addGroupConfirm">确 定</el-button>
      </span>
    </el-dialog>
    <el-dialog title="请输入分组名称" :visible.sync="dialogRenameGroup" width="400px">
      <el-input  v-model="newGroupName" @keydown.enter.native="renameGroupConfirm"/>
      <span slot="footer" class="dialog-footer">
        <el-button @click="dialogRenameGroup = false">取 消</el-button>
        <el-button type="primary" @click="renameGroupConfirm">确 定</el-button>
      </span>
    </el-dialog>
    <div class="scroll-container">
      <div class="menu-container">
        <el-menu
                default-active="application"
                class="el-menu-vertical-demo"
                :default-openeds="openeds"
                @open="handleOpen"
                @close="handleClose">
          <el-submenu index="application" style="border-buttom:1px solid #1c2438">
            <template slot="title">
              <i :class="{'el-icon-arrow-right': !active['application'], 'el-icon-arrow-down': active['application']}"></i>
              <span>新的好友
                <sup class="unread" v-if="applicationUnreadCount !== 0">
                  <template v-if="applicationUnreadCount > 99">99+</template>
                  <template v-else>{{applicationUnreadCount}}</template>
                </sup>
            </span>
            </template>
            <el-menu-item-group>
              <el-menu-item :index="application.userID" v-for="(application, index) in comeInApplicationList" :key="application.userID">
                <friend-application  :application="application" :index="index"></friend-application>
              </el-menu-item>
            </el-menu-item-group>
          </el-submenu>
          <el-submenu index="friendGroup">
            <template slot="title">
              <i :class="{'el-icon-arrow-right': !active['friendGroup'], 'el-icon-arrow-down': active['friendGroup']}"></i>
              <span>好友分组</span>
              <i class="el-icon-circle-plus-outline friend-group-btn" style="right: 20px;font-size: 20px" @click.stop="dialogAddGroup=true"></i>
            </template>
            <el-menu-item-group>
              <el-submenu :index="friendGroup.name" v-for="friendGroup in friendGroupList" :key="friendGroup.name">
                <template slot="title">
                  <i :class="{'el-icon-arrow-right': !active[friendGroup.name], 'el-icon-arrow-down': active[friendGroup.name]}" v-show="friendGroup.userIDList.length>0" class="animated"></i>
                  <i style="padding-left: 15px" v-show="friendGroup.userIDList.length===0"></i>
                  <span>{{friendGroup.name}}</span>
                  <span @click.stop>
                  <el-popover
                          placement="bottom-start"
                          width="200"
                          trigger="click"
                  >

                    <p @click="renameFriendGroupHandler(friendGroup.name)">重命名该组</p>
                    <p @click="deleteFriendGroup(friendGroup.name)">删除该组</p>
                     <img src="../../assets/image/more-icon.png" class="friend-group-btn more-icon" slot="reference">
                  </el-popover>
                </span>
                </template>
                <el-menu-item index="1-4-1" v-for="(friend,index) in groupFriend(friendGroup.userIDList)" :key="friend.userID" >
                  <friend-item  :friend="friend" :friendGroupNameList="friendGroupNameList"  :index="index" :type="'groupFriend'" :groupName="friendGroup.name">
                  </friend-item>
                </el-menu-item>
              </el-submenu>
            </el-menu-item-group>
          </el-submenu>
          <el-submenu :hide-timeout="hideTimeOut"  index="friendList" style="border-buttom:1px solid #1c2438">
            <template slot="title">
              <i :class="{'el-icon-arrow-right': !active['friendList'], 'el-icon-arrow-down': active['friendList']}"></i>
              <span>联系人</span>
            </template>
            <el-menu-item-group>
              <el-menu-item   :index="friend.userID" v-for="(friend,index) in friendList"  :key="friend.userID">
                <friend-item  :index="index" :friend="friend"  :friendGroupNameList="friendGroupNameList" :type="'friendList'"/>
              </el-menu-item>
            </el-menu-item-group>
          </el-submenu>
        </el-menu>
      </div>
    </div>

  </div>
</template>

<script>
import { mapState } from 'vuex'
import FriendItem from './friend-item.vue'
import FriendApplication from './friend-application/application-item.vue'
export default {
  components: {
    FriendItem,
    FriendApplication
  },
  data() {
    return {
      active: {},
      hideTimeOut: 1000,
      openeds: ['friendList'],
      showDialog: false,
      searchShow: false,
      dialogAddFriendVisible: false,
      dialogRenameGroup: false,
      dialogAddGroup: false,
      userID: '',
      groupName: '',
      newGroupName: '',
      oldGroupName: '',
      addForm: {
        userID: '',
        remark: '',
        groupName: '',
        wording: '',
        type: this.TIM.TYPES.SNS_ADD_TYPE_BOTH
      },
      addInfo: {
        groupName: '',
        userList: ''
      },
      profile: {
        avatar: '',
        nick: '',
        userID: '',
      },
      formLabelWidth: '120px'
    }
  },
  computed: {
    ...mapState({
      friendList: state => state.friend.friendList,
      applicationList: state => state.friend.applicationList,
      applicationUnreadCount: state => state.friend.unreadCount,
      myProfile: state => state.user.currentUserProfile,
      friendGroupList: state => state.friend.friendGroupList,
    }),
    hasFriend() {
      return this.friendList.length > 0
    },
    friendGroupNameList() {
      return this.friendGroupList.map((item) => {return item.name})
    },
    comeInApplicationList() {
      return this.applicationList.filter((item) => {return item.type === this.TIM.TYPES.SNS_APPLICATION_SENT_TO_ME})
    },
    groupFriend() {
      return function (userIDList) {
        if (userIDList.length === 0) {
          return
        }
        return this.friendList.filter((item) => userIDList.indexOf(item.userID) > -1)
      }
    },
  },
  mounted() {
    this.$set(this.active, 'friendList',  true)
  },
  methods: {
    handleOpen(key, keyPath) {
      if(keyPath.length ===1) {
        this.$set(this.active, keyPath[0], true)
      }else {
        this.$set(this.active, keyPath[1], true)
      }
      if(key === 'application' && this.applicationUnreadCount > 0) {
        this.tim.setFriendApplicationRead().then(()=> {
          this.$store.commit('updateUnreadCount', 0)
          // 已读上报成功
        }).catch((imError)=> {
          console.warn('setFriendApplicationRead error:', imError)
        })
      }
    },
    handleClose(key, keyPath) {
      if(keyPath.length ===1) {
        this.$set(this.active, keyPath[0], false)
      }else {
        this.$set(this.active, keyPath[1], false)
      }
    },
    handleAddButtonClick() {
      this.showDialog = true
    },
    addFriendPopClick() {
      this.showDialog = false
      this.dialogAddFriendVisible = true
      // this.addForm.wording = `我是${this.myProfile.nick || this.myProfile.userID} ...`
    },
    addFriendConfirm() {
      this.tim.getUserProfile({
        userIDList: [this.userID]
      }).then((imResponse) => {
        this.searchShow = true
        const profile = imResponse.data[0]
        this.addForm.userID  = profile.userID
        this.profile.avatar = profile.avatar
        this.profile.userID = profile.userID
        this.profile.nick = profile.nick
      }).catch((imError)=> {
        console.warn('getUserProfile error:', imError) // 获取其他用户资料失败的相关信息
        this.searchShow = false
        this.$store.commit('showMessage', {
          message: '没有找到该用户',
          type: 'warning'
        })
      })
      this.userID = ''
    },
    addFriend() {
      this.dialogAddFriendVisible = false
      this.tim.addFriend({
        to: this.addForm.userID,
        remark: this.addForm.remark,
        groupName: this.addForm.groupName,
        wording: this.addForm.wording,
        source: 'AddSource_Type_Web',
        type: this.addForm.type
      }).then((res) => {
        if (res.data.code === 0) {
          this.$store.commit('showMessage', {
            message: '添加成功',
            type: 'success'
          })
        }
        if (res.data.code === 30539) {
          this.$store.commit('showMessage', {
            message: res.data.message,
            type: 'warning'
          })
        }
      }).catch(error => {
        this.$store.commit('showMessage', {
          message: error.message,
          type: 'warning'
        })
      })
      this.searchShow = false
      this.profile =  {
        avatar: '',
        nick: '',
        userID: '',
      }
      this.addForm = {
        userID: '',
        remark: '',
        groupName: '',
        wording: '',
      }
    },
    addGroupConfirm() {
      this.tim.createFriendGroup({
        name: this.groupName
      }).then(() => {
      }).catch((error) => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
      this.groupName = ''
      this.dialogAddGroup = false
    },
    deleteFriendGroup(name) {
      this.tim.deleteFriendGroup({
        name: name
      }).then(() => {
        this.$store.commit('showMessage', {
          message: '删除成功',
          type: 'success'
        })
      }).catch((error) => {
        this.$store.commit('showMessage', {
          message: error.message,
          type: 'warning'
        })
      })
    },
    renameFriendGroupHandler(name) {
      this.dialogRenameGroup = true
      this.oldGroupName = name
      this.newGroupName = name
    },
    renameGroupConfirm() {
      this.tim.renameFriendGroup({
        oldName: this.oldGroupName,
        newName: this.newGroupName
      }).then(() => {
        this.$store.commit('showMessage', {
          message: '修改成功',
          type: 'success'
        })
      }).catch((error) => {
        this.$store.commit('showMessage', {
          message: error.message,
          type: 'warning'
        })
      })
      this.dialogRenameGroup = false
    }
  }
}
</script>
<style lang="stylus" scpoed>
.friend-container {
    height 100%
    width 100%
    display flex
    flex-direction column // -reverse
  .add-friend {
    width 100%
    cursor pointer
    color #dddddd
    font-size 18px
    margin 20px auto 0px
    text-align center
    height 40px
    border-bottom 1px solid #1c2438
  }
  .scroll-container  {
    overflow-y scroll
    flex 1
    .menu-container {
      .unread {
        position: absolute;
        top: 10px;
        margin-left 2px
        z-index: 999;
        display: inline-block;
        height: 18px;
        padding: 0 6px;
        font-size: 12px;
        color: #FFF;
        line-height: 18px;
        text-align: center;
        white-space: nowrap;
        border-radius: 10px;
        background-color: $danger;
      }
      .friend-group-btn {
        position absolute
        top 20px
        right 15px
        bottom 0
        margin auto
      }
      .more-icon {
        display block
        width 36px
        top: -3px
      }
      .el-submenu__title, .el-menu-item {
        font-size 16px
        color #ffffff
      }
      .el-menu-item {
        padding-left 20px !important
        padding-right 10px
        height 58px
        line-height 58px
      }
      .el-menu-item * {
        vertical-align: baseline
        }
      .el-submenu {
        font-size 20px
      }
      .el-submenu .el-submenu__title {
        /*padding-left 0 !important*/
      }
      .el-menu-item:focus, .el-menu-item:hover {
        background-color #404953
      }
      .el-submenu__title:focus, .el-submenu__title:hover {
        background-color #404953
      }
      .el-menu-item {
        padding-left 10px !important
      }
      .el-menu {
        background-color transparent
        border-right none
      }
      .el-menu-vertical-demo {
        background-color transparent
      }
      .el-submenu__icon-arrow {
        display none
      }
    }
    .friend-list-container {
      border-top 1px solid #1c2438
      padding-top 10px
      padding-left -15px
    }
  }
  .default {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
    overflow-y: scroll;
  }
  .search-item {
    display flex
    .avatar {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      flex-shrink: 0
      box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
    }
    .item-nick {
      margin-left 20px
      line-height 48px
    }

  }

  .el-icon-circle-plus-outline:before {
    color #ffffff
  }
  .add-friend-icon {
    cursor pointer
    width 30px
    height 30px
    display block
    position absolute
    right 40px
    bottom 40px
  }
  .el-icon-arrow-right {
    transition: all .2s ease;
  }
}


</style>
