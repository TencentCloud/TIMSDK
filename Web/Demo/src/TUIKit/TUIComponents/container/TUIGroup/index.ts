import TUIGroupServer from './server';
import TUIGroupComponent from './index.vue';

const install = (app: any) => {
  TUIGroupComponent.TUIServer = TUIGroup.server;
  app.component(TUIGroup.name, TUIGroupComponent);
};

const plugin = (TUICore: any) => {
  (TUIGroup.server as any)  = new TUIGroupServer(TUICore);
  TUICore.component(TUIGroup.name, TUIGroup);
  return TUIGroup;
};

const TUIGroup = {
  name: 'TUIGroup',
  component: TUIGroupComponent,
  server: TUIGroupServer,
  install,
  plugin,
};

export default TUIGroup;
