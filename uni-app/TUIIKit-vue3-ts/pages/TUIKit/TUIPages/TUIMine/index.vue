<template>
  <view class="contain">
    <!-- 第一部分 -->
    <view class="mine-top">
      <view class="view-image-text" @tap="handlePersonal">
        <image class="image-radius"
          :src="myInfo.avatar ? myInfo.avatar : 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/avatar_21.png'">
        </image>
        <view class="text-container">
          <view class="name">
            {{ myInfo.nick ? myInfo.nick : '提莫' }}
            <text class="hasname">(暂无昵称)</text>
          </view>
          <view class="ID">userID:{{ myInfo.userID }}</view>
        </view>
      </view>
    </view>
  </view>
  <view class="box">
    <!-- <block v-for="(item, index) in userListInfo" :key="index">
				<view class="list" :data-item="item" @tap="handleRouter">
					<image class="list-URL" :src="item.iconUrl"></image>
					<view class="list-name">
						<view>{{ item.name }}</view>
					</view>
					<image class="listimage" src="/static/static/assets/detail.svg"></image>
				</view>
			</block> -->
  </view>
  <view class="quit-main" @tap="handleQuit">
    <view class="quit-main-text">退出登录</view>
  </view>
</template>

<script>
import { defineComponent, reactive, toRefs, computed } from 'vue';
import {
  onShow,
  onReady,
  onNavigationBarButtonTap
} from '@dcloudio/uni-app'
import store from '../../TUICore/store';

const TUIMine = defineComponent({
  setup(props) {
    const data = reactive({
      myInfo: {
        nick: '',
        userID: '',
        avatar: ''
      },
    });

    onReady(() => {
      handleGetMyProfile()
    });
    const handlePersonal = () => {
      // uni.navigateTo({
      // 	url: '../personal/personal'
      // });
    };

    const handleQuit = () => {
      uni.$TUIKit.logout().then(() => {
        uni.clearStorage();
        store.commit('timStore/setLoginStatus', false);
        uni.reLaunch({
          url: '../TUILogin/index',
          success: () => {
            uni.showToast({
              title: '退出成功',
              icon: 'none'
            });
          }
        });
      });
    };

    const handleGetMyProfile = () => {
      uni.$TUIKit.tim
        .getMyProfile()
        .then(imResponse => {
          data.myInfo = imResponse.data
          console.log(imResponse.data, data.config, '---linda')
          // 		app.globalData.userProfile = imResponse.data;
        })
        .catch(imError => {
          console.warn('getMyProfile error:', imError); // 获取个人资料失败的相关信息
        });
    }

    return {
      ...toRefs(data),
      handlePersonal,
      handleQuit,
      handleGetMyProfile,
    };
  },
});
export default TUIMine;

</script>
<style>
.contain {
  width: 100%;
  height: 100vh;
  background: #f6f8fa;
  position: relative;
}

.mine-top {
  height: 358rpx;
  position: relative;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 15px;
  box-sizing: border-box;
}

.view-image-text {
  display: flex;
  width: 100%;
  height: 189rpx;
  justify-content: left;
  align-items: center;
  background: #FFFFFF;
  box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.05);
}

.image-radius {
  padding-left: 43rpx;
  padding-top: 43rpx;
  padding-bottom: 40rpx;
  height: 120rpx;
  width: 120rpx;
}

.name {
  height: 25px;
  font-family: PingFangSC-Medium;
  font-size: 18px;
  color: #333333;
  letter-spacing: 0;
  margin-left: 10px;
  margin-top: 20px;
}

.ID {
  font-family: PingFangSC-Regular;
  font-size: 14px;
  color: #666666;
  letter-spacing: 0;
  margin-left: 10px;
  margin-top: 10px;
  padding-bottom: 40rpx;
}


.quit-main {
  position: absolute;
  bottom: 80px;
  width: 100%;
  height: 112rpx;
  justify-content: center;
  align-items: center;
  display: flex;
  background: #FFFFFF;
}

.quit-main-text {
  display: flex;
  justify-content: center;
  font-family: PingFangSC-Regular;
  font-size: 34rpx;
  color: #FF584C;
  letter-spacing: 0;
}

.arrow {
  width: 16px;
  height: 16px;
  float: right;
}

.pop-mask {
  width: 100vw;
  height: 100vh;
  position: fixed;
  z-index: 2;
  top: 0;
  /*  #ifdef  H5  */
  top: calc(88rpx + constant(safe-area-inset-top));
  top: calc(88rpx + env(safe-area-inset-top));
  /*  #endif  */
  right: 0;
  background: rgba(0, 0, 0, 0.60);
  display: flex;
  align-items: center;
}

.pop-box {
  display: flex;
  justify-content: center;
  flex-direction: column;
  padding: 20rpx;
  align-items: center;
  background: #FFFFFF;
  border: 1px solid #EEF0F3;
  z-index: 1;

}

.text-title {
  right: 100px;
  left: 100px;
}

.pop-box-text {
  display: flex;
  padding-top: 10px;
  font-family: PingFangSC-Regular;
  font-size: 16px;
  padding-left: 20px;
  padding-right: 20px;
}

.agree {
  padding-top: 20rpx;
}

.pop-agree {
  padding-top: 20rpx;
  background: rgba(0, 110, 255, 1);
  border-radius: 30px;
  font-size: 16px;
  color: #FFFFFF;
  letter-spacing: 0;
  /* text-align: center; */
  font-weight: 500;
}
</style>
