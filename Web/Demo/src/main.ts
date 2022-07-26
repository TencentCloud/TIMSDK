import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import store from './store';

// import TIM from "tim-js-sdk";

import { SDKAPPID } from '../debug';

import ElementPlus from 'element-plus';
import 'element-plus/dist/index.css';

import locales from './locales';

// const options = {
//   SDKAppID: 1400187352 // 接入时需要将0替换为您的云通信应用的 SDKAppID，类型为 Number
// };
// const tim = TIM.create(options);

// import { TUIChat, TUIConversation } from './TUIKit/TUIComponents';
import { TUICore, TUIComponents } from './TUIKit';

import TUIAegis from './utils/TUIAegis';
const Aegis = TUIAegis.getInstance();
(window as any).$Aegis = Aegis;

Aegis.reportEvent({
  name: 'mounted',
  ext1: 'mounted-success',
});

const config = {
  SDKAppID: SDKAPPID,
  // tim,
};

const TUIKit = TUICore.init(config);
if (TUIKit.TUIEnv.isH5) {
  Aegis.setAegisOptions({
    ext2: 'TUIKitH5',
    ext3: SDKAPPID,
  });
} else {
  Aegis.setAegisOptions({
    ext2: 'TUIKitWeb',
    ext3: SDKAPPID,
  });
}
TUIKit.config.i18n.provideMessage(locales);

// 方法一: 按需挂载
// TUIKit.component(TUIChat.name, TUIChat);
// TUIKit.component(TUIConversation.name, TUIConversation);

TUIComponents.TUIChat.removePluginComponents(['Custom', 'Location']);

// 方法二: 全部挂载
TUIKit.use(TUIComponents);

const app = createApp(App);

// app.component(TUIChat.name, TUIChat.component);
// app.component(TUIConversation.name, TUIConversation.component);


app
  .use(store)
  .use(router)
  .use(TUIKit)
  .use(Aegis)
  .use(ElementPlus)
  .mount('#app');
