// miniprogram/pages/TUI-Group/create-group/create.js
import logger from '../../../utils/logger';

// eslint-disable-next-line no-undef
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

  // 展示群列表
  showGroupTypeList() {
    this.setData({
      popupToggle: true,
    });
  },
  // 获取输入的群ID
  bindGroupIDInput(e) {
    const id = e.detail.value;
    this.setData({
      groupID: id,
    });
  },
  // 获取输入的群名称
  bindGroupNameInput(e) {
    const groupname = e.detail.value;
    this.setData({
      name: groupname,
    });
  },
  // 创建群聊时，传点击事件对应的值
  click(e) {
    this.setData({
      groupType: e.currentTarget.dataset.value.groupType,
      Type: e.currentTarget.dataset.value.Type,
      name: e.currentTarget.dataset.value.name,
      popupToggle: false,
    });
  },
  // 确认创建群聊
  bindConfirmCreate() {
    logger.log(`| TUI-Group | create-group | bindConfirmCreate | groupID: ${this.data.groupID}`);
    const promise =  wx.$TUIKit.createGroup({
      type: this.data.Type,
      name: this.data.name,
      groupID: this.data.groupID,
    });
    promise.then((imResponse) => { // 创建成功
      // 创建的群的资料
      const payloadData = {
        conversationID: `GROUP${imResponse.data.group.groupID}`,
      };
      wx.navigateTo({
        url: `../../TUI-Chat/chat?conversationInfomation=${JSON.stringify(payloadData)}`,
      });
    }).catch(() => {
      wx.showToast({
        title: '该群组ID被使用，请更换群ID',
        icon: 'none',
      });
    });
  },
  // 点击空白区域关闭弹窗
  handleChooseToggle() {
    this.setData({
      popupToggle: false,
    });
  },
});
