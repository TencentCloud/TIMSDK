# Quick Run of TUICalling Demo for iOS

_[简体中文](README.md) | English_

This document describes how to quickly run the TUICalling demo project to make a high-quality audio/video call. For more information on the TUICalling component connection process, see **[Integrating TUICalling (iOS)](https://www.tencentcloud.com/document/product/647/36065)**.

## Directory Structure

```
TUICalling
├─ Example              // Audio/Video call demo project
    ├─ App              // Folder of audio/video call homepage UI code and used images and internationalization string resources
    ├─ Debug            // Folder of the key business code required for project debugging and running
    ├─ LoginMock        // Folder of the login UI and business logic code
    └─ TXAppBasic       // Dependent basic components of the project
├─ Resources            // Folder of images and internationalization string resources required by the audio/video call feature
├─ Source               // Folder of the core business logic code of audio/video call
```

## Environment Requirements
- Xcode 11.0 or above
- Operating system: iOS 13.0 or later
- A valid developer signature for your project

## Running the Demo

[](id:ui.step1)
### Step 1. Create a TRTC application
1. Go to the [Application management](https://console.cloud.tencent.com/trtc/app) page in the TRTC console, select **Create Application**, enter an application name such as `TUIKitDemo`, and click **Confirm**.
2. Click **Application Information** on the right of the application as shown below:
    <img src="https://qcloudimg.tencent-cloud.cn/raw/62f58d310dde3de2d765e9a460b8676a.png" width="900">
3. On the application information page, note down the `SDKAppID` and key as shown below:
    <img src="https://qcloudimg.tencent-cloud.cn/raw/bea06852e22a33c77cb41d287cac25db.png" width="900">

>! This feature uses two basic PaaS services of Tencent Cloud: [TRTC](https://www.tencentcloud.com/document/product/647/35078) and [IM](https://www.tencentcloud.com/document/product/1047/33513). When you activate TRTC, IM will be activated automatically. IM is a value-added service.

[](id:ui.step2)
### Step 2. Configure the project
1. Open the demo project `TUICallingApp.xcworkspace` with Xcode 11.0 or later.
2. Find the `iOS/Example/Debug/GenerateTestUserSig.swift` file in the project.
3. Set the following parameters in `GenerateTestUserSig.swift`:
<ul style="margin:0"><li/>SDKAPPID: `0` by default. Set it to the actual `SDKAppID`.
<li/>SECRETKEY: Left empty by default. Set it to the actual key.</ul>

<img src="https://main.qcloudimg.com/raw/a226f5713e06e014515debd5a701fb63.png">

[](id:ui.step3)
### Step 3. Compile and run the application

1. Open Terminal, enter the project directory, run the `pod install` command, and wait for it to complete.
2. Open the demo project `TUICalling/Example/TUICallingApp.xcworkspace` with Xcode 11.0 or later and click **Run**.

[](id:ui.step4)
### Step 4. Try out the demo

Note: You need to prepare at least two devices to try out the call feature of TUICalling. Here, users A and B represent two different devices:

**Device A (userId: 111)**

- Step 1: On the welcome page, enter the username (<font color=red>which must be unique</font>), such as `111`. 
- Step 2: Enter the different scenario pages, such as video call, based on your scenario and requirements.
- Step 3: Enter `userId` of user B to be called, click **Search**, and click **Call**.

**Device B (userId: 222)**

- Step 1: On the welcome page, enter the username (<font color=red>which must be unique</font>), such as `222`.
- Step 2: Enter the homepage and wait for the call.

## FAQs

### What should I do if the following error messages are still prompted during debugging on a real device when the TUICalling demo has been configured with a real device certificate?

```
Provisioning profile "XXXXXX" doesn't support the Push Notifications capability.  
Provisioning profile "XXXXXX" doesn't include the aps-environment entitlement.
```

You can delete the `Push Notifications` feature as shown below:

![](https://qcloudimg.tencent-cloud.cn/raw/800bfcdc73e1927e24b5419f09ecef7a.png)


## Have any questions?
Welcome to join our Telegram Group to communicate with our professional engineers! We are more than happy to hear from you~
Click to join: https://t.me/+EPk6TMZEZMM5OGY1
Or scan the QR code

<img src="https://qcloudimg.tencent-cloud.cn/raw/9c67ed5746575e256b81ce5a60216c5a.jpg" width="320"/>
