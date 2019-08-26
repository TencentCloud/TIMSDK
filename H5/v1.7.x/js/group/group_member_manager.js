//定义群组成员表格每行的按钮

function ggmOperateFormatter(value, row, index) {
    return [
        '<a class="pencil ml10" href="javascript:void(0)" title="修改群成员角色">',
        '<i class="glyphicon glyphicon-pencil"></i>',
        '</a>',
        '<a class="time ml10" href="javascript:void(0)" title="设置禁言时间">',
        '<i class="glyphicon glyphicon-time"></i>',
        '</a>',
        '<a class="remove ml10" href="javascript:void(0)" title="移除该成员">',
        '<i class="glyphicon glyphicon-remove"></i>',
        '</a>'

    ].join('');
}
//定义群组成员表格每行的按钮单击事件
window.ggmOperateEvents = {
    'click .remove': function(e, value, row, index) {
        switch ($('#ggm_my_role').val()) {
            case '成员':
                alert('你不是管理员，无法进行此操作');
                break;
            case '管理员':
                if (row.Role == '成员') {
                    $('#dgm_group_id').val($('#ggm_group_id').val());
                    $('#dgm_account').val(row.Member_Account);
                    $('#delete_group_member_dialog').modal('show');
                } else {
                    alert('你不能移除群主或管理员');
                }
                break;
            case '群主':
                if (row.Role == '群主') {
                    alert('你不能移除自己');
                } else {
                    $('#dgm_group_id').val($('#ggm_group_id').val());
                    $('#dgm_account').val(row.Member_Account);
                    $('#delete_group_member_dialog').modal('show');
                }
                break;
        }
    },
    'click .pencil': function(e, value, row, index) {


        switch ($('#ggm_my_role').val()) {
            case '成员':
                alert('你不是群主，无法进行此操作');
                break;
            case '管理员':
                alert('你不是群主，无法进行此操作');
                break;
            case '群主':
                if ($('#ggm_group_type').val() == 'Private') {
                    alert('私有群不支持设置群成员角色操作');
                    return;
                }
                if (row.Role == '群主') {
                    alert('你不能设置自己的群角色');
                } else {
                    $('#mgm_sel_row_index').val(index);
                    $('#mgm_group_id').val($('#ggm_group_id').val());
                    $('#mgm_account').val(row.Member_Account);
                    //设置群身份
                    var role_en = webim.Tool.groupRoleCh2En(row.Role);
                    //$("input[type=radio][name='mgm_role_radio'][value=" + role_en + "]").attr("checked", 'checked');
                    var mgm_role_radio = document.mgm_form.mgm_role_radio;
                    for (var i = 0; i < mgm_role_radio.length; i++) {
                        if (mgm_role_radio[i].value == role_en) {
                            mgm_role_radio[i].checked = true;
                            break;
                        }
                    }
                    $('#modify_group_member_dialog').modal('show');
                }
                break;
        }
    },
    'click .time': function(e, value, row, index) {
        switch ($('#ggm_my_role').val()) {
            case '成员':
                alert('你不是管理员，无法进行此操作');
                break;
            case '管理员':
                if (row.Role == '成员') {
                    $('#fsm_sel_row_index').val(index);
                    $('#fsm_group_id').val($('#ggm_group_id').val());
                    $('#fsm_account').val(row.Member_Account);

                    var shutup_time = 0;
                    if (row.ShutUpUntil != '-') {

                        var shutup_until_time = new Date(row.ShutUpUntil).getTime();
                        var now_time = new Date().getTime();
                        shutup_time = shutup_until_time - now_time;
                        if (shutup_time > 0) {
                            shutup_time = Math.round(shutup_time / 1000);
                        } else {
                            shutup_time = 0;
                        }
                    }
                    $('#fsm_shut_up_time').val(shutup_time);
                    $('#forbid_send_msg_dialog').modal('show');
                } else {
                    alert('你不能设置群主或管理禁言时间');
                }
                break;
            case '群主':
                if (row.Role == '群主') {
                    alert('你不能对自己设置禁言时间');
                } else {

                    $('#fsm_sel_row_index').val(index);
                    $('#fsm_group_id').val($('#ggm_group_id').val());
                    $('#fsm_account').val(row.Member_Account);

                    var shutup_time = 0;

                    if (row.ShutUpUntil != '-') {

                        var shutup_until_time = new Date(row.ShutUpUntil).getTime();
                        var now_time = new Date().getTime();
                        shutup_time = shutup_until_time - now_time;
                        if (shutup_time > 0) {
                            shutup_time = Math.round(shutup_time / 1000);
                        } else {
                            shutup_time = 0;
                        }
                    }
                    $('#fsm_shut_up_time').val(shutup_time);
                    $('#forbid_send_msg_dialog').modal('show');
                }
                break;
        }
    }
};
//初始化群组成员表格

function initGetGroupMemberTable(data) {
    $('#get_group_member_table').bootstrapTable({
        method: 'get',
        cache: false,
        height: 500,
        striped: true,
        pagination: true,
        pageSize: pageSize,
        pageNumber: 1,
        pageList: [10, 20, 50, 100],
        search: true,
        showColumns: true,
        clickToSelect: true,
        columns: [{
            field: "GroupId",
            title: "群ID",
            align: "center",
            valign: "middle",
            sortable: "true"
        }, {
            field: "Member_Account",
            title: "帐号",
            align: "center",
            valign: "middle",
            sortable: "true"
        }, {
            field: "Role",
            title: "角色",
            align: "center",
            valign: "middle",
            sortable: "true"
        }, {
            field: "JoinTime",
            title: "入群时间",
            align: "center",
            valign: "middle",
            sortable: "true"
        }, {
            field: "ShutUpUntil",
            title: "禁言截至时间",
            align: "center",
            valign: "middle",
            sortable: "true"
        }, {
            field: "ggmOperate",
            title: "操作",
            align: "center",
            valign: "middle",
            formatter: "ggmOperateFormatter",
            events: "ggmOperateEvents"
        }],
        data: data,
        formatNoMatches: function() {
            return '无符合条件的记录';
        }
    });
}

//读取群组成员
var getGroupMemberInfo = function(group_id) {
    initGetGroupMemberTable([]);
    var options = {
        'GroupId': group_id,
        'Offset': 0, //必须从0开始
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
        function(resp) {
            if (resp.MemberNum <= 0) {
                alert('该群组目前没有成员');
                return;
            }
            var data = [];
            for (var i in resp.MemberList) {
                var account = resp.MemberList[i].Member_Account;
                var role = webim.Tool.groupRoleEn2Ch(resp.MemberList[i].Role);
                var join_time = webim.Tool.formatTimeStamp(resp.MemberList[i].JoinTime);
                var shut_up_until = webim.Tool.formatTimeStamp(resp.MemberList[i].ShutUpUntil);
                if (shut_up_until == 0) {
                    shut_up_until = '-';
                }
                data.push({
                    GId: group_id,
                    GroupId: webim.Tool.formatText2Html(group_id),
                    Member_Account: webim.Tool.formatText2Html(account),
                    Role: role,
                    JoinTime: join_time,
                    ShutUpUntil: shut_up_until
                });
            }
            $('#get_group_member_table').bootstrapTable('load', data);
            $('#get_group_member_dialog').modal('show');
        },
        function(err) {
            alert(err.ErrorInfo);
        }
    );
};

//修改群组成员角色
var modifyGroupMemberRole = function() {
    var role_en = $('input[name="mgm_role_radio"]:checked').val();
    var role_zh = webim.Tool.groupRoleEn2Ch(role_en);
    var options = {
        'GroupId': $('#mgm_group_id').val(),
        'Member_Account': $('#mgm_account').val(),
        'Role': role_en
    };
    webim.modifyGroupMember(
        options,
        function(resp) {
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
        function(err) {
            alert(err.ErrorInfo);
        }
    );
};
//设置成员禁言时间
var forbidSendMsg = function() {
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
        shut_up_until = webim.Tool.formatTimeStamp(Math.round(new Date().getTime() / 1000) + shut_up_time);
    }
    var options = {
        'GroupId': $('#fsm_group_id').val(), //群id
        'Members_Account': [$('#fsm_account').val()], //被禁言的成员帐号列表
        'ShutUpTime': shut_up_time //禁言时间，单位：秒
    };
    webim.forbidSendMsg(
        options,
        function(resp) {
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
        function(err) {
            alert(err.ErrorInfo);
        }
    );
};

//修改群消息提示类型
var modifyGroupMsgFlag = function() {
    var msg_flag_en = $('input[name="mgmf_msg_flag_radio"]:checked').val();
    var msg_flag_zh = webim.Tool.groupMsgFlagEn2Ch(msg_flag_en);
    var options = {
        'GroupId': $('#mgmf_group_id').val(),
        'Member_Account': loginInfo.identifier,
        'MsgFlag': msg_flag_en
    };
    webim.modifyGroupMember(
        options,
        function(resp) {
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
        function(err) {
            alert(err.ErrorInfo);
        }
    );
};
//删除群组成员
var deleteGroupMember = function() {
    if (!confirm("确定移除该成员吗？")) {
        return;
    }
    var options = {
        'GroupId': $('#dgm_group_id').val(),
        //'Silence': $('input[name="dgm_silence_radio"]:checked').val(),//只有ROOT用户采用权限设置该字段（是否静默移除）
        'MemberToDel_Account': [$('#dgm_account').val()]
    };
    webim.deleteGroupMember(
        options,
        function(resp) {
            //在表格中删除对应的行
            $('#get_group_member_table').bootstrapTable('remove', {
                field: 'Member_Account',
                values: [$('#dgm_account').val()]
            });
            $('#delete_group_member_dialog').modal('hide');
            alert('移除群成员成功');
        },
        function(err) {
            alert(err.ErrorInfo);
        }
    );
};
//邀请好友加群
var addGroupMember = function() {
    var options = {
        'GroupId': $('#agm_group_id').val(),
        'MemberList': [{
                'Member_Account': $('#agm_account').val()
            }

        ]
    };
    webim.addGroupMember(
        options,
        function(resp) {
            //在表格中删除对应的行
            $('#get_my_friend_group_table').bootstrapTable('remove', {
                field: 'Info_Account',
                values: [$('#agm_account').val()]
            });
            $('#add_group_member_dialog').modal('hide');
            alert('邀请好友加群成功');
        },
        function(err) {
            alert(err.ErrorInfo);
        }
    );
};