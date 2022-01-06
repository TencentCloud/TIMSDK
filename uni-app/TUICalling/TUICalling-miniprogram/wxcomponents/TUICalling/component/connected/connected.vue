<template>
<uni-shadow-root class="TUICalling-component-connected-connected"><view :class="'TUICalling-connected-layout '+(callType === 1 ? 'audio' : 'video')">
    <view :class="callType === 1 ? 'pusher-audio' : playerList.length > 1 ? 'stream-box' : (screen === 'pusher' ? 'pusher-video' : 'player')" data-screen="pusher" @click.stop.prevent="toggleViewSize">
        <live-pusher :class="callType === 1 ? 'pusher-audio' : 'live'" :url="pusher.url" :mode="pusher.mode" :autopush="true" :enable-camera="pusher.enableCamera" :enable-mic="true" :muted="(!pusher.enableMic)" :enable-agc="true" :enable-ans="true" :enable-ear-monitor="pusher.enableEarMonitor" :auto-focus="pusher.enableAutoFocus" :zoom="pusher.enableZoom" :min-bitrate="pusher.minBitrate" :max-bitrate="pusher.maxBitrate" :video-width="pusher.videoWidth" :video-height="pusher.videoHeight" :beauty="pusher.beautyLevel" :whiteness="pusher.whitenessLevel" :orientation="pusher.videoOrientation" :aspect="pusher.videoAspect" :device-position="pusher.frontCamera" :remote-mirror="pusher.enableRemoteMirror" :local-mirror="pusher.localMirror" :background-mute="pusher.enableBackgroundMute" :audio-quality="pusher.audioQuality" :audio-volume-type="pusher.audioVolumeType" :audio-reverb-type="pusher.audioReverbType" :waiting-image="pusher.waitingImage" :beauty-style="pusher.beautyStyle" :filter="pusher.filter" @statechange="pusherStateChangeHandler" @netstatus="pusherNetStatus" @error="pusherErrorHandler" @audiovolumenotify="pusherAudioVolumeNotify"></live-pusher>
    </view>
    <view v-if="callType === 1" :class="'TRTCCalling-call-audio-box '+(playerList.length > 1 && 'mutil-img')">
        <view class="TRTCCalling-call-audio-img" v-if="playerList.length > 1">
            <image :src="pusher.avatar || '../../static/default_avatar.png'" class="img-place-holder avatar" :data-value="pusher.userID" data-flag="pusher" @error="handleConnectErrorImage"></image>
            <text class="audio-name">{{pusher.nick || pusher.userID}}(自己)</text>
        </view>
        <view v-for="(item,index) in (playerList)" :key="item.userID" class="TRTCCalling-call-audio-img">
            <image :src="item.avatar || '../../static/default_avatar.png'" class="img-place-holder avatar" :data-value="item.userID" data-flag="player" @error="handleConnectErrorImage"></image>
            <text class="audio-name">{{item.nick || item.userID}}</text>
        </view>
    </view>
    <view v-for="(item,index) in (playerList)" :key="item.streamID" :class="'view-container player-container '+(callType === 1 ? 'player-audio' : '')">
        <view :class="callType === 1 ? 'player-audio' : playerList.length > 1 ? 'stream-box' : (screen === 'player' ? 'pusher-video' : 'player')" data-screen="player" @click.stop.prevent="toggleViewSize">
            <live-player class="live" :id="item.id" :data-userid="item.userID" :data-streamid="item.streamID" :data-streamtype="item.streamType" :src="item.src" mode="RTC" :autoplay="item.autoplay" :mute-audio="item.muteAudio" :mute-video="item.muteVideo" :orientation="item.orientation" :object-fit="item.objectFit" :background-mute="item.enableBackgroundMute" :min-cache="item.minCache" :max-cache="item.maxCache" :sound-mode="soundMode" :enable-recv-message="item.enableRecvMessage" :auto-pause-if-navigate="item.autoPauseIfNavigate" :auto-pause-if-open-native="item.autoPauseIfOpenNative" @statechange="playerStateChange" @fullscreenchange="playerFullscreenChange" @netstatus="playNetStatus" @audiovolumenotify="playerAudioVolumeNotify"></live-player>
        </view>
    </view>
    <view class="handle-btns">
        <view :class="'other-view '+(callType === 1 ? 'black' : 'white')">
            <text>{{pusher.chatTime}}</text>
        </view>
        <view class="btn-list">
            <view class="btn-normal" @click="pusherAudioHandler">
                <image class="btn-image" :src="(pusher.enableMic? '../../static/audio-true.png': '../../static/audio-false.png')+' '"></image>
            </view>
            <view class="btn-hangup" @click="hangup" v-if="callType === 1">
                <image class="btn-image" src="../../static/hangup.png"></image>
            </view>
            <view class="btn-normal" @click="toggleSoundMode">
                <image class="btn-image" :src="(soundMode === 'ear' ? '../../static/speaker-false.png': '../../static/speaker-true.png')+' '"></image>
            </view>
            <view class="btn-normal" @click="pusherVideoHandler" v-if="callType === 2">
                <image class="btn-image" :src="(pusher.enableCamera ? '../../static/camera-true.png': '../../static/camera-false.png')+' '"></image>
            </view>
        </view>
        <view class="btn-list" v-if="callType===2">
            <view class="btn-list-item">
                <view v-if="playerList.length === 1" class="btn-normal" @click="switchAudioCall">
                    <image class="btn-image btn-image-small" :src="('../../static/trans.png')+' '"></image>
                </view>
            </view>
            <view class="btn-list-item other-view">
                <view class="btn-hangup" @click="hangup">
                    <image class="btn-image" src="../../static/hangup.png"></image>
                </view>
                <text class="white">挂断</text>
            </view>
            <view class="btn-list-item btn-footer">
                <view v-if="pusher.enableCamera" :class="playerList.length > 1 ? 'multi-camera' : 'camera'">
                    <image class="camera-image" src="../../static/swtich-camera.png" :data-device="pusher.frontCamera" @click.stop.prevent="toggleSwitchCamera"></image>
                </view>
            </view>
        </view>
    </view>
</view></uni-shadow-root>
</template>

<script>

global['__wxVueOptions'] = {components:{}}

global['__wxRoute'] = 'TUICalling/component/connected/connected'
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    playerList: {
      type: Array,
    },
    pusher: {
      type: Object,
    },
    callType: {
      type: Number,
    },
    soundMode: {
      type: String,
    },
    screen: {
      type: String,
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
    toggleViewSize(event) {
      const data = {
        name: 'toggleViewSize',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    pusherNetStatus(event) {
      const data = {
        name: 'pusherNetStatus',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    playNetStatus(event) {
      const data = {
        name: 'playNetStatus',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    pusherStateChangeHandler(event) {
      const data = {
        name: 'pusherStateChangeHandler',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    pusherAudioVolumeNotify(event) {
      const data = {
        name: 'pusherAudioVolumeNotify',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    playerStateChange(event) {
      const data = {
        name: 'playerStateChange',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    playerAudioVolumeNotify(event) {
      const data = {
        name: 'playerAudioVolumeNotify',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    pusherAudioHandler(event) {
      const data = {
        name: 'pusherAudioHandler',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    hangup(event) {
      const data = {
        name: 'hangup',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    toggleSoundMode(event) {
      const data = {
        name: 'toggleSoundMode',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    pusherVideoHandler(event) {
      const data = {
        name: 'pusherVideoHandler',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    toggleSwitchCamera(event) {
      const data = {
        name: 'toggleSwitchCamera',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    switchAudioCall(event) {
      const data = {
        name: 'switchAudioCall',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    handleConnectErrorImage(e) {
      const { value, flag } = e.target.dataset;
      if (flag === 'pusher') {
        this.data.pusher.avatar = '../../static/default_avatar.png';
        this.setData({
          pusher: this.data.pusher,
        });
      } else {
        const playerList = this.data.playerList.map((item) => {
          if (item.userID === value) {
            item.avatar = '../../static/default_avatar.png';
          }
          return item;
        });
        this.setData({
          playerList,
        });
      }
    },
  },
});
export default global['__wxComponents']['TUICalling/component/connected/connected']
</script>
<style platform="mp-weixin">
.player {
    position: absolute;
    right: 16px;
    top: 107px;
    width: 100px;
    height: 178px;
    padding: 16px;
    z-index: 3;
  }
  .pusher-video {
    position: absolute;
    width: 100%;
    height: 100%;
    /* background-color: #f75c45; */
    z-index: 1;
  }
  .stream-box {
    position: relative;
    float: left;
    width: 50vw;
    height: 260px;
    /* background-color: #f75c45; */
    z-index: 3;
  }
  .handle-btns {
    position: absolute;
    bottom: 44px;
    width: 100vw;
    z-index: 3;
    display: flex;
    flex-direction: column;
  }
  .handle-btns .btn-list {
    display: flex;
    flex-direction: row;
    justify-content: space-around;
    align-items: center;
  }
  
  .btn-normal {
    width: 8vh;
    height: 8vh;
    box-sizing: border-box;
    display: flex;
    /* background: white; */
    justify-content: center;
    align-items: center;
    border-radius: 50%;
  }
  .btn-image{
    width: 8vh;
    height: 8vh;
    background: none;
  }
  .btn-hangup  {
    width: 8vh;
    height: 8vh;
    background: #f75c45;
    box-sizing: border-box;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 50%;
  }
  .btn-hangup>.btn-image {
    width: 4vh;
    height: 4vh;
    background: none;
  }
  
  .TRTCCalling-call-audio {
    width: 100%;
    height: 100%;
  }

  .btn-footer {
    position: relative;
  }
  
  .btn-footer .multi-camera {
    width: 32px;
    height: 32px;
  }
  
  .btn-footer .camera {
    width: 64px;
    height: 64px;
    position: fixed;
    left: 16px;
    top: 107px;
    display: flex;
    justify-content: center;
    align-items: center;
    background: rgba(#ffffff, 0.7);
  }
  .btn-footer .camera .camera-image {
    width: 32px;
    height: 32px;
  }
  
.TUICalling-connected-layout {
  width: 100%;
  height: 100%;
}
.audio{
  padding-top: 15vh;
  background: #ffffff;
}

.pusher-audio {
  width: 0;
  height: 0;
}

.player-audio{
  width: 0;
  height: 0;
}

.live {
  width: 100%;
  height: 100%;
}

.other-view {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: 18px;
  letter-spacing: 0;
  font-weight: 400;
  padding: 16px;
}

.white {
  color: #FFFFFF;
  padding: 5px;
}

.black {
  color: #000000;
  padding: 5px;
}

.TRTCCalling-call-audio-box {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
}
.mutil-img {
  justify-content: flex-start !important;
}

.TRTCCalling-call-audio-img {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.TRTCCalling-call-audio-img>image {
  width: 25vw;
  height: 25vw;
  margin: 0 4vw;
  border-radius: 4vw;
  position: relative;
}
.TRTCCalling-call-audio-img text{
  font-size: 20px;
  color: #333333;
  letter-spacing: 0;
  font-weight: 500;
}

.btn-list-item {
  flex: 1;
  display: flex;
  justify-content: center;
  padding: 16px 0;
}

.btn-image-small {
  transform: scale(.7);
}

.avatar {
	background: #dddddd;
}
</style>