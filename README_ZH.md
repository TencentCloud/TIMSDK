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

## IMSDK 升级 V2API 接口指引

[接口升级指引](https://docs.qq.com/sheet/DS3lMdHpoRmpWSEFW)

## 最新增强版 7.6.5011 @2023.11.03
### SDK
- 在线状态支持返回终端类型
- 发文本、图片消息被安全打击后本地保存安全打击状态
- C 接口层的会话信息补充会话头像和群组具体类型
- 优化消息发送失败状态以及重发逻辑
- 优化消息回应无网络下的拉取逻辑
- 修复跨站切换 sdkappid 偶现连网失败的问题
- 修复被挤下线后，仍然可以云端搜索的问题

### TUIKit & Demo
- 新增推送插件，控制台支持查看统计指标数据，支持排查工具
- 新增开源客服插件 TUICustomerServicePlugin
- TUIChat 发送语音消息增加 60 秒倒计时
- TUIChat 使用新的撤回接口，支持显示撤回操作者
- 优化被安全打击的图片/视频/音频的显示

