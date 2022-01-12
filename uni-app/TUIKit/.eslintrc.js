module.exports = {
  env: {
    // 启用的环境
    browser: true,
    es6: true,
    node: true,
  },
  extends: ['eslint-config-tencent'], // 规范@tencent/eslint-config-tencent
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
  parser: '@babel/eslint-parser',
  parserOptions: {
    ecmaVersion: 'latest', // 最近的解析器解析
    sourceType: 'module',
  },
  rules: {
    indent: ['error', 2, { SwitchCase: 1 }], // 缩进
    semi: ['error'],
    'no-unused-vars': [
      // 禁止出现未使用过的变量
      'error',
      {
        args: 'none', // 不检查参数
      },
    ],
    // 要求构造函数首字母大写 （要求调用 new 操作符时有首字母大小的函数，允许调用首字母大写的函数时没有 new 操作符。）
    'new-cap': [
      2,
      {
        newIsCap: true, // 要求调用 `new` 操作符时有首字母大小的函数
        capIsNew: false, // 允许调用首字母大写的函数时没有 `new` 操作符
      },
    ],
    'no-console': 'off', // 禁用 console
    'no-empty': 'warn', // 禁止出现空语句块
    'linebreak-style': 'off', // 强制使用一致的换行风格
    'require-jsdoc': 'off',
    'max-len': [
      'warn',
      {
        code: 160,
        ignoreComments: true, // 忽略所有拖尾注释和行内注释
        ignoreUrls: true, // 忽略含有链接的行
      },
    ],
    'valid-jsdoc': [
      'warn',
      {
        prefer: {
          return: 'returns', // instead of @return use @returns
        },
        requireReturn: false, // if and only if the function or method has a return statement or returns a value e.g.
        requireReturnDescription: false, // allows missing description in return tags
      },
    ],
    'object-curly-spacing': [
      'error',
      'always', // 要求花括号内有空格
    ],
    eqeqeq: [
      'error',
      'always', // enforces the use of === and !== in every situation
    ],
    'no-alert': 'error', // 禁止使用alert confirm prompt
    'no-nested-ternary': 'error', // 禁止使用嵌套的三目运算
    'space-unary-ops': [
      'error',
      {
        words: true, // 一元操作符，例如：new、delete、typeof、void、yield 后需要有空格
        nonwords: false, // 一元操作符: -、+、--、++、!、!! 前不能有空格
      },
    ],
    'key-spacing': [
      'error',
      {
        mode: 'strict', // enforces exactly one space before or after colons in object literals. 禁止对齐
        beforeColon: false, // disallows spaces between the key and the colon in object literals
        afterColon: true, // requires at least one space between the colon and the value in object literals
      },
    ],
    'space-infix-ops': 'error', // 中缀操作符周围有空格
    'no-else-return': [
      // If an if block contains a return statement, the else block becomes unnecessary. Its contents can be placed outside of the block.
      'error',
      {
        allowElseIf: false, // disallows else if blocks after a return
      },
    ],
    'prefer-rest-params': 'off', // 用arguments没什么不好的
    'guard-for-in': 'error', // for in时需检测hasOwnProperty，避免遍历到继承来的属性方法
    'prefer-spread': 'off', // 用apply也挺好的，es2015的spread syntax不是个必选项
  },
};
