import Vue from 'vue'
import { MessageBox, Row, Col, Button, Input, Loading, Dialog, Dropdown, DropdownMenu, DropdownItem, Checkbox, CheckboxGroup } from 'element-ui'
import Avatar from './components/avatar.vue'
import Index from './index.vue'
import store from './store/index'
import tim from 'tim'
import TIM from 'tim-js-sdk'
import TWebLive from 'tweblive'
import VueClipboard from 'vue-clipboard2'
import './assets/icon/iconfont.css'
import './assets/icon/tim.css'
import trtcCalling from './trtc-calling'
import TRTCCalling from 'trtc-calling-js'

window.tim = tim
window.TIM = TIM
window.TRTCCalling = TRTCCalling
window.trtcCalling = trtcCalling
window.store = store
Vue.prototype.$bus = new Vue() // event Bus 用于无关系组件间的通信。
Vue.prototype.tim = tim
Vue.prototype.TIM = TIM
Vue.prototype.TWebLive = TWebLive
Vue.prototype.$store = store
Vue.prototype.$confirm = MessageBox.confirm
Vue.prototype.trtcCalling = trtcCalling
Vue.prototype.TRTCCalling = TRTCCalling
Vue.use(Button)
Vue.use(Row)
Vue.use(Col)
Vue.use(Input)
Vue.use(Loading)
Vue.use(Dialog)
Vue.use(Dropdown)
Vue.use(DropdownMenu)
Vue.use(DropdownItem)
Vue.use(VueClipboard)
Vue.use(Checkbox)
Vue.use(CheckboxGroup)
Vue.component('avatar', Avatar)
new Vue({
  render: h => h(Index)
}).$mount('#app')
