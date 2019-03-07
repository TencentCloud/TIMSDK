
本文主要介绍如何快速地将腾讯云即时通信Demo工程运行起来，您只需参考如下步骤依次执行即可。

## 1. 创建应用
进入腾讯云通讯（IM）[控制台](https://console.cloud.tencent.com/avc)，会出现“应用列表”，单击“创建应用接入”，会出现下图的内容：
![](https://main.qcloudimg.com/raw/27314e92cd2972a8eada8cfba4055ac6.png)

创建应用后，腾讯云会给您的新应用分配一个应用标识：sdkappid，如下图：
![](https://main.qcloudimg.com/raw/a2c23af3e5a969ff15a6f6fc6889b5d4.png)

## 2. 配置应用
完成创建应用之后返回应用列表，单击相应应用的“应用配置”链接，在新页面中，找到当前页面的**帐号体系集成**部分，单击“编辑”链接：
![](https://main.qcloudimg.com/raw/4e3d70639adf628f90e9d69cc683c423.png)

>账号管理员可以随便填写，在使用云通讯后台的 REST API 发送消息时才会用到。

## 3. 获取测试userSig
点击**下载公私钥**的链接，即可获得一个名为 **keys.zip** 的压缩包，解压后可以得到两个文件，即 public_key 和 private_key，用记事本打开 **private_key** 文件，并将其中的内容拷贝到**开发辅助工具**的私钥文本输入框中。

其中：**identifier** 即为你的测试账号（也就是 userId），私钥为 private_key 文件里的文本内容，生成的签名就是**userSig**。identifier 和 userSig 是一一对应的关系。

![](https://main.qcloudimg.com/raw/a1b9bb35760e1e52825c754bd3ef9a52.png)

> 可以多生成4组以上的 userid 和 usersig，方便在第5步中调试使用。


## 4. 下载 Demo 源码
下载 ImSDK Windows IMApp 工程代码。


## 5. 修改源码配置
- 使用 Visual Stuido（建议 VS2015）双击源码目录下的 ImApp.sln 工程文件，打开 ImApp 工程

- 工程中默认配置了测试的 SDKAPPID 以及在控制台生成的四个测试账号，由于每个账号同时只能有一个端登录，所以您需要按照 step 3 中指引拿到自己的四组测试账号配置进去。

- 在 文件main.cpp 中替换您的 SDKAPPID，以及替换 step 3 中指引拿到的 userId 和 userSig。
![](https://main.qcloudimg.com/raw/3440cb91cac41c6e84b584fdb2c8543f.png)

> ! 这里提到的获取 userid 和 usersig 的方案仅适合本地跑通demo和功能调试，userSig 正确的签发方式请参考 [服务器获取方案](https://cloud.tencent.com/document/product/269/1507)。

## 6. 编译运行
程序启动后，在不同的客户端上登录不同的账号，搜索对方的 userId 创建会话，就可以体验发消息了。
