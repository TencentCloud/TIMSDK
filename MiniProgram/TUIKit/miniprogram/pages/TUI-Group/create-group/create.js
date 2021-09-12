// miniprogram/pages/TUI-Group/create-group/create.js
import logger from '../../../utils/logger'

Page({

  /**
   * 页面的初始数据
   */
  data: {
    groupTypeList: [
      { groupType: '品牌客户群（Work)', Type: wx.$TUIKitTIM.TYPES.GRP_WORK },
      { groupType: 'VIP专属群（Public)', Type: wx.$TUIKitTIM.TYPES.GRP_PUBLIC },
      { groupType: '临时会议群 (Meeting)', Type: wx.$TUIKitTIM.TYPES.GRP_MEETING },
      { groupType: '直播群（AVChatRoom）', Type: wx.$TUIKitTIM.TYPES.GRP_AVCHATROOM },
    ],
    groupType: '',
    Type: '',
    name: '',
    groupID: '',


  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {

  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady() {

  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow() {

  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide() {

  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload() {

  },

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh() {

  },

  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom() {

  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage() {

  },
  showtype() {
    this.setData({
      popupToggle: true,
    })
  },
  bindgroupIDInput(e) {
    const id = e.detail.value
    this.setData({
      groupID: id,
    })
  },
  bindgroupnameInput(e) {
    const groupname = e.detail.value
    this.setData({
      name: groupname,
    })
  },
  click(e) {
    this.setData({
      groupType: e.currentTarget.dataset.value.groupType,
      Type: e.currentTarget.dataset.value.Type,
      name: e.currentTarget.dataset.value.name,
      popupToggle: false,
    })
  },

  bindConfirmCreate() {
    logger.log(`TUI-Group | create-group | bindConfirmCreate | groupID: ${this.data.groupID}`)
    const promise =  wx.$TUIKit.createGroup({
      type: this.data.Type,
      name: this.data.name,
      groupID: this.data.groupID,
    })
    promise.then((imResponse) => { // 创建成功
      // 创建的群的资料
      const { groupID } = imResponse.data.group
      wx.navigateTo({
        url: `../../TUI-Chat/chat?conversationID=GROUP${groupID}`,
      })
    }).catch(() => {
      wx.showToast({
        title: '该群组ID被使用，请更换群ID',
        icon: 'none',
      })
    })
  },
  handleChooseToggle() {
    this.setData({
      popupToggle: false,
    })
  },
})
