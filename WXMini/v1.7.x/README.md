本文主要介绍如何快速地运行云通信 WebIM Demo（小程序）工程，您只需参考如下步骤依次执行即可。

## 1. 创建新的应用
进入登录云通信 IM [控制台](https://console.cloud.tencent.com/avc) 创建一个新的应用，获得 SDKAppID，SDKAppID 是腾讯云后台用来区分不同云通信应用的唯一标识，在第4步中会用到。
![](https://main.qcloudimg.com/raw/b9d211494b6ec8fcea765d1518b228a1.png)

接下来，点击应用进入**快速上手**页面，参考页面上指引的“第一步”、“第二步”和“第三步”操作，即可快速跑通 Demo。

## 2. 下载 SDK+Demo 源码
“快速上手”页面中第一步里的几个链接地址分别为各个平台的 SDK 和 Demo 源码，点击会跳转到 Github 上，如果您当前网络访问 Github 太慢，可以在项目首页中找到镜像下载地址。
![](https://main.qcloudimg.com/raw/d56b4e4434da42d1a3b8e3540cf6718e.png)

## 3. 查看并拷贝加密密钥
点击**查看密钥**按钮，即可看到用于计算 UserSig 的加密密钥，点击“复制密钥”按钮，可以将密钥拷贝到剪贴板中。
![](https://main.qcloudimg.com/raw/5843542ec2e0446d326d7d44f96a5ec0.png)

<h2 id="CopyKey"> 4. 粘贴密钥到Demo工程的指定文件中 </h2>
我们在各个平台的 Demo 的源码工程中都提供了一个叫做 “GenerateTestUserSig” 的文件，它可以通过 HMAC-SHA256 算法本地计算出 UserSig，用于快速跑通 Demo。您只需要将第1步中获得的 SDKAppID 和第3步中获得的加密密钥拷贝到文件中的指定位置即可，如下所示：

![](https://main.qcloudimg.com/raw/9275a5f99bf00467eac6c34f6ddd3ca5.jpg)

## 5. 创建互动直播聊天室
1. 在控制台应用详情页面，选择【群组管理】页签。
2. 单击【添加群组】，配置以下参数：
 - 群名称：请输入群名称，必填项，长度不超过30字节。
 - 群类型：请选择所需创建的群的类型，必填项，**在此 Demo 中必须选择为【互动直播聊天室】**。
3. 单击【确认】。
 群组创建完成后，系统会自动生成群 ID，请记录该群 ID 信息。

## 6. 小程序服务器域名配置
选择 【微信公众平台】>【开发】>【开发设置】>【服务器域名】，将下表所列域名添加到 **request 合法域名**中。

| 域名 | 说明 |  是否必须 |
|:-------:|---------|----|
|`https://webim.tim.qq.com` | WebIM 业务域名 | 是|
|`https://sxb.qcloud.com` | 测试 Demo 域名 | 否，使用测试 Demo 时配置|

## 7. 编译运行
1. 安装微信小程序 [开发者工具](https://mp.weixin.qq.com/debug/wxadoc/dev/devtools/download.html)。
2. 打开微信小程序开发者工具，单击【小程序项目】。
3. 配置以下参数，单击【确定】创建小程序项目。
 - 目录：请选择为 [下载 Demo 源码](#step6) 中获取的代码**根目录**，即`project.config.json`文件所在目录。
 - AppID：请输入您的微信小程序 AppID，而非 [创建应用](#step1) 中获取的 SDKAppID。
4. 修改 `pages/config.js`文件，将 [创建应用](#step1) 中获取的 **SDKAppID**、[创建互动直播聊天室](#step4) 中获取的**群 ID** 填入 `pages/config.js` 的相应位置。
5. 使用手机直接扫描开发者工具预览生成的二维码进入互动直播聊天室。
6. 选择体验帐号登录聊天室，即可体验收发消息等功能。
 ![](https://main.qcloudimg.com/raw/65952c55ee5102973b6e5383ddc5ba7e.png)

## 常见问题
### 1. 小程序 SDK 与 WebIM SDK 有什么区别？
小程序 SDK 是基于 WebIM SDK 的兼容版本，因此相关接口文档请参考 [Web 通用](https://cloud.tencent.com/document/product/269/1595) 及 [Web 直播聊天室](https://cloud.tencent.com/document/product/269/4066) 的相关接口文档。但由于小程序运行时环境的差异，**目前 IM SDK 在小程序中仅支持文本格式消息**。
以上接口需要业务方通过小程序文件上传接口实现，再通过 IM SDK 消息通道发送消息。

### 2. 登录时出现“登录失败，code=70013”怎么处理？
错误码70013含义为请求的 UserID 与生成 UserSig 的 UserID 不匹配，更多错误码详情请参见 [错误码](https://cloud.tencent.com/document/product/269/1671) 。