## (English Click [here](#readme_en))
<a name="readme_cn"></a>

本文介绍如何快速跑通即时通信 IM 的体验 Demo。

## 步骤1：创建应用
1. 登录即时通信 IM [控制台](https://console.cloud.tencent.com/avc)。
 >如果您已有应用，请记录其 SDKAppID 并转到 **步骤2**。
 >
2. 在【应用列表】页，单击【创建应用接入】。
3. 在【创建新应用】对话框中，填写新建应用的信息，单击【确认】。
 应用创建完成后，自动生成一个应用标识 SDKAppID，请记录 SDKAppID 信息。

## 步骤2：获取密钥信息

1. 单击目标应用所在行的【应用配置】，进入应用详情页面。
2. 单击【查看密钥】，拷贝并保存密钥信息。
 >请妥善保管密钥信息，谨防泄露。

## 步骤3：下载并配置 Demo 源码

1. 从 [Github](https://github.com/tencentyun/TIMSDK) 克隆即时通信 IM Demo 工程。
2. 打开所属终端目录的工程，找到对应的 `GenerateTestUserSig` 文件。
 <table>
     <tr>
         <th nowrap="nowrap">所属平台</th>  
         <th nowrap="nowrap">文件相对路径</th>  
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
      <td>Mac</td>   
      <td>Mac/Demo/TUIKitDemo/Debug/GenerateTestUserSig.h</td>   
     </tr>  
  <tr>      
      <td>Windows</td>   
      <td>Windows/Demo/IMApp/GenerateTestUserSig.h</td>   
     </tr>  
  <tr>      
      <td>Web（通用）</td>   
      <td>Web/Demo/public/debug/GenerateTestUserSig.js</td>   
     </tr>  
  <tr>      
      <td>小程序</td>   
      <td>MiniProgram/Demo/static/utils/GenerateTestUserSig.js</td>   
     </tr>  
</table>


 >本文以使用 Android Studio 打开 Android 工程为例。
  >
3. 设置 `GenerateTestUserSig` 文件中的相关参数：
 - SDKAPPID：请设置为 **步骤1** 中获取的实际应用 SDKAppID。
 - SECRETKEY：请设置为 **步骤2** 中获取的实际密钥信息。
![](https://qcloudimg.tencent-cloud.cn/raw/3595b35bc8c88b7361a48ba1c6dbe7c4.png)


>本文提到的获取 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。

## 步骤4：编译运行（全部功能）
用 Android Studio 导入工程直接编译运行即可。

## 步骤5：编译运行（移除音视频通话）
如果您不需要音视频通话功能，只需要在 `app 模块` 的 `build.gradle` 文件中删除音视频通话模块集成代码即可：

![](https://qcloudimg.tencent-cloud.cn/raw/165720d20832f59f1060f58744f05df3.jpeg)

```groovy
api project(':tuicalling')
```
操作完上述步骤后会发现，Demo 中的音频通话、视频通话入口均被隐藏。
会话界面屏蔽 TUICalling 前后的效果：

![](https://qcloudimg.tencent-cloud.cn/raw/11d6846dc76aedcda15f6f70b78c59c7.png) ![](https://qcloudimg.tencent-cloud.cn/raw/ca116e25894a6ba72d49e2507cc213ba.png)

联系人资料界面屏蔽 TUICalling 前后的效果：

![](https://qcloudimg.tencent-cloud.cn/raw/98df67c187384445432d490f6c0f7847.png)  ![](https://qcloudimg.tencent-cloud.cn/raw/b604eeac45f0a2cf5924d23567c69090.png)

> 以上演示的仅仅是 Demo 对移除音视频通话功能的处理，开发者可以按照业务要求自定义。

## 步骤6：编译运行（移除搜索模块）
如果您不需要搜索功能，那么只需要在 `app 模块` 的 `build.gradle` 文件中删除下面一行即可：

![](https://qcloudimg.tencent-cloud.cn/raw/571213fddf6c70354dd6f01b05d29e2f.jpeg)

```groovy
api project(':tuisearch')
```
操作完上述步骤后会发现，Demo 中的消息搜索框被隐藏。

消息界面屏蔽 TUISearch 前后的效果：

![](https://qcloudimg.tencent-cloud.cn/raw/e099c8fe41f3c908cd88573dad6dc820.png)  ![](https://qcloudimg.tencent-cloud.cn/raw/c501170cbb23923d6bacff893b30fdbb.png)

> 以上演示的仅仅是 Demo 对移除搜索功能的处理，开发者可以按照业务要求自定义。

------------------------------
## (中文版本请参看[这里](#readme_cn))
<a name="readme_en"></a>

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
![](https://qcloudimg.tencent-cloud.cn/raw/429009b53771dacd14a9f4ac753132a5.png)


> In this document, the method to obtain UserSig is to configure a SECRETKEY in the client code. In this method, the SECRETKEY is vulnerable to decompilation and reverse engineering. Once your SECRETKEY is leaked, attackers can steal your Tencent Cloud traffic. Therefore, **this method is only suitable for locally running a demo project and feature debugging**.
>The correct `UserSig` distribution method is to integrate the calculation code of `UserSig` into your server and provide an application-oriented API. When `UserSig` is needed, your app can send a request to the business server for a dynamic `UserSig`. For more information, please see [How do I calculate UserSig on the server?](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig).

## Step 4: Compile and Run the Demo (All Features)
Import the demo project with Android Studio, and then compile and run it.

## Step 5: Compile and Run the Demo (Removing the Audio/Video Call Feature)
If you do not need the audio/video call feature, you only delete the audio/video call integration code as shown in the figure below from the `build.gradle` file under the `app` module:

![](https://qcloudimg.tencent-cloud.cn/raw/be4673087f137a26df082c94ee74db3a.png)

```groovy
api project(':tuicalling')
```
After the preceding steps are completed, the audio and video call entries in the demo are hidden.
The conversation UIs before and after TUICalling masking are as follows:

![](https://qcloudimg.tencent-cloud.cn/raw/11d6846dc76aedcda15f6f70b78c59c7.png) ![](https://qcloudimg.tencent-cloud.cn/raw/ca116e25894a6ba72d49e2507cc213ba.png)

The contact profile UIs before and after TUICalling masking are as follows:

![](https://qcloudimg.tencent-cloud.cn/raw/98df67c187384445432d490f6c0f7847.png)  ![](https://qcloudimg.tencent-cloud.cn/raw/b604eeac45f0a2cf5924d23567c69090.png)

> The above only shows how to remove the audio/video call feature from the demo. Developers can customize the demo according to their business requirements.

## Step 6: Compile and Run the Demo (Removing the Search Module)
If you do not need the search feature, you only delete the line of code as shown in the figure below from the `build.gradle` file under the `app` module:

![](https://qcloudimg.tencent-cloud.cn/raw/465b011dc5447eba484f7390818aef18.png)

```groovy
api project(':tuisearch')
```
After the preceding steps are completed, the message search box in the demo is hidden.

The message UIs before and after TUISearch masking are as follows:

![](https://qcloudimg.tencent-cloud.cn/raw/e099c8fe41f3c908cd88573dad6dc820.png)  ![](https://qcloudimg.tencent-cloud.cn/raw/c501170cbb23923d6bacff893b30fdbb.png)

> The above only shows how to remove the search feature from the demo. Developers can customize the demo according to their business requirements.