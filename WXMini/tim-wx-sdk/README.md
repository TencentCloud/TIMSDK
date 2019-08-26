本文主要介绍如何快速地将腾讯云 IM SDK 集成到您的 Web 或者小程序项目中，只要按照如下步骤进行配置，就可以完成 SDK 的集成工作。

## 准备工作
在集成 Web SDK 前，请确保您已完成以下步骤，请参见 [一分钟跑通 Demo](https://cloud.tencent.com/document/product/269/36838)。
- 创建了腾讯云即时通信 IM 应用，并获取到 SDKAppID。
- 获取密钥信息。

## 集成 SDK
您可以通过以下方式集成 SDK：

### NPM 集成
在您的项目中使用 npm 安装相应的 IM SDK 依赖。

#### Web 项目：
```javascript
// IM Web SDK
npm install tim-js-sdk --save
// 发送图片、文件等消息需要的 COS SDK
npm install cos-js-sdk-v5 --save
```

在项目脚本里引入模块，并初始化。

```javascript
import TIM from 'tim-js-sdk';
import COS from "cos-js-sdk-v5";

let options = {
  SDKAppID: 0 // 接入时需要将 0 替换为您的云通信应用的 SDKAppID
};
// 创建 SDK 实例，`TIM.create()`方法对于同一个 `SDKAppID` 只会返回同一份实例
let tim = TIM.create(options); // SDK 实例通常用 tim 表示

// 设置 SDK 日志输出级别为 release 级别（详细分级请参考 setLogLevel 接口的说明）
tim.setLogLevel(1);

// 注册 COS SDK 插件
tim.registerPlugin({'cos-js-sdk': COS});
```

#### 小程序项目：
```javascript
// IM 小程序 SDK
npm install tim-wx-sdk --save
// 发送图片、文件等消息需要的 COS SDK
npm install cos-wx-sdk-v5 --save
```
在项目脚本里引入模块，并初始化。

```javascript
import TIM from 'tim-wx-sdk';
import COS from "cos-wx-sdk-v5";

let options = {
  SDKAppID: 0 // 接入时需要将 0 替换为您的云通信应用的 SDKAppID
};
// 创建 SDK 实例，`TIM.create()`方法对于同一个 `SDKAppID` 只会返回同一份实例
let tim = TIM.create(options); // SDK 实例通常用 tim 表示

// 设置 SDK 日志输出级别为 release 级别（详细分级请参考 setLogLevel 接口的说明）
tim.setLogLevel(1);

// 注册 COS SDK 插件
tim.registerPlugin({'cos-wx-sdk': COS});

// 接下来可以通过 tim 进行事件绑定和构建 IM 应用
```

更详细的初始化流程请看 [SDK 初始化例子](https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html)

### Script 集成
在您的项目中使用 script 标签引入 SDK，并初始化。

#### 相关资源
- IM Web SDK 下载地址：[IM Web SDK](https://github.com/tencentyun/TIMSDK/tree/master/H5)
- 腾讯云 COS JS SDK 源码下载地址：[腾讯云 COS JS SDK](https://github.com/tencentyun/cos-js-sdk-v5)

```html
<script src="./tim.min.js"></script>
<script src="./cos-js-sdk-v5.min.js"></script>
<script>
var options = {
  SDKAppID: 0 // 接入时需要将 0 替换为您的云通信应用的 SDKAppID
};
// 创建 SDK 实例，`TIM.create()`方法对于同一个 `SDKAppID` 只会返回同一份实例
var tim = TIM.create(options);
// 设置 SDK 日志输出级别为 release 级别（详细分级请参考 setLogLevel 接口的说明）
tim.setLogLevel(1);

// 注册 COS SDK 插件
tim.registerPlugin({'cos-wx-sdk': COS});

// 接下来可以通过 tim 进行事件绑定和构建 IM 应用
</script>
```

更详细的初始化流程请看 [SDK 初始化例子](https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html)