English | [简体中文](./README_ZH.md)

This document introduces how to quickly run through the IM demo.

## Step 1. Create an App
1. Log in to the [IM console](https://intl.cloud.tencent.com/login).
> If you already have an app, record its SDKAppID and [configure the app](#step2).
2. Click **Create Application**, enter your app name, and click **Confirm**.
![](https://cloudcache.intl.tencent-cloud.com/cms/backend-cms/2dc3464956bd11ee974d5254005f490f.png)
3. After creation, you can see the status, service version, SDKAppID, creation time, tag, and expiry time of the new app on the overview page of the console. Record the SDKAppID.
![](https://cloudcache.intl.tencent-cloud.com/cms/backend-cms/2dc4751956bd11ee94c3525400d793d0.png)

## Step 2: Obtain Key Information

1. Click the **target app card** to go to the **basic configuration** page of the app.
![](https://cloudcache.intl.tencent-cloud.com/cms/backend-cms/2de94e1b56bd11ee94c3525400d793d0.png)
2. In the Basic Information area, click Display key, and then copy and save the key information.
> Please store the key information properly to prevent leakage.

![](https://cloudcache.intl.tencent-cloud.com/cms/backend-cms/2de94e1b56bd11ee94c3525400d793d0.png)

## Step 3: Download and Configure the Demo Source Code

1. Clone the IM demo project from [GitHub](https://github.com/tencentyun/TIMSDK).
2. Open the project in the terminal directory and find the `GenerateTestUserSig` file.
<table>
<tr>
<th nowrap="nowrap">Platform</th>  
<th nowrap="nowrap">Relative Path to File</th>  
</tr>
<tr>      
<td>Android</td>   
<td>Android/Demo/app/src/main/java/com/tencent/qcloud/tim/demo/signature/GenerateTestUserSig.java</td>   
</tr> 
<tr>
<td>iOS</td>   
<td>iOS/Demo/TUIKitDemo/Debug/GenerateTestUserSig.h</td>
</tr> 
<tr>      
<td>macOS</td>   
<td>Mac/Demo/TUIKitDemo/Debug/GenerateTestUserSig.h</td>   
</tr>  
<tr>      
<td>Windows</td>   
<td>Windows/Demo/IMApp/GenerateTestUserSig.h</td>   
</tr>  
<tr>      
<td>Web (general)</td>   
<td>Web/Demo/public/GenerateTestUserSig.js</td>   
</tr>  
<tr>      
<td>Mini Program</td>   
<td>MiniProgram/Demo/static/utils/GenerateTestUserSig.js</td>   
</tr>  
</table>

>? In this document, an Android project is opened by using Android Studio as an example.
>
3. Set relevant parameters in the `GenerateTestUserSig` file:
- SDKAPPID: set it to the SDKAppID obtained in [Step 1](#step1).
- SECRETKEY: enter the key obtained in [Step 2](#step2).
![](https://qcloudimg.tencent-cloud.cn/raw/487fe57e41ae261f3bbf86c830584afa.png)


>! In this document, the method to obtain UserSig is to configure a SECRETKEY in the client code. In this method, the SECRETKEY is vulnerable to decompilation and reverse engineering. Once your SECRETKEY is leaked, attackers can steal your Tencent Cloud traffic. Therefore, **this method is only suitable for locally running a demo project and feature debugging**.
>The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your app can send a request to the business server for a dynamic `UserSig`. For more information, please see [How do I calculate UserSig on the server?](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig).

## Step 4: Compile and Run the Demo
1. Run the following command on the terminal to check the pod version:
```
pod --version
```
  If the system indicates that no pod exists or that the pod version is earlier than 1.7.5, run the following commands to install the latest pod.
```
// Change sources.
gem sources --remove https://rubygems.org/
gem sources --add https://gems.ruby-china.com/
// Install pod.
sudo gem install cocoapods -n /usr/local/bin
// If multiple versions of Xcode are installed, run the following command to choose an Xcode version (usually the latest one):
sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
// Update the local pod library.
pod setup
```
2. Run the following commands to load the IMSDK library.
```
cd Mac/TUIKitDemo
pod install
```
3. If installation fails, run the following command to update the local CocoaPods repository list:
```
pod repo update
```
4. Go to the Mac/TUIKitDemo folder, and open `TUIKitDemo.xcworkspace` to compile and run the demo.