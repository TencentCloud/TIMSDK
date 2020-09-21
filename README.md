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
    <td style="text-align:center">-</tdh>
  </tr>
  <tr>
    <td style="text-align:center">好友资料管理</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">-</td>
  </tr>
  <tr>
    <td style="text-align:center">好友申请列表</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">-</td>
  </tr>
  <tr>
    <td style="text-align:center">好友分组</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">-</td>
  </tr>
  <tr>
    <td style="text-align:center">好友黑名单</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">-</td>
  <tr>
  <tr>
    <td rowspan='4' width="100px" style="text-align:center">会话</td>
    <td style="text-align:center">获取会话列表</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">-</td>
  </tr>
  <tr>
    <td style="text-align:center">获取会话未读消息数</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">-</td>
  </tr>
  <tr>
    <td style="text-align:center">会话管理</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">-</td>
  </tr>
  <tr>
    <td style="text-align:center">设置会话草稿</td>
    <td style="text-align:center">&#10003</td>
    <td style="text-align:center">-</td>
  </tr>
</table>


## 标准版 5.0.6 @2020.09.18

### SDK

**通用变更点**

- 增加群@功能
- iOS 和 Android 新增接口 deleteMessages，会同时删除本地及漫游消息
- 接口 deleteConversation 在删除会话的同时会删除本地及漫游消息
- API2.0 接口补充了用户资料、好友资料、群成员资料的自定义字段的设置和获取接口
- 优化图片上传兼容性问题
- 修复设置群消息接收选项再立即获取该值，该值未改变的问题
- 修复 C2C 本地会话删除后，C2C 的系统通知会更新会话，但是消息 elem 为空的问题
- 修复含中文的 userID 导致图片上传不成功的问题
- 修复带有特殊字符的账号设置用户 nickname 成功后，进群发消息，群内其他成员接收到新消息回调中 nickname 为空的问题
- 修复已知崩溃问题

**iOS 平台**

- 修复移除消息监听 crash 的问题
- 优化会话对象账号删除导致会话获取异常的问题
- 优化初始化卡顿问题

**Android 平台**

- 优化信令发送超时失败时的处理
- 修复信令取消接口的自定义数据无效的问题
- 修复群属性删除接口 keys 传 null 无法删除所有属性的问题
- 修复信令群呼叫接受或者拒绝后还能继续接受或拒绝的问题
- 修复 API2.0 接口多 Element 解析问题

**Windows 平台**

- 修复已知内存泄漏问题
- 优化日志上传问题
- 修复 PC 上某些机型相同账号同时登录不会互踢的问题
- 修复 PC 收到消息乱序的问题

### TUIKit & Demo

**iOS**

- 增加群@的功能
- 增加新表情包
- 更新 SDWebImage 依赖库
- 优化有人申请加群 UI 展示的问题
- 优化音视频通话文本展示

**Android**

- 增加群@的功能
- 修复建群选择联系人时可能展示的与实际选择不一致的问题
- 修复自定义消息可能显示混乱的问题
- 修复 AVCallManager、TRTCAVCallImpl 偶现 Crash 的问题
- 增加新表情包

## 精简版 5.0.106 @2020.09.21

### SDK

**通用变更点**

- 修复已知稳定性问题

## TUIKit 开源贡献榜

谁是第一位英雄，请现身！
