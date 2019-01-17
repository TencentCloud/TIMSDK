
本文主要介绍如何快速地将腾讯云即时通信Demo工程运行起来，您只需参考如下步骤依次执行即可。

## 1. 创建应用
进入腾讯云通信 [控制台](https://console.cloud.tencent.com/avc/list)，单击“创建应用接入”，会出现下图的内容，您按照您的需要进行应用的创建，
![](https://main.qcloudimg.com/raw/14a392ce346a812dca533282692d8360.png)

创建应用后，会给您分配一个应用标识：sdkappid，接下来进入“帐号集成”。

## 2. 帐号集成
完成创建应用之后返回应用列表，单击相应应用的“应用配置”链接，
![](https://main.qcloudimg.com/raw/944ba26dbf293fd971eb20ee40d0d672.png)

在新的页面内容中，找到当前页面的帐号体系集成部分，单击“编辑”链接，
![](https://main.qcloudimg.com/raw/32b3023bee01dbb4214d6efb6d214921.png)

帐号名称相当于是应用所属系列的名称，多个应用可以使用相同的，如果之前创建过应用，下拉列表中可以看到之前应用使用的帐号名称。

集成模式使用 [独立模式](https://cloud.tencent.com/document/product/269/1507)。

下面是帐号集成完成后应用的配置页面，
![](https://main.qcloudimg.com/raw/70a9d5f3846dac7eb6a288aa3b425b9d.png)

## 3. 获取测试userSig
点击**下载公私钥**的链接，即可获得一个名为 **keys.zip** 的压缩包，解压后可以得到两个文件，即 public_key 和 private_key，用记事本打开 **private_key** 文件，并将其中的内容拷贝到**开发辅助工具**的私钥文本输入框中。

其中：**identifier** 即为你的测试账号（也就是 userId），私钥为 private_key 文件里的文本内容，生成的签名就是**userSig**。identifier 和 userSig 是一一对应的关系。

![](https://main.qcloudimg.com/raw/a1b9bb35760e1e52825c754bd3ef9a52.png)

> 可以多生成4组以上的 userid 和 usersig，方便在第5步中调试使用。


## 4. 下载 Demo 源码
从 [Github](https://github.com/TencentVideoCloudIM/TIMSDK) 下载 ImSDK Android开发包，打开tuikit工程。

## 5. 修改源码配置
- 使用 Android Studio （3.0 以上的版本）  打开源码工程。

- 工程中默认配置了测试的 SDKAPPID 以及在控制台生成的四个测试账号，由于每个账号同时只能有一个端登录，所以您需要按照 step 3 中指引拿到自己的四组测试账号配置进去。

- 在 com.tencent.qcloud.uipojo.utils.Constants 中替换您的 SDKAPPID。
![](https://main.qcloudimg.com/raw/b6cec2fd99c8350f4781304d96d28653.png)

- 在com.tencent.qcloud.uipojo.login.view.LoginActivity中替换 step 3 中指引拿到 userId 和 userSig 。
![](https://main.qcloudimg.com/raw/976f87fe676546bfc93fc3dcb04bc97e.png)

> ! 这里提到的获取 userid 和 usersig 的方案仅适合本地跑通demo和功能调试，userSig 正确的签发方式请参考 [服务器获取方案](https://cloud.tencent.com/document/product/269/1507)。

## 6. 编译运行
APP启动后，在不同的手机上登录不同的账号，就可以搜索对方的 userId 体验发消息了。