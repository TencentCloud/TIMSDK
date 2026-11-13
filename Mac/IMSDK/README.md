English | [简体中文](./README_ZH.md)

# TIM SDK 9.1.7834 (Mac)

## Download IM SDK

[Download ImSDKForMac_Plus.framework Edition](https://im.sdk.qcloud.com/download/plus/9.1.7834/ImSDKForMac_Plus_9.1.7834.framework.zip)

Note: The SDK supports three types of APIs: Objective-C, C, and C++. It is strongly recommended that you choose one type of API and avoid mixing it with other types of APIs.

## Integration with Swift Package Manager (SPM)

In Xcode, select **File > Add Package Dependencies…** and enter the official repository:

```text
https://github.com/Tencent-RTC/Chat_SDK_SwiftPM.git
```

Select **Exact Version** and use the published version TAG **9.1.7834**. Add the required products to your app target:

- macOS: `TXIMSDK_Plus_Mac`

Keep existing underlying module import names unchanged. Select only one SDK core per app target; do not combine Swift or Vision with the OC core or plugins. Plugin products already include the OC core; QUIC and encryption can be selected together.

If you need more detailed integration guidance, please [refer to the complete integration documentation](https://www.tencentcloud.com/document/product/1047/34308)。
