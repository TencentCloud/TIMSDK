import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
import store from './store';


import { SDKAPPID }  from '../debug';

import ElementPlus from 'element-plus';
import 'element-plus/dist/index.css';

import locales from './locales';

import { TUICore, TUIComponents } from './TUIKit';

const config = {
  SDKAppID: SDKAPPID,
};

const TUIKit = TUICore.init(config);

TUIKit.config.i18n.provideMessage(locales);

TUIComponents.TUIChat.removePluginComponents(['Custom', 'Location']);

// component plugin in TUIKit
TUIKit.use(TUIComponents);

const app = createApp(App);

app.use(store).use(router)
  .use(TUIKit)
  .use(ElementPlus)
  .mount('#app');
