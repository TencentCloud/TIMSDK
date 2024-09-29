# TUIRoomKit iOS 示例工程快速跑通

_中文 | [English](README.en.md)_

本文档主要介绍如何快速跑通TUIRoomKit 示例工程，体验高质量多人视频会议，更详细的TUIRoomKit组件接入流程，请点击腾讯云官网文档： [**TUIRoomKit 组件 iOS 接入说明** ](https://cloud.tencent.com/document/product/647/84237)...

![](https://qcloudimg.tencent-cloud.cn/raw/b847f8497287077db8909503e6880e19.svg)

## 目录结构

```
TUIRoomKit
├─ Example                      // 多人视频会议Demo工程
    ├─ App                      // 进入/创建多人视频会议UI代码以及用到的图片及国际化字符串资源文件夹
    ├─ Debug                    // 工程调试运行所需的关键业务代码文件夹
    ├─ Login                    // 登录UI及业务逻辑代码文件夹
    └─ TXReplayKit_Screen       // 共享屏幕逻辑代码文件夹
├─ TUIRoomKit                   // 多人视频会议主要UI代码以及所需的图片、国际化字符串资源文件夹
├─ TUIBarrage                   // 弹幕组件
└─ TUIBeauty                    // 美颜组件
```

## 环境准备

iOS 12.0及更高。

## 运行并体验 App

[](id:ui.step1)
### 第一步：创建TRTC的应用

TUIRoomKit 是基于腾讯云 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 和 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 两项付费 PaaS 服务构建出的音视频通信组件。您可以按照如下步骤开通相关的服务：

1. 登录到 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击**创建新应用**，在弹出的对话框中输入您的应用名称，并单击**确定**。

![](https://qcloudimg.tencent-cloud.cn/raw/07fa9407da05b76b3dbbd9d2c4714cc8.png)
2. 单击刚刚创建出的应用，进入基本配置页面，并在页面的右下角找到开通腾讯实时音视频服务功能区，单击立即开通即可开通实时音视频TRTC 的 7 天免费试用服务。如果需要正式应用上线，可以前往[**实时音视频控制台**](https://console.cloud.tencent.com/trtc/app)付费购买正式版本。

![](https://qcloudimg.tencent-cloud.cn/raw/daa624cbc9c87c787f2afc5b37a8f272.png)

> **友情提示**：
> 单击 **免费体验** 以后，部分之前使用过 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 服务的用户会提示：
> ```java
> [-100013]:TRTC service is  suspended. Please check if the package balance is 0 or the Tencent Cloud accountis in arrears
> ```
> 因为新的 IM 音视频通话能力是整合了腾讯云 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 和 [即时通信 IM](https://cloud.tencent.com/document/product/269/42440) 两个基础的 PaaS 服务，所以当 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 的免费额度（10000分钟）已经过期或者耗尽，就会导致开通此项服务失败，这里您可以单击 [TRTC 控制台](https://console.cloud.tencent.com/trtc/app)，找到对应 SDKAppID 的应用管理页，示例如图，开通后付费功能后，再次 **启用应用** 即可正常体验音视频通话能力。
![](https://qcloudimg.tencent-cloud.cn/raw/559f87a883348cf27cf6ac202f769243.png)

3. 进入应用信息后，按下图操作，记录SDKAppID和密钥：

![](https://qcloudimg.tencent-cloud.cn/raw/ca696884bd53233447b22c730ed82205.png)

[](id:ui.step2)
### 第二步：配置工程
1. 使用Xcode(12.0及以上)打开源码工程`DemoApp.xcworkspace`。
2. 工程内找到 `iOS/Example/Debug/GenerateTestUserSig.swift` 文件。
3. 设置 `GenerateTestUserSig.swift` 文件中的相关参数：
<ul style="margin:0"><li/>SDKAPPID：默认为0，请设置为实际的 SDKAppID。
<li/>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</ul>

![](https://qcloudimg.tencent-cloud.cn/raw/1c4eb799c7e06aa2da54ece87ccf993e.png)

[](id:ui.step3)
### 第三步：编译运行

1. 打开Terminal（终端）进入到工程目录下执行`pod install`指令，等待完成。
2. Xcode（12.0及以上的版本）打开源码工程 `TUIRoomKit/iOS/Example/DemoApp.xcworkspace`，单击 **运行** 即可开始调试本 App。

[](id:ui.step4)

>? 如果您在使用过程中，有什么建议或者意见，欢迎您加入我们的 TUIKit 组件交流群 QQ 群：592465424，进行技术交流和产品沟通。








