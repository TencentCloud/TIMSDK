//获取应用实例
var webim = require('../../utils/webim_wx.js');
var webimhandler = require('../../utils/webim_handler.js');
const CONFIG = require('../config');

global.webim = webim;
var Config = CONFIG.app;

var app = getApp()
Page({
    data: {
        identifier: '', // 当前用户身份标识，必选
        userSig: '', // 当前用户签名，必选
        nickName: '', // 当前用户昵称，选填
        avChatRoomId: CONFIG.avChatRoomId, // 群ID, 必选
        motto: 'Hello World',
        msgs: [],
        msgContent: ""
    },
    //事件处理函数
    bindViewTap: function () {
        wx.navigateTo({
            url: '../logs/logs'
        })
    },

    clearInput: function () {
        this.setData({
            msgContent: ""
        })
    },

    bindConfirm: function (e) {
        var that = this;
        var content = e.detail.value;
        if (!content.replace(/^\s*|\s*$/g, '')) return;
        webimhandler.onSendMsg(content, function () {
            that.clearInput();
        })
    },

    bindTap: function () {
        webimhandler.sendGroupLoveMsg();
    },


    receiveMsgs: function (data) {
        console.log('receiveMsgs', data);
        var msgs = this.data.msgs || [];
        msgs.push(data);
        //最多展示10条信息
        if (msgs.length > 10) {
            msgs.splice(0, msgs.length - 10)
        }

        this.setData({
            msgs: msgs
        })
    },

    initIM: function () {
        var that = this;
        var avChatRoomId = that.data.avChatRoomId;

        webimhandler.init({
            accountMode: 0 ,//帐号模式，0-表示独立模式，1-表示托管模式(已停用，仅作为演示)
            accountType: 1, // 已废弃
            sdkAppID: Config.sdkappid,
            avChatRoomId: avChatRoomId, //默认房间群ID，群类型必须是直播聊天室（AVChatRoom）
            selType: webim.SESSION_TYPE.GROUP,
            selToID: avChatRoomId,
            selSess: null //当前聊天会话
        });
        //当前用户身份
        var loginInfo = {
            'sdkAppID': Config.sdkappid, //用户所属应用id,必填
            'appIDAt3rd': Config.sdkappid, //用户所属应用id，必填
            'accountType': 1, // 已废弃
            'identifier': that.data.identifier, //当前用户ID,必须是否字符串类型，选填
            'identifierNick': that.data.nickName || '', //当前用户昵称，选填
            'userSig': that.data.userSig, //当前用户身份凭证，必须是字符串类型，选填
        };

        //监听（多终端同步）群系统消息方法，方法都定义在demo_group_notice.js文件中
        var onGroupSystemNotifys = {
            "5": webimhandler.onDestoryGroupNotify, //群被解散(全员接收)
            "11": webimhandler.onRevokeGroupNotify, //群已被回收(全员接收)
            "255": webimhandler.onCustomGroupNotify //用户自定义通知(默认全员接收) 
        };

        //监听连接状态回调变化事件
        var onConnNotify = function (resp) {
            switch (resp.ErrorCode) {
                case webim.CONNECTION_STATUS.ON:
                    //webim.Log.warn('连接状态正常...');
                    break;
                case webim.CONNECTION_STATUS.OFF:
                    webim.Log.warn('连接已断开，无法收到新消息，请检查下你的网络是否正常');
                    break;
                default:
                    webim.Log.error('未知连接状态,status=' + resp.ErrorCode);
                    break;
            }
        };


        //监听事件
        var listeners = {
            "onConnNotify": webimhandler.onConnNotify, //选填
            "onBigGroupMsgNotify": function (msg) {
                webimhandler.onBigGroupMsgNotify(msg, function (msgs) {
                    that.receiveMsgs(msgs);
                })
            }, //监听新消息(大群)事件，必填
            "onMsgNotify": webimhandler.onMsgNotify, //监听新消息(私聊(包括普通消息和全员推送消息)，普通群(非直播聊天室)消息)事件，必填
            "onGroupSystemNotifys": webimhandler.onGroupSystemNotifys, //监听（多终端同步）群系统消息事件，必填
            "onGroupInfoChangeNotify": webimhandler.onGroupInfoChangeNotify //监听群资料变化事件，选填
        };

        //其他对象，选填
        var options = {
            'isAccessFormalEnv': true, //是否访问正式环境，默认访问正式，选填
            'isLogOn': true //是否开启控制台打印日志,默认开启，选填
        };

        webimhandler.sdkLogin(loginInfo, listeners, options, avChatRoomId);
    },

    onUnload: function () {
        // 登出
        webimhandler.logout();
    },
    onLoad: function (options) {
        console.log(options);
        this.setData({
            userSig: options.userSig,
            identifier: options.identifier,
            nickName: options.identifier
        });
        this.initIM();
    }
})