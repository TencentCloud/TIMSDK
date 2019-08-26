import Vue from 'vue'
import { Message, MessageBox, Row, Col, Button, Input, Loading, Dialog } from 'element-ui'
import Avatar from './components/avatar.vue'
import Index from './index.vue'
import store from './store/index'
import tim from 'tim'
import TIM from 'tim-js-sdk'
import './assets/icon/iconfont.css'

window.tim = tim
window.store = store
window.$message = Message
Vue.prototype.$bus = new Vue() // event Bus 用于无关系组件间的通信。
Vue.prototype.tim = tim
Vue.prototype.TIM = TIM
Vue.prototype.$store = store
Vue.prototype.$message = Message
Vue.prototype.$confirm = MessageBox.confirm
Vue.use(Button)
Vue.use(Row)
Vue.use(Col)
Vue.use(Input)
Vue.use(Loading)
Vue.use(Dialog)
Vue.component('avatar', Avatar)
new Vue({
  render: h => h(Index)
}).$mount('#app')
