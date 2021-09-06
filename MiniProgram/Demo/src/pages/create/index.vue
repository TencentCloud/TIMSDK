<template>
  <div class="container">
    <div class="form-item">
      <div class="label">群类型</div>
      <picker :range="range" range-key="name" :value="selectedIndex" @change="choose">
        {{range[selectedIndex].name}}
        <i-icon type="enter" />
      </picker>
    </div>
    <!-- AVChatRoom 必须填写 groupID -->
    <div class="form-item" :class="{'required' : isAVChatRoom}">
      <div class="label">
        群ID
        <i-icon v-if="isAVChatRoom" type="prompt" @click="showInfo"/>
      </div>
      <input v-model="groupID" placeholder="请输入群ID" />
    </div>
    <div class="form-item name required">
      <div class="label">
        群名称
      </div>
      <input v-model="groupName" placeholder="请输入群名称" />
    </div>
    <button :class="{'button-disabled' : disabled}" hover-class="clicked" @click="handleClick" :loading="loading" :disabled="disabled">创建群组</button>
  </div>
</template>

<script>
const defaultData = {
  selectedIndex: 0,
  range: [{
    type: wx.TIM.TYPES.GRP_WORK,
    name: '好友工作群'
  },
  {
    type: wx.TIM.TYPES.GRP_PUBLIC,
    name: '陌生人社交群'
  },
  {
    type: wx.TIM.TYPES.GRP_MEETING,
    name: '临时会议群'
  },
  {
    type: wx.TIM.TYPES.GRP_AVCHATROOM,
    name: '直播群'
  }
  ],
  groupName: '',
  groupID: '',
  loading: false
}
export default {
  data () {
    return {
      ...defaultData
    }
  },
  onUnload () {
    Object.assign(this, defaultData)
  },
  computed: {
    isAVChatRoom () {
      return this.range[this.selectedIndex].type === wx.TIM.TYPES.GRP_AVCHATROOM
    },
    disabled () {
      if (this.groupName === '') {
        return true
      }
      if (this.isAVChatRoom && this.groupID === '') {
        return true
      }
      return false
    }
  },
  methods: {
    choose (event) {
      this.selectedIndex = Number(event.mp.detail.value)
    },
    handleClick () {
      this.loading = true
      wx.$app.createGroup({
        type: this.range[this.selectedIndex].type,
        groupID: this.groupID || undefined,
        name: this.groupName
      }).then(({ data: { group } }) => {
        if (this.isAVChatRoom) {
          return wx.$app.joinGroup({ groupID: group.groupID })
        }
        return Promise.resolve()
      }).then(this.handleResolved)
        .catch(this.handleRejected)
    },
    handleResolved () {
      this.loading = false
      wx.showToast({
        title: '创建成功',
        duration: 1000
      })
      setTimeout(() => {
        wx.navigateBack()
      }, 1000)
    },
    handleRejected (error) {
      this.loading = false
      wx.showToast({
        title: error.message || '创建失败',
        icon: 'none'
      })
    },
    showInfo () {
      wx.showModal({
        title: '提示',
        content: '直播群常用于直播聊天场景，只有在主动加群（需要填写群ID）后才能收到消息，重新登录后需要重新加群。\n故在创建直播群时，必须填写群ID',
        showCancel: false,
        confirmText: '了解'
      })
    }
  }
}
</script>

<style lang="stylus">
.container
  height 100vh
  background-color $background
  .form-item
    display flex
    justify-content space-between
    padding 12px 24px
    background-color $white
    label
      display flex
      align-items center

  .required::before
    content: '*'
    color: $danger
    position absolute
    left 12px
button
  width 80vw
  background-color $primary
  color white
  font-size 16px
  position absolute
  bottom 24px
  left 50%
  margin-left -40vw
.clicked
  background-color $dark-primary
</style>
