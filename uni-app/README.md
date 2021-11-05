## 腾讯云即时通信 IM 跨平台利器 ---  uni-app TUIKit
基于 Web IM SDK 在 HBuilderX 中编译 Android、iOS 应用以及小程序应用，可实现一套代码多端打包。

### uni-app TUIKit  在线客服场景

提供了示例客服群 ➕ 示例好友的基础模版，在线客服场景功能包括：
- 支持发送文本消息、图片消息、语音消息、视频消息等常见消息。
- 支持常用语、订单、服务评价等自定义消息。
- 支持创建群聊会话、群成员管理等。

### uni-app TUIKit 支持平台
- 安卓
- iOS
- 微信小程序

### 效果展示：
<table>
<tr>
   <th>安卓演示：</th>
   <th>iOS 演示：</th>
   <th>微信小程序演示：</th>
 </tr>
<tr>
<td><img src="TUIKit/android-uniapp.gif" height = "400"/></td>
<td><img src="TUIKit/ios-uniapp.gif" height = "400"/></td>
<td><img src="TUIKit/wx-uniapp.gif" height = "400"/></td>
</tr>
</table>

### 快速跑通 uni-app TUIKit

#### 步骤1：注册并创建 uni-app 账号

搭建 app 开发环境
- 1、下载 [HBuilderX 编辑器 ](https://www.dcloud.io/hbuilderx.html)

>!
> 项目中 HBuilderX 目前使用的最新版本，如果此前下载过 HBuilderX，为保证开发环境统一请更新到最新版本。
>

- 2、[DCloud 开发者中心注册](https://dev.dcloud.net.cn/)之后登陆 HBuilderX 编辑器

#### 步骤2：创建应用
1. 登录 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)。
>!如果您已有应用，请记录其 SDKAppID 并 [获取密钥信息](#step2)。
>同一个腾讯云账号，最多可创建100个即时通信 IM 应用。若已有100个应用，您可以先 [停用并删除](https://cloud.tencent.com/document/product/269/32578#.E5.81.9C.E7.94.A8.2F.E5.88.A0.E9.99.A4.E5.BA.94.E7.94.A8) 无需使用的应用后再创建新的应用。**应用删除后，该 SDKAppID 对应的所有数据和服务不可恢复，请谨慎操作。**
>
2. 单击**+添加新应用**。
3. 在**创建应用**对话框中输入您的应用名称，单击**确定**。
  创建完成后，可在控制台总览页查看新建应用的状态、业务版本、SDKAppID、创建时间以及到期时间。
  请记录 SDKAppID 信息。
  
  ![](https://main.qcloudimg.com/raw/2753962b67754a9ebb2a2a5b8042f2ef.png)

4. 获取密钥信息。
- 单击目标应用卡片，进入应用的基础配置页面。
- 在**基本信息**区域，单击**显示密钥**，复制并保存密钥信息。
>!请妥善保管密钥信息，谨防泄露。


#### 步骤3：下载并配置 uni-app TUIKit  源码

1. 下载 uni-app TUIKit 代码。

```javascript
# 命令行执行
git clone https://github.com/tencentyun/TIMSDK.git

# 进入 uni-app TUIKit 项目
cd TIMSDK/uni-app/TUIKit
```

2. 将 uni-app TUIKit 工程文件，导入自己的 HBuilderX 工程（版本3.2.11.20211021-alpha）。

     请参考官方 [uni-app 开发](https://uniapp.dcloud.io/quickstart-hx)

3. 设置 GenerateTestUserSig 文件中的相关参数。

- 找到并打开 `debug/GenerateTestUserSig.js` 文件。
- 设置 `GenerateTestUserSig.js` 文件中的相关参数。
  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul> 
  <img src="https://main.qcloudimg.com/raw/575902219de19b4f2d4595673fa755d4.png">

>! 注意
>- 本文提到的生成 `UserSig` 的方案是在客户端代码中配置 `SECRETKEY`，该方法中 `SECRETKEY` 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 uni-app 和功能调试**。
>- 正确的 `UserSig` 签发方式是将 `UserSig` 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 `UserSig` 时由您的 App 向业务服务器发起请求获取动态 `UserSig`。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

####  步骤4：编译运行

 请参考官方 [uni-app 运行](https://uniapp.dcloud.io/quickstart-hx?id=%e8%bf%90%e8%a1%8cuni-app)

####  步骤5：打包发布

 请参考官方 [uni-app 打包](https://uniapp.dcloud.io/quickstart-hx?id=%e5%8f%91%e5%b8%83uni-app)
- 原生App-云打包：HBuilderX 编辑器 → 发行 → 原生 App-云打包 （app图标，启动页等详细配置可在 manifest.json 进行配置）。
- 原生App-离线打包：HBuilderX 编辑器 → 发行 → 生成本地打包 App 资源 （详细打包方案请看 iOS、Android 本地打包指南）。

### 常见问题

**1. uni-app TUIKit 同时支持安卓，iOS， 微信小程序平台，im sdk 如何选择？**

   请选择 `tim-wx-sdk` ，npm 安装或者静态引入

```javascript
    // 从v2.11.2起，SDK 支持了 WebSocket，推荐接入；v2.10.2及以下版本，使用 HTTP
	npm install tim-wx-sdk@2.15.0 --save
	import TIM from 'tim-wx-sdk';
	// 创建 SDK 实例，`TIM.create()`方法对于同一个 `SDKAppID` 只会返回同一份实例
	uni.$TUIKit = TIM.create({
		SDKAppID: 0  // 接入时需要将0替换为您的即时通信 IM 应用的 SDKAppID
	});
	
	// 设置 SDK 日志输出级别，详细分级请参见 setLogLevel 接口的说明
	uni.$TUIKit.setLogLevel(0); // 普通级别，日志量较多，接入时建议使用
	// uni.$TUIKit.setLogLevel(1); // release 级别，SDK 输出关键信息，生产环境时建议使用
```
  如果您的项目需要关系链功能，请使用 `tim-wx-friendship.js`

```javascript
	import TIM from 'tim-wx-sdk/tim-wx-friendship.js';
```
>！
>- 请将im sdk 升级到 [2.15.0](https://cloud.tencent.com/document/product/269/38492)，该版本支持了iOS 语音播放
>- 若同步依赖过程中出现问题，请切换 npm 源后再次重试。
```javascript
	切换 cnpm 源
	>npm config set registry http://r.cnpmjs.org/
	>
	>
```


**2. 如何上传图片、视频、语音消息等富媒体消息？**

   请使用 `cos-wx-sdk-v5`
```javascript
    // 发送图片、语音、视频等消息需要 cos-wx-sdk-v5 上传插件
	npm install cos-wx-sdk-v5@0.7.11 --save
	import COS from "cos-wx-sdk-v5";
	// 注册 COS SDK 插件
	uni.$TUIKit.registerPlugin({
		'cos-wx-sdk': COS
	});
```

**3. uni-app TUIKit 打包 iOS 语音消息无法播放怎么办？**

  请将 im sdk 升级到 [2.15.0](https://cloud.tencent.com/document/product/269/38492)，该版本支持了iOS 语音消息播放

**4. uni-app TUIKit 打包 app 发送语音消息时间显示错误怎么办？**

   uni-app 打包 app，`recorderManager.onStop` 回调中没有 `duration` 和 `fileSize`，<font color=red>需要用户自己补充 duration 和 fileSize
   <ul>   <li>通过本地起定时器记录时间，计算出 duration </li>
   <li>本地计算文件大小，fileSize ＝ (音频码率) x 时间长度(单位:秒) / 8，粗略估算。</li></ul>
   </font>
 详细代码请参考 [uni-app TUIKit](https://github.com/tencentyun/TIMSDK/tree/master/uni-app)
>！
>- 语音消息对象中必须包括 `duration` 和 `fileSize`，如果没有 `fileSize`，语音消息时长是一串错误的数字

  


**5、video 视频消息层级过高无法滑动怎么办？**

  在项目中通过视频图片代替，没有直接渲染 `video`，在播放时渲染的方式规避了层级过高问题
  详细代码请参考 [uni-app TUIKit](https://github.com/tencentyun/TIMSDK/tree/master/uni-app)
>！
官方 [原生组件说明](https://uniapp.dcloud.io/component/native-component)
>

**6、微信小程序环境，真机预览，报系统错误，体积过大怎么办？**

运行时请勾选代码压缩，运行到小程序模拟器 =》运行时是否压缩代码

**7、微信小程序如果需要上线或者部署正式环境怎么办？**

请在**微信公众平台**>**开发**>**开发设置**>**服务器域名**中进行域名配置：

将以下域名添加到 **request 合法域名**：

从v2.11.2起，SDK 支持了 WebSocket，WebSocket 版本须添加以下域名：

| 域名 | 说明 |  是否必须 |
|:-------:|---------|----|
|`wss://wss.im.qcloud.com`| Web IM 业务域名 | 必须|
|`wss://wss.tim.qq.com`| Web IM 业务域名 | 必须|
|`https://web.sdk.qcloud.com`| Web IM 业务域名 | 必须|
|`https://webim.tim.qq.com` | Web IM 业务域名 | 必须|

v2.10.2及以下版本，使用 HTTP，HTTP 版本须添加以下域名：

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

### 参考文档：

- [SDK API 手册](https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html)
- [SDK 更新日志](https://cloud.tencent.com/document/product/269/38492)
- [快速集成微信小程序原生 TUIKit](https://cloud.tencent.com/document/product/269/62766)
- [微信小程序原生 TUIKit 源码](https://github.com/tencentyun/TIMSDK/tree/master/MiniProgram)
