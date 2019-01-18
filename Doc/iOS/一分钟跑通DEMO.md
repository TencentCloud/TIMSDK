
本文主要介绍如何快速地将腾讯云即时通信Demo工程运行起来，您只需参考如下步骤依次执行即可。

## 1. 创建应用
进入腾讯云通讯（IM）[控制台](https://console.cloud.tencent.com/avc)，会出现“应用列表”，单击“创建应用接入”，会出现下图的内容：
![](https://main.qcloudimg.com/raw/27314e92cd2972a8eada8cfba4055ac6.png)

创建应用后，腾讯云会给您的新应用分配一个应用标识：sdkappid，如下图：
![](https://main.qcloudimg.com/raw/826b903373db7cff2adebec6fa3a40a8.png)

## 2. 配置应用
完成创建应用之后返回应用列表，单击相应应用的“应用配置”链接，在新页面中，找到当前页面的**帐号体系集成**部分，单击“编辑”链接：
![](https://main.qcloudimg.com/raw/e3ce0ef527d2d4f8d0b3a0f69cefa78e.png)

>账号管理员可以随便填写，在使用云通讯后台的 REST API 发送消息时才会用到。

## 3. 获取测试userSig
点击**下载公私钥**的链接，即可获得一个名为 **keys.zip** 的压缩包，解压后可以得到两个文件，即 public_key 和 private_key，用记事本打开 **private_key** 文件，并将其中的内容拷贝到**开发辅助工具**的私钥文本输入框中。

其中：**identifier** 即为你的测试账号（也就是 userId），私钥为 private_key 文件里的文本内容，生成的签名就是**userSig**。identifier 和 userSig 是一一对应的关系。

![](https://main.qcloudimg.com/raw/a1b9bb35760e1e52825c754bd3ef9a52.png)

> 可以多生成4组以上的 userid 和 usersig，方便在第5步中调试使用。

## 4. 下载 Demo源码
从 [Git](https://github.com/tencentyun/TIMSDK) 下载 ImSDK iOS开发包，打开TUIKitDemo工程。
![](https://main.qcloudimg.com/raw/45f395119c820d5da88f7124174c013f.png)

## 5. 配置工程
根据步骤二获取的SdkAppid 和 AccountType 、步骤三获取的四对 identifier 和 userSig，参考下图在 Demo 工程 AppDelegate.h 文件配置。
![](https://main.qcloudimg.com/raw/de93117513ed5ae405f3a65448ef32e5.png)
> ! 这里提到的获取 userid 和 usersig 的方案仅适合本地跑通demo和功能调试，userSig 正确的签发方式请参考 [服务器获取方案](https://cloud.tencent.com/document/product/269/1507)。

## 6. 编译运行
APP启动后，在不同的手机上登录不同的账号，就可以搜索对方的 userId 体验发消息了。

