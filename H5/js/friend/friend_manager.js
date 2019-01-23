//定义我的好友表格每行的操作按钮
function gmfOperateFormatter(value, row, index) {
    return [
        '<a class="envelope" href="javascript:void(0)" title="发消息">',
        '<i class="glyphicon glyphicon-envelope"></i>',
        '</a>',
        '<a class="ban-circle" href="javascript:void(0)" title="拉黑">',
        '<i class="glyphicon glyphicon-ban-circle"></i>',
        '</a>',
        '<a class="remove ml10" href="javascript:void(0)" title="删除">',
        '<i class="glyphicon glyphicon-remove"></i>',
        '</a>'

    ].join('');
}
//我的好友表格每行的操作按钮点击事件
window.gmfOperateEvents = {
    'click .envelope': function (e, value, row, index) {
        $('#scm_to_account').val(row.Info_Account);
        $('#send_c2c_msg_dialog').modal('show');
    },
    'click .ban-circle': function (e, value, row, index) {
        if (confirm("确定将该好友拉黑吗？")) {
            addBlackList(row.Info_Account);
        }
    },
    'click .remove': function (e, value, row, index) {
        $('#df_to_account').val(row.Info_Account);
        $('#delete_friend_dialog').modal('show');
    }
};
//初始化我的好友表格
function initGetMyFriendTable(data) {
    $('#get_my_friend_table').bootstrapTable({
        method: 'get',
        cache: false,
        height: 500,
        striped: true,
        pagination: true,
        sidePagination: 'client',
        pageSize: pageSize,
        pageNumber: 1,
        pageList: [10, 20, 50, 100],
        search: true,
        showColumns: true,
        clickToSelect: true,
        columns: [
            {field: "Info_Account", title: "账号", align: "center", valign: "middle", sortable: "true"},
            {field: "Nick", title: "昵称", align: "center", valign: "middle", sortable: "true"},
            {field: "Gender", title: "性别", align: "center", valign: "middle", sortable: "true"},
            {
                field: "gmfOperate",
                title: "操作",
                align: "center",
                valign: "middle",
                formatter: "gmfOperateFormatter",
                events: "gmfOperateEvents"
            }
        ],
        data: data,
        formatNoMatches: function () {
            return '无符合条件的记录';
        }
    });
}
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
        'From_Account': loginInfo.identifier,
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
                    //getAllFriend(getAllFriendsCallbackOK);
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
        'From_Account': loginInfo.identifier,
        'To_Account': to_account,
        //Delete_Type_Both'//单向删除："Delete_Type_Single", 双向删除："Delete_Type_Both".
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
            //getAllFriend(getAllFriendsCallbackOK);
            deleteSessDiv(webim.SESSION_TYPE.C2C,$("#df_to_account").val());//在最近联系人列表中删除好友(如果存在的话)
            $('#delete_friend_dialog').modal('hide');
            alert('删除好友成功');
        },
        function (err) {
            alert(err.ErrorInfo);
        }
    );

};
//获取我的好友
var getMyFriend = function () {

    //清空
    initGetMyFriendTable([]);

    var options = {
        'From_Account': loginInfo.identifier,
        'TimeStamp': 0,
        'StartIndex': 0,
        'GetCount': totalCount,
        'LastStandardSequence': 0,
        "TagList": [
            "Tag_Profile_IM_Nick",
            "Tag_SNS_IM_Remark",
            "Tag_Profile_IM_Gender"
        ]
    };

    webim.getAllFriend(
        options,
        function (resp) {

            if (resp.FriendNum > 0) {

                var table_friends_data = [];
                var friends = resp.InfoItem;
                if (!friends || friends.length == 0) {
                    alert('你目前还没有好友');
                    return;
                }

                var count = friends.length;

                for (var i = 0; i < count; i++) {
                    var friend_name = friends[i].Info_Account;
                    var gender = "未知";
                    if (friends[i].SnsProfileItem) {
                        for (var j in friends[i].SnsProfileItem) {
                            switch (friends[i].SnsProfileItem[j].Tag) {
                                case 'Tag_Profile_IM_Nick':
                                    friend_name = friends[i].SnsProfileItem[j].Value;
                                    break;
                                case 'Tag_Profile_IM_Gender':
                                    switch (friends[i].SnsProfileItem[j].Value) {
                                        case 'Gender_Type_Male':
                                            gender = '男';
                                            break;
                                        case 'Gender_Type_Female':
                                            gender = '女';
                                            break;
                                        case 'Gender_Type_Unknown':
                                            gender = '未知';
                                            break;
                                    }
                                    break;
                            }
                        }
                    }
                    table_friends_data.push({
                        'Info_Account': friends[i].Info_Account,
                        'Nick': webim.Tool.formatText2Html(friend_name),
                        'Gender': gender
                    });
                }

                //打开我的好友列表对话框
                $('#get_my_friend_table').bootstrapTable('load', table_friends_data);
                $('#get_my_friend_dialog').modal('show');
            } else {
                alert('您目前还没有好友');
            }

        },
        function (err) {
            alert(err.ErrorInfo);
        }
    );
};

//从我的好友列表中给好友发消息
function sendC2cMsg(){

    toAccount=$("#scm_to_account").val();
    msgtosend=$("#scm_content").val();

    var msgLen = webim.Tool.getStrBytes(msgtosend);

    var maxLen, errInfo;

    maxLen = webim.MSG_MAX_LENGTH.C2C;
    errInfo = "消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)";

    if (msgtosend.length < 1) {
        alert("发送的消息不能为空!");
        $("#send_msg_text").val('');
        return;
    }

    if (msgLen > maxLen) {
        alert(errInfo);
        return;
    }

    var sess=webim.MsgStore.sessByTypeId(webim.SESSION_TYPE.C2C, toAccount);
    if (!sess) {
        sess = new webim.Session(webim.SESSION_TYPE.C2C, toAccount, toAccount, friendHeadUrl, Math.round(new Date().getTime() / 1000));
    }
    var isSend = true;//是否为自己发送
    var seq = -1;//消息序列，-1表示sdk自动生成，用于去重
    var random = Math.round(Math.random() * 4294967296);//消息随机数，用于去重
    var msgTime = Math.round(new Date().getTime() / 1000);//消息时间戳
    var subType;//消息子类型

    subType = webim.C2C_MSG_SUB_TYPE.COMMON;

    var msg = new webim.Msg(sess, isSend, seq, random, msgTime, loginInfo.identifier, subType, loginInfo.identifierNick);

    var text_obj;

    text_obj = new webim.Msg.Elem.Text(msgtosend);
    msg.addText(text_obj);

    webim.sendMsg(msg, function (resp) {


        if (!selToID) {//没有聊天会话
            selType=webim.SESSION_TYPE.C2C;
            selToID=toAccount;
            selSess=sess;
            addSess(selType,toAccount, toAccount, friendHeadUrl, 0, 'sesslist');
            setSelSessStyleOn(toAccount);
            //私聊时，在聊天窗口手动添加一条发的消息，群聊时，长轮询接口会返回自己发的消息
            addMsg(msg);
        }else{//有聊天会话
            if(selToID==toAccount){//聊天对象不变
                addMsg(msg);
            }else{//聊天对象发生改变
                var tempSessDiv = document.getElementById("sessDiv_" + toAccount);
                if(!tempSessDiv){//不存在这个会话
                    addSess(webim.SESSION_TYPE.C2C,toAccount, toAccount, friendHeadUrl, 0, 'sesslist');//增加一个会话
                }

                onSelSess(webim.SESSION_TYPE.C2C,toAccount);//再进行切换
            }
        }
        webim.Tool.setCookie("tmpmsg_" + toAccount, '', 0);
        $("#scm_content").val('');
        $('#send_c2c_msg_dialog').modal('hide');
        $('#get_my_friend_dialog').modal('hide');

    }, function (err) {
        alert(err.ErrorInfo);
        $("#scm_content").val('');
    });
}

//将我的好友资料（昵称和头像）保存在infoMap
var initInfoMapByMyFriends = function (cbOK) {

    var options = {
        'From_Account': loginInfo.identifier,
        'TimeStamp': 0,
        'StartIndex': 0,
        'GetCount': totalCount,
        'LastStandardSequence': 0,
        "TagList": [
            "Tag_Profile_IM_Nick",
            "Tag_Profile_IM_Image"
        ]
    };

    webim.getAllFriend(
        options,
        function (resp) {
            if (resp.FriendNum > 0) {

                var friends = resp.InfoItem;
                if (!friends || friends.length == 0) {
                    if (cbOK)
                        cbOK();
                    return;
                }
                var count = friends.length;

                for (var i = 0; i < count; i++) {
                    var friend=friends[i];
                    var friend_account = friend.Info_Account;
                    var friend_name=friend_image='';
                    for (var j in friend.SnsProfileItem) {
                        switch (friend.SnsProfileItem[j].Tag) {
                            case 'Tag_Profile_IM_Nick':
                                friend_name = friend.SnsProfileItem[j].Value;
                                break;
                            case 'Tag_Profile_IM_Image':
                                friend_image = friend.SnsProfileItem[j].Value;
                                break;
                        }
                    }
                    var key=webim.SESSION_TYPE.C2C+"_"+friend_account;
                    infoMap[key]={
                        'name':friend_name,
                        'image':friend_image
                    };
                }
                if (cbOK)
                    cbOK();
            }
        },
        function (err) {
            alert(err.ErrorInfo);
        }
    );
};


