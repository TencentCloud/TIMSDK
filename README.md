公告：TUIKit Android 与 iOS 端开放 Pull Request，merge 成功后会在 README.md 上留下您的大名并超链到您的 Github 主页！

## 镜像下载

腾讯云分流下载地址： [DOWNLOAD](https://github-1252463788.cos.ap-shanghai.myqcloud.com/imsdk/TIMSDK.zip)

## TUIKit集成

<table >
  <tr>
    <th width="180px" style="text-align:center">功能模块</th>
    <th width="180px" style="text-align:center">平台</th>
    <th width="500px" style="text-align:center">文档链接</th>
  </tr>

  <tr >
​    <td rowspan='2' style="text-align:center">快速集成</td>
​    <td style="text-align:center">iOS</td>
​    <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37060">TUIKit-iOS快速集成</a></td>
  </tr>

  <tr>
​    <td style="text-align:center">Android</td>
​    <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37059">TUIKit-Android快速集成</a></td>
  </tr>

  <tr>
​    <td rowspan='2' style="text-align:center">快速搭建</td>
​    <td style="text-align:center">iOS</td>
​    <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37063">TUIKit-iOS快速搭建</a></td>
  </tr>

  <tr>
​    <td style="text-align:center">Android</td>
​    <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37062">TUIKit-Android快速搭建</a></td>
  </tr>

  <tr>
​    <td rowspan='2' style="text-align:center">修改界面样式</td>
​    <td style="text-align:center">iOS</td>
​    <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37065">TUIKit-iOS修改界面样式</a></td>

  </tr>

  <tr>
​    <td style="text-align:center">Android</td>
​    <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37064">TUIKit-Android修改界面样式</a></td>
  </tr>

  <tr>
​    <td rowspan='2' style="text-align:center">自定义消息</td>
​    <td style="text-align:center">iOS</td>
​    <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37067">TUIKit-iOS自定义消息</a></td>
  </tr>

  <tr>
​    <td style="text-align:center">Android</td>
​    <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37066">TUIKit-Android自定义消息</a></td>
  </tr>

</table>


## 接口升级

- [iOS v2 v3 v4](https://github.com/tencentyun/TIMSDK/wiki/iOS-IMSDK-%E6%8E%A5%E5%8F%A3%E5%8F%98%E5%8C%96%EF%BC%88v2---v3---v4%EF%BC%89)
- [Android v2 v3 v4](https://github.com/tencentyun/TIMSDK/wiki/Android-IMSDK-%E6%8E%A5%E5%8F%A3%E5%8F%98%E5%8C%96%EF%BC%88v2---v3---v4%EF%BC%89)
- [Windows v2 v4](https://github.com/tencentyun/TIMSDK/wiki/Windows-IMSDK-%E6%8E%A5%E5%8F%A3%E5%8F%98%E5%8C%96%EF%BC%88v2---v4%EF%BC%89)

## 问题反馈
- 为了更好的了解您使用TIMSDK所遇到的问题，方便快速有效定位解决TIMSDK问题，希望您按如下反馈指引反馈issue，方便我们尽快解决您的问题
- [TIMSDK issue反馈指引](https://github.com/tencentyun/TIMSDK/wiki/TIMSDK-issue%E6%9C%89%E6%95%88%E5%8F%8D%E9%A6%88%E6%A8%A1%E6%9D%BF)

## 说明
  - 从 5.0 版本开始，SDK 新增精简版，原有版本称为标准版。
  - 精简版在标准版的基础上裁剪了好友列表和会话列表两项能力，并对部分业务逻辑做了优化，以实现更高的执行效率，更小的安装包增量。
  - 与标准版相比，精简版在 SDK 体积和安装包增量上都有3倍 - 4倍的缩减。如果您的 App 没有使用到好友列表和会话列表相关的功能，同时又特别关注安装包增量，建议您选择精简版。

## 标准版与精简版差异对照表
精简版目前支持 Android 和 iOS 两个平台，后续会逐步增加对 Windows 和 Mac 平台的支持。下面以 Android 和 iOS 平台下的 SDK 为主，对比一下标准版和精简版的差异。

### SDK 体积大小对比
<table>
  <tr>
    <th width="200px" style="text-align:center">平台</th>
    <th width="260px" style="text-align:center">对比项</th>
    <th width="200px" style="text-align:center">标准版</th>
    <th width="200px" style="text-align:center">精简版</th>
  </tr>
  <tr>
    <td style="text-align:center">Android</td>
    <td style="text-align:center">aar 大小</td>
    <td style="text-align:center">7.8 MB</td>
    <td style="text-align:center">2.5 MB</td>
  </tr>
  <tr>
    <td style="text-align:center">iOS</td>
    <td style="text-align:center">framework 大小</td>
    <td style="text-align:center">57.7 MB</td>
    <td style="text-align:center">9.2 MB</td>
  </tr>
</table>

### App 体积增量对比
<table>
  <tr>
    <th width="200px" style="text-align:center">平台</th>
    <th width="260px" style="text-align:center">架构</th>
    <th width="200px" style="text-align:center">标准版</th>
    <th width="200px" style="text-align:center">精简版</th>
  </tr>
  <tr>
    <td rowspan='2' style="text-align:center">apk 增量</td>
    <td style="text-align:center">armeabi-v7a</td>
    <td style="text-align:center">3.2 MB</td>
    <td style="text-align:center">934 KB</td>
  </tr>
  <tr>
    <td style="text-align:center">arm64-v8a</td>
    <td style="text-align:center">5.2 MB</td>
    <td style="text-align:center">1.4 MB</td>
  </tr>
  <tr>
    <td style="text-align:center">ipa 增量</td>
    <td style="text-align:center">arm64</td>
    <td style="text-align:center">2.1 MB</td>
    <td style="text-align:center">908 KB</td>
  </tr>
</table>

### 功能差异对比
<table>
  <tr>
    <th width="200px" style="text-align:center">功能模块</th>
    <th width="260px" style="text-align:center">功能项</th>
    <th width="200px" style="text-align:center">标准版</th>
    <th width="200px" style="text-align:center">精简版</th>
  </tr>
  <tr>
    <td rowspan='2' style="text-align:center;">资料</td>
    <td style="text-align:center">修改自己资料</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">获取他人资料</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td rowspan='5' style="text-align:center">群</td>
    <td style="text-align:center">创建群 销毁群 加群 退群</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">群资料管理</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  </tr>
  <tr>
    <td style="text-align:center">群成员管理</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">群申请列表</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">群自定义属性</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td rowspan='5' style="text-align:center">消息</td>
    <td style="text-align:center">消息发送与接收</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">消息已读与回执</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">消息撤回</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">消息多端同步</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">获取历史消息列表</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td rowspan='1' style="text-align:center">信令</td>
    <td style="text-align:center">信令发送与响应</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  </tr>
  <tr>
    <td rowspan='2' style="text-align:center">离线推送</td>
    <td style="text-align:center">Android 离线推送</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">iOS 离线推送</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  <tr>
    <td rowspan='5' style="text-align:center">关系链</td>
    <td style="text-align:center">添加好友</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</tdh>
  </tr>
  <tr>
    <td style="text-align:center">好友资料管理</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">好友申请列表</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">好友分组</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">好友黑名单</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  <tr>
  <tr>
    <td rowspan='4' width="100px" style="text-align:center">会话</td>
    <td style="text-align:center">获取会话列表</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">获取会话未读消息数</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">会话管理</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
  <tr>
    <td style="text-align:center">设置会话草稿</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">&#10003</td>
  </tr>
</table>

### 集成方式对比
#### jcenter 集成 (Android 平台)
如果使用标准版 SDK，请在 gradle 里添加如下依赖
```
dependencies {
  api 'com.tencent.imsdk:imsdk:版本号'
}
```
如果使用精简版 SDK，请在 gradle 里添加如下依赖
```
dependencies {
  api 'com.tencent.imsdk:imsdk-smart:版本号'
}
```

#### cocoaPods 集成 (iOS 平台)
如果使用标准版 SDK，请您按照如下方式设置 Podfile 文件

```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_iOS'
end
```

如果使用精简版 SDK，请您按照如下方式设置 Podfile 文件
```
platform :ios, '8.0'
source 'https://github.com/CocoaPods/Specs.git'

target 'App' do
pod 'TXIMSDK_Smart_iOS'
end
```

更多集成方式请参考 <a href="https://cloud.tencent.com/document/product/269/32673">集成 SDK</a>

## 精简版 5.1.110 @2020.11.26

### SDK

**通用变更点**

- 已补齐所有 V2 接口
- 增加会话功能
- 增加关系链功能
- 增加群@功能
- iOS 支持 iPhone 和 iPad 同时在线
- 发送消息支持多 Element
- 群资料支持自定义字段
- 修复若干稳定性问题

## 标准版 5.1.2 @2020.11.11

### SDK

**iOS/Mac平台**

- iOS 支持 iphone 和 ipad 同时在线
- Mac 支持 arm64 架构

**Android平台**
- 修复android版本稳定性问题
- 替换为标准TRTC依赖包

## 标准版 5.1.1 @2020.11.05

### SDK

**iOS/Android平台**

- 增加获取 AVChatRoom 直播群在线人数的接口
- 增加根据消息唯一 ID 查询消息的接口
- 增加获取服务器校准时间戳的接口
- 优化登录速度
- 优化群资料拉取逻辑
- 修复退出群组之后拉不到本地消息的问题
- 修复发送成功的消息被第三方回调修改之后，发送端消息没有及时更新的问题
- 修复 Metting 会议群在经过控制台配置后，对应的会话仍然不支持未读数的问题
- 修复 AVChatRoom 直播群偶现收不到消息的问题
- 修复其它一些偶现的稳定性问题

### TUIkit & Demo

**iOS/Android平台**

- 群成员@ 支持 @所有人
- TUIKit 组件国际化支持
- 安卓版本发送图片消息时支持选择视频
- 优化音视频通话请求超时逻辑
- 安卓离线推送更新为依赖 TPNS 的包
- 群直播增加开播动画
- 群直播增加直播小窗的支持


## 精简版 5.0.108 @2020.11.02

### SDK

**通用变更点**

- 修复 iOS 版本稳定性问题
- 修复 Android 版本偶现消息不回调问题

## 标准版 5.0.10 @2020.10.15

### SDK

**iOS/Android平台**

- 优化信令接口，支持设置在线消息 onlineUserOnly 和离线推送信息 offlinePushInfo 参数
- 优化获取单个会话接口的异步回调
- 会话增加获取群类型接口，方便会话列表展示过滤

### TUIKit & Demo

**iOS/Android**
- 新增群直播功能，连麦、送礼、美颜、变声等功能一应俱全
- 新增直播大厅，支持连麦、PK、点赞、送礼、美颜、弹幕、好友关注等
- 优化语音视频信令识别问题


## TUIKit 开源贡献榜

谁是第一位英雄，请现身！


