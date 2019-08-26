## SDK login API 函数

**函数名：**

```
webim.login
```

**定义：**

```
webim.login(loginInfo, listeners, options,cbOk,cbErr)
```

**示例：**

```javascript
//IM SDK 登录
function webimLogin() {
    webim.login(
            loginInfo, listeners, options,
            function (resp) {
                loginInfo.identifierNick = resp.identifierNick;//设置当前用户昵称
                initDemoApp();
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
}
```

## 用户信息对象 loginInfo


**属性名：**

| 名称           | 说明                                          | 类型   |
| -------------- | --------------------------------------------- | ------ |
| sdkAppID       | 用户标识接入 IM SDK 的应用 ID，必填              | String |
| appIDAt3rd     | App 用户使用 OAuth 授权体系分配的 Appid，必填 | String |
| identifier     | 用户帐号，必填                                | String |
| userSig        | 鉴权 Token，当填写了identifier，则该字段必填  | String |

>!Web 端目前只支持单实例登录，如需支持多实例登录（允许在多个网页中同时登录同一帐号），请到即时通信 IM 控制台相应 SDKAppID 【应用配置】 > 【功能配置】> 【Web端实例同时在线】配置实例个数。配置将在50分钟内生效。


## 事件回调对象 listeners


**属性名：**

| 名称                      | 说明                                   | 类型       |
| ----------------------- | ------------------------------------ | -------- |
| onConnNotify            | 用于监听用户连接状态变化的函数，选填                   | Function |
| jsonpCallback           | 用于 IE9（含）以下浏览器中 jsonp 回调函数,移动端可不填，PC 端必填 | Function |
| onMsgNotify             | 监听新消息函数，必填                           | Function |
| onBigGroupMsgNotify     | 监听新消息(直播聊天室)事件，**直播场景**下必填           | Function |
| onGroupInfoChangeNotify | 监听群资料变化事件，选填                         | Function |
| onGroupSystemNotifys    | 监听（多终端同步）群系统消息事件，选填                | Object   |
| onFriendSystemNotifys   | 监听好友系统通知事件，选填                        | Object   |
| onProfileSystemNotifys  | 监听资料系统（自己或好友）通知事件，选填                 | Object   |
| onKickedEventCall       | 被其他登录实例踢下线，选填                        | Function |
| onC2cEventNotifys       | 监听 C2C 系统消息通道，选填                       | Object   |


示例：

```javascript
//监听事件
var listeners = {
    "onConnNotify": onConnNotify//监听连接状态回调变化事件，选填
    ,"jsonpCallback": jsonpCallback//IE9（含）以下浏览器用到的 jsonp 回调函数
    ,"onMsgNotify": onMsgNotify//监听新消息（私聊，普通群（非直播聊天室）消息，全员推送消息）事件，必填
    ,"onBigGroupMsgNotify": onBigGroupMsgNotify//监听新消息（直播聊天室）事件，直播场景下必填
    ,"onGroupSystemNotifys": onGroupSystemNotifys//监听（多终端同步）群系统消息事件，如果不需要监听，可不填
    ,"onGroupInfoChangeNotify": onGroupInfoChangeNotify//监听群资料变化事件，选填
    ,"onFriendSystemNotifys": onFriendSystemNotifys//监听好友系统通知事件，选填
    ,"onProfileSystemNotifys": onProfileSystemNotifys//监听资料系统（自己或好友）通知事件，选填
    ,"onKickedEventCall" : onKickedEventCall//被其他登录实例踢下线
    ,"onC2cEventNotifys": onC2cEventNotifys//监听 C2C 系统消息通道
};
```

## 事件回调对象 listeners.onConnNotify

**示例：**

```javascript
//监听连接状态回调变化事件
var onConnNotify = function (resp) {
    var info;
    switch (resp.ErrorCode) {
        case webim.CONNECTION_STATUS.ON:
            webim.Log.warn('建立连接成功: ' + resp.ErrorInfo);
            break;
        case webim.CONNECTION_STATUS.OFF:
            info = '连接已断开，无法收到新消息，请检查下您的网络是否正常: ' + resp.ErrorInfo;
            alert(info);
            webim.Log.warn(info);
            break;
        case webim.CONNECTION_STATUS.RECONNECT:
            info = '连接状态恢复正常: ' + resp.ErrorInfo;
            alert(info);
            webim.Log.warn(info);
            break;
        default:
            webim.Log.error('未知连接状态: =' + resp.ErrorInfo);
            break;
    }
};
```

**其中回调返回的参数 `resp` 对象属性定义如下：**

| 名称         | 说明                                                     | 类型   |
| ------------ | -------------------------------------------------------- | ------ |
| ActionStatus | 连接状态标识，OK 表示连接成功 FAIL 表示连接失败          | String |
| ErrorCode    | 连接状态码，具体请参考 webim. CONNECTION_STATUS 常量对象 | Number |
| ErrorInfo    | 错误提示信息                                             | String |



## 事件回调对象 listeners.jsonpCallback

为了兼容低版本的 IE 浏览器，IM SDK 使用了 jsonp 技术调用后台接口。**示例：**

```javascript
//位于 js/demo_base.js 中
//IE9（含）以下浏览器用到的 jsonp 回调函数
function jsonpCallback(rspData) {
//设置 jsonp 返回的
    webim.setJsonpLastRspData(rspData);
}
```

属性名：

| 名称      | 说明      | 类型     |
| ------- | ------- | ------ |
| rspData | 接口返回的数据 | String |



## 事件回调对象 listeners.onMsgNotify

**示例：**

>注：其中参数 newMsgList 为 webim.Msg 数组，即 \[webim.Msg]。

```javascript
//监听新消息事件
//newMsgList 为新消息数组，结构为[Msg]
function onMsgNotify(newMsgList) {
    //console.warn(newMsgList);
    var sess, newMsg;
    //获取所有聊天会话
    var sessMap = webim.MsgStore.sessMap();
    for (var j in newMsgList) {//遍历新消息
        newMsg = newMsgList[j];
        if (newMsg.getSession().id() == selToID) {//为当前聊天对象的消息，selToID 为全局变量，表示当前正在进行的聊天 ID，当聊天类型为私聊时，该值为好友帐号，否则为群号。
            selSess = newMsg.getSession();
            //在聊天窗体中新增一条消息
            //console.warn(newMsg);
            addMsg(newMsg);
        }
    }
    //消息已读上报，以及设置会话自动已读标记
    webim.setAutoRead(selSess, true, true);
    for (var i in sessMap) {
        sess = sessMap[i];
        if (selToID != sess.id()) {//更新其他聊天对象的未读消息数
            updateSessDiv(sess.type(), sess.id(), sess.unread());
        }
    }
}
```

## 事件回调对象 listeners.onGroupSystemNotifys

**示例：**

```javascript
//监听（多终端同步）群系统消息方法，方法都定义在 receive_group_system_msg.js 文件中
//注意每个数字代表的含义，例如，
//1表示监听申请加群消息，2表示监听申请加群被同意消息，3表示监听申请加群被拒绝消息
var groupSystemNotifys = {
    "1": onApplyJoinGroupRequestNotify, //申请加群请求（只有管理员会收到）
    "2": onApplyJoinGroupAcceptNotify, //申请加群被同意（只有申请人能够收到）
    "3": onApplyJoinGroupRefuseNotify, //申请加群被拒绝（只有申请人能够收到）
    "4": onKickedGroupNotify, //被管理员踢出群（只有被踢者接收到）
    "5": onDestoryGroupNotify, //群被解散（全员接收）
    "6": onCreateGroupNotify, //创建群（创建者接收）
    "7": onInvitedJoinGroupNotify, //邀请加群（被邀请者接收）
    "8": onQuitGroupNotify, //主动退群（主动退出者接收）
    "9": onSetedGroupAdminNotify, //设置管理员（被设置者接收）
    "10": onCanceledGroupAdminNotify, //取消管理员（被取消者接收）
    "11": onRevokeGroupNotify, //群已被回收（全员接收）
    "255": onCustomGroupNotify//用户自定义通知（默认全员接收）
};
```

## 事件回调对象 listeners.onFriendSystemNotifys

**示例：**

```javascript
//监听好友系统通知函数对象，方法都定义在 receive_friend_system_msg.js 文件中
var onFriendSystemNotifys = {
    "1": onFriendAddNotify, //好友表增加
    "2": onFriendDeleteNotify, //好友表删除
    "3": onPendencyAddNotify, //未决增加
    "4": onPendencyDeleteNotify, //未决删除
    "5": onBlackListAddNotify, //黑名单增加
    "6": onBlackListDeleteNotify//黑名单删除
};
```

## 事件回调对象 listeners.onProfileSystemNotifys

**示例：**

```javascript
//监听资料系统通知函数对象，方法都定义在 receive_profile_system_msg.js 文件中
var onProfileSystemNotifys = {
    "1": onProfileModifyNotify//资料修改
};
```

## 事件回调对象 listeners.onC2cEventNotifys

**示例：**

```javascript
//监听 C2C 消息通道的处理，方法在 receive_new_msg.js 文件中
var onC2cEventNotifys = {
	"92": onMsgReadedNotify,//消息已读通知
};
```

## 事件回调对象 listeners.onGroupInfoChangeNotify

**示例：**

```javascript
//监听 群资料变化 群提示消息
function onGroupInfoChangeNotify(groupInfo) {
    webim.Log.warn("执行 群资料变化 回调： " + JSON.stringify(groupInfo));
    var groupId = groupInfo.GroupId;
    var newFaceUrl = groupInfo.GroupFaceUrl;//新群组图标, 为空，则表示没有变化
    var newName = groupInfo.GroupName;//新群名称, 为空，则表示没有变化
    var newOwner = groupInfo.OwnerAccount;//新的群主 ID, 为空，则表示没有变化
    var newNotification = groupInfo.GroupNotification;//新的群公告, 为空，则表示没有变化
    var newIntroduction = groupInfo.GroupIntroduction;//新的群简介, 为空，则表示没有变化
    if (newName) {
        //更新群组列表的群名称
        //To do
        webim.Log.warn("群id=" + groupId + "的新名称为：" + newName);
    }
}
```

**其中返回的参数 `groupInfo` 对象属性如下：**

| 名称                | 说明                 | 类型     |
| ----------------- | ------------------ | ------ |
| GroupId           | 群 ID                | String |
| GroupFaceUrl      | 新群组图标，为空，则表示没有变化  | String |
| GroupName         | 新群名称，为空，则表示没有变化   | String |
| OwnerAccount      | 新的群主 ID，为空，则表示没有变化 | String |
| GroupNotification | 新的群公告，为空，则表示没有变化  | String |
| GroupIntroduction | 新的群简介，为空，则表示没有变化  | String |


## 其他对象 options

**属性名：**

| 名称                | 说明                                       | 类型      |
| ----------------- | ---------------------------------------- | ------- |
| isAccessFormalEnv | 是否访问正式环境下的后台接口，True-访问正式，False-访问测试环境默认访问正式环境接口，选填 | Boolean |
| isLogOn           | 是否开启控制台打印日志，True-开启，False-关闭，默认开启，选填     | Boolean |



## 回调函数 cbOk & cbErr

IM SDK 登录时，可以定义成功回调函数和失败回调函数。**示例：**

```javascript
//IM SDK 登录
function webimLogin() {
    webim.login(
            loginInfo, listeners, options,
            function (resp) {
                loginInfo.identifierNick = resp.identifierNick;//设置当前用户昵称
                initDemoApp();
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
}
```
>? 当您集成 IM SDK 出现错误时，请参考 [错误码](https://cloud.tencent.com/document/product/269/1671) 进行处理。

