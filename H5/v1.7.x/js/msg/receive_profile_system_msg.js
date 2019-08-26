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
 },
 {
 "Tag": "Tag_Profile_IM_Image",//用户头像
 "ValueBytes": "img/image.png"
 }
 ]
 }
 */

function onProfileModifyNotify(notify) {
    webim.Log.info("执行 资料修改 回调：" + JSON.stringify(notify));
    var typeCh = "[资料修改]";
    var profile, account, nick, sex, allowType, content;
    account = notify.Profile_Account;
    content = "帐号：" + account + ", ";
    for (var i in notify.ProfileList) {
        profile = notify.ProfileList[i];
        switch (profile.Tag) {
            case 'Tag_Profile_IM_Nick':
                nick = profile.ValueBytes;
                break;
            case 'Tag_Profile_IM_Gender':
                sex = profile.ValueBytes;
                break;
            case 'Tag_Profile_IM_AllowType':
                allowType = profile.ValueBytes;
                break;
            case 'Tag_Profile_IM_Image':
                image = profile.ValueBytes;
                break;
            default:
                webim.log.error('未知资料字段：' + JSON.stringify(profile));
                break;
        }
    }
    content += "最新资料：【昵称】：" + nick + ",【性别】：" + sex + ",【加好友方式】：" + allowType + ",【修改头像】：" + image;
    addProfileSystemMsg(notify.Type, typeCh, content);

    if (account != loginInfo.identifier) { //如果是好友资料更新
        //好友资料发生变化，需要重新加载好友列表或者单独更新account的资料信息
        //getAllFriend(getAllFriendsCallbackOK);
        if (account && nick) {
            updateSessNameDiv(webim.SESSION_TYPE.C2C, account, nick); //更新最近聊天会话中的好友昵称
        }

    }
}


//初始化我的资料系统消息表格

function initGetMyProfileSystemMsgs(data) {
    $('#get_my_profile_system_msgs_table').bootstrapTable({
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
            field: "Type",
            title: "类型",
            align: "center",
            valign: "middle",
            sortable: "false",
            visible: false
        }, {
            field: "TypeCh",
            title: "类型",
            align: "center",
            valign: "middle",
            sortable: "true"
        }, {
            field: "MsgContent",
            title: "内容",
            align: "center",
            valign: "middle",
            sortable: "true"
        }],
        data: data,
        formatNoMatches: function() {
            return '无符合条件的记录';
        }
    });
}

//查看我的资料系统消息

function getMyProfileSystemMsgs() {
    $('#get_my_profile_system_msgs_dialog').modal('show');
}

//增加一条资料系统消息

function addProfileSystemMsg(type, typeCh, msgContent) {
    var data = [];
    data.push({
        "Type": type,
        "TypeCh": typeCh,
        "MsgContent": webim.Tool.formatText2Html(msgContent)
    });
    $('#get_my_profile_system_msgs_table').bootstrapTable('append', data);
}
