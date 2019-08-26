当有用户被邀请加入群组，或者有用户被移出群组时，群内会产生有提示消息，调用方可以根据需要展示给群组用户，或者忽略。如下图中，展示一条用户主动退群的提示消息。

![](//mccdn.qcloud.com/static/img/26477a470aaa4149480fad643efea12d/image.png)

**群提示消息类型定义如下：**

```javascript
//群提示消息类型
var WEB_IM_GROUP_TIP_TYPE = {
    "JOIN": 1, //加入群组
    "QUIT": 2, //退出群组
    "KICK": 3, //被踢出群组
    "SET_ADMIN": 4, //被设置为管理员
    "CANCEL_ADMIN": 5, //被取消管理员
    "MODIFY_GROUP_INFO": 6, //修改群资料
    "MODIFY_MEMBER_INFO": 7//修改群成员信息
};
```

**群提示消息对象定义如下：**

```javascript
// class Msg.Elem.GroupTip 群提示消息对象
Msg.Elem.GroupTip = function (opType, opUserId, groupId, groupName, userIdList) {
    this.opType = opType;//操作类型
    this.opUserId = opUserId;//操作者 ID
    this.groupId = groupId;//群 ID
    this.groupName = groupName;//群名称
    this.userIdList = userIdList ? userIdList : [];//被操作的用户 ID 列表
    this.groupInfoList = [];//新的群资料信息，群资料变更时才有值
    this.memberInfoList = [];//新的群成员资料信息，群成员资料变更时才有值
    this.groupMemberNum = null;//群成员数，操作类型为加群或者退群时才有值
};
Msg.Elem.GroupTip.prototype.addGroupInfo = function (groupInfo) {
    this.groupInfoList.push(groupInfo);
};
Msg.Elem.GroupTip.prototype.addMemberInfo = function (memberInfo) {
    this.memberInfoList.push(memberInfo);
};
Msg.Elem.GroupTip.prototype.getOpType = function () {
    return this.opType;
};
Msg.Elem.GroupTip.prototype.getOpUserId = function () {
    return this.opUserId;
};
Msg.Elem.GroupTip.prototype.getGroupId = function () {
    return this.groupId;
};
Msg.Elem.GroupTip.prototype.getGroupName = function () {
    return this.groupName;
};
Msg.Elem.GroupTip.prototype.getUserIdList = function () {
    return this.userIdList;
};
Msg.Elem.GroupTip.prototype.getGroupInfoList = function () {
    return this.groupInfoList;
};
Msg.Elem.GroupTip.prototype.getMemberInfoList = function () {
    return this.memberInfoList;
};
Msg.Elem.GroupTip.prototype.getGroupMemberNum = function () {
    return this.groupMemberNum;
};
Msg.Elem.GroupTip.prototype.setGroupMemberNum = function (groupMemberNum) {
    return this.groupMemberNum = groupMemberNum;
};
Msg.Elem.GroupTip.prototype.toHtml = function () {
    var text = "[群提示消息]";
    var maxIndex = WEB_IM_GROUP_TIP_MAX_USER_COUNT - 1;
    switch (this.opType) {
        case WEB_IM_GROUP_TIP_TYPE.JOIN://加入群
            //代码省略
            break;
        case WEB_IM_GROUP_TIP_TYPE.QUIT://退出群
            //代码省略
            break;
        case WEB_IM_GROUP_TIP_TYPE.KICK://踢出群
            //代码省略
            break;
        case WEB_IM_GROUP_TIP_TYPE.SET_ADMIN://设置管理员
            //代码省略
            break;
        case WEB_IM_GROUP_TIP_TYPE.CANCEL_ADMIN://取消管理员
            //代码省略
            break;
        case WEB_IM_GROUP_TIP_TYPE.MODIFY_GROUP_INFO://群资料变更
            //代码省略
            break;
        case WEB_IM_GROUP_TIP_TYPE.MODIFY_MEMBER_INFO://群成员资料变更(禁言时间)
            //代码省略
            break;
        default:
            text += "未知群提示消息类型：type=" + this.opType;
            break;
    }
    return text;
};
```

## 用户被邀请加入群组 

**触发时机：**当有用户被邀请加入群组时，群组内会由系统发出通知，开发者可选择展示样式。可以更新群成员列表。 收到的消息 type 为 `WEB_IM_GROUP_TIP_TYPE.JOIN`。 

**`Msg.Elem.GroupTip` 成员方法：**

| 方法 | 说明 | 
|---------|---------|
| getOpType()| WEB_IM_GROUP_TIP_TYPE.JOIN  | 
| getOpUserId()| 邀请人 ID  | 
| getGroupName()| 群名  | 
| getUserIdList()| 被邀请入群的用户 ID 列表  | 
| getGroupMemberNum()| 获取当前群成员数  | 

**示例：**

```javascript
case WEB_IM_GROUP_TIP_TYPE.JOIN://加入群
        text += this.opUserId + "邀请了";
        for (var m in this.userIdList) {
            text += this.userIdList[m] + ",";
            if (this.userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                text += "等" + this.userIdList.length + "人";
                break;
            }
        }
        text += "加入该群";
        break;
```

## 用户主动退出群组 

**触发时机：**当有用户主动退群时，群组内会由系统发出通知。可以选择更新群成员列表。收到的消息 type 为 `WEB_IM_GROUP_TIP_TYPE.QUIT`。 

**`Msg.Elem.GroupTip` 成员方法：**

| 方法 | 说明 | 
|---------|---------|
| getOpType()| WEB_IM_GROUP_TIP_TYPE.QUIT  | 
| getOpUserId()| 退群用户 ID   | 
| getGroupName()| 群名  | 
| getGroupMemberNum()| 获取当前群成员数  | 

**示例：** 

```javascript
case WEB_IM_GROUP_TIP_TYPE.QUIT://退出群
    text += this.opUserId + "主动退出该群";
    break;
```

## 用户被踢出群组 

**触发时机：**当有用户被踢出群组时，群组内会由系统发出通知。可以更新群成员列表。收到的消息 type 为 `WEB_IM_GROUP_TIP_TYPE.KICK`。 

**`Msg.Elem.GroupTip` 成员方法：**

| 方法 | 说明 | 
|---------|---------|
| getOpType()| WEB_IM_GROUP_TIP_TYPE.KICK  | 
| getOpUserId()| 踢人 ID   | 
| getGroupName()| 群名  | 
| getUserIdList()| 被踢出群的用户 ID 列表  | 

**示例：** 

```javascript
case WEB_IM_GROUP_TIP_TYPE.KICK://踢出群
    text += this.opUserId + "将";
    for (var m in this.userIdList) {
        text += this.userIdList[m] + ",";
        if (this.userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
            text += "等" + this.userIdList.length + "人";
            break;
        }
    }
    text += "踢出该群";
    break;
```

## 用户被设置成管理员 

**触发时机：**当有用户被设置为管理员时，群组内会由系统发出通知。如果界面有显示是否管理员，此时可更新管理员标识。收到的消息 type 为 `WEB_IM_GROUP_TIP_TYPE.SET_ADMIN`。 

**`Msg.Elem.GroupTip` 成员方法：**

| 方法 | 说明 | 
|---------|---------|
| getOpType()| WEB_IM_GROUP_TIP_TYPE.SET_ADMIN  | 
| getOpUserId()| 设置者 ID   | 
| getGroupName()| 群名  | 
| getUserIdList()| 被设置成管理员的用户 ID 列表  | 

**示例：** 

```javascript
case WEB_IM_GROUP_TIP_TYPE.SET_ADMIN://设置管理员
    text += this.opUserId + "将";
    for (var m in this.userIdList) {
        text += this.userIdList[m] + ",";
        if (this.userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
            text += "等" + this.userIdList.length + "人";
            break;
        }
    }
    text += "设为管理员";
    break;
```

## 用户被取消管理员身份 

**触发时机：**当有用户被被取消管理员身份时，群组内会由系统发出通知。如果界面有显示是否管理员，此时可更新管理员标识。收到的消息 type 为 `WEB_IM_GROUP_TIP_TYPE.CANCEL_ADMIN`。 

**`Msg.Elem.GroupTip` 成员方法：**

| 方法 | 说明 | 
|---------|---------|
| getOpType()| WEB_IM_GROUP_TIP_TYPE.CANCEL_ADMIN  | 
| getOpUserId()| 取消者 ID   | 
| getGroupName()| 群名  | 
| getUserIdList()| 被取消管理员身份的用户 ID 列表  | 

**示例：** 

```javascript
case WEB_IM_GROUP_TIP_TYPE.CANCEL_ADMIN://取消管理员
    text += this.opUserId + "取消";
    for (var m in this.userIdList) {
        text += this.userIdList[m] + ",";
        if (this.userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
            text += "等" + this.userIdList.length + "人";
            break;
        }
    }
    text += "的管理员资格";
    break;
```

## 群组资料变更 

**触发时机：**当群资料变更，如群名、群简介等，会有系统消息发出，可更新相关展示字段。或者选择性把消息展示给用户。收到的消息 type 为 `WEB_IM_GROUP_TIP_TYPE.MODIFY_GROUP_INFO`。 

**`Msg.Elem.GroupTip` 成员方法：**

| 方法 | 说明 | 
|---------|---------|
| getOpType()| WEB_IM_GROUP_TIP_TYPE.MODIFY_GROUP_INFO  | 
| getOpUserId()| 修改群资料的用户 ID   | 
| getGroupName()| 群名  | 
| getUserIdList()| 群变更的具体资料信息，为 Msg.Elem.GroupTip.GroupInfo 对象列表   | 

**变更的群资料信息对象定义如下：**

```javascript
// class Msg.Elem.GroupTip.GroupInfo，变更的群资料信息对象
Msg.Elem.GroupTip.GroupInfo = function (type, value) {
    this.type = type;//群资料信息类型
    this.value = value;//对应的值
};
Msg.Elem.GroupTip.GroupInfo.prototype.getType = function () {
    return this.type;
};
Msg.Elem.GroupTip.GroupInfo.prototype.getValue = function () {
    return this.value;
};
```

**群提示消息-群资料变更类型定义如下：**

```javascript
//群提示消息-群资料变更类型
var WEB_IM_GROUP_TIP_MODIFY_GROUP_INFO_TYPE = {
    "FACE_URL": 1, //修改群头像 URL
    "NAME": 2, //修改群名称
    "OWNER": 3, //修改群主
    "NOTIFICATION": 4, //修改群公告
    "INTRODUCTION": 5//修改群简介
};
```

**示例：** 

```javascript
case WEB_IM_GROUP_TIP_TYPE.MODIFY_GROUP_INFO://群资料变更
    text += this.opUserId + "修改了群资料：";
    for (var m in this.groupInfoList) {
        var type = this.groupInfoList[m].getType();
        var value = this.groupInfoList[m].getValue();
        switch (type) {
            case WEB_IM_GROUP_TIP_MODIFY_GROUP_INFO_TYPE.FACE_URL:
                text += "群头像为" + value + "; ";
                break;
            case WEB_IM_GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NAME:
                text += "群名称为" + value + "; ";
                break;
            case WEB_IM_GROUP_TIP_MODIFY_GROUP_INFO_TYPE.OWNER:
                text += "群主为" + value + "; ";
                break;
            case WEB_IM_GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NOTIFICATION:
                text += "群公告为" + value + "; ";
                break;
            case WEB_IM_GROUP_TIP_MODIFY_GROUP_INFO_TYPE.INTRODUCTION:
                text += "群简介为" + value + "; ";
                break;
            default:
                text += "未知信息为:type=" + type + ",value=" + value + "; ";
                break;
        }
    }
    break;
```

## 群成员资料变更 

**触发时机：**当群成员的群相关资料变更时，会有系统消息发出，可更新相关字段展示，或者选择性把消息展示给用户。此处所说资料变更仅指与群相关的资料变更，例如禁言时间、成员角色变更等，不包括用户昵称等本身资料，目前仅支持禁言时间通知。收到的消息 type 为 `WEB_IM_GROUP_TIP_TYPE.MODIFY_MEMBER_INFO`。 

>!ChatRoom 和 AVChatRoom 设置群成员禁言时间，不会收到相应的群提示消息。

**`Msg.Elem.GroupTip` 成员方法：**

| 方法 | 说明 | 
|---------|---------|
| getOpType()| WEB_IM_GROUP_TIP_TYPE.MODIFY_MEMBER_INFO  | 
| getOpUserId()| 修改者 ID   | 
| getGroupName()| 群名  | 
| getUserIdList()| 变更的群成员的具体资料信息，为 Msg.Elem.GroupTip.MemberInfo 对象列表    | 

**变更的群成员资料信息对象定义如下：**

```javascript
// class Msg.Elem.GroupTip.MemberInfo，变更的群成员资料信息对象
Msg.Elem.GroupTip.MemberInfo = function (userId, shutupTime) {
    this.userId = userId;//群成员 ID
    this.shutupTime = shutupTime;//群成员被禁言时间，0 表示取消禁言，大于 0 表示被禁言时长，单位：秒
};
Msg.Elem.GroupTip.MemberInfo.prototype.getUserId = function () {
    return this.userId;
};
Msg.Elem.GroupTip.MemberInfo.prototype.getShutupTime = function () {
    return this.shutupTime;
};
```

**示例：**

```javascript
case WEB_IM_GROUP_TIP_TYPE.MODIFY_MEMBER_INFO://群成员资料变更(禁言时间)
    text += this.opUserId + "修改了群成员资料:";
    for (var m in this.memberInfoList) {
        var userId = this.memberInfoList[m].getUserId();
        var shutupTime = this.memberInfoList[m].getShutupTime();
        text += userId + ": ";
        if (shutupTime != null && shutupTime !== undefined) {
            if (shutupTime == 0) {
                text += "取消禁言; ";
            } else {
                text += "禁言" + shutupTime + "秒; ";
            }
        } else {
            text += " shutupTime为空";
        }
        if (this.memberInfoList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
            text += "等" + this.memberInfoList.length + "人";
            break;
        }
    }
    break;
```
