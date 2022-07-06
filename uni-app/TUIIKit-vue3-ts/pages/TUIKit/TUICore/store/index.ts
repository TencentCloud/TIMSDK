import { createStore, Store } from 'vuex';
// 持久化管理
import createPersistedstate from 'vuex-persistedstate'
import modules from './modules';
import { timState } from './modules/timStore';

export interface State {
  timStore: timState;
}

export default createStore <State>({
  modules
  })
  