import Vue from 'vue'
import Vuex from 'vuex'
import conversation from './modules/conversation'
import group from './modules/group'
import user from './modules/user'
import friend from './modules/friend'
import blacklist from './modules/blacklist'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    conversation,
    group,
    friend,
    blacklist,
    user
  },
})
