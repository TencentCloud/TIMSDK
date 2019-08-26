## 创建群 

```javascript
/* function createGroup
 *   创建群
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
createGroup: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考 [创建群组 API](https://cloud.tencent.com/document/product/269/1615)。

**示例：**


```javascript
//创建群组
var createGroup = function () {
    var sel_friends = $('#select_friends').val();
    var member_list = [];
    var members = sel_friends.split(";"); //字符分割
    for (var i = 0; i < members.length; i++)
    {
        if (members[i] && members[i].length > 0) {
            member_list.push(members[i]);
        }
    }
    if ($("#cg_name").val().length == 0) {
        alert('请输入群组名称');
        return;
    }
    if (webim.Tool.trimStr($("#cg_name").val()).length == 0) {
        alert('您输入的群组名称全是空格,请重新输入');
        return;
    }
    if (webim.Tool.getStrBytes($("#cg_name").val()) > 30) {
        alert('您输入的群组名称超出限制(最长10个汉字)');
        return;
    }
    if (webim.Tool.getStrBytes($("#cg_notification").val()) > 150) {
        alert('您输入的群组公告超出限制(最长50个汉字)');
        return;
    }
    if (webim.Tool.getStrBytes($("#cg_introduction").val()) > 120) {
        alert('您输入的群组简介超出限制(最长40个汉字)');
        return;
    }
    var groupType=$('input[name="cg_type_radio"]:checked').val();
    var options = {
        'GroupId': $("#cg_id").val(),
        'Owner_Account': loginInfo.identifier,
        'Type': groupType, //Private/Public/ChatRoom/AVChatRoom
        'Name': $("#cg_name").val(),
        'FaceUrl': '',
        'Notification': $("#cg_notification").val(),
        'Introduction': $('#cg_introduction').val(),
        'MemberList': member_list
    };
    if(groupType!='Private'){//非讨论组才支持ApplyJoinOption属性
        options.ApplyJoinOption=$('input[name="cg_ajp_type_radio"]:checked').val();
    }
    webim.createGroup(
            options,
            function (resp) {
                $('#create_group_dialog').modal('hide');
                alert('创建群成功');
                //读取我的群组列表
                getJoinedGroupListHigh(getGroupsCallbackOK);
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 申请加群

```javascript
/* function applyJoinGroup
 *   申请加群
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
applyJoinGroup: function(options, cbOk, cbErr) {},
```


**示例：**

```javascript
//申请加群
var applyJoinGroup = function () {
    if (webim.Tool.getStrBytes($("#ajg_apply_msg").val()) > 300) {
        alert('您输入的附言超出限制(最长100个汉字)');
        return;
    }
    var options = {
        'GroupId': $("#ajg_group_id").val(),
        'ApplyMsg': $("#ajg_apply_msg").val(),
        'UserDefinedField': ''
    };
    webim.applyJoinGroup(
            options,
            function (resp) {
                $('#apply_join_group_dialog').modal('hide');

                if ($("#ajg_group_type").val() == 'ChatRoom') {
                    //刷新我的群组列表
                    getJoinedGroupListHigh(getGroupsCallbackOK);
                    alert('成功加入该聊天室');
                } else {
                    alert('申请成功，请等待群主处理');
                }
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 处理申请加群（同意或拒绝）

```javascript
/* function handleApplyJoinGroup
*   处理申请加群(同意或拒绝)
* params:
*   options	- 请求参数
*   cbOk	- function()类型, 成功时回调函数
*   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
* return:
*   (无)
*/
handleApplyJoinGroup: function(options, cbOk, cbErr) {},
```

**其中 options 定义如下：**

```javascript
{
    'GroupId': //群 ID
    'Applicant_Account': //申请人 ID
    'HandleMsg': //是否同意，Agree 表示同意 Reject 表示拒绝
    'Authentication': //申请凭证（包含在管理员收到的加群申请系统消息中）
    'MsgKey': //消息 key（包含在管理员收到的加群申请系统消息中）
    'ApprovalMsg': //处理附言
    'UserDefinedField': //用户自定义字段（包含在管理员收到的加群申请系统消息中）
}
```

**示例：**

```javascript
//处理加群申请
var handleApplyJoinGroupPendency = function () {
    var options = {
        'GroupId': $("#hajg_group_id").val(), //群 ID
        'Applicant_Account': $("#hajg_to_account").val(), //申请人 ID
        'HandleMsg': $('input[name="hajg_action_radio"]:checked').val(), //Agree 表示同意 Reject 表示拒绝
        'Authentication': $("#hajg_authentication").val(), //申请凭证
        'MsgKey': $("#hajg_msg_key").val(),
        'ApprovalMsg': $("#hajg_approval_msg").val(), //处理附言
        'UserDefinedField': $("#hajg_group_id").val()//用户自定义字段
    };
    //要删除的群未决消息
    var delApplyJoinGroupPendencys = {
        'DelMsgList': [
            {
                "From_Account": $("#hajg_from_account").val(),
                "MsgSeq": parseInt($("#hajg_msg_seq").val()),
                "MsgRandom": parseInt($("#hajg_msg_random").val())
            }
        ]
    };
    webim.handleApplyJoinGroupPendency(
            options,
            function (resp) {
                //在表格中删除对应的行
                $('#get_apply_join_group_pendency_table').bootstrapTable('remove', {
                    field: 'Authentication',
                    values: [$("#hajg_authentication").val()]
                });
                $('#handle_ajg_dialog').modal('hide');
                //删除已处理的加群未决消息，否则下次登录的时候会重复收到加群未决消息
                deleteApplyJoinGroupPendency(delApplyJoinGroupPendencys);
                alert('处理加群申请成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 删除加群申请

在处理完加群申请之后，需要删除对应的加群申请 。**函数名：**

```javascript
/* function deleteApplyJoinGroupPendency
 *   删除加群申请
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
deleteApplyJoinGroupPendency: function(options, cbOk, cbErr) {},
```

**其中 options 定义如下：**

```javascript
//要删除的群未决消息(支持批量删除)
var options = {
//需要删除的消息列表
   'DelMsgList': [
       {
           "From_Account":“@TIM#SYSTEM”,//消息发送者
           "MsgSeq": 345,//消息序列号
           "MsgRandom": 1234//消息随机数
       }
   ]
};
```

**示例：**

```javascript
//删除已处理的加群未决消息
var deleteApplyJoinGroupPendency = function (opts) {
   webim.deleteApplyJoinGroupPendency(opts,
           function (resp) {
               console.info('delete group pendency msg success');
           },
           function (err) {
               alert(err.ErrorInfo);
               console.error('delete group pendency msg failed');
           }
   );
   return;
};
```

## 主动退群

```javascript
/* function quitGroup
 *  主动退群
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
quitGroup: function(options, cbOk, cbErr) {},
```

**示例：**

```javascript
//退群
var quitGroup = function (group_id) {
    var options = null;
    if (group_id) {
        options = {
            'GroupId': group_id
        };
    }
    if (options == null) {
        alert('退群时，群组ID非法');
        return;
    }
    webim.quitGroup(
            options,
            function (resp) {
                //在表格中删除对应的行
                $('#get_my_group_table').bootstrapTable('remove', {
                    field: 'GroupId',
                    values: [group_id]
                });
                //刷新我的群组列表
                getJoinedGroupListHigh(getGroupsCallbackOK);
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 解散群

```javascript
/* function destroyGroup
 *  解散群
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
destroyGroup: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考 [解散群组 API](https://cloud.tencent.com/document/product/269/1624)。

**示例：**

```javascript
//解散群组
var destroyGroup = function (group_id) {
    var options = null;
    if (group_id) {
        options = {
            'GroupId': group_id
        };
    }
    if (options == null) {
        alert('解散群时，群组ID非法');
        return;
    }
    webim.destroyGroup(
            options,
            function (resp) {
                //在表格中删除对应的行
                $('#get_my_group_table').bootstrapTable('remove', {
                    field: 'GroupId',
                    values: [group_id]
                });
                //读取我的群组列表
                getJoinedGroupListHigh(getGroupsCallbackOK);
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 我的群组列表

```javascript
/* function getJoinedGroupListHigh
 *   获取我的群组-高级接口
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err为错误对象
 * return:
 *   (无)
 */
getJoinedGroupListHigh: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考 [获取用户所加入的群组 API](https://cloud.tencent.com/document/product/269/1625)。

**示例：**

```javascript
//获取我的群组
var getMyGroup = function () {
    initGetMyGroupTable([]);
    var options = {
        'Member_Account': loginInfo.identifier,
        'Limit': totalCount,
        'Offset': 0,
        //'GroupType':'',
        'GroupBaseInfoFilter': [
            'Type',
            'Name',
            'Introduction',
            'Notification',
            'FaceUrl',
            'CreateTime',
            'Owner_Account',
            'LastInfoTime',
            'LastMsgTime',
            'NextMsgSeq',
            'MemberNum',
            'MaxMemberNum',
            'ApplyJoinOption',
            'ShutUpAllMember'
        ],
        'SelfInfoFilter': [
            'Role',
            'JoinTime',
            'MsgFlag',
            'UnreadMsgNum'
        ]
    };
    webim.getJoinedGroupListHigh(
            options,
            function (resp) {
                if (!resp.GroupIdList || resp.GroupIdList.length == 0) {
                    alert('您目前还没有加入任何群组');
                    return;
                }
                var data = [];
                for (var i = 0; i < resp.GroupIdList.length; i++) {
                    var group_id = resp.GroupIdList[i].GroupId;
                    var name = webim.Tool.formatText2Html(resp.GroupIdList[i].Name);
                    var type_en = resp.GroupIdList[i].Type;
                    var type = webim.Tool.groupTypeEn2Ch(resp.GroupIdList[i].Type);
                    var role_en = resp.GroupIdList[i].SelfInfo.Role;
                    var role = webim.Tool.groupRoleEn2Ch(resp.GroupIdList[i].SelfInfo.Role);
                    var msg_flag = webim.Tool.groupMsgFlagEn2Ch(
                    resp.GroupIdList[i].SelfInfo.MsgFlag);
                    var msg_flag_en = resp.GroupIdList[i].SelfInfo.MsgFlag;
                    var join_time = webim.Tool.formatTimeStamp(
                    resp.GroupIdList[i].SelfInfo.JoinTime);
                    var member_num = resp.GroupIdList[i].MemberNum;
                    var notification = webim.Tool.formatText2Html(
                    resp.GroupIdList[i].Notification);
                    var introduction = webim.Tool.formatText2Html(
                    resp.GroupIdList[i].Introduction);
					var ShutUpAllMember = resp.GroupIdList[i].ShutUpAllMember;
                    data.push({
                        'GroupId': group_id,
                        'Name': name,
                        'TypeEn': type_en,
                        'Type': type,
                        'RoleEn': role_en,
                        'Role': role,
                        'MsgFlagEn': msg_flag_en,
                        'MsgFlag': msg_flag,
                        'MemberNum': member_num,
                        'Notification': notification,
                        'Introduction': introduction,
                        'JoinTime': join_time,
                    	'ShutUpAllMember': ShutUpAllMember
                    });
                }
                //打开我的群组列表对话框
                $('#get_my_group_table').bootstrapTable('load', data);
                $('#get_my_group_dialog').modal('show');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 读取群详细资料

```javascript
/* function getGroupInfo
 *   读取群详细资料-高级接口
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
getGroupInfo: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考 [获取群组详细资料 API](https://cloud.tencent.com/document/product/269/1616)。

**示例：**

```javascript
//读取群组基本资料-高级接口
var getGroupInfo = function (group_id, cbOK, cbErr) {
    var options = {
        'GroupIdList': [
            group_id
        ],
        'GroupBaseInfoFilter': [
            'Type',
            'Name',
            'Introduction',
            'Notification',
            'FaceUrl',
            'CreateTime',
            'Owner_Account',
            'LastInfoTime',
            'LastMsgTime',
            'NextMsgSeq',
            'MemberNum',
            'MaxMemberNum',
            'ApplyJoinOption'
        ],
        'MemberInfoFilter': [
            'Account',
            'Role',
            'JoinTime',
            'LastSendMsgTime',
            'ShutUpUntil'
        ]
    };
    webim.getGroupInfo(
            options,
            function (resp) {
                if (cbOK) {
                    cbOK(resp);
                }
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 修改群基本资料

```javascript
/* function modifyGroupBaseInfo
 *   修改群基本资料
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err为错误对象
 * return:
 *   (无)
 */
modifyGroupBaseInfo: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考[修改群资本资料 API](https://cloud.tencent.com/document/product/269/1620)

**示例：**


```javascript
//修改群资料
var modifyGroup = function () {
    if ($("#mg_name").val().length == 0) {
        alert('请输入群组名称');
        return;
    }
    if (webim.Tool.trimStr($("#mg_name").val()).length == 0) {
        alert('您输入的群组名称全是空格,请重新输入');
        return;
    }
    if (webim.Tool.getStrBytes($("#fsm_name").val()) > 30) {
        alert('您输入的群组名称超出限制(最长10个汉字)');
        return;
    }
    if (webim.Tool.getStrBytes($("#fsm_notification").val()) > 150) {
        alert('您输入的群组公告超出限制(最长50个汉字)');
        return;
    }
    if (webim.Tool.getStrBytes($("#fsm_introduction").val()) > 120) {
        alert('您输入的群组简介超出限制(最长40个汉字)');
        return;
    }
    var options = {
        'GroupId': $('#mg_group_id').val(),
        'Name': $('#mg_name').val(),
        //'FaceUrl': $('#mg_face_url').val(),
        'Notification': $('#mg_notification').val(),
        'Introduction': $('#mg_introduction').val(),
        'ShutUpAllMember': $('#shut_up_all_member').val()//新增群组全局禁言。参数为：On和Off
    };
    webim.modifyGroupBaseInfo(
            options,
            function (resp) {
                //在表格中修改对应的行
                $('#get_my_group_table').bootstrapTable('updateRow', {
                    index: $('#mg_sel_row_index').val(),
                    row: {
                        Type: $('input[name="mg_type_radio"]:checked').val(),
                        Name: webim.Tool.formatText2Html($('#mg_name').val()),
                        Introduction: webim.Tool.formatText2Html(
                        $('#mg_introduction').val()),
                        Notification: webim.Tool.formatText2Html(
                        $('#mg_notification').val())
                    }
                });
                $('#modify_group_dialog').modal('hide');
                alert('修改群资料成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```
