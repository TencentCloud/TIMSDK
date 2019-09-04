<template>
  <div class="group-member-list-wrapper">
    <div class="group-member-list">
      <popover v-model="addGroupMemberVisible">
        <add-group-member></add-group-member>
        <div slot="reference" class="add-group-member group-member">
          <span class="el-icon-plus add-button" style="width:30px;height:30px;" circle></span>
          <span>Add</span>
        </div>
      </popover>
      <template v-for="member in members">
        <popover placement="right" :key="member.userID">
          <group-member-info :member="member" />
          <div slot="reference" class="group-member" @click="currentMemberID = member.userID">
            <avatar
              :src="member.avatar"
              :text="getGroupMemberAvatarText(member.role)"
              shape="square"
            />
            <span class="member-name" v-if="member.nameCard">{{ member.nameCard }}</span>
            <span class="member-name" v-else-if="member.nick">{{ member.nick }}</span>
            <span class="member-name" v-else>{{ member.userID }}</span>
          </div>
        </popover>
      </template>
    </div>
    <el-button v-if="showLoadMore" type="text" @click="loadMore">查看更多</el-button>
  </div>
</template>

<script>
import { Popover } from 'element-ui'
import { mapState } from 'vuex'
import AddGroupMember from './add-group-member.vue'
import GroupMemberInfo from './group-member-info.vue'
export default {
  data() {
    return {
      addGroupMemberVisible: false,
      currentMemberID: '',
      count: 30 // 显示的群成员数量
    }
  },
  props: ['groupProfile'],
  components: {
    Popover,
    AddGroupMember,
    GroupMemberInfo
  },
  computed: {
    ...mapState({
      currentConversation: state => state.conversation.currentConversation,
      currentMemberList: state => state.group.currentMemberList
    }),
    showLoadMore() {
      return this.members.length < this.groupProfile.memberNum
    },
    members() {
      return this.currentMemberList.slice(0, this.count)
    }
  },
  methods: {
    getGroupMemberAvatarText(role) {
      switch (role) {
        case 'Owner':
          return '主'
        case 'Admin':
          return '管'
        default:
          return '普'
      }
    },
    loadMore() {
      this.$store
        .dispatch('getGroupMemberList', this.groupProfile.groupID)
        .then(() => {
          this.count += 30
        })
    }
  }
}
</script>

<style scoped>
.group-member {
  display: flex;
  flex-direction: column;
  width: fit-content;
  text-align: center;
  color: #000;
  margin: 0 12px;
  cursor: pointer;
}
.add-group-member {
  cursor: pointer;
}
.add-button {
  border: 1px solid gray;
  text-align: center;
  line-height: 30px;
}
.group-member-list-wrapper {
  border-bottom: 1px solid #ded8d8;
  padding-bottom: 6px;
  margin-bottom: 6px;
  max-height: 300px;
  overflow-y: scroll;
}
.group-member-list {
  display: flex;
  justify-content: flex-start;
  align-items: center;
  flex-wrap: wrap;
}
.member-name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  width: 30px;
}
</style>
