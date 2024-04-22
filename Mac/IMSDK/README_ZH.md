[English](./README.md) | 简体中文

# TIM SDK 7.9.5680（Mac）

## 下载 IM SDK

[下载 ImSDKForMac_Plus.framework 版本](https://im.sdk.qcloud.com/download/plus/7.9.5680/ImSDKForMac_Plus_7.9.5680.framework.zip)

说明：SDK 同时支持 Objective-C、C 和 C++ 三种类型的 API；强烈建议您选定一种类型的 API 之后，不要与其它类型的 API 混合使用。

## CocoaPods 集成
在您的 Podfile 文件中添加依赖项。
```
source 'https://github.com/CocoaPods/Specs.git'
platform :macos, '10.10'

target 'TUIKitDemo' do
    pod 'TXIMSDK_Plus_Mac'
end
```

如果您需要更详细的集成指引，请 [查看完整的集成文档](https://cloud.tencent.com/document/product/269/75288)。
