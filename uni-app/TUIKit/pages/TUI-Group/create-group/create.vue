<template>
<view>
<!--miniprogram/pages/TUI-Group/create-group/create.wxml-->
<view class="container">
    <view class="item" @tap.stop="showtype">
        <view class="group-type">
         <view class="icon-box">
            <text class="icon">*</text>
            <text class="aside-left">群类型</text>
            <text class="aside-right" @tap="popupToggle=true">{{groupType}}</text>
            </view>

            <image class=" listimage" src="/static/static/assets/detail.svg"></image>
        </view>
    </view>
    <view class="item">
        <view class="group-ID">
            <text class="aside-left">群ID</text>
              <input class="input" type="number" placeholder="请输入群ID" @input="bindgroupIDInput" placeholder-style="color:#BBBBBB;">
        </view>
    </view>
    <view class="item">
        <view class="group-name">
            <view class="icon-box">
            <text class="icon">*</text>
            <text class="aside-left">群名称</text>
            </view>
             <input class="inputname" placeholder="请输入群名称" @input="bindgroupnameInput" placeholder-style="color:#BBBBBB;">
        </view>
    </view>
     <view class="group-create" @tap="bindConfirmCreate">发起群聊</view>
 </view>

 <view class="pop-mask" v-if="popupToggle" @tap.stop="handleChooseToggle">
     <view class="popup-main" @tap.stop="handleCatchTap">
    <view v-for="(item, index) in groupTypeList" :key="index" :class="'type ' + (item.groupType === groupType &&'type-active')" :data-value="item" @tap="selectType">
        <view class="group-type-list" :data-item="item">
        <view class="list-type">
            <view>{{item.groupType}}</view>
        </view>
    </view>
    </view>
     </view>
 </view>
</view>
</template>

<script>
// miniprogram/pages/TUI-Group/create-group/create.js
import logger from '../../../utils/logger';

export default {
  data() {
    return {
      groupTypeList: [{
        groupType: '品牌客户群（Work)',
        Type: uni.$TUIKitTIM.TYPES.GRP_WORK
      }, {
        groupType: 'VIP专属群（Public)',
        Type: uni.$TUIKitTIM.TYPES.GRP_PUBLIC
      }, {
        groupType: '临时会议群 (Meeting)',
        Type: uni.$TUIKitTIM.TYPES.GRP_MEETING
      }, {
        groupType: '直播群（AVChatRoom）',
        Type: uni.$TUIKitTIM.TYPES.GRP_AVCHATROOM
      }],
      groupType: '',
      Type: '',
      name: '',
      groupID: '',
      popupToggle: false
    };
  },

  components: {},
  props: {},
  methods: {
    showtype() {
      this.setData({
        popupToggle: true
      });
    },

    bindgroupIDInput(e) {
      const id = e.detail.value;
      this.setData({
        groupID: id
      });
    },

    bindgroupnameInput(e) {
      const groupname = e.detail.value;
      this.setData({
        name: groupname
      });
    },

    selectType(e) {
      console.error(e.currentTarget.dataset.value, 'lll')
      this.setData({
        groupType: e.currentTarget.dataset.value.groupType,
        Type: e.currentTarget.dataset.value.Type,
        name: e.currentTarget.dataset.value.name,
        popupToggle: false
      });
    },

    bindConfirmCreate() {
      logger.log(`TUI-Group | create-group | bindConfirmCreate | groupID: ${this.groupID}`);
      const promise = uni.$TUIKit.createGroup({
        type: this.Type,
        name: this.name,
        groupID: this.groupID
      });
      promise.then(imResponse => {
        // 创建成功
        // 创建的群的资料
        const {
          groupID
        } = imResponse.data.group;
        uni.navigateTo({
          url: `../../TUI-Chat/chat?conversationID=GROUP${groupID}`
        });
      }).catch(() => {
        uni.showToast({
          title: '该群组ID被使用，请更换群ID',
          icon: 'none'
        });
      });
    },

    handleChooseToggle() {
      this.setData({
        popupToggle: false
      });
    },

    handleCatchTap() {
      console.log("占位：函数 handleCatchTap 未声明");
    }

  }
};
</script>
<style>
@import "./create.css";
</style>
