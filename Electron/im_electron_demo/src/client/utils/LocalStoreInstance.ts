import Store from 'electron-store';
import reduxStore from '../store';

const store = new Store();

export const  getData = (key) => store.get(key);
export const  setData = (key, data) => store.set(key, data);
export const  deleteData = (key) => store.delete(key)

export const updateHistoryMessageToStore = () => {
    const state = reduxStore.getState();
    const { userId, sdkappId  } = state.settingConfig;
    const isLogIn = state.login.isLogIn;
    if(!isLogIn) {
        return;
    }
    const historyMessage = state.historyMessage.historyMessageList;
    const storeKey = `${sdkappId}-${userId}`;
    let historyMessageObject = Array.from(historyMessage).reduce((obj, [key, value]) => (
        Object.assign(obj, { [key]: value })
      ), {});
    setData(storeKey, historyMessageObject);
};


export default store;