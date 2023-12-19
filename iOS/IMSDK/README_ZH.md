[English](./README.md) | 简体中文

# TIM SDK （iOS）

## 下载地址

### 增强版（Objective-C）

#### 增强版（推荐）

[最新 ImSDK_Plus.framework下载](https://im.sdk.qcloud.com/download/plus/7.6.5011/ImSDK_Plus_7.6.5011.framework.zip)

#### 增强版 xcframework 版本（支持 mac catalyst）

[最新 ImSDK_Plus.xcframework.zip下载](https://im.sdk.qcloud.com/download/plus/7.6.5011/ImSDK_Plus_7.6.5011.xcframework.zip)

### 增强版（Swift）

#### 增强版 xcframework 版本（支持 mac catalyst）

[最新 ImSDK_Plus_Swift.xcframework.zip下载](https://im.sdk.qcloud.com/download/plus/7.6.5011/ImSDK_Plus_Swift_7.6.5011.xcframework.zip)

### C 接口版
[最新 C 接口下载](https://im.sdk.qcloud.com/download/plus/7.6.5011/cross_platform/ImSDK_iOS_C_7.6.5011.framework.zip)

### C++ 接口版
[最新 C++ 接口下载](https://im.sdk.qcloud.com/download/plus/7.6.5011/cross_platform/ImSDK_iOS_CPP_7.6.5011.framework.zip)

### IM SDK 的 Quic 插件 (提供axp-quic多路传输协议，弱网抗性更加优异)

[最新 Quic 插件下载](https://im.sdk.qcloud.com/download/plus/7.7.5282/TIMQuicPlugin_7.7.5282.framework.zip)

### IM SDK 的高级加密插件 (提供数据库加密和 SM4 国密算法)

[最新高级加密插件下载](https://im.sdk.qcloud.com/download/plus/7.7.5282/TIMAdvancedEncryptionPlugin_7.7.5282.framework.zip)

## cocoaPods 集成

如果使用增强版 SDK，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS'
# pod 'TXIMSDK_Plus_Swift_iOS'
end
```

如果使用增强版 xcframework 版本 SDK，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_iOS_XCFramework'
# pod 'TXIMSDK_Plus_Swift_iOS_XCFramework'
end
```

如果集成 Quic 插件，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_QuicPlugin'
end
```

如果集成高级加密插件，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_AdvancedEncryptionPlugin'
end
```

更多集成方式请参考 <a href="https://cloud.tencent.com/document/product/269/75284">集成 SDK</a>
