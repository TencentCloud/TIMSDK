本文主要介绍如何快速地将腾讯云WEBIM Demo(Web) 工程运行起来，您只需参考如下步骤依次执行即可。

## 1. 创建新的应用
进入腾讯云通讯（IM）[控制台](https://console.cloud.tencent.com/avc)，会出现“应用列表”，单击“创建应用接入”，会出现下图的内容：
![](https://main.qcloudimg.com/raw/27314e92cd2972a8eada8cfba4055ac6.png)

创建应用后，腾讯云会给您的新应用分配一个应用标识：sdkappid，如下图：
![](https://main.qcloudimg.com/raw/826b903373db7cff2adebec6fa3a40a8.png)

## 2. 配置应用
完成创建应用之后返回应用列表，单击相应应用的“应用配置”链接，在新页面中，找到当前页面的**帐号体系集成**部分，单击“编辑”链接：
![](https://main.qcloudimg.com/raw/e3ce0ef527d2d4f8d0b3a0f69cefa78e.png)

>账号管理员可以随便填写，在使用云通讯后台的 REST API 发送消息时才会用到。

## 3. 获取测试 userSig
点击**下载公私钥**的链接，即可获得一个名为 **keys.zip** 的压缩包，解压后可以得到两个文件，即 public_key 和 private_key，用记事本打开 **private_key** 文件，并将其中的内容拷贝到**开发辅助工具**的私钥文本输入框中。

其中：**identifier** 由您指定，即为您的测试账号（也就是 userId）。私钥为 private_key 文件里的文本内容，生成的签名就是**userSig**。identifier 和 userSig 是一一对应的关系。

![](https://main.qcloudimg.com/raw/a1b9bb35760e1e52825c754bd3ef9a52.png)

> 可以最多生成4组 userId 和 userSig，方便在Demo中调试使用。

## 4. 下载 Demo 源码
从 [Github](https://github.com/tencentyun/TIMSDK) 下载 IMSDK H5开发包。

## 5. 修改源码配置
使用编辑器打开 index.html ，修改以下参数配置。  
``` 
var sdkAppID = '', // 填写第一步获取到的 sdkappid
    accountType = ''; // 填写第二步设置账号体系集成获取到的 accountType
```

## 6. 运行 Demo
- step1：浏览器打开 index.html
- step2：在页面上输入通过控制台*开发辅助工具**获取到 identifier 和 userSig，单击确定
![](https://main.qcloudimg.com/raw/77bfeddae0703b84d12fa51f38508adf.png)
- step3：登录成功后，就可以进行查找好友，建群，聊天等操作了。
![](https://main.qcloudimg.com/raw/87e6f5eae834907cab89f50d5ce49b49.png)
- setp4: 搜索并添加好友
![](https://main.qcloudimg.com/raw/ef4c39f1ec649ad4f10cd8764ca51d1c.png)
- setp5：选择好友发消息
![](https://main.qcloudimg.com/raw/ff8c787aa814edefd96468de2da59f26.png)
![](https://main.qcloudimg.com/raw/d55732975bb5d3e8e44a283e1a26ba4b.png)








