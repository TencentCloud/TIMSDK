[English](./README.md) | 简体中文

# TIM SDK 9.1.7834（Mac）

## 下载 IM SDK

[下载 ImSDKForMac_Plus.framework 版本](https://im.sdk.qcloud.com/download/plus/9.1.7834/ImSDKForMac_Plus_9.1.7834.framework.zip)

说明：SDK 同时支持 Objective-C、C 和 C++ 三种类型的 API；强烈建议您选定一种类型的 API 之后，不要与其它类型的 API 混合使用。

## 使用 Swift Package Manager (SPM) 集成

在 Xcode 中选择 **File > Add Package Dependencies…**，输入官方仓库地址：

```text
https://github.com/Tencent-RTC/Chat_SDK_SwiftPM.git
```

依赖规则选择 **Exact Version**，使用已发布版本 TAG **9.1.7834**。将所需 Product 添加到应用 Target：

- macOS：`TXIMSDK_Plus_Mac`

已有底层模块的 import 名称保持不变。同一 App Target 只选一种 SDK 核心；Swift、Vision 不与 OC 或两个插件混用。插件 Product 已包含 OC 核心，无需重复选择；QUIC 和加密可同时选择。

如果您需要更详细的集成指引，请 [查看完整的集成文档](https://cloud.tencent.com/document/product/269/75288)。
