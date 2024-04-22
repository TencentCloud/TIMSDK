English | [简体中文](./README_ZH.md)

# TIM SDK 7.9.5680 (iOS)

## Download IM SDK

<table >
  <tr>
    <th width="240px" style="text-align:center">IM SDK Type</th>
    <th width="460px" style="text-align:center">Introduction</th>
    <th width="300px" style="text-align:center">Download Links</th>
  </tr>

  <tr >
     <td style="text-align:center">Objective-C Edition</td>
     <td style="text-align:center">Support Objective-C API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/ImSDK_Plus_7.9.5680.framework.zip">ImSDK_Plus.framework</a></td>
  </tr>
    
  <tr >
     <td style="text-align:center">XCFramework Edition</td>
     <td style="text-align:center">Support Objective-C API and Mac catalyst</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/ImSDK_Plus_7.9.5680.xcframework.zip">ImSDK_Plus.xcframework</a></td>
  </tr>
	
  <tr >
     <td style="text-align:center">Swift Edition</td>
     <td style="text-align:center">Support Swift API and Mac catalyst</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/ImSDK_Plus_Swift_7.9.5680.xcframework.zip">ImSDK_Plus_Swift.xcframework</a></td>
  </tr>

  <tr >
     <td style="text-align:center">Apple Vision Pro Edition</td>
     <td style="text-align:center">Support visionOS and provide Swift API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/ImSDKForVision_Plus_7.9.5680.xcframework.zip">ImSDKForVision_Plus.xcframework</a></td>
  </tr>
</table>

## Download Plugin for IM SDK

<table >
  <tr>
    <th width="240px" style="text-align:center">IM SDK Plugin Type</th>
    <th width="460px" style="text-align:center">Introduction</th>
    <th width="300px" style="text-align:center">Download Links</th>
  </tr>

  <tr >
     <td style="text-align:center">Quic Plugin</td>
     <td style="text-align:center">Providing axp-quic multiplex transmission protocol to enhance network performance</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/7.9.5680/TIMQuicPlugin_7.9.5680.framework.zip">TIMQuicPlugin.framework</a></td>
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
    # pod 'TXIMSDK_Plus_Swift_Vision_XCFramework'

    # If you need to add the Quic plugin, please uncomment the next line.
    # Note:
    # - This plugin must be used with the TXIMSDK_Plus_iOS or TXIMSDK_Plus_iOS_XCFramework edition of the IM SDK, and the plugin version number must match the IM SDK version number.
    # - For the TXIMSDK_Plus_Swift_iOS_XCFramework edition, there is no need to add this plugin. If you need to use the Quic feature in this edition, please contact us.
    # pod 'TXIMSDK_Plus_QuicPlugin'
end
```

If you need to use the Quic feature in the Swift version of the IMSDK, [please contact us](https://www.tencentcloud.com/document/product/1047/41676).

If you need more detailed integration guidance, please [refer to the complete integration documentation](https://www.tencentcloud.com/document/product/1047/34307).

In addition, we also provide SDKs for the C and C++ API, which you can download from here，[Download C API Edition](https://im.sdk.qcloud.com/download/plus/7.9.5680/cross_platform/ImSDK_iOS_C_7.9.5680.framework.zip), [Download  C++ API Edition](https://im.sdk.qcloud.com/download/plus/7.9.5680/cross_platform/ImSDK_iOS_CPP_7.9.5680.framework.zip).
