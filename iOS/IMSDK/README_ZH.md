[English](./README.md) | 简体中文

# TIM SDK 9.1.7834（iOS）

## 下载 IM SDK

<table >
  <tr>
    <th width="180px" style="text-align:center">IM SDK 类型</th>
    <th width="510px" style="text-align:center">简介</th>
    <th width="300px" style="text-align:center">下载地址</th>
  </tr>

  <tr >
     <td style="text-align:center">Objective-C 版本</td>
     <td style="text-align:center">支持 Objective-C API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/9.1.7834/ImSDK_Plus_9.1.7834.xcframework.zip">ImSDK_Plus.xcframework</a></td>
  </tr>
    
  <tr >
     <td style="text-align:center">XCFramework 版本</td>
     <td style="text-align:center">支持 Objective-C API 和 Mac catalyst</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/9.1.7834/ImSDK_Plus_9.1.7834.xcframework.zip">ImSDK_Plus.xcframework</a></td>
  </tr>

  <tr >
     <td style="text-align:center">Apple Vision Pro 版本</td>
     <td style="text-align:center">支持 visionOS 并提供 Swift API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/9.1.7834/ImSDKForVision_Plus_9.1.7834.xcframework.zip">ImSDKForVision_Plus.xcframework</a></td>
  </tr>
</table>

## 下载 IM SDK 的插件

<table >
  <tr>
    <th width="180px" style="text-align:center">IM SDK 插件类型</th>
    <th width="510px" style="text-align:center">简介</th>
    <th width="300px" style="text-align:center">下载地址</th>
  </tr>

  <tr >
     <td style="text-align:center">Quic 插件</td>
     <td style="text-align:center">提供 axp-quic 多路传输协议，弱网抗性更优</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/9.1.7834/TIMQuicPlugin_9.1.7834.xcframework.zip">TIMQuicPlugin.xcframework</a></td>
  </tr>
</table>

## 使用 Swift Package Manager (SPM) 集成

在 Xcode 中选择 **File > Add Package Dependencies…**，输入官方仓库地址：

```text
https://github.com/Tencent-RTC/Chat_SDK_SwiftPM.git
```

依赖规则选择 **Exact Version**，使用已发布版本 TAG **9.1.7834**。将所需 Product 添加到应用 Target：

| 场景 | Product |
| --- | --- |
| iOS（推荐） | `TXIMSDK_Plus_iOS_XCFramework` |
| Swift | `TXIMSDK_Plus_Swift_iOS_XCFramework` |
| QUIC 插件 | `TXIMSDK_Plus_QuicPlugin_XCFramework` |
| 加密插件 | `TXIMSDK_Plus_AdvancedEncryptionPlugin` |
| Vision | `TXIMSDK_Plus_Swift_Vision_XCFramework` |

已有底层模块的 import 名称保持不变。同一 App Target 只选一种 SDK 核心；Swift、Vision 不与 OC 或两个插件混用。插件 Product 已包含 OC 核心，无需重复选择；QUIC 和加密可同时选择。

如果您需要在 Swift 版本的 IMSDK 中使用 Quic 功能，[请您联系我们](https://zhiliao.qq.com/)。

如果您需要更详细的集成指引，请 [查看完整的集成文档](https://cloud.tencent.com/document/product/269/75284)。

此外，我们还提供了 C 接口和 C++ 接口的 SDK，您可以从这里下载：[下载 C API 版本](https://im.sdk.qcloud.com/download/plus/9.1.7834/cross_platform/ImSDK_iOS_C_9.1.7834.framework.zip)、[下载 C++ API 版本](https://im.sdk.qcloud.com/download/plus/9.1.7834/cross_platform/ImSDK_iOS_CPP_9.1.7834.framework.zip)。
