<template>
  <view class="TUI-Create-conversation-container">
    <view class="tui-search-area">
      <view class="tui-search-bar">
        <!-- <image class="tui-searchcion" src="/static/static/assets/serach-icon.svg"></image> -->
        <input class="tui-search-bar-input" :value="inputUserID" placeholder="请输入用户ID" @input="handleUserIdInput"
          @confirm="handleGetUserProfileInfo" @blur="handleGetUserProfileInfo" />
      </view>
      <view class="tui-showID"></view>
    </view>

    <!-- 用户列表 -->
    <view class="tui-person-list-container">
      <view class="tui-person-to-invite" v-for="(item, index) in chooseUserList" :key="index"
        @click="handleChoose(item)">
        <view class="tui-person-choose-container">
          <image class="tui-normal-choose" v-if="item.isChoose" src="/pages/TUIKit/assets/icon/selected.svg"></image>
          <view class="tui-normal-unchoose" v-else></view>
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
      </view>
    </view>

    <view class="tui-confirm-btn-container">
      <view class="tui-confirm-btn" @tap="handleCreateGroup">确认创建</view>
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
    const TUIConversationServer = uni.$TUIKit.TUIConversationServer;
    const { userInfo } = store.state.timStore;
    const data = reactive({
      userID: userInfo?.userID || '',
      inputUserID: '',
      chooseUserList: [],
      title: '发起会话',
      type: uni.$TUIKit.TIM.TYPES.CONV_C2C,
    });
    // 获取页面参数
    onLoad((options) => {
      data.title = options && options.title || '发起会话';
      data.type = options && options.type || uni.$TUIKit.TIM.TYPES.CONV_C2C;
    });
    // 输入查询 inputUserID 变动
    const handleUserIdInput = (e) => {
      data.inputUserID = e.detail.value;
      // data.chooseUserList = data.chooseUserList.filter(obj => obj.isChoose);
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
              isChoose: false
            };
            if (data.chooseUserList.filter(obj => userInfo.userID === obj.userID).length === 0) {
              data.chooseUserList.push(userInfo);
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
    // 确认邀请
    const handleCreateGroup = () => {
      const chooseList = data.chooseUserList.filter(obj => obj.isChoose);
      if (chooseList.length > 0) {
        switch (data.type) {
          case uni.$TUIKit.TIM.TYPES.CONV_C2C: {
            if (chooseList.length > 1) {
              uni.showToast({
                title: `“发起会话”仅能选择一个用户`,
                icon: 'none'
              });
              return;
            } else {
              const conversationId = `C2C${chooseList[0].userID}`;
              handleJumpToChat(conversationId);
            }
            break;
          }
          // 群操作
          case uni.$TUIKit.TIM.TYPES.GRP_WORK:
          case uni.$TUIKit.TIM.TYPES.GRP_PUBLIC:
          case uni.$TUIKit.TIM.TYPES.GRP_MEETING: {
            let name = '';
            if (chooseList.length > 2) {
              name = chooseList.slice(0, 3).map(obj => obj.nick || obj.userID).join(',') || '';
            } else {
              const { userInfo } = store.state.timStore;
              name = chooseList.map(obj => obj.nick || obj.userID).join(',') + '、' + (userInfo?.nick || userInfo?.userID);
            }
            const groupOptions = {
              avatar: 'https://web.sdk.qcloud.com/component/TUIKit/assets/group_avatar.png',
              type: data.type,
              name: name,
              memberList: chooseList.map(obj => ({
                userID: obj.userID,
                role: obj.role,
                memberCustomField: obj.memberCustomField
              }))
            };
            uni.showLoading({ title: '群组创建中…' });
            uni.$TUIKit.tim.createGroup(groupOptions)
              .then(imResponse => {
                uni.hideLoading();
                const { groupID } = imResponse.data && imResponse.data.group;
                if (groupID) {
                  const conversationId = `GROUP${groupID}`;
                  handleJumpToChat(conversationId);
                }
              })
              .catch(err => {
                uni.showToast({ title: '群组创建失败！' });
                uni.hideLoading();
              });
            break;
          }
        }
      } else {
        uni.showToast({
          title: '请选择相关用户',
          icon: 'none'
        });
      }
    }
    // 跳转到会话聊天
    const handleJumpToChat = (conversationId) => {
      store.commit('timStore/setConversationID', conversationId)
      uni.$TUIKit.TUIChatServer.updateStore(conversationId)
      TUIConversationServer.setMessageRead(conversationId);
      TUIConversationServer.getConversationProfile(conversationId)
        .then((res) => {
          // 通知 TUIChat 关闭当前会话
          const { conversation } = res.data;
          console.log('create conversation response = ', res);
          store.commit('timStore/setConversation', conversation);
          let url = '../TUIChat/index';
          if (conversationId.slice(0, 5) === 'GROUP') {
            const { name } = conversation.groupProfile;
            url = `${url}?conversationName=${name}`;
          } else if (conversationId.slice(0, 3) === 'C2C') {
            const { nick: name } = conversation.userProfile;
            url = `${url}?conversationName=${conversation.userProfile.nick?.nick || conversation.userProfile.userID}`;
          }
          uni.redirectTo({ url });
        })
        .catch(err => {
          console.warn('获取 group profile 异常 = ', err);
        });
    };

    return {
      ...toRefs(data),
      handleUserIdInput,
      handleGetUserProfileInfo,
      handleChoose,
      handleCreateGroup,
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
  overflow: auto;
  padding-bottom: 100rpx;
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
}

.tui-normal-choose {
  width: 100%;
  height: 100%;
}

.tui-person-profile {
  width: 622rpx;
  display: flex;
  align-items: center;
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
