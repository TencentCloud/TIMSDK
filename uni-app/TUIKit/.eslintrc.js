module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: ['eslint-config-tencent'],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module',
  },
  globals: {
    __DEV__: true,
    __WECHAT__: true,
    __ALIPAY__: true,
    App: true,
    Page: true,
    Component: true,
    Behavior: true,
    wx: true,
    qq: true,
    module: true,
    getApp: true,
    getCurrentPages: true,
  },
  rules: {
    // allow paren-less arrow functions
    'arrow-parens': 0,
    // allow async-await
    'generator-star-spacing': 0,
    // allow debugger during development
    'no-debugger': process.env.NODE_ENV === 'production' ? 2 : 0,
    'quotes': ['error', 'single'],
    'semi': ['error', 'never'],
  },
}
