import TUIConversationServer from './server';
import TUIConversationComponent from './index.vue';

const install = (app: any) => {
  TUIConversationComponent.TUIServer = TUIConversation.server;
  app.component(TUIConversation.name, TUIConversationComponent);
};

const plugin = (TUICore: any) => {
  (TUIConversation.server as any)  = new TUIConversationServer(TUICore);
  TUICore.component(TUIConversation.name, TUIConversation);
  return TUIConversation;
};

const TUIConversation = {
  name: 'TUIConversation',
  component: TUIConversationComponent,
  server: TUIConversationServer,
  install,
  plugin,
};

export default TUIConversation;
