English | [简体中文](./README.md)

- [Quick Integration with IM SDK for Windows](https://intl.cloud.tencent.com/document/product/1047/34310) and [Demo Quick Start](https://intl.cloud.tencent.com/document/product/1047/45914)

On the Windows platform, if you call the [TIMInit](https://intl.cloud.tencent.com/document/product/1047/34388#timinit) API to initialize the IM SDK after a UI message loop is created and the thread for calling the [TIMInit](https://intl.cloud.tencent.com/document/product/1047/34388#timinit) API is the main UI thread, the IM SDK will throw the callback to the main UI thread to call.


[Documentation](https://intl.cloud.tencent.com/document/product/1047/34549)
