//更新最近会话的未读消息数

function updateSessDiv(sess_type, to_id, name, unread_msg_count) {
    var badgeDiv = document.getElementById("badgeDiv_" + to_id);
    if (badgeDiv && unread_msg_count > 0) {
        if (unread_msg_count >= 100) {
            unread_msg_count = '99+';
        }
        badgeDiv.innerHTML = "<span>" + unread_msg_count + "</span>";
        badgeDiv.style.display = "block";
    } else if (badgeDiv == null) { //没有找到对应的聊天id
        var headUrl;
        if (sess_type == webim.SESSION_TYPE.C2C) {
            headUrl = friendHeadUrl;
        } else {
            headUrl = groupHeadUrl;
        }
        addSess(sess_type, to_id, name, headUrl, unread_msg_count, 'sesslist');
    }
}

//新增一条最近会话

function addSess(sess_type, to_id, name, face_url, unread_msg_count, sesslist, addPositonType) {
    var sessDivId = "sessDiv_" + to_id;
    var sessDiv = document.getElementById(sessDivId);
    if (sessDiv) { //先判断是否存在会话DIV，已经存在，则不需要增加
        return;
    }
    var sessList = document.getElementsByClassName(sesslist)[0];
    sessDiv = document.createElement("div");
    sessDiv.id = sessDivId;
    //如果当前选中的用户是最后一个用户
    sessDiv.className = "sessinfo";
    //添加单击用户头像事件
    sessDiv.onclick = function() {
        if (sessDiv.className == "sessinfo-sel") return;
        onSelSess(sess_type, to_id);
    };
    var faceImg = document.createElement("img");
    faceImg.id = "faceImg_" + to_id;
    faceImg.className = "face";
    faceImg.src = face_url;

    if (name.length > maxNameLen) { //名称过长，截取一部分
        name = name.substr(0, maxNameLen) + "...";
    }

    var delchat = document.createElement("div");
    delchat.className = 'delChat';
    delchat.innerHTML = '删除会话';
    delchat.onclick = function(e) {
        var selSess = webim.MsgStore.sessByTypeId(sess_type, to_id)
        if (sess_type == 'C2C') {
            sess_type = 1;
            webim.setAutoRead(selSess, true, false)
        } else {
            sess_type = 2;
            webim.groupMsgReaded({
                "GroupId": to_id,
                "MsgReadedSeq": selSess._impl.curMaxMsgSeq
            })
        }
        delChat(sess_type, to_id);
        e.preventDefault()
        e.stopPropagation()
        return false;
    }

    var nameDiv = document.createElement("div");
    nameDiv.id = "nameDiv_" + to_id;
    nameDiv.className = "name";
    nameDiv.innerHTML = name;
    var badgeDiv = document.createElement("div");
    badgeDiv.id = "badgeDiv_" + to_id;
    badgeDiv.className = "badge";
    if (unread_msg_count > 0) {
        if (unread_msg_count >= 100) {
            unread_msg_count = '99+';
        }
        badgeDiv.innerHTML = "<span>" + unread_msg_count + "</span>";
        badgeDiv.style.display = "block";
    }
    sessDiv.appendChild(faceImg);
    sessDiv.appendChild(nameDiv);
    sessDiv.appendChild(badgeDiv);
    sessDiv.appendChild(delchat);
    if (!addPositonType || addPositonType == 'TAIL') {
        sessList.appendChild(sessDiv); //默认插入尾部
    } else if (addPositonType == 'HEAD') {
        sessList.insertBefore(sessDiv); //插入头部
    } else {
        console.log(webim.Log.error('未知addPositonType' + addPositonType));
    }
}

//删除会话

function delChat(sess_type, to_id) {

    var data = {
        'To_Account': to_id,
        'chatType': sess_type
    }
    webim.deleteChat(
        data,
        function(resp) {
            $("#sessDiv_" + to_id).remove();
        }
    );
}

//切换好友或群组聊天对象

function onSelSess(sess_type, to_id) {
    if (selToID != null) {

        //将之前选中用户的样式置为未选中样式
        setSelSessStyleOff(selToID);

        //设置之前会话的已读消息标记
        webim.setAutoRead(selSess, false, false);

        //保存当前的消息输入框内容到草稿
        //获取消息内容
        var msgtosend = document.getElementsByClassName("msgedit")[0].value;
        var msgLen = webim.Tool.getStrBytes(msgtosend);
        if (msgLen > 0) {
            webim.Tool.setCookie("tmpmsg_" + selToID, msgtosend, 3600);
        }

        //清空聊天界面
        document.getElementsByClassName("msgflow")[0].innerHTML = "";

        selToID = to_id;
        //设置当前选中用户的样式为选中样式
        setSelSessStyleOn(to_id);

        var tmgmsgtosend = webim.Tool.getCookie("tmpmsg_" + selToID);
        if (tmgmsgtosend) {
            $("#send_msg_text").val(tmgmsgtosend);
        } else {
            $("#send_msg_text").val('');
        }

        bindScrollHistoryEvent.reset();


        var sessMap = webim.MsgStore.sessMap(); //获取到之前已经保存的消息
        var sessCS = webim.SESSION_TYPE.GROUP + selToID;
        if (sessMap && sessMap[sessCS]) { //判断之前是否保存过消息
            selType = webim.SESSION_TYPE.GROUP
            bindScrollHistoryEvent.init();

            function compare(property) {
                return function(a, b) {
                    var value1 = a[property];
                    var value2 = b[property];
                    return value1 - value2;
                }
            }
            var sessMapOld = sessMap[sessCS]._impl.msgs.sort(compare('time'));

            for (var i = 0; i < sessMapOld.length; i++) {
                addMsg(sessMapOld[i]); //显示已经保存的消息
            }
        } else {
            if (sess_type == webim.SESSION_TYPE.GROUP) {
                if (selType == webim.SESSION_TYPE.C2C) {
                    selType = webim.SESSION_TYPE.GROUP;
                }
                selSess = null;
                webim.MsgStore.delSessByTypeId(selType, selToID);

                getLastGroupHistoryMsgs(function(msgList) {
                    getHistoryMsgCallback(msgList);
                    bindScrollHistoryEvent.init();
                }, function(err) {
                    alert(err.ErrorInfo);
                });

            } else {
                if (selType == webim.SESSION_TYPE.GROUP) {
                    selType = webim.SESSION_TYPE.C2C;
                }
                //如果是管理员账号，则为全员推送，没有历史消息
                if (selToID == AdminAcount) {
                    var sess = webim.MsgStore.sessByTypeId(selType, selToID);
                    if (sess && sess.msgs() && sess.msgs().length > 0) {
                        getHistoryMsgCallback(sess.msgs());
                    } else {
                        getLastC2CHistoryMsgs(function(msgList) {
                            getHistoryMsgCallback(msgList);
                            bindScrollHistoryEvent.init();
                        }, function(err) {
                            alert(err.ErrorInfo);
                        });
                    }
                    return;
                }

                //拉取漫游消息
                getLastC2CHistoryMsgs(function(msgList) {
                    getHistoryMsgCallback(msgList);
                    //绑定滚动操作
                    bindScrollHistoryEvent.init();
                }, function(err) {
                    alert(err.ErrorInfo);
                });
            }
        }
    }
}

//删除会话

function deleteSessDiv(sess_type, to_id) {
    var sessDiv = document.getElementById("sessDiv_" + to_id);
    sessDiv && sessDiv.parentNode.removeChild(sessDiv);
}


//更新最近会话的名字

function updateSessNameDiv(sess_type, to_id, newName) {

    var nameDivId = "nameDiv_" + to_id;
    var nameDiv = document.getElementById(nameDivId);
    if (nameDiv) {
        if (newName.length > maxNameLen) { //帐号或昵称过长，截取一部分
            newName = newName.substr(0, maxNameLen) + "...";
        }
        nameDiv.innerHTML = webim.Tool.formatText2Html(newName);
    }
}

//更新最近会话的头像

function updateSessImageDiv(sess_type, to_id, newImageUrl) {
    if (!newImageUrl) {
        return;
    }
    var faceImageId = "faceImg_" + to_id;
    var faceImage = document.getElementById(faceImageId);
    if (faceImage) {
        faceImage.innerHTML = webim.Tool.formatText2Html(newImageUrl);
    }
}

function setSelSessStyleOn(newSelToID) {

    var selSessDiv = document.getElementById("sessDiv_" + newSelToID);
    if (selSessDiv) {
        selSessDiv.className = "sessinfo-sel"; //设置当前选中用户的样式为选中样式
    } else {
        webim.Log.warn("不存在selSessDiv: selSessDivId=" + "sessDiv_" + newSelToID);
    }

    var selBadgeDiv = document.getElementById("badgeDiv_" + newSelToID);
    if (selBadgeDiv) {
        selBadgeDiv.style.display = "none";
    } else {
        webim.Log.warn("不存在selBadgeDiv: selBadgeDivId=" + "badgeDiv_" + selToID);
    }
}

function setSelSessStyleOff(preSelToId) {
    var preSessDiv = document.getElementById("sessDiv_" + preSelToId);
    if (preSessDiv) {
        preSessDiv.className = "sessinfo"; //将之前选中用户的样式置为未选中样式
    } else {
        webim.Log.warn("不存在preSessDiv: selSessDivId=" + "sessDiv_" + preSelToId);
    }
}