module.exports = {
  presets: ['@vue/app'],
  ignore: ['sdk/**'],
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
