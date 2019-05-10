
**跨平台C接口，目前支持以下四个平台**
- Windows 平台，Windows 快速开始 [集成 SDK](https://cloud.tencent.com/document/product/269/33489) 和 [跑通 demo](https://cloud.tencent.com/document/product/269/33488)。
- iOS 平台
- Mac 平台
- Android 平台

**关于接口回调和事件回调说明**
- iOS 、 Mac 、 Android 三个平台的回调在 IM SDK 内部的逻辑线程触发，跟调用接口的线程不是同一线程。
- Windows 平台，如果调用 [TIMInit](https://cloud.tencent.com/document/product/269/33546#timinit) 接口进行初始化 Imsdk 之前，已创建了 UI 的消息循环，且调用 [TIMInit](https://cloud.tencent.com/document/product/269/33546#timinit) 接口的线程为主 UI 线程，则 IM SDK 内部会将回调放到主 UI 线程调用。


[官方使用文档](https://cloud.tencent.com/document/product/269/33543)
