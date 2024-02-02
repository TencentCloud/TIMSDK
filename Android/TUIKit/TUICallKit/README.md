_[English](README.en.md) | 简体中文_
# 腾讯云 · 音视频通话解决方案

<img src="Preview/logo.png" align="left" width=120 height=120>  TUICallKit 是腾讯云推出一款音视频通话的含 UI 组件，通过集成该组件，您只需要编写几行代码就可以为您的 App 添加音视频通话功能，并且支持离线唤起能力。TUICallKit 支持 Android、iOS、Web、小程序、Flutter、UniApp 等多个开发平台。

<a href="https://apps.apple.com/cn/app/%E8%85%BE%E8%AE%AF%E4%BA%91%E9%9F%B3%E8%A7%86%E9%A2%91/id1400663224"><img src="Preview/app-store.svg" height=40></a> <a href="https://dldir1.qq.com/hudongzhibo/liteav/TRTCDemo.apk"><img src="Preview/play-store.svg" height=40></a> <a href="https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/login.html"><img src="Preview/web-app.svg" height=40></a>



## 产品特性

<p align="center">
  <img src="Preview/calls-uikit-zh.png"/>
</p>

- **完善的 UI 交互**：我们提供含 UI 的开源组件 TUICallKit，可以节省您 90% 开发时间，您只需要划分20分钟就可以拥有一款类似微信、FaceTime 的视频通话应用。
- **多平台互联互通**：我们支持Web、Android、iOS、微信小程序等各个平台，同时也支持类似uni-app等跨平台框架，您可以使用不同平台的 TUICallKit 组件支持相互呼叫、接听、挂断等，未来我们还计划支持 Flutter、MacOS、Windows等设备。
- **移动端离线推送**：我们支持Android、iOS 的离线唤醒，当您的应用处于离线状态时，也可以及时收到来电提醒，目前已经支持Google FCM、Apple、小米、华为、OPPO、VIVO、魅族等多个推送服务
- **群组（多人）通话**：我们不仅仅支持1对1的视频通话，还支持在群组内发起多人视频通话，支持中途邀请群成员加入，支持群成员主动加入通话等。
- **多设备登录**：我们也支持您可以在不同平台上登录多台设备，您可以同时在您的Pad、手机登录，更大屏幕，体验更好跟更灵活。
- **更多特性**：我们也支持自定义铃音、自定义头像、AI降噪、弱网优化等多个Feature...



## 开始使用

这里以 含 UI 的集成（即TUICallKit）为例，这也是我们推荐的集成方式，关键步骤如下：

- **Step1**：开通 [腾讯云音视频通话服务](https://console.cloud.tencent.com/vcube/project/manage)，针对开发者集成，我们也提供有免费的体验版本，[更多介绍](https://cloud.tencent.com/document/product/1640/81130#.E6.AD.A5.E9.AA.A4.E4.B8.89.EF.BC.9A.E5.BC.80.E9.80.9A.E6.9C.8D.E5.8A.A1) 
- **Step2**：接入 TUICallKit 到您的项目中，各平台/框架详细的接入流程：[Web](https://cloud.tencent.com/document/product/1640/81132) 、[Android ](https://cloud.tencent.com/document/product/647/78729)、 [iOS](https://cloud.tencent.com/document/product/647/78730)、 [微信小程序](https://cloud.tencent.com/document/product/647/78733)、[uni-app](https://cloud.tencent.com/document/product/647/78732)
- **Step3**：拨打您的第一个视频通话！



## 快速访问

- 如果你遇到了困难，可以先参阅 [常见问题](https://cloud.tencent.com/document/product/647/78767)，这里整理开发者最常出现的问题，覆盖各个平台，希望可以帮助您快速解决问题
- 如果你想了解更多官方示例，可以参考各平台的示例 Demo：[Web](Web/)、[Android](Android/)、[iOS](iOS/)、[微信小程序]([MiniProgram](https://github.com/MinTate/TUICallKit/tree/main/MiniProgram)/)
- 如果您想了解我们最新的一些产品特性，可以查看 [更新日志](https://cloud.tencent.com/document/product/647/80931)，这里有 TUICallKit 最新的功能特性，以及历史版本功能迭代
- 完整的 API 文档见 [音视频通话 SDK API 示例](https://cloud.tencent.com/document/product/647/78748)：包含TUICallKit（含 UIKit）、TUICallEngine（无 UIKit）、以及通话事件回调等介绍。
- 如果你想了解更多腾讯云音视频团队维护的项目，可以查看我们的 [产品官网](https://cloud.tencent.com/product/rtcube)、[Github Organizations](https://github.com/LiteAVSDK) 等。
- 如果因为网络问题导致工程克隆或者下载失败，您可以访问 [Gitee TUICallKit](https://gitee.com/tencent-cloud-uikit/TUICallKit)。



## 交流&反馈

如果您在使用过程中有遇到什么问题，欢迎提交 [**issue**](https://github.com/tencentyun/TUICallKit/issues)，我们也欢迎您加入我们的开发者QQ群进行技术交流和反馈问题，QQ群 ID：605115878.