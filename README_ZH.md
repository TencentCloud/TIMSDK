[English](./README.md) | 简体中文

公告：TUIKit Android 与 iOS 端开放 Pull Request，merge 成功后会在 README.md 上留下您的大名并超链到您的 Github 主页！

# 即时通信 IM
## 产品简介
即时通信 IM（Instant Messaging）基于 QQ 底层 IM 能力开发，仅需植入 IM SDK 即可轻松集成聊天、会话、群组、资料管理和直播弹幕能力，也支持通过信令消息与白板等其他产品打通，全面覆盖您的业务场景，支持各大平台小程序接入使用，全面满足通信需要。

<table style="text-align:center; vertical-align:middle; width:440px">
  <tr>
    <th style="text-align:center;" width="220px">Android 体验 App</th>
    <th style="text-align:center;" width="220px">iOS 体验 App</th>
  </tr>
  <tr>
    <td><img style="width:200px" src="https://qcloudimg.tencent-cloud.cn/raw/078fbb462abd2253e4732487cad8a66d.png"/></td>
    <td><img style="width:200px" src="https://qcloudimg.tencent-cloud.cn/raw/b1ea5318e1cfce38e4ef6249de7a4106.png"/></td>
   </tr>
</table>

我们提供了一套基于 IM SDK 的 TUIKit 组件库，组件库包含了会话、聊天、搜索、关系链、群组、音视频通话等功能。基于 UI 组件您可以像搭积木一样快速搭建起自己的业务逻辑。

<img src="https://qcloudimg.tencent-cloud.cn/raw/40795a52d2df3d6c1f9ed41a51638da5.png" style="zoom:50%;"/>

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
<td style="text-align:left" ><a href="https://cloud.tencent.com/document/product/269/37059">【极速集成】导入TUIKit (Android)</a><br><a href="https://cloud.tencent.com/document/product/269/75283">【常规集成】快速导入到工程 (Android)</a></td>
<td style="text-align:center" rowspan='4'><a href="https://cloud.tencent.com/document/product/269/1606">更新日志(终端)</a> </td>
</tr>
<tr>
<td style="text-align:center">iOS  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/iOS/IMSDK">Github(推荐)</a></td>
<td style="text-align:left" ><a href="https://cloud.tencent.com/document/product/269/37060">【极速集成】导入TUIKit (iOS)</a><br><a href="https://cloud.tencent.com/document/product/269/75284">【常规集成】快速导入到工程  (iOS)</a></td>
</tr>
<tr>
<td style="text-align:center">Mac  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/Mac/IMSDK">Github(推荐)</a></td>
<td style="text-align:left" ><a href="https://cloud.tencent.com/document/product/269/75288">【常规集成】快速导入到工程 (Mac)</a></td>
</tr>
<tr>
<td style="text-align:center">Windows  </td>
<td style="text-align:center" ><a href="https://github.com/tencentyun/TIMSDK/tree/master/Windows/IMSDK">Github(推荐)</a></td>
<td style="text-align:left" ><a href="https://cloud.tencent.com/document/product/269/75287">【常规集成】快速导入到工程 (Windows)</a></td>
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
     <td rowspan='2' style="text-align:center">TUIKit 界面库</td>
     <td style="text-align:center">iOS</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37190">TUIKit-iOS界面库</a></td>
  </tr>

  <tr>
     <td style="text-align:center">Android</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37190">TUIKit-Android界面库</a></td>
  </tr>
    
  <tr >
     <td rowspan='2' style="text-align:center">快速集成</td>
     <td style="text-align:center">iOS</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37060">TUIKit-iOS快速集成</a></td>
  </tr>

  <tr>
     <td style="text-align:center">Android</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37059">TUIKit-Android快速集成</a></td>
  </tr>

  <tr>
     <td rowspan='2' style="text-align:center">修改界面主题</td>
     <td style="text-align:center">iOS</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/79705">TUIKit-iOS修改界面主题</a></td>
  </tr>

  <tr>
     <td style="text-align:center">Android</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/79704">TUIKit-Android修改界面主题</a></td>
  </tr>

  <tr>
     <td rowspan='2' style="text-align:center">设置界面风格</td>
     <td style="text-align:center">iOS</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/79082">TUIKit-iOS设置界面风格</a></td>
  </tr>

  <tr>
     <td style="text-align:center">Android</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/79081">TUIKit-Android设置界面风格</a></td>
  </tr>

  <tr>
     <td rowspan='2' style="text-align:center">添加自定义消息</td>
     <td style="text-align:center">iOS</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37067">TUIKit-iOS添加自定义消息</a></td>
  </tr>

  <tr>
     <td style="text-align:center">Android</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/37066">TUIKit-Android添加自定义消息</a></td>
  </tr>
    
   <tr> 
     <td rowspan='2' style="text-align:center">添加自定义表情</td>
     <td style="text-align:center">iOS</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/81912">TUIKit-iOS添加自定义表情</a></td>
  </tr>

  <tr>
     <td style="text-align:center">Android</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/81911">TUIKit-Android添加自定义表情</a></td>
  </tr>
    
   <tr>
     <td rowspan='2' style="text-align:center">实现本地搜索</td>
     <td style="text-align:center">iOS</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/76103">TUIKit-iOS实现本地搜索</a></td>
  </tr>

  <tr>
     <td style="text-align:center">Android</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/76102">TUIKit-Android实现本地搜索</a></td>
  </tr>
    
  <tr>
     <td rowspan='2' style="text-align:center">接入离线推送</td>
     <td style="text-align:center">iOS</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/74284">TUIKit-iOS接入离线推送</a></td>
  </tr>

  <tr>
     <td style="text-align:center">Android</td>
     <td style="text-align:center"><a href="https://cloud.tencent.com/document/product/269/74285">TUIKit-Android接入离线推送</a></td>
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

## 最新增强版 7.2.4123 @2023.04.25
### SDK

- 话题支持清空消息
- 增加会话被删除的回调
- 优化登录后同步会话列表的速度
- 在普通群和社群内踢人支持封禁
- 本地内容审核针对西欧字母系语言支持分词检查
- 社群支持设置申请入群和邀请入群的审批选项
- Android 离线推送支持 vivo 手机消息二级分类
- 直播群支持云控配置消息长轮询任务的数量
- 单聊已读上报禁止回退已读时间戳
- 群聊已读上报的 sequence 不能超过群最后一条消息的 sequence
- Android 离线推送适配华为、小米、FCM 的 Android 12 系统
- 修复自己发送的群消息缺少群名片字段的问题
- 修复编辑消息成功后偶现不触发消息变更回调的问题
- 修复被踢出群会重复回调 onMemberKicked 的问题
- 修复 Swift 版本消息多 element 解析异常的问题
- 修复特定条件下拉取群消息无回调问题
- 修复撤回消息后偶现未读数更新不及时的问题
- 修复 Android C/C++ 版本偶现 openssl 崩溃的问题

### TUIKit & Demo

- 新增历史通话记录页面
- 消息翻译支持设置目标语言
- TUIChat 新增消息撤回时间配置选项
- 修复在简约版下使用某些第三方输入法发送消息时，点击回车无响应的问题
 
## 最新基础版 5.1.66 @2021.09.22

### Android

- 去掉 WiFi 信息的获取

## 问题反馈
- 为了更好的了解您使用TIMSDK所遇到的问题，方便快速有效定位解决TIMSDK问题，希望您按如下反馈指引反馈issue，方便我们尽快解决您的问题
- [TIMSDK issue反馈指引](https://github.com/tencentyun/TIMSDK/wiki/TIMSDK-issue%E6%9C%89%E6%95%88%E5%8F%8D%E9%A6%88%E6%A8%A1%E6%9D%BF)
