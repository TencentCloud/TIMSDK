本文主要介绍如何快速地运行云通信 WebIM Demo 工程，您只需参考如下步骤依次执行即可。

## 1. 创建新的应用
进入登录云通信 IM [控制台](https://console.cloud.tencent.com/avc) 创建一个新的应用，获得 SDKAppID，SDKAppID 是腾讯云后台用来区分不同云通信应用的唯一标识，在第4步中会用到。
![](https://main.qcloudimg.com/raw/b9d211494b6ec8fcea765d1518b228a1.png)

接下来，点击应用进入**快速上手**页面，参考页面上指引的“第一步”、“第二步”和“第三步”操作，即可快速跑通 Demo。

## 2. 下载 SDK+Demo 源码
“快速上手”页面中第一步里的几个链接地址分别为各个平台的 SDK 和 Demo 源码，点击会跳转到 Github 上，如果您当前网络访问 Github 太慢，可以在项目首页中找到镜像下载地址。
![](https://main.qcloudimg.com/raw/d56b4e4434da42d1a3b8e3540cf6718e.png)

## 3. 查看并拷贝加密密钥
点击**查看密钥**按钮，即可看到用于计算 UserSig 的加密密钥，点击“复制密钥”按钮，可以将密钥拷贝到剪贴板中。
![](https://main.qcloudimg.com/raw/5843542ec2e0446d326d7d44f96a5ec0.png)

<h2 id="CopyKey"> 4. 粘贴密钥到Demo工程的指定文件中 </h2>
我们在各个平台的 Demo 的源码工程中都提供了一个叫做 “GenerateTestUserSig” 的文件，它可以通过 HMAC-SHA256 算法本地计算出 UserSig，用于快速跑通 Demo。您只需要将第1步中获得的 SDKAppID 和第3步中获得的加密密钥拷贝到文件中的指定位置即可，如下所示：

![](https://main.qcloudimg.com/raw/9275a5f99bf00467eac6c34f6ddd3ca5.jpg)

## 5. 编译运行
使用 Chrome 浏览器打开 Demo 根目录下的 **index.html** 即可运行 Demo。
- 登录成功后，可以进行查找好友，建群，聊天等操作：
![](https://main.qcloudimg.com/raw/87e6f5eae834907cab89f50d5ce49b49.png)

- 搜索并添加好友。
![](https://main.qcloudimg.com/raw/ef4c39f1ec649ad4f10cd8764ca51d1c.png)

- 选择好友发消息。
![](https://main.qcloudimg.com/raw/ff8c787aa814edefd96468de2da59f26.png)

- 给好友发消息。
![](https://main.qcloudimg.com/raw/d55732975bb5d3e8e44a283e1a26ba4b.png)