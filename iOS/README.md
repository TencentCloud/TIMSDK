
本文主要介绍如何快速地将腾讯云即时通信Demo工程运行起来，您只需参考如下步骤依次执行即可。

![](https://main.qcloudimg.com/raw/54249c7e9cdffbb4d4cddaf94fccbb16.png)
## 1. 注册腾讯云账号

注册腾讯云账号和开通服务，请访问[http://cloud.tencent.com/product/im.html](http://cloud.tencent.com/product/im.html)，
![](https://main.qcloudimg.com/raw/2919f8c436d94e94728fc98829c03486.png)
单击”立即使用“，如果之前没有使用 QQ 号登录过腾讯云，会跳转到下面的页面，

![](https://main.qcloudimg.com/raw/5f5f6dc10f2781d0b4136b5114f58b32.png)
此处我们**强烈建议**您进行实名认证，以便您能获取更好的服务。

## 2. 创建应用
完成实名认证之后再次通过门户进入云通信产品页，

在跳出的页面内单击“立即使用”，会出现“应用列表”，单击“创建应用接入”，会出现下图的内容，您按照您的需要进行应用的创建，
![](https://main.qcloudimg.com/raw/14a392ce346a812dca533282692d8360.png)

创建应用后，会给您分配一个应用标识：sdkappid，接下来进入“帐号集成”。

## 3. 帐号集成
完成创建应用之后返回应用列表，单击相应应用的“应用配置”链接，
![](https://main.qcloudimg.com/raw/944ba26dbf293fd971eb20ee40d0d672.png)

在新的页面内容中，找到当前页面的帐号体系集成部分，单击“编辑”链接，
![](https://main.qcloudimg.com/raw/2db2225f7851ff42be9ce2d3dfc835fe.png)

帐号名称相当于是应用所属系列的名称，多个应用可以使用相同的，如果之前创建过应用，下拉列表中可以看到之前应用使用的帐号名称。

集成模式使用 [独立模式](https://cloud.tencent.com/document/product/269/1507)。

下面是帐号集成完成后应用的配置页面，
![](https://main.qcloudimg.com/raw/70a9d5f3846dac7eb6a288aa3b425b9d.png)

## 4. 获取测试userSig
点击**下载公私钥**的链接，即可获得一个名为 **keys.zip** 的压缩包，解压后可以得到两个文件，即 public_key 和 private_key，用记事本打开 **private_key** 文件，并将其中的内容拷贝到**开发辅助工具**的私钥文本输入框中。
![](https://main.qcloudimg.com/raw/a1b9bb35760e1e52825c754bd3ef9a52.png)
其中：identifier 即为你的测试账号，私钥为下载的私钥信息，生成的签名就是**userSig**。identifier和userSig是一一对应的关系。

## 5. 下载 Demo源码
从 [Github](https://github.com/TencentVideoCloudIM/TIMSDK) 下载 ImSDK iOS开发包，打开TUIKitDemo工程。
![](https://main.qcloudimg.com/raw/45f395119c820d5da88f7124174c013f.png)

## 6. 配置工程
根据上述步骤获取的SdkAppid 和 userSig，参考下图在工程配置。
![](https://main.qcloudimg.com/raw/9f10172ff1ad34e31a018c27beb1cb79.png)

**注意：该方案仅适合本地跑通demo和功能调试，产品真正上线发布，userSig获取请使用服务器获取方案** [Doc](https://cloud.tencent.com/document/product/269/1507)

## 7. 编译运行
APP启动后，在登录界面上输入 **第四步示意图** 中用来生成userSig的用户名(identifier) IM_User_0 点击登录即可体验。
由于用户名(identifier)跟userSig是一一对应关系，如果要换用户名登录，则需要根据5、6、7步的流程重新生成userSig并替换到代码相应位置。

