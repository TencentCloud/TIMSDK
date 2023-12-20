English | [简体中文](./README_ZH.md)

# TIM SDK 7.7.5282 (iOS)

## Download IM SDK

<table >
  <tr>
    <th width="240px" style="text-align:center">IM SDK Type</th>
    <th width="440px" style="text-align:center">Introduction</th>
    <th width="320px" style="text-align:center">Download Links</th>
  </tr>

  <tr >
     <td style="text-align:center">Objective-C Edition</td>
     <td style="text-align:center">Support Objective-C API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.6.5011/ImSDK_Plus_7.6.5011.framework.zip">ImSDK_Plus.framework</a></td>
  </tr>
    
  <tr >
     <td style="text-align:center">XCFramework Edition</td>
     <td style="text-align:center">Support Objective-C API and Mac catalyst</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.6.5011/ImSDK_Plus_7.6.5011.xcframework.zip">ImSDK_Plus.xcframework</a></td>
  </tr>
	
  <tr >
     <td style="text-align:center">Swift Edition</td>
     <td style="text-align:center">Support Swift API and Mac catalyst</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.6.5011/ImSDK_Plus_Swift_7.6.5011.xcframework.zip">ImSDK_Plus_Swift.xcframework</a></td>
  </tr>
</table>

## Download Plugin for IM SDK

<table >
  <tr>
    <th width="260px" style="text-align:center">IM SDK Plugin Type</th>
    <th width="500px" style="text-align:center">Introduction</th>
    <th width="240px" style="text-align:center">Download Links</th>
  </tr>

  <tr >
     <td style="text-align:center">Quic Plugin</td>
     <td style="text-align:center">Providing axp-quic multiplex transmission protocol to enhance network performance</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.7.5282/TIMQuicPlugin_7.7.5282.framework.zip">TIMQuicPlugin.framework</a></td>
  </tr>
    
  <tr >
     <td style="text-align:center">Advanced Encryption Plugin</td>
     <td style="text-align:center">Providing database encryption and SM4 encryption algorithm</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.7.5282/TIMAdvancedEncryptionPlugin_7.7.5282.framework.zip">TIMAdvancedEncryptionPlugin.framework</a></td>
  </tr>
</table>

## CocoaPods Integration
Add the dependency to your Podfile.

```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
    # Add the IM SDK
    pod 'TXIMSDK_Plus_iOS'
    # pod 'TXIMSDK_Plus_iOS_XCFramework'
    # pod 'TXIMSDK_Plus_Swift_iOS_XCFramework'

    # If you need to add the Quic plugin, please uncomment the next line (Note: the plugin version number must match the IM SDK version number)
    # pod 'TXIMSDK_Plus_QuicPlugin'

    # If you need to add the advanced encryption plugin, please uncomment the next line (Note: the plugin version number must match the IM SDK version number)
    # pod 'TXIMSDK_Plus_AdvancedEncryptionPlugin'
end
```

If you need more detailed integration guidance, please [refer to the complete integration documentation](https://www.tencentcloud.com/document/product/1047/34307).

In addition, we also provide SDKs for the C and C++ API, which you can download from here，[Download C API Edition](https://im.sdk.qcloud.com/download/plus/7.6.5011/cross_platform/ImSDK_iOS_C_7.6.5011.framework.zip), [Download  C++ API Edition](https://im.sdk.qcloud.com/download/plus/7.6.5011/cross_platform/ImSDK_iOS_CPP_7.6.5011.framework.zip).