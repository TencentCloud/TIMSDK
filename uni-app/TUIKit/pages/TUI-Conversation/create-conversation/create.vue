<template>
<view class="TUI-Create-conversation-container">
  <view class="tui-navigatorbar">
    <image class="tui-navigatorbar-back" @tap="goBack" src="/static/static/assets/ic_back_white.svg"></image>
    <view class="conversation-title">发起会话</view>
  </view>
  <view class="tui-search-area">
    <view class="tui-search-bar">
      <image class="tui-searchcion" src="/static/static/assets/serach-icon.svg"></image>
      <input class="tui-search-bar-input" :value="userID" placeholder="请输入用户ID" @input="userIDInput" @confirm="getuserProfile" @blur="getuserProfile">

    </view>
    <view class="tui-showID">您的用户ID  {{userInfo.userID}}</view>
  </view>
  <view class="tui-person-to-invite" v-if="searchUser.userID">
    <image @click="handleChoose" class="tui-normal-choose" :src="isChoose ? '/static/static/assets/single-choice-hover.svg' : '/static/static/assets/single-choice-normal.svg'"></image>
    <view class="tui-person-profile">
      <image class="tui-person-profile-avatar" :src="searchUser.avatar || 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/avatar_21.png'"></image>
      <view>
        <view class="tui-person-profile-nick">{{searchUser.nick}}</view>
        <view class="tui-person-profile-userID">用户ID：{{searchUser.userID}}</view>
      </view>
    </view>
  </view>
  <view class="tui-confirm-btn" @tap="bindConfirmInvite">确认邀请</view>
</view>
</template>

<script>
const app = getApp();

export default {
  data() {
    return {
      userID: '',
      searchUser: {},
      isChoose: false,
      userInfo: {}
    };
  },

  components: {},
  props: {},

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    this.setData({
      userInfo: app.globalData.userInfo
    });
  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady() {},

  /**
   * 生命周期函数--监听页面显示
   */
  onShow() {},

  methods: {
    goBack() {
      uni.navigateBack({
        delta: 1
      });
    },

    userIDInput(e) {
      this.setData({
        userID: e.detail.value,
        searchUser: {}
      });
    },

    getuserProfile() {
      uni.$TUIKit.getUserProfile({
        userIDList: [this.userID]
      }).then(imRes => {
        if (imRes.data.length > 0) {
          this.setData({
            searchUser: imRes.data[0]
          });
        } else {
          uni.showToast({
            title: '用户不存在',
            icon: 'error'
          });
          this.setData({
            userID: ''
          });
        }
      });
    },

    handleChoose() {
      this.isChoose = !this.isChoose;
      this.setData({
        searchUser: this.searchUser
      });
    },

    bindConfirmInvite() {
      if (this.isChoose) {
        uni.navigateTo({
          url: `../../TUI-Chat/chat?conversationID=C2C${this.searchUser.userID}`
        });
      } else {
        uni.showToast({
          title: '请选择相关用户',
          icon: 'none'
        });
      }
    }

  }
};
</script>
<style>
@import "./create.css";
</style>
