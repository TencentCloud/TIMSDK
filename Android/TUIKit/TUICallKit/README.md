English | [简体中文](README-zh_CN.md)

# Call UIKit for Android Quickstart

<img src="https://qcloudimg.tencent-cloud.cn/raw/ec034fc6e4cf42cae579d32f5ab434a1.png" align="left" width=120 height=120>TUICallKit is a UIKit about **audio&video calls** launched by Tencent Cloud. By integrating this component, you can write a few lines of code to use the video calling function, TUICallKit support offline calling and multiple  platforms such as Android, iOS, Web, Flutter, etc.

<a href="https://apps.apple.com/cn/app/%E8%85%BE%E8%AE%AF%E4%BA%91%E8%A7%86%E7%AB%8B%E6%96%B9trtc/id1400663224"><img src="https://qcloudimg.tencent-cloud.cn/raw/afe9b8cc4c715346cf3d9feea8a65e33.svg" height=40></a> <a href="https://dldir1.qq.com/hudongzhibo/liteav/TRTCDemo.apk"><img src="https://qcloudimg.tencent-cloud.cn/raw/006d5ed3359640424955baa08dab7c7f.svg" height=40></a> <a href="https://web.sdk.qcloud.com/trtc/webrtc/demo/api-sample/login.html"><img src="https://qcloudimg.tencent-cloud.cn/raw/d326e70750f8bbad7245e229c5bd6d2b.svg" height=40></a>


## Before getting started

This section shows you the prerequisites you need for testing tuicallkit for Android sample app.

- Android 5.0 (SDK API level 21) or later.
- Gradle 4.2.1 or later.
- Mobile phone on Android 5.0 or later.

## Getting started

If you would like to run the sample app, you can do so by following the steps below.

#### Create application

1. Login or Sign-up for an account on [Tencent RTC Console](https://console.trtc.io/).
2. Create or select a calls-enabled application on the console.
3. Note your application ***SDKAppID*** and ***SDKSecretKey*** for future reference.

#### Build and run the sample app
1. Clone thie repository
   ```
   git clone https://github.com/tencentyun/TUICallKit.git
   ```
2. Specify the SDKAppID and SDKSecretKey
   Input the SDKAppID and SDKSecretKey into file `Android/debug/src/main/java/com/tencent/qcloud/tuikit/debug/GenerateTestUserSig.java` 
   ```
   public static final int SDKAPPID = SDKAppID;
   private static final String SECRETKEY = SDKSecretKey;
   ```
3. Build and run the sample app on two Android devices.

## Making your first call

1. Log in to the sample app on the primary device with the user ID set as the `caller`.
2. Log in to the sample app on the secondary device using the ID of the user set as the `callee`.
3. On the primary device, specify the user ID of the `callee` and initiate a call.
4. If all steps are followed correctly, an incoming call invitation will appear on the device of the `callee`.

## Reference
- If you want to learn more about the product features, you can click on the following [link](https://trtc.io/products/call).

- If you encounter difficulties, you can refer to [FAQs](https://trtc.io/document/53565), here are the most frequently encountered problems of developers, covering various platforms, I hope it can Help you solve problems quickly.

- For complete API documentation, see [Audio Video Call SDK API Example](https://trtc.io/document/51004): including TUICallKit (with UIKit), TUICallEngine (without UIKit), and call events Callbacks, etc.
