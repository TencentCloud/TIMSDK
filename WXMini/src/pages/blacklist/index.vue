<template>
  <div class="blacklist">
    <div class="slot">黑名单</div>
    <div class="wrapper">
      <div v-if="blacklist.length === 0" class="none">
        你还没有拉黑任何人哦
      </div>
      <div class="item" @click="toDetail(id)" v-for="id in blacklist" :key="id">
        {{ id }}
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  data () {
    return {
    }
  },
  computed: {
    ...mapState({
      blacklist: state => state.user.blacklist
    })
  },
  methods: {
    // 去用户详情
    toDetail (id) {
      let option = {
        userIDList: [id]
      }
      wx.$app.getUserProfile(option).then(res => {
        let userProfile = res.data[0]
        switch (userProfile.gender) {
          // TODO: 修改性别
          case this.TIM.TYPES.GENDER_UNKNOWN:
            userProfile.gender = this.$type.GENDER_UNKNOWN
            break
          case this.TIM.TYPES.GENDER_MALE:
            userProfile.gender = this.$type.GENDER_MALE
            break
          case this.TIM.TYPES.GENDER_FEMALE:
            userProfile.gender = this.$type.GENDER_FEMALE
            break
        }
        this.$store.commit('updateUserProfile', userProfile)
        let url = `../detail/main?isGroup=${false}`
        wx.navigateTo({url: url})
      })
    }
  }
}
</script>

<style lang='stylus' scoped>
.blacklist
  padding 10px 0 4px 0
  background-color $background
  height 100vh
.slot
  padding 0 0 4px 10px
  font-size 12px
  color $secondary
.none
  padding 10px
  display flex
  justify-content center
  color $regular
.wrapper
  display flex
  flex-wrap wrap
  padding 4px 6px
  background-color white
  margin-bottom -1px
  border-top 1px solid $border-base
  border-bottom 1px solid $border-base
.item
  border 2px solid $danger
  border-radius 12px
  padding 6px 10px
  font-size 14px
  color $danger
  width fit-content
  margin 6px 8px
</style>
