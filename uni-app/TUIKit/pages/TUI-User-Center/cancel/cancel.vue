<template>
<view>
<!--miniprogram/pages/cancelaton/cancel.wxml-->
<view class="container">
    <view class="main">
        <image class="image" src="/static/static/images/cancellation.png"></image>
        <text selectable="false" space="false" decode="false">
            注销后，您将无法使用当前账号，相关数据也将删除无法找回。当前账户：{{userInfo.userID}}
        </text>
      <view class="cancellation" @tap="handleCancellation">
          <view class="confirm-cancellation">确认注销</view>
      </view>
    </view>
  </view>
<view class="mask" v-if="toggle" @tap.stop="close">
    <view class="popup">
        <view class="popup-main">
            <text>确定要注销账户吗?</text>
        </view>
        <view class="popup-footer">
           <button class="submit" @tap.stop="submit">注销</button>
            <button class="cancel" @tap.stop="close">取消</button>

        </view>
    </view>
</view>
</view>
</template>

<script>
// miniprogram/pages/cancelaton/cancel.js
import { cancellation } from '../../../utils/api';
import logger from '../../../utils/logger';
const app = getApp();

export default {
  data() {
    return {
      userInfo: {},
      phone: '',
      toggle: false
    };
  },

  components: {},
  props: {},

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    this.setData({
      userInfo: app.globalData.userProfile,
      phone: app.globalData.userInfo.phone
    });
    uni.setNavigationBarTitle({
      title: '注销账户'
    });
  },

  methods: {
    handleCancellation() {
      this.setData({
        toggle: true
      });
    },

    close() {
      this.setData({
        toggle: false
      });
    },

    submit() {
      logger.log('| TUI-User-Center | cancel  | logout-cancellation');
      uni.$TUIKit.logout().then(() => {
        cancellation({}, res => {
          logger.log('| TUI-User-Center | cancel  | cancellation |ok');

          if (res.data.errorCode === 0) {
            uni.getStorage({
              key: 'path',
              complete: () => {
                uni.clearStorage();
                app.globalData.resetLoginData();
                uni.redirectTo({
                  url: '../../TUI-Login/login',
                  success: () => {
                    uni.showToast({
                      title: ' 注销成功',
                      icon: 'none'
                    });
                  }
                });
                this.close();
              }
            });
          }
        });
      });
    }

  }
};
</script>
<style>
@import "./cancel.css";
</style>
