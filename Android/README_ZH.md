[English](./README.md) | 简体中文

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

![](https://qcloudimg.tencent-cloud.cn/raw/c3e75cba79968ebce176d9e97b3bd7bf.png)


>本文提到的获取 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 Demo 和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。

## 步骤4：编译运行（全部功能）
用 Android Studio 导入工程直接编译运行即可。

> **Demo 默认集成了音视频通话功能，由于该功能依赖的音视频 SDK 暂不支持模拟器，请使用真机调试或者运行 Demo。**

## 步骤5：编译运行（移除音视频通话）
如果您不需要音视频通话功能，只需要在 `app 模块` 的 `build.gradle` 文件中删除音视频通话模块集成代码即可：

![](https://im.sdk.qcloud.com/tools/resource/tuicalling/android/GitHubDeleteTUICallKit.jpg)

```groovy
api project(':tuicallkit')
```
操作完上述步骤后会发现，Demo 中的音频通话、视频通话入口均被隐藏。
会话界面屏蔽 TUICallKit 前后的效果：

| 修改之前 | 修改之后|
|--------|------|
|<img src="https://im.sdk.qcloud.com/tools/resource/tuicalling/android/GitHubChatAddTUICallKit.jpg" style="zoom:30%" /> | <img src="https://im.sdk.qcloud.com/tools/resource/tuicalling/android/GitHubChatDeleteTUICallKit.jpg" style="zoom:30%" />|

联系人资料界面屏蔽 TUICallKit 前后的效果：

| 修改之前 | 修改之后|
|--------|------|
| <img src="https://im.sdk.qcloud.com/tools/resource/tuicalling/android/GitHubContactAddTUICallKit.jpg" style="zoom:30%" /> | <img src="https://im.sdk.qcloud.com/tools/resource/tuicalling/android/GitHubContactDeleteTUICallKit.jpg" style="zoom:30%" /> |

> 以上演示的仅仅是 Demo 对移除音视频通话功能的处理，开发者可以按照业务要求自定义。

## 步骤6：编译运行（移除搜索模块）
如果您不需要搜索功能，那么只需要在 `app 模块` 的 `build.gradle` 文件中删除下面一行即可：

![](https://im.sdk.qcloud.com/tools/resource/tuicalling/android/GitHubDeleteTUISearch.jpg)

```groovy
api project(':tuisearch')
```
操作完上述步骤后会发现，Demo 中的消息搜索框被隐藏。

消息界面屏蔽 TUISearch 前后的效果：

![](https://qcloudimg.tencent-cloud.cn/raw/e099c8fe41f3c908cd88573dad6dc820.png)  ![](https://qcloudimg.tencent-cloud.cn/raw/c501170cbb23923d6bacff893b30fdbb.png)

> 以上演示的仅仅是 Demo 对移除搜索功能的处理，开发者可以按照业务要求自定义。