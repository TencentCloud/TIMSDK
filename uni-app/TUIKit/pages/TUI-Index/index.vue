<template>
<view class="container">
  <image class="background-image" src="/static/static/assets/background.svg"></image>
  <view class="counter-warp">
    <view class="counter-main">
      <view class="header-content">
        <image src="/static/static/images/im.png" class="icon"></image>
        <view class="text">
          <view class="text-header">登录 · 即时通信</view>
          <view class="text-content">体验群组聊天，视频对话等IM功能</view>
        </view>
      </view>
      <view class="tui-scene-router">
        <view v-for="(item, index) in sceneList" :key="index" class="scene-item-card" :data-item="item" @tap="handleOnPageNavigate">
          <image class="tui-scene-icon" :src="item.iconUrl"></image>
          <view class="tui-scene-name">{{item.name}}</view>
          <image class="tui-scene-link" src="/static/static/assets/detail.svg"></image>
        </view>
      </view>
    </view>
    <view class="foot" @tap="learnMore">了解更多 IM 功能</view>
  </view>

</view>
</template>

<script>
// miniprogram/pages/TUI-Index/TUI-create.js
import logger from '../../utils/logger';
const app = getApp();

export default {
  data() {
    return {
      sceneList: [{
        name: '在线客服',
        url: '../TUI-Conversation/conversation/conversation',
        iconUrl: "/static/static/assets/online-service.svg"
      }]
    };
  },

  components: {},
  props: {},

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {},

  onShow() {
    logger.log(`| TUI-Index | onshow  | login|userSig:${app.globalData.userInfo.userSig} userID:${app.globalData.userInfo.userID}`);
  },

  methods: {
    handleOnPageNavigate(event) {
      const tab = event.currentTarget.dataset.item;

      if (!tab.url) {
        uni.navigateToMiniProgram({
          appId: 'wx3b91b7aaa809ecf9'
        });
      } else {
        uni.navigateTo({
          url: tab.url
        });
      }
    },

    learnMore() {
      uni.navigateTo({
        url: '../TUI-User-Center/webview/webview?url=https://cloud.tencent.com/product/im'
      });
    }

  }
};
</script>
<style>
@import "./index.css";
</style>
