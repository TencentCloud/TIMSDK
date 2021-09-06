<template>
  <transition name="el-fade-in">
    <div
      class="member-profile-card-wrapper"
      ref="member-profile-card"
      v-show="visible"
      :style="{top: y + 'px', left: x + 'px'}"
    >
      <div class="profile">
        <avatar :src="member.avatar" class="avatar" />
        <div class="basic">
          <span>ID：{{member.userID}}</span>
          <span>昵称：{{member.nick||"暂无"}}</span>
        </div>
      </div>
      <el-divider class="divider" />
      <div class="member-profile">
        <div class="item">
          <span class="label">群名片</span>
          {{member.nameCard||"暂无"}}
        </div>
        <div class="item">
          <span class="label">入群时间</span>
          {{joinTime}}
        </div>
        <div v-if="member.muteUntil" class="item">
          <span class="label">禁言至</span>
          {{muteUntil}}
        </div>
      </div>
      <el-button
        class="send-message-btn"
        type="primary"
        size="mini"
        title="发消息"
        @click="handleSendMessage"
        icon="el-icon-message"
        circle
      ></el-button>
    </div>
  </transition>
</template>

<script>
import { Divider } from 'element-ui'
import { getFullDate } from '../../utils/date'

// 群成员资料卡片组件，全局共用同一个组件。
export default {
  name: 'MemberProfileCard',
  components: {
    ElDivider: Divider
  },
  data() {
    return {
      member: {},
      x: 0, // 显示的位置 x
      y: 0, // 显示的位置 y
      visible: false
    }
  },
  mounted() {
    // 通过事件总线，监听 showMemebrProfile 事件
    this.$bus.$on('showMemberProfile', this.handleShowMemberProfile, this)
  },
  computed: {
    joinTime() {
      if (this.member.joinTime) {
        return getFullDate(new Date(this.member.joinTime * 1000))
      }
      return ''
    },
    muteUntil() {
      if (this.member.muteUntil) {
        return getFullDate(new Date(this.member.muteUntil * 1000))
      }
      return ''
    }
  },
  methods: {
    handleSendMessage() {
      this.$store.dispatch('checkoutConversation', `C2C${this.member.userID}`)
      this.hide()
    },
    handleShowMemberProfile({ event, member }) {
      // 可以拿到 meber 和 点击事件的 event 信息
      this.member = member || {}
      this.x = event.x
      this.y = event.y
      this.show()
    },
    show() {
      if (this.visible) {
        return
      }
      // 显示时，监听全局点击事件，若点击区域不是当前组件，则隐藏
      window.addEventListener('click', this.handleClick, this)
      this.visible = true
    },
    hide() {
      if (!this.visible) {
        return
      }
      // 隐藏时，注销监听
      window.removeEventListener('click', this.handleClick, this)
      this.visible = false
    },
    handleClick(event) {
      // 判断点击区域是否是当前组件，若不是，则隐藏组件
      if (event.target !== this.$refs['member-profile-card']) {
        this.hide()
      }
    }
  }
}
</script>

<style lang="stylus" scoped>
.member-profile-card-wrapper {
  max-width: 300px;
  padding: 24px;
  background: #fff;
  border-radius: 5px;
  position: fixed;
  box-shadow: 0 0 10px gray;

  .profile {
    display: flex;

    .avatar {
      width: 60px;
      height: 60px;
      min-width 60px;
      margin-right: 12px;
    }

    .basic {
      display: flex;
      align-items: flex-start;
      flex-direction: column;
    }
  }

  .divider {
    margin: 12px 0;
  }

  .member-profile {
    margin-bottom: 12px;

    .item {
      font-size: 15px;

      .label {
        display: inline-block;
        width: 4em;
        text-align: justify;
        text-align-last: justify;
        color: gray;
      }
    }
  }
  .send-message-btn {
    float right
  }
}
</style>
