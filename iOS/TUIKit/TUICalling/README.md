本文档主要介绍如何快速集成实时音视频（TRTC）SDK，运行 TRTC 场景化解决方案，实现实时视频/语音通话。
	
## 目录结构
	
```
TUICalling
├─ App				// 视频/语音通话主页UI代码以及用到的图片及国际化字符串资源文件夹
├─ Debug			// 工程调试运行所需的关键业务代码文件夹
├─ LoginMock		// 登录UI及业务逻辑代码文件夹
├─ Resources		// 视频/语音通话功能所需的图片、国际化字符串资源文件夹
├─ Source			// 视频/语音通话核心业务逻辑代码文件夹
└─ TXAppBasic		// 工程依赖的基础组件
```
	
## 环境准备
- Xcode 11.0及以上版本
- 最低支持系统：iOS 13.0
- 请确保您的项目已设置有效的开发者签名
	
## 运行示例
	
### 前提条件
- 您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 账号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。
	
### 申请 SDKAPPID 和 SECRETKEY
1. 登录实时音视频控制台，选择【开发辅助】>【[快速跑通Demo](https://console.cloud.tencent.com/trtc/quickstart)】。
2. 单击【立即开始】，输入您的应用名称，例如`TestTRTC`，单击【创建应用】。
<img src="https://main.qcloudimg.com/raw/169391f6711857dca6ed8cfce7b391bd.png" width="650" height="295"/>
3. 创建应用完成后，单击【我已下载，下一步】，可以查看 SDKAppID 和密钥信息。

### 集成SDK
1. 工程默认集成的是`TXLiteAVSDK_TRTC`精简版SDK，您可通过【[官网链接](https://cloud.tencent.com/document/product/647/32689)】了解此版本SDK的具体功能。
2. SDK集成方式默认使用`Cocoapods`，工程目录下`Podfile`文件内已帮您添加了SDK的依赖`pod 'TXLiteAVSDK_TRTC'`，您只需要打开终端进入到工程目录下执行`pod install`，SDK就会自动集成。

### 配置工程文件
1. 使用Xcode(11.0及以上)打开源码工程`TUICallingApp.xcworkspace`。
2. 工程内找到`TUICalling/Debug/GenerateTestUserSig.swift`文件 。
3. 设置`GenerateTestUserSig.swift`文件中的相关参数：
<ul>
<li>SDKAPPID：默认为 0 ，请设置为实际申请的SDKAPPID。</li>
<li>SECRETKEY：默认为空字符串，请设置为实际申请的SECRETKEY。</li>
</ul>
<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/sdkappid_secretkey_ios.png">
4. 返回实时音视频控制台，单击【粘贴完成，下一步】。
5. 单击【关闭指引，进入控制台管理应用】。

>!本文提到的生成 UserSig 的方案是在客户端代码中配置 SECRETKEY，该方法中 SECRETKEY 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通工程和功能调试**。
>正确的 UserSig 签发方式是将 UserSig 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。

### 编译运行
- 使用 Xcode（11.0及以上的版本）打开源码工程 `TUICalling/TUICallingApp.xcworkspace`，单击【运行】即可开始调试本 App。

### 体验应用（**体验应用至少需要两台设备**）

#### 用户 A

步骤1、输入用户名(<font color=red>请确保用户名唯一性，不能与其他用户重复</font>)，如图示：

<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/user_a_ios.png" width="320"/>

步骤2、输入要拨打的用户名，点击搜索，如下图示：

<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/tuicalling_user_ios.PNG" width="320"/>

步骤3、点击呼叫，选择拨打**语音通话**或者**视频通话**（<font color=red>请确保被叫方保持在应用内，否则可能会拨打失败</font>）；

<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/tuicalling_call_ios.PNG" width="320"/>

#### 用户 B

步骤1、输入用户名(<font color=red>请确保用户名唯一性，不能与其他用户重复</font>)，如图示：

<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/user_b_ios.png" width="320"/>

步骤2、进入主页，等待接听来电；
## 常见问题
#### 1. 查看密钥时只能获取公钥和私钥信息，该如何获取密钥？
TRTC SDK 6.6 版本（2019年08月）开始启用新的签名算法 HMAC-SHA256。在此之前已创建的应用，需要先升级签名算法才能获取新的加密密钥。如不升级，您也可以继续使用 [老版本算法 ECDSA-SHA256](https://cloud.tencent.com/document/product/647/17275#.E8.80.81.E7.89.88.E6.9C.AC.E7.AE.97.E6.B3.95)，如已升级，您按需切换为新旧算法。

升级/切换操作：

 1. 登录 [实时音视频控制台](https://console.cloud.tencent.com/trtc)。
 2. 在左侧导航栏选择【应用管理】，单击目标应用所在行的【应用信息】。
 3. 选择【快速上手】页签，单击【第二步 获取签发UserSig的密钥】区域的【点此升级】、【非对称式加密】或【HMAC-SHA256】。
  
  - 升级：
   
   ![](https://main.qcloudimg.com/raw/69bd0957c99e6a6764368d7f13c6a257.png)
   
  - 切换回老版本算法 ECDSA-SHA256：
  
   ![](https://main.qcloudimg.com/raw/f89c00f4a98f3493ecc1fe89bea02230.png)
   
  - 切换为新版本算法 HMAC-SHA256：
  
   ![](https://main.qcloudimg.com/raw/b0412153935704abc9e286868ad8a916.png)
   

#### 2. 两台手机同时运行工程，为什么看不到彼此的画面？
请确保两台手机在运行工程时使用的是不同的 UserID，TRTC 不支持同一个 UserID （除非 SDKAppID 不同）在两个终端同时使用。
<img src="https://liteav.sdk.qcloud.com/doc/res/trtc/picture/zh-cn/login_userid_ios.png" width="320"/>

#### 3. 防火墙有什么限制？
由于 SDK 使用 UDP 协议进行音视频传输，所以在对 UDP 有拦截的办公网络下无法使用。如遇到类似问题，请参考 [应对公司防火墙限制](https://cloud.tencent.com/document/product/647/34399) 排查并解决。



	
