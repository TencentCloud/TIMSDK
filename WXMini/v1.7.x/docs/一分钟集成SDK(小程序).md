本文主要介绍如何快速地将腾讯云 IM SDK 集成到您的小程序项目中，只要按照如下步骤进行配置，就可以完成 SDK 的集成工作。
>! 当前小程序版本 Demo 仅提供直播聊天室场景。

## 准备工作
在集成小程序 SDK 前，请确保您已完成以下步骤，请参见 [一分钟跑通 Demo](https://cloud.tencent.com/document/product/269/36838)。
- 创建了腾讯云即时通信 IM 应用，并获取到 SDKAppID。
- 获取私钥文件。
- 小程序服务器域名配置。

## 开发环境要求
- 最新版微信 Web 开发者工具。
- 小程序基础库最低版本要求：1.7.0。
- 微信 App iOS 最低版本要求：6.5.21。
- 微信 App Android 最低版本要求：6.5.19。

## 下载组件源码
您可以直接从 [Github](https://github.com/tencentyun/TIMSDK) 上下载 IM SDK WXMini 开发包。
SDK 路径为 TIMSDK/WXMini/utils/webim_wx.js
![](https://main.qcloudimg.com/raw/418f52960facd081c932cd34e77ce0a6.png)

## 集成组件
将 webim_wx.js 拷贝到您的小程序项目里合适的目录下（例如 components 文件夹）。
详细的调用过程可参考小程序 Demo 源码。

## 常见问题

### 如果需要上线或者部署正式环境怎么办？
请将以下域名在 【微信公众平台】>【开发】>【开发设置】>【服务器域名】中进行配置，添加到 **request 合法域名**中：

| 域名 | 说明 |  是否必须 |
|:-------:|---------|----|
|`https://webim.tim.qq.com` | Web IM 业务域名 | 必须|
|`https://sxb.qcloud.com` | 测试 Demo 域名 | 非必须，使用测试 Demo 时配置|
