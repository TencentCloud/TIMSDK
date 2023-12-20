[English](./README.md) | 简体中文

# TIM SDK 7.7.5282（iOS）

## 下载 IM SDK

<table >
  <tr>
    <th width="180px" style="text-align:center">IM SDK 类型</th>
    <th width="600px" style="text-align:center">简介</th>
    <th width="220px" style="text-align:center">下载地址</th>
  </tr>

  <tr >
     <td style="text-align:center">Objective-C 版本</td>
     <td style="text-align:center">支持 Objective-C API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.6.5011/ImSDK_Plus_7.6.5011.framework.zip">ImSDK_Plus.framework</a></td>
  </tr>
    
  <tr >
     <td style="text-align:center">XCFramework 版本</td>
     <td style="text-align:center">支持 Objective-C API 和 Mac catalyst</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.6.5011/ImSDK_Plus_7.6.5011.xcframework.zip">ImSDK_Plus.xcframework</a></td>
  </tr>
	
  <tr >
     <td style="text-align:center">Swift 版本</td>
     <td style="text-align:center">支持 Swift API 和 Mac catalyst</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.6.5011/ImSDK_Plus_Swift_7.6.5011.xcframework.zip">ImSDK_Plus_Swift.xcframework</a></td>
  </tr>
</table>

## 下载 IM SDK 的插件

<table >
  <tr>
    <th width="200px" style="text-align:center">IM SDK 插件类型</th>
    <th width="560px" style="text-align:center">简介</th>
    <th width="240px" style="text-align:center">下载地址</th>
  </tr>

  <tr >
     <td style="text-align:center">Quic 插件</td>
     <td style="text-align:center">提供 axp-quic 多路传输协议，弱网抗性更优</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.7.5282/TIMQuicPlugin_7.7.5282.framework.zip">TIMQuicPlugin.framework</a></td>
  </tr>
    
  <tr >
     <td style="text-align:center">高级加密插件</td>
     <td style="text-align:center">提供数据库加密和 SM4 国密算法</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.7.5282/TIMAdvancedEncryptionPlugin_7.7.5282.framework.zip">TIMAdvancedEncryptionPlugin.framework</a></td>
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

    # 如果您需要添加 Quic 插件，请取消下一行的注释（注意：要求插件版本号和 IM SDK 版本号相同）
    # pod 'TXIMSDK_Plus_QuicPlugin'

    # 如果您需要添加高级加密插件，请取消下一行的注释（注意：要求插件版本号和 IM SDK 版本号相同）
    # pod 'TXIMSDK_Plus_AdvancedEncryptionPlugin'
end
```

如果您需要更详细的集成指引，请 [查看完整的集成文档](https://cloud.tencent.com/document/product/269/75284)。

此外，我们还提供了 C 接口和 C++ 接口的 SDK，您可以从这里下载：[下载 C API 版本](https://im.sdk.qcloud.com/download/plus/7.6.5011/cross_platform/ImSDK_iOS_C_7.6.5011.framework.zip)、[下载 C++ API 版本](https://im.sdk.qcloud.com/download/plus/7.6.5011/cross_platform/ImSDK_iOS_CPP_7.6.5011.framework.zip)。