

const data = {
  theme: 'dark',
};

function plugin(TUICore:any) {
  TUICore.setCommonStore(data);
}

function install(app:any) {
  console.log('app', app);
}

const TUIColor = {
  name: 'TUITheme',
  plugin,
  install,
};

export default TUIColor;
