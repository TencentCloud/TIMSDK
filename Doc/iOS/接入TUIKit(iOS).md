## 简介
#### 腾讯云 TUIKit

TUIKit 是基于腾讯云 IMSDK 的一款 UI 组件库，里面提供了一些通用的 UI 组件，开发者可通过该组件库选取自己所需要的组件快速的搭建一个 IM 应用。
IM 软件都具备一些通用的 UI 界面，如会话列表，聊天界面等。TUIKit 提供了这一类的组件，并提供了灵活的 UI 和交互扩展接口，方便用户做个性化开发。

#### IMSDK 与 TUIKit 的结合
腾讯云 IMSDK 提供了 IM 通信所需的各种基础能力，如通信网络，消息收发、存储，好友关系链，用户资料等。 TUIKit 中的组件在实现 UI 功能的同时调用 IMSDK 相应的接口实现了 IM 相关逻辑和数据的处理，因而开发者在使用 TUKit 时只需关注自身业务或做一些个性化的扩展即可。
下面我们将指导您如何快速的接入和使用 TUIKit。

## 帐号相关的基本概念

这里我们先来了解帐号相关的几个概念。

- **用户标识（userId）**:
userId（用户标识）用于在一个 IM 应用中唯一标识一个用户，即我们通常所说的帐号。这个一般由开发者自己的服务生成，即用户信息的生成（注册）需由开发者实现。

- **用户签名（userSig）**:
userSig（用户签名）是用于对一个用户进行鉴权认证，确认用户是否真实的。即用户在开发者的服务里注册一个帐号后，开发者的服务需要给该帐号配置一个由 usersig，后续用户登录 IM 的时候需要带上 usersig 让 IM 服务器进行校验。用户签名生成方法可参考 [生成签名](https://cloud.tencent.com/document/product/647/17275) 文档。

了解了前面的概念后，您可以通过下图了解集成了 IMSDK 应用的注册/登录流程。

![](	http://dldir1.qq.com/hudongzhibo/im/regist&login.jpg)

首先用户的终端需要向您的服务器注册帐号(userid)，您的服务器在进行注册业务处理时，按照用户签名文档中的方法生成一个该用户的 usersig，并返回给客户端。客户端再通过该 userid 和 usersig 到 IMSDK 进行登录操作。
为方便开发者接入开发测试，我们在腾讯云控制台提供了快速生成 usersig 的工具（在这之前您需要先在腾讯云创建自己的 IM 应用，可参考 [云通信 IM 入门](https://cloud.tencent.com/product/im/getting-started)）。登录控制台后选择-【云通信】-【应用列表】（选择您当前在使用的应用）-【应用配置】-【开发辅助工具】，参考上面说明即可生成 usersig。

## 集成TUIKit
1, 从 [Git](https://github.com/TencentVideoCloudIM/TIMSDK.git) 下载 ImSDK 开发包，TUIKit 源码所在的位置如下：
![](https://main.qcloudimg.com/raw/6b3d09ba290e78783cc764a9620b42e1.png)

2 ,以 TUIKitDemo 为例，参考下图，直接把 TUIKit 拖入 TUIKitDemo 工程中，然后编译TUIKit 工程生成 TUIKit.framework , 接着把 TUIKit.framework 和 Imsdk.framework 拖入 【Embedded Binaries】和 【Linked Frameworks and Libraries】里面，最后重启  TUIKitDemo 工程，TUIKit 源码就集成到 TUIKitDemo了。

![](https://main.qcloudimg.com/raw/a09cbe3019676ef182605d893ffe9e57.png)

## 初始化 TUIKit

通常情况下 TUIKit 的初始化非常简单，只需调用下面接口初始化默认配置即可。

```
NSInteger sdkAppid = 1400173143; //填入自己app的sdkAppid
TUIKitConfig *config = [TUIKitConfig defaultConfig];//默认TUIKit配置，这个您可以根据自己的需求在 TUIKitConfig 里面自行配置
[[TUIKit sharedInstance] initKit:sdkAppid withConfig:config];
```

## TUIKit 目录结构说明

![](https://main.qcloudimg.com/raw/64b0d6df1854abbb768e8b15a2c54f98.png)

| 文件名 |主要用途|
|:-:|:-:|
|setting|设置界面，目前主要用于管理程序的退出逻辑|
|chat|聊天界面，主要用于发送和接收各种自定义消息|
|commom|公共基类，主要用于管理公用的基础模块|
|conversation|消息列表界面，主要用于管理消息的列表逻辑|
|group|群组设置界面，主要用于设置群资料，加群，退群的逻辑|
|TUIKit|TUIKit 入口类，主要用于初始化，登录等|
|TUIKitConfig|TUIKit 资源配置类，主要用于加载资源图片，表情包等|
| voiceConvert |主要用于音频文件格式转换|
