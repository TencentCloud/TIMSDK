import Vue from 'mpvue'
import TIMApp from './App'
import TIM from 'tim-wx-sdk'
import store from './store/index'

import COS from 'cos-wx-sdk-v5'
import { SDKAPPID } from '../static/utils/GenerateTestUserSig'
import TYPES from './utils/types'
const tim = TIM.create({
  SDKAppID: SDKAPPID
})
tim.setLogLevel(0)
wx.$app = tim
wx.$app.registerPlugin({'cos-wx-sdk': COS})

let $bus = new Vue()
Vue.prototype.TIM = TIM
Vue.prototype.$type = TYPES
Vue.prototype.$store = store
Vue.prototype.$bus = $bus

tim.on(TIM.EVENT.SDK_READY, onReadyStateUpdate, this)
tim.on(TIM.EVENT.SDK_NOT_READY, onReadyStateUpdate, this)

tim.on(TIM.EVENT.KICKED_OUT, event => {
  store.commit('resetGroup')
  store.commit('resetUser')
  store.commit('resetCurrentConversation')
  store.commit('resetAllConversation')
  wx.showToast({
    title: '你已被踢下线',
    icon: 'none',
    duration: 1500
  })
  setTimeout(() => {
    wx.clearStorage()
    wx.reLaunch({
      url: '../login/main'
    })
  }, 1500)
})

// 出错统一处理
tim.on(TIM.EVENT.ERROR, event => {
  // 网络错误不弹toast && sdk未初始化完全报错
  if (event.data.code !== 2800 && event.data.code !== 2999) {
    store.commit('showToast', {
      title: event.data.message,
      duration: 2000
    })
  }
})

tim.on(TIM.EVENT.MESSAGE_RECEIVED, event => {
  store.dispatch('onMessageEvent', event)
})
tim.on(TIM.EVENT.CONVERSATION_LIST_UPDATED, event => {
  store.commit('updateAllConversation', event.data)
})
tim.on(TIM.EVENT.GROUP_LIST_UPDATED, event => {
  store.commit('updateGroupList', event.data)
})
tim.on(TIM.EVENT.BLACKLIST_UPDATED, event => {
  store.commit('updateBlacklist', event.data)
})

tim.on(TIM.EVENT.GROUP_SYSTEM_NOTICE_RECEIVED, event => {
  console.log('system message', event)
})

function onReadyStateUpdate ({ name }) {
  const isSDKReady = (name === TIM.EVENT.SDK_READY)
  if (isSDKReady) {
    wx.hideLoading()
    wx.switchTab({
      url: '../index/main'
    })
  }
  store.commit('setSdkReady', isSDKReady)
}

new Vue({
  TIMApp
}).$mount()
