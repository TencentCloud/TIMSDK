
本文主要介绍如何快速地运行云通信 IM Demo（iOS & Mac）工程。


## 1、创建应用
1. 登录云通信 IM [控制台](https://console.cloud.tencent.com/avc)。
 >?如果您已有应用，请直接 [配置应用](#step2)。
 >
2. 在【应用列表】页，单击【创建应用接入】。
 ![](https://main.qcloudimg.com/raw/a7769d15f050286162b0cbcdadca5f03.png)
3. 在【创建新应用】对话框中，填写新建应用的信息，单击【确认】。
 应用创建完成后，自动生成一个应用标识 SDKAppID，请记录 SDKAppID 信息。
 ![](https://main.qcloudimg.com/raw/bf8fe4f38d782741a6e142c24648c9e0.png)


## 2、配置应用
1. 单击目标应用所在行的【应用配置】，进入应用详情页面。
 ![](https://main.qcloudimg.com/raw/e41602a50754be9d478b9db84c0bcff2.png)
2. 单击【帐号体系集成】右侧的【编辑】，配置**帐号管理员**信息，单击【保存】。
 ![](https://main.qcloudimg.com/raw/2ad153a77fe6f838633d23a0c6a4dde1.png)


## 3、获取测试 UserSig
>!本文提到的获取 UserID 和 UserSig 的方案仅适合本地跑通 Demo 和功能调试，正确的 UserSig 签发方式请参见 [生成 UserSig](https://cloud.tencent.com/document/product/269/32688)。

1. 在控制台应用详情页面，单击【下载公私钥】，保存 **keys.zip** 压缩文件。
 ![](https://main.qcloudimg.com/raw/c44938b9268d0ef76c68b8bf61689219.png)
2. 解压 **keys.zip** 文件 ，获得 **private_key.txt** 和 **public_key.txt** 文件，其中 **private_key.txt** 即为私钥文件。
 ![](https://main.qcloudimg.com/raw/ec89f5bb93d57de1acffa4e15786da11.png)
3. 在控制台应用详情页面，选择【开发辅助工具】页签，填写【用户名（UserID）】，拷贝私钥文件内容至【私钥（PrivateKey）】文本框中，单击【生成签名】，在【签名（UserSig）】文本框中即可获得该云通信应用指定用户名的 UserSig。
 ![](https://main.qcloudimg.com/raw/f491ffbd8dc3c0e8659288d27152c847.png)
4. 重复上述操作，生成4组或更多组 UserID 和 UserSig。

## 4、下载 Demo 源码
从 [Github](https://github.com/tencentyun/TIMSDK) 下载 IM SDK 开发包，iOS 和 Mac 工程分别在以下截图位置，打开对应的 TUIKitDemo 工程。
- iOS：
 ![](https://main.qcloudimg.com/raw/90184857d891a7ea4c8d47fc243fa45d.png)
 TUIKitDemo.xcworkspace 为一个 pod 创建的工程，执行以下代码更新依赖库：
 <pre>
cd iOS
mv TXIMSDK_iOS.podspec ../
mv TXIMSDK_TUIKit_iOS.podspec ../
cd  TUIKitDemo
pod install
</pre>

- Mac：
 ![](https://main.qcloudimg.com/raw/7fef1d44f93872111a4498601d4dd61b.png)

## 5、配置工程
根据 [创建应用](#step1) 中获取的 SDKAppID 以及 [获取测试 UserSig](#step3) 中获取的4对 UserID 和 UserSig，配置 Demo 工程中的 AppDelegate.h 文件。
![](https://main.qcloudimg.com/raw/099d4241c099e1e6e81b9d9f93fd6fa4.png)

## 6、编译运行
程序启动后，在不同的设备上登录不同的帐号，搜索对方的 UserID 体验发送消息等功能。
