English | [简体中文](./README_ZH.md)

# TIM SDK (Mac)

## Download Links

### Enhanced Edition(Recommend)
[Latest ImSDKForMac_Plus.framework download](https:  // im.sdk.qcloud.com/download/plus/7.3.4358/ImSDKForMac_Plus_7.3.4358.framework.zip)

### Enhanced Edition Pro (Providing axp-quic multiplex transmission protocol to enhance network performance)
[Latest ImSDKForMac_Plus_Pro.framework download](https://im.sdk.qcloud.com/download/plus/7.3.4358/ImSDKForMac_Plus_Pro_7.3.4358.framework.zip)

### Basic Edition
[Latest ImSDKForMac.framework download](https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_Mac_latest_framework.zip)

### C++ API edition
[Latest C++ API download](https://im.sdk.qcloud.com/download/plus/7.3.4358/cross_platform/ImSDK_Mac_CPP_7.3.4358.framework.zip)

### C API edition
[Latest C API download](https://im.sdk.qcloud.com/download/plus/7.3.4358/cross_platform/ImSDK_Mac_C_7.3.4358.framework.zip)

## CocoaPods Integration
If you are using the SDK basic edition, edit the Podfile as follows:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Mac'

end

```

If you are using the SDK enhanced edition, edit the Podfile as follows:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Plus_Mac'

end

```

If you are using the SDK enhanced edition Pro, edit the Podfile as follows:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Plus_Pro_Mac'

end

```
