
本文主要介绍如何快速地将腾讯云云通信 IM Demo(Windows) 工程运行起来，您只需参考如下步骤依次执行即可。

## 1. 创建应用
登录腾讯云通信（IM）[控制台](https://console.cloud.tencent.com/avc)，在**应用列表**页，单击【创建应用接入】，在**创建新应用**弹框中，填写新建应用的信息，单击【确认】。
![](https://main.qcloudimg.com/raw/a7769d15f050286162b0cbcdadca5f03.png)

应用创建完成后，自动生成一个应用标识：SDKAppID，如下图：
![](https://main.qcloudimg.com/raw/bf8fe4f38d782741a6e142c24648c9e0.png)

## 2. 配置应用
完成创建应用之后返回应用列表，单击对应 SDKAppID 的【应用配置】链接，在应用详情页，找到当前页面的【帐号体系集成】部分，单击【编辑】链接，配置【帐号管理员】信息，然后单击【保存】。

>?帐号管理员可以随便填写，在使用云通信后台的 REST API 发送消息时才会用到。

![](https://main.qcloudimg.com/raw/e3ce0ef527d2d4f8d0b3a0f69cefa78e.png)


## 3. 下载公私钥
完成帐号管理员配置后，单击【下载公私钥】的链接，即可获得一个名为 **keys.zip** 的压缩包。解压后可以得到两个文件，即 public_key 和 private_key，用记事本打开 **private_key** 文件。


## 4. 下载 Demo 源码
从 [Github](https://github.com/tencentyun/TIMSDK) 下载 IM SDK Windows IMApp 工程代码。

![](https://main.qcloudimg.com/raw/356319843b9560be6a9b17a679659a4b.png)

## 5. 修改源码配置
- 使用 Visual Stuido（建议 VS2015）双击源码目录下的 ImApp.sln 工程文件，打开 IMApp 工程后，打开 TestUserSigGenerator.h 文件。

- 在工程中配置测试的 SDKAppId 。

  ![](https://main.qcloudimg.com/raw/d806d77c00b146371c3142d11ae123a1.png)

- 在工程中配置测试的私钥 ，用作生成 userSig 。

  ![](https://main.qcloudimg.com/raw/115e1d17d5e773394aefd08b973b43de.png)

- 在文件 main.cpp 中查看您测试的 userId。

  ![](https://main.qcloudimg.com/raw/33834ecf83cf6e1976df2418afe826f1.png)

>! 这里提到的获取 userid 和 usersig 的方案仅适合本地跑通 Demo 和功能调试，userSig 正确的签发方式请参考  [登录鉴权](https://cloud.tencent.com/document/product/269/31999) 文档。

## 6. 编译运行
程序启动后，在不同的客户端上登录不同的帐号，搜索对方的 userId 创建会话，就可以体验发消息了。
