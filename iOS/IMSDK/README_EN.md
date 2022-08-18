English | [简体中文](./README.md)

# TIM SDK (iOS)

## Download Links

### Enhanced Edition(Recommend)
[Latest ImSDK_Plus.framework download](https://im.sdk.cloud.tencent.cn/download/plus/6.6.3002/ImSDK_Plus_6.6.3002.framework.zip)

### Enhanced bitcode edition
[Latest ImSDK_Plus_Bitcode.framework download](https://im.sdk.cloud.tencent.cn/download/plus/6.6.3002/ImSDK_Plus_6.6.3002_Bitcode.framework.zip)

### Enhanced XCFramework edition (supporting Mac Catalyst)
[Latest ImSDK_Plus.xcframework.zip download](https://im.sdk.cloud.tencent.cn/download/plus/6.6.3002/ImSDK_Plus_6.6.3002.xcframework.zip)

### Enhanced XCFramework edition (supporting Mac Catalyst and bitcode)
[Latest ImSDK_Plus_Bitcode.xcframework.zip download](https://im.sdk.cloud.tencent.cn/download/plus/6.6.3002/ImSDK_Plus_6.6.3002_Bitcode.xcframework.zip)

### Basic Edition
[Latest ImSDK.framework download](https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_iOS_latest_framework.zip)

### [Differences Between the Basic Edition and the Enhanced Edition](https://github.com/tencentyun/TIMSDK#%E5%9F%BA%E7%A1%80%E7%89%88%E4%B8%8E%E5%A2%9E%E5%BC%BA%E7%89%88%E5%B7%AE%E5%BC%82%E5%AF%B9%E6%AF%94)

### C API edition
[Latest C API download](https://im.sdk.qcloud.com/download/plus/6.6.3002/cross_platform/ImSDK_iOS_C_6.6.3002.framework.zip)

### C++ API edition
[Latest C++ API download](https://im.sdk.cloud.tencent.cn/download/plus/6.6.3002/cross_platform/ImSDK_iOS_CPP_6.6.3002.framework.zip)

## CocoaPods Integration
If you are using the SDK basic edition, edit the Podfile as follows:

```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_iOS'
end
```

If you are using the SDK enhanced edition, edit the Podfile as follows:
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS'
end
```

If you are using the SDK bitcode enhanced edition, edit the Podfile as follows:
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS_Bitcode'
end
```

If you are using the SDK XCFramework enhanced edition, edit the Podfile as follows:
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS_XCFramework'
end
```

If you are using the SDK XCFramework enhanced edition (bitcode supported), edit the Podfile as follows:
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS_Bitcode_XCFramework'
end
```

For more integration modes, see <a href="https://intl.cloud.tencent.com/document/product/1047/34305">SDK Integration</a>.

