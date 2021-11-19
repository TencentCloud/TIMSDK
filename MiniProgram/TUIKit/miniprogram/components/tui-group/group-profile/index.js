import logger from '../../../utils/logger'
Component({
  /**
 * 组件的属性列表
 */
  properties: {
    conversation: {
      type: Object,
      value: '',
      observer(newVal) {
        if (newVal.type === 'GROUP');
        this.setData({
          conversation: newVal,
        })
      },
    },
    count: {
      type: Number,
      value: '',
      observer(newVal) {
        this.setData({
          memberCount: newVal,
        })
      },
    },
  },
  /**
   * 组件的初始数据
   */
  data: {
    personalProfile: {
    },
    count: '',
    userID: '',
    conversation: {},
    memberCount: '',
    groupMemberprofile: {},
    groupMemberAvatar: [],
    groupMemberNick: [],
    hidden: true,
    notShow: true,
    isShow: false,
    showMore: false,
    addShow: false,
    popupToggle: false,
    quitPopupToggle: false,
    addPopupToggle: false,

  },
  lifetimes: {
    attached() {
      this.setData({
        memberCount: this.data.conversation.groupProfile.memberCount,
      })
    },
  },

  /**
   * 组件的方法列表
   */
  methods: {
    // 展示更多群成员
    showMore() {
      wx.$TUIKit.getGroupMemberList({
        groupID: this.data.conversation.groupProfile.groupID,
        count: 50, offset: 0,
      }) // 从0开始拉取30个群成员
        .then((imResponse) => {
          logger.log(`| TUI-group-profile | getGroupMemberList | getGroupMemberList-length: ${imResponse.data.memberList.length}`)
          if (this.data.conversation.groupProfile.type === 'Private') {
            this.setData({
              addShow: true,
            })
          }
          if (imResponse.data.memberList.length > 3) {
            this.setData({
              showMore: true,
            })
          }
          this.setData({
            memberCount: imResponse.data.memberList.length,
            groupMemberProfile: imResponse.data.memberList,
            hidden: !this.data.hidden,
            notShow: !this.data.notShow,
            isShow: !this.data.isShow,

          })
        })
    },
    // 关闭显示showmore
    showLess() {
      this.setData({
        isShow: false,
        notShow: true,
        hidden: true,
      })
    },
    // 展示更多群成员弹窗
    showMoreMember() {
      this.setData({
        popupToggle: true,
      })
    },
    // 关闭显示弹窗
    close() {
      this.setData({
        popupToggle: false,
        addPopupToggle: false,
        quitPopupToggle: false,
      })
    },
    quitGroup() {
      this.setData({
        quitPopupToggle: true,
        popupToggle: false,
      })
    },
    // 主动退群
    quitGroupConfirm() {
      wx.$TUIKit.quitGroup(this.data.conversation.groupProfile.groupID)
        .then(() => {
          wx.navigateBack({
            delta: 1,
          })
        })
        .catch((imError) => {
          wx.showToast({
            title: '该群不允许群主主动退出',
            icon: 'none',
          })
          logger.warn('quitGroup error:', imError) // 退出群组失败的相关信息
        })
    },
    // 退出群聊的按钮显示
    quitGroupAbandon() {
      this.setData({
        quitPopupToggle: false,
      })
    },
    // 添加群成员按钮显示
    addMember() {
      this.setData({
        addPopupToggle: true,
      })
    },
    // 获取输入的用户ID
    binduserIDInput(e) {
      const id = e.detail.value
      this.setData({
        userID: id,
      })
    },
    // work群主动添加群成员
    submit() {
      wx.$TUIKit.addGroupMember({
        groupID: this.data.conversation.groupProfile.groupID,
        userIDList: [this.data.userID],
      }).then((imResponse) => {
        if (imResponse.data.successUserIDList.length > 0) {
          wx.showToast({ title: '添加成功', duration: 800 })
          this.userID = ''
          this.addMemberModalVisible = false
          this.setData({
            addPopupToggle: false,
          })
        }
        if (imResponse.data.existedUserIDList.length > 0) {
          wx.showToast({ title: '该用户已在群中', duration: 800, icon: 'none' })
        }
      })
        .catch((imError) => {
          console.warn('addGroupMember error:', imError) // 错误信息
          wx.showToast({ title: '添加失败，请确保该用户存在', duration: 800, icon: 'none' })
        })
    },
    // 跳转查看群成员资料
    handleJumpPage(e) {
      this.setData({
        personalProfile: e.currentTarget.dataset.value,
      })
      const url =  `/pages/TUI-Group/memberprofile-group/memberprofile?personalProfile=${JSON.stringify(this.data.personalProfile)}`
      wx.navigateTo({
        url,
      })
    },
    // 实时更新群成员个数
    updateMemberCount(event) {
      if (event === 1) {
        this.setData({
          memberCount: this.data.memberCount + 1,
        })
      }
      if (event === 2) {
        this.setData({
          memberCount: this.data.memberCount - 1,
        })
      }
    },
  },
})
