<template>
  <div class="profile">
    <i-cell-group>
      <i-cell title="userID" :value="myInfo.userID" value-class="cell-value"></i-cell>
      <i-cell title="头像">
        <i-avatar slot="footer" i-class="avatar" :src="myInfo.avatar" />
      </i-cell>
      <i-cell title="昵称" value-class="cell-value" :value="myInfo.nick || '暂无'" is-link url="../update-profile/main?type=user&key=nick"/>
      <i-cell title="个性签名" value-class="cell-value" is-link url="../update-profile/main?type=user&key=signature">
        <div slot="footer" class="signature">
          {{myInfo.selfSignature || '暂无'}}
        </div>
      </i-cell>
    </i-cell-group>
  </div>
</template>

<script>
import { mapState } from 'vuex'

export default {
  data () {
    return {
      nick: '',
      gender: false,
      avatar: ''
    }
  },
  computed: {
    ...mapState({
      myInfo: state => state.user.myInfo
    })
  },
  methods: {
    onChange (e) {
      this.avatar = e.target.value
    }
  }
}
</script>

<style lang="stylus">
.profile
  background-color $background
  min-height 100vh
.avatar
  width 30px
  height 30px
  border-radius 3px
.signature
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
  max-width 50vw
.cell-value
  color $secondary !important
</style>
