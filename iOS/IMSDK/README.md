English | [简体中文](./README_ZH.md)

# TIM SDK 9.1.7834 (iOS)

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
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/9.1.7834/ImSDK_Plus_9.1.7834.xcframework.zip">ImSDK_Plus.xcframework</a></td>
  </tr>
    
  <tr >
     <td style="text-align:center">XCFramework Edition</td>
     <td style="text-align:center">Support Objective-C API and Mac catalyst</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/9.1.7834/ImSDK_Plus_9.1.7834.xcframework.zip">ImSDK_Plus.xcframework</a></td>
  </tr>

  <tr >
     <td style="text-align:center">Apple Vision Pro Edition</td>
     <td style="text-align:center">Support visionOS and provide Swift API</td>
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/9.1.7834/ImSDKForVision_Plus_9.1.7834.xcframework.zip">ImSDKForVision_Plus.xcframework</a></td>
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
     <td style="text-align:center"><a href="https://im.sdk.qcloud.com/download/plus/9.1.7834/TIMQuicPlugin_9.1.7834.xcframework.zip">TIMQuicPlugin.xcframework</a></td>
  </tr>
</table>

## Integration with Swift Package Manager (SPM)

In Xcode, select **File > Add Package Dependencies…** and enter the official repository:

```text
https://github.com/Tencent-RTC/Chat_SDK_SwiftPM.git
```

Select **Exact Version** and use the published version TAG **9.1.7834**. Add the required products to your app target:

| Use case | Product |
| --- | --- |
| iOS (recommended) | `TXIMSDK_Plus_iOS_XCFramework` |
| Swift | `TXIMSDK_Plus_Swift_iOS_XCFramework` |
| QUIC plugin | `TXIMSDK_Plus_QuicPlugin_XCFramework` |
| Encryption plugin | `TXIMSDK_Plus_AdvancedEncryptionPlugin` |
| Vision | `TXIMSDK_Plus_Swift_Vision_XCFramework` |

Keep existing underlying module import names unchanged. Select only one SDK core per app target; do not combine Swift or Vision with the OC core or plugins. Plugin products already include the OC core; QUIC and encryption can be selected together.

If you need to use the Quic feature in the Swift version of the IMSDK, [please contact us](https://www.tencentcloud.com/document/product/1047/41676).

If you need more detailed integration guidance, please [refer to the complete integration documentation](https://www.tencentcloud.com/document/product/1047/34307).

In addition, we also provide SDKs for the C and C++ API, which you can download from here，[Download C API Edition](https://im.sdk.qcloud.com/download/plus/9.1.7834/cross_platform/ImSDK_iOS_C_9.1.7834.framework.zip), [Download  C++ API Edition](https://im.sdk.qcloud.com/download/plus/9.1.7834/cross_platform/ImSDK_iOS_CPP_9.1.7834.framework.zip).
