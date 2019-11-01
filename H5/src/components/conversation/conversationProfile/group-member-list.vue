<template>
  <div class="group-member-list-wrapper">
    <div class="header">
      <span class="member-count text-ellipsis">群成员：{{currentConversation.groupProfile.memberNum}}</span>
      <popover v-model="addGroupMemberVisible">
        <add-group-member></add-group-member>
        <div slot="reference" class="btn-add-member" title="添加群成员">
          <span class="tim-icon-friend-add"></span>
        </div>
      </popover>
    </div>
    <div class="scroll-content">
      <div class="group-member-list">
        <template v-for="member in members">
          <popover placement="right" :key="member.userID">
            <group-member-info :member="member" />
            <div slot="reference" class="group-member" @click="currentMemberID = member.userID">
              <avatar :title=getGroupMemberAvatarText(member.role) :src="member.avatar" />
              <div class="member-name text-ellipsis">
                <span v-if="member.nameCard" :title=member.nameCard>{{ member.nameCard }}</span>
                <span v-else-if="member.nick" :title=member.nick>{{ member.nick }}</span>
                <span v-else :title=member.userID>{{ member.userID }}</span>
              </div>
            </div>
          </popover>
        </template>
      </div>
    </div>
    <div class="more">
      <el-button v-if="showLoadMore" type="text" @click="loadMore">查看更多</el-button>
    </div>
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
          return '群主'
        case 'Admin':
          return '管理员'
        default:
          return '群成员'
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

<style lang="stylus" scoped>
.group-member-list-wrapper
  .header
    height 50px
    padding 10px 16px 10px 20px
    border-bottom 1px solid $border-base
    .member-count
      display inline-block
      max-width 130px
      line-height 30px
      font-size 14px
      vertical-align bottom
    .btn-add-member
      width 30px
      height 30px
      font-size 28px
      text-align center
      line-height 32px
      cursor pointer
      float right
      &:hover
        color $light-primary
  .scroll-content
    max-height: 250px;
    overflow-y: scroll;
    padding 10px 15px 10px 15px
    width 100%
    .group-member-list
      display flex
      justify-content flex-start
      flex-wrap wrap
      width 100%
    .group-member
      width 60px
      height 60px
      display: flex;
      justify-content center
      align-content center
      flex-direction: column;
      text-align: center;
      color: $black;
      cursor: pointer;
      .avatar
        width 40px
        height 40px
        border-radius 50%
      .member-name
        font-size 12px
        width: 40px;
        text-align center
  .more
    padding 0 20px
    border-bottom 1px solid $border-base

// .add-group-member {
//   cursor: pointer;
// }
// .add-button {
//   border: 1px solid gray;
//   text-align: center;
//   line-height: 30px;
// }



</style>
