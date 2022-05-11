import { createStore } from 'vuex';

const taskList = [
  {
    id: 1,
    label: '发送一条消息',
    status: false,
  },
  {
    id: 2,
    label: '撤回一条消息',
    status: false,
  },
  {
    id: 3,
    label: '修改一次我的昵称',
    status: false,
  },
  {
    id: 4,
    label: '发起一个多人会话',
    status: false,
  },
  {
    id: 5,
    label: '开启一次群禁言',
    status: false,
  },
  {
    id: 6,
    label: '解散一个多人会话',
    status: false,
  },
];

const state:any = {
  taskList,
  userInfo: {},
};

if (localStorage.getItem('TUIKit-userInfo')) {
  const localUserInfoStorage:any = localStorage.getItem('TUIKit-userInfo') || {};
  state.userInfo = JSON.parse(localUserInfoStorage);
}

export default createStore({
  state,
  mutations: {
    handleTask(state, index:number) {
      state.taskList[index].status = true;
    },
    setUserInfo(state, userInfo:any) {
      state.userInfo = userInfo;
      localStorage.setItem('TUIKit-userInfo', JSON.stringify(userInfo));
    },
  },
  actions: {},
  modules: {},
});
