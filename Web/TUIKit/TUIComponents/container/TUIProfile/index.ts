import TUIProfileServer from './server';
import TUIProfileComponent from './index.vue';

const install = (app: any) => {
  TUIProfileComponent.TUIServer = TUIProfile.server;
  app.component(TUIProfile.name, TUIProfileComponent);
};

const plugin = (TUICore: any) => {
  (TUIProfile.server as any)  = new TUIProfileServer(TUICore);
  TUICore.component(TUIProfile.name, TUIProfile);
  return TUIProfile;
};

const TUIProfile = {
  name: 'TUIProfile',
  component: TUIProfileComponent,
  server: TUIProfileServer,
  install,
  plugin,
};

export default TUIProfile;
