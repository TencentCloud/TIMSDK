## 什么是 uni-app TUIKit？
uni-app TUIKit 是基于 IM SDK 实现的一套 UI 组件，其包含会话、聊天、群组管理等功能，基于 UI 组件您可以像搭积木一样快速搭建起自己的业务逻辑。

目前我们提供了示例客服群、示例好友的基础模板，在线客服功能包括：
- 支持发送文本消息、图片消息、语音消息、视频消息等常见消息。
- 支持双人语音、视频通话功能。
- 支持常用语、订单、服务评价等自定义消息。
- 支持创建群聊会话、群成员管理等。

<table>
     <tr>
         <th style="text-align:center">会话列表界面</th>
         <th style="text-align:center">C2C 聊天界面</th>
		 <th style="text-align:center">群组聊天界面</th>
     </tr>
	 <tr>
	 <td style="text-align:center"><img src="https://qcloudimg.tencent-cloud.cn/raw/a4c7abfd6a58a54da955c151c9a4a9ef.jpeg" width="200"/></td>
	 <td style="text-align:center"><img src="https://qcloudimg.tencent-cloud.cn/raw/5931930a9061f55623a8e6cbff09e342.jpeg" width="200"/></td>
	 <td style="text-align:center"><img src="https://qcloudimg.tencent-cloud.cn/raw/32e3f7d32fa8a7b14052b82ac698e6ab.jpeg" width="200"/></td>
     </tr>
</table>

## uni-app TUIKit 支持平台
- Android
- iOS
- 微信小程序

## 技术栈
- vue2.x

## 如何集成 TUIKit？

## 快速搭建

### 步骤1：安装依赖
1. uni-app TUIKit 支持源码集成，下载 [uni-app TUIKit 源码](https://github.com/tencentyun/TIMSDK/tree/master)。将 TUIKit 文件夹与自己的工程文件夹置于同级，例如：
![](https://qcloudimg.tencent-cloud.cn/raw/096980f3029fae3e2750d4b77082cb55.png)
2. 根据 package.json 进行对应依赖安装。
![](https://qcloudimg.tencent-cloud.cn/raw/d0594851c404f6bb4c5ed30b1ab02359.png)

### 步骤2：初始化TUIKit
将 app.vue 中的代码复制到 myApplication 项目中，填写 SDKAppID。
![](https://qcloudimg.tencent-cloud.cn/raw/526abe7a9580e55262a99faa9d938238.png)

### 步骤3：集成静态资源文件
1. 在 myApplication 项目中集成静态资源文件 （工具、图片等）。
![](https://qcloudimg.tencent-cloud.cn/raw/fb8de22dac2e222b1e4f508865b416fa.png)
2. 在 myApplication 引入 mixins，用于实现 setData 等功能。
![](https://qcloudimg.tencent-cloud.cn/raw/05bb2cbe69432fcacf19919a694d67ac.png)

### 步骤4：集成所需模块
1. 将 pages 和 components 复制到 myApplication 项目中。
![](https://qcloudimg.tencent-cloud.cn/raw/2ca7b29c78e0d05779413cc2f49370b2.png)
2. 也可以只集成自己所需要的模块，将 pages 和其对应的 components 复制到 myApplication 项目目录下。
![](https://qcloudimg.tencent-cloud.cn/raw/19769b954a6448f3148275291515c5db.png)
 
### 步骤5：更新路由

根据页面更新路由：更新 pages.json  中的 pages 路由。
![](https://qcloudimg.tencent-cloud.cn/raw/40afe0526582a95c7d08008552534936.png)

### 步骤6：获取签名和登录
>! 
>- 正确的 `UserSig` 签发方式是将 `UserSig` 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 `UserSig` 时由您的 App 向业务服务器发起请求获取动态 `UserSig`。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

```javascript
uni.$TUIKit.login({userID: 'your userID', userSig: 'your userSig'})
.then(function(imResponse) {
  console.log(imResponse.data); // 登录成功
  if (imResponse.data.repeatLogin === true) {
    // 标识帐号已登录，本次登录操作为重复登录。v2.5.1 起支持
    console.log(imResponse.data.errorInfo);
  }
})
.catch(function(imError) {
  console.warn('login error:', imError); // 登录失败的相关信息
});

```

## 开启音视频通话
-  打包 App 集成，请参见原生音视频插件接入 [原生音视频插件](https://ext.dcloud.net.cn/plugin?id=7097)。
- 打包小程序集成 ，请参见小程序音视频插件接入 [腾讯云小程序音视频插件](https://ext.dcloud.net.cn/plugin?id=7151)。

## 常见问题
[](id:Q1)
### 1. uni-app  同时支持 Android，iOS， 微信小程序平台，IM SDK 如何选择？
请选择 `tim-wx-sdk` ，npm 安装或者静态引入：
```javascript
  // 从v2.11.2起，SDK 支持了 WebSocket，推荐接入；v2.10.2及以下版本，使用 HTTP
	 npm install tim-wx-sdk@latest --save
	import TIM from 'tim-wx-sdk';
	// 创建 SDK 实例，`TIM.create()`方法对于同一个 `SDKAppID` 只会返回同一份实例
	uni.$TUIKit = TIM.create({
		SDKAppID: 0  // 接入时需要将0替换为您的即时通信 IM 应用的 SDKAppID
	});
	
	// 设置 SDK 日志输出级别，详细分级请参见 setLogLevel 接口的说明
	uni.$TUIKit.setLogLevel(0); // 普通级别，日志量较多，接入时建议使用
	// uni.$TUIKit.setLogLevel(1); // release 级别，SDK 输出关键信息，生产环境时建议使用
```

如果您的项目需要关系链功能，请使用 `tim-wx-friendship.js`：
```javascript

	import TIM from 'tim-wx-sdk/tim-wx-friendship.js';
```

>?
>- **为了 uni-app 更好地接入使用 tim，快速定位和解决问题，请勿修改 uni.$TUIKit 命名，如果您已经接入 tim ，请将 uni.tim 修改为 uni.$TUIKit。**
>- 请将 IM SDK 升级到 [2.15.0](https://cloud.tencent.com/document/product/269/38492)，该版本支持了 iOS 语音播放。
>- 若同步依赖过程中出现问题，请切换 npm 源后再次重试。
```javascript
	切换 cnpm 源
	>npm config set registry http://r.cnpmjs.org/
	>
	>
```
[](id:Q2)
### 2. 如何上传图片、视频、语音消息等富媒体消息？
请使用 `cos-wx-sdk-v5`：
```javascript

  // 发送图片、语音、视频等消息需要 cos-wx-sdk-v5 上传插件
	npm install cos-wx-sdk-v5@0.7.11 --save
	import COS from "cos-wx-sdk-v5";
	// 注册 COS SDK 插件
	uni.$TUIKit.registerPlugin({
		'cos-wx-sdk': COS
	});
```

[](id:Q3)

### 3. uni-app  打包 app 发送语音消息时间显示错误怎么办？
   uni-app 打包 app，`recorderManager.onStop` 回调中没有 `duration` 和 `fileSize`，需要用户自己补充 duration 和 fileSize。
- **通过本地起定时器记录时间，计算出 duration。**
- **本地计算文件大小，fileSize ＝ (音频码率) x 时间长度(单位:秒) / 8，粗略估算。**
详细代码请参见 [uni-app TUIKit](https://github.com/tencentyun/TIMSDK/tree/master/uni-app)。
>!语音消息对象中必须包括 `duration` 和 `fileSize`，如果没有 `fileSize`，语音消息时长是一串错误的数字

[](id:Q4)
### 4. 微信小程序环境，真机预览，报系统错误，体积过大怎么办？
运行时请勾选代码压缩，运行到小程序模拟器>运行时是否压缩代码。

[](id:Q5)
### 5. 引入原生音视频插件报以下错怎么办？
![](https://qcloudimg.tencent-cloud.cn/raw/1ca0dd341e8258236a9265a9ba23f780.png)
根据 uni-app [原生插件调试](https://ask.dcloud.net.cn/article/35412)制作[自定义基座](https://ask.dcloud.net.cn/article/35115)
![](https://qcloudimg.tencent-cloud.cn/raw/5957ce797f77f3101156cb63c3622633.png)

[](id:Q6)
### 6. uni-app 是否支持离线推送？
 开发中，计划7月推出...	敬请期待～

[](id:Q7)
### 7. vue2 版本 TUIKit 会持续更新吗？
 我们会持续优化体验，更多的功能会在vue3 版本持续迭代～
 
[](id:Q8)
### 7. 微信小程序如果需要上线或者部署正式环境怎么办？
请在**微信公众平台**>**开发**>**开发设置**>**服务器域名**中进行域名配置：

将以下域名添加到 **request 合法域名**：

从v2.11.2起 SDK 支持了 WebSocket，WebSocket 版本须添加以下域名：

| 域名 | 说明 |  是否必须 |
|:-------:|---------|----|
|`wss://wss.im.qcloud.com`| Web IM 业务域名 | 必须|
|`wss://wss.tim.qq.com`| Web IM 业务域名 | 必须|
|`https://web.sdk.qcloud.com`| Web IM 业务域名 | 必须|
|`https://webim.tim.qq.com` | Web IM 业务域名 | 必须|

v2.10.2及以下版本使用 HTTP，HTTP 版本须添加以下域名：

| 域名 | 说明 |  是否必须 |
|:-------:|---------|----|
|`https://webim.tim.qq.com` | Web IM 业务域名 | 必须|
|`https://yun.tim.qq.com` | Web IM 业务域名 | 必须|
|`https://events.tim.qq.com` | Web IM 业务域名 | 必须|
|`https://grouptalk.c2c.qq.com`| Web IM 业务域名 | 必须|
|`https://pingtas.qq.com` | Web IM 统计域名 | 必须|

将以下域名添加到 **uploadFile 合法域名**：

| 域名 | 说明 |  是否必须 |
|:-------:|---------|----|
|`https://cos.ap-shanghai.myqcloud.com` | 文件上传域名 | 必须|

将以下域名添加到 **downloadFile 合法域名**：

| 域名 | 说明 |  是否必须 |
|:-------:|---------|----|
|`https://cos.ap-shanghai.myqcloud.com` | 文件下载域名 | 必须|

 
[](id:QQ)
## 技术咨询
了解更多详情您可 QQ 咨询：<dx-tag-link link="#QQ" tag="技术交流群">309869925</dx-tag-link>

## 参见
## 文档
- [SDK API 手册](https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html)
- [SDK 更新日志](https://cloud.tencent.com/document/product/269/38492)
- [uni-app TUIKit 源码](https://github.com/tencentyun/TIMSDK/tree/master/uni-app)
- [一分钟跑通 Demo (uni-app）](https://cloud.tencent.com/document/product/269/64506)
- [快速集成微信小程序原生 TUIKit](https://cloud.tencent.com/document/product/269/62766)
- [微信小程序原生 TUIKit 源码](https://github.com/tencentyun/TIMSDK/tree/master/MiniProgram)