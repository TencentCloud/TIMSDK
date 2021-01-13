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



## 标准版与精简版差异对比
- SDK 从5.0版本开始新增精简版，原有版本称为标准版。
- 精简版与标准版同时支持 V2 API，在接口能力上完全一致。
- 精简版不再支持旧版 API，标准版继续支持旧版 API。
- 在 SDK 体积和安装包增量上，精简版与标准版相比有大幅度缩减。
- 精简版目前支持 Android 和 iOS 两个平台，后续会逐步增加对 Windows 和 Mac 平台的支持。
- 如果您没有接入过旧版 API，建议您直接使用 V2 API，选择精简版 SDK。
- 如果您已经接入了旧版 API，推荐您升级到 V2 API，逐步切换到精简版 SDK。

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
    <td style="text-align:center">3.1 MB</td>
  </tr>
  <tr>
    <td style="text-align:center">iOS</td>
    <td style="text-align:center">framework 大小</td>
    <td style="text-align:center">57.7 MB</td>
    <td style="text-align:center">11.2 MB</td>
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
    <td style="text-align:center">1.1 MB</td>
  </tr>
  <tr>
    <td style="text-align:center">arm64-v8a</td>
    <td style="text-align:center">5.2 MB</td>
    <td style="text-align:center">1.7 MB</td>
  </tr>
  <tr>
    <td style="text-align:center">ipa 增量</td>
    <td style="text-align:center">arm64</td>
    <td style="text-align:center">2.1 MB</td>
    <td style="text-align:center">1.1 MB</td>
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

## 最新精简版 5.1.127 @2021.01.13

### SDK
**通用变更点**
- 修复获取会话列表时，没有会话更新，也触发会话更新回调的问题
- 修复清空会话所有消息时，没有把对应会话的最后一条消息置空的问题

**iOS 平台**
- 修复 iOS 平台下 getSignallingInfo 方法传入非信令消息返回的不是 nil 的问题

**Android 平台**
- 修复 Android 平台下偶现 JNI 局部引用表超限导致的 crash 问题


## 最新标准版 5.1.20 @2021.01.08

### SDK

**通用变更点**

- V2 自定义消息补齐 desc 和 ext 字段
- V2 用户资料接口补齐 role 和 level 字段
- V2 接口优化无论登录成功与否，都可以获取本地会话列表数据以及本地历史消息数据
- V2 增加 getHistoryMessageList 接口，支持获取云端或本地消息以及向前向后拉取
- 优化 C2C 消息获取头像问题
- 优化富媒体消息文件上传的安全性问题及续期问题
- 修复发送的富媒体消息的本地路径为空的问题
- 修复向群内插入一条本地消息，退出重新登录后该会话的 lastMessage 显示为上一条消息问题
- 修复 Elem 乱序的问题
- 修复群@消息撤回，消息列表@提示仍存在问题
- 修复离线期间的群@消息，上线后拉取群历史消息会拉到该系统消息问题
- 修复发送一个语音通话的信令邀请，会接受到二条离线推送通知问题
- 修复聊天消息过多时，设置本地“消息自定义数据”失效问题
- 修复未读的群消息被撤回后，未读计数没有减少的问题
- 修复其他稳定性问题

**iOS & Mac**

- 修复自定义消息传 array json 接收端 crash 的问题
- 修复调用 deleteConversation 传错误的会话 id 直接闪退问题
- 修复草稿箱最后一条草稿删除不掉问题

### TUIKit & Demo

- iOS 修复删除好友/退群后未清除会话置顶信息
- iOS 修复控制台设置用户为管理员，界面仍显示为无管理员权限问题
- iOS 优化视频缩略图为空引起的crash问题
- iOS 修复撤回长文本消息后，撤回消息高度异常问题
- iOS 修复群禁言tips的不显示的问题
- iOS 优化国际化会话界面的时间显示
- Android 修复创建直播间进入倒计时过程，点击返回crash问题
- Android 修复群聊通话过程，成员拒接出现通话界面未消失问题
- Android 修复直播间观众小窗口模式被踢下线，小窗口未正常关闭问题
- Android 修复成员加群偶现crash问题

谁是第一位英雄，请现身！


