<template>
  <div class="container">
<!--    <i-modal title="添加的用户ID" :visible="addModalVisible" @ok="handleAdd" @cancel="handleModalShow">-->
<!--      <div class="input-wrapper">-->
<!--        <input type="text" class="input border center" v-model.lazy:value="addUserId"/>-->
<!--      </div>-->
<!--    </i-modal>-->
    <i-modal title="提示" :visible="applyModalVisible" @ok="handleApply" @cancel="handleApplyModal">
      <div class="input-wrapper">
        确定要加入群{{search}}吗？
      </div>
    </i-modal>
    <div class="methods">
      <div class="search-wrapper">
        <input type="text" class="search" placeholder="输入群ID进行搜索" v-model.lazy:value="search" confirm-type="search" @confirm="confirm()"/>
      </div>
      <div class="item" @click="startConversation()">
        <i-row>
          <i-col span="4">
            <div style="padding: 10px">
              <i-avatar shape="square" size="large" src="../../../static/images/start.png" />
            </div>
          </i-col>
          <i-col span="20">
            <div class="right border-bottom">
              <div class="information">发起会话</div>
            </div>
          </i-col>
        </i-row>
      </div>
<!--      <div class="item" @click="handleModalShow()">-->
<!--        <i-row>-->
<!--          <i-col span="4">-->
<!--            <div style="padding: 10px">-->
<!--              <i-avatar shape="square" size="large" src="../../../static/images/add.png" />-->
<!--            </div>-->
<!--          </i-col>-->
<!--          <i-col span="20">-->
<!--            <div class="right border-bottom">-->
<!--              <div class="information">添加好友</div>-->
<!--            </div>-->
<!--          </i-col>-->
<!--        </i-row>-->
<!--      </div>-->
      <div class="item" @click="createGroup()">
        <i-row>
          <i-col span="4">
            <div style="padding: 10px">
              <i-avatar shape="square" size="large" src="../../../static/images/group.png" />
            </div>
          </i-col>
          <i-col span="20">
            <div class="right border-bottom">
              <div class="information">新建群聊</div>
            </div>
          </i-col>
        </i-row>
      </div>
      <div class="item" @click="toBlacklist()">
        <i-row>
          <i-col span="4">
            <div style="padding: 10px">
              <i-avatar shape="square" size="large" src="../../../static/images/blacklist.png" />
            </div>
          </i-col>
          <i-col span="20">
            <div class="right">
              <div class="information border-bottom">黑名单</div>
            </div>
          </i-col>
        </i-row>
      </div>
      <div class="item" @click="toGroupList()">
        <i-row style="border-bottom: 1px solid #e9eaec">
          <i-col span="4">
            <div style="padding: 10px">
              <i-avatar shape="square" size="large" src="../../../static/images/contact.png" />
            </div>
          </i-col>
          <i-col span="20">
            <div class="right">
              <div class="information  border-bottom">我的群聊</div>
            </div>
          </i-col>
        </i-row>
      </div>
    </div>
<!--    <div class="friends">-->
<!--      <div class="slot">-->
<!--        联系人-->
<!--      </div>-->
<!--      <div class="friend">-->
<!--        <i-row v-for="item in friends" :key="item.name" @click="chatTo(item)">-->
<!--          <i-col span="4">-->
<!--            <div style="padding: 10px">-->
<!--              <i-avatar shape="square" size="large" src="../../../static/images/header.png" />-->
<!--            </div>-->
<!--          </i-col>-->
<!--          <i-col span="20">-->
<!--            <p class="line">{{item.profile.nick || item.profile.userID}}</p>-->
<!--          </i-col>-->
<!--        </i-row>-->
<!--      </div>-->
<!--    </div>-->
  </div>
</template>

<script>
export default {
  data () {
    return {
      search: '',
      friends: [],
      addModalVisible: false,
      addUserId: '',
      applyModalVisible: false,
      result: {}
    }
  },
  components: {},
  methods: {
    handleApply () {
      wx.$app
        .joinGroup({ groupID: this.result.groupID, type: this.result.type })
        .then(res => {
          if (res.data.status === 'JoinedSuccess') {
            this.$store.commit('showToast', {
              title: '加群成功'
            })
            this.search = ''
          } else {
            this.$store.commit('showToast', {
              title: '申请成功，等待群管理员确认'
            })
          }
          this.handleApplyModal()
        })
        .catch(() => {
          this.$store.commit('showToast', {
            title: '加群失败'
          })
        })
    },
    handleApplyModal () {
      this.applyModalVisible = !this.applyModalVisible
    },
    // 软键盘点击搜索
    confirm () {
      if (this.search !== '@TIM#SYSTEM') {
        wx.$app.searchGroupByID(this.search).then((res) => {
          this.result = res.data.group
          this.handleApplyModal()
        }).catch(() => {
          this.search = ''
          this.$store.commit('showToast', {
            title: '没有搜到群组'
          })
        })
      } else {
        this.$store.commit('showToast', {
          title: '没有搜到群组'
        })
      }
    },
    // 初始化朋友列表
    initFriendsList () {
      wx.$app.getFriendList({
        fromAccount: this.$store.state.user.userProfile.to
      }).then(res => {
        this.friends = res.data
      })
    },
    // 去黑名单页面
    toBlacklist () {
      let url = '../blacklist/main'
      wx.navigateTo({url})
    },
    // 去群组页面
    toGroupList () {
      let url = '../groups/main'
      wx.navigateTo({url})
    },
    // 点击朋友item, 开始聊天
    startConversation () {
      let url = '../friend/main'
      wx.navigateTo({url})
    },
    // 模态框显示状态
    handleModalShow () {
      this.addModalVisible = !this.addModalVisible
    },
    // 跳转到创建群组页面
    createGroup () {
      let url = '../create/main'
      wx.navigateTo({ url })
    },
    // 加好友
    // handleAdd () {
    //   if (this.addUserId !== '') {
    //     let option = {
    //       userIDList: [this.addUserId]
    //     }
    //     wx.$app.getUserProfile(option).then(res => {
    //       let userProfile = res.data[0]
    //       let options = {
    //         To_Account: userProfile.userID
    //       }
    //       wx.$app.applyAddFriend(options).then(() => {
    //         this.$store.commit('showToast', { title: '发送申请成功' })
    //         this.handleModalShow()
    //       }).catch(() => {
    //         this.$store.commit('showToast', { title: '发送申请失败' })
    //       })
    //     })
    //   }
    // },
    chatTo (item) {
      let conversationID = this.TIM.TYPES.CONV_C2C + item.userID
      wx.$app.getConversationProfile(conversationID).then((res) => {
        this.$store.commit('updateCurrentConversation', res.data.conversation)
        this.$store.state.conversation.currentMessageList = []
        this.$store.dispatch('getMessageList', conversationID)
        this.content = ''
        this.id = ''
        let url = `../chat/main?toAccount=${res.data.conversation.userProfile.nick}`
        wx.navigateTo({ url })
      }).catch(error => {
        console.log(error)
      })
    }
  },
  mounted () {
    // this.initFriendsList()
  }
}
</script>

<style lang='stylus' scoped>
.line
  line-height 60px
.container
  background $background
  width 100%
  height 100%
.input-wrapper
  width 100%
  display flex
  justify-content center
  padding 20px
  box-sizing border-box
.input
    color $regular
    text-align left
    height 32px
    background-color white
    font-size 16px
    line-height 32px
    width 75%
    border-radius 10px
.search-wrapper
  background-color #E7E9EA
  padding 10px 20px
  .search
    width 100%
    box-sizing border-box
    background-color white
    height 30px
    font-size 14px
    line-height 30px
    border-radius 20px
    text-align center
.input
  text-align center
  height 32px
  background-color white
  border-radius 8px
  font-size 16px
.item
  background-color white
.right
  display flex
  flex-direction column
  justify-content space-between
  vertical-align middle
.border-bottom
  border-bottom 1px solid $border-base
.information
  padding 17px 0
.username
  color $base
.last
  color $regular
  font-size 12px
.content
  color $regular
  font-size 12px
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
  width 80%
.remain
  color white
  font-size 12px
  background-color $danger
  border-radius 8px
  padding 2px 8px
.slot
  color $regular
  font-size 12px
  padding-left 10px
.friends
  padding-top 30px
.friend
  background-color white
  margin-bottom -1px
  border-bottom 1px solid $border-light
  border-top 1px solid $border-light
.border
  border 1px solid $border-base
.center
  text-align center
</style>
