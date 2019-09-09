<template>
  <div class="counter-warp">
    <div class="login">
      <div style="margin-bottom: 20px" class="register">
        注册
      </div>
      <div class="item">
        <div class="label">
          用户名：
        </div>
        <div>
          <input type="text" class="input" placeholder="请输入用户名" v-model.lazy:value="userID"/>
        </div>
      </div>
      <div class="tip">由英文开始，可使用a~z,A~Z,0~9，长度4~24位</div>
      <div class="item">
        <div class="label">
          密码：
        </div>
        <div>
          <input type="password" class="input" minlength="6" placeholder="请输入密码" v-model.lazy:value="password"/>
        </div>
      </div>
      <div class="tip">最少6位</div>
    </div>
    <div class="login-button">
      <i-button @click="handleRegister" type="primary" shape="circle">注册</i-button>
    </div>
  </div>
</template>

<script>
import md5 from 'md5'

export default {
  data () {
    return {
      userID: '',
      password: ''
    }
  },
  methods: {
    // 点击登录进行初始化
    handleRegister () {
      let that = this
      if (/^[a-zA-Z][a-zA-Z0-9_]{3,23}$/g.test(this.userID) && this.password.length >= 6) {
        wx.request({
          url: 'https://im-demo.qcloud.com/register',
          method: 'post',
          data: {
            userid: that.userID,
            password: md5(that.password)
          },
          success (res) {
            const { code } = res.data
            let message = ''
            if (code === 200) {
              that.$store.commit('showToast', {
                title: '注册成功'
              })
              let url = '../login/main'
              wx.navigateTo({url: url})
              that.userID = ''
              that.password = ''
            } else {
              switch (code) {
                case 601:
                  message = '用户名格式错误'
                  break
                case 602:
                  message = '用户名或密码不合法'
                  break
                case 612:
                  message = '用户已存在'
                  break
                case 500:
                  message = '服务器错误'
                  break
                case 620:
                  message = '密码错误'
                  break
                default:
                  break
              }
              that.$store.commit('showToast', {
                title: message
              })
            }
          },
          fail () {
            that.$store.commit('showToast', {
              title: '出错了！请再试试'
            })
          }
        })
      } else {
        that.$store.commit('showToast', {
          title: '请按照格式设置哦！'
        })
      }
    }
  }
}
</script>

<style lang="stylus" scoped>
.register
  text-align center
  color $base
  font-weight 600
  font-size 16px
.item
  height 40px
  display flex
  background-color white
  font-size 14px
  padding 3px 5px
  vertical-align middle
  box-sizing border-box
  border 1px solid $border-light
  margin-bottom -1px
  .label
    line-height 32px
    color $regular
    width 40%
.counter-warp
  text-align center
  margin-top 100px
.login
  display inline-block
  padding 10px 0
  border-radius 8px
  width 70vw
.input
  text-align center
  color $regular
  height 32px
  background-color white
  font-size 16px
  line-height 32px
  border-radius 10px
.login-button
  width 220px
  padding 20px 0
  display inline-block
.tip
  padding-top 2px
  padding-bottom 6px
  font-size 12px
  color $primary
  text-align left
</style>
