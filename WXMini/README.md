本文主要介绍如何快速地将腾讯云WEBIM Demo(小程序) 工程运行起来，您只需参考如下步骤依次执行即可。

## 1. 创建新的应用
进入腾讯云通讯（IM）[控制台](https://console.cloud.tencent.com/avc)，会出现“应用列表”，单击“创建应用接入”，会出现下图的内容：
![](https://main.qcloudimg.com/raw/27314e92cd2972a8eada8cfba4055ac6.png)

创建应用后，腾讯云会给您的新应用分配一个应用标识：sdkappid，如下图：
![](https://main.qcloudimg.com/raw/826b903373db7cff2adebec6fa3a40a8.png)

## 2. 配置应用
完成创建应用之后返回应用列表，单击相应应用的“应用配置”链接，在新页面中，找到当前页面的**帐号体系集成**部分，单击“编辑”链接：
![](https://main.qcloudimg.com/raw/e3ce0ef527d2d4f8d0b3a0f69cefa78e.png)

>账号管理员可以随便填写，在使用云通讯后台的 REST API 发送消息时才会用到。

## 3. 获取测试 userSig
点击**下载公私钥**的链接，即可获得一个名为 **keys.zip** 的压缩包，解压后可以得到两个文件，即 public_key 和 private_key，用记事本打开 **private_key** 文件，并将其中的内容拷贝到**开发辅助工具**的私钥文本输入框中。

其中：**identifier** 由您指定，即为您的测试账号（也就是 userId）。私钥为 private_key 文件里的文本内容，生成的签名就是**userSig**。identifier 和 userSig 是一一对应的关系。

![](https://main.qcloudimg.com/raw/a1b9bb35760e1e52825c754bd3ef9a52.png)

> 可以最多生成4组 identifier 和 userSig，方便在Demo中调试使用。

## 4. 小程序服务器域名配置
SDK 内部需要访问如下地址，请将以下域名在 【微信公众平台】-【开发】-【开发设置】-【服务器域名】中进行配置，添加到 **request 合法域名**中：

| 域名 | 说明 |  是否必须 |
|:-------:|---------|----|
|`https://webim.tim.qq.com` | WebIM 业务域名 | **必须**|
|`https://sxb.qcloud.com` | 测试demo域名 | 非必须，使用测试demo时配置|

## 5. 下载 Demo 源码
从 [Github](https://github.com/tencentyun/TIMSDK) 下载 IMSDK WXMini开发包。

## 6. 编译运行
- step1：安装微信小程序 [开发者工具](https://mp.weixin.qq.com/debug/wxadoc/dev/devtools/download.html)，打开微信开发者工具，单击【小程序项目】按钮。

- step2：输入您申请到的微信小程序 AppID（注意：不是上面的 SDKAppID），项目目录选择上一步下载到的代码目录（ **注意：** 目录请选择**根目录**，根目录包含有 `project.config.json`文件），单击【确定】创建小程序项目。
- step3：修改 `pages/config.js`，将上文获取到的 sdkappid、accountType、identifier 和 userSig 填入 `pages/config.js` 的相应位置。
- step4：使用手机进行测试，直接扫描开发者工具预览生成的二维码进入。
- step5: 选择体验帐号然后登录聊天室，即可进行收发消息。
![](https://main.qcloudimg.com/raw/65952c55ee5102973b6e5383ddc5ba7e.png)
  	

## 常见问题
### 1. 小程序SDK 与 WebIM SDK 有什么区别
小程序 SDK 是基于 WebIM SDK 的兼容版本，因此相关接口文档请参考 [Web(通用)](https://cloud.tencent.com/document/product/269/1595) 及 [Web（直播聊天室）](https://cloud.tencent.com/document/product/269/4066) 的相关接口文档

但由于小程序运行时环境的差异，目前IMSDK的部分接口在小程序尚未支持

· 图片上传
· 文件上传

以上接口需要业务方自己通过小程序文件上传接口实现，再通过IMSDK消息通道发送消息。

### 2. 登录时出现“登录失败，code=70013”
code 70013 含义为请求的 Identifier 与生成 UserSig 的 Identifier 不匹配。[错误码](https://cloud.tencent.com/document/product/269/1671)文档