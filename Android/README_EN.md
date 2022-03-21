
English | [简体中文](./README.md)

This document introduces how to quickly run through the IM demo.

## Step 1. Create an App
1. Log in to the [IM console](https://intl.cloud.tencent.com/login).
 >If you already have an app, record its SDKAppID and go to **step 2**.
 >
2. On the **Application List** page, click **Create Application**.
3. In the **Create Application** dialog box, enter the app information and click **Confirm**.
 After the app is created, an app ID (SDKAppID) will be automatically generated, which should be noted down.

## Step 2: Obtain Key Information

1. Click **Application Configuration** in the row of the target app to enter the app details page.
2. Click **View Key** and copy and save the key information.
 > Please store the key information properly to prevent leakage.

## Step 3: Download and Configure the Demo Source Code

1. Clone the IM demo project from [GitHub](https://github.com/tencentyun/TIMSDK).
2. Open the project in the terminal directory and find the `GenerateTestUserSig` file in the following paths:
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
      <td>iOS/Demo/TUIKitDemo/Private/GenerateTestUserSig.h</td>
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
      <td>Web/Demo/public/debug/GenerateTestUserSig.js</td>   
     </tr>  
  <tr>      
      <td>Mini Program</td>   
      <td>MiniProgram/Demo/static/utils/GenerateTestUserSig.js</td>   
     </tr>  
</table>


 >In this document, an Android project is opened by using Android Studio as an example.
  >
3. Set relevant parameters in the `GenerateTestUserSig` file:
 - SDKAPPID: set it to the SDKAppID obtained in **step 1**.
 - SECRETKEY: enter the actual key information obtained in **step 2**.

![](https://qcloudimg.tencent-cloud.cn/raw/bc39d074e1c70cfe6541971836f8dc56.png)

> In this document, the method to obtain UserSig is to configure a SECRETKEY in the client code. In this method, the SECRETKEY is vulnerable to decompilation and reverse engineering. Once your SECRETKEY is leaked, attackers can steal your Tencent Cloud traffic. Therefore, **this method is only suitable for locally running a demo project and feature debugging**.
>The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your app can send a request to the business server for a dynamic `UserSig`. For more information, please see [How do I calculate UserSig on the server?](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig).

## Step 4: Compile and Run the Demo (All Features)
Import the demo project with Android Studio, and then compile and run it.

## Step 5: Compile and Run the Demo (Removing the Audio/Video Call Feature)
If you do not need the audio/video call feature, you only delete the audio/video call integration code as shown in the figure below from the `build.gradle` file under the `app` module:

![](https://qcloudimg.tencent-cloud.cn/raw/cd9e13bec6a5ac6ea67d1aeecfa5e9be.png)

```groovy
api project(':tuicalling')
```
After the preceding steps are completed, the audio and video call entries in the demo are hidden.
The conversation UIs before and after TUICalling masking are as follows:

| before | After |
|---------|---------|
| ![](https://qcloudimg.tencent-cloud.cn/raw/760e9de375121f01f4b385d101c30157.png) | ![](https://qcloudimg.tencent-cloud.cn/raw/71b73179123f1fc0201eca1f8b20e3ec.png)

The contact profile UIs before and after TUICalling masking are as follows:

| before | After |
|---------|---------|
| ![](https://qcloudimg.tencent-cloud.cn/raw/5f0f2c490267ab4986d68a8c54f1e1fa.png) | ![](https://qcloudimg.tencent-cloud.cn/raw/a722756f50dcf96fe120c9dccb7dee44.png)

> The above only shows how to remove the audio/video call feature from the demo. Developers can customize the demo according to their business requirements.

## Step 6: Compile and Run the Demo (Removing the Search Module)
If you do not need the search feature, you only delete the line of code as shown in the figure below from the `build.gradle` file under the `app` module:

![](https://qcloudimg.tencent-cloud.cn/raw/70c328a1ef45eb844d946f86ba65941e.png)

```groovy
api project(':tuisearch')
```
After the preceding steps are completed, the message search box in the demo is hidden.

The message UIs before and after TUISearch masking are as follows:

| before | After |
|---------|---------|
| ![](https://qcloudimg.tencent-cloud.cn/raw/a5da1ef2be61d395a3fb7a54c117afc0.png) | ![](https://qcloudimg.tencent-cloud.cn/raw/84223f91d5681b7c15d333f5743044a2.png)

> The above only shows how to remove the search feature from the demo. Developers can customize the demo according to their business requirements.