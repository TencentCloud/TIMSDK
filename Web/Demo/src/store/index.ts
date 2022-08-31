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
    label: '发起一个群聊',
    status: false,
  },
  {
    id: 5,
    label: '开启一次群禁言',
    status: false,
  },
  {
    id: 6,
    label: '解散一个群聊',
    status: false,
  },
];

const state: any = {
  taskList,
  userInfo: {},
  needReadReceipt: true,
};

if (localStorage.getItem('TUIKit-userInfo')) {
  const localUserInfoStorage: any = localStorage.getItem('TUIKit-userInfo') || {};
  try {
    state.userInfo = JSON.parse(localUserInfoStorage);
  } catch (error) {
    state.userInfo = {};
  }
}

if (sessionStorage.getItem('needReadReceipt')) {
  const localNeedReadReceipt: string = sessionStorage.getItem('needReadReceipt') || '';
  try {
    state.needReadReceipt = JSON.parse(localNeedReadReceipt);
  } catch (error) {
    state.needReadReceipt = false;
  }
}

export default createStore({
  state,
  mutations: {
    handleTask(state, index: number) {
      state.taskList[index].status = true;
    },
    setUserInfo(state, userInfo: any) {
      state.userInfo = userInfo;
      localStorage.setItem('TUIKit-userInfo', JSON.stringify(userInfo));
    },
    setNeedReadReceipt(state, needReadReceipt: boolean) {
      state.needReadReceipt = needReadReceipt;
      sessionStorage.setItem('needReadReceipt', JSON.stringify(needReadReceipt));
    },
  },
  actions: {},
  modules: {},
});
