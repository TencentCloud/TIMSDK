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

## 最新精简版 5.1.118 @2020.12.11

### SDK
**通用变更点**
- 修复删除和撤回群的未读消息时，群未读计数不会减小的问题
- 优化消息去重逻辑，修复同一条消息可能会回调多次的问题
- 修复发送失败的消息不能删除的问题
- 修复删除群会话时，如果已经退群或者对应的群已经解散，会回调删除失败的问题
- 修复设置群消息已读上报时，如果已经退群或者对应的群已经解散，会回调设置失败的问题
- 增加向本地插入 C2C 消息的接口

**Android 平台**
- 修复添加好友黑名单偶现崩溃的问题
- 修复发送消息没有同步返回消息 ID 的问题

**IOS 平台**
- 修复个人资料设置个性签名返回失败的问题

## 最新标准版 5.1.10 @2020.12.04

### SDK

**通用变更点**

- V2 API 增加群自定义字段和消息多 Element 支持
- V2 API 增加向本地插入 C2C 消息的接口
- 优化普通群和直播群丢消息问题
- 修复发送失败的消息无法删除的问题
- 修复 C2C 会话里，发送的第一消息是在线消息的情况下，收不到已读回执的问题
- 修复已经撤回的消息，通过拉历史消息的接口返回后，消息状态不正确的问题
- 修复 iOS 平台获取好友分组的接口传入空分组名时，不能返回所有分组信息的问题
- 修复稳定性问题

谁是第一位英雄，请现身！


