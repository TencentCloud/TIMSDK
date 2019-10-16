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

## 4.5.109 @2019.10.16

### SDK

**通用变更点**

- 修复获取群指定类型的成员列表接口的分页问题
- 发送文件类型消息时生成的 URL 增加格式后缀，提高在其他平台播放的兼容性
- 群自定义字段修改后增加通知回调
- 未登录调用 initStorage 方法后，可以获取本地用户和群组信息
- 修复内存泄露问题
- 修复发送消息后撤回，消息状态码不正确问题
- 修复 getMessage 回调错误码不对问题
- 修复强杀 App 重启后单聊未读数错误问题

**iOS & Mac 平台**

- 修复 Mac 休眠偶现一直登录失败问题

**Android 平台**

- 修复某些场景下的稳定性问题
- 修复离线推送在 Android 8.0 系统以上的 OPPO 手机无法接收离线推送问题
- 优化 getElementCount 接口的返回类型

**Windows 平台**

- 跨平台库优化各个平台的网络重连速度
- 修复 Windows 公开群设置管理失败问题
- 跨平台库新增 JVM 配置，方便 Android 环境传入 jvm

### TUIKit & Demo

**iOS**

- 支持与 Web 端互发语音消息
- 修复 swift 加载 TUIKit 资源文件找不到的问题
- 修复好友备注修改后，聊天界面看不到备注名的问题
- 修复会话置顶后会话列表不能及时刷新的问题

**Android**

- 支持与 Web 端互发语音消息
- 支持设置输入框样式
- 支持语音消息未读红点
- 修复 x86 设备视频消息不能播放的问题
- 修复 FileProvider 与集成端冲突的问题
- 修复部分机型上语音权限识别不到的问题
- 修复特定条件下头像不能正常加载的问题
- 修复偶尔气泡显示不全的问题
