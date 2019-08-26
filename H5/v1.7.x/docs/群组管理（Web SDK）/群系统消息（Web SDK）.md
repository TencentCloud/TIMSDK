当有用户申请加群等事件发生时，管理员会收到邀请加群系统消息，相应的消息会通过群系统消息展示给用户。**群系统消息类型主要有以下几种：**

```javascript
//群系统消息类型
var WEB_IM_GROUP_SYSTEM_TYPE = {
    "JOIN_GROUP_REQUEST": 1, //申请加群请求（只有管理员会收到）
    "JOIN_GROUP_ACCEPT": 2, //申请加群被同意（只有申请人能够收到）
    "JOIN_GROUP_REFUSE": 3, //申请加群被拒绝（只有申请人能够收到）
    "KICK": 4, //被管理员踢出群(只有被踢者接收到)
    "DESTORY": 5, //群被解散(全员接收)
    "CREATE": 6, //创建群(创建者接收, 不展示)
    "INVITED_JOIN_GROUP_REQUEST": 7, //邀请加群(被邀请者接收)
    "QUIT": 8, //主动退群(主动退出者接收, 不展示)
    "SET_ADMIN": 9, //设置管理员(被设置者接收)
    "CANCEL_ADMIN": 10, //取消管理员(被取消者接收)
    "REVOKE": 11, //群已被回收(全员接收, 不展示)
    "CUSTOM": 255//用户自定义通知(默认全员接收)
};
```

目前是通过定义群系统消息监听事件来处理群系统消息的。**示例：**

```javascript
//监听（多终端同步）群系统消息，方法都定义在 webim_demo_group_notice.js 文件中
//注意每个数字代表的含义，例如，
//1 表示监听申请加群消息，2 表示监听申请加群被同意消息，3 表示监听申请加群被拒绝消息
var groupSystemNotifys = {
    "1": onApplyJoinGroupRequestNotify, //申请加群请求（只有管理员会收到）
    "2": onApplyJoinGroupAcceptNotify, //申请加群被同意（只有申请人能够收到）
    "3": onApplyJoinGroupRefuseNotify, //申请加群被拒绝（只有申请人能够收到）
    "4": onKickedGroupNotify, //被管理员踢出群(只有被踢者接收到)
    "5": onDestoryGroupNotify, //群被解散(全员接收)
    "6": onCreateGroupNotify, //创建群(创建者接收)
    "7": onInvitedJoinGroupNotify, //邀请加群(被邀请者接收)
    "8": onQuitGroupNotify, //主动退群(主动退出者接收)
    "9": onSetedGroupAdminNotify, //设置管理员(被设置者接收)
    "10": onCanceledGroupAdminNotify, //取消管理员(被取消者接收)
    "11": onRevokeGroupNotify, //群已被回收(全员接收)
    "255": onCustomGroupNotify//用户自定义通知(默认全员接收,暂不支持)
};
```

**Demo 提供了查看群系统消息通知的入口： **

![](//mccdn.qcloud.com/static/img/acf4d425d2353617a543784916396539/image.png)

## 申请加群

**触发时机：**当有用户申请加群时，群管理员会收到申请加群消息，管理员决定是否同意对方加群。

**Demo 提供了查看加群申请的入口：**

![](//mccdn.qcloud.com/static/img/ccc1a4aa08e8141fb90d18be59b18b2a/image.png)

**示例：**

```javascript
//监听 申请加群 系统消息
function onApplyJoinGroupRequestNotify(notify) {
   console.info("执行 加群申请 回调： %s", JSON.stringify(notify));
   var data = [];
   var timestamp = notify.MsgTime;
   notify.MsgTimeStamp = timestamp;
   notify.MsgTime = webim.Tool.formatTimeStamp(notify.MsgTime);
   data.push(notify);
   $('#get_apply_join_group_pendency_table').bootstrapTable('append', data);
   $('#get_apply_join_group_pendency_dialog').modal('show');

   var reportTypeCh = "[申请加群]";
   var content = notify.Operator_Account + "申请加入您的群";
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, timestamp);
}
```

## 申请加群被同意

**触发时机：**当管理员同意加群请求时，申请人会收到同意加群的消息。

**示例：**

```javascript
//监听 申请加群被同意 系统消息
function onApplyJoinGroupAcceptNotify(notify) {
   console.info("执行 申请加群被同意 回调： %s", JSON.stringify(notify));
   //刷新我的群组列表
   getJoinedGroupListHigh(getGroupsCallbackOK);
   var reportTypeCh = "[申请加群被同意]";
   var content = notify.Operator_Account + "同意您的加群申请，附言：" + notify.RemarkInfo;
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```

## 申请加群被拒绝

**触发时机：**当管理员拒绝时，申请人会收到拒绝加群的消息。

**示例： **

```javascript
//监听 申请加群被拒绝 系统消息
function onApplyJoinGroupRefuseNotify(notify) {
   console.info("执行 申请加群被拒绝 回调： %s", JSON.stringify(notify));
   var reportTypeCh = "[申请加群被拒绝]";
   var content = notify.Operator_Account + "拒绝了您的加群申请，附言：" + notify.RemarkInfo;
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```

## 被管理员踢出群

**触发时机：**当用户被管理员踢出群组时，用户会收到被踢出群的消息。

**示例：**

```javascript
//监听 被踢出群 系统消息
function onKickedGroupNotify(notify) {
   console.info("执行 被踢出群  回调： %s", JSON.stringify(notify));
   //刷新我的群组列表
   getJoinedGroupListHigh(getGroupsCallbackOK);
   var reportTypeCh = "[被踢出群]";
   var content = "您被管理员" + notify.Operator_Account + "踢出该群";
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```

## 解散群

**触发时机：**当群被解散时，全员会收到解散群消息。

**示例： **

```javascript
//监听 解散群 系统消息
function onDestoryGroupNotify(notify) {
   console.info("执行 解散群 回调： %s", JSON.stringify(notify));
   //刷新我的群组列表
   getJoinedGroupListHigh(getGroupsCallbackOK);
   var reportTypeCh = "[群被解散]";
   var content = "群主" + notify.Operator_Account + "已解散该群";
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```

## 创建群

**触发时机：**当创建群成功时，创建者会收到创建群消息。

**示例： **

```javascript
//监听 创建群 系统消息
function onCreateGroupNotify(notify) {
   console.info("执行 创建群 回调： %s", JSON.stringify(notify));
   var reportTypeCh = "[创建群]";
   var content = "您创建了该群";
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```

## 被邀请加群

**触发时机：**当用户被邀请加入群组时，该用户会收到邀请消息，**创建群组时初始成员无需邀请即可入群**。

**示例：**

```javascript
//监听 被邀请加群 系统消息
function onInvitedJoinGroupNotify(notify) {
   console.info("执行 被邀请加群  回调： %s", JSON.stringify(notify));
   //刷新我的群组列表
   getJoinedGroupListHigh(getGroupsCallbackOK);
   var reportTypeCh = "[被邀请加群]";
   var content = "您被管理员" + notify.Operator_Account + "邀请加入该群";
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```

## 主动退群

**触发时机：**当用户主动退出群组时，该用户会收到退群消息，只有退群的用户自己可以收到。

**示例：**

```javascript
//监听 主动退群 系统消息
function onQuitGroupNotify(notify) {
   console.info("执行 主动退群  回调： %s", JSON.stringify(notify));
   var reportTypeCh = "[主动退群]";
   var content = "您退出了该群";
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```

## 被设为管理员

**触发时机：**当用户被设置为管理员时，可收到被设置管理员的消息通知，可提示用户。

**示例： **

```javascript
//监听 被设置为管理员 系统消息
function onSetedGroupAdminNotify(notify) {
   console.info("执行 被设置为管理员  回调： %s", JSON.stringify(notify));
   var reportTypeCh = "[被设置为管理员]";
   var content = "您被群主" + notify.Operator_Account + "设置为管理员";
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```

## 被取消管理员

**触发时机：**当用户被取消管理员时，可收到取消通知，可提示用户。

**示例：**

```javascript
//监听 被取消管理员 系统消息
function onCanceledGroupAdminNotify(notify) {
   console.info("执行 被取消管理员 回调： %s", JSON.stringify(notify));
   var reportTypeCh = "[被取消管理员]";
   var content = "您被群主" + notify.Operator_Account + "取消了管理员资格";
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```

## 群被回收

**触发时机：**当群组被系统回收时，全员可收到群组被回收消息。

**示例： **

```javascript
//监听 群被回收 系统消息
function onRevokeGroupNotify(notify) {
   console.info("执行 群被回收 回调： %s", JSON.stringify(notify));
   //刷新我的群组列表
   getJoinedGroupListHigh(getGroupsCallbackOK);
   var reportTypeCh = "[群被回收]";
   var content = "该群已被回收";
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```

## 用户自定义

**触发时机：**只有 App 管理员才可以发送自定义系统通知，全员可收到该消息。

**发送 API：**

```javascript
/* function sendCustomGroupNotify
	 *   发送自定义群通知
	 * params:
	 *   options	- 请求参数
	 *   cbOk	- function()类型, 成功时回调函数
	 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
	 * return:
	 *   (无)
	 */
	sendCustomGroupNotify: function(options,cbOk, cbErr) {},
```


>?详细参数说明请参考 [在群组中发送系统通知 API](https://cloud.tencent.com/document/product/269/1630)。

Demo 增加了发送自定义通知入口，在 Demo 中单击【菜单】-【群组】-【我的群组】。**发送自定义群通知如下图：**

![](//mccdn.qcloud.com/static/img/b762e41a5b46b23ac72699bf330adb75/image.png)

**发送 Demo：**

```javascript
//发送自定义群系统通知
var sendCustomGroupNotify = function () {
    var content=$("#sgsm_content").val();
    if (content.length < 1) {
        alert("发送的消息不能为空!");
        return;
    }
    if (webim.Tool.getStrBytes(content) > MaxMsgLen.GROUP) {
        alert("消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)");
        return;
    }
    var options = {
        'GroupId': $("#sgsm_group_id").val(),
        'Content': content
    };
    webim.sendCustomGroupNotify(
            options,
            function (resp) {
                $('#send_group_system_msg_dialog').modal('hide');
                alert('发送成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

**监听解析 Demo：**

```javascript
//监听 用户自定义 群系统消息
function onCustomGroupNotify(notify) {
   console.info("执行 用户自定义系统消息 回调： %s", JSON.stringify(notify));
   var reportTypeCh = "[用户自定义系统消息]";
   var content = "收到了自己自定义的系统消息";
   addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId,
                     notify.GroupName, content, notify.MsgTime);
}
```
