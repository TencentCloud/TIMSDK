<template>
  <div class="container">
    <i-modal title="添加的用户ID" :visible="addModalVisible" @ok="handleAdd" @cancel="handleModalShow">
      <div class="input-wrapper">
        <input type="text" class="input border center" v-model.lazy:value="addUserId"/>
      </div>
    </i-modal>
    <div class="title">基础信息</div>
    <div class="item">
      <div class="label">
        群ID：
      </div>
      <div>
        <input type="text" class="input" placeholder="请输入群ID" v-model.lazy:value="id"/>
      </div>
    </div>
    <div class="item">
      <div class="label">
        群名：
      </div>
      <div>
        <input type="text" class="input" placeholder="请输入群名" v-model.lazy:value="name"/>
      </div>
    </div>
    <div class="item">
      <div class="label">
        群头像：
      </div>
      <div>
        <input type="text" class="input" placeholder="请输入群头像" v-model.lazy:value="avatar"/>
      </div>
    </div>
    <div class="item">
      <div class="label">
        群简介：
      </div>
      <div>
        <input type="text" class="input" placeholder="请输入群简介" v-model.lazy:value="introduction"/>
      </div>
    </div>
    <div class="item">
      <div class="label">
        群公告：
      </div>
      <div>
        <input type="text" class="input" placeholder="请输入群公告" v-model.lazy:value="notice"/>
      </div>
    </div>
    <div class="type">
      <div class="title">
        群类型：
      </div>
      <div class="choose">
        <i-radio-group :current="currentType" @change="handleTypeChange">
          <i-radio value="Private"></i-radio>
          <i-radio value="Public"></i-radio>
          <i-radio value="ChatRoom"></i-radio>
          <i-radio value="AVChatRoom"></i-radio>
        </i-radio-group>
      </div>
    </div>
    <div class="type" v-if="currentType !== 'Private' && currentType !== 'AVChatRoom'">
      <div class="title">
        加群方式：
      </div>
      <div class="choose" >
        <i-radio-group :current="addType" @change="handleAddTypeChange">
          <i-radio value="自由加群"></i-radio>
          <i-radio value="需要验证"></i-radio>
          <i-radio value="禁止加群"></i-radio>
        </i-radio-group>
      </div>
    </div>
    <div class="type">
      <div class="title">
        群成员列表<span @click="handleModalShow" class="adding">添加成员</span>
      </div>
    </div>
    <div class="temp" v-if="memberList.length === 0">
    </div>
    <div class="item" v-for="item in memberList" :key="item.userID">
      <div class="add-label">
        {{item.nick || '无昵称'}}
      </div>
      <div class="add-label">
        {{item.userID}}
      </div>
      <div class="delete" @click="deleteMember(item)">
        <i-avatar src="../../../static/images/delete.png" />
      </div>
    </div>
    <i-row>
      <i-col span="24">
        <button type="button" class="button success" @click="createGroup">确定创建</button>
        <button type="button" class="button fail" @click="empty">清空</button>
      </i-col>
    </i-row>
  </div>
</div>
</template>

<script>
export default {
  data () {
    return {
      id: '',
      name: '',
      content: '',
      currentType: this.$type.GRP_PRIVATE,
      avatar: '',
      introduction: '',
      notice: '',
      addType: '自由加群',
      memberList: [],
      addModalVisible: false,
      addUserId: ''
    }
  },
  computed: {
    username () {
      return this.$store.state.user.userProfile.to
    }
  },
  methods: {
    // 创建群组
    createGroup () {
      if (this.name) {
        let list = this.memberList.map(userID => { return { userID: userID.userID } })
        let adding
        switch (this.addType) {
          case '自由加群':
            adding = this.$type.JOIN_OPTIONS_FREE_ACCESS
            break
          case '禁止加群':
            adding = this.$type.JOIN_OPTIONS_DISABLE_APPLY
            break
          case '需要验证':
            adding = this.$type.JOIN_OPTIONS_NEED_PERMISSION
            break
        }
        let options
        if (this.currentType !== this.TIM.TYPES.GRP_PRIVATE && this.currentType !== this.TIM.TYPES.GRP_AVCHATROOM) {
          adding = (this.currentType === this.TIM.TYPES.GRP_AVCHATROOM) ? this.$type.JOIN_OPTIONS_FREE_ACCESS : adding
          options = {
            groupID: this.id,
            name: this.name,
            type: this.currentType,
            avatar: this.avatar,
            introduction: this.introduction,
            notification: this.notice,
            joinOption: adding,
            memberList: list
          }
        } else {
          options = {
            groupID: this.id,
            name: this.name,
            type: this.currentType,
            avatar: this.avatar,
            introduction: this.introduction,
            notification: this.notice,
            memberList: list
          }
        }
        wx.$app.createGroup(options).then(() => {
          this.$store.commit('showToast', {
            title: '创建成功',
            icon: 'success',
            duration: 1500
          })
          this.empty()
          wx.switchTab({
            url: '../index/main'
          })
        }).catch((err) => {
          console.log(err)
        })
      } else {
        this.$store.commit('showToast', {
          title: '请输入群名'
        })
      }
    },
    handleTypeChange (e) {
      this.currentType = e.target.value
    },
    handleAddTypeChange (e) {
      this.addType = e.target.value
    },
    // 添加群成员modal
    handleModalShow () {
      this.addModalVisible = !this.addModalVisible
    },
    // 添加群成员
    handleAdd () {
      if (this.addUserId) {
        wx.$app
          .getUserProfile({
            userIDList: [this.addUserId]
          }).then(res => {
            this.addUserId = ''
            if (res.data.length > 0) {
              this.handleModalShow()
              this.memberList.push(res.data[0])
              this.$store.commit('showToast', {
                title: '添加成功',
                icon: 'none',
                duration: 1500
              })
            } else {
              this.$store.commit('showToast', {
                title: '没有找到该用户',
                icon: 'none',
                duration: 1500
              })
            }
          }).catch(() => {
            this.$store.commit('showToast', {
              title: '没有找到该用户',
              icon: 'none',
              duration: 1500
            })
          })
      } else {
        this.$store.commit('showToast', {
          title: 'ID不能为空'
        })
      }
    },
    // 删除成员
    deleteMember (item) {
      this.memberList = this.memberList.filter(member => member.userID !== item.userID)
    },
    // 清空所有的信息
    empty () {
      this.id = ''
      this.name = ''
      this.currentType = ''
      this.avatar = ''
      this.introduction = ''
      this.notice = ''
      this.addType = ''
      this.memberList = []
      this.addModalVisible = false
    }
  }
}
</script>

<style lang='stylus' scoped>
.temp
  height 20px
  border 1px solid $border-light
  background-color white
  width 100%
.input-wrapper
  width 100%
  display flex
  justify-content center
  padding 20px
  box-sizing border-box
.title
  color $regular
  font-size 12px
  padding 0 0 4px 10px
.add
  color white
  background-color $success
  border-radius 12px
  height 30px
  width 120px
  line-height 30px
  font-size 14px
.container
  min-height 100vh
  padding 20px 0
  box-sizing border-box
  background-color $background
.item
  height 40px
  display flex
  background-color white
  font-size 14px
  padding 3px 10px
  vertical-align middle
  box-sizing border-box
  border 1px solid $border-light
  margin-bottom -1px
  .label
    line-height 32px
    color $regular
    width 25%
  .add-label
    line-height 32px
    color $regular
    width 40%
.input
  color $regular
  text-align left
  height 32px
  background-color white
  font-size 16px
  line-height 32px
  width 75%
  border-radius 10px
.type
  padding-top 20px
  .adding
    font-size 12px
    color $primary
    padding-left 10px
.start
  color white
  background-color $primary
  border-radius 8px
  height 50px
  width 200px
  line-height 50px
  font-size 16px
.card
  border-bottom 1px solid $border-light
.avatar
  padding 10px
.right
  box-sizing border-box
  height 100px
  padding 10px
  display flex
  flex-direction column
  justify-content space-around
.username
  font-weight 600
  font-size 18px
  color $base
.account
  font-size 14px
  color $secondary
.button
  color white
  border-radius 12px
  height 40px
  width 200px
  line-height 40px
  font-size 16px
  margin-top 20px
.success
  background-color $success
.fail
  background-color $danger
.border
  border 1px solid $border-base
.center
  text-align center
</style>
