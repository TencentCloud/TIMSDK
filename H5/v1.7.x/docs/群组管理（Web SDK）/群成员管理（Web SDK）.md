## 获取群成员列表 

```javascript
/* function getGroupMemberInfo  
 *   获取群组成员列表
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
getGroupMemberInfo: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考 [获取群组成员详细资料 API](https://cloud.tencent.com/document/product/269/1617)。

**示例： **

```javascript
//读取群组成员
var getGroupMemberInfo = function (group_id) {
    initGetGroupMemberTable([]);
    var options = {
        'GroupId': group_id,
        'Offset': 0, //必须从 0 开始
        'Limit': totalCount,
        'MemberInfoFilter': [
            'Account',
            'Role',
            'JoinTime',
            'LastSendMsgTime',
            'ShutUpUntil'
        ]
    };
    webim.getGroupMemberInfo(
            options,
            function (resp) {
                if (resp.MemberNum <= 0) {
                    alert('该群组目前没有成员');
                    return;
                }
                var data = [];
                for (var i in resp.MemberList) {
                    var account = resp.MemberList[i].Member_Account;
                    var role = webim.Tool.groupRoleEn2Ch(resp.MemberList[i].Role);
                    var join_time = webim.Tool.formatTimeStamp(
                    resp.MemberList[i].JoinTime);
                    var shut_up_until = webim.Tool.formatTimeStamp(
                    resp.MemberList[i].ShutUpUntil);
                    if (shut_up_until == 0) {
                        shut_up_until = '-';
                    }
                    data.push({
                        GroupId: group_id,
                        Member_Account: account,
                        Role: role,
                        JoinTime: join_time,
                        ShutUpUntil: shut_up_until
                    });
                }
                $('#get_group_member_table').bootstrapTable('load', data);
                $('#get_group_member_dialog').modal('show');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 邀请好友加群 

```javascript
/* function addGroupMember  
 *   邀请好友加群
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
addGroupMember: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考 [增加群组成员 API](https://cloud.tencent.com/document/product/269/1621)。

**示例： **

```javascript
//邀请好友加群
var addGroupMember = function () {
    var options = {
        'GroupId': $('#agm_group_id').val(),
        'MemberList': [
            {
                'Member_Account': $('#agm_account').val()
            }

        ]
    };
    webim.addGroupMember(
            options,
            function (resp) {
                //在表格中删除对应的行
                $('#get_my_friend_group_table').bootstrapTable('remove', {
                    field: 'Info_Account',
                    values: [$('#agm_account').val()]
                });
                $('#add_group_member_dialog').modal('hide');
                alert('邀请好友加群成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 修改群消息提示 

```javascript
/* function modifyGroupMember  
 *   修改群成员资料（角色或者群消息提类型示）
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
modifyGroupMember: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考 [修改群成员资料 API](https://cloud.tencent.com/document/product/269/1623)。

**示例： **

```javascript
//修改群消息提示类型
var modifyGroupMsgFlag = function () {
    var msg_flag_en = $('input[name="mgmf_msg_flag_radio"]:checked').val();
    var msg_flag_zh = webim.Tool.groupMsgFlagEn2Ch(msg_flag_en);
    var options = {
        'GroupId': $('#mgmf_group_id').val(),
        'Member_Account': loginInfo.identifier,
        'MsgFlag': msg_flag_en
    };
    webim.modifyGroupMember(
            options,
            function (resp) {
                //在表格中修改对应的行              
                $('#get_my_group_table').bootstrapTable('updateRow', {
                    index: $('#mgmf_sel_row_index').val(),
                    row: {
                        MsgFlag: msg_flag_zh,
                        MsgFlagEn: msg_flag_en
                    }
                });
                $('#modify_group_msg_flag_dialog').modal('hide');
                alert('设置群消息提示类型成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 修改群成员角色 

```javascript
/* function modifyGroupMember  
 *   修改群成员资料（角色或者群消息提类型示）
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
modifyGroupMember: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考 [修改群成员资料 API](https://cloud.tencent.com/document/product/269/1623)。

**示例： **

```javascript
//修改群组成员角色
var modifyGroupMemberRole = function () {
    var role_en = $('input[name="mgm_role_radio"]:checked').val();
    var role_zh = webim.Tool.groupRoleEn2Ch(role_en);
    var options = {
        'GroupId': $('#mgm_group_id').val(),
        'Member_Account': $('#mgm_account').val(),
        'Role': role_en
    };
    webim.modifyGroupMember(
            options,
            function (resp) {
                //在表格中修改对应的行              
                $('#get_group_member_table').bootstrapTable('updateRow', {
                    index: $('#mgm_sel_row_index').val(),
                    row: {
                        Role: role_zh
                    }
                });
                $('#modify_group_member_dialog').modal('hide');
                alert('修改群成员角色成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 设置群成员禁言时间 

```javascript
/* function forbidSendMsg  
 *   设置群成员禁言时间
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
forbidSendMsg: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考 [批量禁言和取消禁言 API](https://cloud.tencent.com/document/product/269/1627)。

**示例：**

```javascript
//设置成员禁言时间
var forbidSendMsg = function () {
    if (!webim.Tool.validNumber($('#fsm_shut_up_time').val())) {
        alert('您输入的禁言时间非法,只能是数字(0-31536000)');
        return;
    }
    var shut_up_time = parseInt($('#fsm_shut_up_time').val());
    if (shut_up_time > 31536000) {
        alert('您输入的禁言时间非法,只能是数字(0-31536000)');
        return;
    }
    var shut_up_until = '-';
    if (shut_up_time != 0) {
        //当前时间+禁言时间=禁言截至时间
        shut_up_until = webim.Tool.formatTimeStamp(
        Math.round(new Date().getTime() / 1000) + shut_up_time);
    }
    var options = {
        'GroupId': $('#fsm_group_id').val(),//群组id
        'Members_Account': [$('#fsm_account').val()],//被禁言的成员帐号列表
        'ShutUpTime': shut_up_time//禁言时间，单位：秒
    };
    webim.forbidSendMsg(
            options,
            function (resp) {
                //在表格中修改对应的行              
                $('#get_group_member_table').bootstrapTable('updateRow', {
                    index: $('#fsm_sel_row_index').val(),
                    row: {
                        ShutUpUntil: shut_up_until
                    }
                });
                $('#forbid_send_msg_dialog').modal('hide');
                alert('设置成员禁言时间成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```

## 删除群成员 

```javascript
/* function deleteGroupMember  
 *   删除群成员
 * params:
 *   options	- 请求参数
 *   cbOk	- function()类型, 成功时回调函数
 *   cbErr	- function(err)类型, 失败时回调函数, err 为错误对象
 * return:
 *   (无)
 */
deleteGroupMember: function(options, cbOk, cbErr) {},
```

>?详细参数说明请参考 [删除群组成员 API](https://cloud.tencent.com/document/product/269/1622)。

**示例：**

```javascript
//删除群组成员
var deleteGroupMember = function () {
    if (!confirm("确定移除该成员吗？")) {
        return;
    }
    var options = {
        'GroupId': $('#dgm_group_id').val(),
        //'Silence': $('input[name="dgm_silence_radio"]:checked').val(),
        //只有 ROOT 用户采用权限设置该字段（是否静默移除）
        'MemberToDel_Account': [$('#dgm_account').val()]
    };
    webim.deleteGroupMember(
            options,
            function (resp) {
                //在表格中删除对应的行
                $('#get_group_member_table').bootstrapTable('remove', {
                    field: 'Member_Account',
                    values: [$('#dgm_account').val()]
                });
                $('#delete_group_member_dialog').modal('hide');
                alert('移除群成员成功');
            },
            function (err) {
                alert(err.ErrorInfo);
            }
    );
};
```
