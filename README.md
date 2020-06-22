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

## 4.8.50 @2020.06.22

### SDK

**通用变更点**

- 修复 API 2.0 接口有人进入直播群（AVChatRoom）后没有回调 onMemberEnter 问题
- API 2.0 接口的 onGroupInfoChanged 和 onMemberInfoChanged 回调增加 groupID 参数
- 修复 C2C 消息发送成功后没有回调会话更新的问题
- 修复切换帐号加入同一个直播群（AVChatRoom）后收不到消息的问题
- 修复偶现登录后同步未读消息回调顺序不对的问题
- 增加信令接口
- 直播群（AVChatRoom）增加群自定义属性接口
- 修复已知崩溃问题

**Android 平台**

- 为兼容 android Q 版本，修改日志默认存储位置为 /sdcard/Android/data/包名/files/log/tencent/imsdk

**Windows 平台**

- 修复建群时群成员角色问题

### TUIKit & Demo

**iOS**

- tuikit 替换 api 2.0接口
- 结合 TRTC 实现了音视频通话功能
- 增加了深色模式

**Android**
- tuikit 替换 api 2.0接口
- 结合 TRTC 实现了音视频通话功能
- 支持 AndroidX