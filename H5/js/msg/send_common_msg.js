//发送消息(文本或者表情)

function onSendMsg() {

    if (!selToID) {
        alert("你还没有选中好友或者群组，暂不能聊天");
        $("#send_msg_text").val('');
        return;
    }
    //获取消息内容
    var msgContent = document.getElementsByClassName("msgedit")[0].value;
    var msgLen = webim.Tool.getStrBytes(msgContent);

    if (msgContent.length < 1) {
        alert("发送的消息不能为空!");
        $("#send_msg_text").val('');
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
    //发消息处理
    handleMsgSend(msgContent);
}


function handleMsgSend(msgContent) {
    if (!selSess) {
        var selSess = new webim.Session(selType, selToID, selToID, friendHeadUrl, Math.round(new Date().getTime() / 1000));
    }
    var isSend = true; //是否为自己发送
    var seq = -1; //消息序列，-1表示sdk自动生成，用于去重
    var random = Math.round(Math.random() * 4294967296); //消息随机数，用于去重
    var msgTime = Math.round(new Date().getTime() / 1000); //消息时间戳
    var subType; //消息子类型
    if (selType == webim.SESSION_TYPE.C2C) {
        subType = webim.C2C_MSG_SUB_TYPE.COMMON;
    } else {
        //webim.GROUP_MSG_SUB_TYPE.COMMON-普通消息,
        //webim.GROUP_MSG_SUB_TYPE.LOVEMSG-点赞消息，优先级最低
        //webim.GROUP_MSG_SUB_TYPE.TIP-提示消息(不支持发送，用于区分群消息子类型)，
        //webim.GROUP_MSG_SUB_TYPE.REDPACKET-红包消息，优先级最高
        subType = webim.GROUP_MSG_SUB_TYPE.COMMON;
    }
    var msg = new webim.Msg(selSess, isSend, seq, random, msgTime, loginInfo.identifier, subType, loginInfo.identifierNick);

    var text_obj, face_obj, tmsg, emotionIndex, emotion, restMsgIndex;
    //解析文本和表情
    var expr = /\[[^[\]]{1,3}\]/mg;
    var emotions = msgContent.match(expr);
    if (!emotions || emotions.length < 1) {
        text_obj = new webim.Msg.Elem.Text(msgContent);
        msg.addText(text_obj);
    } else {
        for (var i = 0; i < emotions.length; i++) {
            tmsg = msgContent.substring(0, msgContent.indexOf(emotions[i]));
            if (tmsg) {
                text_obj = new webim.Msg.Elem.Text(tmsg);
                msg.addText(text_obj);
            }
            emotionIndex = webim.EmotionDataIndexs[emotions[i]];
            emotion = webim.Emotions[emotionIndex];

            if (emotion) {
                face_obj = new webim.Msg.Elem.Face(emotionIndex, emotions[i]);
                msg.addFace(face_obj);
            } else {
                text_obj = new webim.Msg.Elem.Text(emotions[i]);
                msg.addText(text_obj);
            }
            restMsgIndex = msgContent.indexOf(emotions[i]) + emotions[i].length;
            msgContent = msgContent.substring(restMsgIndex);
        }
        if (msgContent) {
            text_obj = new webim.Msg.Elem.Text(msgContent);
            msg.addText(text_obj);
        }
    }

    msg.PushInfo = {
        "PushFlag": 0,
        "Desc": '测试离线推送内容', //离线推送内容
        "Ext": '测试离线推送透传内容', //离线推送透传内容
        "AndroidInfo": {
            "Sound": "android.mp3" //离线推送声音文件路径。
        },
        "ApnsInfo": {
            "Sound": "apns.mp3", //离线推送声音文件路径。
            "BadgeMode": 1
        }
    };

    msg.PushInfoBoolean = true; //是否开启离线推送push同步
    msg.sending = 1;
    msg.originContent = msgContent;
    addMsg(msg);
    $("#send_msg_text").val('');
    turnoffFaces_box();

    webim.sendMsg(msg, function(resp) {
        //发送成功，把sending清理
        $("#id_" + msg.random).find(".spinner").remove();
        webim.Tool.setCookie("tmpmsg_" + selToID, '', 0);
    }, function(err) {
        //alert(err.ErrorInfo);
        //提示重发
        showReSend(msg);
    });
}

function showReSend(msg) {
    //resend a dom
    var resendBtn = $('<a href="javascript:;">重发</a>');
    //绑定重发事件
    resendBtn.click(function() {
        //删除当前的dom
        $("#id_" + msg.random).remove();
        //发消息处理
        handleMsgSend(msg.originContent);
    });
    $("#id_" + msg.random).find(".spinner").empty().append(resendBtn);
}


//发送文本框按下键盘事件

function onTextareaKeyDown(event) {
    if (event && event.keyCode == 13) {
        onSendMsg();
    }
}
//关闭聊天界面

function onClose() {
    document.getElementById("webim_demo").style.display = "none";
    //离线
    webim.logout();
}

//打开表情窗体
var showEmotionDialog = function() {
    if (emotionFlag) {
        $('#wl_faces_box').css({
            "display": "block"
        });
        return;
    }
    emotionFlag = true;

    for (var index in webim.Emotions) {
        var emotions = $('<img>').attr({
            "id": webim.Emotions[index][0],
            "src": webim.Emotions[index][1],
            "style": "cursor:pointer;"
        }).click(function() {
            selectEmotionImg(this);
        });
        $('<li>').append(emotions).appendTo($('#emotionUL'));
    }
    $('#wl_faces_box').css({
        "display": "block"
    });
};

//表情选择div的关闭方法
var turnoffFaces_box = function() {
    $("#wl_faces_box").fadeOut("slow");
};
//选中表情
var selectEmotionImg = function(selImg) {
    var txt = document.getElementsByClassName("msgedit")[0];
    txt.value = txt.value + selImg.id;
    txt.focus();
};