# TUICallKit iOS 示例工程快速跑通

_简体中文 | [English](README.en.md)_

本文档主要介绍如何快速跑通TUICallKit 示例工程，体验高质量视频/语音通话，更详细的TUICallKit组件接入流程，请点击腾讯云官网文档： [**TUICallKit 组件 iOS 接入说明** ](https://cloud.tencent.com/document/product/647/42044)...

## 目录结构

```
TUICallKit
├─ Example              // 视频/语音通话Demo工程
    ├─ App              // 视频/语音通话主页UI代码以及用到的图片及国际化字符串资源文件夹
    ├─ Debug            // 工程调试运行所需的关键业务代码文件夹
    ├─ LoginMock        // 登录UI及业务逻辑代码文件夹
    └─ TXAppBasic       // 工程依赖的基础组件
├─ Resources            // 视频/语音通话功能所需的图片、国际化字符串资源文件夹
├─ TUICallKit           // 视频/语音通话核心业务逻辑代码文件夹
```

## 环境准备

iOS 9.0 (API level 16) 及更高。

## 运行并体验 App

[](id:ui.step1)
### 第一步：创建TRTC的应用

TUICallKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务并体验 7 天的免费试用服务

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。
<img width="640" src="https://qcloudimg.tencent-cloud.cn/raw/1105c3c339be4f71d72800fe2839b113.png">
2. 点击刚刚创建出的应用，进入**基本配置**页面，并在页面的右下角找到**开通腾讯实时音视频服务**功能区，单击**免费体验**即可开通 TUICallKit 的 7 天免费试用服务。
<img width="640" src="https://qcloudimg.tencent-cloud.cn/raw/667633f7addfd0c589bb086b1fc17d30.png">

3. 进入应用信息后，按下图操作，记录SDKAppID和密钥：
<img width="640" src="https://qcloudimg.tencent-cloud.cn/raw/e435332cda8d9ec7fea21bd95f7a0cba.png">

> **注意**：
> 单击 **免费体验** 以后，部分之前使用过 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 服务的用户会提示：
> ```java
> [-100013]:TRTC service is  suspended. Please check if the package balance is 0 or the Tencent Cloud accountis in arrears
> ```
> 因为新的 IM 音视频通话能力是整合了腾讯云 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 和 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 两个基础的 PaaS 服务，所以当 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 的免费额度（10000分钟）已经过期或者耗尽，就会导致开通此项服务失败，这里您可以单击 [TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，找到对应 SDKAppID 的应用管理页，示例如图，开通后付费功能后，再次 **启用应用** 即可正常体验音视频通话能力。
> <img width=800px src="https://qcloudimg.tencent-cloud.cn/raw/f74a13a7170cf8894195a1cae6c2f153.png" />


[](id:ui.step2)
### 第二步：配置工程
1. 使用Xcode(11.0及以上)打开源码工程`TUICallingApp.xcworkspace`。
2. 工程内找到 `iOS/Example/Debug/GenerateTestUserSig.swift` 文件。
3. 设置 `GenerateTestUserSig.swift` 文件中的相关参数：
<ul style="margin:0"><li/>SDKAPPID：默认为0，请设置为实际的 SDKAppID。
<li/>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</ul>

<img src="https://main.qcloudimg.com/raw/a226f5713e06e014515debd5a701fb63.png">

[](id:ui.step3)
### 第三步：编译运行

1. 打开Terminal（终端）进入到工程目录下执行`pod install`指令，等待完成。
2. Xcode（11.0及以上的版本）打开源码工程 `TUICallKit/iOS/Example/TUICallingApp.xcworkspace`，单击 **运行** 即可开始调试本 App。

[](id:ui.step4)
### 第四步：示例体验

Tips：TUICallKit 通话体验，至少需要两台设备，如果用户A/B分别代表两台不同的设备：

**设备 A（userId：111）**

- 步骤 1：在欢迎页，输入用户名(<font color=red>请确保用户名唯一性，不能与其他用户重复</font>)，比如111； 
- 步骤 2：根据不同的场景&业务需求，进入不同的场景界面，比如视频通话；
- 步骤 3：输入要拨打的用户B的userId，点击搜索，然后点击呼叫；

| 步骤1 | 步骤2 | 步骤3 | 
|---------|---------|---------|
|<img src="https://qcloudimg.tencent-cloud.cn/raw/ab18c3dee2fa825b14ff19fc727a161b.png" width="240"/>|<img src="https://qcloudimg.tencent-cloud.cn/raw/94ce7747260d1ad2b5c9a476feb51b01.png" width="240">|<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/tuicalling_user.png" width="240"/>

**设备 B（userId：222）**

- 步骤 1：在欢迎页，输入用户名(<font color=red>请确保用户名唯一性，不能与其他用户重复</font>)，比如222；
- 步骤 2：进入主页，等待接听来电即可；

## 常见问题

### TUICallKit Example 已经配置了真机证书，真机调试仍然提示以下错误：

```
Provisioning profile "XXXXXX" doesn't support the Push Notifications capability.  
Provisioning profile "XXXXXX" doesn't include the aps-environment entitlement.
```

可以删除 `Push Notifications`功能，如下图：

![](https://qcloudimg.tencent-cloud.cn/raw/800bfcdc73e1927e24b5419f09ecef7a.png)

>? 更多帮助信息，详见 [TUICallKit (iOS) 常见问题](https://cloud.tencent.com/document/product/647/78768)，欢迎加入 QQ 群：592465424，进行技术交流和反馈~!
