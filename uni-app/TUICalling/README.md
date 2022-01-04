一分钟跑通 uni-app 音视频插件示例

## 介绍

TUICalling 插件是**腾讯云官方推出**的基于腾讯云实时音视频（TRTC）和即时通信 IM 服务组合而成的插件，支持双人和多人音视频通话。插件提供了全套定制UI，开发者仅需两个 API 可集成实现通话功能。

## 效果展示

<table>
<tr>
   <th>双人视频通话演示</th>
   <th>多人视频通话演示</th>
 </tr>
<tr>
<td><img   src="https://web.sdk.qcloud.com/component/TUIKit/assets/uni-app/uni-calling-call.gif"/ ></td>
<td><img   src="https://web.sdk.qcloud.com/component/TUIKit/assets/uni-app/uni-calling-group.gif" ></td>
</tr>
</table>
<table>


## 应用场景

在线客服、在线面试、企业在线沟通、在线问诊、音视频社交等。

## 实现架构和支持平台

<img src="https://web.sdk.qcloud.com/component/TUIKit/assets/uni-app/uni-calling.png" height = "400"/>

## 支持平台

 安卓  、 iOS

## 快速跑通
### 步骤一：注册并创建 uni-app 账号

搭建 app 开发环境
- 1、下载 [HBuilderX 编辑器 ](https://www.dcloud.io/hbuilderx.html)

>!
> 项目中 HBuilderX 目前使用的最新版本，如果此前下载过 HBuilderX，为保证开发环境统一请更新到最新版本。
>

- 2、[DCloud 开发者中心注册](https://dev.dcloud.net.cn/)之后登陆 HBuilderX 编辑器

### 步骤二：创建应用并开通腾讯云服务
#### 步骤1：创建即时通信 IM 应用
1. 登录 [即时通信 IM 控制台](https://console.cloud.tencent.com/im)，单击 **创建新应用** 将弹出对话框。
   ![](https://main.qcloudimg.com/raw/c8d1dc415801404e30e49ddd4e0c0c13.png)
2. 输入您的应用名称，单击 **确认** 即可完成创建。
   ![](https://main.qcloudimg.com/raw/496cdc614f7a9d904cb462bd4d1e7120.png)
3. 您可在 [即时通信 IM 控制台](https://console.cloud.tencent.com/im) 总览页面查看新建应用的状态、业务版本、SDKAppID、创建时间以及到期时间。请记录 SDKAppID 信息。
4. 登录设置
##### 1). 在**登录与消息**页面，单击**登录设置**右侧的**编辑**。
##### 2). 在弹出的登录设置对话框中，选择多端登录类型，设置 Web 端以及其他平台实例同时在线数量。
>!
旗舰版选择多平台登录时，Web 端可同时在线个数最多为10个；Android、iPhone、iPad、Windows、Mac 平台可同时在线设备个数最多为3个。

<img src="https://web.sdk.qcloud.com/component/TUIKit/assets/uni-app/uni-app-calling-4.png" width = "600"/>

#### 3. 单击**确定**保存设置。

>!请务必开启多终端  

#### 步骤2：获取 IM 密钥并开通实时音视频服务
1. 在 [即时通讯 IM 控制台](https://console.cloud.tencent.com/im) 总览页单击您创建完成的即时通信 IM 应用，随即跳转至该应用的基础配置页。在 **基本信息** 区域，单击 **显示密钥**，复制并保存密钥信息。
![](https://main.qcloudimg.com/raw/030440f94a14cd031476ce815ed8e2bc.png)
>!请妥善保管密钥信息，谨防泄露。
2. 在该应用的基础配置页，开通腾讯云实时音视频服务。
![](https://main.qcloudimg.com/raw/1c2ce5008dad434d9206aabf0c07fd04.png)

### 步骤三：下载并配置 TUICalling 源码

1. 根据您的实际业务需求，下载 SDK 及配套的 [Demo 源码](https://gitee.com/cloudtencent/TIMSDK/tree/master/uni-app/TUICalling/TUICalling-app)。

```javascript
# 命令行执行
git clone https://gitee.com/cloudtencent/TIMSDK

# 进入 uni-app TUICalling 项目
cd TIMSDK/uni-app/TUICalling/TUICalling-app
```

2. 将 uni-app 中 TUICalling 工程文件，导入自己的 HBuilderX 工程。

     请参考官方 [uni-app 开发](https://uniapp.dcloud.io/quickstart-hx)

3. 设置 GenerateTestUserSig 文件中的相关参数。

- 找到并打开 `debug/GenerateTestUserSig.js` 文件。
- 设置 `GenerateTestUserSig.js` 文件中的相关参数。
  <ul><li>SDKAPPID：默认为0，请设置为实际的 SDKAppID。</li>
  <li>SECRETKEY：默认为空字符串，请设置为实际的密钥信息。</li></ul> 
  <img src="https://main.qcloudimg.com/raw/575902219de19b4f2d4595673fa755d4.png">

>! 注意
>- 本文提到的生成 `UserSig` 的方案是在客户端代码中配置 `SECRETKEY`，该方法中 `SECRETKEY` 很容易被反编译逆向破解，一旦您的密钥泄露，攻击者就可以盗用您的腾讯云流量，因此**该方法仅适合本地跑通 uni-app 和功能调试**。
>- 正确的 `UserSig` 签发方式是将 `UserSig` 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 `UserSig` 时由您的 App 向业务服务器发起请求获取动态 `UserSig`。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/647/17275#Server)。


### 步骤四：导入插件  [腾讯云原生音视频插件](https://ext.dcloud.net.cn/plugin?id=7097)

请参考官方 [原生插件使用指南](https://ask.dcloud.net.cn/article/35412)

#### 步骤1：购买uni-app原生插件

<img src="https://web.sdk.qcloud.com/component/TUIKit/assets/uni-app/uni-calling-1.png" width = "600"/>

使用前需先登录uni原生插件市场，在插件详情页中购买，免费插件也可以在插件市场0元购。购买后才能够云端打包使用插件
购买插件时请选择正确的appid，以及绑定正确包名。

#### 步骤2：使用自定义基座打包uni原生插件 （注：请使用真机运行自定义基座）

使用uni原生插件必须先提交云端打包才能生效，购买插件后在应用的manifest.json页面的“App原生插件配置”项下点击“选择云端插件”，选择需要打包的插件

![](https://img-cdn-tc.dcloud.net.cn/uploads/article/20190416/1b5297e695ad1536ddafe3c834e9c297.png)

直接云端打包后无法打log，不利于排错，所以一般先打一个自定义基座，把需要的原生插件打到真机运行基座里，然后在本地写代码调用调试。

>! 注意
>- 自定义基座不是正式版，真正发布时，需要再打正式包。使用自定义基座是无法正常升级替换apk的。
>- 请尽量不要使用本地插件，插件包超过自定义基座的限制，可能导致调试收费

#### 步骤五：编译运行

 请参考官方 [uni-app 运行](https://uniapp.dcloud.io/quickstart-hx?id=%e8%bf%90%e8%a1%8cuni-app)

#### 步骤六：打包发布

使用自定义基座开发调试uni-app原生插件后，不可直接将自定义基座apk作为正式版发布。
应该重新提交云端打包（不能勾选“自定义基座”）生成正式版本。

## 如何集成

[腾讯云原生音视频插件](https://ext.dcloud.net.cn/plugin?id=7097)

## 技术咨询

了解更多详情您可 QQ 咨询：309869925 (技术交流群)

<img src="https://web.sdk.qcloud.com/component/TUIKit/assets/uni-app/uni-app-qq.png" width = "600"/>


## 相关文档：
- [uni-app 音视频插件集成](地址)
- [uni-app TUIKit 源码](https://github.com/tencentyun/TIMSDK/tree/master/uni-app)
- [一分钟跑通 Demo (uni-app)](https://cloud.tencent.com/document/product/269/64506)
- [快速集成 uni-app TUIKit](https://cloud.tencent.com/document/product/269/64507)


