# TIM SDK （iOS）

## 下载地址

### 标准版
[最新 ImSDK.framework 下载](https://imsdk-1252463788.cos.ap-guangzhou.myqcloud.com/5.1.60/TIM_SDK_iOS_latest_framework.zip)

### 精简版
[最新 ImSDK_Smart.framework下载](https://im.sdk.qcloud.com/download/smart/5.3.425/ImSDK_Smart_5.3.425.framework.zip)

### 精简版 bitcode 版本
[最新 ImSDK_Smart_Bitcode.framework下载](https://im.sdk.qcloud.com/download/smart/5.3.425/ImSDK_Smart_5.3.425_Bitcode.framework.zip)

### 精简版 xcframework 版本（支持 mac catalyst）
[最新 ImSDK_Smart.xcframework.zip下载](https://im.sdk.qcloud.com/download/smart/5.3.425/ImSDK_Smart_5.3.425.xcframework.zip)

### [标准版与精简版差异对比](https://github.com/tencentyun/TIMSDK#%E6%A0%87%E5%87%86%E7%89%88%E4%B8%8E%E7%B2%BE%E7%AE%80%E7%89%88%E5%B7%AE%E5%BC%82%E5%AF%B9%E6%AF%94)

## cocoaPods 集成
如果使用标准版 SDK，请您按照如下方式设置 Podfile 文件

```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_iOS'
end
```

如果使用精简版 SDK，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Smart_iOS'
end
```

如果使用精简版 bitcode 版本 SDK，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Smart_iOS_Bitcode'
end
```

如果使用精简版 xcframework 版本 SDK，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Smart_iOS_XCFramework'
end
```

更多集成方式请参考 <a href="https://cloud.tencent.com/document/product/269/32673">集成 SDK</a>
