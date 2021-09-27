<template>
  <div class="login-wrapper">
      <!-- 顶部三个蓝条 -->
      <div class="row-div" style="width: 100%; height: 10px">
          <div style="width: 190px; height: 100%; background-color: #006EFF"></div>
          <div style="width: 160px; height: 100%; background-color: #00A4FF"></div>
          <div style="width: 100px; height: 100%; background-color: #5AD5E0"></div>
      </div>
    <!-- 腾讯云logo -->
    <div class="row-div" style="width: 100%; height: 100px; justify-content: center">
        <img style="height: 23px" :src="txcLogo" alt="">
        <div style="width: 9px"></div>
        <div style="width: 1px; height: 10px; background-color: #D8D8D8"></div>
        <div style="width: 9px"></div>
        <div style="width: 86px; height: 23px; font-size: 18px; color: #333333">即时通信</div>
    </div>
    <img class="logo" :src="logo"/>
    <!-- 登录操作区-->
    <el-form ref="login" label-width="120" :rules="rules" :model="form" class="loginBox" >
      <template v-if="!hasToken">
        <el-form-item prop="phoneNum">
          <el-input id="phoneNum" v-model="form.phoneNum" placeholder="请输入手机号" type="text">
              <el-input v-model="form.areaCode" class="areaCode"   type="text"  slot="prepend" placeholder="86">
              </el-input>
          </el-input>
        </el-form-item>
        <el-form-item class="get-code-item" prop="verifyCode">
          <el-input id="verifyCode" v-model="form.verifyCode" placeholder="请输入验证码" type="text"></el-input>
          <span id="sendCode" class="send-code" :class="[!canGetCode ? 'counter' : '']"  @click="getVerifyCode">{{sendCodeBtnText}}</span>
        </el-form-item>
      </template>
      <el-form-item v-if="hasToken" prop="userID" label="用户ID">
        <el-input id="userID" v-model="form.userID" type="text" disabled></el-input>
      </el-form-item>
     <div>
         <el-checkbox v-model="privacy" style="display: inline">
         </el-checkbox>
         <span class="privacy-text">我已阅读并同意<a href="https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html">《隐私条例》</a>和<a href="https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html">《用户协议》</a></span>
     </div>
      <el-form-item>
        <el-button class="login-im-btn" style="margin-top: 12px" type="primary" @click="login" :loading="loading" >登录</el-button>
      </el-form-item>
      <el-form-item  v-if="hasToken">
        <el-button class="logout-account-btn" type="default" @click="exitAccount">退出帐号</el-button>
      </el-form-item>
    </el-form>
<!--    <div class="loginFooter" @click="loginWithAccount">已有帐号密码登录</div>-->
  </div>
</template>

<script>
import { Form, FormItem } from 'element-ui'
import axios from 'axios'
import txcLogo from '../../../assets/image/txc-logo.png'
import logo from '../../../assets/image/logo.png'

// 手机号验证码登录缓存key
const TIM_SMS_LOGIN_INFO = 'tim_sms_login_info'

export default {
  name: 'SmsLogin',
  components: {
    ElForm: Form,
    ElFormItem: FormItem,
  },
  data() {
    return {
      privacy: false,
      hasToken: false,
      sessionID: '',
      canGetCode: true, // 控制获取验证码button
      sendCodeBtnText: '获取验证码',
      form: {
        phoneNum: '',
        verifyCode: '',
        areaCode: '86',
        userID: ''
      },
      rules: {},
      txcLogo: txcLogo,
      logo: logo,
      loading: false
    }
  },
  created () {
    let timSmsLoginInfo = localStorage.getItem(TIM_SMS_LOGIN_INFO)
    timSmsLoginInfo = timSmsLoginInfo ? JSON.parse(timSmsLoginInfo) : {}
    const { userID = '', token = '', loginTime = 0 } = timSmsLoginInfo
    // token 30天过期 设置29天时重新发送验证码，避免token过期时登录异常
    if (token && (loginTime + 29 * 24 * 60 * 60 * 1000 > Date.now())) {
      this.hasToken = true
      this.form.userID = userID
    } else {
      localStorage.removeItem(TIM_SMS_LOGIN_INFO)
      this.hasToken = false
    }
  },
  methods: {
    // 获取手机验证码
    getVerifyCode () {
      if (!this.form.areaCode || !this.form.phoneNum) {
        this.$store.commit('showMessage', {message: '请输入区号和手机号', type: 'warning'})
        return
      }
      if (this.canGetCode) {
        // 2079625916 图片验证码 AppID 后台提供
        // eslint-disable-next-line
        let captcha = new TencentCaptcha('2079625916',((res) => {
          if (res.ret === 0) {
            let ticket = res.ticket
            let randstr = res.randstr
            let phone = this.form.areaCode + this.form.phoneNum
            axios(`https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/smsImg?phone=${phone.trim()}&ticket=${ticket.trim()}&randstr=${randstr.trim()}`)
              .then((res) => {
                if (res.data.errorCode === 0) {
                  this.sessionID = res.data.data.sessionId
                  this.canGetCode = false
                  this.startCountDown()
                  return
                }
                this.handleLoginFail(res.data.errorCode)
              })
              .catch(() => {
                this.$store.commit('showMessage', {message: '发送验证码失败', type: 'error'})
              })
          }
        }))
        captcha.show()
      } else {
        this.$store.commit('showMessage', {message: '请输入区号和手机号', type: 'warning'})
      }
    },
    // 通过验证码获取IM登录凭证
    loginWithCode () {
      let phone = this.form.areaCode + this.form.phoneNum
      axios(`https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/demoSms?method=login&phone=${phone.trim()}&code=${this.form.verifyCode.trim()}&sessionId=${this.sessionID}`)
      .then((res) => {
        if (res.data.errorCode === 0) {
          const { token, phone, userId: userID, userSig } = res.data.data
          let timSmsLoginInfo = {
            loginTime: Date.now(),
            token: token,
            phone: phone,
            userID: userID
          }
          localStorage.setItem(TIM_SMS_LOGIN_INFO, JSON.stringify(timSmsLoginInfo))
          this.$store.commit({
            type: 'GET_USER_INFO',
            userID: userID,
            userSig: userSig,
            sdkAppID: this.$SDKAppID
          })
          this.timLogin(userID, userSig)
          return
        }
        this.handleLoginFail(res.data.errorCode)
      })
      .catch(() => {
        this.$store.commit('showMessage', { message: '获取签名失败', type: 'error' })
      })
    },
    // 通过token获取IM登录凭证
    loginWithToken () {
      let timSmsLoginInfo = localStorage.getItem(TIM_SMS_LOGIN_INFO)
      const { token, phone } = JSON.parse(timSmsLoginInfo)
      axios(`https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com/release/demoSms?method=login&phone=${phone}&token=${token}`)
      .then((res) => {
        if (res.data.errorCode === 0) {
          const { userId: userID, userSig } = res.data.data
          this.$store.commit({
            type: 'GET_USER_INFO',
            userID: userID,
            userSig: userSig,
            sdkAppID: this.$SDKAppID
          })
          this.timLogin(userID, userSig)
          return
        }
        this.handleLoginFail(res.data.errorCode)
      })
      .catch(() => {
        this.$store.commit('showMessage', { message: '操作异常', type: 'error' })
      })
    },
    // 倒计时
    startCountDown () {
      let time = 60 // 60s
      this.sendCodeBtnText = `${time}s`
      let timer = setInterval(() => {
        time--
        if (time < 0) {
          time = 0
          clearInterval(timer)
          this.canGetCode = true
        }
        this.sendCodeBtnText = `${time}s`
        if (this.canGetCode) {
          this.sendCodeBtnText = '获取验证码'
        }
      }, 1000)
    },
    // IM 登录
    timLogin (userID, userSig) {
      this.tim.login({
        userID: userID,
        userSig: userSig
      }).then(() => {
        this.loading = false
        this.$store.commit('toggleIsLogin', true)
        this.$store.commit('startComputeCurrent')
        this.$store.commit('showMessage', { message: '登录成功', type: 'success' })
      }).catch(() => {
        this.loading = false
        this.$store.commit('showMessage', { message: '登录失败', type: 'error' })
      })
    },
    // 登录
    login () {
      if (!this.privacy) {
        this.$store.commit('showMessage', {message: '请先勾选用户协议哦~', type: 'warning'})
        return
      }
      this.loading = true
      if (this.hasToken) {
        this.loginWithToken()
        return
      }
      this.loginWithCode()
    },
    // 处理登录失败的情况
    handleLoginFail (code) {
      this.loading = false
      let message = ''
      switch (code) {
        case -1001:
          message = '缺少参数'
          break
        case -1002:
          message = '手机号格式不对'
          break
        case -1003:
          message = '验证码发送失败'
          break
        case -1004:
          message = '方法名不存在'
          break
        case -1005:
          message = 'token错误'
          break
        case -1006:
          message = 'token已过期，输入短信验证码重新登录'
          break
        case -1007:
          message = '手机号与token不匹配'
          break
        case -1100:
          message = '验证码已失效'
          break
        case -1101:
          message = '验证码已过期'
          break
        case -1102:
          message = '验证码错误'
          break
        case -1103:
          message = 'sessionID不匹配'
          break
        case -1201:
          message = '该手机号尚未注册'
          break
        default:
          message = '操作异常'
          break
      }
      this.$store.commit('showMessage', { message: message, type: 'error' })
    },
    // 退出帐号
    exitAccount () {
      localStorage.removeItem(TIM_SMS_LOGIN_INFO)
      this.hasToken = false
    },
    // 切换为账号密码登录
    loginWithAccount () {
      this.$bus.$emit('changeLoginType', 2)
    }

  }
}
</script>

<style lang="stylus" scoped>
.login-wrapper
  display flex
  align-items center
  flex-direction column
  width 450px
  background $white
  color $black
  border-radius 5px
  box-shadow: 0 11px 20px 0 rgba(0,0,0,0.3)
  .row-div
    display flex
    justify-content center
    align-items center
    flex-direction row
  .logo
    width 110px
    height 110px
  .loginBox
    width 320px
    margin 0 0 20px 0
    .get-code-item
      position relative
      .send-code
        position absolute
        right 0
        top 0
        width 112px
        text-align center
        color #409EFF
        cursor pointer
      .counter
        color #777
        font-size 16px
    .login-im-btn,.logout-account-btn
      width 100%
  .loginFooter
    color: #8c8a8ac7
    text-align: center
    padding: 0 0 20px 0
    cursor: pointer
  /deep/ .el-input-group__prepend {
      border-left 0
      padding 0
      border 0
      /*border-radius 0*/
      .el-input__inner {
          border-top-right-radius 0
          border-bottom-right-radius 0
          border-top-left-radius 4px
          border-bottom-left-radius 4px
          border-right 0
          width 60px
      }
  }
  .privacy-text {
      margin-left 10px
      font-size 14px
      color #333
      & a {
          text-decoration: underline;
          color: #409EFF;
      }
  }

  /deep/ .el-input-group--prepend {
      border-top-right-radius: 0;
      border-bottom-right-radius: 0
  }
  /deep/ .el-checkbox__inner {
      width 20px
      height 20px
  }
 /deep/ .el-checkbox__inner::after {
     height 9px
     left 6px
     top 2px
     width 4px
 }
</style>
