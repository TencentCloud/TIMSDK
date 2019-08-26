
本文主要介绍如何快速地将腾讯云 IM SDK 集成到您的 Web 项目中，只要按照如下步骤进行配置，就可以完成 SDK 的集成工作。


## 准备工作
在集成 Web SDK 前，请确保您已完成以下步骤，请参见 [一分钟跑通 Demo](https://cloud.tencent.com/document/product/269/36838)。
- 创建了腾讯云即时通信 IM 应用，并获取到 SDKAppID。
- 获取密钥信息。

## 下载组件源码
您可以直接从 [Github](https://github.com/tencentyun/TIMSDK) 上下载 IM SDK H5 开发包。
SDK 存放路径为 TIMSDK/TIMSDK/H5/sdk/，相关文件清单如下：

| 目录| 说明 |
|:-------:|---------|
| json2.js | 提供了 JSON 的序列化和反序列化方法，可以将一个 JSON 对象转换成 JSON 字符串，也可以将一个 JSON 字符串转换成一个 JSON 对象，如果要需要在原生不支持 JSON 数据格式处理的浏览器使用 WEBIM SDK，则需要引入该文件 |
| spark-md5 | 用于获取文件 MD5，在上传图片时需要先获取文件的 MD5 |
| webim.js | WEBIM SDK 库，提供了聊天，群组管理，资料管理，关系链（好友，黑名单）管理功能 |

## 集成 SDK
在需要实现 WEB IM 的页面引入 SDK 相关文件：
```html
<script type="text/javascript" src="./sdk/json2.js"></script>
<!--用于获取文件MD5，上传图片需要先获取文件的 MD5-->
<script type="text/javascript" src="./sdk/spark-md5.js"></script>
<script type="text/javascript" src="./sdk/webim.js"></script>
```

## SDK 函数调用顺序

| 步骤 | 对应函数 | 说明 |
|---------|---------|---------|
| SDK 登录 | webim.login(loginInfo, listeners,opts,cbOk,cbErr);| 登录 SDK，需要传入当前用户信息，新消息通知回调函数等，注意，为了版本向下兼容，仍保留了老版本的初始化 init 接口，它和 login 是一样的，开发者调用其中一个即可。|
| 监听新消息|Demo 中使用的监听函数是 onMsgNotify（监听新消息）、groupSystemNotifys（监听群系统消息））|业务自定义监听函数，包括好友消息，群普通消息，群提示消息和群系统消息，登录时传给 SDK。 |
| 上报已读消息|webim.setAutoRead(selSess, isOn, isResetAll);|设置聊天会话自动已读标识。|
| 发消息 |webim.sendMsg(options,cbOk, cbErr); |发送消息（私聊和群聊）。 |
| 获取消息 |webim.getC2CHistoryMsgs (options,cbOk, cbErr);|获取好友历史消息。 |
| 获取消息 |webim.syncGroupMsgs(options,cbOk, cbErr);|获取群历史消息。 |
| 资料管理 |webim.getProfilePortrait(options,cbOk, cbErr);|查询个人资料。 |
| 资料管理 |webim.setProfilePortrait(options,cbOk, cbErr);|设置个人资料。 |
| 好友管理|webim.applyAddFriend(options,cbOk, cbErr);|申请添加好友。|
| 好友管理|webim.getAllFriend(options,cbOk, cbErr);等|获取我的好友等。|
| 群组管理|webim.createGroup(options,cbOk, cbErr);|创建群。|
| 群组管理|webim.applyJoinGroup(options,cbOk,cbErr);等|申请加群等。|
| SDK 登出|webim.logout(options,cbOk, cbErr); |退出，用于切换帐号登录。 |

## 支持的平台
- IM SDK 支持 IE 7+ ( Windows XP / Vista 除外)，Chrome 7+，FireFox 3.6+，Opera 12+ 和 Safari 6+。
- Demo 支持 IE 8+ ( Windows XP / Vista 除外)，Chrome 7+，FireFox 3.6+，Opera 12+ 和 Safari 6+。
