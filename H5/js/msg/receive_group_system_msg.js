//监听 申请加群 系统消息

function onApplyJoinGroupRequestNotify(notify) {
    webim.Log.info("执行 加群申请 回调：" + JSON.stringify(notify));
    var data = [];
    var timestamp = notify.MsgTime;
    notify.MsgTimeStamp = timestamp;
    notify.MsgTime = webim.Tool.formatTimeStamp(notify.MsgTime);
    data.push(notify);
    $('#get_apply_join_group_pendency_table').bootstrapTable('append', data);
    $('#get_apply_join_group_pendency_dialog').modal('show');

    var reportTypeCh = "[申请加群]";
    var content = notify.Operator_Account + "申请加入你的群";
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, timestamp);
}

//监听 申请加群被同意 系统消息

function onApplyJoinGroupAcceptNotify(notify) {
    webim.Log.info("执行 申请加群被同意 回调：" + JSON.stringify(notify));
    //刷新我的群组列表
    //getJoinedGroupListHigh(getGroupsCallbackOK);

    var reportTypeCh = "[申请加群被同意]";
    var content = notify.Operator_Account + "同意你的加群申请，附言：" + notify.RemarkInfo;
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);

}
//监听 申请加群被拒绝 系统消息

function onApplyJoinGroupRefuseNotify(notify) {
    webim.Log.info("执行 申请加群被拒绝 回调：" + JSON.stringify(notify));
    var reportTypeCh = "[申请加群被拒绝]";
    var content = notify.Operator_Account + "拒绝了你的加群申请，附言：" + notify.RemarkInfo;
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
//监听 被踢出群 系统消息

function onKickedGroupNotify(notify) {
    webim.Log.info("执行 被踢出群  回调：" + JSON.stringify(notify));
    //刷新我的群组列表
    //getJoinedGroupListHigh(getGroupsCallbackOK);
    deleteSessDiv(webim.SESSION_TYPE.GROUP, notify.GroupId); //在最近的联系人列表删除可能存在的群会话
    var reportTypeCh = "[被踢出群]";
    var content = "你被管理员" + notify.Operator_Account + "踢出该群";
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
//监听 解散群 系统消息

function onDestoryGroupNotify(notify) {
    webim.Log.info("执行 解散群 回调：" + JSON.stringify(notify));
    //刷新我的群组列表
    //getJoinedGroupListHigh(getGroupsCallbackOK);
    deleteSessDiv(webim.SESSION_TYPE.GROUP, notify.GroupId); //在最近的联系人列表删除可能存在的群会话
    var reportTypeCh = "[群被解散]";
    var content = "群主" + notify.Operator_Account + "已解散该群";
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
//监听 创建群 系统消息

function onCreateGroupNotify(notify) {
    webim.Log.info("执行 创建群 回调：" + JSON.stringify(notify));
    var reportTypeCh = "[创建群]";
    var content = "你创建了该群";
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
//监听 被邀请加群 系统消息

function onInvitedJoinGroupNotify(notify) {
    webim.Log.info("执行 被邀请加群  回调: " + JSON.stringify(notify));
    //刷新我的群组列表
    //getJoinedGroupListHigh(getGroupsCallbackOK);
    var reportTypeCh = "[被邀请加群]";
    var content = "你被管理员" + notify.Operator_Account + "邀请加入该群";
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}

//监听 被邀请加群(用户需要同意) 系统消息

function onInvitedJoinGroupNotifyRequest(notify) {
    var timestamp = notify.MsgTime;
    var data = [];
    notify.MsgTimeStamp = timestamp;
    notify.MsgTime = webim.Tool.formatTimeStamp(notify.MsgTime);
    data.push(notify);
    $('#get_apply_join_group_pendency_table').bootstrapTable('append', data);
    $('#get_apply_join_group_pendency_dialog').modal('show');
    addGroupSystemMsg(notify.ReportType, notify.GroupId, notify.GroupName, timestamp);
}

//监听 主动退群 系统消息

function onQuitGroupNotify(notify) {
    webim.Log.info("执行 主动退群  回调： " + JSON.stringify(notify));
    deleteSessDiv(webim.SESSION_TYPE.GROUP, notify.GroupId); //在最近的联系人列表删除可能存在的群会话
    var reportTypeCh = "[主动退群]";
    var content = "你退出了该群";
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
//监听 被设置为管理员 系统消息

function onSetedGroupAdminNotify(notify) {
    webim.Log.info("执行 被设置为管理员  回调：" + JSON.stringify(notify));
    var reportTypeCh = "[被设置为管理员]";
    var content = "你被群主" + notify.Operator_Account + "设置为管理员";
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
//监听 被取消管理员 系统消息

function onCanceledGroupAdminNotify(notify) {
    webim.Log.info("执行 被取消管理员 回调：" + JSON.stringify(notify));
    var reportTypeCh = "[被取消管理员]";
    var content = "你被群主" + notify.Operator_Account + "取消了管理员资格";
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
//监听 群被回收 系统消息

function onRevokeGroupNotify(notify) {
    webim.Log.info("执行 群被回收 回调：" + JSON.stringify(notify));
    //刷新我的群组列表
    //getJoinedGroupListHigh(getGroupsCallbackOK);
    deleteSessDiv(webim.SESSION_TYPE.GROUP, notify.GroupId); //在最近的联系人列表删除可能存在的群会话
    var reportTypeCh = "[群被回收]";
    var content = "该群已被回收";
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}
//监听 用户自定义 群系统消息

function onCustomGroupNotify(notify) {
    webim.Log.info("执行 用户自定义系统消息 回调：" + JSON.stringify(notify));
    var reportTypeCh = "[用户自定义系统消息]";
    var content = notify.UserDefinedField; //群自定义消息数据
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}

//监听 群资料变化 群提示消息

function onGroupInfoChangeNotify(notify) {
    webim.Log.info("执行 群资料变化 回调： " + JSON.stringify(notify));
    var groupId = notify.GroupId;
    var newFaceUrl = notify.GroupFaceUrl; //新群组图标, 为空，则表示没有变化
    var newName = notify.GroupName; //新群名称, 为空，则表示没有变化
    var newOwner = notify.OwnerAccount; //新的群主id, 为空，则表示没有变化
    var newNotification = notify.GroupNotification; //新的群公告, 为空，则表示没有变化
    var newIntroduction = notify.GroupIntroduction; //新的群简介, 为空，则表示没有变化

    if (newName) {
        updateSessNameDiv(webim.SESSION_TYPE.GROUP, groupId, newName);
    }
    if (newFaceUrl) {
        updateSessImageDiv(webim.SESSION_TYPE.GROUP, groupId, newFaceUrl);
    }
}

function onCustomGroupNotify(notify) {
    webim.Log.info("执行 用户自定义系统消息 回调：" + JSON.stringify(notify));
    var reportTypeCh = "[用户自定义系统消息]";
    var content = notify.UserDefinedField; //群自定义消息数据
    addGroupSystemMsg(notify.ReportType, reportTypeCh, notify.GroupId, notify.GroupName, content, notify.MsgTime);
}

//已读消息同步
//告诉你哪个类型的那个群组已读消息的情况

function onReadedSyncGroupNotify(notify) {
    var seq = notify.LastReadMsgSeq;
    //更新当前的seq
    var currentUnRead = recentSessMap[webim.SESSION_TYPE.GROUP + "_" + notify.GroupId].MsgGroupReadedSeq;
    var unread = currentUnRead - seq;
    unread = unread > 0 ? unread : 0;
    recentSessMap[webim.SESSION_TYPE.GROUP + "_" + notify.GroupId].MsgGroupReadedSeq = seq;


    //更新未读数
    var sess = webim.MsgStore.sessByTypeId(webim.SESSION_TYPE.GROUP, notify.GroupId);
    sess.unread(unread);

    webim.Log.info("群消息同步的回调:已读消息情况 ## 未读数：GroupId:[" + notify.GroupId + "]:" + unread, currentUnRead, seq);
    if (unread > 0) {
        $(document.getElementById("badgeDiv_" + notify.GroupId)).text(unread).show();
    } else {
        $(document.getElementById("badgeDiv_" + notify.GroupId)).val("").hide();
    }
}

//初始化我的群组系统消息表格

function initGetMyGroupSystemMsgs(data) {
    $('#get_my_group_system_msgs_table').bootstrapTable({
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
            field: "ReportType",
            title: "类型",
            align: "center",
            valign: "middle",
            sortable: "false",
            visible: false
        }, {
            field: "ReportTypeCh",
            title: "类型",
            align: "center",
            valign: "middle",
            sortable: "true"
        }, {
            field: "GroupId",
            title: "群ID",
            align: "center",
            valign: "middle",
            sortable: "true"
        }, {
            field: "GroupName",
            title: "群名称",
            align: "center",
            valign: "middle",
            sortable: "true"
        }, {
            field: "MsgContent",
            title: "内容",
            align: "center",
            valign: "middle",
            sortable: "true"
        }, {
            field: "MsgTime",
            title: "时间",
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

//查看我的群组系统消息
var getMyGroupSystemMsgs = function() {
    $('#get_my_group_system_msgs_dialog').modal('show');
};

//增加一条群组系统消息

function addGroupSystemMsg(type, typeCh, group_id, group_name, msg_content, msg_time) {
    var data = [];
    data.push({
        "ReportType": type,
        "ReportTypeCh": typeCh,
        "GroupId": webim.Tool.formatText2Html(group_id),
        "GroupName": webim.Tool.formatText2Html(group_name),
        "MsgContent": webim.Tool.formatText2Html(msg_content),
        "MsgTime": webim.Tool.formatTimeStamp(msg_time)
    });
    $('#get_my_group_system_msgs_table').bootstrapTable('append', data);
    //$('#get_my_group_system_msgs_dialog').modal('show');
}