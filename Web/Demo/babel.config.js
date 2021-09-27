module.exports = {
  presets: ['@vue/app'],
  ignore: ['sdk/**', '../TIMSDK-WEB/dist/tim-js-sdk'],
  plugins: [
    [
      'component',
      {
        libraryName: 'element-ui',
        styleLibraryName: 'theme-chalk'
      }
    ]
  ]
}
