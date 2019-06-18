## 简介
### 腾讯云 TUIKit

TUIKit 是基于腾讯云 IM SDK 的一款 UI 组件库，它提供了一类通用的 UI 组件，开发者可通过该组件库选取自己所需的组件快速搭建一个 IM 应用。
IM 应用都具备一些通用的 UI 界面，如会话列表，聊天界面等。TUIKit 提供了这一类的组件，并提供了灵活的 UI 和交互扩展接口，方便用户做个性化开发。

### IM SDK 与 TUIKit 的结合
腾讯云 IM SDK 提供了 IM 通信所需的各种基础能力，例如通信网络，消息收发、存储，好友关系链以及用户资料等。 TUIKit 中的组件在实现 UI 功能的同时，调用 IM SDK 相应的接口实现 IM 相关逻辑和数据的处理，因而开发者在使用 TUIKit 时只需关注自身业务或做一些个性化的扩展即可。

### 帐号相关概念
- **用户标识（UserID）**：
UserID（用户标识）用于在一个 IM 应用中唯一标识一个用户，即我们通常所说的帐号。一般由开发者自己的服务生成，即用户信息的生成（注册）需由开发者实现。

- **用户签名（UserSig）**：
UserSig（用户签名）用于对一个用户进行鉴权认证，确认用户是否真实。即用户在开发者的服务里注册一个帐号后，开发者的服务需要给该帐号配置一个 UserSig，后续用户登录 IM 时需要带上 UserSig 让 IM 服务器进行校验。用户签名生成方法请参见 [生成 UserSig](https://cloud.tencent.com/document/product/269/32688)。

## 帐号注册/登录流程
您可以通过下图了解集成了 IM SDK 应用的注册/登录流程。
![](https://main.qcloudimg.com/raw/e919794716ae01121371e321cd249ebb.png)

1. 用户的终端向您的服务器注册帐号（UserID）。
2. 您的服务器在进行注册业务处理时，为该用户 [生成](https://cloud.tencent.com/document/product/269/32688#.E6.9C.8D.E5.8A.A1.E5.99.A8.E7.94.9F.E6.88.90-usersig) 一个 UserSig 并返回给客户端。
3. 客户端使用 UserID 和 UserSig 登录 IM SDK。
4. IM 服务器返回登录结果。

## TUIKit 效果图
会话列表，通讯录相关界面演示：
<div>
<img src="https://cdn.nlark.com/yuque/0/2019/gif/367185/1560518740493-e5a89223-4cb4-44df-a9a5-665e78b67983.gif#align=left&display=inline&height=674&name=%E4%BC%9A%E8%AF%9D%E5%88%97%E8%A1%A8.gif&originHeight=674&originWidth=380&size=319844&status=done&width=380" width="300" height="535">
</div>
聊天界面收发消息演示：
<div>
<img src="https://cdn.nlark.com/yuque/0/2019/gif/367185/1560519391978-f7dbd5fa-8ee7-4b4c-9e71-c7e8d6c5b01b.gif#align=left&display=inline&height=674&name=%E8%81%8A%E5%A4%A9%E6%BC%94%E7%A4%BA.gif&originHeight=674&originWidth=380&size=918355&status=done&width=380" width="300" height="535">
</div>
输入区域自定义部分功能演示：
<div>
<img src="https://cdn.nlark.com/yuque/0/2019/gif/366128/1559825875054-fdfb0919-1f59-4382-924a-b2197f813ab4.gif#align=left&display=inline&height=533&name=add.gif&originHeight=1920&originWidth=1080&size=547272&status=done&width=300" width="300" height="535">
</div>
输入区域自定义按钮事件演示：
<div>
<img src="https://cdn.nlark.com/yuque/0/2019/gif/366128/1559825509248-ebb52b9b-8fee-421f-ad32-f2a12192167c.gif#align=left&display=inline&height=533&name=replace%2B.gif&originHeight=1920&originWidth=1080&size=177751&status=done&width=300" width="300">
</div>
输入区域自定义全部功能演示：
<div>
<img src="https://cdn.nlark.com/yuque/0/2019/gif/366128/1559826601807-394ea189-6188-47e7-bfe8-bb19c67b9dbb.gif#align=left&display=inline&height=587&name=new.gif&originHeight=1920&originWidth=1080&size=508813&status=done&width=330" width="300" height="535">
</div>

## TUIKit 文档

<table >
  <tr>
    <th width="180px" style="text-align:center">功能模块</th>
    <th width="180px" style="text-align:center">平台</th>
    <th width="500px" style="text-align:center">文档链接</th>
  </tr>

  <tr >
    <td rowspan='2' style="text-align:center">快速集成</td>
    <td style="text-align:center">iOS</td>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-iOS%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90">TUIKit-iOS 快速集成</a></td>
  </tr>

  <tr>
    <td style="text-align:center">Android</td>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-Android%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90">TUIKit-Android 快速集成</a></td>
  </tr>

  <tr>
    <td rowspan='2' style="text-align:center">快速搭建</td>
    <td style="text-align:center">iOS</td>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-iOS%E5%BF%AB%E9%80%9F%E6%90%AD%E5%BB%BA">TUIKit-iOS 快速搭建</a></td>
  </tr>

  <tr>
    <td style="text-align:center">Android</td>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-Android%E5%BF%AB%E9%80%9F%E6%90%AD%E5%BB%BA">TUIKit-Android 快速搭建</a></td>
  </tr>

  <tr>
    <td rowspan='6' style="text-align:center">修改界面样式</td>
    <td style="text-align:center">iOS</td>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-iOS%E4%BF%AE%E6%94%B9%E7%95%8C%E9%9D%A2%E6%A0%B7%E5%BC%8F">TUIKit-iOS 修改界面样式</a></td>

  </tr>

  <tr>
    <td rowspan='5' style="text-align:center">Android</td>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-Android%E4%BF%AE%E6%94%B9%E7%95%8C%E9%9D%A2%E6%A0%B7%E5%BC%8F-%E4%BC%9A%E8%AF%9D%E5%88%97%E8%A1%A8">TUIKit-Android 修改界面样式-会话列表</a></td>
  </tr>

  <tr>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-Android%E4%BF%AE%E6%94%B9%E7%95%8C%E9%9D%A2%E6%A0%B7%E5%BC%8F-%E8%81%8A%E5%A4%A9%E7%95%8C%E9%9D%A2">TUIKit-Android 修改界面样式-聊天界面</a></td>
  </tr>

  <tr>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-Android%E4%BF%AE%E6%94%B9%E7%95%8C%E9%9D%A2%E6%A0%B7%E5%BC%8F-%E8%81%8A%E5%A4%A9%E7%95%8C%E9%9D%A2-%E9%80%9A%E7%9F%A5%E5%8C%BA%E5%9F%9F">TUIKit-Android 修改界面样式-聊天界面-通知区域</a></td>
  </tr>

  <tr>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-Android%E4%BF%AE%E6%94%B9%E7%95%8C%E9%9D%A2%E6%A0%B7%E5%BC%8F-%E8%81%8A%E5%A4%A9%E7%95%8C%E9%9D%A2-%E6%B6%88%E6%81%AF%E5%8C%BA%E5%9F%9F">TUIKit-Android 修改界面样式-聊天界面-消息区域</a></td>
  </tr>

  <tr>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-Android%E4%BF%AE%E6%94%B9%E7%95%8C%E9%9D%A2%E6%A0%B7%E5%BC%8F-%E8%81%8A%E5%A4%A9%E7%95%8C%E9%9D%A2-%E8%BE%93%E5%85%A5%E5%8C%BA%E5%9F%9F">TUIKit-Android 修改界面样式-聊天界面-输入区域</a></td>
  </tr>

  <tr>
    <td rowspan='2' style="text-align:center">自定义消息</td>
    <td style="text-align:center">iOS</td>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-iOS%E8%87%AA%E5%AE%9A%E4%B9%89%E6%B6%88%E6%81%AF">TUIKit-iOS 自定义消息</a></td>
  </tr>

  <tr>
    <td style="text-align:center">Android</td>
    <td style="text-align:center"><a href="https://github.com/tencentyun/TIMSDK/wiki/TUIKit-Android%E8%87%AA%E5%AE%9A%E4%B9%89%E6%B6%88%E6%81%AF">TUIKit-Android 自定义消息</a></td>
  </tr>
</table>




## 快速体验

欢迎扫码体验我们的 DEMO，后续会继续完善。更多最新资讯请关注 [这里](https://github.com/tencentyun/TIMSDK)。

