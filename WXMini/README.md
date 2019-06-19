本文主要介绍如何快速地将腾讯云 WEBIM Demo(小程序) 工程运行起来，您只需参考如下步骤依次执行即可。
>!当前小程序版本 Demo 仅提供直播聊天室场景。

## 1. 创建应用
登录腾讯云通信（IM）[控制台](https://console.cloud.tencent.com/avc)，在**应用列表**页，单击【创建应用接入】，在**创建新应用**弹框中，填写新建应用的信息，单击【确认】：
![](https://main.qcloudimg.com/raw/a7769d15f050286162b0cbcdadca5f03.png)

应用创建完成后，自动生成一个应用标识：SDKAppID，如下图：
![](https://main.qcloudimg.com/raw/bf8fe4f38d782741a6e142c24648c9e0.png)

## 2. 配置应用
完成创建应用之后返回应用列表，单击对应 SDKAppID 的**应用配置**链接，在应用详情页，找到当前页面的**帐号体系集成**部分，单击**编辑**链接，配置**账号管理员**信息，然后单击【保存】：

>?账号管理员可以随便填写，在使用云通信后台的 REST API 发送消息时才会用到。

![](https://main.qcloudimg.com/raw/e3ce0ef527d2d4f8d0b3a0f69cefa78e.png)


## 3. 获取测试 userSig 和创建互动直播聊天室
完成账号管理员配置后，单击**下载公私钥**的链接，即可获得一个名为 **keys.zip** 的压缩包。解压后可以得到两个文件，即 public_key 和 private_key，用记事本打开 **private_key** 文件，并将其中的内容拷贝到**开发辅助工具**的私钥文本输入框中。

其中：**identifier** 即为您的测试账号（也就是 userId），私钥为 private_key 文件里的文本内容，生成的签名就是**userSig**。identifier 和 userSig 是一一对应的关系。
>! 可以多生成4组以上的 userid 和 usersig，方便在 Demo 中调试使用。

![](https://main.qcloudimg.com/raw/a1b9bb35760e1e52825c754bd3ef9a52.png)

切换到**群组管理**页面，单击**添加群组**，按照弹框的提示，创建互动直播聊天室，并记下创建的群 ID。
>! 群类型必须为互动直播聊天室。

![](https://main.qcloudimg.com/raw/c51a8d491c723670b382cf5de04e4f61.png)


## 4. 小程序服务器域名配置
SDK 内部需要访问如下地址，请将以下域名在 【微信公众平台】-【开发】-【开发设置】-【服务器域名】中进行配置，添加到 **request 合法域名**中：

| 域名 | 说明 |  是否必须 |
|:-------:|---------|----|
|`https://webim.tim.qq.com` | WebIM 业务域名 | 必须|
|`https://sxb.qcloud.com` | 测试demo域名 | 非必须，使用测试 Demo 时配置|

## 5. 下载 Demo 源码
从 [Github](https://github.com/tencentyun/TIMSDK) 下载 IM SDK WXMini 开发包。

## 6. 编译运行
- step1：安装微信小程序 [开发者工具](https://mp.weixin.qq.com/debug/wxadoc/dev/devtools/download.html)，打开微信开发者工具，单击【小程序项目】按钮。

- step2：输入您申请到的微信小程序 AppID（注意：不是上面的 SDKAppID），项目目录选择上一步下载到的代码目录（ **注意：** 目录请选择**根目录**，根目录包含有 `project.config.json`文件），单击【确定】创建小程序项目。
- step3：修改 `pages/config.js`，将上文获取到的 SDKAppID、identifier、userSig、群 ID 填入 `pages/config.js` 的相应位置。
- step4：使用手机进行测试，直接扫描开发者工具预览生成的二维码进入。
- step5：选择体验帐号然后登录聊天室，即可进行收发消息。
![](https://main.qcloudimg.com/raw/65952c55ee5102973b6e5383ddc5ba7e.png)
  	

## 常见问题
### 1. 小程序 SDK 与 WebIM SDK 有什么区别？
小程序 SDK 是基于 WebIM SDK 的兼容版本，因此相关接口文档请参考 [Web(通用)](https://cloud.tencent.com/document/product/269/1595) 及 [Web（直播聊天室）](https://cloud.tencent.com/document/product/269/4066) 的相关接口文档。

但由于小程序运行时环境的差异，目前 IM SDK 在小程序中仅支持文本格式消息。

以上接口需要业务方自己通过小程序文件上传接口实现，再通过 IM SDK 消息通道发送消息。

### 2. 登录时出现“登录失败，code=70013”怎么处理？
code 70013 含义为请求的 Identifier 与生成 UserSig 的 Identifier 不匹配。[错误码](https://cloud.tencent.com/document/product/269/1671) 文档。
