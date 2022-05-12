import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import store from './store';

// import TIM from "tim-js-sdk";

import { SDKAPPID }  from '../debug';

import ElementPlus from 'element-plus';
import 'element-plus/dist/index.css';

import locales from './locales';

// const options = {
//   SDKAppID: 1400187352 // 接入时需要将0替换为您的云通信应用的 SDKAppID，类型为 Number
// };
// const tim = TIM.create(options);

// import { TUIChat, TUIConversation } from './TUIKit/TUIComponents';
import { TUICore, TUIComponents } from './TUIKit';

const config = {
  SDKAppID: SDKAPPID,
  // tim,
};

const TUIKit = TUICore.init(config);

TUIKit.config.i18n.provideMessage(locales);

TUIComponents.TUIChat.removePluginComponents(['Custom', 'Location']);

// 组件挂载到 TUIKit
TUIKit.use(TUIComponents);

const app = createApp(App);

app.use(store).use(router)
  .use(TUIKit)
  .use(ElementPlus)
  .mount('#app');
