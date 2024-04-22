English | [简体中文](./README_ZH.md)

# TIM SDK 7.9.5680 (Mac)

## Download IM SDK

[Download ImSDKForMac_Plus.framework Edition](https://im.sdk.qcloud.com/download/plus/7.9.5680/ImSDKForMac_Plus_7.9.5680.framework.zip)

Note: The SDK supports three types of APIs: Objective-C, C, and C++. It is strongly recommended that you choose one type of API and avoid mixing it with other types of APIs.

## CocoaPods Integration
Add the dependency to your Podfile.

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
    pod 'TXIMSDK_Plus_Mac'
end
```

If you need more detailed integration guidance, please [refer to the complete integration documentation](https://www.tencentcloud.com/document/product/1047/34308)。
