import logger from '../../../utils/logger';
// eslint-disable-next-line no-undef
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
        });
      },
    },
    count: {
      type: Number,
      value: '',
      observer(newVal) {
        this.setData({
          memberCount: newVal,
        });
      },
    },
  },
  /**
   * 组件的初始数据
   */
  data: {
    personalProfile: {
    },
    getMemberCount: 30,
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
    showText: '退出群聊',
    showOwner: false,
    noRepateOwner: [],
    showOwnerName: {},
    showGetMore: false,
    offsetNumber: 0,
  },
  lifetimes: {
    attached() {
      this.setData({
        memberCount: this.data.conversation.groupProfile.memberCount,
      });
    },
  },

  /**
   * 组件的方法列表
   */
  methods: {
    // 展示更多群成员
    showMore() {
      wx.$TUIKit.getGroupProfile({
        groupID: this.data.conversation.groupProfile.groupID,
      }).then((imResponse) => {
        this.setData({
          memberCount: imResponse.data.group.memberCount,
        });
        if (imResponse.data.group.memberCount > this.data.getMemberCount) {
          this.setData({
            showGetMore: true,
          });
        }
        if (imResponse.data.group.selfInfo.role === 'Owner') {
          this.setData({
            showText: '解散群聊',
          });
        }
      });
      wx.$TUIKit.getGroupMemberList({
        groupID: this.data.conversation.groupProfile.groupID,
        count: this.data.getMemberCount, offset: 0,
      })
        .then((imResponse) => {
          logger.log(`| TUI-group-profile | getGroupMemberList | getGroupMemberList-length: ${imResponse.data.memberList.length}`);
          if (this.data.conversation.groupProfile.type === 'Private') {
            this.setData({
              addShow: true,
            });
          }
          if (imResponse.data.memberList.length > 3) {
            this.setData({
              showMore: true,
            });
          }
          this.setData({
            groupMemberProfile: imResponse.data.memberList,
            hidden: !this.data.hidden,
            notShow: !this.data.notShow,
            isShow: !this.data.isShow,
          });
        });
    },
    // 拉取更多成员进行展示
    getMoreMember() {
      const offset = this.data.offsetNumber + this.data.getMemberCount;
      this.setData({
        offsetNumber: offset,
      });
      wx.$TUIKit.getGroupMemberList({
        groupID: this.data.conversation.groupProfile.groupID,
        count: this.data.getMemberCount, offset,
      }).then((imResponse) => {
        this.setData({
          groupMemberProfile: this.data.groupMemberProfile.concat(imResponse.data.memberList),
        });
        if (this.data.groupMemberProfile.length === this.data.memberCount) {
          this.setData({
            showGetMore: false,
          });
        }
      });
    },
    // 关闭显示showmore
    showLess() {
      this.setData({
        isShow: false,
        notShow: true,
        hidden: true,
      });
    },
    // 展示更多群成员弹窗
    showMoreMember() {
      this.setData({
        popupToggle: true,
      });
    },
    // 关闭显示弹窗
    close() {
      this.setData({
        popupToggle: false,
        addPopupToggle: false,
        quitPopupToggle: false,
      });
    },
    quitGroup() {
      if (this.data.showText === '退出群聊') {
        this.setData({
          quitPopupToggle: true,
          popupToggle: false,
        });
      } else if (this.data.showText === '解散群聊') {
        this.setData({
          dismissPopupToggle: true,
          popupToggle: false,
        });
      }
    },
    // 解散群聊
    dismissGroupConfirm() {
      wx.$TUIKit.dismissGroup(this.data.conversation.groupProfile.groupID)
        .then(() => {
          wx.navigateBack({
            delta: 1,
          });
        })
        .catch((imError) => {
          wx.showToast({
            title: '群主不能解散好友工作群',
            icon: 'none',
          });
          this.setData({
            dismissPopupToggle: false,
          });
          logger.warn('dismissGroup error:', imError);
        });
    },
    // 解散群聊的按钮提示
    dismissGroupAbandon() {
      this.setData({
        dismissPopupToggle: false,
      });
    },
    // 主动退群
    quitGroupConfirm() {
      wx.$TUIKit.quitGroup(this.data.conversation.groupProfile.groupID)
        .then(() => {
          wx.navigateBack({
            delta: 1,
          });
        })
        .catch((imError) => {
          wx.showToast({
            title: '该群不允许群主主动退出',
            icon: 'none',
          });
          this.setData({
            quitPopupToggle: false,
          });
          logger.warn('quitGroup error:', imError); // 退出群组失败的相关信息
        });
    },
    // 退出群聊的按钮显示
    quitGroupAbandon() {
      this.setData({
        quitPopupToggle: false,
      });
    },
    // 添加群成员按钮显示
    addMember() {
      this.setData({
        addPopupToggle: true,
      });
    },
    // 获取输入的用户ID
    binduserIDInput(e) {
      const id = e.detail.value;
      this.setData({
        userID: id,
      });
    },
    // work群主动添加群成员
    submit() {
      wx.$TUIKit.addGroupMember({
        groupID: this.data.conversation.groupProfile.groupID,
        userIDList: [this.data.userID],
      }).then((imResponse) => {
        if (imResponse.data.successUserIDList.length > 0) {
          wx.showToast({ title: '添加成功', duration: 800 });
          this.userID = '';
          this.addMemberModalVisible = false;
          this.setData({
            addPopupToggle: false,
          });
        }
        if (imResponse.data.existedUserIDList.length > 0) {
          wx.showToast({ title: '该用户已在群中', duration: 800, icon: 'none' });
        }
      })
        .catch((imError) => {
          console.warn('addGroupMember error:', imError); // 错误信息
          wx.showToast({ title: '添加失败，请确保该用户存在', duration: 800, icon: 'none' });
        });
    },
    // 跳转查看群成员资料
    handleJumpPage(e) {
      this.setData({
        personalProfile: e.currentTarget.dataset.value,
      });
      const url =  `/pages/TUI-Group/memberprofile-group/memberprofile?personalProfile=${JSON.stringify(this.data.personalProfile)}`;
      wx.navigateTo({
        url,
      });
    },
    // 实时更新群成员个数
    updateMemberCount(event) {
      if (event === 1) { // 1是有成员加群
        wx.$TUIKit.getGroupMemberList({
          groupID: this.data.conversation.groupProfile.groupID,
          count: this.data.getMemberCount, offset: 0,
        }).then((imResponse) => {
          this.setData({
            groupMemberProfile: imResponse.data.memberList,
            memberCount: this.data.memberCount + 1,
          });
        });
      }
      if (event === 2) { // 2是有成员退群
        wx.$TUIKit.getGroupMemberList({
          groupID: this.data.conversation.groupProfile.groupID,
          count: this.data.getMemberCount, offset: 0,
        }).then((imResponse) => {
          this.setData({
            groupMemberProfile: imResponse.data.memberList,
            memberCount: this.data.memberCount - 1,
          });
        });
      }
    },
    // 复制群ID
    copyGroupID() {
      wx.setClipboardData({
        data: this.data.conversation.groupProfile.groupID,
        success() {
          wx.getClipboardData({
            success(res) {
              logger.log(`| TUI-chat | tui-group | copyGroupID: ${res.data} `);
            },
          });
        },
      });
    },
  },
});
