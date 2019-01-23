//弹出发自定义消息对话框

function showEditCustomMsgDialog() {
    $('#ecm_form')[0].reset();
    $('#edit_custom_msg_dialog').modal('show');
}
//发送自定义消息

function sendCustomMsg() {
    if (!selToID) {
        alert("您还没有好友或群组，暂不能聊天");
        return;
    }
    var data = $("#ecm_data").val();
    var desc = $("#ecm_desc").val();
    var ext = $("#ecm_ext").val();

    var msgLen = webim.Tool.getStrBytes(data);

    if (data.length < 1) {
        alert("发送的消息不能为空!");
        return;
    }
    var maxLen, errInfo;
    if (selType == webim.SESSION_TYPE.C2C) {
        maxLen = webim.MSG_MAX_LENGTH.C2C;
        errInfo = "消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)";
    } else {
        maxLen = webim.MSG_MAX_LENGTH.GROUP;
        errInfo = "消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)";
    }
    if (msgLen > maxLen) {
        alert(errInfo);
        return;
    }

    if (!selSess) {
        selSess = new webim.Session(selType, selToID, selToID, friendHeadUrl, Math.round(new Date().getTime() / 1000));
    }
    var msg = new webim.Msg(selSess, true, -1, -1, -1, loginInfo.identifier, 0, loginInfo.identifierNick);
    var custom_obj = new webim.Msg.Elem.Custom(data, desc, ext);
    msg.addCustom(custom_obj);
    //调用发送消息接口
    msg.sending = 1;
    webim.sendMsg(msg, function(resp) {
        addMsg(msg);
        $("#id_" + msg.random).find(".spinner").remove();
        // if (selType == webim.SESSION_TYPE.C2C) {
        //     //私聊时，在聊天窗口手动添加一条发的消息，群聊时，长轮询接口会返回自己发的消息
        //     addMsg(msg);
        // }
        $('#edit_custom_msg_dialog').modal('hide');
    }, function(err) {
        alert(err.ErrorInfo);
    });
}