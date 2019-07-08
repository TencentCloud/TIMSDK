本文主要介绍如何快速地运行云通信 WebIM Demo 工程。

<span id="step1"></span>
## 创建应用
1. 登录云通信 IM [控制台](https://console.cloud.tencent.com/avc)。
 >?如果您已有应用，请记录其 SDKAppID 并 [配置应用](#step2)。
 >
2. 在【应用列表】页，单击【创建应用接入】。
 ![](https://main.qcloudimg.com/raw/a7769d15f050286162b0cbcdadca5f03.png)
3. 在【创建新应用】对话框中，填写新建应用的信息，单击【确认】。
 应用创建完成后，自动生成一个应用标识 SDKAppID，请记录 SDKAppID 信息。
 ![](https://main.qcloudimg.com/raw/bf8fe4f38d782741a6e142c24648c9e0.png)

<span id="step2"></span>
## 配置应用
1. 单击目标应用所在行的【应用配置】，进入应用详情页面。
 ![](https://main.qcloudimg.com/raw/e41602a50754be9d478b9db84c0bcff2.png)
2. 单击【帐号体系集成】右侧的【编辑】，配置**帐号管理员**信息，单击【保存】。
 ![](https://main.qcloudimg.com/raw/2ad153a77fe6f838633d23a0c6a4dde1.png)

<span id="step3"></span>
## 获取测试 UserSig
>!本文提到的获取 UserID 和 UserSig 的方案仅适合本地跑通 Demo 和功能调试，正确的 UserSig 签发方式请参见 [生成 UserSig](https://cloud.tencent.com/document/product/269/32688)。

1. 在控制台应用详情页面，单击【下载公私钥】，保存 **keys.zip** 压缩文件。
 ![](https://main.qcloudimg.com/raw/e11d958bc43b09fb41c7064ee2b09722.png)
2. 解压 **keys.zip** 文件 ，获得 **private_key.txt** 和 **public_key.txt** 文件，其中 **private_key.txt** 即为私钥文件。
 ![](https://main.qcloudimg.com/raw/ec89f5bb93d57de1acffa4e15786da11.png)
3. 在控制台应用详情页面，选择【开发辅助工具】页签，填写【用户名（UserID）】，拷贝私钥文件内容至【私钥（PrivateKey）】文本框中，单击【生成签名】，在【签名（UserSig）】文本框中即可获得该云通信应用指定用户名的 UserSig。
 ![](https://main.qcloudimg.com/raw/f491ffbd8dc3c0e8659288d27152c847.png)
4. 重复上述操作，生成4组或更多组 UserID 和 UserSig。

## 下载 Demo 源码
从 [Github](https://github.com/tencentyun/TIMSDK) 下载 IM SDK H5 开发包。

## 修改源码配置
使用编辑器打开 index.html ，修改以下参数配置。  
<pre>
var sdkAppID = '', // 填写 <a href="https://cloud.tencent.com/document/product/269/32940#step1">创建应用</a> 中获取的 SDKAppID
</pre>

## 运行 Demo
1. 使用浏览器打开 index.html。
2. 输入 [获取测试 userSig](#step3) 中获取到 UserID 和 userSig，单击【确定】。
 ![](https://main.qcloudimg.com/raw/77bfeddae0703b84d12fa51f38508adf.png)
3. 登录成功后，可以进行查找好友，建群，聊天等操作：
 ![](https://main.qcloudimg.com/raw/87e6f5eae834907cab89f50d5ce49b49.png)
 - 搜索并添加好友。
  ![](https://main.qcloudimg.com/raw/ef4c39f1ec649ad4f10cd8764ca51d1c.png)
 - 选择好友发消息。
  ![](https://main.qcloudimg.com/raw/ff8c787aa814edefd96468de2da59f26.png)
 - 给好友发消息。
  ![](https://main.qcloudimg.com/raw/d55732975bb5d3e8e44a283e1a26ba4b.png)
