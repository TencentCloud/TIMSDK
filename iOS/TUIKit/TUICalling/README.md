# TUICalling iOS 示例工程快速跑通

_中文 | [English](README.en.md)_

本文档主要介绍如何快速跑通TUICalling 示例工程，体验高质量视频/语音通话，更详细的TUICalling组件接入流程，请点击腾讯云官网文档： [**TUICalling 组件 iOS 接入说明** ](https://cloud.tencent.com/document/product/647/42044)...

## 目录结构

```
TUICalling
├─ Example              // 视频/语音通话Demo工程
    ├─ App              // 视频/语音通话主页UI代码以及用到的图片及国际化字符串资源文件夹
    ├─ Debug            // 工程调试运行所需的关键业务代码文件夹
    ├─ LoginMock        // 登录UI及业务逻辑代码文件夹
    └─ TXAppBasic       // 工程依赖的基础组件
├─ Resources            // 视频/语音通话功能所需的图片、国际化字符串资源文件夹
├─ Source               // 视频/语音通话核心业务逻辑代码文件夹
```

## 环境准备
- Xcode 11.0及以上版本
- 最低支持系统：iOS 13.0
- 请确保您的项目已设置有效的开发者签名

## 运行并体验 App

[](id:ui.step1)
### 第一步：创建TRTC的应用
1. 一键进入腾讯云实时音视频控制台的[应用管理](https://console.cloud.tencent.com/trtc/app)界面，选择创建应用，输入应用名称，例如 `TUIKitDemo` ，单击 **创建**；
2. 点击对应应用条目后的**应用信息**，具体位置如下图所示：
    <img src="https://qcloudimg.tencent-cloud.cn/raw/62f58d310dde3de2d765e9a460b8676a.png" width="900">
3. 进入应用信息后，按下图操作，记录SDKAppID和密钥：
    <img src="https://qcloudimg.tencent-cloud.cn/raw/bea06852e22a33c77cb41d287cac25db.png" width="900">

>! 本功能同时使用了腾讯云 [实时音视频 TRTC](https://cloud.tencent.com/document/product/647/16788) 和 [即时通信 IM](https://cloud.tencent.com/document/product/269) 两个基础 PaaS 服务，开通实时音视频后会同步开通即时通信 IM 服务。 即时通信 IM 属于增值服务，详细计费规则请参见 [即时通信 IM 价格说明](https://cloud.tencent.com/document/product/269/11673)。

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
2. Xcode（11.0及以上的版本）打开源码工程 `TUICalling/Example/TUICallingApp.xcworkspace`，单击 **运行** 即可开始调试本 App。

[](id:ui.step4)
### 第四步：示例体验

Tips：TUICalling 通话体验，至少需要两台设备，如果用户A/B分别代表两台不同的设备：

**设备 A（userId：111）**

- 步骤 1：在欢迎页，输入用户名(<font color=red>请确保用户名唯一性，不能与其他用户重复</font>)，比如111； 
- 步骤 2：根据不同的场景&业务需求，进入不同的场景界面，比如视频通话；
- 步骤 3：输入要拨打的用户B的userId，点击搜索，然后点击呼叫；

| 步骤1 | 步骤2 | 步骤3 | 
|---------|---------|---------|
|<img src="https://qcloudimg.tencent-cloud.cn/raw/ab18c3dee2fa825b14ff19fc727a161b.png" width="240"/>|<img src="https://qcloudimg.tencent-cloud.cn/raw/011897b6601bac5ba27641a9b120647a.png" width="240">|<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/tuicalling_user.png" width="240"/>

**设备 B（userId：222）**

- 步骤 1：在欢迎页，输入用户名(<font color=red>请确保用户名唯一性，不能与其他用户重复</font>)，比如222；
- 步骤 2：进入主页，等待接听来电即可；

## 常见问题

### TUICalling Example 已经配置了真机证书，真机调试仍然提示以下错误：

```
Provisioning profile "XXXXXX" doesn't support the Push Notifications capability.  
Provisioning profile "XXXXXX" doesn't include the aps-environment entitlement.
```

可以删除 `Push Notifications`功能，如下图：

![](https://qcloudimg.tencent-cloud.cn/raw/800bfcdc73e1927e24b5419f09ecef7a.png)

>? 更多帮助信息，详见 [TUI 场景化解决方案常见问题](https://cloud.tencent.com/developer/article/1952880)，欢迎加入 QQ 群：592465424，进行技术交流和反馈~!
