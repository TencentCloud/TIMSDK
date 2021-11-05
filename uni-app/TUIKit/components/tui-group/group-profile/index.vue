<template>
<view>
<!--miniprogram/components/tui-group/group-profile/index.wxml-->
<view class="group-information-box" @show="getgroupProfile">
    <view class="group-box">
        <text class="group-ID">群ID:{{conversation.groupProfile.groupID}}</text>
        <view @tap="showMoreHandler">
        <text class="group-member">聊天成员:{{conversation.groupProfile.memberCount}}人</text>
        <image v-if="notShow" class=" icon-right" src="/static/static/assets/down.svg"></image>
        <image v-if="isShow" class=" icon-right" src="/static/static/assets/up.svg"></image>
        </view>
    </view>
    <view v-show="!hidden" class="showdetail">
         <view v-for="(item, index) in groupmemberprofile" :key="index" class="box" v-if="index<3" :data-value="item">
            <image class="profile-box" :src="item.avatar|| 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/avatar_21.png'"></image>
             <text class="nick-box">{{item.nick||item.userID}}</text>
          </view>
        <view class="box" v-if="showMore">
            <image class="profile-box" src="/static/static/assets/show.svg" @tap="showMoreMember"></image>
            <text class="nick-box">更多</text>
        </view>
        <view class="left-box">
         <view class="box-group" v-if="addShow">
            <image class="addmember" src="/static/static/assets/addgroup.svg" @tap="addMember"></image>
            <text class="addmember-text">添加成员</text>
        </view>
        <view class="box-group-quit">
            <image class="quitgroup" src="/static/static/assets/quitgroup.svg" @tap.stop="quitGroup"></image>
            <text class="quitgroup-text">退出群聊</text>
        </view>
    </view>
    </view>
</view>
<view class="pop-container">
<view class="popup-mask" v-if="popupToggle" @tap.stop="handleEditToggle">
    <view class="pop-main">
        <view class="pop-main-header">
        <text class="group-member-text">群成员</text>
        <text class="close" @tap.stop="close">关闭</text>
        </view>
    <view class="image-list">
    <view v-for="(item, index) in groupmemberprofile" :key="index" class="image-nick-box" :data-value="item">
        <image class="image-box" :src="item.avatar|| 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/avatar_21.png'"></image>
        <text class="groupmembername">{{item.nick||item.userID}}</text>
    </view>
    </view>
    </view>
</view>
</view>
<view class="pop-container">
<view class="quitpop-mask" v-if="quitpopupToggle">
<view class="quitpop">
    <view class=" quit-box">
        <view class="text-box">
        <text class="confirmQuitgroup-text">退出群聊后会同步删除历史聊天记录，是否要退出群聊？</text>
    </view>
    <view class="text-box-qiut" @tap.stop="quitgroupConfirm">
        <text class="quitgroup-confirm">退出</text>
    </view>
    <view class="text-box-cancle" @tap="quitgroupAbandon">
        <text class="quitgroup-abandon">取消</text>
    </view>
</view>
</view>

</view>
</view>
<view class="mask" v-if="addpopupToggle">
    <view class="popup">
        <view class="popup-main">
            <text>添加群成员</text>
            <input class="input-box" type="number" placeholder="请输入userID" @input="binduserIDInput" placeholder-style="color:#BBBBBB;">
        </view>
        <view class="popup-footer">
           <button class=" popup-footer-button submit" @tap.stop="submit">确认</button>
            <button class="popup-footer-button cancel" @tap.stop="close">取消</button>

        </view>
    </view>
</view>
</view>
</template>

<script>
import logger from '../../../utils/logger';

export default {
  data() {
    return {
      userID: '',
      // conversation: {},
      newgroup: {},
      groupmemberprofile: {},
      groupmemberavatar: [],
      groupmembernick: [],
      hidden: true,
      notShow: true,
      isShow: false,
      showMore: false,
      addShow: false,
      popupToggle: false,
      quitpopupToggle: false,
      addpopupToggle: false
    };
  },

  components: {},
  props: {
    conversation: {
      type: Object,
    }
  },
  watch: {
    conversation: {
      handler: function (newVal) {
        if (newVal.type === 'GROUP') ;
        this.setData({
          conversation: newVal
        });
      },
      immediate: true,
      deep: true
    }
  },

  beforeMount() {},

  methods: {
    showMoreHandler() {
      uni.$TUIKit.getGroupMemberList({
        groupID: this.conversation.groupProfile.groupID,
        count: 50,
        offset: 0
      }) // 从0开始拉取30个群成员
      .then(imResponse => {
        logger.log(`| TUI-group-profile | getGroupMemberList  | getGroupMemberList-length: ${imResponse.data.memberList.length}`);

        if (this.conversation.groupProfile.type === 'Private') {
          this.setData({
            addShow: true
          });
        }

        if (imResponse.data.memberList.length > 3) {
          this.setData({
            showMore: true
          });
        }

        this.setData({
          groupmemberprofile: imResponse.data.memberList,
          hidden: !this.hidden,
          notShow: !this.notShow,
          isShow: !this.isShow
        });
      });
    },

    showless() {
      this.setData({
        isShow: false,
        notShow: true,
        hidden: true
      });
    },

    showMoreMember() {
      this.setData({
        popupToggle: true //  quitpopupToggle: false

      });
    },

    close() {
      this.setData({
        popupToggle: false,
        addpopupToggle: false,
        quitpopupToggle: false
      });
    },

    quitGroup() {
      this.setData({
        quitpopupToggle: true,
        popupToggle: false
      });
    },

    quitgroupConfirm() {
      uni.$TUIKit.quitGroup(this.conversation.groupProfile.groupID).then(imResponse => {
        console.log(imResponse.data.groupID); // 退出成功的群 ID

        uni.navigateBack({
          delta: 1
        });
      }).catch(imError => {
        uni.showToast({
          title: '该群不允许群主主动退出',
          icon: 'none'
        });
        console.warn('quitGroup error:', imError); // 退出群组失败的相关信息
      });
    },

    quitgroupAbandon() {
      console.log(22222);
      this.setData({
        quitpopupToggle: false
      });
    },

    addMember() {
      this.setData({
        addpopupToggle: true
      });
    },

    binduserIDInput(e) {
      const id = e.detail.value;
      this.setData({
        userID: id
      });
    },

    submit() {
      console.log(this.userID);
      uni.$TUIKit.addGroupMember({
        groupID: this.conversation.groupProfile.groupID,
        userIDList: [this.userID]
      }).then(imResponse => {
        if (imResponse.data.successUserIDList.length > 0) {
          uni.showToast({
            title: '添加成功',
            duration: 800
          });
          this.userID = '';
          this.addMemberModalVisible = false;
          this.setData({
            addpopupToggle: false
          });
        }

        if (imResponse.data.existedUserIDList.length > 0) {
          uni.showToast({
            title: '该用户已在群中',
            duration: 800,
            icon: 'none'
          });
        }
      }).catch(imError => {
        console.warn('addGroupMember error:', imError); // 错误信息

        uni.showToast({
          title: '添加失败，请确保该用户存在',
          duration: 800,
          icon: 'none'
        });
      });
    },

    handleEditToggle() {
      console.log("占位：函数 handleEditToggle 未声明");
    },

    getgroupProfile() {
      console.log("占位：函数 getgroupProfile 未声明");
    }

  }
};
</script>
<style>
@import "./index.css";
</style>
