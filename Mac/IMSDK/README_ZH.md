[English](./README.md) | 简体中文

# TIM SDK （Mac）

## 下载地址

### 增强版（推荐）
[最新 ImSDKForMac_Plus.framework 下载](https://im.sdk.qcloud.com/download/plus/7.7.5282/ImSDKForMac_Plus_7.7.5282.framework.zip)

### 增强版 Pro (网络层增加axp-quic多路传输协议，弱网抗性更加优异)

从 7.7.5282 版本开始，不再针对 MacOS 系统提供单独的 Pro 版本，[最新的 ImSDKForMac_Plus.framework 版本](https://im.sdk.qcloud.com/download/plus/7.7.5282/ImSDKForMac_Plus_7.7.5282.framework.zip) 已支持 QUIC 及加密能力。

### C++接口版

从 7.7.5282 版本开始，不再针对 MacOS 系统提供单独的 C++ 接口版本，[最新的 ImSDKForMac_Plus.framework 版本](https://im.sdk.qcloud.com/download/plus/7.7.5282/ImSDKForMac_Plus_7.7.5282.framework.zip) 已包含了 C++头文件。

### C接口版
从 7.7.5282 版本开始，不再针对 MacOS 系统提供单独的 C 接口版本，[最新的 ImSDKForMac_Plus.framework 版本](https://im.sdk.qcloud.com/download/plus/7.7.5282/ImSDKForMac_Plus_7.7.5282.framework.zip) 已包含了 C 头文件。

## cocoaPods 集成
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
