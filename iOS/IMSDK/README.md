English | [简体中文](./README_ZH.md)

# TIM SDK (iOS)

## Download Links

### Enhanced Edition (Objective-C)

#### Enhanced Edition(Recommend)

[Latest ImSDK_Plus.framework download](https://im.sdk.qcloud.com/download/plus/7.4.4661/ImSDK_Plus_7.4.4661.framework.zip)

#### Enhanced XCFramework edition (supporting Mac Catalyst)

[Latest ImSDK_Plus.xcframework.zip download](https://im.sdk.qcloud.com/download/plus/7.4.4661/ImSDK_Plus_7.4.4661.xcframework.zip)

#### Enhanced Edition Pro (Providing axp-quic multiplex transmission protocol to enhance network performance)

[Latest ImSDK_Plus_Pro.framework download](https://im.sdk.qcloud.com/download/plus/7.4.4661/ImSDK_Plus_Pro_7.4.4661.framework.zip)

### Enhanced Edition (Swift)

#### Enhanced XCFramework edition (supporting Mac Catalyst)

[Latest ImSDK_Plus_Swift.xcframework.zip download](https://im.sdk.qcloud.com/download/plus/7.4.4661/ImSDK_Plus_Swift_7.4.4661.xcframework.zip)

### Basic Edition

[Latest ImSDK.framework download](https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_iOS_latest_framework.zip)

### [Differences Between the Basic Edition and the Enhanced Edition](https://github.com/tencentyun/TIMSDK#%E5%9F%BA%E7%A1%80%E7%89%88%E4%B8%8E%E5%A2%9E%E5%BC%BA%E7%89%88%E5%B7%AE%E5%BC%82%E5%AF%B9%E6%AF%94)

### C API edition
[Latest C API download](https://im.sdk.qcloud.com/download/plus/7.4.4661/cross_platform/ImSDK_iOS_C_7.4.4661.framework.zip)

### C++ API edition
[Latest C++ API download](https://im.sdk.qcloud.com/download/plus/7.4.4661/cross_platform/ImSDK_iOS_CPP_7.4.4661.framework.zip)

## CocoaPods Integration
If you are using the SDK enhanced edition, edit the Podfile as follows:
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS'
# pod 'TXIMSDK_Plus_Swift_iOS'
end
```

If you are using the SDK XCFramework enhanced edition, edit the Podfile as follows:
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS_XCFramework'
# pod 'TXIMSDK_Plus_Swift_iOS_XCFramework'
end
```

If you are using the SDK enhanced edition Pro, edit the Podfile as follows:
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_Pro_iOS'
end
```

If you are using the SDK basic edition, edit the Podfile as follows:

```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_iOS'
end
```

For more integration modes, see <a href="https://www.tencentcloud.com/document/product/1047/34307">SDK Integration</a>.
