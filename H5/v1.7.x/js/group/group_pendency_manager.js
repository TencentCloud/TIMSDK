//定义我的加群申请表格每行按钮
function gajgpOperateFormatter(value, row, index) {
    return [
        '<a class="edit" href="javascript:void(0)" title="处理">',
        '<i class="glyphicon glyphicon-edit"></i>',
        '</a>'

    ].join('');
}
//我的加群申请表格每行的按钮点击事件
window.gajgpOperateEvents = {
    'click .edit': function (e, value, row, index) {

        $("#hajg_group_id").val(row.GroupId);
        $("#hajg_to_account").val(row.Operator_Account);
        $("#hajg_msg_key").val(row.MsgKey);
        $("#hajg_authentication").val(row.Authentication);
        $("#hajg_user_defined_field").val(row.UserDefinedField);

        $("#hajg_from_account").val(row.From_Account);
        $("#hajg_msg_seq").val(row.MsgSeq);
        $("#hajg_msg_random").val(row.MsgRandom);

        $('#handle_ajg_dialog').modal('show');
    }
};
//初始化我的加群申请表格
function initGetApplyJoinGroupPendency(data) {
    $('#get_apply_join_group_pendency_table').bootstrapTable({
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
        columns: [
            {field: "GroupId", title: "群ID", align: "center", valign: "middle", sortable: "true"},
            {field: "GroupName", title: "群名称", align: "center", valign: "middle", sortable: "true"},
            {field: "Operator_Account", title: "对方账号", align: "center", valign: "middle", sortable: "true"},
            //{field: "ApplyNick", title: "对方昵称", align: "center", valign: "middle", sortable: "true"},

            {field: "MsgTime", title: "申请时间", align: "center", valign: "middle", sortable: "true"},
            {field: "RemarkInfo", title: "附言", align: "center", valign: "middle", sortable: "true"},
            {field: "MsgKey", title: "MsgKey", align: "center", valign: "middle", sortable: "true", visible: false},
            {
                field: "Authentication",
                title: "Authentication",
                align: "center",
                valign: "middle",
                sortable: "true",
                visible: false
            },
            {
                field: "UserDefinedField",
                title: "UserDefinedField",
                align: "center",
                valign: "middle",
                sortable: "true",
                visible: false
            },
            {field: "From_Account", title: "发送者", align: "center", valign: "middle", sortable: "true", visible: false},
            {field: "MsgSeq", title: "消息序号", align: "center", valign: "middle", sortable: "true", visible: false},
            {field: "MsgRandom", title: "消息随机数", align: "center", valign: "middle", sortable: "true", visible: false},
            {
                field: "gajgpOperate",
                title: "操作",
                align: "center",
                valign: "middle",
                formatter: "gajgpOperateFormatter",
                events: "gajgpOperateEvents"
            }
        ],
        data: data,
        formatNoMatches: function () {
            return '无符合条件的记录';
        }
    });
}


//查看未决加群申请
var getApplyJoinGroupPendency = function () {
    $('#get_apply_join_group_pendency_dialog').modal('show');
};

//处理加群申请
var handleApplyJoinGroupPendency = function () {

    var options = {
        'GroupId': $("#hajg_group_id").val(), //群id
        'Applicant_Account': $("#hajg_to_account").val(), //申请人id
        'HandleMsg': $('input[name="hajg_action_radio"]:checked').val(), //Agree-同意 Reject-拒绝
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

//删除已处理的加群未决消息
var deleteApplyJoinGroupPendency = function (opts) {

    webim.deleteApplyJoinGroupPendency(opts,
        function (resp) {
            webim.Log.info('delete group pendency msg success');
        },
        function (err) {
            alert(err.ErrorInfo);
            webim.Log.error('delete group pendency msg failed');
        }
    );
    return;
};

