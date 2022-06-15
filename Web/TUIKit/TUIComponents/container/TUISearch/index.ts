import TUISearchServer from './server';
import TUISearchComponent from './index.vue';

const install = (app: any) => {
  TUISearchComponent.TUIServer = TUISearch.server;
  app.component(TUISearch.name, TUISearchComponent);
};

const plugin = (TUICore: any) => {
  (TUISearch.server as any)  = new TUISearchServer(TUICore);
  TUICore.component(TUISearch.name, TUISearch);
  return TUISearch;
};

const TUISearch = {
  name: 'TUISearch',
  component: TUISearchComponent,
  server: TUISearchServer,
  install,
  plugin,
};

export default TUISearch;
