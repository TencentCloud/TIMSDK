[English](./README.md) | 简体中文

公告：TUIKit Android 与 iOS 端开放 Pull Request，merge 成功后会在 README.md 上留下您的大名并超链到您的 Github 主页！

## 镜像下载

腾讯云分流下载地址： [DOWNLOAD](https://im.sdk.qcloud.com/download/github/TIMSDK.zip)

## SDK下载

<table>
<tr>
<th width="94px" style="text-align:center" >终端 SDK</td>
 <th width="0px" style="text-align:center" >下载地址</td>
<th width="0px"  style="text-align:center">集成指引文档</td>
<th width="175px" style="text-align:center">更新日志</td>
</tr>
<tr>
<td style="text-align:center">Android  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/Android/IMSDK">Github(推荐)</a></td>
<td style="text-align:left" ><a href="https://cloud.tencent.com/document/product/269/37059">【极速集成】导入TUIKit (Android)</a><br><a href="https://cloud.tencent.com/document/product/269/32679">【常规集成】快速导入到工程 (Android)</a></td>
<td style="text-align:center" rowspan='4'><a href="https://cloud.tencent.com/document/product/269/1606">更新日志(终端)</a> </td>
</tr>
<tr>
<td style="text-align:center">iOS  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/iOS/IMSDK">Github(推荐)</a></td>
<td style="text-align:left" ><a href="https://cloud.tencent.com/document/product/269/37060">【极速集成】导入TUIKit (iOS)</a><br><a href="https://cloud.tencent.com/document/product/269/32675">【常规集成】快速导入到工程  (iOS)</a></td>
</tr>
<tr>
<td style="text-align:center">Mac  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/Mac/IMSDK">Github(推荐)</a></td>
<td style="text-align:left" ><a href="https://cloud.tencent.com/document/product/269/32676">【常规集成】快速导入到工程 (Mac)</a></td>
</tr>
<tr>
<td style="text-align:center">Windows  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/Windows/IMSDK">Github(推荐)</a></td>
<td style="text-align:left" ><a href="https://cloud.tencent.com/document/product/269/33489">【常规集成】快速导入到工程 (Windows)</a></td>
</tr>
</table>

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

## 基础版与增强版差异对比
- SDK 从 5.4 版本开始，原有精简版改名为增强版，原有标准版改名为基础版。
- 增强版与基础版同时支持 [V2 API](https://cloud.tencent.com/document/product/269/44498)；但增强版不再支持旧版 API，基础版继续支持旧版 API。
- 如果您没有接入过旧版 API，建议您直接使用 [V2 API](https://cloud.tencent.com/document/product/269/44498)，选择增强版 SDK。
- 如果您已经接入了旧版 API，推荐您升级到 [V2 API](https://cloud.tencent.com/document/product/269/44498)，逐步切换到增强版 SDK。
- 在 SDK 体积和安装包增量上，增强版与基础版相比有大幅度缩减。
- 在 SDK 功能支持上，增强版与基础版相比提供了更多新功能特性。
- 后续新功能开发，只在增强版上提供支持；基础版后续只做例行维护与现有问题修复。
- SDK 从 6.8 版本开始，发布增强版 Pro，支持网络层双线路加速，提供更强的网络抗性。

### SDK 体积大小对比
<table>
  <tr>
    <th width="200px" style="text-align:center">平台</th>
    <th width="260px" style="text-align:center">对比项</th>
    <th width="200px" style="text-align:center">基础版</th>
    <th width="200px" style="text-align:center">增强版</th>
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
    <th width="200px" style="text-align:center">基础版</th>
    <th width="200px" style="text-align:center">增强版</th>
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

## IMSDK 升级 V2API 接口指引

[接口升级指引](https://docs.qq.com/sheet/DS3lMdHpoRmpWSEFW)

## 最新增强版 6.8.3374 @2022.11.14

### SDK

- 支持客户端本地文本审核
- 发布 Swift 版本 SDK
- 支持普通群的群属性功能
- 优化普通群有人进出后，群成员人数的更新逻辑
- 优化 cos 上传流程
- 优化社群中消息撤回等操作后的未读数计算问题
- 修复单独设置好友自定义字段不会下发通知的问题
- 修复群监听回调两次的问题
- 修复退出并再次进入同一个社群后，社群下的话题资料没有及时更新的问题
- 修复插入本地消息成功后的回调中，消息对象头像为空的问题
- 修复重复登录设置消息扩展偶现报错的问题
- 修复标记所有会话已读后，会话更新回调中消息已读不更新的问题
- 修复在登录回调后立即发消息，消息的 send_user_id 偶现为空的问题
- C++ API 添加判断消息是否已读的接口
- C++ API 修复分页拉取会话列表的结果中游标不更新的问题

### TUIKit & Demo

- 修复 iOS16 长按文本消息，弹出搜索网页弹窗的问题
- TUIChat-iOS 支持发送 gif 图片
- TUIChat-iOS 修复图片发送状态异常的问题
- TUIChat-iOS 删除消息支持同时删除时间
- 修复 iOS TUIOfflinePush 引起的系统异常等问题
- 修复 Android TUIOfflinePush 推送参数设置不生效问题

 
## 最新基础版 5.1.66 @2021.09.22

### Android

- 去掉 WiFi 信息的获取

## 问题反馈
- 为了更好的了解您使用TIMSDK所遇到的问题，方便快速有效定位解决TIMSDK问题，希望您按如下反馈指引反馈issue，方便我们尽快解决您的问题
- [TIMSDK issue反馈指引](https://github.com/tencentyun/TIMSDK/wiki/TIMSDK-issue%E6%9C%89%E6%95%88%E5%8F%8D%E9%A6%88%E6%A8%A1%E6%9D%BF)
