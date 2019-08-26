
## IM SDK 登录 `login` 函数

**函数名：**
```javascript
webim.login
```

**定义：**

```javascript
webim.login(loginInfo, listeners, options,cbOk,cbErr)
```

**示例：**

```javascript
//IM SDK 登录
function sdkLogin() {
    //Web SDK 登录
    webim.login(loginInfo, listeners, options,
            function (identifierNick) {
                //identifierNick 为登录用户昵称(没有设置时，为帐号)，无登录态时为空
                webim.Log.info('webim登录成功');
                applyJoinBigGroup(avChatRoomId);//加入大群
                hideDiscussForm();//隐藏评论表单
                initEmotionUL();//初始化表情
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );//
}
```

## 用户信息对象 loginInfo

**属性名：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|sdkAppID	|用户标识接入 IM SDK 的应用 ID，必填|	String|
|appIDAt3rd	|App 用户使用 OAuth 授权体系分配的 Appid，必填	|String|
|identifier	|用户帐号，选填	|String|
|identifierNick|	用户昵称，选填	|String|
|userSig	|鉴权 Token，identifier 不为空时，必填	|String|

## 事件回调对象 listeners

**属性名：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|onConnNotify	|用于监听用户连接状态变化的函数，选填	|Function|
|jsonpCallback	|用于 IE9（含）以下浏览器中 jsonp 回调函数,移动端可不填，PC 端必填|	Function|
|onBigGroupMsgNotify	|监听新的群（普通和提示）消息函数，必填	|Function|
|onGroupSystemNotifys	|监听（多终端同步）群系统消息事件，必填|	Object|
|onGroupInfoChangeNotify|	监听群资料变化事件，选填	|Function|

**示例：**

```javascript
//监听事件
var listeners = {
    "onConnNotify": onConnNotify, //选填
    "jsonpCallback": jsonpCallback, //IE9(含)以下浏览器用到的 jsonp 回调函数,移动端可不填，PC 端必填
    "onBigGroupMsgNotify": onBigGroupMsgNotify, //监听新消息(大群)事件，必填
    "onMsgNotify": onMsgNotify, //监听新消息(私聊(包括普通消息和全员推送消息)，普通群(非直播聊天室)消息)事件，必填
    "onGroupSystemNotifys": onGroupSystemNotifys, //监听（多终端同步）群系统消息事件，必填
    "onGroupInfoChangeNotify": onGroupInfoChangeNotify//监听群资料变化事件，选填
};
```

## 事件回调对象 listeners.onConnNotify

**示例：**

```javascript
//监听连接状态回调变化事件
var onConnNotify = function (resp) {
    switch (resp.ErrorCode) {
        case webim.CONNECTION_STATUS.ON:
            //webim.Log.warn('连接状态正常...');
            break;
        case webim.CONNECTION_STATUS.OFF:
            webim.Log.warn('连接已断开，无法收到新消息，请检查下您的网络是否正常');
            break;
        default:
            webim.Log.error('未知连接状态,status=' + resp.ErrorCode);
            break;
    }
};
```

**其中回调返回的参数 `resp` 对象属性定义如下：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|ActionStatus	|连接状态标识，OK-标识连接成功 FAIL-标识连接失败|	String|
|ErrorCode	|连接状态码，具体请参考 webim. CONNECTION_STATUS 常量对象|Integer|
|ErrorInfo	|错误提示信息	|String|

## 事件回调对象 listeners.jsonpCallback

为了兼容低版本的 IE 浏览器，IM SDK 使用了 jsonp 技术调用后台接口。**示例：**

```javascript
//位于 js/demo_base.js 中
//IE9(含)以下浏览器用到的 jsonp 回调函数
function jsonpCallback(rspData) {
//设置 jsonp 返回的
    webim.setJsonpLastRspData(rspData);
}
```

**属性名：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|rspData	|接口返回的数据	|String|

## 事件回调对象 listeners.onBigGroupMsgNotify

用来监听直播聊天室消息。其中参数 `msgList` 为 `webim.Msg` 数组，即 `[webim.Msg]`。**示例：**

```javascript
//监听大群新消息（普通，点赞，提示，红包）
function onBigGroupMsgNotify(msgList) {
    for (var i = msgList.length - 1; i >= 0; i--) {//遍历消息，按照时间从后往前
        var msg = msgList[i];
        webim.Log.warn('receive a new group msg: ' + msg.getFromAccountNick());
        //显示收到的消息
        showMsg(msg);
    }
}
```

## 事件回调对象 listeners.onMsgNotify

用来监听新消息（私聊（包括普通消息和全员推送消息），普通群（非直播聊天室）消息）。其中参数 `newMsgList` 为 `webim.Msg` 数组，即 `[webim.Msg]`。**示例：**

```javascript
//监听新消息(私聊(包括普通消息、全员推送消息)，普通群(非直播聊天室)消息)事件
//newMsgList 为新消息数组，结构为 [Msg]
function onMsgNotify(newMsgList) {
    var newMsg;
    for (var j in newMsgList) {//遍历新消息
        newMsg = newMsgList[j];
        handlderMsg(newMsg);//处理新消息
    }
}
```

**其中 `handlderMsg` 示例代码如下：**

```javascript
//处理消息（私聊(包括普通消息和全员推送消息)，普通群(非直播聊天室)消息）
function handlderMsg(msg) {
    var fromAccount, fromAccountNick, sessType, subType,contentHtml;
    fromAccount = msg.getFromAccount();
    if (!fromAccount) {
        fromAccount = '';
    }
    fromAccountNick = msg.getFromAccountNick();
    if (!fromAccountNick) {
        fromAccountNick = fromAccount;
    }
    //解析消息
    //获取会话类型
    //webim.SESSION_TYPE.GROUP-群聊，
    //webim.SESSION_TYPE.C2C-私聊，
    sessType = msg.getSession().type();
    //获取消息子类型
    //会话类型为群聊时，子类型为：webim.GROUP_MSG_SUB_TYPE
    //会话类型为私聊时，子类型为：webim.C2C_MSG_SUB_TYPE
    subType = msg.getSubType();
    switch (sessType) {
        case webim.SESSION_TYPE.C2C://私聊消息
            switch (subType) {
                case webim.C2C_MSG_SUB_TYPE.COMMON://C2C 普通消息
                    //业务可以根据发送者帐号 fromAccount 是否为 App 管理员帐号，来判断 C2C 消息是否为全员推送消息，还是普通好友消息
                    //或者业务在发送全员推送消息时，发送自定义类型(webim.MSG_ELEMENT_TYPE.CUSTOM,即TIMCustomElem)的消息，在里面增加一个字段来标识消息是否为推送消息
                    contentHtml = convertMsgtoHtml(msg);
                    webim.Log.warn('receive a new c2c msg: fromAccountNick=' + fromAccountNick+", content="+contentHtml);
                    //C2C 消息一定要调用已读上报接口
                    var opts={
                        'To_Account':fromAccount,//好友帐号
                        'LastedMsgTime':msg.getTime()//消息时间戳
                    };
                    webim.c2CMsgReaded(opts);
                    alert('收到一条c2c消息(好友消息或者全员推送消息): 发送人=' + fromAccountNick+", 内容="+contentHtml);
                    break;
            }
            break;
        case webim.SESSION_TYPE.GROUP://普通群消息，对于直播聊天室场景，不需要作处理
            break;
    }
}
```

## 事件回调对象 listeners.onGroupSystemNotifys

**示例：**

```javascript
//监听（多终端同步）群系统消息方法，方法都定义在 demo_group_notice.js 文件中
//注意每个数字代表的含义，例如，
//1表示监听申请加群消息，2表示监听申请加群被同意消息，3表示监听申请加群被拒绝消息等
var onGroupSystemNotifys = {
    //"1": onApplyJoinGroupRequestNotify, //申请加群请求（只有管理员会收到,暂不支持）
    //"2": onApplyJoinGroupAcceptNotify, //申请加群被同意（只有申请人能够收到,暂不支持）
    //"3": onApplyJoinGroupRefuseNotify, //申请加群被拒绝（只有申请人能够收到,暂不支持）
    //"4": onKickedGroupNotify, //被管理员踢出群(只有被踢者接收到,暂不支持)
    "5": onDestoryGroupNotify, //群被解散(全员接收)
    //"6": onCreateGroupNotify, //创建群(创建者接收,暂不支持)
    //"7": onInvitedJoinGroupNotify, //邀请加群(被邀请者接收,暂不支持)
    //"8": onQuitGroupNotify, //主动退群(主动退出者接收,暂不支持)
    //"9": onSetedGroupAdminNotify, //设置管理员(被设置者接收,暂不支持)
    //"10": onCanceledGroupAdminNotify, //取消管理员(被取消者接收,暂不支持)
    "11": onRevokeGroupNotify, //群已被回收(全员接收)
    "255": onCustomGroupNotify//用户自定义通知(默认全员接收)
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

**其中返回的参数 groupInfo 对象属性如下：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|GroupId	|群 ID	|String|
|GroupFaceUrl |	新群组图标，为空，则表示没有变化|String|
|GroupName	|新群名称，为空，则表示没有变化	|String|
|OwnerAccount	|新的群主 ID，为空，则表示没有变化|	String|
|GroupNotification	|新的群公告，为空，则表示没有变化	|String|
|GroupIntroduction	|新的群简介，为空，则表示没有变化|	String|

## 其他对象 options

**属性名：**

| 名称 | 说明 | 类型 |
|---------|---------|---------|
|isAccessFormalEnv	|是否访问正式环境下的后台接口，True-访问正式，False-访问测试环境默认访问正式环境接口，选填	|Boolean|
|isLogOn	|是否开启控制台打印日志，True-开启；False-关闭，默认开启，选填|	Boolean|

## 回调函数 cbOk & cbErr

IM SDK 登录时，可以定义成功回调函数和失败回调函数。**示例：**

```javascript
//IM SDK 登录
function sdkLogin() {
    //Web SDK 登录
    webim.login(loginInfo, listeners, options,
            function (identifierNick) {
                //identifierNick 为登录用户昵称(没有设置时，为帐号)，无登录态时为空
                webim.Log.info('webim登录成功');
                applyJoinBigGroup(avChatRoomId);//加入大群
                hideDiscussForm();//隐藏评论表单
                initEmotionUL();//初始化表情
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );//
}
```
