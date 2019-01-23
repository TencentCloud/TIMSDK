//获取历史消息(c2c或者group)成功回调函数
//msgList 为消息数组，结构为[Msg]

function getHistoryMsgCallback(msgList, prepage) {
    var msg;
    prepage = prepage || false;

    //如果是加载前几页的消息，消息体需要prepend，所以先倒排一下
    if (prepage) {
        msgList.reverse();
    }

    for (var j in msgList) { //遍历新消息
        msg = msgList[j];
        if (msg.getSession().id() == selToID) { //为当前聊天对象的消息
            selSess = msg.getSession();
            //在聊天窗体中新增一条消息
            addMsg(msg, prepage);
        }
    }
    //消息已读上报，并将当前会话的消息设置成自动已读
    webim.setAutoRead(selSess, true, true);
}

//获取最新的c2c历史消息,用于切换好友聊天，重新拉取好友的聊天消息
var getLastC2CHistoryMsgs = function(cbOk, cbError) {
    if (selType == webim.SESSION_TYPE.GROUP) {
        alert('当前的聊天类型为群聊天，不能进行拉取好友历史消息操作');
        return;
    }
    if (!selToID || selToID == '@TIM#SYSTEM') {
        alert('当前的聊天id非法，selToID=' + selToID);
        return;
    }
    var lastMsgTime = 0; //第一次拉取好友历史消息时，必须传0
    var msgKey = '';
    var options = {
        'Peer_Account': selToID, //好友帐号
        'MaxCnt': reqMsgCount, //拉取消息条数
        'LastMsgTime': lastMsgTime, //最近的消息时间，即从这个时间点向前拉取历史消息
        'MsgKey': msgKey
    };
    selSess = null;
    webim.MsgStore.delSessByTypeId(selType, selToID);


    webim.getC2CHistoryMsgs(
        options,
        function(resp) {
            var complete = resp.Complete; //是否还有历史消息可以拉取，1-表示没有，0-表示有

            if (resp.MsgList.length == 0) {
                webim.Log.warn("没有历史消息了:data=" + JSON.stringify(options));
                return;
            }
            getPrePageC2CHistroyMsgInfoMap[selToID] = { //保留服务器返回的最近消息时间和消息Key,用于下次向前拉取历史消息
                'LastMsgTime': resp.LastMsgTime,
                'MsgKey': resp.MsgKey
            };
            //清空聊天界面
            document.getElementsByClassName("msgflow")[0].innerHTML = "";
            if (cbOk)
                cbOk(resp.MsgList);
        },
        cbError
    );
};

//向上翻页，获取更早的好友历史消息
var getPrePageC2CHistoryMsgs = function(cbOk, cbError) {
    if (selType == webim.SESSION_TYPE.GROUP) {
        alert('当前的聊天类型为群聊天，不能进行拉取好友历史消息操作');
        return;
    }
    var tempInfo = getPrePageC2CHistroyMsgInfoMap[selToID]; //获取下一次拉取的c2c消息时间和消息Key
    var lastMsgTime;
    var msgKey;
    if (tempInfo) {
        lastMsgTime = tempInfo.LastMsgTime;
        msgKey = tempInfo.MsgKey;
    } else {
        alert('获取下一次拉取的c2c消息时间和消息Key为空');
        return;
    }
    var options = {
        'Peer_Account': selToID, //好友帐号
        'MaxCnt': reqMsgCount, //拉取消息条数
        'LastMsgTime': lastMsgTime, //最近的消息时间，即从这个时间点向前拉取历史消息
        'MsgKey': msgKey
    };
    webim.getC2CHistoryMsgs(
        options,
        function(resp) {
            var complete = resp.Complete; //是否还有历史消息可以拉取，1-表示没有，0-表示有
            if (resp.MsgList.length == 0) {
                webim.Log.warn("没有历史消息了:data=" + JSON.stringify(options));
                return;
            }
            getPrePageC2CHistroyMsgInfoMap[selToID] = { //保留服务器返回的最近消息时间和消息Key,用于下次向前拉取历史消息
                'LastMsgTime': resp.LastMsgTime,
                'MsgKey': resp.MsgKey
            };
            if (cbOk) {
                cbOk(resp.MsgList);
            } else {
                getHistoryMsgCallback(resp.MsgList, true);
            }
        },
        cbError
    );
};

//获取最新的群历史消息,用于切换群组聊天时，重新拉取群组的聊天消息
var getLastGroupHistoryMsgs = function(cbOk) {
    if (selType == webim.SESSION_TYPE.C2C) {
        alert('当前的聊天类型为好友聊天，不能进行拉取群历史消息操作');
        return;
    }
    getGroupInfo(selToID, function(resp) {
        //拉取最新的群历史消息
        var options = {
            'GroupId': selToID,
            'ReqMsgSeq': resp.GroupInfo[0].NextMsgSeq - 1,
            'ReqMsgNumber': reqMsgCount
        };
        if (options.ReqMsgSeq == null || options.ReqMsgSeq == undefined || options.ReqMsgSeq <= 0) {
            webim.Log.warn("该群还没有历史消息:options=" + JSON.stringify(options));
            return;
        }
        selSess = null;
        webim.MsgStore.delSessByTypeId(selType, selToID);
        recentSessMap[webim.SESSION_TYPE.GROUP + "_" + selToID] = {};

        recentSessMap[webim.SESSION_TYPE.GROUP + "_" + selToID].MsgGroupReadedSeq = resp.GroupInfo && resp.GroupInfo[0] && resp.GroupInfo[0].MsgSeq;
        webim.syncGroupMsgs(
            options,
            function(msgList) {
                if (msgList.length == 0) {
                    webim.Log.warn("该群没有历史消息了:options=" + JSON.stringify(options));
                    return;
                }
                var msgSeq = msgList[0].seq - 1;
                getPrePageGroupHistroyMsgInfoMap[selToID] = {
                    "ReqMsgSeq": msgSeq
                };
                //清空聊天界面
                document.getElementsByClassName("msgflow")[0].innerHTML = "";
                if (cbOk)
                    cbOk(msgList);
            },
            function(err) {
                alert(err.ErrorInfo);
            }
        );
    });
};

//向上翻页，获取更早的群历史消息
var getPrePageGroupHistoryMsgs = function(cbOk) {
    if (selType == webim.SESSION_TYPE.C2C) {
        alert('当前的聊天类型为好友聊天，不能进行拉取群历史消息操作');
        return;
    }
    var tempInfo = getPrePageGroupHistroyMsgInfoMap[selToID]; //获取下一次拉取的群消息seq
    var reqMsgSeq;
    if (tempInfo) {
        reqMsgSeq = tempInfo.ReqMsgSeq;
        if (reqMsgSeq <= 0) {
            webim.Log.warn('该群没有历史消息可拉取了');
            return;
        }
    } else {
        webim.Log.error('获取下一次拉取的群消息seq为空');
        return;
    }
    var options = {
        'GroupId': selToID,
        'ReqMsgSeq': reqMsgSeq,
        'ReqMsgNumber': reqMsgCount
    };

    webim.syncGroupMsgs(
        options,
        function(msgList) {
            if (msgList.length == 0) {
                webim.Log.warn("该群没有历史消息了:options=" + JSON.stringify(options));
                return;
            }
            var msgSeq = msgList[0].seq - 1;
            getPrePageGroupHistroyMsgInfoMap[selToID] = {
                "ReqMsgSeq": msgSeq
            };

            if (cbOk) {
                cbOk(msgList);
            } else {
                getHistoryMsgCallback(msgList, true);
            }
        },
        function(err) {
            alert(err.ErrorInfo);
        }
    );
};