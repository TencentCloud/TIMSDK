# Quick Run of TUIRoomKit Demo for Android
_[中文](README.md) | English_

This document describes how to quickly run the `TUIRoomKit` demo project to try out multi-person audio/video interactions. For more information on the TUIRoomKit component connection process, see **[Integrating TUIRoomKit (Android)](https://write.woa.com/document/93119926066618368)**.
>!This product is currently in the free public beta period, and no additional fees are charged for the time being. The current service billing is consistent with instant messaging IM, real-time audio and video TRTC product billing services.
You can download the SDK for free for a limited time and access to experience multi-person audio and video sessions ability.
If there are any changes in the billing method, functions, and free public beta time of the multiplayer audio and video SDK in the future,
we will issue an announcement on the official website to explain in advance,
and notify you in advance through in-site letters, text messages, emails, etc., so stay tuned
<img src="https://qcloudimg.tencent-cloud.cn/raw/526f1e79040089c7a7bb5f9be6f084f9.svg" width="900">

## Directory Structure

```
Android
├─ app              // Main panel, which is the entry of the multi-person audio/video interaction scenario
├─ basic            // basic code,contains base method and class,etc.
├─ debug            // Debugging code
├─ tuibeauty        // Beauty filter panel, which provides effects such as beauty filters, filters, and animated effect
├─ tuicore          // Public library, used to mount tui components
├─ tuivideoseat     // Video panel，for streaming video
└─ tuiroomkit       // Multi-person audio/video interaction business logic
```

## Environment Requirements
- Compatibility with Android 4.2 (SDK API Level 17) or above is required. Android 5.0 (SDK API Level 21) or above is recommended
- Android Studio 3.5 or above

## Demo Run Example

### Step 1. Create a TRTC application
1. Go to the [Application management](https://console.cloud.tencent.com/trtc/app) page in the TRTC console, click **Create Application**, enter an application name such as `TUIKitDemo`, and then click **Confirm**.
2. Click **Application Information** on the right of the application as shown below:
    <img src="https://qcloudimg.tencent-cloud.cn/raw/62f58d310dde3de2d765e9a460b8676a.png" width="900">
3. On the application information page, note down the `SDKAppID` and key as shown below:
    <img src="https://qcloudimg.tencent-cloud.cn/raw/bea06852e22a33c77cb41d287cac25db.png" width="900">

>! This feature uses two basic PaaS services of Tencent Cloud: [TRTC](https://www.tencentcloud.com/document/product/647/35078) and [IM](https://www.tencentcloud.com/document/product/1047/33513). When you activate TRTC, IM will be activated automatically. IM is a value-added service.


[](id:ui.step2)
### Step 2. Download the source code and configure the project
1. Clone or directly download the source code in the repository. **Feel free to star our project if you like it.**
2. Find and open the `Android/debug/src/main/java/com/tencent/liteav/debug/GenerateTestUserSig.java` file.
3. Set parameters in `GenerateTestUserSig.java`:
	<img src="https://main.qcloudimg.com/raw/f9b23b8632058a75b78d1f6fdcdca7da.png" width="900">

	- SDKAPPID: A placeholder by default. Set it to the `SDKAppID` that you noted down in step 1.
	- SECRETKEY: A placeholder by default. Set it to the key information that you noted down in step 1.

### Step 3. Compile and run the application
You can open the source code directory `TUIRoomKit/Android` in Android Studio 3.5 or later, wait for the Android Studio project to be synced, connect to a real device, and click **Run** to try out the application.

### Step 4. Try out the demo

Note: You need to prepare at least two devices to try out TUIRoomKit. Here, users A and B represent two different devices:

**Device A (userId: 111)**

- Step 1: On the welcome page, enter the username (which must be unique), such as `111`.
- Step 2: Click **Create Room**.
- Step 3: Enter the room creation page. Note down the ID of the newly created room.
- Step 4: Enter the room.

**Device B (userId: 222)**

- Step 1: Enter the username (which must be unique), such as `222`.
- Step 2: Click **Enter Room** and enter the ID of the room created by user A (the room ID that you noted down in step 3 on device A) to enter the room.

## Have any questions?
Welcome to join our Telegram Group to communicate with our professional engineers! We are more than happy to hear from you~
Click to join: https://t.me/+EPk6TMZEZMM5OGY1
Or scan the QR code

<img src="https://qcloudimg.tencent-cloud.cn/raw/9c67ed5746575e256b81ce5a60216c5a.jpg" width="320"/>