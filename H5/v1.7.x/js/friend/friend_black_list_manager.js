//定义我的黑名单表格每行的操作按钮
function gblOperateFormatter(value, row, index) {
    return [
        '<a class="remove ml10" href="javascript:void(0)" title="删除">',
        '<i class="glyphicon glyphicon-remove"></i>',
        '</a>'

    ].join('');
}
//定义我的黑名单表格每行的操作按钮点击事件
window.gblOperateEvents = {
    'click .remove': function (e, value, row, index) {
        if (confirm("确定将该联系人从黑名单删除吗？")) {
            deleteBlackList(row.To_Account);
        }
    }
};
//初始化我的黑名单表格
function initGetBlackListTable(data) {
    $('#get_black_list_table').bootstrapTable({
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
            {field: "To_Account", title: "账号", align: "center", valign: "middle", sortable: "true"},
            {field: "AddBlackTimeStamp", title: "操作时间", align: "center", valign: "middle", sortable: "true"},
            {
                field: "operate",
                title: "操作",
                align: "center",
                valign: "middle",
                formatter: "gblOperateFormatter",
                events: "gblOperateEvents"
            }
        ],
        data: data,
        formatNoMatches: function () {
            return '无符合条件的记录';
        }
    });
}
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
        'From_Account': loginInfo.identifier,
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
            //getAllFriend(getAllFriendsCallbackOK);
            deleteSessDiv(webim.SESSION_TYPE.C2C,add_account);//在最近联系人列表中删除对应拉黑的好友(如果存在的话)
            alert('添加黑名单成功');
        },
        function (err) {
            alert(err.ErrorInfo);
        }
    );
};

//删除黑名单
var deleteBlackList = function (del_account) {

    var to_account = [
        del_account
    ];
    var options = {
        'From_Account': loginInfo.identifier,
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

//我的黑名单
var getBlackList = function (cbOK, cbErr) {
    initGetBlackListTable([]);
    var options = {
        'From_Account': loginInfo.identifier,
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
                    var add_time = webim.Tool.formatTimeStamp(resp.BlackListItem[i].AddBlackTimeStamp);
                    data.push({
                        To_Account: webim.Tool.formatText2Html(resp.BlackListItem[i].To_Account),
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