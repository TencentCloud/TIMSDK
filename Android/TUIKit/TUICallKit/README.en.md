# Quick Run of TUICalling Demo for Android
_[中文](README.md) | English_

This document describes how to quickly run the TUICalling demo project to make a high-quality audio/video call. For more information on the TUICalling component connection process, see **[Integrating TUICalling (Android)](https://cloud.tencent.com/document/product/647/42045)**.

## Directory Structure

```
TUICalling
├─ app          // Main panel, which is the entry of the audio/video call scenario
├─ debug        // Debugging code
└─ tuicalling   // Real-time audio/video call business logic
```

## Environment Requirements
- Compatibility with Android 4.2 (SDK API Level 17) or above is required. Android 5.0 (SDK API Level 21) or above is recommended
- Android Studio 3.5 or above

## Demo Run Example

### Step 1. Create a TRTC application
1. Go to the [Application management](https://console.cloud.tencent.com/trtc/app) page in the TRTC console, select **Create Application**, enter an application name such as `TUIKitDemo`, and click **Confirm**.
2. Click **Application Information** on the right of the application as shown below:
    <img src="https://qcloudimg.tencent-cloud.cn/raw/62f58d310dde3de2d765e9a460b8676a.png" width="900">
3. On the application information page, note down the `SDKAppID` and key as shown below:
    <img src="https://qcloudimg.tencent-cloud.cn/raw/bea06852e22a33c77cb41d287cac25db.png" width="900">

>! This feature uses two basic PaaS services of Tencent Cloud: [TRTC](https://cloud.tencent.com/document/product/647/16788) and [IM](https://cloud.tencent.com/document/product/269). When you activate TRTC, IM will be activated automatically. IM is a value-added service. See [Pricing](https://cloud.tencent.com/document/product/269/11673) for its billing details.

[](id:ui.step2)
### Step 2. Download the source code and configure the project
1. Clone or directly download the source code in the repository. **Feel free to star our project if you like it.**
2. Find and open the `Android/debug/src/main/java/com/tencent/liteav/debug/GenerateTestUserSig.java` file.
3. Set parameters in `GenerateTestUserSig.java`:
	<img src="https://main.qcloudimg.com/raw/f9b23b8632058a75b78d1f6fdcdca7da.png" width="900">
	- SDKAPPID: A placeholder by default. Set it to the `SDKAppID` that you noted down in step 1.
	- SECRETKEY: A placeholder by default. Set it to the key information that you noted down in step 1.

### Step 3. Compile and run the application
Open the source code directory `TUICalling/Android` in Android Studio, wait for the Android Studio project to be synced, connect to a real device, and then click **Run** to try out the application.

### Step 4. Try out the demo

Note: You need to prepare at least two devices to try out the call feature of TUICalling. Here, users A and B represent two different devices:

**Device A (userId: 111)**

- Step 1: On the welcome page, enter the username (<font color=red>which must be unique</font>), such as `111`. 

- Step 2: Go to the different scenario pages, such as video call, based on your scenario and requirements.

- Step 3: Enter `userId` of user B to be called, click **Search**, and then click **Call**.

  | Step 1 | Step 2 | Step 3 | 
  |---------|---------|---------|
  |<img src="https://qcloudimg.tencent-cloud.cn/raw/ab18c3dee2fa825b14ff19fc727a161b.png" width="240"/>|<img src="https://qcloudimg.tencent-cloud.cn/raw/011897b6601bac5ba27641a9b120647a.png" width="240">|<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/tuicalling_user.png" width="240"/>

**Device B (userId: 222)**

- Step 1: On the welcome page, enter the username (<font color=red>which must be unique</font>), such as `222`.
- Step 2: Enter the homepage and wait for the call.


## FAQs

- [FAQs About TUI Scenario-Specific Solution](https://cloud.tencent.com/developer/article/1952880)
- If you have any questions or feedback, feel free to [contact us](https://intl.cloud.tencent.com/contact-us).

