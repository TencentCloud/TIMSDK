# TIM SDK （iOS）

## 下载地址

### 基础版
[最新 ImSDK.framework 下载](https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_iOS_latest_framework.zip)

### 增强版
[最新 ImSDK_Plus.framework下载](https://sdk-im-1252463788.cos.ap-hongkong.myqcloud.com/download/plus/6.0.1975/ImSDK_Plus_6.0.1975.framework.zip)

### 增强版 bitcode 版本
[最新 ImSDK_Plus_Bitcode.framework下载](https://sdk-im-1252463788.cos.ap-hongkong.myqcloud.com/download/plus/6.0.1975/ImSDK_Plus_6.0.1975_Bitcode.framework.zip)

### 增强版 xcframework 版本（支持 mac catalyst）
[最新 ImSDK_Plus.xcframework.zip下载](https://sdk-im-1252463788.cos.ap-hongkong.myqcloud.com/download/plus/6.0.1975/ImSDK_Plus_6.0.1975.xcframework.zip)

### 增强版 xcframework 版本（支持 mac catalyst、支持 bitcode）
[最新 ImSDK_Plus_Bitcode.xcframework.zip下载](https://sdk-im-1252463788.cos.ap-hongkong.myqcloud.com/download/plus/6.0.1975/ImSDK_Plus_6.0.1975_Bitcode.xcframework.zip)

### [基础版与增强版差异对比](https://github.com/tencentyun/TIMSDK#%E5%9F%BA%E7%A1%80%E7%89%88%E4%B8%8E%E5%A2%9E%E5%BC%BA%E7%89%88%E5%B7%AE%E5%BC%82%E5%AF%B9%E6%AF%94)

### C 接口版
[最新C接口下载](https://im.sdk.qcloud.com/download/plus/6.0.1975/cross_platform/ImSDK_iOS_C_6.0.1975.framework.zip)

### C++ 接口版
[最新C++接口下载](https://im.sdk.cloud.tencent.cn/download/plus/6.0.1975/cross_platform/ImSDK_iOS_CPP_6.0.1975.framework.zip)

## cocoaPods 集成
如果使用基础版 SDK，请您按照如下方式设置 Podfile 文件

```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_iOS'
end
```

如果使用增强版 SDK，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS'
end
```

如果使用增强版 bitcode 版本 SDK，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS_Bitcode'
end
```

如果使用增强版 xcframework 版本 SDK，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS_XCFramework'
end
```

如果使用增强版 xcframework 版本 SDK（支持 bitcode），请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS_Bitcode_XCFramework'
end
```

更多集成方式请参考 <a href="https://cloud.tencent.com/document/product/269/32673">集成 SDK</a>
