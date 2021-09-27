<template>
  <div class="application-item-container" :id="'application-'+ index" @click="selectedItem">
    <div  class="application-box">
      <avatar :src="application.avatar" />
      <div class="application-content">
        <span class="application-name text-ellipsis">{{application.nick || application.userID}}</span>
        <span class="application-wording text-ellipsis" v-if="application.wording">{{application.wording}} </span>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  components: {
  },
  props: ['application','index'],
  data() {
    return {
      applicationType: 'comeIn',
      showApplicationList: [],
      acceptApplication: {
        remark: '',
        tag: '',
        type: 'Response_Action_AgreeAndAdd',
      },
    }
  },
  computed: {
    ...mapState({
      applicationList: state => state.friend.applicationList
    }),
    comeInApplicationList() {
      return this.applicationList.filter((item) => {return item.type === this.TIM.TYPES.SNS_APPLICATION_SENT_TO_ME})
    },
    sendOutApplicationList() {
      return this.applicationList.filter((item) => {return item.type === this.TIM.TYPES.SNS_APPLICATION_SENT_BY_ME})
    }
  },
  created() {
    this.showApplicationList = this.comeInApplicationList
  },
  mounted() {
  },
  methods: {
    selectedItem() {
      this.$store.commit('resetCurrentConversation')
      this.$store.dispatch('setApplicationContent', this.application)
    },
    // 应答
    acceptFriendApplication(userID) {
      this.tim.acceptFriendApplication({
        userID: userID,
        remark: this.acceptApplication.remark,
        tag: this.acceptApplication.tag,
        type: this.acceptApplication.type
      }).then(() => {
        this.resetContent()
        this.$store.commit('showMessage', {
          message: '已同意加好友',
          type: 'success'
        })

      }).catch((error) => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
    },
    resetContent() {
      this.$store.commit('resetCurrentConversation')
      this.$store.commit('resetFriendContent')
      this.$store.commit('resetApplicationContent')
    }
  }
}
</script>
<style lang="stylus" scpoed>
  .application-item-container {
    padding-left 40px
    .application-box {
      position relative
      display flex
      .avatar {
        width 40px
        height 40px
        border-radius 50%
        flex-shrink 0
        box-shadow 0 5px 10px 0 rgba(0, 0, 0, 0.1)
        margin-top 9px
      }
      .application-content {
        padding 5px 10px
        display flex
        flex-direction column
        justify-content center
        margin-top 5px
        .application-name {
          display block
          font-size 16px
          color #ffffff
          height 20px
          margin-bottom 3px
          line-height 20px
          width 80px
        }
        .application-wording {
          display block
          font-size 12px
          color #c0c4cc
          width 80px
          height 20px
          line-height 20px
        }
      }
      .accept-btn {
        position absolute
        top 16px
        right 5px
        width 40px
        height 24px
        font-size 13px
        color #ffffff
        border-radius 12px
        line-height 24px
        text-align center
        background-color #00a4ff
      }
    }

  }
  .default {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100%;
    overflow-y: scroll;
  }
  .text-ellipsis {
    /*overflow hidden*/
    /*text-overflow ellipsis*/
    /*white-space nowrap*/
  }
</style>
