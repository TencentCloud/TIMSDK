本文主要介绍如何快速地运行云通信 WebIM Demo（小程序）工程。
>!当前小程序版本 Demo 仅提供直播聊天室场景。

<span id="step1"></span>
## 创建应用
1. 登录云通信 IM [控制台](https://console.cloud.tencent.com/avc)。
 >?如果您已有应用，请记录其 SDKAppID 并 [配置应用](#step2)。
 >
2. 在【应用列表】页，单击【创建应用接入】。
 ![](https://main.qcloudimg.com/raw/a7769d15f050286162b0cbcdadca5f03.png)
3. 在【创建新应用】对话框中，填写新建应用的信息，单击【确认】。
 应用创建完成后，自动生成一个应用标识 SDKAppID，请记录 SDKAppID 信息。
 ![](https://main.qcloudimg.com/raw/bf8fe4f38d782741a6e142c24648c9e0.png)

<span id="step2"></span>
## 配置应用
1. 单击目标应用所在行的【应用配置】，进入应用详情页面。
 ![](https://main.qcloudimg.com/raw/e41602a50754be9d478b9db84c0bcff2.png)
2. 单击【帐号体系集成】右侧的【编辑】，配置**帐号管理员**信息，单击【保存】。
 ![](https://main.qcloudimg.com/raw/2ad153a77fe6f838633d23a0c6a4dde1.png)

<span id="step3"></span>
## 获取测试 UserSig
>!本文提到的获取 UserID 和 UserSig 的方案仅适合本地跑通 Demo 和功能调试，正确的 UserSig 签发方式请参见 [生成 UserSig](https://cloud.tencent.com/document/product/269/32688)。

1. 在控制台应用详情页面，单击【下载公私钥】，保存 **keys.zip** 压缩文件。
 ![](https://main.qcloudimg.com/raw/e11d958bc43b09fb41c7064ee2b09722.png)
2. 解压 **keys.zip** 文件 ，获得 **private_key.txt** 和 **public_key.txt** 文件，其中 **private_key.txt** 即为私钥文件。
 ![](https://main.qcloudimg.com/raw/ec89f5bb93d57de1acffa4e15786da11.png)
3. 在控制台应用详情页面，选择【开发辅助工具】页签，填写【用户名（UserID）】，拷贝私钥文件内容至【私钥（PrivateKey）】文本框中，单击【生成签名】，在【签名（UserSig）】文本框中即可获得该云通信应用指定用户名的 UserSig。
 ![](https://main.qcloudimg.com/raw/f491ffbd8dc3c0e8659288d27152c847.png)
4. 重复上述操作，生成4组或更多组 UserID 和 UserSig。

<span id="step4"></span>
## 创建互动直播聊天室
1. 在控制台应用详情页面，选择【群组管理】页签。
2. 单击【添加群组】，配置以下参数：
 - 群名称：请输入群名称，必填项，长度不超过30字节。
 - 群类型：请选择所需创建的群的类型，必填项，**在此 Demo 中必须选择为【互动直播聊天室】**。
3. 单击【确认】。
 群组创建完成后，系统会自动生成群 ID，请记录该群 ID 信息。

## 小程序服务器域名配置
选择 【微信公众平台】>【开发】>【开发设置】>【服务器域名】，将下表所列域名添加到 **request 合法域名**中。

| 域名 | 说明 |  是否必须 |
|:-------:|---------|----|
|`https://webim.tim.qq.com` | WebIM 业务域名 | 是|
|`https://sxb.qcloud.com` | 测试 Demo 域名 | 否，使用测试 Demo 时配置|

<span id="step6"></span>
## 下载 Demo 源码
从 [Github](https://github.com/tencentyun/TIMSDK) 下载 IM SDK WXMini 开发包。

## 编译运行
1. 安装微信小程序 [开发者工具](https://mp.weixin.qq.com/debug/wxadoc/dev/devtools/download.html)。
2. 打开微信小程序开发者工具，单击【小程序项目】。
3. 配置以下参数，单击【确定】创建小程序项目。
 - 目录：请选择为 [下载 Demo 源码](#step6) 中获取的代码**根目录**，即`project.config.json`文件所在目录。
 - AppID：请输入您的微信小程序 AppID，而非 [创建应用](#step1) 中获取的 SDKAppID。
4. 修改 `pages/config.js`文件，将 [创建应用](#step1) 中获取的 **SDKAppID**、[获取测试 userSig](#step3) 中获取到 **UserID** 和 **userSig** 以及、[创建互动直播聊天室](#step4) 中获取的**群 ID** 填入 `pages/config.js` 的相应位置。
5. 使用手机直接扫描开发者工具预览生成的二维码进入互动直播聊天室。
6. 选择体验帐号登录聊天室，即可体验收发消息等功能。
 ![](https://main.qcloudimg.com/raw/65952c55ee5102973b6e5383ddc5ba7e.png)
  	

## 常见问题
### 1. 小程序 SDK 与 WebIM SDK 有什么区别？
小程序 SDK 是基于 WebIM SDK 的兼容版本，因此相关接口文档请参考 [Web 通用](https://cloud.tencent.com/document/product/269/1595) 及 [Web 直播聊天室](https://cloud.tencent.com/document/product/269/4066) 的相关接口文档。但由于小程序运行时环境的差异，**目前 IM SDK 在小程序中仅支持文本格式消息**。
以上接口需要业务方通过小程序文件上传接口实现，再通过 IM SDK 消息通道发送消息。

### 2. 登录时出现“登录失败，code=70013”怎么处理？
错误码70013含义为请求的 UserID 与生成 UserSig 的 UserID 不匹配，更多错误码详情请参见 [错误码](https://cloud.tencent.com/document/product/269/1671) 。
