#### 腾讯云即时通信IM Electron API

基于腾讯云即时通信IM跨平台 C接口封装，接口与C接口保持一致。

#### 支持平台

Windows、Mac、Linux（uos）

#### 使用

```javascript
// 主进程
const TimMain = require('im_electron_sdk/dist/main')

const sdkappid = 0;// 可以去腾讯云即时通信IM控制台申请
const tim = new TimMain({
  sdkappid:sdkappid
})

//渲染进程

const TimRender = require('im_electron_sdk/dist/render')
const timRender = new TimRender();
// 初始化
timRender.TIMInit()
// 登录
timRender.TIMLogin({
  userID:"userID",
  userSig:"userSig" // 参考userSig生成
}).then(()=>{
  // success
}).catch(err=>{
  // error
})
// 其他api
```
#### 注意
1、多渲染进程使用sdk不能重复初始化和登录

#### 常见问题
- 使用vue-cli-plugin-electron-builder 构建的项目使用native modules 请参考[No native build was found for platform = xxx](https://github.com/nklayman/vue-cli-plugin-electron-builder/issues/1492)
- 自己使用webpack 构建的项目使用native modules 请参考[Windows 下常见问题](https://blog.csdn.net/Yoryky/article/details/106780254)
- Dynamic Linking Error. electron-builder 配置 
```javascript
   extraFiles:[
    {
      "from": "./node_modules/im_electron_sdk/lib/",
      "to": "./Resources",
      "filter": [
        "**/*"
      ]
    }
  ]
```

#### API列表


[完整文档](https://comm.qq.com/toc-electron-sdk-doc/index.html)

#### 关于文档

右侧manger/xxx 是各个API的文档
右侧interface/xxx 是各个API方法的interface，其中有各个参数的提醒注意事项


#### 其他

底层sdk版本：mac(5.7.1445)、windows(5.7.1445)、Linux(5.7.1445)

