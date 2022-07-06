<template>
  <view class="TUI-Create-conversation-container">
    <view class="tui-search-area">
      <view class="tui-search-bar" v-if="type === 'add'">
        <!-- <image class="tui-searchcion" src="/static/static/assets/serach-icon.svg"></image> -->
        <input class="tui-search-bar-input" :value="inputUserID" placeholder="请输入用户ID" @input="handleUserIdInput"
          @confirm="handleGetUserProfileInfo" @blur="handleGetUserProfileInfo" />
      </view>
      <view class="tui-showID">我的 ID：{{ userID }}</view>
    </view>

    <!-- 用户列表 -->
    <view class="tui-person-list-container" :class="{ delete: type === 'remove' }" v-if="chooseUserList.length > 0">
      <view class="tui-person-to-invite" :class="{ isExist: item.isExist }" v-for="(item, index) in chooseUserList"
        :key="index" @click="handleChoose(item)">
        <view class="tui-person-choose-container">
          <image class="tui-normal-choose" v-if="item.isChoose" src="/pages/TUIKit/assets/icon/selected.svg"></image>
          <view class="tui-normal-unchoose" :class="{ isExist: item.isExist && type === 'add' }" v-else></view>
        </view>
        <view class="tui-person-profile">
          <image class="tui-person-profile-avatar"
            :src="item.avatar || 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/avatar_21.png'">
          </image>
          <view>
            <view class="tui-person-profile-nick">{{ item.nick }}</view>
            <view class="tui-person-profile-userID">用户ID：{{ item.userID }}</view>
          </view>
        </view>
        <view class="exist-tips" v-if="item.isExist && type === 'add'">(已在群聊中)</view>
      </view>
    </view>
    <view class="tui-confirm-btn-container">
      <view class="tui-confirm-btn" @tap="handleConfirmOperate">确认</view>
    </view>
  </view>
</template>

<script>
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';
import { getUserProfile } from '@/pages/TUIKit/TUICore/server/profile/index';
import store from '@/pages/TUIKit/TUICore/store';
import { onLoad } from '@dcloudio/uni-app';

export default defineComponent({
  name: 'Create',
  props: {},
  setup(props, context) {
    const TUIGroupServer = uni.$TUIKit.TUIGroupServer;
    const { userInfo } = store.state.timStore;
    const data = reactive({
      userID: userInfo?.userID || '',
      inputUserID: '',
      chooseUserList: [],
      title: '发起会话',
      type: '',
      groupID: '',
    });

    // 获取页面参数
    onLoad((options) => {
      data.title = options?.title || '发起会话';
      data.type = options?.type || '';
      data.groupID = options?.groupID || '';
      uni.setNavigationBarTitle({ title: options?.type === 'add' ? '添加成员' : '删除成员' });

      // 获取群用户列表
      const params = {
        groupID: data.groupID,
        count: 100,
        offset: 0,
      };
      TUIGroupServer.getGroupMemberList(params).then((res) => {
        if (res.code === 0) {
          data.chooseUserList = (res.data.memberList || []).map(obj => ({
            ...obj,
            isShow: true,
            isExist: true,
          }));
        }
      });
    });
    // 输入查询 inputUserID 变动
    const handleUserIdInput = (e) => {
      data.inputUserID = e.detail.value;
    };
    // 获取用户信息
    const handleGetUserProfileInfo = () => {
      if (!data.inputUserID) return;
      const userIDList = [data.inputUserID];
      uni.showLoading({ title: '加载中' });

      getUserProfile(userIDList)
        .then(imRes => {
          uni.hideLoading();
          if (imRes.data.length > 0) {
            const userInfo = {
              ...imRes.data[0],
              isChoose: false,
              isShow: true,
            };
            if (data.chooseUserList.filter(obj => userInfo.userID === obj.userID).length === 0) {
              data.chooseUserList.push(userInfo);
            } else {
              data.chooseUserList = data.chooseUserList.map(obj => {
                return obj.userID === userInfo.userID ? { ...obj, isShow: true } : obj;
              });
            }
          } else {
            uni.showToast({
              title: '搜索用户不存在',
              icon: 'error'
            });
            data.inputUserID = '';
          }
        })
        .catch(err => {
          uni.hideLoading();
        });
    };
    // 用户选择切换
    const handleChoose = (item) => {
      if (item.isExist && data.type === 'add') return;
      const list = data.chooseUserList.map(obj => {
        if (item.userID == obj.userID) {
          return {
            ...obj,
            isChoose: !obj.isChoose,
          };
        } else {
          return obj;
        }
      });
      data.chooseUserList = list;
    };
    // 确认操作
    const handleConfirmOperate = async () => {
      const { type, groupID } = data;
      if (type === 'add') {
        const userIDList = data.chooseUserList.filter(obj => obj.isChoose && !obj.isExist).map(obj => obj.userID);
        await TUIGroupServer.addGroupMember({
          groupID,
          userIDList,
        });
        uni.navigateBack();
      }
      if (type === 'remove') {
        const userIDList = data.chooseUserList.filter(obj => obj.isChoose).map(obj => obj.userID);
        await TUIGroupServer.deleteGroupMember({
          groupID,
          userIDList,
        });
        uni.navigateBack();
      }
    };

    return {
      ...toRefs(data),
      handleUserIdInput,
      handleGetUserProfileInfo,
      handleChoose,
      handleConfirmOperate,
    };
  }
});
</script>
<style lang="scss" scoped>
.TUI-Create-conversation-container {
  width: 100%;
  height: 100%;
  background-color: #F4F5F9;
  overflow: hidden;
}

.tui-search-area {
  position: fixed;
  width: 750rpx;
  background-color: #EBF0F6;
  z-index: 100;
}

.tui-showID {
  padding-left: 80rpx;
  line-height: 40rpx;
  font-size: 28rpx;
  color: black;
  height: 50rpx;
  padding-top: 8rpx;
}

.tui-search-bar {
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
  margin-left: 40rpx;
  margin-top: 32rpx;
  width: 670rpx;
  height: 80rpx;
  background: #FFFFFF;
  border-radius: 40rpx;
  border-radius: 40rpx;
}

.tui-searchcion {
  display: inline-block;
  margin-left: 24rpx;
  width: 48rpx;
  height: 48rpx;
}

.tui-search-bar-input {
  // margin-left: 24rpx;
  line-height: 40rpx;
  font-size: 28rpx;
  padding: 0 36rpx;
  width: 100%;
  display: inline-block;
}

.tui-person-list-container {
  position: absolute;
  top: 100px;
  display: flex;
  flex-direction: column;
  width: 100%;
  /* height: 150rpx; */
  background-color: #FFFFFF;
  padding-left: 16px;
  align-items: center;
  overflow: hidden;
  padding-bottom: 100rpx;

  &.delete {
    top: 30px;
  }
}

.tui-person-to-invite {
  display: flex;
  flex-wrap: nowrap;
  width: 750rpx;
  height: 150rpx;
  background-color: #FFFFFF;
  padding-left: 16px;
  align-items: center;
  border-bottom: 1rpx solid #DBDBDB;

  .exist-tips {
    width: 200rpx;
  }
}

.tui-person-to-invite:last-child {
  border-bottom: 0rpx solid #DBDBDB;
}

.tui-person-choose-container {
  width: 22px;
  height: 22px;
  display: flex;
  align-items: center;
  margin-right: 17px;
}

.tui-normal-unchoose {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  border: 1px solid #DDDDDD;

  &.isExist {
    width: 100%;
    height: 100%;
    background: #FFFFFF;
    border: 1px solid #DDDDDD;
    border-radius: 50%;
  }
}

.tui-normal-choose {
  width: 100%;
  height: 100%;
}

.tui-person-profile {
  width: 622rpx;
  display: flex;
  align-items: center;
  flex: 1;
}

.tui-person-profile-avatar {
  width: 96rpx;
  height: 96rpx;
  margin-right: 24rpx;
  border-radius: 10rpx;
}

.tui-person-profile-nick {
  color: #333333;
  line-height: 50rpx;
  font-size: 36rpx;
  margin-bottom: 4rpx;
}

.tui-person-profile-userID {
  color: #999999;
  line-height: 40rpx;
  font-size: 28rpx;
}

.tui-confirm-btn-container {
  position: fixed;
  display: flex;
  justify-content: center;
  align-items: center;
  bottom: 0rpx;
  width: 100%;
  height: 96rpx;
  background-color: #FFFFFF;
  line-height: 44rpx;
  font-size: 32rpx;

  .tui-confirm-btn {
    width: 670rpx;
    height: 42px;
    background: #006EFF;
    color: #FFFFFF;
    border-radius: 42rpx;
    line-height: 44rpx;
    display: flex;
    justify-content: center;
    align-items: center;
  }
}
</style>
