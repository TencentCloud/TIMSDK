本文主要介绍如何快速地运行云通信 IM Demo（Android）工程。

<span id="step1"></span>
## 创建应用
1. 登录云通信 IM [控制台](https://console.cloud.tencent.com/avc)。
 >如果您已有应用，请记录其 SDKAppID 并 [配置应用](#step2)。
 >
2. 在【应用列表】页，单击【创建应用接入】。
 ![](https://main.qcloudimg.com/raw/a7769d15f050286162b0cbcdadca5f03.png)
3. 在【创建新应用】对话框中，填写新建应用的信息，单击【确认】。
 应用创建完成后，自动生成一个应用标识 SDKAppID，请记录 SDKAppID 信息。
 ![](https://main.qcloudimg.com/raw/bf8fe4f38d782741a6e142c24648c9e0.png)

<span id="step2"></span>
## 配置应用
1. 单击目标应用所在行的【应用配置】，进入应用详情页面。
 ![](https://main.qcloudimg.com/raw/e41602a50754be9d478b9db84c0bcff2.png)
2. 单击【帐号体系集成】右侧的【编辑】，配置**帐号管理员**信息，单击【保存】。
 ![](https://main.qcloudimg.com/raw/2ad153a77fe6f838633d23a0c6a4dde1.png)

<span id="step3"></span>
## 下载公私钥

1. 在控制台应用详情页面，单击【下载公私钥】，保存 **keys.zip** 压缩文件。
 ![](https://main.qcloudimg.com/raw/e11d958bc43b09fb41c7064ee2b09722.png)
2. 解压 **keys.zip** 文件 ，获得 **private_key.txt** 和 **public_key.txt** 文件，其中 **private_key.txt** 即为私钥文件。
 ![](https://main.qcloudimg.com/raw/ec89f5bb93d57de1acffa4e15786da11.png)

## 下载 Demo 源码
从 [Github](https://github.com/tencentyun/TIMSDK/tree/master/Android) 下载云通信 IM Demo（Android）工程。

## 修改源码配置
1. 使用 Android Studio （3.0以上的版本）打开源码工程。
2. 打开 /TIMSDK/Android/app/src/main/java/com/tencent/qcloud/tim/demo/utils/Constants.java 文件，将工程中默认的 SDKAppID 替换成 [创建应用](#step1) 中获取的 SDKAppID。
 ![](https://main.qcloudimg.com/raw/260d0bea33a644b519fd11d612df770b.png)
3. 打开 /TIMSDK/Android/app/src/main/java/com/tencent/qcloud/tim/demo/signature/GenerateTestUserSig.java 文件 ，将常量 **PRIVATEKEY** 的值设置为 [下载公私钥](#step3) 中获得的私钥文件内容。
 ![](https://main.qcloudimg.com/raw/d9e6f60bbe4b6c23fa3886ab16a4afd3.png)
4. 通过 **GenerateTestUserSig** 中的 **genTestUserSig** 方法，自动帮您获取测试 **UserSig** 。

>!本文提到的获取 UserSig 的方案是在客户端代码中配置 PRIVATEKEY，该方法中 PRIVATEKEY 很容易被反编译逆向破解，一旦您的私钥泄露，攻击者就可以盗用您的腾讯云流量，因此该方法仅适合本地跑通 Demo 和功能调试。
>**正确的 UserSig 签发方式是将 UserSig 的计算代码放在您的业务服务器上，并提供面向 App 的服务端接口，在需要 UserSig 时由您的 App 向业务服务器发起请求获取动态 UserSig。**更多详情请参见 [服务器生成 UserSig](https://cloud.tencent.com/document/product/269/32688#.E6.9C.8D.E5.8A.A1.E5.99.A8.E7.94.9F.E6.88.90-usersig)。

## 编译运行
App 启动后，在不同的手机上登录不同的帐号，搜索对方的 UserID 创建会话，即可体验发送消息等功能。
会话列表以及通讯录相关界面演示：
<div>
<img src="https://cdn.nlark.com/yuque/0/2019/gif/367185/1560518740493-e5a89223-4cb4-44df-a9a5-665e78b67983.gif#align=left&display=inline&height=674&name=%E4%BC%9A%E8%AF%9D%E5%88%97%E8%A1%A8.gif&originHeight=674&originWidth=380&size=319844&status=done&width=380" width="300" height="535">
</div>
聊天界面收发消息演示：
<div>
<img src="https://cdn.nlark.com/yuque/0/2019/gif/367185/1560519391978-f7dbd5fa-8ee7-4b4c-9e71-c7e8d6c5b01b.gif#align=left&display=inline&height=674&name=%E8%81%8A%E5%A4%A9%E6%BC%94%E7%A4%BA.gif&originHeight=674&originWidth=380&size=918355&status=done&width=380" width="300" height="535">
</div>
输入区域自定义部分功能演示：
<div>
<img src="https://cdn.nlark.com/yuque/0/2019/gif/366128/1559825875054-fdfb0919-1f59-4382-924a-b2197f813ab4.gif#align=left&display=inline&height=533&name=add.gif&originHeight=1920&originWidth=1080&size=547272&status=done&width=300" width="300" height="535">
</div>
输入区域自定义按钮事件演示：
<div>
<img src="https://cdn.nlark.com/yuque/0/2019/gif/366128/1559825509248-ebb52b9b-8fee-421f-ad32-f2a12192167c.gif#align=left&display=inline&height=533&name=replace%2B.gif&originHeight=1920&originWidth=1080&size=177751&status=done&width=300" width="300">
</div>
输入区域自定义全部功能演示：
<div>
<img src="https://cdn.nlark.com/yuque/0/2019/gif/366128/1559826601807-394ea189-6188-47e7-bfe8-bb19c67b9dbb.gif#align=left&display=inline&height=587&name=new.gif&originHeight=1920&originWidth=1080&size=508813&status=done&width=330" width="300" height="535">
</div>
