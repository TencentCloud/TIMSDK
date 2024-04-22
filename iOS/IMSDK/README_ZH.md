[English](./README.md) | 简体中文

# TIM SDK 7.9.5680（iOS）

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
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/ImSDK_Plus_7.9.5680.framework.zip">ImSDK_Plus.framework</a></td>
  </tr>
    
  <tr >
     <td style="text-align:center">XCFramework 版本</td>
     <td style="text-align:center">支持 Objective-C API 和 Mac catalyst</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/ImSDK_Plus_7.9.5680.xcframework.zip">ImSDK_Plus.xcframework</a></td>
  </tr>
	
  <tr >
     <td style="text-align:center">Swift 版本</td>
     <td style="text-align:center">支持 Swift API 和 Mac catalyst</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/ImSDK_Plus_Swift_7.9.5680.xcframework.zip">ImSDK_Plus_Swift.xcframework</a></td>
  </tr>

  <tr >
     <td style="text-align:center">Apple Vision Pro 版本</td>
     <td style="text-align:center">支持 visionOS 并提供 Swift API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/ImSDKForVision_Plus_7.9.5680.xcframework.zip">ImSDKForVision_Plus.xcframework</a></td>
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
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/TIMQuicPlugin_7.9.5680.framework.zip">TIMQuicPlugin.framework</a></td>
  </tr>
</table>

## CocoaPods 集成
在您的 Podfile 文件中添加依赖项。

```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
    # 添加 IM SDK
    pod 'TXIMSDK_Plus_iOS'
    # pod 'TXIMSDK_Plus_iOS_XCFramework'
    # pod 'TXIMSDK_Plus_Swift_iOS_XCFramework'
    # pod 'TXIMSDK_Plus_Swift_Vision_XCFramework'

    # 如果您需要添加 Quic 插件，请取消下一行的注释
    # 注意：
    # - 这个插件必须搭配 TXIMSDK_Plus_iOS 或 TXIMSDK_Plus_iOS_XCFramework 版本的 IM SDK 使用，并且插件版本号必须和 IM SDK 版本号相同
    # - 对于 TXIMSDK_Plus_Swift_iOS_XCFramework 版本，不需要添加这个插件，如果您需要在这个版本中使用 Quic 功能，请您联系我们
    # pod 'TXIMSDK_Plus_QuicPlugin'
end
```

如果您需要在 Swift 版本的 IMSDK 中使用 Quic 功能，[请您联系我们](https://zhiliao.qq.com/)。

如果您需要更详细的集成指引，请 [查看完整的集成文档](https://cloud.tencent.com/document/product/269/75284)。

此外，我们还提供了 C 接口和 C++ 接口的 SDK，您可以从这里下载：[下载 C API 版本](https://im.sdk.qcloud.com/download/plus/7.9.5680/cross_platform/ImSDK_iOS_C_7.9.5680.framework.zip)、[下载 C++ API 版本](https://im.sdk.qcloud.com/download/plus/7.9.5680/cross_platform/ImSDK_iOS_CPP_7.9.5680.framework.zip)。
