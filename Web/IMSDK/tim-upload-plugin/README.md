### 简介

腾讯云即时通信 IM 上传插件，用来上传图片、语音、视频、文件等类型的消息，支持 Web 和微信、QQ、百度、头条、支付宝小程序平台。

### 优势

使用 tim-upload-plugin 有以下4个优势：

- 应用数据更安全
- 上传文件速度较 cos-js-sdk 和 cos-wx-sdk 快10%~50%
- 同时支持 Web 和微信、QQ、百度、头条、支付宝小程序平台
- 体积非常小，仅26KB，对小程序应用更友好

### 注意事项

使用 tim-upload-plugin 需要注意以下2点：

- 使用前请将 [tim-js-sdk](https://www.npmjs.com/package/tim-js-sdk) 或 [tim-wx-sdk](https://www.npmjs.com/package/tim-wx-sdk) 升级到v2.9.2或更高版本
- 小程序端使用 tim-upload-plugin，在小程序管理后台增加 uploadFile 域名配置 `https://cos.ap-shanghai.myqcloud.com`，增加 downloadFile 域名配置 `https://cos.ap-shanghai.myqcloud.com`


### 使用方式

#### npm 引入

```javascript
// 下载依赖
npm i tim-upload-plugin --save
// tim-js-sdk 的版本请使用 v2.9.2 或更高版本才能集成 tim-upload-plugin
npm i tim-js-sdk@latest --save

// 在项目脚本里引入模块，并初始化
import TIM from 'tim-js-sdk';
import TIMUploadPlugin from 'tim-upload-plugin';

let options = {
  SDKAppID: 0 // 接入时需要将0替换为您的云通信应用的 SDKAppID，类型为 Number
};
// 创建 SDK 实例，`TIM.create()`方法对于同一个 `SDKAppID` 只会返回同一份实例
let tim = TIM.create(options); // SDK 实例通常用 tim 表示

// 设置 SDK 日志输出级别，详细分级请参见 setLogLevel 接口的说明
tim.setLogLevel(0); // 普通级别，日志量较多，接入时建议使用
// tim.setLogLevel(1); // release级别，SDK 输出关键信息，生产环境时建议使用

// 注册 COS SDK 插件
tim.registerPlugin({'tim-upload-plugin': TIMUploadPlugin});

```

#### script 标签引入
```javascript
<!-- tim-js.js 和 tim-upload-plugin.js 可以从 https://github.com/tencentyun/TIMSDK/tree/master/H5/sdk 获取 -->
<script src='./tim-js.js'></script>
<script src='./tim-upload-plugin.js'></script>
<script>
let options = {
  SDKAppID: 0 // 接入时需要将0替换为您的云通信应用的 SDKAppID，类型为 Number
};
// 创建 SDK 实例，`TIM.create()`方法对于同一个 `SDKAppID` 只会返回同一份实例
let tim = TIM.create(options);
// 设置 SDK 日志输出级别，详细分级请参见 setLogLevel 接口的说明
tim.setLogLevel(0); // 普通级别，日志量较多，接入时建议使用
// tim.setLogLevel(1); // release级别，SDK 输出关键信息，生产环境时建议使用

// 注册 COS SDK 插件
tim.registerPlugin({'tim-upload-plugin': TIMUploadPlugin});

// 接下来可以通过 tim 进行事件绑定和构建 IM 应用
</script>
```