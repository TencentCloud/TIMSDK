<template>
    <div class="group-member-list-wrapper">
        <div class="header">
            <span class="member-count text-ellipsis">会话列表</span>
        </div>
        <div class="scroll-content">
            <div class="group-member-list">
                <el-checkbox-group v-model="conversationSelected" @change="handleCheckedConversationChange">
                    <el-checkbox v-for="conversation in conversationList"  :label="conversation.conversationID" :key="conversation.conversationID">
<!--                        <conversation-item :conversation="item"/>-->
                        <div class="conversation-item-container">
                            <div class="warp">
                                <avatar :src="avatar(conversation)" :type="conversation.type" />
                                <div class="content">
                                    <div class="row-1">
                                        <div class="name">
                                            <div class="text-ellipsis">
                <span :title="conversation.userProfile.nick || conversation.userProfile.userID"
                      v-if="conversation.type ===  TIM.TYPES.CONV_C2C"
                >{{conversation.userProfile.nick || conversation.userProfile.userID}}
                </span>
                                                <span :title="conversation.groupProfile.name || conversation.groupProfile.groupID"
                                                      v-else-if="conversation.type ===  TIM.TYPES.CONV_GROUP"
                                                >{{conversation.groupProfile.name || conversation.groupProfile.groupID}}
                </span>
                                                <span
                                                        v-else-if="conversation.type === TIM.TYPES.CONV_SYSTEM"
                                                >系统通知
                </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
<!--                        <el-divider></el-divider>-->
                    </el-checkbox>
                </el-checkbox-group>
            </div>
        </div>
        <div class="more">
<!--            <el-button v-if="showLoadMore" type="text" @click="loadMore">查看更多</el-button>-->
        </div>
    </div>
</template>

<script>
  import { mapState } from 'vuex'
  export default {
    props:['type'],
    data() {
      return {
        conversationSelected:[],
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
        conversationList: state => state.conversation.conversationList,
      }),
      showLoadMore() {
        return this.members.length < this.currentConversation.groupProfile.memberCount
      },
      avatar() {
        return function (conversation) {
          switch (conversation.type) {
            case 'GROUP':
              return conversation.groupProfile.avatar
            case 'C2C':
              return conversation.userProfile.avatar
            default:
              return ''
          }
        }

      },
      members() {
        return this.currentMemberList.slice(0, this.count)
      }
    },
    methods: {
      handleCheckedConversationChange() {
        this.$emit('getList',this.conversationSelected)
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



    .conversation-item-container
        padding 5px 20px
        cursor pointer
        position relative
        overflow hidden
        transition .2s
        .warp
            display flex
        .avatar
            width 40px
            height 40px
            margin-right 10px
            border-radius 50%
            flex-shrink 0
        .content
            flex 1
            height 40px
            overflow hidden
            font-size 13px
            .row-1
                display flex
                line-height 21px
                .name
                    color #000
                    flex 1
                    min-width 0px
                    line-height 40px

 /deep/ .el-checkbox{
     display block
 }
/deep/ .el-checkbox__label{
    width 100%
}
/deep/ .el-divider--horizontal{
   margin 0
}
.group-member-list /deep/ .el-checkbox__input {
    position absolute
    top -12px
    left 3px
    bottom 0
    margin auto
    cursor pointer
    line-height 1
    display flex
    justify-content center
    align-items center
}
</style>
