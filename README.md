## 镜像下载

腾讯云分流下载地址： [DOWNLOAD](https://github-1252463788.cos.ap-shanghai.myqcloud.com/imsdk/TIMSDK-4.5.15.zip)

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

## 4.5.45 @2019.09.18

### SDK

**通用变更点**

- 优化网络连接的质量
- 修复删除群会话后，再收到新消息，修复未读数异常的问题
- 修复删除会话后，还能在会话更新回调里面获取到已删除会话的问题 
- 优化群/群成员自定义段拉取逻辑

**Android 平台**

- 废弃 TIMManager中的 setOfflinePushListener 接口 以及 TIMOfflinePushNotification 类

### TUIKit & Demo

**iOS**

- 修复 NSSting + Common.h  类冲突的问题
- 修复群 tips 消息展示不全的问题

**Android**

- 增加已读回执
- 兼容老版本正在输入显示
- 修复重发消息不能立即显示在聊天窗口最下方的问题
- 修复群聊时特定条件下不能显示头像的问题
- 修复不能显示多 elements 群消息的问题
- 修复特定消息导致的崩溃
- 修复群管理员权限错误的问题
- 修复web端发送文件不能正常接收的问题

