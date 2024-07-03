[English](./README.md) | 简体中文

本文介绍如何快速跑通即时通信 IM 的体验 Demo。

>为尊重表情设计版权，IM Demo/TUIKit 工程中不包含大表情元素切图，正式上线商用前请您替换为自己设计或拥有版权的其他表情包。下图所示默认的小黄脸表情包版权归腾讯云所有，可有偿授权使用，如需获得授权可 [提交工单](https://console.cloud.tencent.com/workorder/category) 联系我们。
>
> <img src="https://qcloudimg.tencent-cloud.cn/image/document/6438e8feb7bba909511e0d798dfaf91d.png" width="300px" />

## 步骤1：创建应用
1. 登录即时通信 IM [控制台](https://console.cloud.tencent.com/avc)。
> 如果您已有应用，请记录其 SDKAppID 并 [配置应用](#step2)。
2. 在应用管理页面，单击创建新应用，在弹出的对话框中输入应用名称，选择合适的数据中心，单击确定。
![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100027937867/6fc4b61ba62d11eeae9a525400c26da5.png?q-sign-algorithm=sha1&q-ak=AKID2R7tLDF_vlveaNTTR3qs7HdRt6tsl0fKDMVHHpXNMxTLgJHsuHp5NYOXM--72JDy&q-sign-time=1705041321;1705044921&q-key-time=1705041321;1705044921&q-header-list=&q-url-param-list=&q-signature=f533fa8be64c49ab562163e56cd4986d0000aff8&x-cos-security-token=9ppkNO9PtSvH4JbxBSmHE82h1D9Fjrua1fcebe235c87f42f214d99e3ddd175ed_G6fbYPfiMADONai5bOUWdr3nJkinW0mqjfc7aTs7AISjyZsb6TZiPj7ZUYZcva29WNd7iyw1w-4N7T1LFRUDyF60aiD-wjM5SKi2Wysl7vCqj-RoeEpjvk7yr0hBEASFcEoyCtYqI_QSH7nVrqXgtbYOJQr5jFbSX96VIxdzSRtw3L_eH58KXNMiplGn1ahlYJ345uR9hOLS0FBRUuXp8XTL2gOSkHwX6qjY-4KlImyS-CfR6HAc6OhHvhtbPJeCdh5g8fZITwQVlMZPRWRUW7N7xAN4jOGNL97wYTjqfjtomp2r2I5yZxLjtC5oDDZN17BIaAwe0TGyLFlnwR1KNQlQ4RuZOsEQJJvYoLOaRVfmvmP4TshXpFMjBJ2ag8a)
![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100027937867/6fbc3f98a62d11ee9fd6525400bb593a.png?q-sign-algorithm=sha1&q-ak=AKIDPwe6pqU-RnSVbdCZrun0wxBi-uXIyd9_u4ElR2nanFdeQ6r68ULdNkBzdahmUsW-&q-sign-time=1705041321;1705044921&q-key-time=1705041321;1705044921&q-header-list=&q-url-param-list=&q-signature=af7f754a00fdb65fd5848145b39bc9bf9185d690&x-cos-security-token=9ppkNO9PtSvH4JbxBSmHE82h1D9Fjruad2fbd6fb6b49030895823ed0dce3d45e_G6fbYPfiMADONai5bOUWdr3nJkinW0mqjfc7aTs7AISjyZsb6TZiPj7ZUYZcva29WNd7iyw1w-4N7T1LFRUDyF60aiD-wjM5SKi2Wysl7vCqj-RoeEpjvk7yr0hBEASFcEoyCtYqI_QSH7nVrqXgtbYOJQr5jFbSX96VIxdzSRtw3L_eH58KXNMiplGn1ahjSj_kgAUbV5ezrtqPU_3Rw6GGTGBYUTg-aY3nLTaAXF9Ls9XPYl2w8GijqlxCtUIytAjiscy5oyaQKcqXpPvrmJYmDaR5Ks4vIQiq2JEAo4euM2IGbU5VvDL89Fc0qcuE5-n6sOjdZ6rzE4iM3g1lEomjV1Ib5BQ-npye-Dh6Wh-ft30xROKz57hEhSHzq6g)
3. 创建完成后，可在应用管理页面查看、搜索、管理应用。请记录 SDKAppID 信息。
![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100027937867/6fcb1f76a62d11ee9939525400461a83.png?q-sign-algorithm=sha1&q-ak=AKIDVD2vIt54ixTf0QhZppp8jvneKnCbCC7cYGuqfWGiD3KwrNqI0kDROe5MSL5Tj2zH&q-sign-time=1705041321;1705044921&q-key-time=1705041321;1705044921&q-header-list=&q-url-param-list=&q-signature=5a0050227ee027c9c84d4be4b90fad73c8470ae2&x-cos-security-token=9ppkNO9PtSvH4JbxBSmHE82h1D9Fjrua2a491a422bb339b62bdf7c4f461e2e36_G6fbYPfiMADONai5bOUWdr3nJkinW0mqjfc7aTs7AISjyZsb6TZiPj7ZUYZcva29WNd7iyw1w-4N7T1LFRUDyF60aiD-wjM5SKi2Wysl7vCqj-RoeEpjvk7yr0hBEASFcEoyCtYqI_QSH7nVrqXgtbYOJQr5jFbSX96VIxdzSRtw3L_eH58KXNMiplGn1ahNgNiQlZ0juftKVUFkiygn_W3rvjSLIm4gpnWISRukeVhBQiorz9m7PF5q-9RkTcfS29DQYvW0sg_ekNdGI0MeDpiOyXjKqcT47hGVTNsy7VyO8MjiuR3RkId6XKpqhePl1cWGATcZII9C6JhUTWDAZxcsDtalFMr35ES8-fOuPVF4Lv0pYbVlx1tWa5vBbDb)

## 步骤2：获取密钥信息

1. 在应用管理页面的操作中单击查看密钥。
![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100027269567/ecb86072b11311ee9fd6525400bb593a.png?q-sign-algorithm=sha1&q-ak=AKIDccwHwiaKs1zZASGFRQ3tNJvDGWsqubRgoI4D_iNrbonzVD4qv7zEEPeuovJM2t2e&q-sign-time=1705041321;1705044921&q-key-time=1705041321;1705044921&q-header-list=&q-url-param-list=&q-signature=d9deb00235c65787247dd560425a99db16dd5c94&x-cos-security-token=GhZpk0pF2CizBUrN0bW5tlarp9KJGD0ab514201872c5cb9444912a8c8c8f9d6bLvvJzap6DWP7R36kGigcgvUMGXYwZ6IqwB8FjO4F96E4SxeYxahI1AltuBfjeMXmfi9HCVNnUJjZvooIQtEUq7IqXLSaryDKcK7O8MXMHyzgvNybEWZow1zB6cJ6dEKsngqDhKc9M41ZjQWsXm-xncp7Rv4gQjLU5uAw9h4L3ko5jEJdtd4G549PvJqIdvhBWgNoQVY3yD7ST-iLPkdnwjZY_Rqd4HlqA5Jh_I9k2kfcjJl60RjR6z8G2oFGUOtwzp4CJqltmWkL8OUDzxHq0ZXVesfBDJUMSonjfcTxdYApBahJz5MZ9el7OE2QpjnqEjYQPqqx-a_Ll898RVIAtqy1T_Y4pWmkxak_eGAqljyFsTA-61p_NfulgjBzMsME)
2. 在弹出的对话框中，单击显示密钥，复制并保存密钥信息。
![](https://write-document-release-1258344699.cos.ap-guangzhou.tencentcos.cn/100027269567/f1d63334b11311eeae9a525400c26da5.png?q-sign-algorithm=sha1&q-ak=AKID9l6AMH0HkGUpETTygUSLq-OdLGol_zYiH5S5YGV_VKPMtI4n5INkaRRiB10WMa5d&q-sign-time=1705041321;1705044921&q-key-time=1705041321;1705044921&q-header-list=&q-url-param-list=&q-signature=4e945e058a1ffcbc287130ecc9ba6a3cce4dde92&x-cos-security-token=9ppkNO9PtSvH4JbxBSmHE82h1D9Fjruab80bda0fa2814297db0adf4ac6bc9c65_G6fbYPfiMADONai5bOUWdr3nJkinW0mqjfc7aTs7AISjyZsb6TZiPj7ZUYZcva29WNd7iyw1w-4N7T1LFRUDyF60aiD-wjM5SKi2Wysl7vCqj-RoeEpjvk7yr0hBEASFcEoyCtYqI_QSH7nVrqXgtbYOJQr5jFbSX96VIxdzSSvkzF659HECTPUQjNANdxvl-Pe7hHa8vk8Gons8iP0PcmSe8YE7VRUSpOKIkfwqZGOOCEyT94A9ilepUP1g93gMh5G9QP9xdjFazstbYu1uc4f4EhWJrZ3XjMZSsXfn9uA2wvmfdJEuSN4B8I0_ifZ3hoad-w2xm34K329ehxdFMawRQ4aKC0EH9Jq3T6FcMWdcog1MedNgGDCkTYqdJlh)

> 请妥善保管密钥信息，谨防泄露。

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