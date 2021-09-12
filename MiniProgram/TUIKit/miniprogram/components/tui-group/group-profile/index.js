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
  },
  /**
   * 组件的初始数据
   */
  data: {
    userID: '',
    conversation: {},
    newgroup: {},
    groupmemberprofile: {},
    groupmemberavatar: [],
    groupmembernick: [],
    hidden: true,
    notShow: true,
    isShow: false,
    Showmore: false,
    addShow: false,
    popupToggle: false,
    quitpopupToggle: false,
    addpopupToggle: false,

  },
  lifetimes: {
    attached() {
    },
  },

  /**
   * 组件的方法列表
   */
  methods: {
    showmore() {
      wx.$TUIKit.getGroupMemberList({
        groupID: this.data.conversation.groupProfile.groupID,
        count: 50, offset: 0,
      }) // 从0开始拉取30个群成员
        .then((imResponse) => {
          logger.log(`| TUI-group-profile | getGroupMemberList  | getGroupMemberList-length: ${imResponse.data.memberList.length}`)
          if (this.data.conversation.groupProfile.type === 'Private') {
            this.setData({
              addShow: true,
            })
          }
          if (imResponse.data.memberList.length > 3) {
            this.setData({
              Showmore: true,
            })
          }
          this.setData({
            groupmemberprofile: imResponse.data.memberList,
            hidden: !this.data.hidden,
            notShow: !this.data.notShow,
            isShow: !this.data.isShow,

          })
        })
    },
    showless() {
      this.setData({
        isShow: false,
        notShow: true,
        hidden: true,
      })
    },
    showmoreMember() {
      this.setData({
        popupToggle: true,
        //  quitpopupToggle: false
      })
    },
    close() {
      this.setData({
        popupToggle: false,
        addpopupToggle: false,
        quitpopupToggle: false,
      })
    },
    quitGroup() {
      this.setData({
        quitpopupToggle: true,
        popupToggle: false,
      })
    },
    quitgroupConfirm() {
      wx.$TUIKit.quitGroup(this.data.conversation.groupProfile.groupID)
        .then((imResponse) => {
          console.log(imResponse.data.groupID) // 退出成功的群 ID
          wx.navigateBack({
            delta: 1,
          })
        })
        .catch((imError) => {
          wx.showToast({
            title: '该群不允许群主主动退出',
            icon: 'none',
          })
          console.warn('quitGroup error:', imError) // 退出群组失败的相关信息
        })
    },
    quitgroupAbandon() {
      console.log(22222)
      this.setData({
        quitpopupToggle: false,
      })
    },
    addMember() {
      this.setData({
        addpopupToggle: true,
      })
    },
    binduserIDInput(e) {
      const id = e.detail.value
      this.setData({
        userID: id,
      })
    },
    submit() {
      console.log(this.data.userID)
      wx.$TUIKit.addGroupMember({
        groupID: this.data.conversation.groupProfile.groupID,
        userIDList: [this.data.userID],
      }).then((imResponse) => {
        if (imResponse.data.successUserIDList.length > 0) {
          wx.showToast({ title: '添加成功', duration: 800 })
          this.userID = ''
          this.addMemberModalVisible = false
          this.setData({
            addpopupToggle: false,
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
  },


})
