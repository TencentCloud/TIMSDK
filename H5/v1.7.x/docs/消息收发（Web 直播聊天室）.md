
目前支持实时拉取群消息（普通、点赞、提示和系统）和发送群消息（普通、点赞和红包）。

## 监听群消息（普通、点赞、提示和红包）

>!若已调用 [setProfilePortrait 接口](https://cloud.tencent.com/document/product/269/1599#.E8.AE.BE.E7.BD.AE.E4.B8.AA.E4.BA.BA.E8.B5.84.E6.96.99) 设置用户资料，直播群中会自动下发用户资料。

示例代码如下：

```javascript
//监听大群新消息（普通，点赞，提示，红包）
function onBigGroupMsgNotify(msgList) {
    for (var i = msgList.length - 1; i >= 0; i--) {//遍历消息，按照时间从后往前
        var msg = msgList[i];
        webim.Log.error('receive a new group msg: ' + msg.getFromAccountNick());
        //显示收到的消息
        showMsg(msg);
    }
}
```

## 显示群消息（普通、点赞、提示和红包）

示例代码如下：

```javascript
//显示消息（群普通+点赞+提示+红包）
function showMsg(msg) {
    var isSelfSend, fromAccount, fromAccountNick, sessType, subType;
    var ul, li, paneDiv, textDiv, nickNameSpan, contentSpan;
    fromAccount = msg.getFromAccount();
    if (!fromAccount) {
        fromAccount = '';
    }
    fromAccountNick = msg.getFromAccountNick();
    if (!fromAccountNick) {
        fromAccountNick = '未知用户';
    }
    ul = document.getElementById("video_sms_list");
    var maxDisplayMsgCount = 4;
    //var opacityStep=(1.0/4).toFixed(2);
    var opacityStep = 0.2;
    var opacity;
    var childrenLiList = $("#video_sms_list").children();
    if (childrenLiList.length == maxDisplayMsgCount) {
        $("#video_sms_list").children(":first").remove();
        for (var i = 0; i < maxDisplayMsgCount; i++) {
            opacity = opacityStep * (i + 1) + 0.2;
            $('#video_sms_list').children().eq(i).css("opacity", opacity);
        }
    }
    li = document.createElement("li");
    paneDiv = document.createElement("div");
    paneDiv.setAttribute('class', 'video-sms-pane');
    textDiv = document.createElement("div");
    textDiv.setAttribute('class', 'video-sms-text');
    nickNameSpan = document.createElement("span");
    var colorList = ['red', 'green', 'blue', 'org'];
    var index = Math.round(fromAccount.length % colorList.length);
    var color = colorList[index];
    nickNameSpan.setAttribute('class', 'user-name-' + color);
    nickNameSpan.innerHTML = fromAccountNick;
    contentSpan = document.createElement("span");
    //解析消息
    //获取会话类型，目前只支持群聊
    //webim.SESSION_TYPE.GROUP-群聊，
    //webim.SESSION_TYPE.C2C-私聊，
    sessType = msg.getSession().type();
    //获取消息子类型
    //会话类型为群聊时，子类型为：webim.GROUP_MSG_SUB_TYPE
    //会话类型为私聊时，子类型为：webim.C2C_MSG_SUB_TYPE
    subType = msg.getSubType();
    isSelfSend = msg.getIsSend();//消息是否为自己发的
    switch (subType) {
        case webim.GROUP_MSG_SUB_TYPE.COMMON://群普通消息
            contentSpan.innerHTML = convertMsgtoHtml(msg);
            break;
        case webim.GROUP_MSG_SUB_TYPE.REDPACKET://群红包消息
            contentSpan.innerHTML = "[群红包消息]" + convertMsgtoHtml(msg);
            break;
        case webim.GROUP_MSG_SUB_TYPE.LOVEMSG://群点赞消息
            //业务自己可以增加逻辑，例如展示点赞动画效果
            contentSpan.innerHTML = "[群点赞消息]" + convertMsgtoHtml(msg);
            //展示点赞动画
            showLoveMsgAnimation();
            break;
        case webim.GROUP_MSG_SUB_TYPE.TIP://群提示消息
            contentSpan.innerHTML = "[群提示消息]" + convertMsgtoHtml(msg);
            break;
    }
    textDiv.appendChild(nickNameSpan);
    textDiv.appendChild(contentSpan);
    paneDiv.appendChild(textDiv);
    li.appendChild(paneDiv);
    ul.appendChild(li);
}
```

## 解析群消息（普通、点赞、提示和红包）

示例代码如下：

```
//把消息转换成 HTML
function convertMsgtoHtml(msg) {
    var html = "", elems,elem, type, content;
    elems=msg.getElems();//获取消息包含的元素数组
    for (var i in elems) {
        elem = elems[i];
        type = elem.getType();//获取元素类型
        content = elem.getContent();//获取元素对象
        switch (type) {
            case webim.MSG_ELEMENT_TYPE.TEXT:
                html += convertTextMsgToHtml(content);
                break;
            case webim.MSG_ELEMENT_TYPE.FACE:
                html += convertFaceMsgToHtml(content);
                break;
            case webim.MSG_ELEMENT_TYPE.IMAGE:
                html += convertImageMsgToHtml(content);
                break;
            case webim.MSG_ELEMENT_TYPE.SOUND:
                html += convertSoundMsgToHtml(content);
                break;
            case webim.MSG_ELEMENT_TYPE.FILE:
                html += convertFileMsgToHtml(content);
                break;
            case webim.MSG_ELEMENT_TYPE.LOCATION://暂不支持地理位置
                //html += convertLocationMsgToHtml(content);
                break;
            case webim.MSG_ELEMENT_TYPE.CUSTOM:
                html += convertCustomMsgToHtml(content);
                break;
            case webim.MSG_ELEMENT_TYPE.GROUP_TIP:
                html += convertGroupTipMsgToHtml(content);
                break;
            default:
                webim.Log.error('未知消息元素类型: elemType=' + type);
                break;
        }
    }
    return html;
}
```

## 解析文本消息元素

示例代码如下：

```
//解析文本消息元素
function convertTextMsgToHtml(content) {
    return content.getText();
}
```


## 解析表情消息元素

示例代码如下：

```
//解析表情消息元素
function convertFaceMsgToHtml(content) {
    var index = content.getIndex();
    var data = content.getData();
    var url=null;
    var emotion=webim.Emotions[index];
    if(emotion && emotion[1]){
        url=emotion[1];
    }
    if (url) {
        return	"<img src='" + url + "'/>";
    } else {
        return data;
    }
}
```

## 解析图片消息元素

示例代码如下：

```
//解析图片消息元素
function convertImageMsgToHtml(content) {
    var smallImage = content.getImage(webim.IMAGE_TYPE.SMALL);//小图
    var bigImage = content.getImage(webim.IMAGE_TYPE.LARGE);//大图
    var oriImage = content.getImage(webim.IMAGE_TYPE.ORIGIN);//原图
    if (!bigImage) {
        bigImage = smallImage;
    }
    if (!oriImage) {
        oriImage = smallImage;
    }
    return	"<img src='" + smallImage.getUrl() + "#" + bigImage.getUrl() + "#" + oriImage.getUrl() + "' style='CURSOR: hand' id='" + content.getImageId() + "' bigImgUrl='" + bigImage.getUrl() + "' onclick='imageClick(this)' />";
}
```

## 解析语音消息元素

示例代码如下：

```
//解析语音消息元素
function convertSoundMsgToHtml(content) {
    var second=content.getSecond();//获取语音时长
    var downUrl=content.getDownUrl();
    if (webim.BROWSER_INFO.type == 'ie' && parseInt(webim.BROWSER_INFO.ver) <= 8) {
        return '[这是一条语音消息]demo暂不支持ie8(含)以下浏览器播放语音,语音URL:' + downUrl;
    }
    return '<audio src="' + downUrl + '" controls="controls" onplay="onChangePlayAudio(this)" preload="none"></audio>';
}
```

## 解析文件消息元素

示例代码如下：

```
//解析文件消息元素
function convertFileMsgToHtml(content) {
    var fileSize = Math.round(content.getSize() / 1024);
    return '<a href="' + content.getDownUrl() + '" title="单击下载文件" ><i class="glyphicon glyphicon-file">&nbsp;' + content.getName() + '(' + fileSize + 'KB)</i></a>';
}
```

## 解析位置消息元素

示例代码如下：

```
//解析位置消息元素
function convertLocationMsgToHtml(content) {
    return '经度='+content.getLongitude()+',纬度='+content.getLatitude()+',描述='+content.getDesc();
}
```

## 解析自定义消息元素

示例代码如下：

```
//解析自定义消息元素
function convertCustomMsgToHtml(content) {
    var data = content.getData();
    var desc = content.getDesc();
    var ext = content.getExt();
    return "data=" + data + ", desc=" + desc + ", ext=" + ext;
}
```

## 解析群提示消息元素

当有用户被邀请加入群组，或者有用户被移出群组时，群内会产生有提示消息，调用方可以根据需要选择是否展示给群组用户。

示例代码如下：

```javascript
//解析群提示消息元素
function convertGroupTipMsgToHtml(content) {
    var WEB_IM_GROUP_TIP_MAX_USER_COUNT=10;
    var text ="";
    var maxIndex = WEB_IM_GROUP_TIP_MAX_USER_COUNT - 1;
    var opType,opUserId,userIdList;
    opType=content.getOpType();//群提示消息类型（操作类型）
    opUserId=content.getOpUserId();//操作人 ID
    switch (opType) {
        case webim.GROUP_TIP_TYPE.JOIN://加入群
            userIdList=content.getUserIdList();
            //text += opUserId + "邀请了";
            for (var m in userIdList) {
                text += userIdList[m] + ",";
                if (userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                    text += "等" + userIdList.length + "人";
                    break;
                }
            }
            text += "加入该群";
            break;
        case webim.GROUP_TIP_TYPE.QUIT://退出群
            text += opUserId + "主动退出该群";
            break;
        case webim.GROUP_TIP_TYPE.KICK://踢出群
            text += opUserId + "将";
            userIdList=content.getUserIdList();
            for (var m in userIdList) {
                text += userIdList[m] + ",";
                if (userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                    text += "等" + userIdList.length + "人";
                    break;
                }
            }
            text += "踢出该群";
            break;
        case webim.GROUP_TIP_TYPE.SET_ADMIN://设置管理员
            text += opUserId + "将";
            userIdList=content.getUserIdList();
            for (var m in userIdList) {
                text += userIdList[m] + ",";
                if (userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                    text += "等" + userIdList.length + "人";
                    break;
                }
            }
            text += "设为管理员";
            break;
        case webim.GROUP_TIP_TYPE.CANCEL_ADMIN://取消管理员
            text += opUserId + "取消";
            userIdList=content.getUserIdList();
            for (var m in userIdList) {
                text += userIdList[m] + ",";
                if (userIdList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                    text += "等" + userIdList.length + "人";
                    break;
                }
            }
            text += "的管理员资格";
            break;
        case webim.GROUP_TIP_TYPE.MODIFY_GROUP_INFO://群资料变更
            text += opUserId + "修改了群资料：";
            var groupInfoList=content.getGroupInfoList();
            var type,value;
            for (var m in groupInfoList) {
                type = groupInfoList[m].getType();
                value = groupInfoList[m].getValue();
                switch (type) {
                    case webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE.FACE_URL:
                        text += "群头像为" + value + "; ";
                        break;
                    case webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NAME:
                        text += "群名称为" + value + "; ";
                        break;
                    case webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE.OWNER:
                        text += "群主为" + value + "; ";
                        break;
                    case webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NOTIFICATION:
                        text += "群公告为" + value + "; ";
                        break;
                    case webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE.INTRODUCTION:
                        text += "群简介为" + value + "; ";
                        break;
                    default:
                        text += "未知信息为:type=" + type + ",value=" + value + "; ";
                        break;
                }
            }
            break;
        case webim.GROUP_TIP_TYPE.MODIFY_MEMBER_INFO://群成员资料变更(禁言时间)
            text += opUserId + "修改了群成员资料:";
            var memberInfoList=content.getMemberInfoList();
            var userId,shutupTime;
            for (var m in memberInfoList) {
                userId = memberInfoList[m].getUserId();
                shutupTime = memberInfoList[m].getShutupTime();
                text += userId + ": ";
                if (shutupTime != null && shutupTime !== undefined) {
                    if (shutupTime == 0) {
                        text += "取消禁言; ";
                    } else {
                        text += "禁言" + shutupTime + "秒; ";
                    }
                } else {
                    text += " shutupTime为空";
                }
                if (memberInfoList.length > WEB_IM_GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                    text += "等" + memberInfoList.length + "人";
                    break;
                }
            }
            break;
        default:
            text += "未知群提示消息类型：type=" + opType;
            break;
    }
    return text;
}
```

## 发送群消息（普通）

**`sendMsg` 函数名：**

```javascript
webim.sendMsg
```

**定义：**

```javascript
webim.sendMsg(msg,cbOk, cbErr)
```

**参数列表：**

| 名称    | 说明         | 类型        |
| ----- | ---------- | --------- |
| msg   | 消息对象       | webim.Msg |
| cbOk  | 调用接口成功回调函数 | Function  |
| cbErr | 调用接口失败回调函数 | Function  |

**示例：**

```javascript
	//发送消息(普通消息)
function onSendMsg() {
    if (!loginInfo.identifier) {//未登录
        return;
    }
    // selToID 为全局变量，表示当前正在进行的聊天 ID，当聊天类型为私聊时，该值为好友帐号，否则为群号。
    if (!selToID) {
        alert("您还没有进入房间，暂不能聊天");
        $("#send_msg_text").val('');
        return;
    }
    //获取消息内容
    var msgtosend = $("#send_msg_text").val();
    var msgLen = webim.Tool.getStrBytes(msgtosend);
    if (msgtosend.length < 1) {
        alert("发送的消息不能为空!");
        return;
    }
    var maxLen, errInfo;
    if (selType == webim.SESSION_TYPE.GROUP) {
        maxLen = webim.MSG_MAX_LENGTH.GROUP;
        errInfo = "消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)";
    } else {
        maxLen = webim.MSG_MAX_LENGTH.C2C;
        errInfo = "消息长度超出限制(最多" + Math.round(maxLen / 3) + "汉字)";
    }
    if (msgLen > maxLen) {
        alert(errInfo);
        return;
    }
    if (!selSess) {
        selSess = new webim.Session(selType, selToID, selToID, selSessHeadUrl, Math.round(new Date().getTime() / 1000));
    }
    var isSend = true;//是否为自己发送
    var seq = -1;//消息序列，-1表示 IM SDK 自动生成，用于去重
    var random = Math.round(Math.random() * 4294967296);//消息随机数，用于去重
    var msgTime = Math.round(new Date().getTime() / 1000);//消息时间戳
    var subType;//消息子类型
    if (selType == webim.SESSION_TYPE.GROUP) {
        //群消息子类型如下：
        //webim.GROUP_MSG_SUB_TYPE.COMMON-普通消息,
        //webim.GROUP_MSG_SUB_TYPE.LOVEMSG-点赞消息，优先级最低
        //webim.GROUP_MSG_SUB_TYPE.TIP-提示消息(不支持发送，用于区分群消息子类型)，
        //webim.GROUP_MSG_SUB_TYPE.REDPACKET-红包消息，优先级最高
        subType = webim.GROUP_MSG_SUB_TYPE.COMMON;
    } else {
        //C2C消息子类型如下：
        //webim.C2C_MSG_SUB_TYPE.COMMON-普通消息,
        subType = webim.C2C_MSG_SUB_TYPE.COMMON;
    }
    var msg = new webim.Msg(selSess, isSend, seq, random, msgTime, loginInfo.identifier, subType, loginInfo.identifierNick);
    //解析文本和表情
    var expr = /\[[^[\]]{1,3}\]/mg;
    var emotions = msgtosend.match(expr);
    var text_obj, face_obj, tmsg, emotionIndex, emotion, restMsgIndex;
    if (!emotions || emotions.length < 1) {
        text_obj = new webim.Msg.Elem.Text(msgtosend);
        msg.addText(text_obj);
    } else {//有表情
        for (var i = 0; i < emotions.length; i++) {
            tmsg = msgtosend.substring(0, msgtosend.indexOf(emotions[i]));
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
            restMsgIndex = msgtosend.indexOf(emotions[i]) + emotions[i].length;
            msgtosend = msgtosend.substring(restMsgIndex);
        }
        if (msgtosend) {
            text_obj = new webim.Msg.Elem.Text(msgtosend);
            msg.addText(text_obj);
        }
    }
    webim.sendMsg(msg, function (resp) {
        if (selType == webim.SESSION_TYPE.C2C) {//私聊时，在聊天窗口手动添加一条发的消息，群聊时，长轮询接口会返回自己发的消息
            showMsg(msg);
        }
        webim.Log.info("发消息成功");
        $("#send_msg_text").val('');
        hideDiscussForm();//隐藏评论表单
        showDiscussTool();//显示评论工具栏
        hideDiscussEmotion();//隐藏表情
    }, function (err) {
        webim.Log.error("发消息失败:" + err.ErrorInfo);
        alert("发消息失败:" + err.ErrorInfo);
    });
}
```

## 发送群消息（点赞）

示例代码如下：

```javascript
//发送消息(群点赞消息)
function sendGroupLoveMsg() {

    if (!loginInfo.identifier) {//未登录
        return;
    }
    if (!selToID) {
        alert("您还没有进入房间，暂不能点赞");
        return;
    }
    if (!selSess) {
        selSess = new webim.Session(selType, selToID, selToID, selSessHeadUrl, Math.round(new Date().getTime() / 1000));
    }
    var isSend = true;//是否为自己发送
    var seq = -1;//消息序列，-1表示 IM SDK 自动生成，用于去重
    var random = Math.round(Math.random() * 4294967296);//消息随机数，用于去重
    var msgTime = Math.round(new Date().getTime() / 1000);//消息时间戳
    //群消息子类型如下：
    //webim.GROUP_MSG_SUB_TYPE.COMMON-普通消息,
    //webim.GROUP_MSG_SUB_TYPE.LOVEMSG-点赞消息，优先级最低
    //webim.GROUP_MSG_SUB_TYPE.TIP-提示消息(不支持发送，用于区分群消息子类型)，
    //webim.GROUP_MSG_SUB_TYPE.REDPACKET-红包消息，优先级最高
    var subType = webim.GROUP_MSG_SUB_TYPE.LOVEMSG;
    var msg = new webim.Msg(selSess, isSend, seq, random, msgTime, loginInfo.identifier, subType, loginInfo.identifierNick);
    var msgtosend = 'love_msg';
    var text_obj = new webim.Msg.Elem.Text(msgtosend);
    msg.addText(text_obj);
    webim.sendMsg(msg, function (resp) {
        if (selType == webim.SESSION_TYPE.C2C) {//私聊时，在聊天窗口手动添加一条发的消息，群聊时，长轮询接口会返回自己发的消息
            showMsg(msg);
        }
        webim.Log.info("点赞成功");
        //展示点赞动画
        showLoveMsgAnimation();
    }, function (err) {
        webim.Log.error("发送点赞消息失败:" + err.ErrorInfo);
        alert("发送点赞消息失败:" + err.ErrorInfo);
    });
}
```

## 发送群消息（红包）

红包消息的下发优先级最高，保证不丢消息。
发送群消息（红包）的示例代码只需将发送群消息（点赞）示例代码中的 `subType` 设成 `webim.GROUP_MSG_SUB_TYPE.REDPACKET` 即可。

