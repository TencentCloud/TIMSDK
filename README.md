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

## 4.6.1 @2019.11.13

### SDK

**通用变更点**

- 撤回消息支持漫游
- 修复restAPI静默邀请进群引发未读数错误
- 修复弱网下偶现发消息异常
- 修复获取群成员时，角色过滤条件错误逻辑
- 修复通过 RestApi 创建的群组，第一次进群发消息，获取群 name 失败的问题
- 修复关闭缓存后 getUsersProfile 获取用户信息失败的问题
- 修复语音消息文件在没有后缀的情况下，接收后无法下载问题

**iOS & Mac 平台**

- 增加 OPPOChannelID 的设置，解决 Android 8.0 系统以上的 OPPO 手机接收 iOS 消息推送失败的问题
- 优化 getGrouplist 返回对象的注释

**Android 平台**

- 8.0 系统以上的 OPPO 手机离线推送的 channleID 支持在控制台设置
- 废弃 TIMCustomElem 的 ext、sound、desc 字段

**Windows 平台**

- 修复群系统消息的类型字段异常
- 修复返回的群组信息中群组类型与头文件不一致问题
- 修复创建群组时指定群组自定义字段失败问题
- 消息新增发送者资料以及离线推送配置

### TUIKit & Demo

**iOS**

- 增加视频通话功能
- 增加群组头像九宫格合成展示
- 优化会话列表、通讯录以及聊天界面UI

**Android**

- 增加方法来设置对方已读回执是否展示
- 增加群组头像九宫格合成展示
- 优化会话列表、通讯录以及聊天界面UI
- 解决部分手机输入法、界面、文件选择等兼容性问题
- 解决自定义消息会显示错乱的问题
- 解决压力测试下通讯录加载缓慢的问题
- 解决与其他库资源冲突的问题
- 解决cache目录设置不生效的问题
