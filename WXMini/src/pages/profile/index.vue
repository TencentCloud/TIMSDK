<template>
  <div class="profile">
    <div class="title">个人信息</div>
    <div class="item">
      <div class="label">
        昵称：
      </div>
      <div>
        <input type="text" class="input" placeholder="请输入新昵称" v-model.lazy:value="nick"/>
      </div>
    </div>
    <div class="title">头像</div>
    <div class="avatar">
      <radio-group  @change="onChange" class="group">
        <label v-for="(item,index) in imgArr" :key="index" class="label">
          <image style="width: 40px; height: 40px; border-radius: 8px" :src="item"/>
          <div class="radio-wrapper">
            <input type="radio" name="list" :value="item" :checked="avatar === item">
          </div>
        </label>
      </radio-group>
    </div>
    <i-row>
      <i-col span="12" offset="6">
        <div style="padding: 20px 0">
          <i-button @click="revise" type="primary" long="true" shape="circle">修改资料</i-button>
        </div>
      </i-col>
    </i-row>
  </div>
</template>

<script>
export default {
  data () {
    return {
      nick: '',
      myInfo: {},
      gender: false,
      imgArr: [
        'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-1.png',
        'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-2.png',
        'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-3.png',
        'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-4.png',
        'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-5.png'
      ],
      avatar: ''
    }
  },
  onShow () {
    this.myInfo = this.$store.state.user.myInfo
  },
  methods: {
    onChange (e) {
      this.avatar = e.target.value
    },
    // 更新个人信息，目前只有昵称和头像
    revise () {
      if (this.nick || this.avatar) {
        wx.$app.updateMyProfile({
          nick: this.nick || this.myInfo.nick,
          avatar: this.avatar || this.myInfo.avatar
        }).then((res) => {
          this.$store.commit('updateMyInfo', res.data)
          this.$store.commit('showToast', {
            title: '修改成功',
            icon: 'success',
            duration: 1500
          })
          this.nick = ''
          this.avatar = ''
          wx.switchTab({
            url: '../own/main'
          })
        }).catch(() => {
          this.$store.commit('showToast', {
            title: '修改失败',
            icon: 'none',
            duration: 1500
          })
        })
      } else {
        this.$store.commit('showToast', { title: '你什么都还没填哦！' })
      }
    }
  }
}
</script>

<style lang="stylus">
.profile
  background-color $background
  min-height 100vh
.title
  color $regular
  font-size 12px
  padding 10px 0 4px 16px
.item
  height 40px
  display flex
  background-color white
  font-size 14px
  padding 3px 10px
  vertical-align middle
  box-sizing border-box
  border 1px solid $border-light
  margin-bottom -1px
  .label
    line-height 32px
    color $regular
    width 25%
  .add-label
    line-height 32px
    color $regular
    width 40%
.radio-group .radio
  background #FFFFFF
  border 1px solid #D6D6D6
  border-radius 2px
  padding 3px 12px
  text-align center
  margin-right 3px
radio
  padding-left 7px
radio .wx-radio-input.wx-radio-input-checked
  border-color $primary !important
  background $primary !important
.group
  display flex
  flex-direction row
  justify-content space-around
.label
  padding 10px
  display flex
  justify-content center
  flex-direction column
  .circle
    height 15px
    width 15px
.avatar
  background-color white
  border 1px solid $border-light
.input
  color $regular
  text-align left
  height 32px
  background-color white
  font-size 16px
  line-height 32px
  width 75%
  border-radius 10px
.button
  color white
  background-color $primary
  border-radius 8px
  height 50px
  width 200px
  line-height 50px
  font-size 16px
  margin-top 30px
</style>
