<template>
    <div class="group-member-list-wrapper">
        <div class="header">
            <span class="member-count text-ellipsis">群成员：{{currentConversation.groupProfile.memberCount}}</span>
        </div>
        <div class="scroll-content">
            <div class="group-member-list">
                <el-checkbox-group v-model="callingList" @change="handleCheckedMembersChange">
                    <el-checkbox v-if="type === 'groupAt'"  :label="JSON.stringify({userID:this.TIM.TYPES.MSG_AT_ALL,nick:'所有人'})" >
                        <div class="group-member">
                            <avatar  :src="''" />
                            <div class="member-name text-ellipsis">
                                <span >所有人</span>
                            </div>
                        </div>
                    </el-checkbox>
                    <el-checkbox v-for="member in members" :disabled="member.userID===userID" :label="JSON.stringify({userID:member.userID,nick:member.nameCard || member.nick || member.userID})" :key="member.userID">
                       <div class="group-member">
                           <avatar  :src="member.avatar" />
                           <div class="member-name text-ellipsis">
                               <span v-if="member.nameCard" >{{ member.nameCard }}</span>
                               <span v-else-if="member.nick" >{{ member.nick }}</span>
                               <span v-else >{{ member.userID }}</span>
                           </div>
                       </div>
                    </el-checkbox>
                </el-checkbox-group>
            </div>
        </div>
        <div class="more">
            <el-button v-if="showLoadMore" type="text" @click="loadMore">查看更多</el-button>
        </div>
    </div>
</template>

<script>
  import { mapState } from 'vuex'
  export default {
    props:['type'],
    data() {
      return {
        callingList:[],
        addGroupMemberVisible: false,
        currentMemberID: '',
        count: 30 // 显示的群成员数量
      }
    },
    components: {
    },
    computed: {
      ...mapState({
        userID: state => state.user.userID,
        currentConversation: state => state.conversation.currentConversation,
        currentMemberList: state => state.group.currentMemberList
      }),
      showLoadMore() {
        return this.members.length < this.currentConversation.groupProfile.memberCount
      },
      members() {
        return this.currentMemberList.slice(0, this.count)
      }
    },
    methods: {
      handleCheckedMembersChange() {
        this.$emit('getList',this.callingList)
      },
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
                width 100px
                height 80px
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
                    margin 0 auto
                .member-name
                    font-size 12px
                    width: 100px;
                    text-align center
        .more
            padding 0 20px
            border-bottom 1px solid $border-base


</style>
