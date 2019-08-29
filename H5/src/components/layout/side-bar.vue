<template>
  <div class="side-bar-wrapper">
    <div class="bar-header">
      <my-profile />
      <div class="tab-items" @click="handleClick">
        <el-badge :value="totalUnreadCount" :max="99" :hidden="totalUnreadCount === 0">
          <span
            id="conversation-list"
            class="iconfont icon-conversation"
            :class="{ active: showConversationList }"
            title="会话列表"
          ></span>
        </el-badge>
        <span id="group-list" class="iconfont icon-group" :class="{ active: showGroupList }" title="群组列表"></span>
        <span
          id="friend-list"
          class="iconfont icon-contact"
          :class="{ active: showFriendList }"
          title="好友列表"
        ></span>
        <span
          id="black-list"
          class="iconfont icon-blacklist"
          :class="{ active: showBlackList }"
          title="黑名单列表"
        ></span>
      </div>
      <el-popover placement="right" trigger="click" :visible-arrow="false">
        <el-button type="text" @click="$store.dispatch('logout')">退出</el-button>
        <div slot="reference" class="more el-icon-s-operation" title="更多"></div>
      </el-popover>
    </div>
    <div class="bar-content">
      <conversation-list v-show="showConversationList" />
      <group-list v-show="showGroupList" />
      <friend-list v-show="showFriendList" />
      <black-list v-show="showBlackList" />
    </div>
  </div>
</template>

<script>
import { Popover, Badge } from 'element-ui'
import { mapGetters } from 'vuex'
import MyProfile from '../my-profile'
import ConversationList from '../conversation/conversation-list'
import GroupList from '../group/group-list'
import FriendList from '../friend/friend-list'
import BlackList from '../blacklist/blacklist'

const activeName = {
  CONVERSATION_LIST: 'conversation-list',
  GROUP_LIST: 'group-list',
  FRIEND_LIST: 'friend-list',
  BLACK_LIST: 'black-list'
}
export default {
  name: 'SideBar',
  components: {
    MyProfile,
    ConversationList,
    GroupList,
    FriendList,
    BlackList,
    ElPopover: Popover,
    ElBadge: Badge
  },
  data() {
    return {
      active: activeName.CONVERSATION_LIST,
      activeName: activeName
    }
  },
  computed: {
    ...mapGetters(['totalUnreadCount']),
    showConversationList() {
      return this.active === activeName.CONVERSATION_LIST
    },
    showGroupList() {
      return this.active === activeName.GROUP_LIST
    },
    showFriendList() {
      return this.active === activeName.FRIEND_LIST
    },
    showBlackList() {
      return this.active === activeName.BLACK_LIST
    },
    showAddButton() {
      return [activeName.CONVERSATION_LIST, activeName.GROUP_LIST].includes(this.active)
    }
  },
  methods: {
    checkoutActive(name) {
      this.active = name
    },
    handleClick(event) {
      switch (event.target.id) {
        case activeName.CONVERSATION_LIST:
          this.checkoutActive(activeName.CONVERSATION_LIST)
          break
        case activeName.GROUP_LIST:
          this.checkoutActive(activeName.GROUP_LIST)
          break
        case activeName.FRIEND_LIST:
          this.checkoutActive(activeName.FRIEND_LIST)
          break
        case activeName.BLACK_LIST:
          this.checkoutActive(activeName.BLACK_LIST)
          break
      }
    },
    handleRefresh() {
      switch (this.active) {
        case activeName.CONVERSATION_LIST:
          this.tim.getConversationList()
          break
        case activeName.GROUP_LIST:
          this.getGroupList()
          break
        case activeName.FRIEND_LIST:
          this.getFriendList()
          break
        case activeName.BLACK_LIST:
          this.$store.dispatch('getBlacklist')
          break
      }
    },
    getGroupList() {
      this.tim.getGroupList().then(({ data: groupList }) => {
        this.$store.dispatch('updateGroupList', groupList)
      })
    },
    getFriendList() {
      this.tim.getFriendList().then(({ data: friendList }) => {
        this.$store.commit('upadteFriendList', friendList)
      })
    }
  }
}
</script>

<style scoped>
.iconfont {
  font-size: 24px;
  cursor: pointer;
  color: gray;
  margin: 8px 0;
}
.more {
  position: absolute;
  margin-left: -12px;
  bottom: 30px;
  font-size: 24px;
  color: gray;
  cursor: pointer;
}
.iconfont:hover {
  color: rgb(160, 160, 160);
}
.more:hover {
  color: rgb(160, 160, 160);
}
.active {
  color: #fff;
}
.active:hover {
  color: #fff;
}
.side-bar-wrapper {
  position: relative;
  width: 300px;
  min-width: 300px;
  height: 100%;
  background-color: #dcdcdc;
  color: #000;
  display: flex;
}

.bar-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px;
  background-color: #464545;
}
.bar-content {
  width: 100%;
  overflow-y: scroll;
  overflow-x: hidden;
}
.tab-items {
  display: flex;
  flex-direction: column;
  margin-top: 12px;
}
</style>
