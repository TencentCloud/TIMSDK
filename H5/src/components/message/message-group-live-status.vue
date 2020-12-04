<template>
  <div class="group-live-custom-message-card" @click="handleClick">
    <p class="card-title">{{cardTitle}}</p>
    <p class="card-content">{{cardContent}}</p>
    <div class="card-footer">
      <img class="avatar" :src="roomCover" alt="">
      <span>群直播</span>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import axios from 'axios'
export default {
  name: 'MessageGroupLiveStatus',
  props: {
    liveInfo: {
      type: Object,
      required: true
    }
  },
  computed: {
    ...mapState({
      userID: state => state.user.userID
    }),
    cardTitle() {
      return `${this.liveInfo.anchorName || this.liveInfo.anchorId}的直播`
    },
    cardContent() {
      return Number(this.liveInfo.roomStatus) === 1 ? '正在直播' : '结束直播'
    },
    roomCover() {
      return this.liveInfo.roomCover || 'https://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-2.png'
    }
  },
  methods: {
    async handleClick() {
      const isExisting = await this.checkRoomExist()
      const { roomId: roomID, anchorId: anchorID, roomName } = this.liveInfo
      if (!isExisting) {
        this.$store.commit('showMessage', {
          message: '直播已结束',
          type: 'info'
        })
        return
      }
      // 主播多实例登录时，点击卡片直接返回
      if (anchorID === this.userID) {
        this.$store.commit('showMessage', {
          message: '您正在其它终端或者Web实例上开播，请勿重复开播！',
          type: 'info'
        })
        return
      }
      this.$store.commit('updateGroupLiveInfo', {
        groupID: this.toAccount,
        roomID: roomID,
        anchorID: anchorID,
        roomName: roomName,
      })
      this.$bus.$emit('open-group-live',  { channel: 3 })
    },
    // 检查房间是否存在
    async checkRoomExist() {
      const checkRes = await axios ('https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/forTest?method=getRoomList&appId=1400187352&type=groupLive')
      const list = (checkRes.data && checkRes.data.data) || []
      const roomIDList = []
      list.forEach(item => {
        roomIDList.push(item.roomId)
      })
      return roomIDList.includes(this.liveInfo.roomId) 
    }
  }
}
</script>

<style lang="stylus" scoped>
.group-live-custom-message-card {
  min-width: 160px;
  max-width: 220px;
  height 100px;
  padding: 10px;
  background-color: #fff;
  color: #000;
  cursor: pointer;
  overflow: hidden;
  text-overflow: ellipsis;
  // white-space: nowrap;

  .card-title {
    font-weight: 500;
    margin: 0;
  }
  .card-content {
    margin-bottom: 5px;
    font-weight: 400;
    border-bottom: 1px solid #e6e6e6;
  }
  .card-footer {
    display: flex;
    align-items: center;
    color: #8e8b8b;
    font-weight: 400;
    font-size: 13px;
    .avatar {
      width: 28px;
      height: 28px;
      border-radius: 50%;
      margin-right: 5px;
    }
  }
}
</style>
