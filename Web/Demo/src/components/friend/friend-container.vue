<template>
    <div class="friend-content" v-if="showFriendContent || showApplicationContent" @click="closeHandler">
        <div class="friend-box" v-if="showFriendContent">
            <div class="profile-container" >
                <div class="item-nick text-ellipsis">{{friendProfile.profile.nick||friendProfile.profile.userID}}</div>
                <img
                        class="avatar"
                        :src="friendProfile.profile.avatar ? friendProfile.profile.avatar : 'https://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-2.png'"
                />
            </div>
            <el-divider></el-divider>
            <p class="content-box"><span class="content-title">userID</span><span class="content-text">{{friendProfile.userID}}</span></p>
            <div class="content-box"><span class="content-title">备注名</span>
                <div class="text-box"   v-if="!showEditRemark">
                    <span class="content-text  content-width text-ellipsis">{{friendProfile.remark || '暂无'}}</span>
                    <i
                            class="el-icon-edit"
                            @click.stop="
                        showEditRemark = true
                        inputFocus('showEditRemark')

            "
                            style="cursor:pointer; font-size:16px; margin-left: 6px"
                    />
                </div>
                <el-input
                        style="display: inline-block"
                        ref="showEditRemark"
                        v-else
                        autofocus
                        v-model="profileRemark"
                        size="mini"
                        @blur="blurHandler"
                        @keydown.enter.native="editRemarkHandler"
                />
            </div>

            <p class="content-box"><span class="content-title">来源</span><span class="content-text">{{getSource(friendProfile.source)}}</span></p>
            <el-divider></el-divider>
            <div class="content-box" v-show="friendType==='friendList'">
                <span class="content-title" v-show="!showEdit" style="line-height: 35px">所在分组</span>
                <span class="content-title" v-show="showEdit"  style="line-height: 35px">添加到分组</span>
                <div class="text-content">
                    <span class="content-text" v-show="!showEdit">{{groupName}}</span>
                    <i class="el-icon-edit edit-icon" v-show="!showEdit"   @click.stop="showEditHandler"></i>
                </div>
                <el-select v-if="showEdit" v-model="addGroupName"  placeholder="选择分组" @change="addToFriendGroup">
                    <el-option
                            v-for="item in friendGroupList"
                            @blur="showEdit = false"
                            :key="item.name"
                            :label="item.name"
                            :value="item.name">
                    </el-option>
                </el-select>
            </div>
            <p class="content-box" v-show="friendType==='groupFriend'" style="height: 40px">
                <span class="content-title" style="line-height: 35px">所在分组</span>
                <span class="content-text" v-show="!showEdit" style="line-height: 35px">{{groupName}}</span>
            </p>
            <div class="sendBtn" @click.stop="checkoutConversation(friendProfile.userID)">发送消息</div>
            <div class="delete-text" v-show="friendType==='groupFriend'" @click.stop="removeFromFriendGroup(friendProfile.userID)">从该群组中移除</div>
            <div class="delete-text" v-show="friendType==='friendList'" @click.stop="removeFromFriendList(friendProfile.userID)">删除该好友</div>
        </div>
        <div class="friend-box" v-if="showApplicationContent">
            <div class="profile-container" >
                <div class="item-nick text-ellipsis">{{applicationContent.nick||applicationContent.userID}}</div>
                <img
                        class="avatar"
                        :src="applicationContent.avatar ? applicationContent.avatar : 'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-2.png'"
                />
            </div>
            <el-divider></el-divider>
            <p class="content-box"><span class="content-title">userID</span><span class="content-text">{{applicationContent.userID}}</span></p>
            <p class="content-box"><span class="content-title">来源</span><span class="content-text content-width text-ellipsis">{{getSource(applicationContent.source)}}</span></p>
            <div class="content-box" v-if="showRemark"><span class="content-title">备注名</span>
                <el-input
                        style="display: inline-block"
                        ref="showRemark"
                        autofocus
                        v-model="acceptApplication.remark"
                        size="mini"
                        @blur="remarkBlurHandler"
                        @keydown.enter.native="editRemarkHandler"
                />
            </div>
            <el-divider></el-divider>
            <p class="content-box">
                <span class="content-title">打招呼</span>
                <el-tooltip class="item" effect="dark" :content="applicationContent.wording" placement="bottom-end">
                    <span class="content-text content-width text-ellipsis">{{applicationContent.wording}}</span>
                </el-tooltip>
            </p>
            <div class="application-box" v-if="!showRemark">
                <p class="application-refuse" @click="acceptHandler">同意</p>
                <p class="application-delete"  @click="refuseFriendApplication(applicationContent.userID)">拒绝</p>
            </div>
            <div class="application-box" v-else>
                <p class="application-refuse" @click="acceptFriendApplication(applicationContent.userID)">确认</p>
                <p class="application-delete"  @click="cancelHandler()">取消</p>
            </div>
        </div>
    </div>
</template>

<script>
  import { mapState } from 'vuex'
  export default {
    name: 'index',
    data() {
      return {
        showEdit: false,
        showEditRemark: false,
        showRemark: false,
        addGroupName: '',
        profileRemark: '',
        editGroupList: [],
        isUpdate: false,
        acceptApplication: {
          remark: '',
          type: 'Response_Action_AgreeAndAdd',
        },
      }
    },
    computed: {
      ...mapState({
        friendContent: state => state.friend.friendContent,
        applicationContent: state => state.friend.applicationContent,
        friendGroupList: state => state.friend.friendGroupList,
      }),
      showFriendContent() {
        if (JSON.stringify(this.friendContent) === '{}') {
          return false
        }
        return true
      },
      showApplicationContent() {
        if (JSON.stringify(this.applicationContent) === '{}') {
          return false
        }
        return true
      },
      friendProfile() {
        return this.friendContent.friend
      },
      groupName() {
        if(this.friendProfile.groupList.length>0) {
          return this.friendProfile.groupList.join(',')
        }else {
          return '暂无分组'
        }
      },
      groupList:{
        get() {
          return this.friendProfile.groupList
        },
        set(value) {
          this.editGroupList = value
        }
      },
      friendType() {
        return this.friendContent.type
      },
      getSource() {
        return function (source) {
          return source.substring(15)
        }
      },
    },
    methods: {
      showEditHandler() {
        this.showEdit = true
        this.addGroupName = ''
      },
      inputFocus(ref) {
        this.profileRemark = this.friendProfile.remark
        this.$nextTick(() => {
          this.$refs[ref].focus()
        })
      },
      blurHandler() {
        this.showEditRemark = false
        this.isUpdate = true
      },
      remarkBlurHandler() {
        // this.showEditRemark = false
      },
      acceptHandler() {
        this.showRemark = true
        this.acceptApplication.remark = ''
        this.$nextTick(() => {
          this.$refs.showRemark.focus()
        })
      },
      cancelHandler() {
        this.showRemark = false
      },
      closeHandler() {
        this.showEdit = false
        if (this.isUpdate) {
          this.editRemarkHandler()
        }
      },
      editRemarkHandler() {
        this.showEditRemark = false
        // 更新好友备注
        this.tim.updateFriend({
          userID: this.friendProfile.userID,
          remark: this.profileRemark
        }).then(()=> {
        }).catch((imError)=> {
          console.warn('getFriendProfile error:', imError) // 更新失败
        })
        this.isUpdate = false
      },
      updateFriendGroup() {
        this.profileRemark = this.friendProfile.remark
        // 更新好友分组
        this.tim.updateFriend({
          userID: this.friendProfile.userID,
          groupList: this.editGroupList
        }).then(()=>{
        }).catch((imError)=> {
          console.warn('getFriendProfile error:', imError) // 更新失败
        })
      },
      checkoutConversation(userID) {
        this.$store
          .dispatch('checkoutConversation', `C2C${userID}`)
          .then(() => {
            this.showDialog = false
            this.$bus.$emit('checkoutConversation')
          }).catch(() => {
          this.$store.commit('showMessage', {
            message: '没有找到该用户',
            type: 'warning'
          })
        })
      },
      addToFriendGroup() {
        this.tim.addToFriendGroup({name: this.addGroupName, userIDList: [this.friendProfile.userID]}).then(() => {
          this.$store.commit('showMessage', {
            message: '添加成功',
            type: 'success'
          })
        }).catch((error) => {
          this.$store.commit('showMessage', {
            type: 'error',
            message: error.message
          })
        })
        this.showEdit = false
      },
      removeFromFriendGroup(userID) {
        this.tim.removeFromFriendGroup({
          name: this.friendContent.groupName,
          userIDList: [userID],
        }).then(() => {
          this.resetContent() // 清空页面
        }).catch(() => {
        })
      },
      removeFromFriendList(userID) {
        this.tim.deleteFriend({
          userIDList: [userID],
          type: 'Delete_Type_Both'
        }).then(() => {
          this.resetContent() // 清空页面
        }).catch(error => {
          this.$store.commit('showMessage', {
            type: 'error',
            message: error.message
          })
        })
      },
      // 同意
      acceptFriendApplication(userID) {
        this.tim.acceptFriendApplication({
          userID: userID,
          remark: this.acceptApplication.remark,
          tag: this.acceptApplication.tag,
          type: this.acceptApplication.type
        }).then(() => {
          this.resetContent()
          this.$store.commit('showMessage', {
            message: '已同意加好友',
            type: 'success'
          })

        }).catch((error) => {
          this.$store.commit('showMessage', {
            type: 'error',
            message: error.message
          })
        })
        this.acceptApplication.remark = ''
        this.showRemark = false
      },
      // application
      deleteFriendApplication(application) {
        this.$store.commit('updateUnreadCount', 0)
        this.tim.deleteFriendApplication({userID: application.userID ,type: application.type}).then(() => {
          this.resetContent() // 清空页面
          this.$store.commit('showMessage', {
            message: '已删除',
            type: 'success'
          })
        }).catch((error) => {
          this.$store.commit('showMessage', {
            type: 'error',
            message: error.message
          })
        })
      },
      // 拒绝
      refuseFriendApplication(userID) {
        this.$store.commit('updateUnreadCount', 0)
        this.tim.refuseFriendApplication({
          userID: userID
        }).then(() => {
          this.resetContent() // 清空页面
          this.$store.commit('showMessage', {
            message: '已拒绝',
            type: 'success'
          }).catch((error) => {
            this.$store.commit('showMessage', {
              type: 'error',
              message: error.message
            })
          })
        })
      },
      resetContent() {
        this.$store.commit('resetCurrentConversation')
        this.$store.commit('resetFriendContent')
        this.$store.commit('resetApplicationContent')
      }
    }
  }
</script>

<style lang="stylus" scpoed>
    .friend-content {
        /*width 60%*/
        width 100%
        .friend-box {
            margin 100px auto 0
            width 360px
            .profile-container {
                display flex
                justify-content space-between
                .item-nick {
                    width 200px
                    line-height 48px
                }
                .avatar {
                    display block
                    width 48px
                    height 48px
                    border-radius 50%
                    margin-right 25px
                }
            }
            .el-input {
                width 50%
            }
            .el-select .el-input {
                width 100%
            }
            .content-box {
                display flex
                /*justify-content space-between*/
                margin 18px 0
                .text-content {
                    height 40px
                }
                .text-box {
                    display flex
                    justify-content center
                    align-items center
                }
                .content-title {
                    display inline-block
                    min-width 80px
                    font-size 16px
                    color #717175
                    margin-right 140px
                }
                .content-text {
                    font-size 18px
                    color #000000
                    word-break break-word
                }
                .content-width {
                    display inline-block
                    max-width 115px
                    height 28px
                }
                .edit-icon {
                    cursor: pointer
                    font-size 16px
                    margin-left 6px
                    margin-top 8px
                }

            }

            .sendBtn {
                cursor pointer
                width 120px
                height 40px
                border-radius 5px
                background-color #00A4FF
                color #ffffff
                font-size 16px
                margin 80px auto 0
                text-align center
                line-height 40px
            }

            .delete-text {
                position absolute
                cursor pointer
                left 0
                right 0
                margin auto
                bottom 25px
                width 120px
                height 40px
                font-size 17px
                color #586B95
                text-align center
            }
            .application-box {
                display flex
                justify-content space-between
            }
            .application-delete {
                cursor pointer
                width 120px
                height 40px
                border-radius 5px
                border 1px solid #00A4FF
                color #1c2438
                font-size 16px
                margin-top 80px
                text-align center
                line-height 40px
            }
            .application-refuse {
                cursor pointer
                width 120px
                height 40px
                border-radius 5px
                background-color #00A4FF
                border 1px solid #00A4FF
                color #ffffff
                font-size 16px
                margin-top 80px
                text-align center
                line-height 40px
            }
        }
    }


</style>
