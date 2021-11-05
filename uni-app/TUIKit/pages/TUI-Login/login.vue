<template>
<view class="container">
  <image class="background-image" src="/static/static/assets/background.svg"></image>
  <view class="counter-warp">
    <view class="header-content">
      <image src="/static/static/images/im.png" class="icon"></image>
      <view class="text">
        <view class="text-header">登录 · 即时通信</view>
        <view class="text-content">体验群组聊天，视频对话等IM功能</view>
      </view>
    </view>
    <view class="box">
      <view class="list">
        <view class="list-item">
          <label class="list-item-label">用户ID</label>
		  <input class="input" type="text" placeholder="请输入用户名" @input='bindUserIDInput' placeholder-style="color:#BBBBBB;"/>
        </view>
      </view>
      <view class="private-protocol-box">
          <view class="private-protocol-switch" @tap="onAgreePrivateProtocol">
            <image v-if="privateAgree" src="/static/static/images/selected.png" lazy-load="true"></image>
            <image v-else src="/static/static/images/select.png" lazy-load="true"></image>
          </view>
          <view class="text-box"><text>我已阅读并同意</text><text class="link" @tap="linkToPrivacyTreaty">《隐私条例》</text><text>和</text><text class="link" @tap="linkToUserAgreement">《用户协议》</text>
          </view>
      </view>
      <view class="login">
            <button class="loginBtn" :disabled="!privateAgree" @tap="login">登录</button>
      </view>
    </view>
  </view>
</view>
</template>

<script>
import { setTokenStorage } from '../../utils/token';
import logger from '../../utils/logger';
import { genTestUserSig } from '../../debug/GenerateTestUserSig.js'
const {
  getTokenStorage
} = require("../../utils/token.js");
const app = getApp();

export default {
  data() {
    return {
      userID: '',
      hidden: false,
      btnValue: '获取验证码',
      btnDisabled: false,
      privateAgree: false,
      phone: '',
      code: '',
      sessionID: '',
      second: 60,
      path: '',
      lastTime: 0,
      countryIndicatorStatus: false,
      country: '86',
      indicatorValue: 46,
      headerHeight: app.globalData.headerHeight,
      statusBarHeight: app.globalData.statusBarHeight,
      showlogin: false
    };
  },

  components: {},
  props: {},

  onLoad(option) {
    const that = this;
    this.setData({
      path: option.path
    });
    uni.getStorage({
      // 获取本地缓存
      key: 'sessionID',

      success(res) {
        that.setData({
          sessionID: res.data
        });
      }

    });
    uni.setStorage({
      key: 'path',
      data: option.path
    });
  },

  onShow() {

  },

  methods: {
    loginWithToken() {
      uni.switchTab({
        url: '../TUI-Index/index'
      });
    },

    onBack() {
      uni.navigateTo({
        url: '../TUI-Index/TUI-Index'
      });
    },

    // 手机号输入
    bindPhoneInput(e) {
      const val = e.detail.value;
      this.setData({
        // 不加 86 会导致接口校验错误, 有国际化需求的时候这里要改动下
        phone: `86${val}`
      });

      if (val !== '') {
        this.setData({
          hidden: false,
          btnValue: '获取验证码'
        });
      }
    },
  // 输入userID
  bindUserIDInput(e) {
	const val = e.detail.value
	this.setData({
	  userID: val,
	})
  },
    // 验证码输入
    bindCodeInput(e) {
      this.setData({
        code: e.detail.value
      });
    },

    onAgreePrivateProtocol() {
      this.setData({
        privateAgree: !this.privateAgree
      });
    },

    linkToPrivacyTreaty() {
      const url = 'https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html';
      uni.navigateTo({
        url: `../TUI-User-Center/webview/webview?url=${url}&nav=Privacy-Protection`
      });
    },

    linkToUserAgreement() {
      const url = 'https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html';
      uni.navigateTo({
        url: `../TUI-User-Center/webview/webview?url=${url}&nav=User-Agreement`
      });
    },

    // 获取验证码
    handlerVerify(ev) {
      if (ev.detail.ret === 0) {
        const ticket = `${ev.detail.ticket}`;
        const phone = `${this.phone}`;
        uni.request({
          url: 'https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/smsImg',
          method: 'POST',
          data: {
            phone,
            ticket,
            type: 'wxmini'
          },
          header: {
            'content-type': 'application/x-www-form-urlencoded'
          },
          success: res => {
            logger.log('TUIKit | TUI-login | handlerVerify  | ok');
            const data = res.data.data.sessionId;

            switch (res.data.errorCode) {
              case 0:
                this.timer();
                uni.setStorage({
                  key: 'sessionID',
                  data
                });
                this.setData({
                  sessionID: data
                });
                uni.showToast({
                  title: '验证码已发送',
                  icon: 'success',
                  duration: 1000,
                  mask: true
                });
                break;

              case -1001:
              case -1002:
                uni.showToast({
                  title: '请输入正确的手机号',
                  icon: 'none',
                  duration: 1000,
                  mask: true
                });
                break;

              case -1003:
                uni.showToast({
                  title: '验证码发送失败',
                  icon: 'none',
                  duration: 1000,
                  mask: true
                });
                break;

              default:
                break;
            }

            this.lastTime = new Date().getTime();
          },
          fail: () => {
            uni.showToast({
              title: '发送验证码失败',
              icon: 'none',
              duration: 1000
            });
          }
        });
      }
    },

    getCode() {
      const now = new Date();
      const nowTime = now.getTime();

      if (this.phone !== '') {
        if (nowTime - this.lastTime > 10000) {
          this.selectComponent('#captcha').show();
        }
      } else {
        uni.showToast({
          title: '请输入手机号'
        });
      }
    },

    // 计时器
    timer() {
      const promise = new Promise(resolve => {
        const setTimer = setInterval(() => {
          const second = this.second - 1;
          this.setData({
            second,
            btnValue: `${second}s`,
            btnDisabled: true
          });

          if (this.second <= 0) {
            this.setData({
              second: 60,
              btnValue: '获取验证码',
              btnDisabled: false
            });
            resolve(setTimer);
          }
        }, 1000);
      });
      promise.then(setTimer => {
        clearInterval(setTimer);
      });
    },

    login() {
		console.log(this.userID, 'login')
	  const userID = this.userID
	  const userSig = genTestUserSig(userID).userSig
	  logger.log(`TUI-login | login  | userSig:${userSig} userID:${userID}`)
	  app.globalData.userInfo = {
		userSig,
		userID,
	  }
	  setTokenStorage({
		userInfo: app.globalData.userInfo,
	  })
	  if (this.path && this.path !== 'undefined') {
		uni.redirectTo({
		  url: this.path,
		})
	  } else {
		uni.switchTab({
		  url: '../TUI-Index/index',
		})
	  }
    },

    // 国家区号选择组件开关
    onToggleCountryIndicator() {
      this.setData({
        countryIndicatorStatus: true
      });
    },

    onCountryIndicatorClose(event) {
      this.setData({
        countryIndicatorStatus: event.detail.status
      });
    },

    // 国家区号确定选择
    handleIndicator(event) {
      this.setData({
        country: event.detail.country,
        indicatorValue: event.detail.indicatorValue
      });
    }

  }
};
</script>
<style scoped>
@import "./login.css";
</style>
