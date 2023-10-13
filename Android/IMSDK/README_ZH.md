[English](./README.md) | 简体中文

# TIM SDK（Android）

## 下载地址

### 增强版（推荐）
[最新增强版 IM SDK 下载](https://im.sdk.qcloud.com/download/plus/7.5.4864/imsdk-plus-7.5.4864.aar) 

### 增强版 Pro (网络层增加axp-quic多路传输协议，弱网抗性更加优异)
[最新增强版 Pro IM SDK 下载](https://im.sdk.qcloud.com/download/plus/7.5.4864/imsdk-plus-pro-7.5.4864.aar) 

### 基础版
[最新基础版 IM SDK 下载](https://im.sdk.qcloud.com/download/standard/5.1.66/imsdk-5.1.66.aar)

### [基础版与增强版差异对比](https://github.com/tencentyun/TIMSDK#%E5%9F%BA%E7%A1%80%E7%89%88%E4%B8%8E%E5%A2%9E%E5%BC%BA%E7%89%88%E5%B7%AE%E5%BC%82%E5%AF%B9%E6%AF%94)

### C 接口版
[最新C接口下载](https://im.sdk.qcloud.com/download/plus/7.5.4864/cross_platform/ImSDK_Android_C_7.5.4864.zip)

### C++ 接口版
[最新C++接口下载](https://im.sdk.qcloud.com/download/plus/7.5.4864/cross_platform/ImSDK_Android_CPP_7.5.4864.zip)

#### maven 集成 (Android 平台)
 如果使用增强版 SDK，请在 gradle 里添加如下依赖
 ```
 dependencies {
   api 'com.tencent.imsdk:imsdk-plus:版本号'
 }
 ```
 
 如果使用增强版 Pro SDK，请在 gradle 里添加如下依赖
 ```
 dependencies {
   api 'com.tencent.imsdk:imsdk-plus-pro:版本号'
 }
 ```
 如果使用基础版 SDK，请在 gradle 里添加如下依赖
 ```
 dependencies {
   api 'com.tencent.imsdk:imsdk:版本号'
 }
 ```
