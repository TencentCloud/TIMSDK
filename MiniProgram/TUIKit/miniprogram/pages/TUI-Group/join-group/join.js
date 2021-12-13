import logger from '../../../utils/logger';

// eslint-disable-next-line no-undef
Page({

  /**
   * 页面的初始数据
   */
  data: {
    groupID: '',
    searchGroup: {},
  },

  // 回退
  goBack() {
    wx.navigateBack({
      delta: 1,
    });
  },
  // 获取输入的群ID
  getGroupIDInput(e) {
    this.setData({
      groupID: e.detail.value,
    });
  },
  // 通过输入的群ID来查找群
  searchGroupByID() {
    wx.$TUIKit.searchGroupByID(this.data.groupID)
      .then((imResponse) => {
        if (imResponse.data.group.groupID !== '') {
          this.setData({
            searchGroup: imResponse.data.group,
          });
        }
      })
      .catch((imError) => {
        wx.hideLoading();
        if (imError.code === 10007) {
          wx.showToast({
            title: '讨论组类型群不允许申请加群',
            icon: 'none',
          });
        } else {
          wx.showToast({
            title: '未找到该群组',
            icon: 'none',
          });
        }
      });
  },
  // 选择查找到的群
  handleChoose() {
    this.data.searchGroup.isChoose = !this.data.searchGroup.isChoose;
    this.setData({
      searchGroup: this.data.searchGroup,
    });
  },
  // 确认加入
  bindConfirmJoin() {
    logger.log(`| TUI-Group | join-group | bindConfirmJoin | groupID: ${this.data.groupID}`);
    wx.$TUIKit.joinGroup({ groupID: this.data.groupID, type: this.data.searchGroup.type })
      .then((imResponse) => {
        if (this.data.searchGroup.isChoose) {
          if (imResponse.data.status === 'WaitAdminApproval') {
            wx.showToast({
              title: '等待管理员同意',
              icon: 'none',
            });
          } else {
            const payloadData = {
              conversationID: `GROUP${this.data.searchGroup.groupID}`,
            };
            wx.navigateTo({
              url: `../../TUI-Chat/chat?conversationInfomation=${JSON.stringify(payloadData)}`,
            });
          }
        } else {
          wx.showToast({
            title: '请选择相关群聊',
            icon: 'error',
          });
        }
        switch (imResponse.data.status) {
          case wx.$TUIKitTIM.TYPES.JOIN_STATUS_WAIT_APPROVAL:
            // 等待管理员同意
            break;
          case wx.$TUIKitTIM.TYPES.JOIN_STATUS_SUCCESS: // 加群成功
            break;
          case wx.$TUIKitTIM.TYPES.JOIN_STATUS_ALREADY_IN_GROUP: // 已经在群中
            break;
          default:
            break;
        }
      })
      .catch((imError) => {
        console.warn('joinGroup error:', imError); // 申请加群失败的相关信息
      });
  },
});
