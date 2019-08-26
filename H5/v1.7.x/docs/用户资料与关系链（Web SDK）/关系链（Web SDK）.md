## 申请增加好友 

```javascript
/* function applyAddFriend 
 *   申请添加好友
 * params:
 *   options - Object 类型，参考下方请求参数说明
 *   cbOk	- function()类型, 成功时回调函数，参考下方响应参数说明
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象，参考下方错误码说明
 * return:
 *   (无)
 */
applyAddFriend: function(options, cbOk, cbErr) {},
```

### 请求参数说明

| 字段                     | 类型   | 属性 | 说明                                                         |
| ------------------------ | ------ | ---- | ------------------------------------------------------------ |
| AddFriendItem            | Array  | 必填 | 好友结构体对象                                               |
| AddFriendItem.To_Account | String | 必填 | 好友的 Identifier                                            |
| AddFriendItem.Remark     | String | 选填 | To_Account 的好友备注，详情可参见 [标配好友字段](https://cloud.tencent.com/document/product/269/1501#.E6.A0.87.E9.85.8D.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5) |
| AddFriendItem.GroupName  | String | 选填 | To_Account 的分组信息，详情可参见 [标配好友字段](https://cloud.tencent.com/document/product/269/1501#.E6.A0.87.E9.85.8D.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5) |
| AddFriendItem.AddSource  | String | 必填 | 加好友来源字段，详情可参见 [标配好友字段](https://cloud.tencent.com/document/product/269/1501#.E6.A0.87.E9.85.8D.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5) |
| AddFriendItem.AddWording | String | 选填 | To_Account 形成好友关系时的附言信息，详情可参见 [标配好友字段](https://cloud.tencent.com/document/product/269/1501#.E6.A0.87.E9.85.8D.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5) |
| AddType                 | String | 选填 | 加好友方式（默认双向加好友方式），“Add_Type_Single” 表示单向加好友 “Add_Type_Both” 表示双向加好友|
| ForceAddFlags            | Number | 选填 | 管理员强制加好友标记，1表示强制加好友，0表示常规加好友方式 |

### 响应参数说明

| 字段                  | 类型   | 说明                                                      |
| --------------------- | ------ | --------------------------------------------------------- |
| ResultItem            | Array  | 批量加好友的结果对象数组                                  |
| ResultItem.To_Account | String | 请求添加的好友的 Identifier                               |
| ResultItem.ResultCode | Number | 批量加好友中单个好友的处理结果，0表示成功，非0表示失败 |
| ResultItem.ResultInfo | String | To_Account 的错误描述信息，成功时该字段为空               |
| Fail_Account          | Array  | 返回处理失败的用户列表。成功时响应体无该字段              |
| Invalid_Account       | Array  | 返回请求包中的非法用户列表。成功时响应体无该字段          |
| ActionStatus          | String | 请求处理的结果，“OK” 表示处理成功，“FAIL” 表示失败        |
| ErrorCode             | Number | 错误码，0表示成功，非0表示失败                            |
| ErrorInfo             | String | 详细错误信息                                              |
| ErrorDisplay          | String | 详细的客户端展示信息                                      |

### 错误码说明

详情请参考 [错误码说明](https://cloud.tencent.com/document/product/269/1643#.E9.94.99.E8.AF.AF.E7.A0.81.E8.AF.B4.E6.98.8E)。

### 示例代码

```javascript
//申请加好友
var applyAddFriend = function () {
    var len = webim.Tool.getStrBytes($("#af_add_wording").val());
    if (len > 120) {
        alert('您输入的附言超过字数限制(最长40个汉字)');
        return;
    }
    var add_friend_item = [
        {
            'To_Account': $("#af_to_account").val(),
            "AddSource": "AddSource_Type_Unknow",
            "AddWording": $("#af_add_wording").val() //加好友附言，可为空
        }
    ];
    var options = {
        'AddFriendItem': add_friend_item
    };
    webim.applyAddFriend(
            options,
            function (resp) {
                if (resp.Fail_Account && resp.Fail_Account.length > 0) {
                    for (var i in resp.ResultItem) {
                        alert(resp.ResultItem[i].ResultInfo);
                        break;
                    }
                } else {
                    if ($('#af_allow_type').val() == '允许任何人') {
                        //重新加载好友列表
                        getAllFriend(getAllFriendsCallbackOK);
                        alert('添加好友成功');
                    } else {
                        $('#add_friend_dialog').modal('hide');
                        alert('申请添加好友成功');
                    }
                }
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 拉取好友申请 


```javascript
/* function getPendency 
 *   拉取好友申请
 * params:
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
getPendency: function(options, cbOk, cbErr) {},
```

### 示例代码

```javascript
//读取好友申请列表
var getPendency = function () {
    initGetPendencyTable([]);
    var options = {
        'PendencyType': 'Pendency_Type_ComeIn',
        'StartTime': 0,
        'MaxLimited': totalCount,
        'LastSequence': 0
    };
    webim.getPendency(
            options,
            function (resp) {
                var data = [];
                if (resp.UnreadPendencyCount > 0) {
                    for (var i in resp.PendencyItem) {
                        var apply_time = webim.Tool.formatTimeStamp(
                        resp.PendencyItem[i].AddTime);
                        var nick = webim.Tool.formatText2Html(resp.PendencyItem[i].Nick);
                        if (nick == '') {
                            nick = resp.PendencyItem[i].To_Account;
                        }
                        var addWording = webim.Tool.formatText2Html(
                        resp.PendencyItem[i].AddWording);
                        data.push({
                            To_Account: resp.PendencyItem[i].To_Account,
                            Nick: nick,
                            AddWording: addWording,
                            AddSource: resp.PendencyItem[i].AddSource,
                            AddTime: apply_time
                        });
                    }
                }
                $('#get_pendency_table').bootstrapTable('load', data);
                $('#get_pendency_dialog').modal('show');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 响应好友申请 

```javascript
/* function responseFriend 
 *   响应好友申请
 * params:
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
responseFriend: function(options, cbOk, cbErr) {},
```

### 示例代码

```javascript
//处理好友申请
var responseFriend = function () {
    var response_friend_item = [
        {
            'To_Account': $("#rf_to_account").val(),
            "ResponseAction": $('input[name="rf_action_radio"]:checked').val()
            //类型：Response_Action_Agree 或者 Response_Action_AgreeAndAdd
        }
    ];
    var options = {
        'ResponseFriendItem': response_friend_item
    };
    webim.responseFriend(
            options,
            function (resp) {
                //在表格中删除对应的行
                $('#get_pendency_table').bootstrapTable('remove', {
                    field: 'To_Account',
                    values: [$("#rf_to_account").val()]
                });
                $('#response_friend_dialog').modal('hide');
                if (response_friend_item[0].ResponseAction 
                    == 'Response_Action_AgreeAndAdd') {
                    getAllFriend(getAllFriendsCallbackOK);
                }
                alert('处理好友申请成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 删除好友申请 

```javascript
/* function deletePendency 
 *   删除好友申请
 * params:
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
deletePendency: function(options, cbOk, cbErr) {},
```

### 示例代码

```javascript
//删除申请列表
var deletePendency = function (del_account) {
    var options = {
        'PendencyType': 'Pendency_Type_ComeIn',
        'To_Account': [del_account]
    };
    webim.deletePendency(
            options,
            function (resp) {
                //在表格中删除对应的行
                $('#get_pendency_table').bootstrapTable('remove', {
                    field: 'To_Account',
                    values: [del_account]
                });
                alert('删除好友申请成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 我的好友列表 

```javascript
/* function getAllFriend
 *   拉取我的好友
 * params:
 *	 options - Object类型，参考下方请求参数说明
 *   cbOk	- function()类型, 成功时回调函数，参考下方响应参数说明
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象，参考下方错误码说明
 * return:
 *   (无)
 */
getAllFriend: function(options, cbOk, cbErr) {},
```

### 请求参数说明

| 字段                 | 类型   | 属性 | 说明                                                         |
| -------------------- | ------ | ---- | ------------------------------------------------------------ |
| TimeStamp            | Number | 选填 | 上次拉取的时间戳，不填或为0时表示全量拉取                  |
| StartIndex           | Number | 必填 | 拉取的起始位置                                               |
| TagList              | Array  | 选填 | 指定要拉取的字段 Tag，支持拉取的字段有：<li>1. 标配资料字段，详情可参见 [标配资料字段](https://cloud.tencent.com/document/product/269/1500#.E6.A0.87.E9.85.8D.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5)<li>2. 自定义资料字段，详情可参见 [自定义资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.87.AA.E5.AE.9A.E4.B9.89.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5)<li>3. 标配好友字段，详情可参见 [标配好友字段](https://cloud.tencent.com/document/product/269/1501#.E6.A0.87.E9.85.8D.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5)<li>4. 自定义好友字段，详情可参见 [自定义好友字段](https://cloud.tencent.com/document/product/269/1501#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5) |
| LastStandardSequence | Number | 选填 | 上次拉取标配关系链的 Sequence，仅在只拉取标配关系链字段时有用 |
| GetCount             | Number | 选填 | 每页需要拉取的好友数量：<li>1. 默认每页返回100个好友<li>2. 每页最多返回100个好友的数据<li>3. 如果拉取好友超时，请适量减少每页拉取的好友数 |

### 响应参数说明

| 字段                          | 类型                | 说明                                                         |
| ----------------------------- | ------------------- | ------------------------------------------------------------ |
| NeedUpdateAll                 | String              | 是否需要全量更新： "GetAll_Type_YES" 表示需要全量更新， "GetAll_Type_NO"表示不需要全量更新 |
| TimeStampNow                  | Number              | 本次拉取的时间戳，客户端需要保存该时间，下次请求时通过 TimeStamp 字段返回给后台 |
| StartIndex                    | Number              | 下页拉取的起始位置                                           |
| InfoItem                      | Array               | 好友对象数组，每一个好友对象都包括了 Info_Account 和 SnsProfileItem，若无该字段返回则表示没有好友 |
| InfoItem.Info_Account         | String              | 好友的 Identifier                                            |
| InfoItem.SnsProfileItem       | Array               | 好友的详细信息数组，数组每一个元素都包括 Tag 和 Value        |
| InfoItem.SnsProfileItem.Tag   | String              | 好友的资料字段或好友字段的名称                               |
| InfoItem.SnsProfileItem.Value | String/Number/Array | 好友的资料字段或好友字段的值，详情可参见 [关系链字段](https://cloud.tencent.com/document/product/269/1501#.E5.85.B3.E7.B3.BB.E9.93.BE.E5.AD.97.E6.AE.B5) 及 [资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5) |
| CurrentStandardSequence       | Number              | 本次拉取标配关系链的 Sequence，客户端需要保存该 Sequence，下次请求时通过 LastStandardSequence 字段返回给后台 |
| FriendNum                     | Number              | 好友总数                                                     |
| ActionStatus                  | String              | 请求处理的结果，“OK” 表示处理成功，“FAIL” 表示失败           |
| ErrorCode                     | Number              | 错误码，0表示成功，非0表示失败                               |
| ErrorInfo                     | String              | 详细错误信息                                                 |
| ErrorDisplay                  | String              | 详细的客户端展示信息                                         |

### 错误码说明

详情请参考 [错误码说明](https://cloud.tencent.com/document/product/269/1647#.E9.94.99.E8.AF.AF.E7.A0.81.E8.AF.B4.E6.98.8E)。

### 示例代码

```javascript
//初始化聊天界面左侧好友列表框
var getAllFriend = function (cbOK, cbErr) {
    var options = {
        'TimeStamp': 0,
        'StartIndex': 0,
        'GetCount': totalCount,
        'LastStandardSequence': 0,
        "TagList":
                [
                    "Tag_Profile_IM_Nick",
                    "Tag_SNS_IM_Remark"
                ]
    };
    webim.getAllFriend(
            options,
            function (resp) {
                //清空聊天对象列表
                var sessList = document.getElementsByClassName("sesslist")[0];
                sessList.innerHTML = "";
                if (resp.FriendNum > 0) {
                    var friends = resp.InfoItem;
                    if (!friends || friends.length == 0) {
                        return;
                    }
                    var count = friends.length;
                    for (var i = 0; i < count; i++) {
                        var friend_name = friends[i].Info_Account;
                        if (friends[i].SnsProfileItem && friends[i].SnsProfileItem[0] 
                            && friends[i].SnsProfileItem[0].Tag) {
                            friend_name = friends[i].SnsProfileItem[0].Value;
                        }
                        if (friend_name.length > 7) {//帐号或昵称过长，截取一部分
                            friend_name = friend_name.substr(0, 7) + "...";
                        }
                        //增加一个好友div
                        addSess(friends[i].Info_Account, webim.Tool.formatText2Html(
                        friend_name), 
                        friendHeadUrl, 0, 'sesslist');
                    }
                    if (selType == SessionType.C2C) {
                        //清空聊天界面
                        document.getElementsByClassName("msgflow")[0].innerHTML = "";
                        //默认选中当前聊天对象，selToID 为全局变量，表示当前正在进行的聊天 ID，当聊天类型为私聊时，该值为好友帐号，否则为群号。
                        selToID = friends[0].Info_Account;
                        //设置当前选中用户的样式为选中样式 
                        var selSessDiv = $("#sessDiv_" + selToID)[0];
                        selSessDiv.className = "sessinfo-sel";
                        var selBadgeDiv = $("#badgeDiv_" + selToID)[0];
                        selBadgeDiv.style.display = "none";
                    }
                    if (cbOK)
                        cbOK();
                }
            },
            function (err) {
                //alert(err.ErrorInfo);
            }
    );
};
```

## 删除好友 

```javascript
/* function deleteFriend
 *   删除好友
 * params:
 *	 options - Object类型，参考下方请求参数说明
 *   cbOk	- function()类型, 成功时回调函数，参考下方响应参数说明
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象，参考下方错误码说明
 * return:
 *   (无)
 */
deleteFriend: function(options, cbOk, cbErr) {},
```

### 请求参数说明

| 字段       | 类型   | 属性 | 说明                                                         |
| ---------- | ------ | ---- | ------------------------------------------------------------ |
| To_Account | Array  | 必填 | 待删除的好友的 Identifier 列表，单次请求的 To_Account 数不得超过 1000 |
| DeleteType | String | 选填 | 删除模式，详情请参考 [删除好友](https://cloud.tencent.com/document/product/269/1501#.E5.88.A0.E9.99.A4.E5.A5.BD.E5.8F.8B) |

### 响应参数说明

| 字段                  | 类型   | 说明                                                     |
| --------------------- | ------ | -------------------------------------------------------- |
| ResultItem            | Array  | 批量删除好友的结果对象数组                               |
| ResultItem.To_Account | String | 请求删除的好友的 Identifier                              |
| ResultItem.ResultCode | Number | To_Account 的处理结果，0表示删除成功，非0表示删除失败 |
| ResultItem.ResultInfo | String | To_Account 的错误描述信息，成功时该字段为空              |
| Fail_Account          | Array  | 返回处理失败的 To_Account列表，成功时响应体无该字段      |
| Invalid_Account       | Array  | 返回请求包中的非法 To_Account 列表，成功时响应体无该字段 |
| ActionStatus          | String | 请求包的处理结果，“OK”表示处理成功，“FAIL”表示失败       |
| ErrorCode             | Number | 错误码，0表示成功，非0表示失败                           |
| ErrorInfo             | String | 详细错误信息                                             |
| ErrorDisplay          | String | 详细的客户端展示信息                                     |

### 错误码说明

详情请参考 [错误码说明](https://cloud.tencent.com/document/product/269/1644#.E9.94.99.E8.AF.AF.E7.A0.81.E8.AF.B4.E6.98.8E)。

### 示例代码

```javascript
//删除好友
var deleteFriend = function () {
    if (!confirm("确定删除该好友吗？")) {
        return;
    }
    var to_account = [];
    to_account = [
        $("#df_to_account").val()
    ];
    if (to_account.length <= 0) {
        return;
    }
    var options = {
        'To_Account': to_account,
         //单向删除："Delete_Type_Single", 双向删除："Delete_Type_Both".
        'DeleteType': $('input[name="df_type_radio"]:checked').val()
    };
    webim.deleteFriend(
            options,
            function (resp) {
                //在表格中删除对应的行
                $('#get_my_friend_table').bootstrapTable('remove', {
                    field: 'Info_Account',
                    values: [$("#df_to_account").val()]
                });
                //重新加载好友列表
                getAllFriend(getAllFriendsCallbackOK);
                $('#delete_friend_dialog').modal('hide');
                alert('删除好友成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 增加黑名单 
>!
>- 如果用户 A 与用户 B 之间存在好友关系，拉黑时会解除双向好友关系。
>- 如果用户 A 与用户 B 之间存在黑名单关系，二者之间无法发起会话。
>- 如果用户 A 与用户 B 之间存在黑名单关系，二者之间无法发起加好友请求。


```javascript
/* function addBlackList 
 *   增加黑名单
 * params:
 *	 options - Object类型，参考下方请求参数说明
 *   cbOk	- function()类型, 成功时回调函数，参考下方响应参数说明
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象，参考下方错误码说明
 * return:
 *   (无)
 */
addBlackList: function(options, cbOk, cbErr) {},
```

### 请求参数说明

| 字段       | 类型  | 属性 | 说明                                                         |
| ---------- | ----- | ---- | ------------------------------------------------------------ |
| To_Account | Array | 必填 | 待添加为黑名单的用户 Identifier 列表，单次请求的 To_Account 数不得超过 1000 |

### 响应参数说明

| 字段                  | 类型   | 说明                                                     |
| --------------------- | ------ | -------------------------------------------------------- |
| ResultItem            | Array  | 批量添加黑名单的结果对象数组                             |
| ResultItem.To_Account | String | 请求添加为黑名单的用户 Identifier                        |
| ResultItem.ResultCode | Number | To_Account 的处理结果，0表示删除成功，非0表示删除失败 |
| ResultItem.ResultInfo | String | To_Account 的错误描述信息，成功时该字段为空              |
| Fail_Account          | Array  | 返回处理失败的 To_Account 列表                           |
| Invalid_Account       | Array  | 返回请求包中的非法 To_Account 列表                       |
| ActionStatus          | String | 请求包的处理结果，“OK” 表示处理成功，“FAIL” 表示失败     |
| ErrorCode             | Number | 错误码，0表示成功，非0表示失败                           |
| ErrorInfo             | String | 详细错误信息                                             |
| ErrorDisplay          | String | 详细的客户端展示信息                                     |

### 错误码说明

详情请参考 [错误码说明](https://cloud.tencent.com/document/product/269/3718#.E9.94.99.E8.AF.AF.E7.A0.81.E8.AF.B4.E6.98.8E)。

### 示例代码

```javascript
//添加黑名单
var addBlackList = function (add_account) {
    var to_account = [];
    if (add_account) {
        to_account = [add_account];
    }
    if (0 == to_account.length) {
        alert('需要拉黑的帐号为空');
        return;
    }
    var options = {
        'To_Account': to_account
    };
    webim.addBlackList(
            options,
            function (resp) {
                //在表格中删除对应的行
                $('#get_my_friend_table').bootstrapTable('remove', {
                    field: 'Info_Account',
                    values: [add_account]
                });
                //重新加载好友列表
                getAllFriend(getAllFriendsCallbackOK);
                alert('添加黑名单成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 我的黑名单

```javascript
/* function getBlackList  
 *   删除黑名单
 * params:
 *	 options - Object类型，参考下方请求参数说明
 *   cbOk	- function()类型, 成功时回调函数，参考下方响应参数说明
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象，参考下方错误码说明
 * return:
 *   (无)
 */
getBlackList: function(options, cbOk, cbErr) {},
```

### 请求参数说明

| 字段         | 类型   | 属性 | 说明                                                   |
| ------------ | ------ | ---- | ------------------------------------------------------ |
| StartIndex   | Number | 必填 | 拉取的起始位置                                         |
| MaxLimited   | Number | 必填 | 每页最多拉取的黑名单数                                 |
| LastSequence | Number | 必填 | 上一次拉黑名单时后台返回给客户端的 Seq，初次拉取时为 0 |

### 响应参数说明

| 字段                            | 类型   | 说明                                                         |
| ------------------------------- | ------ | ------------------------------------------------------------ |
| BlackListItem                   | Array  | 黑名单对象数组，每一个黑名单对象都包括了 To_Account 和 AddBlackTimeStamp。若无该字段返回则表示没有用户在黑名单中 |
| BlackListItem.To_Account        | String | 黑名单的 Identifier                                          |
| BlackListItem.AddBlackTimeStamp | Number | 添加黑名单的时间                                             |
| StartIndex                      | Number | 下页拉取的起始位置，0表示已拉完                             |
| CurruentSequence                | Number | 黑名单最新的 Seq                                             |
| ActionStatus                    | String | 请求处理的结果，“OK” 表示处理成功，“FAIL” 表示失败           |
| ErrorCode                       | Number | 错误码，0表示成功，非0表示失败                               |
| ErrorInfo                       | String | 详细错误信息                                                 |
| ErrorDisplay                    | String | 详细的客户端展示信息                                         |

### 错误码说明

详情请参考 [错误码说明](https://cloud.tencent.com/document/product/269/3722#.E9.94.99.E8.AF.AF.E7.A0.81.E8.AF.B4.E6.98.8E)。

### 示例代码

```javascript
//我的黑名单
var getBlackList = function (cbOK, cbErr) {
    initGetBlackListTable([]);
    var options = {
        'StartIndex': 0,
        'MaxLimited': totalCount,
        'LastSequence': 0
    };
    webim.getBlackList(
            options,
            function (resp) {
                var data = [];
                if (resp.BlackListItem && resp.BlackListItem.length > 0) {
                    for (var i in resp.BlackListItem) {
                        var add_time = webim.Tool.formatTimeStamp(
                        resp.BlackListItem[i].AddBlackTimeStamp);
                        data.push({
                            To_Account: resp.BlackListItem[i].To_Account,
                            AddBlackTimeStamp: add_time
                        });
                    }
                }
                $('#get_black_list_table').bootstrapTable('load', data);
                $('#get_black_list_dialog').modal('show');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 删除黑名单 

```javascript
/* function deleteBlackList  
 *   我的黑名单
 * params:
 *	 options - Object类型，参考下方请求参数说明
 *   cbOk	- function()类型, 成功时回调函数，参考下方响应参数说明
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象，参考下方错误码说明
 * return:
 *   (无)
 */
deleteBlackList: function(options, cbOk, cbErr) {},
```

### 请求参数说明

| 字段       | 类型  | 属性 | 说明                                                         |
| ---------- | ----- | ---- | ------------------------------------------------------------ |
| To_Account | Array | 必填 | 待删除的黑名单的 Identifier 列表，单次请求的 To_Account 数不得超过1000 |

### 响应参数说明

| 字段                  | 类型   | 说明                                                     |
| --------------------- | ------ | -------------------------------------------------------- |
| ResultItem            | Array  | 批量删除黑名单的结果对象数组                             |
| ResultItem.To_Account | String | 请求删除的黑名单的 Identifier                            |
| ResultItem.ResultCode | Number | To_Account 的处理结果，0表示删除成功，非0表示删除失败 |
| ResultItem.ResultInfo | String | To_Account 的错误描述信息，成功时该字段为空              |
| Fail_Account          | Array  | 返回处理失败的 To_Account 列表                           |
| Invalid_Account       | Array  | 返回请求包中的非法 To_Account 列表                       |
| ActionStatus          | String | 请求包的处理结果，“OK” 表示处理成功，“FAIL” 表示失败     |
| ErrorCode             | Number | 错误码，0表示成功，非0表示失败                           |
| ErrorInfo             | String | 详细错误信息                                             |
| ErrorDisplay          | String | 详细的客户端展示信息                                     |

### 错误码说明

详情请参考 [错误码说明](https://cloud.tencent.com/document/product/269/3719#.E9.94.99.E8.AF.AF.E7.A0.81.E8.AF.B4.E6.98.8E)。

### 示例代码

```javascript
//删除黑名单
var deleteBlackList = function (del_account) {
    var to_account = [
        del_account
    ];
    var options = {
        'To_Account': to_account
    };
    webim.deleteBlackList(
            options,
            function (resp) {
                //在表格中删除对应的行
                $('#get_black_list_table').bootstrapTable('remove', {
                    field: 'To_Account',
                    values: to_account
                });
                alert('删除黑名单成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```
