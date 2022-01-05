<template>
<uni-shadow-root class="TUICalling-component-calling-calling"><view class="invite-call" v-if="callType === 2">
    <camera class="local-video" v-if="remoteUsers.length === 1" :device-position="pusher.frontCamera"></camera>
    <view class="invite-calling">
        <view class="invite-calling-header" v-if="remoteUsers.length === 1">
            <view class="invite-calling-header-left">
                <image src="../../static/swtich-camera.png" :data-device="pusher.frontCamera" @click.stop.prevent="toggleSwitchCamera"></image>
            </view>
            <view class="invite-calling-header-right">
                <view class="invite-calling-header-message">
                    <label class="tips">{{remoteUsers[0].nick || remoteUsers[0].userID}}</label>
                    <text class="tips-subtitle" v-if="(!isSponsor)">邀请你视频通话</text>
                    <text class="tips-subtitle" v-else>等待对方接受</text> 
                </view>
                <image class="avatar" :src="remoteUsers[0].avatar || '../../static/default_avatar.png'" :id="remoteUsers[0].userID" @error="handleErrorImage"></image>
            </view>
        </view>
        <view class="invite-calling-header invite-calling-list" v-else>
             <view v-for="(item,index) in (remoteUsers)" :key="item.userID" class="invite-calling-item">
                 <image class="avatar" :src="item.avatar || '../../static/default_avatar.png'" :id="item.userID" @error="handleErrorImage"></image>
                <view class="invite-calling-item-message">
                    <label class="tips">{{item.nick || item.userID}}</label>
                    <text class="tips-subtitle" v-if="(!isSponsor)">邀请你视频通话</text>
                    <text class="tips-subtitle" v-else>等待对方接受</text> 
                </view>
            </view>
        </view>
        <view class="footer">
            <view class="btn-operate" v-if="isSponsor">
                <view class="btn-operate-item call-switch" @click.stop.prevent="switchAudioCall">
                    <text>切换到语音通话</text>
                    <view class="call-operate">
                        <image src="../../static/trans.png"></image>
                    </view>
                </view>
            </view>
            <view class="btn-operate" v-if="isSponsor">
                <view class="btn-operate-item">
                    <view class="call-operate" style="background-color: red" @click.stop.prevent="hangup">
                        <image src="../../static/hangup.png"></image>
                    </view>
                    <text>挂断</text>
                </view>
            </view>
            <view class="btn-operate" v-if="(!isSponsor)">
                <view class="btn-operate-item">
                    <view class="call-operate" style="background-color: red" @click.stop.prevent="reject">
                        <image src="../../static/hangup.png"></image>
                    </view>
                    <text>挂断</text>
                </view>
                <view class="btn-operate-item">
                    <view class="call-operate" style="background-color: #07c160" @click.stop.prevent="accept">
                        <image src="../../static/hangup.png" style="transform: rotate(-135deg); "></image>
                    </view>
                    <text>接听</text>
                </view>
            </view>
        </view>
    </view> 
</view>
<view class="incoming-call audio-call" v-if="callType === 1">
    <view class="invite-calling-single" v-if="remoteUsers.length === 1">
        <image class="avatar" :src="remoteUsers[0].avatar || './static/default_avatar.png'" :id="remoteUsers[0].userID" @error="handleErrorImage"></image>
        <view class="tips">{{remoteUsers[0].nick || remoteUsers[0].userID}}</view>
        <view v-if="isSponsor && callType === 1" class="tips-subtitle">{{'等待对方接受'}}</view>
    </view>
    <view class="invite-calling-header invite-calling-list" v-else>
            <view v-for="(item,index) in (remoteUsers)" :key="item.userID" class="invite-calling-item">
                <image class="avatar" :src="item.avatar || '../../static/default_avatar.png'" :id="item.userID" @error="handleErrorImage"></image>
            <view class="invite-calling-item-message">
                <label class="tips">{{item.nick || item.userID}}</label>
                <text class="tips-subtitle" v-if="(!isSponsor)">邀请你视频通话</text>
                <text class="tips-subtitle" v-else>等待对方接受</text> 
            </view>
        </view>
    </view>
    <view class="footer">
        
        <view v-if="(!isSponsor && callType === 1)" class="btn-operate">
            <view class="call-operate" style="background-color: red" @click.stop.prevent="reject">
                <image src="../../static/hangup.png"></image>
            </view>
            <view class="call-operate" style="background-color: #07c160" @click.stop.prevent="accept">
                <image src="../../static/hangup.png" style="transform: rotate(-135deg); "></image>
            </view>
        </view>
        <view v-if="isSponsor && callType === 1" class="btn-operate">
            <view class="call-operate" style="background-color: red" @click.stop.prevent="hangup">
                <image src="../../static/hangup.png"></image>
            </view>
        </view>
    </view>
</view></uni-shadow-root>
</template>

<script>

global['__wxVueOptions'] = {components:{}}

global['__wxRoute'] = 'TUICalling/component/calling/calling'
// components/tui-calling/TUICalling/component/calling.js
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    isSponsor: {
      type: Boolean,
      value: false,
    },
    pusher: {
      type: Object,
    },
    callType: {
      type: Number,
    },
    remoteUsers: {
      type: Array,
    },
  },

  /**
   * 组件的初始数据
   */
  data: {

  },

  /**
   * 组件的方法列表
   */
  methods: {
    accept(event) {
      const data = {
        name: 'accept',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    hangup(event) {
      const data = {
        name: 'hangup',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    reject(event) {
      const data = {
        name: 'reject',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    handleErrorImage(e) {
      const { id } = e.target;
      const remoteUsers = this.data.remoteUsers.map((item) => {
        if (item.userID === id) {
          item.avatar = '../../static/default_avatar.png';
        }
        return item;
      });
      this.setData({
        remoteUsers,
      });
    },
    toggleSwitchCamera(event) {
      const data = {
        name: 'toggleSwitchCamera',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    switchAudioCall(event) {
      const data = {
        name: 'switchAudioCall',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
  },
});
export default global['__wxComponents']['TUICalling/component/calling/calling']
</script>
<style platform="mp-weixin">
.footer {
	position: absolute;
	bottom: 5vh;
	width: 100%;
	display: flex;
	flex-direction: column;
	justify-content: center;
	align-items: center;
}

.btn-operate {
	display: flex;
	justify-content: space-between;
}
.btn-operate-item{
	display: flex;
	flex-direction: column;
	align-items: center;
}
.btn-operate-item text {
	padding: 8px 0;
	font-size: 18px;
	color: #FFFFFF;
	letter-spacing: 0;
	font-weight: 400;
}

.call-switch text{
	padding: 0;
	font-size: 14px;
}

.call-operate {
	width: 8vh;
	height: 8vh;
	border-radius: 8vh;
	margin: 0 15vw;
	box-sizing: border-box;
	display: flex;
	justify-content: center;
	align-items: center;
}
.call-switch .call-operate {
	width: 4vh;
	height: 4vh;
	padding: 2vh 0 4vh;
}

.call-operate image {
	width: 4vh;
	height: 4vh;
	background: none;
}

.tips {
	font-size: 20px;
	color: #FFFFFF;
	letter-spacing: 0;
	margin: 0 auto;
	/* text-shadow: 0 1px 2px rgba(0,0,0,0.40); */
	font-weight: 600;
	max-width: 150px;
	overflow: hidden;
	text-overflow: ellipsis;
	white-space: nowrap;
}
.tips-subtitle {
	font-family: PingFangSC-Regular;
	font-size: 14px;
	color: #FFFFFF;
	letter-spacing: 0;
	text-align: right;
	/* text-shadow: 0 1px 2px rgba(0,0,0,0.30); */
	font-weight: 400;
}

.invite-call {
	/* background: #ffffff; */
	position: absolute;
	top: 0;
	z-index: 100;
	width: 100vw;
	height: 100vh;
}
.invite-call .local-video {
	width: 100vw;
	height: 100vh;
}
.invite-call .invite-calling {
	position: absolute;
	top: 0;
	z-index: 101;
	width: 100vw;
	height: 100vh;
}
.invite-calling-header {
	margin-top:107px;
	display: flex;
	justify-content: space-between;
	padding: 0 16px;
	
}
.invite-calling-header-left image {
	width: 32px;
	height: 32px;
}
.invite-calling-header-right {
	display: flex;
	align-items: center;
}
.invite-calling-header-message {
	display: flex;
	flex-direction: column;
	padding: 0 16px;
}
.invite-calling-header-right image {
	width: 100px;
	height: 100px;
	border-radius: 12px;
}
.invite-calling .footer {
	position: absolute;
	bottom: 5vh;
	width: 100%;
}
.invite-calling .btn-operate{
	display: flex;
	justify-content: center;
}


.hidden {
	display: none;
}

.trtc-calling {
	width: 100vw;
	height: 100vh;
	overflow: hidden;
	margin: 0;
	z-index: 99;
}

.audio-call {
	width: 100vw;
	height: 100vh;
	position: absolute;
	top: 0;
	z-index: 100;
	background: #FFFFFF;
}
.audio-call > .btn-operate{
	display: flex;
	justify-content: center;
}

.audio-call > image {
	width: 40vw;
	height: 40vw;
	display: block;
	margin: 20vw 30vw;
	margin-top: 40vw;
}

.invite-calling-single > image {
	width: 120px;
	height: 120px;
	border-radius: 12px;
	display: block;
	margin: 140px auto 15px;
	/* margin: 20vw 30vw; */
}

.invite-calling-single .tips {
	width: 100%;
	height: 40px;
	line-height: 40px;
	text-align: center;
	font-size: 20px;
	color: #333333;
	letter-spacing: 0;
	font-weight: 500;
}
.invite-calling-single .tips-subtitle {
	height: 20px;
	font-family: PingFangSC-Regular;
	font-size: 14px;
	color: #97989C;
	letter-spacing: 0;
	font-weight: 400;
	text-align: center;
}

.invite-calling-list {
	justify-content: flex-start;
}

.invite-calling-item {
	position: relative;
	margin: 0 12px;
}
.invite-calling-item image {
	width: 100px;
	height: 100px;
	border-radius: 12px;
}
.invite-calling-item-message {
	position: absolute;
	background: rgba(0, 0, 0, 0.5);
	width: 100px;
	height: 100px;
	top: 0;
	left: 0;
	z-index: 2;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.avatar {
	background: #dddddd;
}
</style>