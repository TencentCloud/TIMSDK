### 项目简介

TUIKit 基于小程序原生开发，我们提供了 IM 聊天、在线客服、实时音视频通话等开源组件，开发者可以在这些组件的基础上灵活自定义修改。

### 效果展示

![](https://web.sdk.qcloud.com/component/TUIKit/assets/tuikit-github-1.jpg)

###  一分钟跑通 TUIKit

#### 步骤1：克隆仓库到本地

```javascript

# 命令行执行
git clone https://github.com/tencentyun/TIMSDK.git

# 进入小程序 TUIKit 项目
cd TIMSDK/MiniProgram/TUIKit

```

#### 步骤2：安装微信小程序 [开发者工具](https://mp.weixin.qq.com/debug/wxadoc/dev/devtools/download.html)。

#### 步骤3：使用微信开发者工具导入项目，然后填入自己的小程序 AppID。

>!即时通信 IM 属于增值服务，详细计费规则请参见 [即时通信 IM 价格说明](https://cloud.tencent.com/document/product/269/11673)。实时通话需要提前开通腾讯云 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788)。


#### 步骤4：配置 TUIKit 工程文件，填入您的应用信息

1. 找到并打开 `TUIKit/miniprogram/debug/GenerateTestUserSig.js` 文件。
2. 设置 `GenerateTestUserSig.js` 文件中的相关参数：
  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul> 
  <img src="https://main.qcloudimg.com/raw/575902219de19b4f2d4595673fa755d4.png">

>!
>- 本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 TUIKit 和功能调试**。
>- 正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

####  步骤5：编译运行
1. 打开微信开发者工具，选择【小程序】，单击新建图标，选择【导入项目】。
2. 填写您微信小程序的 AppID，单击【导入】。

![](https://web.sdk.qcloud.com/component/TUIKit/assets/tuikit-github-2.jpg)

>!此处应输入您微信小程序的 AppID，而非 SDKAppID。
3. 单击【预览】，生成二维码，通过手机微信扫码二维码即可进入小程序。

![](https://web.sdk.qcloud.com/component/TUIKit/assets/tuikit-github-3.jpg)

### 常见问题

**1. 小程序如果需要上线或者部署正式环境怎么办？**
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

### 文档：
- SDK API 手册：https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html
- SDK 更新日志：https://cloud.tencent.com/document/product/269/38492
