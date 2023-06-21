[English](./README.md) | 简体中文

# TIM SDK （iOS）

## 下载地址

### 增强版（Objective-C）

#### 增强版（推荐）

[最新 ImSDK_Plus.framework下载](https://im.sdk.qcloud.com/download/plus/7.3.4358/ImSDK_Plus_7.3.4358.framework.zip)

#### 增强版 xcframework 版本（支持 mac catalyst）

[最新 ImSDK_Plus.xcframework.zip下载](https://im.sdk.qcloud.com/download/plus/7.3.4358/ImSDK_Plus_7.3.4358.xcframework.zip)

#### 增强版 Pro (网络层增加axp-quic多路传输协议，弱网抗性更加优异)

[最新 ImSDK_Plus_Pro.framework下载](https://im.sdk.qcloud.com/download/plus/7.3.4358/ImSDK_Plus_Pro_7.3.4358.framework.zip)


### 增强版（Swift）

#### 增强版 xcframework 版本（支持 mac catalyst）

[最新 ImSDK_Plus_Swift.xcframework.zip下载](https://im.sdk.cloud.tencent.cn/download/plus/7.3.4358/ImSDK_Plus_Swift_7.3.4358.xcframework.zip)


### 基础版 
[最新 ImSDK.framework 下载](https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_iOS_latest_framework.zip)

### C 接口版
[最新 C 接口下载](https://im.sdk.qcloud.com/download/plus/7.3.4358/cross_platform/ImSDK_iOS_C_7.3.4358.framework.zip)

### C++ 接口版
[最新 C++ 接口下载](https://im.sdk.cloud.tencent.cn/download/plus/7.3.4358/cross_platform/ImSDK_iOS_CPP_7.3.4358.framework.zip)

### [基础版与增强版差异对比](https://github.com/tencentyun/TIMSDK#%E5%9F%BA%E7%A1%80%E7%89%88%E4%B8%8E%E5%A2%9E%E5%BC%BA%E7%89%88%E5%B7%AE%E5%BC%82%E5%AF%B9%E6%AF%94)

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

如果使用增强版 Pro SDK，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Plus_Pro_iOS'
end
```

更多集成方式请参考 <a href="https://cloud.tencent.com/document/product/269/32673">集成 SDK</a>
