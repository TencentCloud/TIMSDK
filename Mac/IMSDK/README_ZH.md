[English](./README.md) | 简体中文

# TIM SDK （Mac）

## 下载地址

### 增强版（推荐）
[最新 ImSDKForMac_Plus.framework 下载](https://im.sdk.qcloud.com/download/plus/7.5.4864/ImSDKForMac_Plus_7.5.4864.framework.zip)

### 增强版 Pro (网络层增加axp-quic多路传输协议，弱网抗性更加优异)
[最新 ImSDKForMac_Plus_Pro.framework 下载](https://im.sdk.qcloud.com/download/plus/7.5.4864/ImSDKForMac_Plus_Pro_7.5.4864.framework.zip)

### 基础版
[最新 ImSDKForMac.framework 下载](https://im.sdk.qcloud.com/download/standard/5.1.62/TIM_SDK_Mac_latest_framework.zip)

### C++接口版
[最新C++接口下载](https://im.sdk.qcloud.com/download/plus/7.5.4864/cross_platform/ImSDK_Mac_CPP_7.5.4864.framework.zip)

### C接口版
[最新C接口下载](https://im.sdk.qcloud.com/download/plus/7.5.4864/cross_platform/ImSDK_Mac_C_7.5.4864.framework.zip)

## cocoaPods 集成
如果使用基础版 SDK，请您按照如下方式设置 Podfile 文件

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Mac'

end

```

如果使用增强版 SDK，请您按照如下方式设置 Podfile 文件

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Plus_Mac'

end

```

如果使用增强版 Pro SDK，请您按照如下方式设置 Podfile 文件

```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
   pod 'TXIMSDK_Plus_Pro_Mac'

end

```
