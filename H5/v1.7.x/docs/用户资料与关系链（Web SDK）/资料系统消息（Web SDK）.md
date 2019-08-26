目前是通过定义资料系统消息监听事件来处理通知。**示例：**

```javascript
//监听资料系统通知函数对象，方法都定义在 receive_profile_system_msg.js 文件中
var onProfileSystemNotifys = {
    "1": onProfileModifyNotify//资料修改  
};
```

## 资料变化

**触发时机：**当自己或好友的资料发生变化时，会收到此类通知。

**示例：** 

```javascript
//监听 资料变化（自己或好友） 系统通知
/*notify对数示例：
{
    "Type":1,//子通知类型
    "Profile_Account": "Jim",//用户帐号
    "ProfileList": [
        {
            "Tag": "Tag_Profile_IM_Nick",//昵称
            "ValueBytes": "吉姆"
        },
        {
            "Tag": "Tag_Profile_IM_Gender",//性别
            "ValueBytes": "Gender_Type_Male"
        },
        {
            "Tag": "Tag_Profile_IM_AllowType",//加好友认证方式
            "ValueBytes": "AllowType_Type_NeedConfirm"
        }
    ]
}
*/
function onProfileModifyNotify(notify) {
    webim.Log.info("执行 资料修改 回调："+JSON.stringify(notify));
    var typeCh = "[资料修改]";
    var profile,account,nick,sex,allowType,content;
    account=notify.Profile_Account;
    content = "帐号："+account+", ";
    for(var i in notify.ProfileList){
        profile=notify.ProfileList[i];
        switch(profile.Tag){
            case 'Tag_Profile_IM_Nick':
                nick=profile.ValueBytes;
                break;
            case 'Tag_Profile_IM_Gender':
                sex=profile.ValueBytes;
                break;
            case 'Tag_Profile_IM_AllowType':
                allowType=profile.ValueBytes;
                break;
            default:
                webim.log.error('未知资料字段：'+JSON.stringify(profile));
                break;
        }
    }
    content+="最新资料：【昵称】："+nick+",【性别】："+sex+",【加好友方式】："+allowType;
    addProfileSystemMsg(notify.Type, typeCh, content);
    if(account!=loginInfo.identifier){//如果是好友资料更新
        //好友资料发生变化，需要重新加载好友列表或者单独更新 account 的资料信息
        getAllFriend(getAllFriendsCallbackOK);
    }
}
```