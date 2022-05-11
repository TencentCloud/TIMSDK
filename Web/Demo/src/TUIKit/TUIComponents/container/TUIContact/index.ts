import TUIContactServer from './server';
import TUIContactComponent from './index.vue';

const install = (app: any) => {
  TUIContactComponent.TUIServer = TUIContact.server;
  app.component(TUIContact.name, TUIContactComponent);
};

const plugin = (TUICore: any) => {
  (TUIContact.server as any)  = new TUIContactServer(TUICore);
  TUICore.component(TUIContact.name, TUIContact);
  return TUIContact;
};

const TUIContact = {
  name: 'TUIContact',
  component: TUIContactComponent,
  server: TUIContactServer,
  install,
  plugin,
};

export default TUIContact;
