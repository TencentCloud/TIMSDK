目前是通过定义好友系统消息监听事件来处理好友系统消息的。**示例：**

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

## 好友表添加

**触发时机：**当用户添加了新的好友时，会收到好友表添加通知。 

**示例：** 

```javascript
//监听 好友表添加 系统通知
/*notify对数示例：
 {
    'Type':1,//通知类型
    'Accounts':['jim','bob']//用户 ID 列表
 }
*/
function onFriendAddNotify(notify) {
    webim.Log.info("执行 好友表添加 回调："+JSON.stringify(notify));
    //好友表发生变化，需要重新加载好友列表或者单独添加 notify.Accounts 好友帐号
    getAllFriend(getAllFriendsCallbackOK);
    var typeCh = "[好友表添加]";
    var content = "新增以下好友："+notify.Accounts;
    addFriendSystemMsg(notify.Type, typeCh, content);
}
```

## 好友表删除

**触发时机：**当用户的好友发生减少时，会收到好友表删除通知。 

**示例：** 

```javascript
//监听 好友表删除 系统通知
/*notify对数示例：
 {
    'Type':2,//通知类型
    'Accounts':['jim','bob']//用户 ID 列表
 }
*/
function onFriendDeleteNotify(notify) {
    webim.Log.info("执行 好友表删除 回调："+JSON.stringify(notify));
    //好友表发生变化，需要重新加载好友列表或者单独删除notify.Accounts好友帐号
    getAllFriend(getAllFriendsCallbackOK);
    var typeCh = "[好友表删除]";
    var content = "减少以下好友："+notify.Accounts;
    addFriendSystemMsg(notify.Type, typeCh, content);
}
```

## 加好友未决添加

**触发时机：**当有人向您发出好友申请时，会收到加好友通知。 

**示例： **

```javascript
//监听 未决添加 系统通知
/*notify对象示例：
{
    "Type":3,//通知类型
    "PendencyList":[
        {
            "PendencyAdd_Account": "peaker1",//对方帐号
            "ProfileImNic": "匹克1",//对方昵称
            "AddSource": "AddSource_Type_Unknow",//来源
            "AddWording": "您好"//申请附言
        },
        {
            "PendencyAdd_Account": "peaker2",//对方帐号
            "ProfileImNic": "匹克2",//对方昵称
            "AddSource": "AddSource_Type_Unknow",//来源
            "AddWording": "您好"//申请附言
        }
    ]
}
*/
function onPendencyAddNotify(notify) {
    webim.Log.info("执行 未决添加 回调："+JSON.stringify(notify));
    //收到加好友申请，弹出拉取好友申请列表
    getPendency(true);
    var typeCh = "[未决添加]";
    var pendencyList=notify.PendencyList;
    var content = "收到以下加好友申请："+JSON.stringify(pendencyList);
    addFriendSystemMsg(notify.Type, typeCh, content);
}
```

## 加好友未决删除

**触发时机：**当用户被管理员踢出群组时，用户会收到被踢出群的消息。

**示例：** 

```javascript
//监听 未决删除 系统通知
/*notify对数示例：
 {
    'Type':4,//通知类型
    'Accounts':['jim','bob']//用户 ID 列表
 }
*/
function onPendencyDeleteNotify(notify) {
    webim.Log.info("执行 未决删除 回调："+JSON.stringify(notify));
    var typeCh = "[未决删除]";
    var content = "以下好友未决已被删除："+notify.Accounts;
    addFriendSystemMsg(notify.Type, typeCh, content);
}
```

## 好友黑名单添加

**触发时机：**当新增好友黑名单时，会收到此类通知。 

**示例： **

```javascript
//监听 好友黑名单添加 系统通知
/*notify对数示例：
 {
    'Type':5,//通知类型
    'Accounts':['jim','bob']//用户 ID 列表
 }
*/
function onBlackListAddNotify(notify) {
    webim.Log.info("执行 黑名单添加 回调："+JSON.stringify(notify));
    var typeCh = "[黑名单添加]";
    var content = "新增以下黑名单："+notify.Accounts;
    addFriendSystemMsg(notify.Type, typeCh, content);
}
```

## 好友黑名单删除

**触发时机：**当删除好友黑名单时，会收到此类通知。 

**示例： **

```javascript
//监听 好友黑名单删除 系统通知
/*notify对数示例：
 {
    'Type':6,//通知类型
    'Accounts':['jim','bob']//用户 ID 列表
 }
*/
function onBlackListDeleteNotify(notify) {
    webim.Log.info("执行 黑名单删除 回调："+JSON.stringify(notify));
    var typeCh = "[黑名单删除]";
    var content = "减少以下黑名单："+notify.Accounts;
    addFriendSystemMsg(notify.Type, typeCh, content);
}
```
