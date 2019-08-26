

当有用户申请加群等事件发生时，管理员会收到邀请加群系统消息，相应的消息会通过群系统消息展示给用户。目前支持自动拉取群系统消息。

## 监听群系统消息

**定义监听群系统消息示例：**

```
//监听（多终端同步）群系统消息事件
var groupSystemNotifys = {
    "1": onApplyJoinGroupRequestNotify, //申请加群请求（只有管理员会收到，不支持）
    "2": onApplyJoinGroupAcceptNotify, //申请加群被同意（只有申请人能够收到，不支持）
    "3": onApplyJoinGroupRefuseNotify, //申请加群被拒绝（只有申请人能够收到，不支持）
    "4": onKickedGroupNotify, //被管理员踢出群(只有被踢者接收到，不支持)
    "5": onDestoryGroupNotify, //群被解散(全员接收，支持)
    "6": onCreateGroupNotify, //创建群(创建者接收，不支持)
    "7": onInvitedJoinGroupNotify, //邀请加群(被邀请者接收，不支持)
    "8": onQuitGroupNotify, //主动退群(主动退出者接收，不支持)
    "9": onSetedGroupAdminNotify, //设置管理员(被设置者接收，不支持)
    "10": onCanceledGroupAdminNotify, //取消管理员(被取消者接收，不支持)
    "11": onRevokeGroupNotify, //群已被回收(全员接收，支持)
    "255": onCustomGroupNotify//用户自定义通知(默认全员接收，支持)
};
```

**显示群系统消息示例：**

```
//显示一条群组系统消息
function showGroupSystemMsg(type, typeCh, group_id, group_name, msg_content, msg_time) {
    var sysMsgStr="收到一条群系统消息: type="+type+", typeCh="+typeCh+",群ID="+group_id+", 群名称="+group_name+", 内容="+msg_content+", 时间="+webim.Tool.formatTimeStamp(msg_time);
    webim.Log.warn(sysMsgStr);
    alert(sysMsgStr);
}
```

## 监听群被解散消息

**触发时机：**当群被解散时，全员会收到解散群消息。支持全员接收消息。

**示例：**

```
//监听 解散群 系统消息
function onDestoryGroupNotify(notify) {
    webim.Log.warn("执行 解散群 回调："+JSON.stringify(notify));
    var reportTypeCh = "[群被解散]";
    var content = "群主" + notify.Operator_Account + "已解散该群";
    showGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
```


## 监听群被回收消息

**触发时机：**当有用户申请加群时，群管理员会收到申请加群消息，管理员决定是否同意对方加群。支持全员接收消息。

**示例：**

```
//监听 群被回收 系统消息
function onRevokeGroupNotify(notify) {
    webim.Log.warn("执行 群被回收 回调："+JSON.stringify(notify));
    var reportTypeCh = "[群被回收]";
    var content = "该群已被回收";
    showGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
```

## 监听自定义群通知消息

**触发时机：**当 App 管理员通过控制台发出自定义的系统消息时，全员可收到该消息。支持全员接收消息。

**示例：**

```
//监听用户自定义群系统消息
function onCustomGroupNotify(notify) {
    webim.Log.warn("执行 用户自定义系统消息 回调："+JSON.stringify(notify));
    var reportTypeCh = "[用户自定义系统消息]";
    var content = notify.UserDefinedField;//群自定义消息数据
    showGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
```
