//定义我的好友申请表格每行按钮
function gpOperateFormatter(value, row, index) {
    return [
        '<a class="edit" href="javascript:void(0)" title="处理">',
        '<i class="glyphicon glyphicon-edit"></i>',
        '</a>',
        '<a class="remove ml10" href="javascript:void(0)" title="删除">',
        '<i class="glyphicon glyphicon-remove"></i>',
        '</a>'

    ].join('');
}
//我的好友申请表格每行的按钮点击事件
window.gpOperateEvents = {
    'click .edit': function (e, value, row, index) {

        $("#rf_to_account").val(row.To_Account);
        $('#response_friend_dialog').modal('show');

    },
    'click .remove': function (e, value, row, index) {
        if (confirm("确定删除这条记录吗？")) {
            deletePendency(row.To_Account);
        }

    }
};
//初始化我的好友申请表格
function initGetPendencyTable(data) {
    $('#get_pendency_table').bootstrapTable({
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
            {field: "To_Account", title: "对方账号", align: "center", valign: "middle", sortable: "true", visible: false},
            {field: "Nick", title: "对方昵称", align: "center", valign: "middle", sortable: "true"},
            {field: "AddWording", title: "附言", align: "center", valign: "middle", sortable: "true"},
            {field: "AddSource", title: "来源", align: "center", valign: "middle", sortable: "true", visible: false},
            {field: "AddTime", title: "申请时间", align: "center", valign: "middle", sortable: "true"},
            {
                field: "gpOperate",
                title: "操作",
                align: "center",
                valign: "middle",
                formatter: "gpOperateFormatter",
                events: "gpOperateEvents"
            }
        ],
        data: data,
        formatNoMatches: function () {
            return '无符合条件的记录';
        }
    });
}
//读取好友申请列表
//notifyFlag： true表示来自好友系统通知触发，false表示用户主动点击【获取好友申请】菜单
var getPendency = function (notifyFlag) {
    initGetPendencyTable([]);
    var options = {
        //请求发起方的帐号，一般情况下为用户本人帐号，在管理员代替用户发起请求的情况下，这里应该填写被代替的用户的帐号
        'From_Account': loginInfo.identifier,
        //Pendency_Type_ComeIn: 别人发给我的; Pendency_Type_SendOut: 我发给别人的
        'PendencyType': 'Pendency_Type_ComeIn',
        //好友申请的起始时间
        'StartTime': 0,
        //分页大小，如果取值为30 则表示客户端要求服务器端每页最多返回30个好友申请
        'MaxLimited': totalCount,
        //好友申请数据的版本号，用户每收到或删除一条好友申请，服务器端就自增一次好友申请数据版本号，一般传0，表示拉取最新的数据
        'LastSequence': 0
    };

    webim.getPendency(
        options,
        function (resp) {
            var data = [];
            if (resp.UnreadPendencyCount > 0) {//存在未读未决
                for (var i in resp.PendencyItem) {
                    var apply_time = webim.Tool.formatTimeStamp(resp.PendencyItem[i].AddTime);
                    var nick = webim.Tool.formatText2Html(resp.PendencyItem[i].Nick);
                    if (nick == '') {
                        nick = resp.PendencyItem[i].To_Account;
                    }
                    var addWording = webim.Tool.formatText2Html(resp.PendencyItem[i].AddWording);
                    data.push({
                        To_Account: webim.Tool.formatText2Html(resp.PendencyItem[i].To_Account),
                        Nick: nick,
                        AddWording: addWording,
                        AddSource: resp.PendencyItem[i].AddSource,
                        AddTime: apply_time
                    });
                }
                $('#get_pendency_table').bootstrapTable('load', data);
                $('#get_pendency_dialog').modal('show');
            } else {
                if (!notifyFlag) {
                    alert('没有加好友申请');
                }
            }

        },
        function (err) {
            alert(err.ErrorInfo);
        }
    );
};

//删除申请列表
var deletePendency = function (del_account) {

    var options = {
        'From_Account': loginInfo.identifier,
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
//处理好友申请
var responseFriend = function () {

    var response_friend_item = [
        {
            'To_Account': $("#rf_to_account").val(),
            "ResponseAction": $('input[name="rf_action_radio"]:checked').val()//类型：Response_Action_Agree 或者 Response_Action_AgreeAndAdd
        }
    ];
    var options = {
        'From_Account': loginInfo.identifier,
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

            if (response_friend_item[0].ResponseAction == 'Response_Action_AgreeAndAdd') {
                //getAllFriend(getAllFriendsCallbackOK);
            }

            alert('处理好友申请成功');
        },
        function (err) {
            alert(err.ErrorInfo);
        }
    );

};

