<template>
  <view class="container">
    <view class="container" v-show="showLogin">
      <image class="background-image" src="../../static/background.svg"></image>
      <view class="counter-warp">
        <view class="header-content">
          <image src="../../static/calling-logo.png" class="icon-box" />
          <view class="text-header">腾讯云音视频插件</view>
        </view>
        <view class="box">
          <view class="list-item">
            <label class="list-item-label">用户ID</label>
            <input class="input-box" type="text" v-model="userID" placeholder="请输入用户ID"
              placeholder-style="color:#BBBBBB;" />
          </view>
          <view class="login"><button class="loginBtn" @click="loginHandler">登录</button></view>
        </view>
      </view>
    </view>
    <view class="container" v-show="!showLogin">
      <view class="input-container">
        <label class="list-item-label" style="margin-bottom: 10px;">
          呼叫用户ID:
          <span style="color:#C0C0C0;margin-left: 8px;">user1;user2(“;”为英文分号)</span>
        </label>
        <input class="input-box" v-model="callUserID" maxlength="140" type="text" placeholder="输入userID"
          placeholder-style="color:#BBBBBB;" />
      </view>
      <view class="guide-box">
        <view class="single-box" :id="index" @click="callingHandle(item.type)" v-for="(item, index) in entryInfos"
          :key="index">
          <image class="icon" mode="aspectFit" :src="item.icon" role="img"></image>

          <view class="single-content">
            <view class="label">{{ item.title }}</view>
            <view class="desc">{{ item.desc }}</view>
          </view>
        </view>
      </view>
      <view class="login" style="width: 70%; margin: 0 auto 0;"><button class="loginBtn"
          @click="logoutHandler">登出</button></view>
      <view style="width: 70%; margin: 15px auto 0;" @click="setNickHandler">设置昵称</view>
      <view style="width: 70%; margin: 15px auto 0;" @click="setUserAvatarHandler">设置头像</view>
      <view style="width: 70%; margin: 15px auto 0;" @click="setCallingBellHandler">设置铃声</view>
    </view>
  </view>
</template>
<script>
import {
  genTestUserSig
} from '../../debug/GenerateTestUserSig.js';

export default {
  data() {
    return {
      entryInfos: [{
        icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/audio-card.png',
        title: '语音通话',
        desc: '丢包率70%仍可正常语音通话',
        type: 1
      },
      {
        icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/video-card.png',
        title: '视频通话',
        desc: '丢包率50%仍可正常视频通话',
        type: 2
      }
      ],
      userID: '',
      showLogin: true,
      callUserID: ''
    };
  },
  onLoad() {
    uni.$TUICallKitEvent.addEventListener('onError', (code, msg) => {
      console.log('onError', code, msg);
    });
    uni.$TUICallKitEvent.addEventListener('onCallReceived', (res) => {
      console.log('onCallReceived', JSON.stringify(res));
    });
    uni.$TUICallKitEvent.addEventListener('onCallCancelled', (callerId) => {
      console.log('onCallCancelled', callerId);
    });
    uni.$TUICallKitEvent.addEventListener('onCallBegin', (res) => {
      console.log('onCallBegin', JSON.stringify(res));
    });
    uni.$TUICallKitEvent.addEventListener('onCallEnd', (res) => {
      console.log('onCallEnd', JSON.stringify(res));
    });

  },
  methods: {
    loginHandler() {
      const userID = this.userID;
      const userSig = genTestUserSig(userID).userSig;
      // 登录 IM
      uni.$TUIKit.login({
        userID: userID,
        userSig: userSig
      });
      uni.$TUICallKit.login({
        SDKAppID: genTestUserSig('').sdkAppID,
        userID: userID,
        userSig: userSig,
      }, (res) => {
        if (res.code === 0) {
          // 开启悬浮窗
          uni.$TUICallKit.enableFloatWindow(true);
          uni.showToast({
            title: 'login success',
            icon: 'none'
          });
        } else {
          console.error('login failed, failed message = ', res.msg);
        }
      }
      );
      this.showLogin = false;
    },
    callingHandle(type) {
      const userIDs = this.callUserID.split(';');
      if (this.callUserID === '') {
        uni.showToast({
          title: '请在上方输入userID',
          icon: 'none'
        });
        return;
      }
      // 在自己的项目中可优化
      uni.$TUIKit
        .getUserProfile({
          userIDList: userIDs
        })
        .then(res => {
          if (res.data.length < userIDs.length) {
            uni.showToast({
              title: '该用户不存在，请重新输入userID',
              icon: 'none'
            });
            return;
          }
          if (res.data.length === 1) {
            // type：通话的媒体类型，比如：语音通话(callMediaType = 1)、视频通话(callMediaType = 2)
            uni.$TUICallKit.call({
              userID: userIDs[0],
              callMediaType: type
            },
              res => {
                console.log(JSON.stringify(res));
              }
            );
          }
          if (res.data.length > 1) {
            // type：通话的媒体类型，比如：语音通话(callMediaType = 1)、视频通话(callMediaType = 2)
            uni.$TUICallKit.groupCall({
              groupID: 'myGroup',
              userIDList: userIDs,
              callMediaType: type,
            },
              res => {
                console.log(JSON.stringify(res));
              }
            );
          }
        })
        .catch((error) => {
          console.log(error, '----linda')
        });
    },

    setNickHandler() {
      console.error('--linda')
      uni.$TUICallKit.setSelfInfo({
        nickName: '小橙子'
      }, (res) => {
        uni.showToast({
          title: res.msg,
          icon: 'none'
        });
        console.log(JSON.stringify(res))
      })
    },
    setUserAvatarHandler() {
      uni.$TUICallKit.setSelfInfo({
        avatar: 'https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar7.png'
      }, (res) => {
        uni.showToast({
          title: res.msg,
          icon: 'none'
        });
        console.log(JSON.stringify(res))
      })
    },
    setCallingBellHandler() {
      const ringtone = '/sdcard/android/data/uni.UNI03400CB/rain.mp3'; // 
      uni.$TUICallKit.setCallingBell(ringtone, (res) => {
        uni.showToast({
          title: res.msg,
          icon: 'none'
        });
        console.log(JSON.stringify(res))
      });
    },
    logoutHandler() {
      this.showLogin = true;
      this.callUserID = '';
      // IM 登出
      uni.$TUIKit.logout();

      // 登出 原生插件
      uni.$TUICallKit.logout((res) => {
        console.log('logout response = ', JSON.stringify(res));
      });
    }
  }
};
</script>
<style scoped>
.container {
  width: 100vw;
  height: 100vh;
  background-color: #f4f5f9;
  position: fixed;
  top: 0;
  right: 0;
  left: 0;
  bottom: 0;
}

.counter-warp {
  position: absolute;
  top: 0;
  right: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.background-image {
  width: 100%;
}

.header-content {
  display: flex;
  width: 100vw;
  padding: 50px 20px 10px;
  box-sizing: border-box;
  top: 100rpx;
  align-items: center;
}

.icon-box {
  width: 56px;
  height: 56px;
}

.text-header {
  height: 72rpx;
  font-size: 48rpx;
  line-height: 72rpx;
  color: #ffffff;
  margin: 40px auto;
}

.text-content {
  height: 36rpx;
  font-size: 24rpx;
  line-height: 36rpx;
  color: #ffffff;
}

.box {
  width: 80%;
  height: 50vh;
  position: relative;
  background: #ffffff;
  border-radius: 4px;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  justify-content: left;
  padding: 30px 20px;
}

.input-box {
  flex: 1;
  display: flex;
  font-family: PingFangSC-Regular;
  font-size: 14px;
  color: rgba(0, 0, 0, 0.8);
  letter-spacing: 0;
}

.login {
  display: flex;
  box-sizing: border-box;
  margin-top: 15px;
  width: 100%;
}

.login button {
  background: rgba(0, 110, 255, 1);
  border-radius: 30px;
  font-size: 16px;
  color: #ffffff;
  letter-spacing: 0;
  /* text-align: center; */
  font-weight: 500;
}

.loginBtn {
  margin-top: 8px;
  background-color: white;
  border-radius: 24px;
  border-radius: 24px;
  /* display: flex;
	  justify-content: center; */
  width: 100% !important;
  font-family: PingFangSC-Regular;
  font-size: 16px;
  color: #ffffff;
  letter-spacing: 0;
}

.list-item {
  display: flex;
  flex-direction: column;
  font-family: PingFangSC-Medium;
  font-size: 14px;
  color: #333333;
  border-bottom: 1px solid #eef0f3;
}

.input-container {
  width: 90%;
  margin: 50px auto 0;
  display: flex;
  flex-direction: column;
  font-family: PingFangSC-Medium;
  font-size: 14px;
  color: #333333;
  border-bottom: 1px solid #eef0f3;
}

/* 	.input-box {
		height: 20px;
		padding: 5px;
		width: 100%;
		border: 1px solid #999999;;	
	} */
.list-item .list-item-label {
  font-weight: 500;
  padding: 10px 0;
}

.guide-box {
  width: 100vw;
  box-sizing: border-box;
  padding: 16px;
  display: flex;
  flex-direction: column;
}

.single-box {
  flex: 1;
  border-radius: 10px;
  background-color: #ffffff;
  margin-bottom: 2px;
  display: flex;
  align-items: center;
}

.icon {
  display: block;
  width: 180px;
  height: 144px;
}

.single-content {
  padding: 36px 30px 36px 20px;
  color: #333333;
}

.label {
  display: block;
  font-size: 18px;
  color: #333333;
  letter-spacing: 0;
  font-weight: 500;
}

.desc {
  display: block;
  font-size: 14px;
  color: #333333;
  letter-spacing: 0;
  font-weight: 500;
}

.logo-box {
  position: absolute;
  width: 100vw;
  bottom: 36rpx;
  text-align: center;
}
</style>
