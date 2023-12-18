English | [简体中文](./README_ZH.md)

# TIM SDK (Mac)

## Download Links

### Enhanced Edition(Recommend)
[Latest ImSDKForMac_Plus.framework download](https://im.sdk.qcloud.com/download/plus/7.7.5282/ImSDKForMac_Plus_7.7.5282.framework.zip)

### Enhanced Edition Pro (Providing axp-quic multiplex transmission protocol to enhance network performance)
Starting from version 7.7.5282, there is no longer a separate Pro version for the MacOS system. The [latest ImSDKForMac_Plus.framework version](https://im.sdk.qcloud.com/download/plus/7.7.5282/ImSDKForMac_Plus_7.7.5282.framework.zip) already supports QUIC and encryption capabilities.

### C++ API edition
Starting from version 7.7.5282, there is no longer a separate C++ API version for MacOS systems. The [latest ImSDKForMac_Plus.framework version](https://im.sdk.qcloud.com/download/plus/7.7.5282/ImSDKForMac_Plus_7.7.5282.framework.zip)now includes C++ header files.

### C API edition
Starting from version 7.7.5282, there is no longer a separate C API version for MacOS systems. The [latest ImSDKForMac_Plus.framework version](https://im.sdk.qcloud.com/download/plus/7.7.5282/ImSDKForMac_Plus_7.7.5282.framework.zip)now includes C header files.

## CocoaPods Integration

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
