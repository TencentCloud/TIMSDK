
import TUIChat from './container/TUIChat';
import TUIConversation from './container/TUIConversation';
import TUIProfile from './container/TUIProfile';
import TUIGroup from './container/TUIGroup';
import TUIContact from './container/TUIContact';
import TUISearch from './container/TUISearch';

const list = [
  TUIChat,
  TUIConversation,
  TUIProfile,
  TUIGroup,
  TUIContact,
  TUISearch,
];

/**
 * 组件挂载
 *
 * @param {app} app 挂载到主体
 */
const install = (app: any) => {
  list.forEach((component:any) => {
    component.install(app);
  });
};

/**
 * 组件注册到TUICore
 *
 * @param {TUICore} TUICore 主体TUICore
 */
const plugin = (TUICore: any) => {
  list.forEach((component:any) => {
    component.plugin(TUICore);
  });
};

const TUIComponents = {
  name: 'TUIComponents',
  version: '1.0.0',
  TUIChat,
  TUIConversation,
  TUIProfile,
  TUIGroup,
  TUIContact,
  TUISearch,
  install,
  plugin,
};

export default TUIComponents;

export {
  TUIChat,
  TUIConversation,
  TUIProfile,
  TUIGroup,
  TUIContact,
  TUISearch,
};
