# TUICallKit Android 示例工程快速跑通
_中文 | [English](README.en.md)_

本文档主要介绍如何快速跑通 TUICallKit 示例工程，体验高质量视频/语音通话，更详细的 TUICallKit 组件接入流程，请点击腾讯云官网文档： [**TUICallKit 组件 Android 接入说明** ](https://cloud.tencent.com/document/product/647/78729)...

## 目录结构

```
TUICallKit
├─ app          // 主面板，音视频通话场景入口
├─ debug        // 调试相关
└─ tuicallkit   // 实时语音/视频通话业务逻辑
```

## 环境准备
- 最低兼容 Android 4.2（SDK API Level 19），建议使用 Android 5.0 （SDK API Level 21）及以上版本。
- Android Studio 3.5及以上版本。
- Android 4.1 及以上的手机设备。

## 运行示例

[](id:step1)
### 第一步：开通服务
TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务：

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。
![](https://qcloudimg.tencent-cloud.cn/raw/1105c3c339be4f71d72800fe2839b113.png)
2. 单击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。
![](https://qcloudimg.tencent-cloud.cn/raw/667633f7addfd0c589bb086b1fc17d30.png)
1. 在同一页面找到 **SDKAppID** 和 **密钥(SecretKey)** 并记录下来，它们会在后续的 [第二步](#step2) 中被用到。
![](https://qcloudimg.tencent-cloud.cn/raw/e435332cda8d9ec7fea21bd95f7a0cba.png)

> **注意**：
> 单击 **免费体验** 以后，部分之前使用过 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 服务的用户会提示：
> ```java
> [-100013]:TRTC service is  suspended. Please check if the package balance is 0 or the Tencent Cloud accountis in arrears
> ```
> 因为新的 IM 音视频通话能力是整合了腾讯云 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 和 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 两个基础的 PaaS 服务，所以当 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 的免费额度（10000分钟）已经过期或者耗尽，就会导致开通此项服务失败，这里您可以单击 [TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，找到对应 SDKAppID 的应用管理页，示例如图，开通后付费功能后，再次 **启用应用** 即可正常体验音视频通话能力。
> <img width=800px src="https://qcloudimg.tencent-cloud.cn/raw/f74a13a7170cf8894195a1cae6c2f153.png" />


[](id:step2)
### 第二步：下载源码，配置工程
1. 克隆或者直接下载此仓库源码，**欢迎 Star**，感谢~~
2. 找到并打开 `Android/debug/src/main/java/com/tencent/liteav/debug/GenerateTestUserSig.java` 文件。
3. 配置 `GenerateTestUserSig.java` 文件中的相关参数：
	<img src="https://main.qcloudimg.com/raw/f9b23b8632058a75b78d1f6fdcdca7da.png" width="900">
	
	- SDKAPPID：默认为占位符（PLACEHOLDER），请设置为 [第一步](#step1) 中记录下的 SDKAppID。
	- SECRETKEY：默认为占位符（PLACEHOLDER），请设置为 [第一步](#step1) 中记录下的密钥(SecretKey)信息。

[](id:step3)
### 第三步：编译运行
使用 Android Studio 打开源码目录 `TUICallKit/Android`，待Android Studio工程同步完成后，连接 **真机** 单击 **运行按钮** 即可开始体验本APP。

[](id:step4)
### 第四步：示例体验

`Tips：TUICallKit 通话体验，至少需要两台设备，如果用户A/B分别代表两台不同的设备：`

**用户 A（userId：111）**

- 步骤 1：在欢迎页，输入用户名(<font color=red>请确保用户名唯一性，不能与其他用户重复</font>)，比如111； 

- 步骤 2：根据不同的场景&业务需求，进入不同的场景界面，比如视频通话；

- 步骤 3：输入要拨打的用户B的userId，点击搜索，然后点击呼叫；

  | 步骤1 | 步骤2 | 步骤3 | 
  |---------|---------|---------|
  |<img src="https://qcloudimg.tencent-cloud.cn/raw/ab18c3dee2fa825b14ff19fc727a161b.png" width="240"/>|<img src="https://qcloudimg.tencent-cloud.cn/raw/94ce7747260d1ad2b5c9a476feb51b01.png" width="240">|<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/tuicalling_user.png" width="240"/>

**用户 B（userId：222）**

- 步骤 1：在欢迎页，输入用户名(<font color=red>请确保用户名唯一性，不能与其他用户重复</font>)，比如222；
- 步骤 2：进入主页，等待接听来电即可；


## 常见问题

- [TUICallKit (Android) 常见问题](https://cloud.tencent.com/document/product/647/78767)
- 欢迎加入 QQ 群：**592465424**，进行技术交流和反馈~

