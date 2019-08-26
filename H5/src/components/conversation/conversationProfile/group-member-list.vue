<template>
  <div class="group-member-list-wrapper">
    <popover v-model="addGroupMemberVisible">
      <add-group-member></add-group-member>
      <div slot="reference" class="add-group-member group-member">
        <span class="el-icon-plus add-button" style="width:30px;height:30px;" circle></span>
        <span>Add</span>
      </div>
    </popover>
    <template v-for="member in memberList">
      <popover placement="right" :key="member.userID">
        <group-member-info :member="member" />
        <div slot="reference" class="group-member" @click="currentMemberID = member.userID">
          <avatar :src="member.avatar" :text="getGroupMemberAvatarText(member.role)" shape="square" />
          <span class="member-name" v-if="member.nameCard">{{ member.nameCard }}</span>
          <span class="member-name" v-else-if="member.nick">{{ member.nick }}</span>
          <span class="member-name" v-else>{{ member.userID }}</span>
        </div>
      </popover>
    </template>
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
      currentMemberID: ''
    }
  },
  props: ['memberList'],
  components: {
    Popover,
    AddGroupMember,
    GroupMemberInfo
  },
  computed: {
    ...mapState({
      currentConversation: state => state.conversation.currentConversation
    })
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
  display: flex;
  justify-content: flex-start;
  align-items: center;
  flex-wrap: wrap;
  border-bottom: 1px solid #ded8d8;
  padding-bottom: 6px;
  margin-bottom: 6px;
}
.member-name {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  width: 30px;
}
</style>
