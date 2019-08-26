//点击发送群自定义通知菜单事件
function showSendCustomGroupNotifyDialog() {
    if (selType == webim.SESSION_TYPE.GROUP && selToID) {
        $("#sgsm_group_id").val(selToID);
    }
    $('#send_group_system_msg_dialog').modal('show');
}

//发送自定义群系统通知
var sendCustomGroupNotify = function () {

    var groupId = $("#sgsm_group_id").val();
    var content = $("#sgsm_content").val();

    if (content.length < 1) {
        alert("发送的消息不能为空!");
        return;
    }
    if (webim.Tool.getStrBytes(content) > webim.MSG_MAX_LENGTH.GROUP) {
        alert("消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)");
        return;
    }
    if (groupId.length < 1) {
        alert("群ID不能为空!");
        return;
    }
    //详细参数，请参考链接：http://avc.qcloud.com/wiki2.0/im/%E6%9C%8D%E5%8A%A1%E7%AB%AF%E9%9B%86%E6%88%90/%E7%BE%A4%E7%BB%84%E7%AE%A1%E7%90%86/%E5%9C%A8%E7%BE%A4%E7%BB%84%E4%B8%AD%E5%8F%91%E9%80%81%E7%B3%BB%E7%BB%9F%E9%80%9A%E7%9F%A5/%E5%9C%A8%E7%BE%A4%E7%BB%84%E4%B8%AD%E5%8F%91%E9%80%81%E7%B3%BB%E7%BB%9F%E9%80%9A%E7%9F%A5.html
    var options = {
        'GroupId': groupId,
        'Content': content
    };
    webim.sendCustomGroupNotify(
        options,
        function (resp) {
            $('#send_group_system_msg_dialog').modal('hide');
            alert('发送成功');
        },
        function (err) {
            alert(err.ErrorInfo);
        }
    );
};