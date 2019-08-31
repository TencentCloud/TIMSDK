/* webim javascript SDK (for wechat miniProgram ) 
*/
module.exports = function () {
    var Version = '1.7.3';

    if (typeof Array.prototype.forEach != 'function') {
        Array.prototype.forEach = function (callback) {
            for (var i = 0; i < this.length; i++) {
                callback.apply(this, [this[i], i, this]);
            }
        };
    }
    /* webim javascript SDK
     */

    /* webim API definitions
     */
    var msgCache = {};
    var webim = { // namespace object webim

        /* function init
         *   sdk登录
         * params:
         *   loginInfo      - Object, 登录身份相关参数集合，详见下面
         *   {
         *     sdkAppID     - String, 用户标识接入SDK的应用ID，必填
         *     accountType  - int, 账号类型，必填
         *     identifier   - String, 用户帐号,必须是字符串类型，必填
         *     identifierNick   - String, 用户昵称，选填
         *     userSig      - String, 鉴权Token，必须是字符串类型，必填
         *   }
         *   listeners      - Object, 事件回调函数集合, 详见下面
         *   {
         *     onConnNotify - function(connInfo), 用于收到连接状态相关通知的回调函数,目前未使用
         *     onMsgNotify  - function(newMsgList), 用于收到消息通知的回调函数,
         *      newMsgList为新消息数组，格式为[Msg对象]
         *      使用方有两种处理回调: 1)处理newMsgList中的增量消息,2)直接访问webim.MsgStore获取最新的消息
         *     onGroupInfoChangeNotify  - function(groupInfo), 用于监听群组资料变更的回调函数,
         *          groupInfo为新的群组资料信息
         *     onGroupSystemNotifys - Object, 用于监听（多终端同步）群系统消息的回调函数对象
         *
         *   }
         *   options        - Object, 其它选项, 目前未使用
         * return:
         *   (无)
         */
        login: function (loginInfo, listeners, options) {},

        /* function syncMsgs
         *   拉取最新C2C消息
         *   一般不需要使用方直接调用, SDK底层会自动同步最新消息并通知使用方, 一种有用的调用场景是用户手动触发刷新消息
         * params:
         *   cbOk   - function(msgList)类型, 当同步消息成功时的回调函数, msgList为新消息数组，格式为[Msg对象],
         *            如果此参数为null或undefined则同步消息成功后会像自动同步那样回调cbNotify
         *   cbErr  - function(err)类型, 当同步消息失败时的回调函数, err为错误对象
         * return:
         *   (无)
         */
        syncMsgs: function (cbOk, cbErr) {},


        /* function getC2CHistoryMsgs
         * 拉取C2C漫游消息
         * params:
         *   options    - 请求参数
         *   cbOk   - function(msgList)类型, 成功时的回调函数, msgList为消息数组，格式为[Msg对象],
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getC2CHistoryMsgs: function (options, cbOk, cbErr) {},

        /* function syncGroupMsgs
         * 拉取群漫游消息
         * params:
         *   options    - 请求参数
         *   cbOk   - function(msgList)类型, 成功时的回调函数, msgList为消息数组，格式为[Msg对象],
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        syncGroupMsgs: function (options, cbOk, cbErr) {},

        /* function sendMsg
         *   发送一条消息
         * params:
         *   msg    - webim.Msg类型, 要发送的消息对象
         *   cbOk   - function()类型, 当发送消息成功时的回调函数
         *   cbErr  - function(err)类型, 当发送消息失败时的回调函数, err为错误对象
         * return:
         *   (无)
         */
        sendMsg: function (msg, cbOk, cbErr) {},

        /* function logout
         *   sdk登出
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        logout: function (cbOk, cbErr) {},

        /* function setAutoRead
         * 设置会话自动已读上报标志
         * params:
         *   selSess    - webim.Session类型, 当前会话
         *   isOn   - boolean, 将selSess的自动已读消息标志改为isOn，同时是否上报当前会话已读消息
         *   isResetAll - boolean，是否重置所有会话的自动已读标志
         * return:
         *   (无)
         */
        setAutoRead: function (selSess, isOn, isResetAll) {},

        /* function getProfilePortrait
         *   拉取资料（搜索用户）
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getProfilePortrait: function (options, cbOk, cbErr) {},

        /* function setProfilePortrait
         *   设置个人资料
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        setProfilePortrait: function (options, cbOk, cbErr) {},

        /* function applyAddFriend
         *   申请添加好友
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        applyAddFriend: function (options, cbOk, cbErr) {},

        /* function getPendency
         *   拉取好友申请
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getPendency: function (options, cbOk, cbErr) {},

        /* function deletePendency
         *   删除好友申请
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        deletePendency: function (options, cbOk, cbErr) {},

        /* function responseFriend
         *   响应好友申请
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        responseFriend: function (options, cbOk, cbErr) {},

        /* function getAllFriend
         *   拉取我的好友
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getAllFriend: function (options, cbOk, cbErr) {},

        /* function deleteFriend
         *   删除好友
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        deleteFriend: function (options, cbOk, cbErr) {},

        /* function addBlackList
         *   增加黑名单
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        addBlackList: function (options, cbOk, cbErr) {},

        /* function getBlackList
         *   删除黑名单
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getBlackList: function (options, cbOk, cbErr) {},

        /* function deleteBlackList
         *   我的黑名单
         * params:
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        deleteBlackList: function (options, cbOk, cbErr) {},

        /* function uploadPic
         *   上传图片
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        uploadPic: function (options, cbOk, cbErr) {},

        /* function createGroup
         *   创建群
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        createGroup: function (options, cbOk, cbErr) {},

        /* function applyJoinGroup
         *   申请加群
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        applyJoinGroup: function (options, cbOk, cbErr) {},

        /* function handleApplyJoinGroup
         *   处理申请加群(同意或拒绝)
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        handleApplyJoinGroup: function (options, cbOk, cbErr) {},

        /* function deleteApplyJoinGroupPendency
         *   删除加群申请
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        deleteApplyJoinGroupPendency: function (options, cbOk, cbErr) {},


        /* function quitGroup
         *  主动退群
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        quitGroup: function (options, cbOk, cbErr) {},

        /* function getGroupPublicInfo
         *   读取群公开资料-高级接口
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getGroupPublicInfo: function (options, cbOk, cbErr) {},

        /* function getGroupInfo
         *   读取群详细资料-高级接口
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getGroupInfo: function (options, cbOk, cbErr) {},

        /* function modifyGroupBaseInfo
         *   修改群基本资料
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        modifyGroupBaseInfo: function (options, cbOk, cbErr) {},

        /* function destroyGroup
         *  解散群
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        destroyGroup: function (options, cbOk, cbErr) {},

        /* function getJoinedGroupListHigh
         *   获取我的群组-高级接口
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getJoinedGroupListHigh: function (options, cbOk, cbErr) {},

        /* function getGroupMemberInfo
         *   获取群组成员列表
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getGroupMemberInfo: function (options, cbOk, cbErr) {},

        /* function addGroupMember
         *   邀请好友加群
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        addGroupMember: function (options, cbOk, cbErr) {},

        /* function modifyGroupMember
         *   修改群成员资料（角色或者群消息提类型示）
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        modifyGroupMember: function (options, cbOk, cbErr) {},

        /* function forbidSendMsg
         *   设置群成员禁言时间
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        forbidSendMsg: function (options, cbOk, cbErr) {},

        /* function deleteGroupMember
         *   删除群成员
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        deleteGroupMember: function (options, cbOk, cbErr) {},

        /* function getPendencyGroup
         *   获取群组未决列表
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getPendencyGroup: function (options, cbOk, cbErr) {},

        /* function getPendencyReport
         *   好友未决已读上报
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getPendencyReport: function (options, cbOk, cbErr) {},

        /* function getPendencyGroupRead
         *   群组未决已读上报
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        getPendencyGroupRead: function (options, cbOk, cbErr) {},

        /* function sendCustomGroupNotify
         *   发送自定义群通知
         * params:
         *   options    - 请求参数，详见api文档
         *   cbOk   - function()类型, 成功时回调函数
         *   cbErr  - function(err)类型, 失败时回调函数, err为错误对象
         * return:
         *   (无)
         */
        sendCustomGroupNotify: function (options, cbOk, cbErr) {},

        /* class webim.Msg
         *   一条消息的描述类, 消息发送、接收的API中都会涉及此类型的对象
         * properties:
         *   sess   - Session object-ref, 消息所属的会话(e.g:我与好友A的C2C会话，我与群组G的GROUP会话)
         *   isSend - Boolean, true表示是我发出消息, false表示是发给我的消息)
         *   seq    - Integer, 消息序列号, 用于判断消息是否同一条
         *   random - Integer, 消息随机数,用于判断消息是否同一条
         *   time   - Integer, 消息时间戳, 为unix timestamp
         *   fromAccount -String,  消息发送者帐号
         *   subType -Integer,  消息子类型，c2c消息时，0-表示普通消息；群消息时，0-普通消息，1-点赞消息，2-提示消息
         *   fromAccountNick -String,  消息发送者昵称
         *   elems  - Array of webim.Msg.Elem, 描述消息内容的元素列表
         * constructor:
         *   Msg(sess, isSend, seq,random time,fromAccount) - 构造函数, 参数定义同上面properties中定义
         * methods:
         *   addText(text)  - 向elems中添加一个TEXT元素
         *   addFace(face)  - 向elems中添加一个FACE元素
         *   toHtml()       - 转成可展示的html String
         *addFace
         * sub-class webim.Msg.Elem
         *   消息中一个组成元素的描述类, 一条消息的内容被抽象描述为N个元素的有序列表
         * properties:
         *   type   - 元素类型, 目前有TEXT(文本)、FACE(表情)、IMAGE(图片)等
         *   content- 元素内容体, 当TEXT时为String, 当PIC时为UrlString
         * constructor:
         *   Elem(type, content) - 构造函数, 参数定义同上面properties中定义
         *
         * sub-class webim.Msg.Elem.TextElem
         *   文本
         * properties:
         *   text  - String 内容
         * constructor:
         *   TextElem(text) - 构造函数, 参数定义同上面properties中定义
         *
         * sub-class webim.Msg.Elem.FaceElem
         *   表情
         * properties:
         *   index  - Integer 表情索引, 用户自定义
         *   data   - String 额外数据，用户自定义
         * constructor:
         *   FaceElem(index,data) - 构造函数, 参数定义同上面properties中定义
         *
         *
         */
        Msg: function (sess, isSend, seq, random, time, fromAccount, subType, fromAccountNick, fromAccountHeadurl) { /*Class constructor*/ },

        /* singleton object MsgStore
         * webim.MsgStore是消息数据的Model对象(参考MVC概念), 它提供接口访问当前存储的会话和消息数据
         * 下面说明下会话数据类型: Session
         *
         * class Session
         *   一个Session对象描述一个会话，会话可简单理解为最近会话列表的一个条目，它由两个字段唯一标识:
         *     type - String, 会话类型(如"C2C", "GROUP", ...)
         *     id   - String, 会话ID(如C2C类型中为对方帐号,"C2C"时为好友ID,"GROUP"时为群ID)
         * properties:
         *   (Session对象未对外暴露任何属性字段, 所有访问通过下面的getter方法进行)
         * methods:
         *   type()     - String, 返回会话类型,"C2C"表示与好友私聊，"GROUP"表示群聊
         *   id()       - String, 返回会话ID
         *   name()     - String, 返回会话标题(如C2C类型中为对方的昵称,暂不支持)
         *   icon()     - String, 返回会话图标(对C2C类型中为对方的头像URL，暂不支持)
         *   unread()           - Integer, 返回会话未读条数
         *   time()     - Integer, 返回会话最后活跃时间, 为unix timestamp
         *   curMaxMsgSeq() - Integer, 返回会话最大消息序列号
         *   msgCount() - Integer, 返回会话中所有消息条数
         *   msg(index) - webim.Msg, 返回会话中第index条消息
         */
        MsgStore: {
            /* function sessMap
             *   获取所有会话
             * return:
             *   所有会话对象
             */
            sessMap: function () {
                return { /*Object*/ };
            },
            /* function sessCount
             *   获取当前会话的个数
             * return:
             *   Integer, 会话个数
             */
            sessCount: function () {
                return 0;
            },

            /* function sessByTypeId
             *   根据会话类型和会话ID取得相应会话
             * params:
             *   type   - String, 会话类型(如"C2C", "GROUP", ...)
             *   id     - String, 会话ID(如对方ID)
             * return:
             *   Session, 会话对象(说明见上面)
             */
            sessByTypeId: function (type, id) {
                return { /*Session Object*/ };
            },
            /* function delSessByTypeId
             *   根据会话类型和会话ID删除相应会话
             * params:
             *   type   - String, 会话类型(如"C2C", "GROUP", ...)
             *   id     - String, 会话ID(如对方ID)
             * return:
             *   Boolean, 布尔类型
             */
            delSessByTypeId: function (type, id) {
                return true;
            },

            /* function resetCookieAndSyncFlag
             *   重置上一次读取新c2c消息Cookie和是否继续拉取标记
             * return:
             *
             */
            resetCookieAndSyncFlag: function () {},

            downloadMap: {}
        }

    };

    /* webim API implementation
     */
    (function (webim) {
        //sdk版本
        var SDK = {
            'VERSION': Version, //sdk版本号
            'APPID': '537048168', //web im sdk 版本 APPID
            'PLAATFORM': "10" //发送请求时判断其是来自web端的请求
        };

        //是否启用正式环境，默认启用
        var isAccessFormaEnvironment = true;
        // 是否需要进行XSS Filter
        var xssFilterEnable = true;

        //后台接口主机
        var SRV_HOST = {
            'FORMAL': {
                'COMMON': 'https://webim.tim.qq.com',
                'PIC': 'https://pic.tim.qq.com'
            },
            'TEST': {
                'COMMON': 'https://test.tim.qq.com',
                'PIC': 'https://pic.tim.qq.com'
            }
        };

        //浏览器版本信息
        var BROWSER_INFO = {};
        //是否为ie9（含）以下
        var lowerBR = false;

        //服务名称
        var SRV_NAME = {
            'OPEN_IM': 'openim', //私聊（拉取未读c2c消息，长轮询，c2c消息已读上报等）服务名
            'GROUP': 'group_open_http_svc', //群组管理（拉取群消息，创建群，群成员管理，群消息已读上报等）服务名
            'FRIEND': 'sns', //关系链管理（好友管理，黑名单管理等）服务名
            'PROFILE': 'profile', //资料管理（查询，设置个人资料等）服务名
            'RECENT_CONTACT': 'recentcontact', //最近联系人服务名
            'PIC': 'openpic', //图片（或文件）服务名
            'BIG_GROUP': 'group_open_http_noauth_svc', //直播大群 群组管理（申请加大群）服务名
            'BIG_GROUP_LONG_POLLING': 'group_open_long_polling_http_noauth_svc', //直播大群 长轮询（拉取消息等）服务名
            'IM_OPEN_STAT': 'imopenstat', //质量上报，统计接口错误率
            'DEL_CHAT': 'recentcontact', //删除会话
            'WEB_IM': 'webim'
        };

        //不同服务对应的版本号
        var SRV_NAME_VER = {
            'openim': 'v4',
            'group_open_http_svc': 'v4',
            'sns': 'v4',
            'profile': 'v4',
            'recentcontact': 'v4',
            'openpic': 'v4',
            'group_open_http_noauth_svc': 'v1',
            'group_open_long_polling_http_noauth_svc': 'v1',
            'imopenstat': 'v4',
            'webim': 'v3'
        };

        //不同的命令名对应的上报类型ID，用于接口质量上报
        var CMD_EVENT_ID_MAP = {
            'login': 1, //登录
            'pic_up': 3, //上传图片
            'apply_join_group': 9, //申请加入群组
            'create_group': 10, //创建群组
            'longpolling': 18, //普通长轮询
            'send_group_msg': 19, //群聊
            'sendmsg': 20 //私聊
        };

        //聊天类型
        var SESSION_TYPE = {
            'C2C': 'C2C', //私聊
            'GROUP': 'GROUP' //群聊
        };

        //最近联系人类型
        var RECENT_CONTACT_TYPE = {
            'C2C': 1, //好友
            'GROUP': 2 //群
        };

        //消息最大长度（字节）
        var MSG_MAX_LENGTH = {
            'C2C': 9000, //私聊消息 与官网文档维持一致，https://cloud.tencent.com/document/product/269/32429#.E4.B8.9A.E5.8A.A1.E7.89.B9.E6.80.A7.E9.99.90.E5.88.B6
            'GROUP': 9000 //群聊
        };

        //后台接口返回类型
        var ACTION_STATUS = {
            'OK': 'OK', //成功
            'FAIL': 'FAIL' //失败
        };

        var ERROR_CODE_CUSTOM = 99999; //自定义后台接口返回错误码

        //消息元素类型
        var MSG_ELEMENT_TYPE = {
            'TEXT': 'TIMTextElem', //文本
            'FACE': 'TIMFaceElem', //表情
            'IMAGE': 'TIMImageElem', //图片
            'CUSTOM': 'TIMCustomElem', //自定义
            'SOUND': 'TIMSoundElem', //语音,只支持显示
            'FILE': 'TIMFileElem', //文件,只支持显示
            'LOCATION': 'TIMLocationElem', //地理位置
            'GROUP_TIP': 'TIMGroupTipElem' //群提示消息,只支持显示
        };

        //图片类型
        var IMAGE_TYPE = {
            'ORIGIN': 1, //原图
            'LARGE': 2, //缩略大图
            'SMALL': 3 //缩略小图
        };

        //图片格式
        var IMAGE_FORMAT = {
            JPG: 0x1,
            JPEG: 0x1,
            GIF: 0x2,
            PNG: 0x3,
            BMP: 0x4,
            UNKNOWN: 0xff
        };


        //上传资源包类型
        var UPLOAD_RES_PKG_FLAG = {
            'RAW_DATA': 0, //原始数据
            'BASE64_DATA': 1 //base64编码数据
        };

        //下载文件配置
        var DOWNLOAD_FILE = {
            'BUSSINESS_ID': '10001', //下载文件业务ID
            'AUTH_KEY': '617574686b6579', //下载文件authkey
            'SERVER_IP': '182.140.186.147', //下载文件服务器IP
            'SOUND_SERVER_DOMAIN': 'grouptalk.c2c.qq.com'
        };

        //下载文件类型
        var DOWNLOAD_FILE_TYPE = {
            "SOUND": 2106, //语音
            "FILE": 2107 //普通文件
        };

        //上传资源类型
        var UPLOAD_RES_TYPE = {
            "IMAGE": 1, //图片
            "FILE": 2, //文件
            "SHORT_VIDEO": 3, //短视频
            "SOUND": 4 //语音，PTT
        };

        //版本号，用于上传图片或文件接口
        var VERSION_INFO = {
            'APP_VERSION': '2.1', //应用版本号
            'SERVER_VERSION': 1 //服务端版本号
        };

        //长轮询消息类型
        var LONG_POLLINNG_EVENT_TYPE = {
            "C2C": 1 //新的c2c消息通知
                ,
            "GROUP_COMMON": 3 //新的群普通消息
                ,
            "GROUP_TIP": 4 //新的群提示消息
                ,
            "GROUP_SYSTEM": 5 //新的群系统消息
                ,
            "GROUP_TIP2": 6 //新的群提示消息2
                ,
            "FRIEND_NOTICE": 7 //好友系统通知
                ,
            "PROFILE_NOTICE": 8 //资料系统通知
                ,
            "C2C_COMMON": 9 //新的C2C消息
                ,
            "C2C_EVENT": 10
        };

        //c2c消息子类型
        var C2C_MSG_SUB_TYPE = {
            "COMMON": 0 //普通消息
        };
        //c2c消息子类型
        var C2C_EVENT_SUB_TYPE = {
            "READED": 92, //已读消息同步
            "KICKEDOUT": 96
        };

        //群消息子类型
        var GROUP_MSG_SUB_TYPE = {
            "COMMON": 0, //普通消息
            "LOVEMSG": 1, //点赞消息
            "TIP": 2, //提示消息
            "REDPACKET": 3 //红包消息
        };

        //群消息优先级类型
        var GROUP_MSG_PRIORITY_TYPE = {
            "REDPACKET": 1, //红包消息
            "COMMON": 2, //普通消息
            "LOVEMSG": 3 //点赞消息
        };

        //群提示消息类型
        var GROUP_TIP_TYPE = {
            "JOIN": 1, //加入群组
            "QUIT": 2, //退出群组
            "KICK": 3, //被踢出群组
            "SET_ADMIN": 4, //被设置为管理员
            "CANCEL_ADMIN": 5, //被取消管理员
            "MODIFY_GROUP_INFO": 6, //修改群资料
            "MODIFY_MEMBER_INFO": 7 //修改群成员信息
        };

        //群提示消息-群资料变更类型
        var GROUP_TIP_MODIFY_GROUP_INFO_TYPE = {
            "FACE_URL": 1, //修改群头像URL
            "NAME": 2, //修改群名称
            "OWNER": 3, //修改群主
            "NOTIFICATION": 4, //修改群公告
            "INTRODUCTION": 5 //修改群简介
        };

        //群系统消息类型
        var GROUP_SYSTEM_TYPE = {
            "JOIN_GROUP_REQUEST": 1, //申请加群请求（只有管理员会收到）
            "JOIN_GROUP_ACCEPT": 2, //申请加群被同意（只有申请人能够收到）
            "JOIN_GROUP_REFUSE": 3, //申请加群被拒绝（只有申请人能够收到）
            "KICK": 4, //被管理员踢出群(只有被踢者接收到)
            "DESTORY": 5, //群被解散(全员接收)
            "CREATE": 6, //创建群(创建者接收, 不展示)
            "INVITED_JOIN_GROUP_REQUEST": 7, //邀请加群(被邀请者接收)
            "QUIT": 8, //主动退群(主动退出者接收, 不展示)
            "SET_ADMIN": 9, //设置管理员(被设置者接收)
            "CANCEL_ADMIN": 10, //取消管理员(被取消者接收)
            "REVOKE": 11, //群已被回收(全员接收, 不展示)
            "READED": 15, //群消息已读同步
            "CUSTOM": 255, //用户自定义通知(默认全员接收)
            "INVITED_JOIN_GROUP_REQUEST_AGREE": 12, //邀请加群(被邀请者需同意)
        };

        //好友系统通知子类型
        var FRIEND_NOTICE_TYPE = {
            "FRIEND_ADD": 1, //好友表增加
            "FRIEND_DELETE": 2, //好友表删除
            "PENDENCY_ADD": 3, //未决增加
            "PENDENCY_DELETE": 4, //未决删除
            "BLACK_LIST_ADD": 5, //黑名单增加
            "BLACK_LIST_DELETE": 6, //黑名单删除
            "PENDENCY_REPORT": 7, //未决已读上报
            "FRIEND_UPDATE": 8 //好友数据更新
        };

        //资料系统通知子类型
        var PROFILE_NOTICE_TYPE = {
            "PROFILE_MODIFY": 1 //资料修改
        };

        //腾讯登录服务错误码（用于托管模式）
        var TLS_ERROR_CODE = {
            'OK': 0, //成功
            'SIGNATURE_EXPIRATION': 11 //用户身份凭证过期
        };

        //长轮询连接状态
        var CONNECTION_STATUS = {
            'INIT': -1, //初始化
            'ON': 0, //连接正常
            'RECONNECT': 1, //连接恢复正常
            'OFF': 9999 //连接已断开,可能是用户网络问题，或者长轮询接口报错引起的
        };

        var UPLOAD_PIC_BUSSINESS_TYPE = { //图片业务类型
            'GROUP_MSG': 1, //私聊图片
            'C2C_MSG': 2, //群聊图片
            'USER_HEAD': 3, //用户头像
            'GROUP_HEAD': 4 //群头像
        };

        var FRIEND_WRITE_MSG_ACTION = { //好友输入消息状态
            'ING': 14, //正在输入
            'STOP': 15 //停止输入
        };

        //ajax默认超时时间，单位：毫秒
        var ajaxDefaultTimeOut = 15000;

        //大群长轮询接口返回正常时，延时一定时间再发起下一次请求
        var OK_DELAY_TIME = 1000;

        //大群长轮询接口发生错误时，延时一定时间再发起下一次请求
        var ERROR_DELAY_TIME = 5000;

        //群提示消息最多显示人数
        var GROUP_TIP_MAX_USER_COUNT = 10;

        //长轮询连接状态
        var curLongPollingStatus = CONNECTION_STATUS.INIT;

        //当长轮询连接断开后，是否已经回调过
        var longPollingOffCallbackFlag = false;

        //当前长轮询返回错误次数
        var curLongPollingRetErrorCount = 0;

        //长轮询默认超时时间，单位：毫秒
        var longPollingDefaultTimeOut = 60000;

        //长轮询返回错误次数达到一定值后，发起新的长轮询请求间隔时间，单位：毫秒
        var longPollingIntervalTime = 5000;

        //没有新消息时，长轮询返回60008错误码是正常的
        var longPollingTimeOutErrorCode = 60008;

        //多实例登录被kick的错误码
        var longPollingKickedErrorCode = 91101;

        var longPollingPackageTooLargeErrorCode = 10018;
        var LongPollingId = null;

        //当前大群长轮询返回错误次数
        var curBigGroupLongPollingRetErrorCount = 0;

        //最大允许长轮询返回错误次数
        var LONG_POLLING_MAX_RET_ERROR_COUNT = 10;

        //上传重试累计
        var Upload_Retry_Times = 0;
        //最大上传重试
        var Upload_Retry_Max_Times = 20;


        var uploadResultIframeId = 0; //用于上传图片的iframe id

        var ipList = []; //文件下载地址
        var authkey = null; //文件下载票据
        var expireTime = null; //文件下载票据超时时间

        //错误码
        var ERROR = {};
        //当前登录用户
        var ctx = {
            sdkAppID: null,
            appIDAt3rd: null,
            accountType: null,
            identifier: null,
            tinyid: null,
            identifierNick: null,
            userSig: null,
            a2: null,
            contentType: 'json',
            apn: 1
        };
        var opt = {};
        var xmlHttpObjSeq = 0; //ajax请求id
        var xmlHttpObjMap = {}; //发起的ajax请求
        var curSeq = 0; //消息seq
        var tempC2CMsgList = []; //新c2c消息临时缓存
        var tempC2CHistoryMsgList = []; //漫游c2c消息临时缓存

        var maxApiReportItemCount = 20; //一次最多上报条数
        var apiReportItems = []; //暂存api接口质量上报数据

        var Resources = {
            downloadMap: {}
        };

        //表情标识字符和索引映射关系对象，用户可以自定义
        var emotionDataIndexs = {
            "[惊讶]": 0,
            "[撇嘴]": 1,
            "[色]": 2,
            "[发呆]": 3,
            "[得意]": 4,
            "[流泪]": 5,
            "[害羞]": 6,
            "[闭嘴]": 7,
            "[睡]": 8,
            "[大哭]": 9,
            "[尴尬]": 10,
            "[发怒]": 11,
            "[调皮]": 12,
            "[龇牙]": 13,
            "[微笑]": 14,
            "[难过]": 15,
            "[酷]": 16,
            "[冷汗]": 17,
            "[抓狂]": 18,
            "[吐]": 19,
            "[偷笑]": 20,
            "[可爱]": 21,
            "[白眼]": 22,
            "[傲慢]": 23,
            "[饿]": 24,
            "[困]": 25,
            "[惊恐]": 26,
            "[流汗]": 27,
            "[憨笑]": 28,
            "[大兵]": 29,
            "[奋斗]": 30,
            "[咒骂]": 31,
            "[疑问]": 32,
            "[嘘]": 33,
            "[晕]": 34
        };

        //表情对象，用户可以自定义
        var emotions = {};
        //工具类
        var tool = new function () {

            //格式化时间戳
            //format格式如下：
            //yyyy-MM-dd hh:mm:ss 年月日时分秒(默认格式)
            //yyyy-MM-dd 年月日
            //hh:mm:ss 时分秒
            this.formatTimeStamp = function (timestamp, format) {
                if (!timestamp) {
                    return 0;
                }
                var formatTime;
                format = format || 'yyyy-MM-dd hh:mm:ss';
                var date = new Date(timestamp * 1000);
                var o = {
                    "M+": date.getMonth() + 1, //月份
                    "d+": date.getDate(), //日
                    "h+": date.getHours(), //小时
                    "m+": date.getMinutes(), //分
                    "s+": date.getSeconds() //秒
                };
                if (/(y+)/.test(format)) {
                    formatTime = format.replace(RegExp.$1, (date.getFullYear() + "").substr(4 - RegExp.$1.length));
                } else {
                    formatTime = format;
                }
                for (var k in o) {
                    if (new RegExp("(" + k + ")").test(formatTime))
                        formatTime = formatTime.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
                }
                return formatTime;
            };

            //根据群类型英文名转换成中文名
            this.groupTypeEn2Ch = function (type_en) {
                var type_ch = null;
                switch (type_en) {
                    case 'Public':
                        type_ch = '公开群';
                        break;
                    case 'ChatRoom':
                        type_ch = '聊天室';
                        break;
                    case 'Private':
                        type_ch = '私有群'; //即讨论组
                        break;
                    case 'AVChatRoom':
                        type_ch = '直播聊天室';
                        break;
                    default:
                        type_ch = type_en;
                        break;
                }
                return type_ch;
            };
            //根据群类型中文名转换成英文名
            this.groupTypeCh2En = function (type_ch) {
                var type_en = null;
                switch (type_ch) {
                    case '公开群':
                        type_en = 'Public';
                        break;
                    case '聊天室':
                        type_en = 'ChatRoom';
                        break;
                    case '私有群': //即讨论组
                        type_en = 'Private';
                        break;
                    case '直播聊天室':
                        type_en = 'AVChatRoom';
                        break;
                    default:
                        type_en = type_ch;
                        break;
                }
                return type_en;
            };
            //根据群身份英文名转换成群身份中文名
            this.groupRoleEn2Ch = function (role_en) {
                var role_ch = null;
                switch (role_en) {
                    case 'Member':
                        role_ch = '成员';
                        break;
                    case 'Admin':
                        role_ch = '管理员';
                        break;
                    case 'Owner':
                        role_ch = '群主';
                        break;
                    default:
                        role_ch = role_en;
                        break;
                }
                return role_ch;
            };
            //根据群身份中文名转换成群身份英文名
            this.groupRoleCh2En = function (role_ch) {
                var role_en = null;
                switch (role_ch) {
                    case '成员':
                        role_en = 'Member';
                        break;
                    case '管理员':
                        role_en = 'Admin';
                        break;
                    case '群主':
                        role_en = 'Owner';
                        break;
                    default:
                        role_en = role_ch;
                        break;
                }
                return role_en;
            };
            //根据群消息提示类型英文转换中文
            this.groupMsgFlagEn2Ch = function (msg_flag_en) {
                var msg_flag_ch = null;
                switch (msg_flag_en) {
                    case 'AcceptAndNotify':
                        msg_flag_ch = '接收并提示';
                        break;
                    case 'AcceptNotNotify':
                        msg_flag_ch = '接收不提示';
                        break;
                    case 'Discard':
                        msg_flag_ch = '屏蔽';
                        break;
                    default:
                        msg_flag_ch = msg_flag_en;
                        break;
                }
                return msg_flag_ch;
            };
            //根据群消息提示类型中文名转换英文名
            this.groupMsgFlagCh2En = function (msg_flag_ch) {
                var msg_flag_en = null;
                switch (msg_flag_ch) {
                    case '接收并提示':
                        msg_flag_en = 'AcceptAndNotify';
                        break;
                    case '接收不提示':
                        msg_flag_en = 'AcceptNotNotify';
                        break;
                    case '屏蔽':
                        msg_flag_en = 'Discard';
                        break;
                    default:
                        msg_flag_en = msg_flag_ch;
                        break;
                }
                return msg_flag_en;
            };
            //将空格和换行符转换成HTML标签
            this.formatText2Html = function (text) {
                var html = text;
                if (html) {
                    html = this.xssFilter(html); //用户昵称或群名称等字段会出现脚本字符串
                    html = html.replace(/ /g, "&nbsp;");
                    html = html.replace(/\n/g, "<br/>");
                }
                return html;
            };
            //将HTML标签转换成空格和换行符
            this.formatHtml2Text = function (html) {
                var text = html;
                if (text) {
                    text = text.replace(/&nbsp;/g, " ");
                    text = text.replace(/<br\/>/g, "\n");
                }
                return text;
            };
            //获取字符串(UTF-8编码)所占字节数
            //参考：http://zh.wikipedia.org/zh-cn/UTF-8
            this.getStrBytes = function (str) {
                if (str == null || str === undefined) return 0;
                if (typeof str != "string") {
                    return 0;
                }
                var total = 0,
                    charCode, i, len;
                for (i = 0, len = str.length; i < len; i++) {
                    charCode = str.charCodeAt(i);
                    if (charCode <= 0x007f) {
                        total += 1; //字符代码在000000 – 00007F之间的，用一个字节编码
                    } else if (charCode <= 0x07ff) {
                        total += 2; //000080 – 0007FF之间的字符用两个字节
                    } else if (charCode <= 0xffff) {
                        total += 3; //000800 – 00D7FF 和 00E000 – 00FFFF之间的用三个字节，注: Unicode在范围 D800-DFFF 中不存在任何字符
                    } else {
                        total += 4; //010000 – 10FFFF之间的用4个字节
                    }
                }
                return total;
            };


            //防止XSS攻击
            this.xssFilter = function (val) {
                if( xssFilterEnable ){
                    val = val.toString();
                    val = val.replace(/[<]/g, "&lt;");
                    val = val.replace(/[>]/g, "&gt;");
                    val = val.replace(/"/g, "&quot;");
                }
                return val;
            };

            //去掉头尾空白符
            this.trimStr = function (str) {
                if (!str) return '';
                str = str.toString();
                return str.replace(/(^\s*)|(\s*$)/g, "");
            };
            //判断是否为8位整数
            this.validNumber = function (str) {
                str = str.toString();
                return str.match(/(^\d{1,8}$)/g);
            };
            this.getReturnError = function (errorInfo, errorCode) {
                if (!errorCode) {
                    errorCode = -100;
                }
                var error = {
                    'ActionStatus': ACTION_STATUS.FAIL,
                    'ErrorCode': errorCode,
                    'ErrorInfo': errorInfo + "[" + errorCode + "]"
                };
                return error;
            };
            this.replaceObject = function (keyMap, json) {
                for (var a in json) {
                    if (keyMap[a]) {
                        json[keyMap[a]] = json[a]
                        delete json[a]
                        if (json[keyMap[a]] instanceof Array) {
                            var len = json[keyMap[a]].length
                            for (var i = 0; i < len; i++) {
                                json[keyMap[a]][i] = this.replaceObject(keyMap, json[keyMap[a]][i])
                            }
                        } else if (typeof json[keyMap[a]] === 'object') {
                            json[keyMap[a]] = this.replaceObject(keyMap, json[keyMap[a]])
                        }
                    }
                }
                return json;
            }
        };

        //日志对象
        var log = new function () {

            var on = true;

            this.setOn = function (onFlag) {
                on = onFlag;
            };

            this.getOn = function () {
                return on;
            };

            this.error = function (logStr) {
                try {
                    on && console.error(logStr);
                } catch (e) {}
            };
            this.warn = function (logStr) {
                try {
                    on && console.warn(logStr);
                } catch (e) {}
            };
            this.info = function (logStr) {
                try {
                    on && console.info(logStr);
                } catch (e) {}
            };
            this.debug = function (logStr) {
                try {
                    on && console.debug(logStr);
                } catch (e) {}
            };
        };
        //获取unix时间戳
        var unixtime = function (d) {
            if (!d) d = new Date();
            return Math.round(d.getTime() / 1000);
        };
        //时间戳转日期
        var fromunixtime = function (t) {
            return new Date(t * 1000);
        };
        //获取下一个消息序号
        var nextSeq = function () {
            if (curSeq) {
                curSeq = curSeq + 1;
            } else {
                curSeq = Math.round(Math.random() * 10000000);
            }
            return curSeq;
        };
        //产生随机数
        var createRandom = function () {
            return Math.round(Math.random() * 4294967296);
        };

        //发起ajax请求
        var ajaxRequest = function (meth, url, req, timeout, isLongPolling, cbOk, cbErr) {

            wx.request({
                url: url,
                data: req,
                dataType: 'json',
                method: meth,
                header: {
                    'Content-Type': 'application/json'
                },
                success: function (res) {
                    curLongPollingRetErrorCount = curBigGroupLongPollingRetErrorCount = 0;
                    if (cbOk) cbOk(res.data);
                },
                fail: function (res) {
                    setTimeout(function () {
                        var errInfo = "请求服务器失败,请检查你的网络是否正常";
                        var error = tool.getReturnError(errInfo, -2);
                        //if (!isLongPolling && cbErr) cbErr(error);
                        if (cbErr) cbErr(error);
                    }, 16);
                }
            });
        }

        //发起ajax请求（json格式数据）
        var ajaxRequestJson = function (meth, url, req, timeout, isLongPolling, cbOk, cbErr) {
            ajaxRequest(meth, url, JSON.stringify(req), timeout, isLongPolling, function (resp) {
                var json = null;
                if (resp) json = resp; //将返回的json字符串转换成json对象
                if (cbOk) cbOk(json);
            }, cbErr);
        }
        //判断用户是否已登录
        var isLogin = function () {
            return ctx.sdkAppID && ctx.identifier;
        };
        //检查是否登录
        var checkLogin = function (cbErr, isNeedCallBack) {
            if (!isLogin()) {
                if (isNeedCallBack) {
                    var errInfo = "请登录";
                    var error = tool.getReturnError(errInfo, -4);

                    if (cbErr) cbErr(error);
                }
                return false;
            }
            return true;
        };

        //检查是否访问正式环境
        var isAccessFormalEnv = function () {
            return isAccessFormaEnvironment;
        };

        //根据不同的服务名和命令，获取对应的接口地址
        var getApiUrl = function (srvName, cmd, cbOk, cbErr) {
            var srvHost = SRV_HOST;
            if (isAccessFormalEnv()) {
                srvHost = SRV_HOST.FORMAL.COMMON;
            } else {
                srvHost = SRV_HOST.TEST.COMMON;
            }

            //if (srvName == SRV_NAME.RECENT_CONTACT) {
            //    srvHost = SRV_HOST.TEST.COMMON;
            //}

            if (srvName == SRV_NAME.PIC) {
                if (isAccessFormalEnv()) {
                    srvHost = SRV_HOST.FORMAL.PIC;
                } else {
                    srvHost = SRV_HOST.TEST.PIC;
                }
            }

            var url = srvHost + '/' + SRV_NAME_VER[srvName] + '/' + srvName + '/' + cmd + '?websdkappid=' + SDK.APPID + "&v=" + SDK.VERSION + "&platform=" + SDK.PLAATFORM;;

            if (isLogin()) {
                if (cmd == 'login' || cmd == 'accesslayer') {
                    url += '&identifier=' + encodeURIComponent(ctx.identifier) + '&usersig=' + ctx.userSig;
                } else {
                    if (ctx.tinyid && ctx.a2) {
                        url += '&tinyid=' + ctx.tinyid + '&a2=' + ctx.a2;
                    } else {
                        if (cbErr) {
                            log.error("tinyid或a2为空[" + srvName + "][" + cmd + "]");
                            cbErr(tool.getReturnError("tinyid或a2为空[" + srvName + "][" + cmd + "]", -5));
                            return false;
                        }
                    }
                }
                url += '&contenttype=' + ctx.contentType;
            }
            url += '&sdkappid=' + ctx.sdkAppID + '&accounttype=' + ctx.accountType + '&apn=' + ctx.apn + '&reqtime=' + unixtime();
            return url;
        };

        //获取语音下载url
        var getSoundDownUrl = function (uuid, senderId) {
            var soundUrl = null;
            if (authkey && ipList[0]) {
                // soundUrl = "http://" + ipList[0] + "/asn.com/stddownload_common_file?authkey=" + authkey + "&bid=" + DOWNLOAD_FILE.BUSSINESS_ID + "&subbid=" + ctx.sdkAppID + "&fileid=" + uuid + "&filetype=" + DOWNLOAD_FILE_TYPE.SOUND + "&openid=" + senderId + "&ver=0";
                soundUrl = "https://" + DOWNLOAD_FILE.SOUND_SERVER_DOMAIN + "/asn.com/stddownload_common_file?authkey=" + authkey + "&bid=" + DOWNLOAD_FILE.BUSSINESS_ID + "&subbid=" + ctx.sdkAppID + "&fileid=" + uuid + "&filetype=" + DOWNLOAD_FILE_TYPE.SOUND + "&openid=" + senderId + "&ver=0";
            } else {
                log.error("拼接语音下载url不报错：ip或者authkey为空");
            }
            return soundUrl;
        };

        //获取文件下载地址
        var getFileDownUrl = function (uuid, senderId, fileName) {
            var fileUrl = null;
            if (authkey && ipList[0]) {
                fileUrl = "http://" + ipList[0] + "/asn.com/stddownload_common_file?authkey=" + authkey + "&bid=" + DOWNLOAD_FILE.BUSSINESS_ID + "&subbid=" + ctx.sdkAppID + "&fileid=" + uuid + "&filetype=" + DOWNLOAD_FILE_TYPE.FILE + "&openid=" + senderId + "&ver=0&filename=" + encodeURIComponent(fileName);
            } else {
                log.error("拼接文件下载url不报错：ip或者authkey为空");
            }
            Resources.downloadMap["uuid_" + uuid] = fileUrl;
            return fileUrl;
        };

        //获取文件下载地址
        var getFileDownUrlV2 = function (uuid, senderId, fileName, downFlag, receiverId, busiId, type) {
            var options = {
                "From_Account": senderId, //"identifer_0",       // 类型: String, 发送者tinyid
                "To_Account": receiverId, //"identifer_1",         // 类型: String, 接收者tinyid
                "os_platform": 10, // 类型: Number, 终端的类型 1(android) 2(ios) 3(windows) 10(others...)
                "Timestamp": unixtime().toString(), // 类型: Number, 时间戳
                "Random": createRandom().toString(), // 类型: Number, 随机值
                "request_info": [ // 类型: Array
                    {
                        "busi_id": busiId, // 类型: Number, 群(1) C2C(2) 其他请联系sdk开发者分配
                        "download_flag": downFlag, // 类型: Number, 申请下载地址标识  0(申请架平下载地址)  1(申请COS平台下载地址)  2(不需要申请, 直接拿url下载(这里应该不会为2))
                        "type": type, // 类型: Number, 0(短视频缩略图), 1(文件), 2(短视频), 3(ptt), 其他待分配
                        "uuid": uuid, // 类型: Number, 唯一标识一个文件的uuid
                        "version": VERSION_INFO.SERVER_VERSION, // 类型: Number, 架平server版本
                        "auth_key": authkey, // 类型: String, 认证签名
                        "ip": ipList[0] // 类型: Number, 架平IP
                    }
                ]
            };
            //获取下载地址
            proto_applyDownload(options, function (resp) {
                if (resp.error_code == 0 && resp.response_info) {
                    Resources.downloadMap["uuid_" + options.uuid] = resp.response_info.url;
                }
                if (onAppliedDownloadUrl) {
                    onAppliedDownloadUrl({
                        uuid: options.uuid,
                        url: resp.response_info.url,
                        maps: Resources.downloadMap
                    });
                }
            }, function (resp) {
                log.error("获取下载地址失败", options.uuid)
            });
        };


        //重置ajax请求
        var clearXmlHttpObjMap = function () {
            //遍历xmlHttpObjMap{}
            for (var seq in xmlHttpObjMap) {
                var xmlHttpObj = xmlHttpObjMap[seq];
                if (xmlHttpObj) {
                    xmlHttpObj.abort(); //中断ajax请求(长轮询)
                    xmlHttpObjMap[xmlHttpObjSeq] = null; //清空
                }
            }
            xmlHttpObjSeq = 0;
            xmlHttpObjMap = {};
        };

        //重置sdk全局变量
        var clearSdk = function () {

            clearXmlHttpObjMap();

            //当前登录用户
            ctx = {
                sdkAppID: null,
                appIDAt3rd: null,
                accountType: null,
                identifier: null,
                identifierNick: null,
                userSig: null,
                contentType: 'json',
                apn: 1
            };
            opt = {};

            curSeq = 0;


            apiReportItems = [];

            MsgManager.clear();
            MsgStore.clear();

            //重置longpollingId
            LongPollingId = null;
        };

        //登录
        var _login = function (loginInfo, listeners, options, cbOk, cbErr) {

            clearSdk();

            if (options) opt = options;
            if (opt.isAccessFormalEnv == false) {
                log.error("请切换为正式环境！！！！");
                isAccessFormaEnvironment = opt.isAccessFormalEnv;
            }
            if (opt.isLogOn == false) {
                log.setOn(opt.isLogOn);
            }
            if( typeof opt.xssFilterEnable !=='undefined'){
                xssFilterEnable = opt.xssFilterEnable;
            }
            /*
             if(opt.emotions){
             emotions=opt.emotions;
             webim.Emotions= emotions;
             }
             if(opt.emotionDataIndexs){
             emotionDataIndexs=opt.emotionDataIndexs;
             webim.EmotionDataIndexs= emotionDataIndexs;
             }*/

            if (!loginInfo) {
                if (cbErr) {
                    cbErr(tool.getReturnError("loginInfo is empty", -6));
                    return;
                }
            }
            if (!loginInfo.sdkAppID) {
                if (cbErr) {
                    cbErr(tool.getReturnError("loginInfo.sdkAppID is empty", -7));
                    return;
                }
            }
            // if (!loginInfo.accountType) {
            //     if (cbErr) {
            //         cbErr(tool.getReturnError("loginInfo.accountType is empty", -8));
            //         return;
            //     }
            // }

            if (loginInfo.identifier) {
                ctx.identifier = loginInfo.identifier.toString();
            }
            if (loginInfo.identifier && !loginInfo.userSig) {
                if (cbErr) {
                    cbErr(tool.getReturnError("loginInfo.userSig is empty", -9));
                    return;
                }
            }
            if (loginInfo.userSig) {
                ctx.userSig = loginInfo.userSig.toString();
            }
            ctx.sdkAppID = loginInfo.sdkAppID;
            ctx.accountType = Math.ceil(Math.random() * 10000);

            if (ctx.identifier && ctx.userSig) { //带登录态
                proto_accesslayer(function () {
                    //登录
                    proto_login(
                        function (identifierNick, headurl) {
                            MsgManager.init(
                                listeners,
                                function (mmInitResp) {
                                    if (cbOk) {
                                        mmInitResp.identifierNick = identifierNick;
                                        mmInitResp.headurl = headurl;
                                        cbOk(mmInitResp);
                                    }
                                }, cbErr
                            );
                        },
                        cbErr
                    );
                })
            } else { //不带登录态，进入直播场景sdk
                MsgManager.init(
                    listeners,
                    cbOk,
                    cbErr
                );
            }
        };

        //初始化浏览器信息
        var initBrowserInfo = function () {
            //初始化浏览器类型
            BROWSER_INFO = "wechat"
        };

        //接口质量上报
        var reportApiQuality = function (cmd, errorCode, errorInfo) {
            if (cmd == 'longpolling' && (errorCode == longPollingTimeOutErrorCode || errorCode == longPollingKickedErrorCode)) { //longpolling 返回60008错误可以视为正常,可以不上报
                return;
            }
            var eventId = CMD_EVENT_ID_MAP[cmd];
            if (eventId) {
                var reportTime = unixtime();
                var uniqKey = null;
                var msgCmdErrorCode = {
                    'Code': errorCode,
                    'ErrMsg': errorInfo
                };
                if (ctx.a2) {
                    uniqKey = ctx.a2.substring(0, 10) + "_" + reportTime + "_" + createRandom();
                } else if (ctx.userSig) {
                    uniqKey = ctx.userSig.substring(0, 10) + "_" + reportTime + "_" + createRandom();
                }

                if (uniqKey) {

                    var rptEvtItem = {
                        "UniqKey": uniqKey,
                        "EventId": eventId,
                        "ReportTime": reportTime,
                        "MsgCmdErrorCode": msgCmdErrorCode
                    };

                    if (cmd == 'login') {
                        var loginApiReportItems = [];
                        loginApiReportItems.push(rptEvtItem);
                        var loginReportOpt = {
                            "EvtItems": loginApiReportItems,
                            "MainVersion": SDK.VERSION,
                            "Version": "0"
                        };
                        proto_reportApiQuality(loginReportOpt,
                            function (resp) {
                                loginApiReportItems = null; //
                            },
                            function (err) {
                                loginApiReportItems = null; //
                            }
                        );
                    } else {
                        apiReportItems.push(rptEvtItem);
                        if (apiReportItems.length >= maxApiReportItemCount) { //累计一定条数再上报
                            var reportOpt = {
                                "EvtItems": apiReportItems,
                                "MainVersion": SDK.VERSION,
                                "Version": "0"
                            };
                            proto_reportApiQuality(reportOpt,
                                function (resp) {
                                    apiReportItems = []; //清空
                                },
                                function (err) {
                                    apiReportItems = []; //清空
                                }
                            );
                        }
                    }

                }
            }
        };

        var proto_accesslayer = function (callback) {
            ConnManager.apiCall(SRV_NAME.WEB_IM, "accesslayer", {}, function (data) {
                if (data.ErrorCode === 0 && data.WebImAccessLayer === 1) {
                    SRV_HOST.FORMAL.COMMON = 'https://events.tim.qq.com';
                }
                callback();
            }, function () {
                callback();
            });
        };
        // REST API calls
        //上线
        var proto_login = function (cbOk, cbErr) {
            ConnManager.apiCall(SRV_NAME.OPEN_IM, "login", {
                    "State": "Online"
                },
                function (loginResp) {
                    if (loginResp.TinyId) {
                        ctx.tinyid = loginResp.TinyId;
                    } else {
                        if (cbErr) {
                            cbErr(tool.getReturnError("TinyId is empty", -10));
                            return;
                        }
                    }
                    if (loginResp.A2Key) {
                        ctx.a2 = loginResp.A2Key;
                    } else {
                        if (cbErr) {
                            cbErr(tool.getReturnError("A2Key is empty", -11));
                            return;
                        }
                    }
                    var tag_list = [
                        "Tag_Profile_IM_Nick",
                        "Tag_Profile_IM_Image"
                    ];
                    var options = {
                        'From_Account': ctx.identifier,
                        'To_Account': [ctx.identifier],
                        'LastStandardSequence': 0,
                        'TagList': tag_list
                    };
                    proto_getProfilePortrait(
                        options,
                        function (resp) {
                            var nick, image;
                            if (resp.UserProfileItem && resp.UserProfileItem.length > 0) {
                                for (var i in resp.UserProfileItem) {
                                    for (var j in resp.UserProfileItem[i].ProfileItem) {
                                        switch (resp.UserProfileItem[i].ProfileItem[j].Tag) {
                                            case 'Tag_Profile_IM_Nick':
                                                nick = resp.UserProfileItem[i].ProfileItem[j].Value;
                                                if (nick) ctx.identifierNick = nick;
                                                break;
                                            case 'Tag_Profile_IM_Image':
                                                image = resp.UserProfileItem[i].ProfileItem[j].Value;
                                                if (image) ctx.headurl = image;
                                                break;
                                        }
                                    }
                                }
                            }
                            if (cbOk) cbOk(ctx.identifierNick, ctx.headurl); //回传当前用户昵称
                        }, cbErr);
                }, cbErr);
        };
        //下线
        var proto_logout = function (type, cbOk, cbErr) {
            if (!checkLogin(cbErr, false)) { //不带登录态
                clearSdk();
                if (cbOk) cbOk({
                    'ActionStatus': ACTION_STATUS.OK,
                    'ErrorCode': 0,
                    'ErrorInfo': 'logout success'
                });
                return;
            }
            if (type == "all") {
                ConnManager.apiCall(SRV_NAME.OPEN_IM, "logout", {},
                    function (resp) {
                        clearSdk();
                        if (cbOk) cbOk(resp);
                    },
                    cbErr);
            } else {
                ConnManager.apiCall(SRV_NAME.OPEN_IM, "longpollinglogout", {
                        LongPollingId: LongPollingId
                    },
                    function (resp) {
                        clearSdk();
                        if (cbOk) cbOk(resp);
                    },
                    cbErr);
            }
        };
        //发送消息，包括私聊和群聊
        var proto_sendMsg = function (msg, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            var msgInfo = null;

            switch (msg.sess.type()) {
                case SESSION_TYPE.C2C:
                    msgInfo = {
                        'From_Account': ctx.identifier,
                        'To_Account': msg.sess.id().toString(),
                        'MsgTimeStamp': msg.time,
                        'MsgSeq': msg.seq,
                        'MsgRandom': msg.random,
                    	'MsgBody': [],
                    	'OfflinePushInfo': msg.offlinePushInfo
                    };
                    break;
                case SESSION_TYPE.GROUP:
                    var subType = msg.getSubType();
                    msgInfo = {
                        'GroupId': msg.sess.id().toString(),
                        'From_Account': ctx.identifier,
                        'Random': msg.random,
                        'MsgBody': []
                    };
                    switch (subType) {
                        case GROUP_MSG_SUB_TYPE.COMMON:
                            msgInfo.MsgPriority = "COMMON";
                            break;
                        case GROUP_MSG_SUB_TYPE.REDPACKET:
                            msgInfo.MsgPriority = "REDPACKET";
                            break;
                        case GROUP_MSG_SUB_TYPE.LOVEMSG:
                            msgInfo.MsgPriority = "LOVEMSG";
                            break;
                        case GROUP_MSG_SUB_TYPE.TIP:
                            log.error("不能主动发送群提示消息,subType=" + subType);
                            break;
                        default:
                            log.error("发送群消息时，出现未知子消息类型：subType=" + subType);
                            return;
                            break;
                    }
                    break;
                default:
                    break;
            }

            for (var i in msg.elems) {
                var elem = msg.elems[i];
                var msgContent = null;
                var msgType = elem.type;
                switch (msgType) {
                    case MSG_ELEMENT_TYPE.TEXT: //文本
                        msgContent = {
                            'Text': elem.content.text
                        };
                        break;
                    case MSG_ELEMENT_TYPE.FACE: //表情
                        msgContent = {
                            'Index': elem.content.index,
                            'Data': elem.content.data
                        };
                        break;
                    case MSG_ELEMENT_TYPE.IMAGE: //图片
                        var ImageInfoArray = [];
                        for (var j in elem.content.ImageInfoArray) {
                            ImageInfoArray.push({
                                'Type': elem.content.ImageInfoArray[j].type,
                                'Size': elem.content.ImageInfoArray[j].size,
                                'Width': elem.content.ImageInfoArray[j].width,
                                'Height': elem.content.ImageInfoArray[j].height,
                                'URL': elem.content.ImageInfoArray[j].url
                            });
                        }
                        msgContent = {
                            'ImageFormat': elem.content.ImageFormat,
                            'UUID': elem.content.UUID,
                            'ImageInfoArray': ImageInfoArray
                        };
                        break;
                    case MSG_ELEMENT_TYPE.SOUND: //
                        log.warn('web端暂不支持发送语音消息');
                        continue;
                        break;
                    case MSG_ELEMENT_TYPE.LOCATION: //
                        log.warn('web端暂不支持发送地理位置消息');
                        continue;
                        break;
                    case MSG_ELEMENT_TYPE.FILE: //
                        msgContent = {
                            'UUID': elem.content.uuid,
                            'FileName': elem.content.name,
                            'FileSize': elem.content.size,
                            'DownloadFlag': elem.content.downFlag
                        };
                        break;
                    case MSG_ELEMENT_TYPE.CUSTOM: //
                        msgContent = {
                            'Data': elem.content.data,
                            'Desc': elem.content.desc,
                            'Ext': elem.content.ext
                        };
                        msgType = MSG_ELEMENT_TYPE.CUSTOM;
                        break;
                    default:
                        log.warn('web端暂不支持发送' + elem.type + '消息');
                        continue;
                        break;
                }

                if (msg.PushInfoBoolean) {
                    msgInfo.OfflinePushInfo = msg.PushInfo; //当android终端进程被杀掉时才走push，IOS退到后台即可
                }

                msgInfo.MsgBody.push({
                    'MsgType': msgType,
                    'MsgContent': msgContent
                });
            }
            if (msg.sess.type() == SESSION_TYPE.C2C) { //私聊
                ConnManager.apiCall(SRV_NAME.OPEN_IM, "sendmsg", msgInfo, cbOk, cbErr);
            } else if (msg.sess.type() == SESSION_TYPE.GROUP) { //群聊
                ConnManager.apiCall(SRV_NAME.GROUP, "send_group_msg", msgInfo, cbOk, cbErr);
            }
        };
        //长轮询接口
        var proto_longPolling = function (options, cbOk, cbErr) {
            if (!isAccessFormaEnvironment && typeof stopPolling != "undefined" && stopPolling == true) {
                return;
            }
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.OPEN_IM, "longpolling", options, cbOk, cbErr, longPollingDefaultTimeOut, true);
        };

        //长轮询接口(拉取直播聊天室新消息)
        var proto_bigGroupLongPolling = function (options, cbOk, cbErr, timeout) {
            ConnManager.apiCall(SRV_NAME.BIG_GROUP_LONG_POLLING, "get_msg", options, cbOk, cbErr, timeout);
        };

        //拉取未读c2c消息接口
        var proto_getMsgs = function (cookie, syncFlag, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.OPEN_IM, "getmsg", {
                    'Cookie': cookie,
                    'SyncFlag': syncFlag
                },
                function (resp) {

                    if (resp.MsgList && resp.MsgList.length) {
                        for (var i in resp.MsgList) {
                            tempC2CMsgList.push(resp.MsgList[i]);
                        }
                    }
                    if (resp.SyncFlag == 1) {
                        proto_getMsgs(resp.Cookie, resp.SyncFlag, cbOk, cbErr);
                    } else {
                        resp.MsgList = tempC2CMsgList;
                        tempC2CMsgList = [];
                        if (cbOk) cbOk(resp);
                    }
                },
                cbErr);
        };
        //C2C消息已读上报接口
        var proto_c2CMsgReaded = function (cookie, c2CMsgReadedItem, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            var tmpC2CMsgReadedItem = [];
            for (var i in c2CMsgReadedItem) {
                var item = {
                    'To_Account': c2CMsgReadedItem[i].toAccount,
                    'LastedMsgTime': c2CMsgReadedItem[i].lastedMsgTime
                };
                tmpC2CMsgReadedItem.push(item);
            }
            ConnManager.apiCall(SRV_NAME.OPEN_IM, "msgreaded", {
                C2CMsgReaded: {
                    'Cookie': cookie,
                    'C2CMsgReadedItem': tmpC2CMsgReadedItem
                }
            }, cbOk, cbErr);
        };

        //删除c2c消息
        var proto_deleteC2CMsg = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.OPEN_IM, "deletemsg", options,
                cbOk, cbErr);
        };

        //拉取c2c历史消息接口
        var proto_getC2CHistoryMsgs = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.OPEN_IM, "getroammsg", options,
                function (resp) {
                    var reqMsgCount = options.MaxCnt;
                    var complete = resp.Complete;
                    var rspMsgCount = resp.MaxCnt;
                    var msgKey = resp.MsgKey;
                    var lastMsgTime = resp.LastMsgTime;

                    if (resp.MsgList && resp.MsgList.length) {
                        tempC2CHistoryMsgList = resp.MsgList.concat(tempC2CHistoryMsgList);
                    }
                    var netxOptions = null;
                    if (complete == 0) { //还有历史消息可拉取
                        if (rspMsgCount < reqMsgCount) {
                            netxOptions = {
                                'Peer_Account': options.Peer_Account,
                                'MaxCnt': reqMsgCount - rspMsgCount,
                                'LastMsgTime': lastMsgTime,
                                'MsgKey': msgKey
                            };
                        }
                    }

                    if (netxOptions) { //继续拉取
                        proto_getC2CHistoryMsgs(netxOptions, cbOk, cbErr);
                    } else {
                        resp.MsgList = tempC2CHistoryMsgList;
                        tempC2CHistoryMsgList = [];
                        if (cbOk) cbOk(resp);
                    }
                },
                cbErr);
        };

        //群组接口
        //创建群组
        //协议参考：https://www.qcloud.com/doc/product/269/1615
        var proto_createGroup = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            var opt = {
                //必填    群组形态，包括Public（公开群），Private（私有群），ChatRoom（聊天室），AVChatRoom（互动直播聊天室）。
                'Type': options.Type,
                //必填    群名称，最长30字节。
                'Name': options.Name
            };
            var member_list = [];

            //Array 选填  初始群成员列表，最多500个。成员信息字段详情参见：群成员资料。
            for (var i = 0; i < options.MemberList.length; i++) {
                member_list.push({
                    'Member_Account': options.MemberList[i]
                })
            }
            opt.MemberList = member_list;
            //选填    为了使得群组ID更加简单，便于记忆传播，腾讯云支持APP在通过REST API创建群组时自定义群组ID。详情参见：自定义群组ID。
            if (options.GroupId) {
                opt.GroupId = options.GroupId;
            }
            //选填    群主id，自动添加到群成员中。如果不填，群没有群主。
            if (options.Owner_Account) {
                opt.Owner_Account = options.Owner_Account;
            }
            //选填    群简介，最长240字节。
            if (options.Introduction) {
                opt.Introduction = options.Introduction;
            }
            //选填    群公告，最长300字节。
            if (options.Notification) {
                opt.Notification = options.Notification;
            }
            //选填    最大群成员数量，最大为10000，不填默认为2000个。
            if (options.MaxMemberCount) {
                opt.MaxMemberCount = options.MaxMemberCount;
            }
            //选填    申请加群处理方式。包含FreeAccess（自由加入），NeedPermission（需要验证），DisableApply（禁止加群），不填默认为NeedPermission（需要验证）。
            if (options.ApplyJoinOption) { //
                opt.ApplyJoinOption = options.ApplyJoinOption;
            }
            //Array 选填  群组维度的自定义字段，默认情况是没有的，需要开通，详情参见：自定义字段。
            if (options.AppDefinedData) {
                opt.AppDefinedData = options.AppDefinedData;
            }
            //选填    群头像URL，最长100字节。
            if (options.FaceUrl) {
                opt.FaceUrl = options.FaceUrl;
            }
            ConnManager.apiCall(SRV_NAME.GROUP, "create_group", opt,
                cbOk, cbErr);
        };

        //创建群组-高级接口
        //协议参考：https://www.qcloud.com/doc/product/269/1615
        var proto_createGroupHigh = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.GROUP, "create_group", options,
                cbOk, cbErr);
        };

        //修改群组基本资料
        //协议参考：https://www.qcloud.com/doc/product/269/1620
        var proto_modifyGroupBaseInfo = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "modify_group_base_info", options,
                cbOk, cbErr);
        };

        //申请加群
        var proto_applyJoinGroup = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            options.GroupId = String(options.GroupId)
            ConnManager.apiCall(SRV_NAME.GROUP, "apply_join_group", {
                    'GroupId': options.GroupId,
                    'ApplyMsg': options.ApplyMsg,
                    'UserDefinedField': options.UserDefinedField
                },
                cbOk, cbErr);
        };

        //申请加入大群
    // var BigGroupId;
        var proto_applyJoinBigGroup = function (options, cbOk, cbErr) {
            options.GroupId = String(options.GroupId)
        //BigGroupId = options.GroupId;
            var srvName;
            if (!checkLogin(cbErr, false)) { //未登录
                srvName = SRV_NAME.BIG_GROUP;
            } else { //已登录
                srvName = SRV_NAME.GROUP;
        }
        if( MsgManager.checkBigGroupLongPollingOn( options.GroupId ) ) {
            cbErr && cbErr(tool.getReturnError("Join Group failed; You have already been in this group, you have to quit group before you rejoin", 10013));
            return;
            }
            ConnManager.apiCall(srvName, "apply_join_group", {
                    'GroupId': options.GroupId,
                    'ApplyMsg': options.ApplyMsg,
                    'UserDefinedField': options.UserDefinedField
                },
                function (resp) {
                    if (resp.JoinedStatus && resp.JoinedStatus == 'JoinedSuccess') {
                        if (resp.LongPollingKey) {
                            MsgManager.setBigGroupLongPollingOn(true); //开启长轮询
                        MsgManager.setBigGroupLongPollingKey(options.GroupId, resp.LongPollingKey); //更新大群长轮询key
                            MsgManager.setBigGroupLongPollingMsgMap(options.GroupId, 0); //收到的群消息置0
                        MsgManager.bigGroupLongPolling( options.GroupId ); //开启长轮询
                        } else { //没有返回LongPollingKey，说明申请加的群不是直播聊天室(AVChatRoom)
                            cbErr && cbErr(tool.getReturnError("Join Group succeed; But the type of group is not AVChatRoom: groupid=" + options.GroupId, -12));
                            return;
                        }
                    }
                    if (cbOk) cbOk(resp);
                },
                function (err) {

                    if (cbErr) cbErr(err);
                });
        };

        //处理加群申请(同意或拒绝)
        var proto_handleApplyJoinGroupPendency = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "handle_apply_join_group", {
                    'GroupId': options.GroupId,
                    'Applicant_Account': options.Applicant_Account,
                    'HandleMsg': options.HandleMsg,
                    'Authentication': options.Authentication,
                    'MsgKey': options.MsgKey,
                    'ApprovalMsg': options.ApprovalMsg,
                    'UserDefinedField': options.UserDefinedField
                },
                cbOk,
                function (err) {
                    if (err.ErrorCode == 10024) { //apply has be handled
                        if (cbOk) {
                            var resp = {
                                'ActionStatus': ACTION_STATUS.OK,
                                'ErrorCode': 0,
                                'ErrorInfo': '该申请已经被处理过'
                            };
                            cbOk(resp);
                        }
                    } else {
                        if (cbErr) cbErr(err);
                    }
                }
            );
        };

        //获取群组未决列表
        var proto_getPendencyGroup = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "get_pendency", {
                    'StartTime': options.StartTime,
                    'Limit': options.Limit,
                    'Handle_Account': ctx.identifier
                },
                cbOk,
                function (err) {

                }
            );
        };


        //群组未决已经上报
        var proto_getPendencyGroupRead = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "report_pendency", {
                    'ReportTime': options.ReportTime,
                    'From_Account': ctx.identifier
                },
                cbOk,
                function (err) {

                }
            );
        };

        //处理被邀请进群申请(同意或拒绝)
        var proto_handleInviteJoinGroupRequest = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "handle_invite_join_group", {
                    'GroupId': options.GroupId,
                    'Inviter_Account': options.Inviter_Account,
                    'HandleMsg': options.HandleMsg,
                    'Authentication': options.Authentication,
                    'MsgKey': options.MsgKey,
                    'ApprovalMsg': options.ApprovalMsg,
                    'UserDefinedField': options.UserDefinedField
                },
                cbOk,
                function (err) {

                }
            );
        };

        //主动退群
        var proto_quitGroup = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "quit_group", {
                    'GroupId': options.GroupId
                },
                cbOk, cbErr);
        };

        //退出大群
        var proto_quitBigGroup = function (options, cbOk, cbErr) {
            var srvName;
            if (!checkLogin(cbErr, false)) { //未登录
                srvName = SRV_NAME.BIG_GROUP;
            } else { //已登录
                srvName = SRV_NAME.GROUP;
            }
        MsgManager.resetBigGroupLongPollingInfo( options.GroupId );
            ConnManager.apiCall(srvName, "quit_group", {
                    'GroupId': options.GroupId
                },
                function (resp) {
                    MsgStore.delSessByTypeId(SESSION_TYPE.GROUP, options.GroupId);
                    //重置当前再请求中的ajax
                    //clearXmlHttpObjMap();
                    //退出大群成功之后需要重置长轮询信息
                    // MsgManager.resetBigGroupLongPollingInfo();
                    if (cbOk) cbOk(resp);
                },
                cbErr);
        };
        //查找群(按名称)
        var proto_searchGroupByName = function (options, cbOk, cbErr) {
            ConnManager.apiCall(SRV_NAME.GROUP, "search_group", options, cbOk, cbErr);
        };

        //获取群组公开资料
        var proto_getGroupPublicInfo = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "get_group_public_info", {
                    'GroupIdList': options.GroupIdList,
                    'ResponseFilter': {
                        'GroupBasePublicInfoFilter': options.GroupBasePublicInfoFilter
                    }
                },
                function (resp) {
                    resp.ErrorInfo = '';
                    if (resp.GroupInfo) {
                        for (var i in resp.GroupInfo) {
                            var errorCode = resp.GroupInfo[i].ErrorCode;
                            if (errorCode > 0) {
                                resp.ActionStatus = ACTION_STATUS.FAIL;
                                resp.GroupInfo[i].ErrorInfo = "[" + errorCode + "]" + resp.GroupInfo[i].ErrorInfo;
                                resp.ErrorInfo += resp.GroupInfo[i].ErrorInfo + '\n';
                            }
                        }
                    }
                    if (resp.ActionStatus == ACTION_STATUS.FAIL) {
                        if (cbErr) {
                            cbErr(resp);
                        }
                    } else if (cbOk) {
                        cbOk(resp);
                    }

                },
                cbErr);
        };

        //获取群组详细资料--高级
        //请求协议参考：https://www.qcloud.com/doc/product/269/1616
        var proto_getGroupInfo = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            var opt = {
                'GroupIdList': options.GroupIdList,
                'ResponseFilter': {
                    'GroupBaseInfoFilter': options.GroupBaseInfoFilter,
                    'MemberInfoFilter': options.MemberInfoFilter
                }
            };
            if (options.AppDefinedDataFilter_Group) {
                opt.ResponseFilter.AppDefinedDataFilter_Group = options.AppDefinedDataFilter_Group;
            }
            if (options.AppDefinedDataFilter_GroupMember) {
                opt.ResponseFilter.AppDefinedDataFilter_GroupMember = options.AppDefinedDataFilter_GroupMember;
            }
            ConnManager.apiCall(SRV_NAME.GROUP, "get_group_info", opt,
                cbOk, cbErr);
        };

        //获取群组成员-高级接口
        //协议参考：https://www.qcloud.com/doc/product/269/1617
        var proto_getGroupMemberInfo = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "get_group_member_info", {
                    'GroupId': options.GroupId,
                    'Offset': options.Offset,
                    'Limit': options.Limit,
                    'MemberInfoFilter': options.MemberInfoFilter,
                    'MemberRoleFilter': options.MemberRoleFilter,
                    'AppDefinedDataFilter_GroupMember': options.AppDefinedDataFilter_GroupMember
                },
                cbOk, cbErr);
        };


        //增加群组成员
        //协议参考：https://www.qcloud.com/doc/product/269/1621
        var proto_addGroupMember = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "add_group_member", {
                    'GroupId': options.GroupId,
                    'Silence': options.Silence,
                    'MemberList': options.MemberList
                },
                cbOk, cbErr);
        };
        //修改群组成员资料
        //协议参考：https://www.qcloud.com/doc/product/269/1623
        var proto_modifyGroupMember = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            var opt = {};
            if (options.GroupId) {
                opt.GroupId = options.GroupId;
            }
            if (options.Member_Account) {
                opt.Member_Account = options.Member_Account;
            }
            //Admin或者Member
            if (options.Role) {
                opt.Role = options.Role;
            }
            // AcceptAndNotify代表解收并提示消息，Discard代表不接收也不提示消息，AcceptNotNotify代表接收消息但不提示
            if (options.MsgFlag) {
                opt.MsgFlag = options.MsgFlag;
            }
            if (options.ShutUpTime) { //禁言时间
                opt.ShutUpTime = options.ShutUpTime;
            }
            if (options.NameCard) { //群名片,最大不超过50个字节
                opt.NameCard = options.NameCard;
            }
            if (options.AppMemberDefinedData) { //群成员维度的自定义字段，默认情况是没有的，需要开通
                opt.AppMemberDefinedData = options.AppMemberDefinedData;
            }
            ConnManager.apiCall(SRV_NAME.GROUP, "modify_group_member_info", opt,
                cbOk, cbErr);
        };
        //删除群组成员
        //协议参考：https://www.qcloud.com/doc/product/269/1622
        var proto_deleteGroupMember = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "delete_group_member", {
                    'GroupId': options.GroupId,
                    'Silence': options.Silence,
                    'MemberToDel_Account': options.MemberToDel_Account,
                    'Reason': options.Reason
                },
                cbOk, cbErr);
        };
        //解散群组
        //协议参考：https://www.qcloud.com/doc/product/269/1624
        var proto_destroyGroup = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "destroy_group", {
                    'GroupId': options.GroupId
                },
                cbOk, cbErr);
        };
        //转让群组
        //协议参考：https://www.qcloud.com/doc/product/269/1633
        var proto_changeGroupOwner = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.GROUP, "change_group_owner", options, cbOk, cbErr);
        };
        //获取用户所加入的群组-高级接口
        //协议参考：https://www.qcloud.com/doc/product/269/1625
        var proto_getJoinedGroupListHigh = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "get_joined_group_list", {
                    'Member_Account': options.Member_Account,
                    'Limit': options.Limit,
                    'Offset': options.Offset,
                    'GroupType': options.GroupType,
                    'ResponseFilter': {
                        'GroupBaseInfoFilter': options.GroupBaseInfoFilter,
                        'SelfInfoFilter': options.SelfInfoFilter
                    }
                },
                cbOk, cbErr);
        };
        //查询一组UserId在群中的身份
        //协议参考：https://www.qcloud.com/doc/product/269/1626
        var proto_getRoleInGroup = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "get_role_in_group", {
                    'GroupId': options.GroupId,
                    'User_Account': options.User_Account
                },
                cbOk, cbErr);
        };
        //设置取消成员禁言时间
        //协议参考：https://www.qcloud.com/doc/product/269/1627
        var proto_forbidSendMsg = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            ConnManager.apiCall(SRV_NAME.GROUP, "forbid_send_msg", {
                    'GroupId': options.GroupId,
                    'Members_Account': options.Members_Account,
                    'ShutUpTime': options.ShutUpTime //单位为秒，为0时表示取消禁言
                },
                cbOk, cbErr);
        };

        //发送自定义群系统通知
        var proto_sendCustomGroupNotify = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.GROUP, "send_group_system_notification", options,
                cbOk, cbErr);
        };

        //拉取群消息接口
        var proto_getGroupMsgs = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.GROUP, "group_msg_get", {
                    "GroupId": options.GroupId,
                    "ReqMsgSeq": options.ReqMsgSeq,
                    "ReqMsgNumber": options.ReqMsgNumber
                },
                cbOk, cbErr);
        };
        //群消息已读上报接口
        var proto_groupMsgReaded = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.GROUP, "msg_read_report", {
                    'GroupId': options.GroupId,
                    'MsgReadedSeq': options.MsgReadedSeq
                },
                cbOk, cbErr);
        };
        //end

        //好友接口
        //处理好友接口返回的错误码
        var convertErrorEn2ZhFriend = function (resp) {
            var errorAccount = [];
            if (resp.Fail_Account && resp.Fail_Account.length) {
                errorAccount = resp.Fail_Account;
            }
            if (resp.Invalid_Account && resp.Invalid_Account.length) {
                for (var k in resp.Invalid_Account) {
                    errorAccount.push(resp.Invalid_Account[k]);
                }
            }
            if (errorAccount.length) {
                resp.ActionStatus = ACTION_STATUS.FAIL;
                resp.ErrorCode = ERROR_CODE_CUSTOM;
                resp.ErrorInfo = '';
                for (var i in errorAccount) {
                    var failCount = errorAccount[i];
                    for (var j in resp.ResultItem) {
                        if (resp.ResultItem[j].To_Account == failCount) {

                            var resultCode = resp.ResultItem[j].ResultCode;
                            resp.ResultItem[j].ResultInfo = "[" + resultCode + "]" + resp.ResultItem[j].ResultInfo;
                            resp.ErrorInfo += resp.ResultItem[j].ResultInfo + "\n";
                            break;
                        }
                    }
                }
            }
            return resp;
        };
        //添加好友
        var proto_applyAddFriend = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.FRIEND, "friend_add", {
                    'From_Account': ctx.identifier,
                    'AddFriendItem': options.AddFriendItem
                },
                function (resp) {
                    var newResp = convertErrorEn2ZhFriend(resp);
                    if (newResp.ActionStatus == ACTION_STATUS.FAIL) {
                        if (cbErr) cbErr(newResp);
                    } else if (cbOk) {
                        cbOk(newResp);
                    }
                }, cbErr);
        };
        //删除好友
        var proto_deleteFriend = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.FRIEND, "friend_delete", {
                    'From_Account': ctx.identifier,
                    'To_Account': options.To_Account,
                    'DeleteType': options.DeleteType
                },
                function (resp) {
                    var newResp = convertErrorEn2ZhFriend(resp);
                    if (newResp.ActionStatus == ACTION_STATUS.FAIL) {
                        if (cbErr) cbErr(newResp);
                    } else if (cbOk) {
                        cbOk(newResp);
                    }
                }, cbErr);
        };

        //删除会话
        var proto_deleteChat = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;

            if (options.chatType == 1) {
                ConnManager.apiCall(SRV_NAME.DEL_CHAT, "delete", {
                        'From_Account': ctx.identifier,
                        'Type': options.chatType,
                        'To_Account': options.To_Account
                    },
                    cbOk, cbErr);
            } else {
                ConnManager.apiCall(SRV_NAME.DEL_CHAT, "delete", {
                        'From_Account': ctx.identifier,
                        'Type': options.chatType,
                        'ToGroupid': options.To_Account
                    },
                    cbOk, cbErr);

            }

        };

        //获取好友申请
        var proto_getPendency = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.FRIEND, "pendency_get", {
                    "From_Account": ctx.identifier,
                    "PendencyType": options.PendencyType,
                    "StartTime": options.StartTime,
                    "MaxLimited": options.MaxLimited,
                    "LastSequence": options.LastSequence
                },
                cbOk, cbErr);
        };
        //好友申请已读上报
        var proto_getPendencyReport = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.FRIEND, "PendencyReport", {
                    "From_Account": ctx.identifier,
                    "LatestPendencyTimeStamp": options.LatestPendencyTimeStamp
                },
                cbOk, cbErr);
        };
        //删除好友申请
        var proto_deletePendency = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.FRIEND, "pendency_delete", {
                    "From_Account": ctx.identifier,
                    "PendencyType": options.PendencyType,
                    "To_Account": options.To_Account

                },
                function (resp) {
                    var newResp = convertErrorEn2ZhFriend(resp);
                    if (newResp.ActionStatus == ACTION_STATUS.FAIL) {
                        if (cbErr) cbErr(newResp);
                    } else if (cbOk) {
                        cbOk(newResp);
                    }
                }, cbErr);
        };
        //处理好友申请
        var proto_responseFriend = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.FRIEND, "friend_response", {
                    'From_Account': ctx.identifier,
                    'ResponseFriendItem': options.ResponseFriendItem
                },
                function (resp) {
                    var newResp = convertErrorEn2ZhFriend(resp);
                    if (newResp.ActionStatus == ACTION_STATUS.FAIL) {
                        if (cbErr) cbErr(newResp);
                    } else if (cbOk) {
                        cbOk(newResp);
                    }
                }, cbErr);
        };
        //我的好友
        var proto_getAllFriend = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.FRIEND, "friend_get_all", {
                    'From_Account': ctx.identifier,
                    'TimeStamp': options.TimeStamp,
                    'StartIndex': options.StartIndex,
                    'GetCount': options.GetCount,
                    'LastStandardSequence': options.LastStandardSequence,
                    'TagList': options.TagList
                },
                cbOk, cbErr);
        };

        //资料接口
        //查看个人资料
        var proto_getProfilePortrait = function (options, cbOk, cbErr) {
            if (options.To_Account.length > 100) {
                options.To_Account.length = 100;
                log.error('获取用户资料人数不能超过100人')
            }
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.PROFILE, "portrait_get", {
                    'From_Account': ctx.identifier,
                    'To_Account': options.To_Account,
                    //'LastStandardSequence':options.LastStandardSequence,
                    'TagList': options.TagList
                },
                function (resp) {
                    var errorAccount = [];
                    if (resp.Fail_Account && resp.Fail_Account.length) {
                        errorAccount = resp.Fail_Account;
                    }
                    if (resp.Invalid_Account && resp.Invalid_Account.length) {
                        for (var k in resp.Invalid_Account) {
                            errorAccount.push(resp.Invalid_Account[k]);
                        }
                    }
                    if (errorAccount.length) {
                        resp.ActionStatus = ACTION_STATUS.FAIL;
                        resp.ErrorCode = ERROR_CODE_CUSTOM;
                        resp.ErrorInfo = '';
                        for (var i in errorAccount) {
                            var failCount = errorAccount[i];
                            for (var j in resp.UserProfileItem) {
                                if (resp.UserProfileItem[j].To_Account == failCount) {
                                    var resultCode = resp.UserProfileItem[j].ResultCode;
                                    resp.UserProfileItem[j].ResultInfo = "[" + resultCode + "]" + resp.UserProfileItem[j].ResultInfo;
                                    resp.ErrorInfo += "账号:" + failCount + "," + resp.UserProfileItem[j].ResultInfo + "\n";
                                    break;
                                }
                            }
                        }
                    }
                    if (resp.ActionStatus == ACTION_STATUS.FAIL) {
                        if (cbErr) cbErr(resp);
                    } else if (cbOk) {
                        cbOk(resp);
                    }
                },
                cbErr);
        };

        //设置个人资料
        var proto_setProfilePortrait = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.PROFILE, "portrait_set", {
                    'From_Account': ctx.identifier,
                    'ProfileItem': options.ProfileItem
                },
                function (resp) {
                    for (var i in options.ProfileItem) {
                        var profile = options.ProfileItem[i];
                        if (profile.Tag == 'Tag_Profile_IM_Nick') {
                            ctx.identifierNick = profile.Value; //更新昵称
                            break;
                        }
                    }
                    if (cbOk) cbOk(resp);
                }, cbErr);
        };

        //增加黑名单
        var proto_addBlackList = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.FRIEND, "black_list_add", {
                    'From_Account': ctx.identifier,
                    'To_Account': options.To_Account
                },
                function (resp) {
                    var newResp = convertErrorEn2ZhFriend(resp);
                    if (newResp.ActionStatus == ACTION_STATUS.FAIL) {
                        if (cbErr) cbErr(newResp);
                    } else if (cbOk) {
                        cbOk(newResp);
                    }
                }, cbErr);
        };

        //删除黑名单
        var proto_deleteBlackList = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.FRIEND, "black_list_delete", {
                    'From_Account': ctx.identifier,
                    'To_Account': options.To_Account
                },
                function (resp) {
                    var newResp = convertErrorEn2ZhFriend(resp);
                    if (newResp.ActionStatus == ACTION_STATUS.FAIL) {
                        if (cbErr) cbErr(newResp);
                    } else if (cbOk) {
                        cbOk(newResp);
                    }
                }, cbErr);
        };

        //我的黑名单
        var proto_getBlackList = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.FRIEND, "black_list_get", {
                    'From_Account': ctx.identifier,
                    'StartIndex': options.StartIndex,
                    'MaxLimited': options.MaxLimited,
                    'LastSequence': options.LastSequence
                },
                cbOk, cbErr);
        };

        //获取最近联系人
        var proto_getRecentContactList = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.RECENT_CONTACT, "get", {
                    'From_Account': ctx.identifier,
                    'Count': options.Count
                },
                cbOk, cbErr);
        };

        //上传图片或文件
        var proto_uploadPic = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            var cmdName;
            if (isAccessFormalEnv()) {
                cmdName = 'pic_up';
            } else {
                cmdName = 'pic_up_test';
            }
            ConnManager.apiCall(SRV_NAME.PIC, cmdName, {
                    'App_Version': VERSION_INFO.APP_VERSION,
                    'From_Account': ctx.identifier,
                    'To_Account': options.To_Account,
                    'Seq': options.Seq,
                    'Timestamp': options.Timestamp,
                    'Random': options.Random,
                    'File_Str_Md5': options.File_Str_Md5,
                    'File_Size': options.File_Size,
                    'File_Type': options.File_Type,
                    'Server_Ver': VERSION_INFO.SERVER_VERSION,
                    'Auth_Key': authkey,
                    'Busi_Id': options.Busi_Id,
                    'PkgFlag': options.PkgFlag,
                    'Slice_Offset': options.Slice_Offset,
                    'Slice_Size': options.Slice_Size,
                    'Slice_Data': options.Slice_Data
                },
                cbOk, cbErr);
        };

        //获取语音和文件下载IP和authkey
        var proto_getIpAndAuthkey = function (cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.OPEN_IM, "authkey", {}, cbOk, cbErr);
        };

        //接口质量上报
        var proto_reportApiQuality = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.IM_OPEN_STAT, "web_report", options, cbOk, cbErr);
        };


        var proto_getLongPollingId = function (options, cbOk, cbErr) {
            if (!checkLogin(cbErr, true)) return;
            ConnManager.apiCall(SRV_NAME.OPEN_IM, "getlongpollingid", {},
                function (resp) {
                    cbOk && cbOk(resp);
                }, cbErr);
        }


        var proto_applyDownload = function (options, cbOk, cbErr) {
            //把下载地址push到map中
            ConnManager.apiCall(SRV_NAME.PIC, "apply_download", options, cbOk, cbErr);
        }

        //end
        initBrowserInfo();
        // singleton object ConnManager
        var ConnManager = new function () {
            var onConnCallback = null; //回调函数
            this.init = function (onConnNotify, cbOk, cbErr) {
                if (onConnNotify) onConnCallback = onConnNotify;
            };
            this.callBack = function (info) {
                if (onConnCallback) onConnCallback(info);
            };
            this.clear = function () {
                onConnCallback = null;
            };
            //请求后台服务接口
            this.apiCall = function (type, cmd, data, cbOk, cbErr, timeout, isLongPolling) {
                //封装后台服务接口地址
                var url = getApiUrl(type, cmd, cbOk, cbErr);
                if (url == false) return;
                //发起ajax请求
                ajaxRequestJson("POST", url, data, timeout, isLongPolling, function (resp) {
                    var errorCode = null,
                        tempErrorInfo = '';
                    if (cmd == 'pic_up') {
                        data.Slice_Data = '';
                    }
                    var info = "\n request url: \n" + url + "\n request body: \n" + JSON.stringify(data) + "\n response: \n" + JSON.stringify(resp);
                    //成功
                    if (resp.ActionStatus == ACTION_STATUS.OK) {
                        log.info("[" + type + "][" + cmd + "]success: " + info);
                        if (cbOk) cbOk(resp); //回调
                        errorCode = 0;
                        tempErrorInfo = '';
                    } else {
                        errorCode = resp.ErrorCode;
                        tempErrorInfo = resp.ErrorInfo;
                        //报错
                        if (cbErr) {
                            resp.SrcErrorInfo = resp.ErrorInfo;
                            resp.ErrorInfo = "[" + type + "][" + cmd + "]failed: " + info;
                            if (cmd != 'longpolling' || resp.ErrorCode != longPollingTimeOutErrorCode) {
                                log.error(resp.ErrorInfo);
                            }
                            cbErr(resp);
                        }
                    }
                    reportApiQuality(cmd, errorCode, tempErrorInfo); //接口质量上报
                }, function (err) {
                    cbErr && cbErr(err);
                    reportApiQuality(cmd, err.ErrorCode, err.ErrorInfo); //接口质量上报
                });
            };
        };
        // class Session
        var Session = function (type, id, name, icon, time, seq) {
            this._impl = {
                skey: Session.skey(type, id),
                type: type,
                id: id,
                name: name,
                icon: icon,
                unread: 0, //未读消息数
                isAutoRead: false,
                time: time >= 0 ? time : 0,
                curMaxMsgSeq: seq >= 0 ? seq : 0,
                msgs: [],
                isFinished: 1
            };
        };
        Session.skey = function (type, id) {
            return type + id;
        };
        Session.prototype.type = function () {
            return this._impl.type;
        };
        Session.prototype.id = function () {
            return this._impl.id;
        };
        Session.prototype.name = function () {
            return this._impl.name;
        };
        Session.prototype.icon = function () {
            return this._impl.icon;
        };
        Session.prototype.unread = function (val) {
            if (typeof val !== 'undefined') {
                this._impl.unread = val;
            } else {
                return this._impl.unread;
            }
        };
        Session.prototype.isFinished = function (val) {
            if (typeof val !== 'undefined') {
                this._impl.isFinished = val;
            } else {
                return this._impl.isFinished;
            }
        };
        Session.prototype.time = function () {
            return this._impl.time;
        };
        Session.prototype.curMaxMsgSeq = function (seq) {
            if (typeof seq !== 'undefined') {
                this._impl.curMaxMsgSeq = seq;
            } else {
                return this._impl.curMaxMsgSeq;
            }
        };
        Session.prototype.msgCount = function () {
            return this._impl.msgs.length;
        };
        Session.prototype.msg = function (index) {
            return this._impl.msgs[index];
        };
        Session.prototype.msgs = function () {
            return this._impl.msgs;
        };
        Session.prototype._impl_addMsg = function (msg, unread) {
            this._impl.msgs.push(msg);
            //if (!msg.isSend && msg.time > this._impl.time)
            if (msg.time > this._impl.time)
                this._impl.time = msg.time;
            //if (!msg.isSend && msg.seq > this._impl.curMaxMsgSeq)
            if (msg.seq > this._impl.curMaxMsgSeq)
                this._impl.curMaxMsgSeq = msg.seq;
            //自己发送的消息不计入未读数
            if (!msg.isSend && !this._impl.isAutoRead && unread) {
                this._impl.unread++;
            }
        };
        //class C2CMsgReadedItem
        var C2CMsgReadedItem = function (toAccount, lastedMsgTime) {
            this.toAccount = toAccount;
            this.lastedMsgTime = lastedMsgTime;
        }


        // class Msg
        var Msg = function (sess, isSend, seq, random, time, fromAccount, subType, fromAccountNick, fromAccountHeadurl) {
            this.sess = sess;
            this.subType = subType >= 0 ? subType : 0; //消息类型,c2c消息时，type取值为0；group消息时，type取值0和1，0-普通群消息，1-群提示消息
            this.fromAccount = fromAccount;
            this.fromAccountNick = fromAccountNick ? fromAccountNick : fromAccount;
            this.fromAccountHeadurl = fromAccountHeadurl || null;
            this.isSend = Boolean(isSend);
            this.seq = seq >= 0 ? seq : nextSeq();
            this.random = random >= 0 ? random : createRandom();
            this.time = time >= 0 ? time : unixtime();
            this.elems = [];
            var type = sess.type();
            switch (type) {
                case SESSION_TYPE.GROUP:
                    break;
                case SESSION_TYPE.C2C:
                default:
                    break;
            }


        };
        Msg.prototype.getSession = function () {
            return this.sess;
        };
        Msg.prototype.getType = function () {
            return this.subType;
        };
        Msg.prototype.getSubType = function () {
            return this.subType;
        };
        Msg.prototype.getFromAccount = function () {
            return this.fromAccount;
        };
        Msg.prototype.getFromAccountNick = function () {
            return this.fromAccountNick;
        };
        Msg.prototype.getIsSend = function () {
            return this.isSend;
        };
        Msg.prototype.getSeq = function () {
            return this.seq;
        };
        Msg.prototype.getTime = function () {
            return this.time;
        };
        Msg.prototype.getRandom = function () {
            return this.random;
        };
        Msg.prototype.getElems = function () {
            return this.elems;
        };
        Msg.prototype.getMsgUniqueId = function () {
            return this.uniqueId;
        };
        //文本
        Msg.prototype.addText = function (text) {
            this.addElem(new webim.Msg.Elem(MSG_ELEMENT_TYPE.TEXT, text));
        };
        //表情
        Msg.prototype.addFace = function (face) {
            this.addElem(new webim.Msg.Elem(MSG_ELEMENT_TYPE.FACE, face));
        };
        //图片
        Msg.prototype.addImage = function (image) {
            this.addElem(new webim.Msg.Elem(MSG_ELEMENT_TYPE.IMAGE, image));
        };
        //地理位置
        Msg.prototype.addLocation = function (location) {
            this.addElem(new webim.Msg.Elem(MSG_ELEMENT_TYPE.LOCATION, location));
        };
        //文件
        Msg.prototype.addFile = function (file) {
            this.addElem(new webim.Msg.Elem(MSG_ELEMENT_TYPE.FILE, file));
        };
        //自定义
        Msg.prototype.addCustom = function (custom) {
            this.addElem(new webim.Msg.Elem(MSG_ELEMENT_TYPE.CUSTOM, custom));
        };
        Msg.prototype.addElem = function (elem) {
            this.elems.push(elem);
        };
        Msg.prototype.toHtml = function () {
            var html = "";
            for (var i in this.elems) {
                var elem = this.elems[i];
                html += elem.toHtml();
            }
            return html;
        };

        // class Msg.Elem
        Msg.Elem = function (type, value) {
            this.type = type;
            this.content = value;
        };
        Msg.Elem.prototype.getType = function () {
            return this.type;
        };
        Msg.Elem.prototype.getContent = function () {
            return this.content;
        };
        Msg.Elem.prototype.toHtml = function () {
            var html;
            html = this.content.toHtml();
            return html;
        };

        // class Msg.Elem.Text
        Msg.Elem.Text = function (text) {
            this.text = tool.xssFilter(text);
        };
        Msg.Elem.Text.prototype.getText = function () {
            return this.text;
        };
        Msg.Elem.Text.prototype.toHtml = function () {
            return this.text;
        };

        // class Msg.Elem.Face
        Msg.Elem.Face = function (index, data) {
            this.index = index;
            this.data = data;
        };
        Msg.Elem.Face.prototype.getIndex = function () {
            return this.index;
        };
        Msg.Elem.Face.prototype.getData = function () {
            return this.data;
        };
        Msg.Elem.Face.prototype.toHtml = function () {
            var faceUrl = null;
            var index = emotionDataIndexs[this.data];
            var emotion = emotions[index];
            if (emotion && emotion[1]) {
                faceUrl = emotion[1];
            }
            if (faceUrl) {
                return "<img src='" + faceUrl + "'/>";
            } else {
                return this.data;
            }
        };

        // 地理位置消息 class Msg.Elem.Location
        Msg.Elem.Location = function (longitude, latitude, desc) {
            this.latitude = latitude; //纬度
            this.longitude = longitude; //经度
            this.desc = desc; //描述
        };
        Msg.Elem.Location.prototype.getLatitude = function () {
            return this.latitude;
        };
        Msg.Elem.Location.prototype.getLongitude = function () {
            return this.longitude;
        };
        Msg.Elem.Location.prototype.getDesc = function () {
            return this.desc;
        };
        Msg.Elem.Location.prototype.toHtml = function () {
            return '经度=' + this.longitude + ',纬度=' + this.latitude + ',描述=' + this.desc;
        };

        //图片消息
        // class Msg.Elem.Images
        Msg.Elem.Images = function (imageId, format) {
            this.UUID = imageId;
            if (typeof format !== 'number') {
                format = parseInt(IMAGE_FORMAT[format] || IMAGE_FORMAT['UNKNOWN'], 10);
            }
            this.ImageFormat = format;
            this.ImageInfoArray = [];
        };
        Msg.Elem.Images.prototype.addImage = function (image) {
            this.ImageInfoArray.push(image);
        };
        Msg.Elem.Images.prototype.toHtml = function () {
            var smallImage = this.getImage(IMAGE_TYPE.SMALL);
            var bigImage = this.getImage(IMAGE_TYPE.LARGE);
            var oriImage = this.getImage(IMAGE_TYPE.ORIGIN);
            if (!bigImage) {
                bigImage = smallImage;
            }
            if (!oriImage) {
                oriImage = smallImage;
            }
            return "<img src='" + smallImage.getUrl() + "#" + bigImage.getUrl() + "#" + oriImage.getUrl() + "' style='CURSOR: hand' id='" + this.getImageId() + "' bigImgUrl='" + bigImage.getUrl() + "' onclick='imageClick(this)' />";

        };
        Msg.Elem.Images.prototype.getImageId = function () {
            return this.UUID;
        };
        Msg.Elem.Images.prototype.getImageFormat = function () {
            return this.ImageFormat;
        };
        Msg.Elem.Images.prototype.getImage = function (type) {
            for (var i in this.ImageInfoArray) {
                if (this.ImageInfoArray[i].getType() == type) {
                    return this.ImageInfoArray[i];
                }
            }
            var img = null;
            this.ImageInfoArray.forEach(function (image) {
                if (image.getType() == type) {
                    img = image;
                }
            })
            return img;
        };
        // class Msg.Elem.Images.Image
        Msg.Elem.Images.Image = function (type, size, width, height, url) {
            this.type = type;
            this.size = size;
            this.width = width;
            this.height = height;
            this.url = url;
        };
        Msg.Elem.Images.Image.prototype.getType = function () {
            return this.type;
        };
        Msg.Elem.Images.Image.prototype.getSize = function () {
            return this.size;
        };
        Msg.Elem.Images.Image.prototype.getWidth = function () {
            return this.width;
        };
        Msg.Elem.Images.Image.prototype.getHeight = function () {
            return this.height;
        };
        Msg.Elem.Images.Image.prototype.getUrl = function () {
            return this.url;
        };

        // class Msg.Elem.Sound
        Msg.Elem.Sound = function (uuid, second, size, senderId, receiverId, downFlag, chatType, url) {
            this.uuid = uuid; //文件id
            this.second = second; //时长，单位：秒
            this.size = size; //大小，单位：字节
            this.senderId = senderId; //发送者
            this.receiverId = receiverId; //接收方id
            this.downFlag = downFlag; //下载标志位
            this.busiId = chatType == SESSION_TYPE.C2C ? 2 : 1; //busi_id ( 1：群    2:C2C)

            //根据不同情况拉取数据
            //是否需要申请下载地址  0:到架平申请  1:到cos申请  2:不需要申请, 直接拿url下载
            if (downFlag==2 && url!=null) {
                this.downUrl= url;
            } else {
                if (this.downFlag !== undefined && this.busiId !== undefined) {
                    getFileDownUrlV2(uuid, senderId, second, downFlag, receiverId, this.busiId, UPLOAD_RES_TYPE.SOUND);
                } else {
                    this.downUrl = getSoundDownUrl(uuid, senderId, second); //下载地址
                }
            }
        };
        Msg.Elem.Sound.prototype.getUUID = function () {
            return this.uuid;
        };
        Msg.Elem.Sound.prototype.getSecond = function () {
            return this.second;
        };
        Msg.Elem.Sound.prototype.getSize = function () {
            return this.size;
        };
        Msg.Elem.Sound.prototype.getSenderId = function () {
            return this.senderId;
        };
        Msg.Elem.Sound.prototype.getDownUrl = function () {
            return this.downUrl;
        };
        Msg.Elem.Sound.prototype.toHtml = function () {
            if (BROWSER_INFO.type == 'ie' && parseInt(BROWSER_INFO.ver) <= 8) {
                return '[这是一条语音消息]demo暂不支持ie8(含)以下浏览器播放语音,语音URL:' + this.downUrl;
            }
            return '<audio id="uuid_' + this.uuid + '" src="' + this.downUrl + '" controls="controls" onplay="onChangePlayAudio(this)" preload="none"></audio>';
        };

        // class Msg.Elem.File
        Msg.Elem.File = function (uuid, name, size, senderId, receiverId, downFlag, chatType) {
            this.uuid = uuid; //文件id
            this.name = name; //文件名
            this.size = size; //大小，单位：字节
            this.senderId = senderId; //发送者
            this.receiverId = receiverId; //接收方id
            this.downFlag = downFlag; //下载标志位

            this.busiId = chatType == SESSION_TYPE.C2C ? 2 : 1; //busi_id ( 1：群    2:C2C)
            //根据不同情况拉取数据
            //是否需要申请下载地址  0:到架平申请  1:到cos申请  2:不需要申请, 直接拿url下载
            if (downFlag==2 && url!=null) {
                this.downUrl= url;
            } else {
                if (downFlag !== undefined && this.busiId !== undefined) {
                    getFileDownUrlV2(uuid, senderId, name, downFlag, receiverId, this.busiId, UPLOAD_RES_TYPE.FILE);
                } else {
                    this.downUrl = getFileDownUrl(uuid, senderId, name); //下载地址
                }
            }
        };
        Msg.Elem.File.prototype.getUUID = function () {
            return this.uuid;
        };
        Msg.Elem.File.prototype.getName = function () {
            return this.name;
        };
        Msg.Elem.File.prototype.getSize = function () {
            return this.size;
        };
        Msg.Elem.File.prototype.getSenderId = function () {
            return this.senderId;
        };
        Msg.Elem.File.prototype.getDownUrl = function () {
            return this.downUrl;
        };
        Msg.Elem.File.prototype.getDownFlag = function () {
            return this.downFlag;
        };
        Msg.Elem.File.prototype.toHtml = function () {
            var fileSize, unitStr;
            fileSize = this.size;
            unitStr = "Byte";
            if (this.size >= 1024) {
                fileSize = Math.round(this.size / 1024);
                unitStr = "KB";
            }
            return {
                uuid: this.uuid,
                name: this.name,
                size: fileSize,
                unitStr: unitStr
            };
        };

        // class Msg.Elem.GroupTip 群提示消息对象
        Msg.Elem.GroupTip = function (opType, opUserId, groupId, groupName, userIdList, userinfo) {
            this.opType = opType; //操作类型
            this.opUserId = opUserId; //操作者id
            this.groupId = groupId; //群id
            this.groupName = groupName; //群名称
            this.userIdList = userIdList ? userIdList : []; //被操作的用户id列表
            this.groupInfoList = []; //新的群资料信息，群资料变更时才有值
            this.memberInfoList = []; //新的群成员资料信息，群成员资料变更时才有值
            this.groupMemberNum = null; //群成员数，操作类型为加群或者退群时才有值
            this.userinfo = userinfo ? userinfo : []; //被操作的用户信息列表列表
        };
        Msg.Elem.GroupTip.prototype.addGroupInfo = function (groupInfo) {
            this.groupInfoList.push(groupInfo);
        };
        Msg.Elem.GroupTip.prototype.addMemberInfo = function (memberInfo) {
            this.memberInfoList.push(memberInfo);
        };
        Msg.Elem.GroupTip.prototype.getOpType = function () {
            return this.opType;
        };
        Msg.Elem.GroupTip.prototype.getOpUserId = function () {
            return this.opUserId;
        };
        Msg.Elem.GroupTip.prototype.getGroupId = function () {
            return this.groupId;
        };
        Msg.Elem.GroupTip.prototype.getGroupName = function () {
            return this.groupName;
        };
        Msg.Elem.GroupTip.prototype.getUserIdList = function () {
            return this.userIdList;
        };
        Msg.Elem.GroupTip.prototype.getUserInfo = function () {
            return this.userinfo;
        };
        Msg.Elem.GroupTip.prototype.getGroupInfoList = function () {
            return this.groupInfoList;
        };
        Msg.Elem.GroupTip.prototype.getMemberInfoList = function () {
            return this.memberInfoList;
        };
        Msg.Elem.GroupTip.prototype.getGroupMemberNum = function () {
            return this.groupMemberNum;
        };
        Msg.Elem.GroupTip.prototype.setGroupMemberNum = function (groupMemberNum) {
            return this.groupMemberNum = groupMemberNum;
        };
        Msg.Elem.GroupTip.prototype.toHtml = function () {
            var text = "[群提示消息]";
            var maxIndex = GROUP_TIP_MAX_USER_COUNT - 1;
            switch (this.opType) {
                case GROUP_TIP_TYPE.JOIN: //加入群
                    text += this.opUserId + "邀请了";
                    for (var m in this.userIdList) {
                        text += this.userIdList[m] + ",";
                        if (this.userIdList.length > GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                            text += "等" + this.userIdList.length + "人";
                            break;
                        }
                    }
                    text += "加入该群";
                    break;
                case GROUP_TIP_TYPE.QUIT: //退出群
                    text += this.opUserId + "主动退出该群";
                    break;
                case GROUP_TIP_TYPE.KICK: //踢出群
                    text += this.opUserId + "将";
                    for (var m in this.userIdList) {
                        text += this.userIdList[m] + ",";
                        if (this.userIdList.length > GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                            text += "等" + this.userIdList.length + "人";
                            break;
                        }
                    }
                    text += "踢出该群";
                    break;
                case GROUP_TIP_TYPE.SET_ADMIN: //设置管理员
                    text += this.opUserId + "将";
                    for (var m in this.userIdList) {
                        text += this.userIdList[m] + ",";
                        if (this.userIdList.length > GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                            text += "等" + this.userIdList.length + "人";
                            break;
                        }
                    }
                    text += "设为管理员";
                    break;
                case GROUP_TIP_TYPE.CANCEL_ADMIN: //取消管理员
                    text += this.opUserId + "取消";
                    for (var m in this.userIdList) {
                        text += this.userIdList[m] + ",";
                        if (this.userIdList.length > GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                            text += "等" + this.userIdList.length + "人";
                            break;
                        }
                    }
                    text += "的管理员资格";
                    break;


                case GROUP_TIP_TYPE.MODIFY_GROUP_INFO: //群资料变更
                    text += this.opUserId + "修改了群资料：";
                    for (var m in this.groupInfoList) {
                        var type = this.groupInfoList[m].getType();
                        var value = this.groupInfoList[m].getValue();
                        switch (type) {
                            case GROUP_TIP_MODIFY_GROUP_INFO_TYPE.FACE_URL:
                                text += "群头像为" + value + "; ";
                                break;
                            case GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NAME:
                                text += "群名称为" + value + "; ";
                                break;
                            case GROUP_TIP_MODIFY_GROUP_INFO_TYPE.OWNER:
                                text += "群主为" + value + "; ";
                                break;
                            case GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NOTIFICATION:
                                text += "群公告为" + value + "; ";
                                break;
                            case GROUP_TIP_MODIFY_GROUP_INFO_TYPE.INTRODUCTION:
                                text += "群简介为" + value + "; ";
                                break;
                            default:
                                text += "未知信息为:type=" + type + ",value=" + value + "; ";
                                break;
                        }
                    }
                    break;

                case GROUP_TIP_TYPE.MODIFY_MEMBER_INFO: //群成员资料变更(禁言时间)
                    text += this.opUserId + "修改了群成员资料:";
                    for (var m in this.memberInfoList) {
                        var userId = this.memberInfoList[m].getUserId();
                        var shutupTime = this.memberInfoList[m].getShutupTime();
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
                        if (this.memberInfoList.length > GROUP_TIP_MAX_USER_COUNT && m == maxIndex) {
                            text += "等" + this.memberInfoList.length + "人";
                            break;
                        }
                    }
                    break;

                case GROUP_TIP_TYPE.READED: //消息已读
                    /**/
                    Log.info("消息已读同步")
                    break;
                default:
                    text += "未知群提示消息类型：type=" + this.opType;
                    break;
            }
            return text;
        };

        // class Msg.Elem.GroupTip.GroupInfo，变更的群资料信息对象
        Msg.Elem.GroupTip.GroupInfo = function (type, value) {
            this.type = type; //群资料信息类型
            this.value = value; //对应的值
        };
        Msg.Elem.GroupTip.GroupInfo.prototype.getType = function () {
            return this.type;
        };
        Msg.Elem.GroupTip.GroupInfo.prototype.getValue = function () {
            return this.value;
        };

        // class Msg.Elem.GroupTip.MemberInfo，变更的群成员资料信息对象
        Msg.Elem.GroupTip.MemberInfo = function (userId, shutupTime) {
            this.userId = userId; //群成员id
            this.shutupTime = shutupTime; //群成员被禁言时间，0表示取消禁言，大于0表示被禁言时长，单位：秒
        };
        Msg.Elem.GroupTip.MemberInfo.prototype.getUserId = function () {
            return this.userId;
        };
        Msg.Elem.GroupTip.MemberInfo.prototype.getShutupTime = function () {
            return this.shutupTime;
        };

        // 自定义消息类型 class Msg.Elem.Custom
        Msg.Elem.Custom = function (data, desc, ext) {
            this.data = data; //数据
            this.desc = desc; //描述
            this.ext = ext; //扩展字段
        };
        Msg.Elem.Custom.prototype.getData = function () {
            return this.data;
        };
        Msg.Elem.Custom.prototype.getDesc = function () {
            return this.desc;
        };
        Msg.Elem.Custom.prototype.getExt = function () {
            return this.ext;
        };
        Msg.Elem.Custom.prototype.toHtml = function () {
            return this.data;
        };

        // singleton object MsgStore
        var MsgStore = new function () {
            var sessMap = {}; //跟所有用户或群的聊天记录MAP
            var sessTimeline = []; //按时间降序排列的会话列表
            msgCache = {}; //消息缓存，用于判重
            //C2C
            this.cookie = ""; //上一次拉取新c2c消息的cookie
            this.syncFlag = 0; //上一次拉取新c2c消息的是否继续拉取标记

            var visitSess = function (visitor) {
                for (var i in sessMap) {
                    visitor(sessMap[i]);
                }
            };
            //消息查重
            var checkDupMsg = function (msg) {
                var dup = false;
                var first_key = msg.sess._impl.skey;
                var second_key = [!!msg.isSend? '1': '0' ,msg.seq, msg.random].join('');
                var tempMsg = msgCache[first_key] && msgCache[first_key][second_key];
                if (tempMsg) {
                    dup = true;
                }
                if (msgCache[first_key]) {
                    msgCache[first_key][second_key] = {
                        time: msg.time
                    };
                } else {
                    msgCache[first_key] = {};
                    msgCache[first_key][second_key] = {
                        time: msg.time
                    };
                }
                return dup;
            };

            this.sessMap = function () {
                return sessMap;
            };
            this.sessCount = function () {
                return sessTimeline.length;
            };
            this.sessByTypeId = function (type, id) {
                var skey = Session.skey(type, id);
                if (skey === undefined || skey == null) return null;
                return sessMap[skey];
            };
            this.delSessByTypeId = function (type, id) {
                var skey = Session.skey(type, id);
                if (skey === undefined || skey == null) return false;
                if (sessMap[skey]) {
                    delete sessMap[skey];
                    delete msgCache[skey];
                }
                return true;
            };
            this.resetCookieAndSyncFlag = function () {
                this.cookie = "";
                this.syncFlag = 0;
            };

            //切换将当前会话的自动读取消息标志为isOn,重置其他会话的自动读取消息标志为false
            this.setAutoRead = function (selSess, isOn, isResetAll) {
                if (isResetAll)
                    visitSess(function (s) {
                        s._impl.isAutoRead = false;
                    });
                if (selSess) {
                    selSess._impl.isAutoRead = isOn; //
                    if (isOn) { //是否调用已读上报接口
                        selSess._impl.unread = 0;

                        if (selSess._impl.type == SESSION_TYPE.C2C) { //私聊消息已读上报
                            var tmpC2CMsgReadedItem = [];
                            tmpC2CMsgReadedItem.push(new C2CMsgReadedItem(selSess._impl.id, selSess._impl.time));
                            //调用C2C消息已读上报接口
                            proto_c2CMsgReaded(MsgStore.cookie,
                                tmpC2CMsgReadedItem,
                                function (resp) {
                                    log.info("[setAutoRead]: c2CMsgReaded success");
                                },
                                function (err) {
                                    log.error("[setAutoRead}: c2CMsgReaded failed:" + err.ErrorInfo);
                                });
                        } else if (selSess._impl.type == SESSION_TYPE.GROUP) { //群聊消息已读上报
                            var tmpOpt = {
                                'GroupId': selSess._impl.id,
                                'MsgReadedSeq': selSess._impl.curMaxMsgSeq
                            };
                            //调用group消息已读上报接口
                            proto_groupMsgReaded(tmpOpt,
                                function (resp) {
                                    log.info("groupMsgReaded success");

                                },
                                function (err) {
                                    log.error("groupMsgReaded failed:" + err.ErrorInfo);

                                });
                        }
                    }
                }
            };

            this.c2CMsgReaded = function (opts, cbOk, cbErr) {
                var tmpC2CMsgReadedItem = [];
                tmpC2CMsgReadedItem.push(new C2CMsgReadedItem(opts.To_Account, opts.LastedMsgTime));
                //调用C2C消息已读上报接口
                proto_c2CMsgReaded(MsgStore.cookie,
                    tmpC2CMsgReadedItem,
                    function (resp) {
                        if (cbOk) {
                            log.info("c2CMsgReaded success");
                            cbOk(resp);
                        }
                    },
                    function (err) {
                        if (cbErr) {
                            log.error("c2CMsgReaded failed:" + err.ErrorInfo);
                            cbErr(err);
                        }
                    });
            };

            this.addSession = function (sess) {
                sessMap[sess._impl.skey] = sess;
            };
            this.delSession = function (sess) {
                delete sessMap[sess._impl.skey];
            };
            this.clear = function () {
                sessMap = {}; //跟所有用户或群的聊天记录MAP
                sessTimeline = []; //按时间降序排列的会话列表
                msgCache = {}; //消息缓存，用于判重
                this.cookie = ""; //上一次拉取新c2c消息的cookie
                this.syncFlag = 0; //上一次拉取新c2c消息的是否继续拉取标记
            };
            this.addMsg = function (msg, unread) {
                if (checkDupMsg(msg)) return false;
                var sess = msg.sess;
                if (!sessMap[sess._impl.skey]) this.addSession(sess);
                sess._impl_addMsg(msg, unread);
                return true;
            };
            this.updateTimeline = function () {
                var arr = new Array;
                visitSess(function (sess) {
                    arr.push(sess);
                });
                arr.sort(function (a, b) {
                    return b.time - a.time;
                });
                sessTimeline = arr;
            };
        };
        // singleton object MsgManager
        var MsgManager = new function () {

            var onMsgCallback = null; //新消息(c2c和group)回调

            var onGroupInfoChangeCallback = null; //群资料变化回调
            //收到新群系统消息回调列表
            var onGroupSystemNotifyCallbacks = {
                "1": null,
                "2": null,
                "3": null,
                "4": null,
                "5": null,
                "6": null,
                "7": null,
                "8": null,
                "9": null,
                "10": null,
                "11": null,
                "15": null,
                "255": null,
                "12": null,
            };
            //监听好友系统通知函数
            var onFriendSystemNotifyCallbacks = {
                "1": null,
                "2": null,
                "3": null,
                "4": null,
                "5": null,
                "6": null,
                "7": null,
                "8": null
            };

            var onProfileSystemNotifyCallbacks = {
                "1": null
            };

            var onKickedEventCall = null;

            var onMsgReadCallback = null;

            //普通长轮询
            var longPollingOn = false; //是否开启普通长轮询
            var isLongPollingRequesting = false; //是否在长轮询ing
            var notifySeq = 0; //c2c通知seq
            var noticeSeq = 0; //群消息seq

            //大群长轮询
            var onBigGroupMsgCallback = null; //大群消息回调
            var bigGroupLongPollingOn = false; //是否开启长轮询
            var bigGroupLongPollingStartSeqMap = {}; //请求拉消息的起始seq(大群长轮询)
            var bigGroupLongPollingHoldTime = 90; //客户端长轮询的超时时间，单位是秒(大群长轮询)
            var bigGroupLongPollingKeyMap = null; //客户端加入群组后收到的的Key(大群长轮询)
            var bigGroupLongPollingMsgMap = {}; //记录收到的群消息数

            var onC2cEventCallbacks = {
                "92": null, //消息已读通知,
                "96": null
            };;
            var onAppliedDownloadUrl = null;


            var getLostGroupMsgCount = 0; //补拉丢失的群消息次数
            //我的群当前最大的seq
            var myGroupMaxSeqs = {}; //用于补拉丢失的群消息

            var groupSystemMsgsCache = {}; //群组系统消息缓存,用于判重

            //设置长轮询开关
            //isOn=true 开启
            //isOn=false 停止
            this.setLongPollingOn = function (isOn) {
                longPollingOn = isOn;
            };
            this.getLongPollingOn = function () {
                return longPollingOn;
            };

            //重置长轮询变量
            this.resetLongPollingInfo = function () {
                longPollingOn = false;
                notifySeq = 0;
                noticeSeq = 0;
            };

        //设置大群长轮询开关
        //isOn=true 开启
        //isOn=false 停止
        this.setBigGroupLongPollingOn = function (isOn) {
            bigGroupLongPollingOn = isOn;
        };

        //查看是否存在该轮询，防止多次入群
        this.checkBigGroupLongPollingOn = function ( groupId ) {
            return !!bigGroupLongPollingKeyMap[groupId]
        };
        //设置大群长轮询key
        this.setBigGroupLongPollingKey = function (GroupId, key) {
            bigGroupLongPollingKeyMap[GroupId] = key;
        };
        //重置大群长轮询变量
        this.resetBigGroupLongPollingInfo = function ( groupId ) {
            bigGroupLongPollingOn = false;
            bigGroupLongPollingStartSeqMap[groupId] = 0;
            bigGroupLongPollingKeyMap[groupId] = null;
            bigGroupLongPollingMsgMap[groupId] = {};

            delete bigGroupLongPollingStartSeqMap[groupId];
            delete bigGroupLongPollingKeyMap[groupId];
            delete bigGroupLongPollingMsgMap[groupId];
        };

            //设置群消息数据条数
            this.setBigGroupLongPollingMsgMap = function (groupId, count) {
                var bigGroupLongPollingMsgCount = bigGroupLongPollingMsgMap[groupId];
                if (bigGroupLongPollingMsgCount) {
                    bigGroupLongPollingMsgCount = parseInt(bigGroupLongPollingMsgCount) + count;
                    bigGroupLongPollingMsgMap[groupId] = bigGroupLongPollingMsgCount;
                } else {
                    bigGroupLongPollingMsgMap[groupId] = count;
                }
            };

            //重置
            this.clear = function () {

                onGroupInfoChangeCallback = null;
                onGroupSystemNotifyCallbacks = {
                    "1": null, //申请加群请求（只有管理员会收到）
                    "2": null, //申请加群被同意（只有申请人能够收到）
                    "3": null, //申请加群被拒绝（只有申请人能够收到）
                    "4": null, //被管理员踢出群(只有被踢者接收到)
                    "5": null, //群被解散(全员接收)
                    "6": null, //创建群(创建者接收)
                    "7": null, //邀请加群(被邀请者接收)
                    "8": null, //主动退群(主动退出者接收)
                    "9": null, //设置管理员(被设置者接收)
                    "10": null, //取消管理员(被取消者接收)
                    "11": null, //群已被回收(全员接收)
                    "15": null, //群已被回收(全员接收)
                    "255": null, //用户自定义通知(默认全员接收)
                    "12": null, //邀请加群(被邀请者需要同意)
                };
                onFriendSystemNotifyCallbacks = {
                    "1": null, //好友表增加
                    "2": null, //好友表删除
                    "3": null, //未决增加
                    "4": null, //未决删除
                    "5": null, //黑名单增加
                    "6": null, //黑名单删除
                    "7": null, //未决已读上报
                    "8": null //好友信息(备注，分组)变更
                };
                onProfileSystemNotifyCallbacks = {
                    "1": null //资料修改
                };
                //重置普通长轮询参数
                onMsgCallback = null;
                longPollingOn = false;
                notifySeq = 0; //c2c新消息通知seq
                noticeSeq = 0; //group新消息seq

            //重置大群长轮询参数
            onBigGroupMsgCallback = null;
            bigGroupLongPollingOn = false;
            bigGroupLongPollingStartSeqMap = {};
            bigGroupLongPollingKeyMap = {};
            bigGroupLongPollingMsgMap = {};

                groupSystemMsgsCache = {};

                ipList = []; //文件下载地址
                authkey = null; //文件下载票据
                expireTime = null; //票据超时时间
            };

            //初始化文件下载ip和票据
            var initIpAndAuthkey = function (cbOk, cbErr) {
                proto_getIpAndAuthkey(function (resp) {
                        ipList = resp.IpList;
                        authkey = resp.AuthKey;
                        expireTime = resp.ExpireTime;
                        if (cbOk) cbOk(resp);
                    },
                    function (err) {
                        log.error("initIpAndAuthkey failed:" + err.ErrorInfo);
                        if (cbErr) cbErr(err);
                    }
                );
            };

            //初始化我的群当前最大的seq，用于补拉丢失的群消息
            var initMyGroupMaxSeqs = function (cbOk, cbErr) {
                var opts = {
                    'Member_Account': ctx.identifier,
                    'Limit': 1000,
                    'Offset': 0,
                    'GroupBaseInfoFilter': [
                        'NextMsgSeq'
                    ]
                };
                proto_getJoinedGroupListHigh(opts, function (resp) {
                        if (!resp.GroupIdList || resp.GroupIdList.length == 0) {
                            log.info("initMyGroupMaxSeqs: 目前还没有加入任何群组");
                            if (cbOk) cbOk(resp);
                            return;
                        }
                        for (var i = 0; i < resp.GroupIdList.length; i++) {
                            var group_id = resp.GroupIdList[i].GroupId;
                            var curMaxSeq = resp.GroupIdList[i].NextMsgSeq - 1;
                            myGroupMaxSeqs[group_id] = curMaxSeq;
                        }

                        if (cbOk) cbOk(resp);

                    },
                    function (err) {
                        log.error("initMyGroupMaxSeqs failed:" + err.ErrorInfo);
                        if (cbErr) cbErr(err);
                    }
                );
            };

            //补拉群消息
            var getLostGroupMsgs = function (groupId, reqMsgSeq, reqMsgNumber) {
                getLostGroupMsgCount++;
                //发起一个拉群群消息请求
                var tempOpts = {
                    'GroupId': groupId,
                    'ReqMsgSeq': reqMsgSeq,
                    'ReqMsgNumber': reqMsgNumber
                };
                //发起一个拉群群消息请求
                log.warn("第" + getLostGroupMsgCount + "次补齐群消息,参数=" + JSON.stringify(tempOpts));
                MsgManager.syncGroupMsgs(tempOpts);
            };

            //更新群当前最大消息seq
            var updateMyGroupCurMaxSeq = function (groupId, msgSeq) {
                //更新myGroupMaxSeqs中的群最大seq
                var curMsgSeq = myGroupMaxSeqs[groupId]
                if (curMsgSeq) { //如果存在，比较大小
                    if (msgSeq > curMsgSeq) {
                        myGroupMaxSeqs[groupId] = msgSeq;
                    }
                } else { //不存在，新增
                    myGroupMaxSeqs[groupId] = msgSeq;
                }
            };

            //添加群消息列表
            var addGroupMsgList = function (msgs, new_group_msgs) {
                for (var p in msgs) {
                    var newGroupMsg = msgs[p];
                    //发群消息时，长轮询接口会返回用户自己发的群消息
                    //if(newGroupMsg.From_Account && newGroupMsg.From_Account!=ctx.identifier ){
                    if (newGroupMsg.From_Account) {
                        //false-不是主动拉取的历史消息
                        //true-需要保存到sdk本地session,并且需要判重
                        var msg = handlerGroupMsg(newGroupMsg, false, true);
                        if (msg) { //不为空，加到新消息里
                            new_group_msgs.push(msg);
                        }
                        //更新myGroupMaxSeqs中的群最大seq
                        updateMyGroupCurMaxSeq(newGroupMsg.ToGroupId, newGroupMsg.MsgSeq);
                    }
                }
                return new_group_msgs;
            };

            //处理收到的群普通和提示消息
            var handlerOrdinaryAndTipC2cMsgs = function (eventType, groupMsgArray) {
                var groupMsgMap = {}; //保存收到的C2c消息信息（群号，最小，最大消息seq，消息列表）
                var new_group_msgs = [];
                var minGroupMsgSeq = 99999999;
                var maxGroupMsgSeq = -1;
                for (var j in groupMsgArray) {

                    var groupMsgs = groupMsgMap[groupMsgArray[j].ToGroupId];
                    if (!groupMsgs) {
                        groupMsgs = groupMsgMap[groupMsgArray[j].ToGroupId] = {
                            "min": minGroupMsgSeq, //收到新消息最小seq
                            "max": maxGroupMsgSeq, //收到新消息最大seq
                            "msgs": [] //收到的新消息
                        };
                    }
                    //更新长轮询的群NoticeSeq
                    if (groupMsgArray[j].NoticeSeq > noticeSeq) {
                        log.warn("noticeSeq=" + noticeSeq + ",msgNoticeSeq=" + groupMsgArray[j].NoticeSeq);
                        noticeSeq = groupMsgArray[j].NoticeSeq;
                    }
                    groupMsgArray[j].Event = eventType;
                    groupMsgMap[groupMsgArray[j].ToGroupId].msgs.push(groupMsgArray[j]); //新增一条消息
                    if (groupMsgArray[j].MsgSeq < groupMsgs.min) { //记录最小的消息seq
                        groupMsgMap[groupMsgArray[j].ToGroupId].min = groupMsgArray[j].MsgSeq;
                    }
                    if (groupMsgArray[j].MsgSeq > groupMsgs.max) { //记录最大的消息seq
                        groupMsgMap[groupMsgArray[j].ToGroupId].max = groupMsgArray[j].MsgSeq;
                    }
                }

                for (var groupId in groupMsgMap) {
                    new_group_msgs = addGroupMsgList(groupMsgMap[groupId].msgs, new_group_msgs);
                }
                if (new_group_msgs.length) {
                    MsgStore.updateTimeline();
                }
                if (onMsgCallback && new_group_msgs.length) onMsgCallback(new_group_msgs);

            };

            //处理收到的群普通和提示消息
            var handlerOrdinaryAndTipGroupMsgs = function (eventType, groupMsgArray) {
                var groupMsgMap = {}; //保存收到的群消息信息（群号，最小，最大消息seq，消息列表）
                var new_group_msgs = [];
                var minGroupMsgSeq = 99999999;
                var maxGroupMsgSeq = -1;
                for (var j in groupMsgArray) {

                    var groupMsgs = groupMsgMap[groupMsgArray[j].ToGroupId];
                    if (!groupMsgs) {
                        groupMsgs = groupMsgMap[groupMsgArray[j].ToGroupId] = {
                            "min": minGroupMsgSeq, //收到新消息最小seq
                            "max": maxGroupMsgSeq, //收到新消息最大seq
                            "msgs": [] //收到的新消息
                        };
                    }
                    //更新长轮询的群NoticeSeq
                    if (groupMsgArray[j].NoticeSeq > noticeSeq) {
                        log.warn("noticeSeq=" + noticeSeq + ",msgNoticeSeq=" + groupMsgArray[j].NoticeSeq);
                        noticeSeq = groupMsgArray[j].NoticeSeq;
                    }
                    groupMsgArray[j].Event = eventType;
                    groupMsgMap[groupMsgArray[j].ToGroupId].msgs.push(groupMsgArray[j]); //新增一条消息
                    if (groupMsgArray[j].MsgSeq < groupMsgs.min) { //记录最小的消息seq
                        groupMsgMap[groupMsgArray[j].ToGroupId].min = groupMsgArray[j].MsgSeq;
                    }
                    if (groupMsgArray[j].MsgSeq > groupMsgs.max) { //记录最大的消息seq
                        groupMsgMap[groupMsgArray[j].ToGroupId].max = groupMsgArray[j].MsgSeq;
                    }
                }

                for (var groupId in groupMsgMap) {
                    new_group_msgs = addGroupMsgList(groupMsgMap[groupId].msgs, new_group_msgs);
                }
                if (new_group_msgs.length) {
                    MsgStore.updateTimeline();
                }
                if (onMsgCallback && new_group_msgs.length) onMsgCallback(new_group_msgs);

            };

            //处理新的群提示消息
            var handlerGroupTips = function (groupTips) {
                var new_group_msgs = [];
                for (var o in groupTips) {
                    var groupTip = groupTips[o];
                    //添加event字段
                    groupTip.Event = LONG_POLLINNG_EVENT_TYPE.GROUP_TIP;
                    //更新群消息通知seq
                    if (groupTip.NoticeSeq > noticeSeq) {
                        noticeSeq = groupTip.NoticeSeq;
                    }
                    var msg = handlerGroupMsg(groupTip, false, true);
                    if (msg) {
                        new_group_msgs.push(msg);
                    }
                }
                if (new_group_msgs.length) {
                    MsgStore.updateTimeline();
                }
                if (onMsgCallback && new_group_msgs.length) onMsgCallback(new_group_msgs);
            };

            //处理新的群系统消息
            //isNeedValidRepeatMsg 是否需要判重
            var handlerGroupSystemMsgs = function (groupSystemMsgs, isNeedValidRepeatMsg) {
                for (var k in groupSystemMsgs) {
                    var groupTip = groupSystemMsgs[k];
                    var groupReportTypeMsg = groupTip.MsgBody;
                    var reportType = groupReportTypeMsg.ReportType;
                    //当长轮询返回的群系统消息，才需要更新群消息通知seq
                    if (isNeedValidRepeatMsg == false && groupTip.NoticeSeq && groupTip.NoticeSeq > noticeSeq) {
                        noticeSeq = groupTip.NoticeSeq;
                    }
                    var toAccount = groupTip.GroupInfo.To_Account;
                    //过滤本不应该给自己的系统消息
                    /*if (!toAccount || toAccount != ctx.identifier) {
                 log.error("收到本不应该给自己的系统消息: To_Account=" + toAccount);
                 continue;
                 }*/
                    if (isNeedValidRepeatMsg) {
                        //var key=groupTip.ToGroupId+"_"+reportType+"_"+groupTip.MsgTimeStamp+"_"+groupReportTypeMsg.Operator_Account;
                        var key = groupTip.ToGroupId + "_" + reportType + "_" + groupReportTypeMsg.Operator_Account+"_"+groupTip.ClientSeq;
                        var isExist = groupSystemMsgsCache[key];
                        if (isExist) {
                            log.warn("收到重复的群系统消息：key=" + key);
                            continue;
                        }
                        groupSystemMsgsCache[key] = true;
                    }

                    var notify = {
                        "SrcFlag": 0,
                        "ReportType": reportType,
                        "GroupId": groupTip.ToGroupId,
                        "GroupName": groupTip.GroupInfo.GroupName,
                        "Operator_Account": groupReportTypeMsg.Operator_Account,
                        "MsgTime": groupTip.MsgTimeStamp,
                        "groupReportTypeMsg": groupReportTypeMsg,
                        "MsgSeq": groupTip.ClientSeq, //群系统消息的 ClientSeq 才是可用的，如删除群系统消息的接口 (deleteMsg) 中传的 MsgSeq 参数即 ClientSeq
                        "MsgRandom": groupTip.MsgRandom,
                        "sourceGroupTip": groupTip
                    };
                    switch (reportType) {
                        case GROUP_SYSTEM_TYPE.JOIN_GROUP_REQUEST: //申请加群(只有管理员会接收到)
                            notify["RemarkInfo"] = groupReportTypeMsg.RemarkInfo;
                            notify["MsgKey"] = groupReportTypeMsg.MsgKey;
                            notify["Authentication"] = groupReportTypeMsg.Authentication;
                            notify["UserDefinedField"] = groupTip.UserDefinedField;
                            notify["From_Account"] = groupTip.From_Account;
                            break;
                        case GROUP_SYSTEM_TYPE.JOIN_GROUP_ACCEPT: //申请加群被同意(只有申请人自己接收到)
                        case GROUP_SYSTEM_TYPE.JOIN_GROUP_REFUSE: //申请加群被拒绝(只有申请人自己接收到)
                            notify["RemarkInfo"] = groupReportTypeMsg.RemarkInfo;
                            break;
                        case GROUP_SYSTEM_TYPE.KICK: //被管理员踢出群(只有被踢者接收到)
                        case GROUP_SYSTEM_TYPE.DESTORY: //群被解散(全员接收)
                        case GROUP_SYSTEM_TYPE.CREATE: //创建群(创建者接收, 不展示)
                        case GROUP_SYSTEM_TYPE.INVITED_JOIN_GROUP_REQUEST: //邀请加群(被邀请者接收)
                        case GROUP_SYSTEM_TYPE.INVITED_JOIN_GROUP_REQUEST_AGREE: //邀请加群(被邀请者需同意)
                        case GROUP_SYSTEM_TYPE.QUIT: //主动退群(主动退出者接收, 不展示)
                        case GROUP_SYSTEM_TYPE.SET_ADMIN: //群设置管理员(被设置者接收)
                        case GROUP_SYSTEM_TYPE.CANCEL_ADMIN: //取消管理员(被取消者接收)
                        case GROUP_SYSTEM_TYPE.REVOKE: //群已被回收(全员接收, 不展示)
                            break;
                        case GROUP_SYSTEM_TYPE.READED: //群消息已读同步
                            break;
                        case GROUP_SYSTEM_TYPE.CUSTOM: //用户自定义通知(默认全员接收)
                            notify["UserDefinedField"] = groupReportTypeMsg.UserDefinedField;
                            break;
                        default:
                            log.error("未知群系统消息类型：reportType=" + reportType);
                            break;
                    }

                    if (isNeedValidRepeatMsg) {
                        //注释只收取一种通知
                        // if (reportType == GROUP_SYSTEM_TYPE.JOIN_GROUP_REQUEST) {
                        //回调
                        if (onGroupSystemNotifyCallbacks[reportType]) {
                            onGroupSystemNotifyCallbacks[reportType](notify);
                        } else {
                            log.error("未知群系统消息类型：reportType=" + reportType);
                        }
                        //}
                    } else {
                        //回调
                        if (onGroupSystemNotifyCallbacks[reportType]) {
                            if (reportType == GROUP_SYSTEM_TYPE.READED) {
                                var arr = notify.groupReportTypeMsg.GroupReadInfoArray;
                                for (var i = 0, l = arr.length; i < l; i++) {
                                    var item = arr[i];
                                    onGroupSystemNotifyCallbacks[reportType](item);
                                }
                            } else {
                                onGroupSystemNotifyCallbacks[reportType](notify);
                            }
                        }
                    }
                } //loop
            };


            //处理新的好友系统通知
            //isNeedValidRepeatMsg 是否需要判重
            var handlerFriendSystemNotices = function (friendSystemNotices, isNeedValidRepeatMsg) {
                var friendNotice, type, notify;
                for (var k in friendSystemNotices) {
                    friendNotice = friendSystemNotices[k];
                    type = friendNotice.PushType;
                    //当长轮询返回的群系统消息，才需要更新通知seq
                    if (isNeedValidRepeatMsg == false && friendNotice.NoticeSeq && friendNotice.NoticeSeq > noticeSeq) {
                        noticeSeq = friendNotice.NoticeSeq;
                    }
                    notify = {
                        'Type': type
                    };
                    switch (type) {
                        case FRIEND_NOTICE_TYPE.FRIEND_ADD: //好友表增加
                            notify["Accounts"] = friendNotice.FriendAdd_Account;
                            break;
                        case FRIEND_NOTICE_TYPE.FRIEND_DELETE: //好友表删除
                            notify["Accounts"] = friendNotice.FriendDel_Account;
                            break;
                        case FRIEND_NOTICE_TYPE.PENDENCY_ADD: //未决增加
                            notify["PendencyList"] = friendNotice.PendencyAdd;
                            break;
                        case FRIEND_NOTICE_TYPE.PENDENCY_DELETE: //未决删除
                            notify["Accounts"] = friendNotice.FrienPencydDel_Account;
                            break;
                        case FRIEND_NOTICE_TYPE.BLACK_LIST_ADD: //黑名单增加
                            notify["Accounts"] = friendNotice.BlackListAdd_Account;
                            break;
                        case FRIEND_NOTICE_TYPE.BLACK_LIST_DELETE: //黑名单删除
                            notify["Accounts"] = friendNotice.BlackListDel_Account;
                            break;
                            /*case FRIEND_NOTICE_TYPE.PENDENCY_REPORT://未决已读上报

                     break;
                     case FRIEND_NOTICE_TYPE.FRIEND_UPDATE://好友数据更新

                     break;
                     */
                        default:
                            log.error("未知好友系统通知类型：friendNotice=" + JSON.stringify(friendNotice));
                            break;
                    }

                    if (isNeedValidRepeatMsg) {
                        if (type == FRIEND_NOTICE_TYPE.PENDENCY_ADD) {
                            //回调
                            if (onFriendSystemNotifyCallbacks[type]) onFriendSystemNotifyCallbacks[type](notify);
                        }
                    } else {
                        //回调
                        if (onFriendSystemNotifyCallbacks[type]) onFriendSystemNotifyCallbacks[type](notify);
                    }
                } //loop
            };

            //处理新的资料系统通知
            //isNeedValidRepeatMsg 是否需要判重
            var handlerProfileSystemNotices = function (profileSystemNotices, isNeedValidRepeatMsg) {
                var profileNotice, type, notify;
                for (var k in profileSystemNotices) {
                    profileNotice = profileSystemNotices[k];
                    type = profileNotice.PushType;
                    //当长轮询返回的群系统消息，才需要更新通知seq
                    if (isNeedValidRepeatMsg == false && profileNotice.NoticeSeq && profileNotice.NoticeSeq > noticeSeq) {
                        noticeSeq = profileNotice.NoticeSeq;
                    }
                    notify = {
                        'Type': type
                    };
                    switch (type) {
                        case PROFILE_NOTICE_TYPE.PROFILE_MODIFY: //资料修改
                            notify["Profile_Account"] = profileNotice.Profile_Account;
                            notify["ProfileList"] = profileNotice.ProfileList;
                            break;
                        default:
                            log.error("未知资料系统通知类型：profileNotice=" + JSON.stringify(profileNotice));
                            break;
                    }

                    if (isNeedValidRepeatMsg) {
                        if (type == PROFILE_NOTICE_TYPE.PROFILE_MODIFY) {
                            //回调
                            if (onProfileSystemNotifyCallbacks[type]) onProfileSystemNotifyCallbacks[type](notify);
                        }
                    } else {
                        //回调
                        if (onProfileSystemNotifyCallbacks[type]) onProfileSystemNotifyCallbacks[type](notify);
                    }
                } //loop
            };

            //处理新的群系统消息(用于直播大群长轮询)
            var handlerGroupSystemMsg = function (groupTip) {
                var groupReportTypeMsg = groupTip.MsgBody;
                var reportType = groupReportTypeMsg.ReportType;
                var toAccount = groupTip.GroupInfo.To_Account;
                //过滤本不应该给自己的系统消息
                //if(!toAccount || toAccount!=ctx.identifier){
                //    log.error("收到本不应该给自己的系统消息: To_Account="+toAccount);
                //    continue;
                //}
                var notify = {
                    "SrcFlag": 1,
                    "ReportType": reportType,
                    "GroupId": groupTip.ToGroupId,
                    "GroupName": groupTip.GroupInfo.GroupName,
                    "Operator_Account": groupReportTypeMsg.Operator_Account,
                    "MsgTime": groupTip.MsgTimeStamp
                };
                switch (reportType) {
                    case GROUP_SYSTEM_TYPE.JOIN_GROUP_REQUEST: //申请加群(只有管理员会接收到)
                        notify["RemarkInfo"] = groupReportTypeMsg.RemarkInfo;
                        notify["MsgKey"] = groupReportTypeMsg.MsgKey;
                        notify["Authentication"] = groupReportTypeMsg.Authentication;
                        notify["UserDefinedField"] = groupTip.UserDefinedField;
                        notify["From_Account"] = groupTip.From_Account;
                        notify["MsgSeq"] = groupTip.ClientSeq;
                        notify["MsgRandom"] = groupTip.MsgRandom;
                        break;
                    case GROUP_SYSTEM_TYPE.JOIN_GROUP_ACCEPT: //申请加群被同意(只有申请人自己接收到)
                    case GROUP_SYSTEM_TYPE.JOIN_GROUP_REFUSE: //申请加群被拒绝(只有申请人自己接收到)
                        notify["RemarkInfo"] = groupReportTypeMsg.RemarkInfo;
                        break;
                    case GROUP_SYSTEM_TYPE.KICK: //被管理员踢出群(只有被踢者接收到)
                    case GROUP_SYSTEM_TYPE.DESTORY: //群被解散(全员接收)
                    case GROUP_SYSTEM_TYPE.CREATE: //创建群(创建者接收, 不展示)
                    case GROUP_SYSTEM_TYPE.INVITED_JOIN_GROUP_REQUEST: //邀请加群(被邀请者接收)
                    case GROUP_SYSTEM_TYPE.INVITED_JOIN_GROUP_REQUEST_AGREE: //邀请加群(被邀请者需要同意)
                    case GROUP_SYSTEM_TYPE.QUIT: //主动退群(主动退出者接收, 不展示)
                    case GROUP_SYSTEM_TYPE.SET_ADMIN: //群设置管理员(被设置者接收)
                    case GROUP_SYSTEM_TYPE.CANCEL_ADMIN: //取消管理员(被取消者接收)
                    case GROUP_SYSTEM_TYPE.REVOKE: //群已被回收(全员接收, 不展示)
                        break;
                    case GROUP_SYSTEM_TYPE.CUSTOM: //用户自定义通知(默认全员接收)
                        notify["MsgSeq"] = groupTip.MsgSeq;
                        notify["UserDefinedField"] = groupReportTypeMsg.UserDefinedField;
                        break;
                    default:
                        log.error("未知群系统消息类型：reportType=" + reportType);
                        break;
                }
                //回调
                if (onGroupSystemNotifyCallbacks[reportType]) onGroupSystemNotifyCallbacks[reportType](notify);

            };

            //处理C2C EVENT 消息通道Array
            var handlerC2cNotifyMsgArray = function (arr) {
                for (var i = 0, l = arr.length; i < l; i++) {
                    handlerC2cEventMsg(arr[i]);
                }
            }

            //处理C2C EVENT 消息通道Item
            var handlerC2cEventMsg = function (notify) {
                var subType = notify.SubMsgType;
                switch (subType) {
                    case C2C_EVENT_SUB_TYPE.READED:
                        log.warn("C2C已读消息通知");
                        if (notify.ReadC2cMsgNotify && notify.ReadC2cMsgNotify.UinPairReadArray && onC2cEventCallbacks[subType]) {
                            for (var i = 0, l = notify.ReadC2cMsgNotify.UinPairReadArray.length; i < l; i++) {
                                var item = notify.ReadC2cMsgNotify.UinPairReadArray[i];
                                onC2cEventCallbacks[subType](item);
                            }
                        }
                        break;
                    case C2C_EVENT_SUB_TYPE.KICKEDOUT:
                        log.warn("多终端互踢通知");
                        proto_logout('instance');
                        if (onC2cEventCallbacks[subType]) {
                            onC2cEventCallbacks[subType]();
                        }
                        break;
                    default:
                        log.error("未知C2c系统消息：subType=" + subType);
                        break;
                }

            };

            //长轮询
            this.longPolling = function (cbOk, cbErr) {


                var opts = {
                    'Timeout': longPollingDefaultTimeOut / 1000,
                    'Cookie': {
                        'NotifySeq': notifySeq,
                        'NoticeSeq': noticeSeq
                    }
                };
                if (LongPollingId) {
                    opts.Cookie.LongPollingId = LongPollingId;
                    doPolling();
                } else {
                    proto_getLongPollingId({}, function (resp) {
                        LongPollingId = opts.Cookie.LongPollingId = resp.LongPollingId;
                        //根据回包设置超时时间，超时时长不能>60秒，因为webkit手机端的最长超时时间不能大于60s
                        longPollingDefaultTimeOut = resp.Timeout > 60 ? longPollingDefaultTimeOut : resp.Timeout * 1000;
                        doPolling();
                    });
                }

                function doPolling() {
                    proto_longPolling(opts, function (resp) {
                        for (var i in resp.EventArray) {
                            var e = resp.EventArray[i];
                            switch (e.Event) {
                                case LONG_POLLINNG_EVENT_TYPE.C2C: //c2c消息通知
                                    //更新C2C消息通知seq
                                    notifySeq = e.NotifySeq;
                                    log.warn("longpolling: received new c2c msg");
                                    //获取新消息
                                    MsgManager.syncMsgs();
                                    break;
                                case LONG_POLLINNG_EVENT_TYPE.GROUP_COMMON: //普通群消息通知
                                    log.warn("longpolling: received new group msgs");
                                    handlerOrdinaryAndTipGroupMsgs(e.Event, e.GroupMsgArray);
                                    break;
                                case LONG_POLLINNG_EVENT_TYPE.GROUP_TIP: //（全员广播）群提示消息
                                    log.warn("longpolling: received new group tips");
                                    handlerOrdinaryAndTipGroupMsgs(e.Event, e.GroupTips);
                                    break;
                                case LONG_POLLINNG_EVENT_TYPE.GROUP_TIP2: //群提示消息
                                    log.warn("longpolling: received new group tips");
                                    handlerOrdinaryAndTipGroupMsgs(e.Event, e.GroupTips);
                                    break;
                                case LONG_POLLINNG_EVENT_TYPE.GROUP_SYSTEM: //（多终端同步）群系统消息
                                    log.warn("longpolling: received new group system msgs");
                                    //false 表示 通过长轮询收到的群系统消息，可以不判重
                                    handlerGroupSystemMsgs(e.GroupTips, false);
                                    break;
                                case LONG_POLLINNG_EVENT_TYPE.FRIEND_NOTICE: //好友系统通知
                                    log.warn("longpolling: received new friend system notice");
                                    //false 表示 通过长轮询收到的好友系统通知，可以不判重
                                    handlerFriendSystemNotices(e.FriendListMod, false);
                                    break;
                                case LONG_POLLINNG_EVENT_TYPE.PROFILE_NOTICE: //资料系统通知
                                    log.warn("longpolling: received new profile system notice");
                                    //false 表示 通过长轮询收到的资料系统通知，可以不判重
                                    handlerProfileSystemNotices(e.ProfileDataMod, false);
                                    break;
                                case LONG_POLLINNG_EVENT_TYPE.C2C_COMMON: //c2c消息通知
                                    noticeSeq = e.C2cMsgArray[0].NoticeSeq;
                                    //更新C2C消息通知seq
                                    log.warn("longpolling: received new c2c_common msg", noticeSeq);
                                    handlerOrdinaryAndTipC2cMsgs(e.Event, e.C2cMsgArray);
                                    break;
                                case LONG_POLLINNG_EVENT_TYPE.C2C_EVENT: //c2c已读消息通知
                                    noticeSeq = e.C2cNotifyMsgArray[0].NoticeSeq;
                                    log.warn("longpolling: received new c2c_event msg");
                                    handlerC2cNotifyMsgArray(e.C2cNotifyMsgArray);
                                    break;
                                default:
                                    log.error("longpolling收到未知新消息类型: Event=" + e.Event);
                                    break;
                            }
                        }
                        var successInfo = {
                            'ActionStatus': ACTION_STATUS.OK,
                            'ErrorCode': 0
                        };
                        updatecLongPollingStatus(successInfo);
                    }, function (err) {
                        //log.error(err);
                        updatecLongPollingStatus(err);
                        if (cbErr) cbErr(err);
                    });
                }
            };


        //大群 长轮询
        this.bigGroupLongPolling = function (GroupId, cbOk, cbErr) {
            // if( !GroupId ){
            //     for(var a in bigGroupLongPollingMsgMap){
            //         this.bigGroupLongPolling( a )
            //     }
            //     return;
            // }
            // var GroupId = BigGroupId;
            var opts = {
                'USP': 1,
                'StartSeq': bigGroupLongPollingStartSeqMap[GroupId], //请求拉消息的起始seq
                'HoldTime': bigGroupLongPollingHoldTime, //客户端长轮询的超时时间，单位是秒
                'Key': bigGroupLongPollingKeyMap[GroupId] //客户端加入群组后收到的的Key
                };

                proto_bigGroupLongPolling(opts, function (resp) {
                // if (GroupId != BigGroupId) return;
                    var msgObjList = [];
                bigGroupLongPollingStartSeqMap[GroupId] = resp.NextSeq;
                bigGroupLongPollingHoldTime = resp.HoldTime;
                bigGroupLongPollingKeyMap[GroupId] = resp.Key;

                    if (resp.RspMsgList && resp.RspMsgList.length > 0) {
                        var msgCount = 0,
                            msgInfo, event, msg;
                        for (var i = resp.RspMsgList.length - 1; i >= 0; i--) {
                            msgInfo = resp.RspMsgList[i];
                            //后台这里做了调整，缩短字段名，以下是兼容代码
                            var keyMap = {
                                "F_Account": "From_Account",
                                "T_Account": "To_Account",
                                "FAType": "EnumFrom_AccountType",
                                "TAType": "EnumTo_AccountType",
                                "GCode": "GroupCode",
                                "GName": "GroupName",
                                "GId": "GroupId",
                                "MFlg": "MsgFlag",
                                "FAEInfo": "MsgFrom_AccountExtraInfo",
                                "Evt": "Event",
                                "GInfo": "GroupInfo",
                                "BPlc": "IsPlaceMsg",
                                "MBody": "MsgBody",
                                "Pri": "MsgPriority",
                                "Rdm": "MsgRandom",
                                "MSeq": "MsgSeq",
                                "TStp": "MsgTimeStamp",
                                "TGId": "ToGroupId",
                                "UEInfo": "UinExtInfo",
                                "UId": "UserId",
                                "BSys": "IsSystemMsg",
                                "FAHUrl": "From_AccountHeadurl",
                                "FANick": "From_AccountNick"
                            };
                            msgInfo = tool.replaceObject(keyMap, msgInfo);
                            //如果是已经删除的消息或者发送者帐号为空或者消息内容为空
                            //IsPlaceMsg=1
                            if (msgInfo.IsPlaceMsg || !msgInfo.From_Account || !msgInfo.MsgBody || msgInfo.MsgBody.length == 0) {
                                continue;
                            }

                            event = msgInfo.Event; //群消息类型
                            switch (event) {
                                case LONG_POLLINNG_EVENT_TYPE.GROUP_COMMON: //群普通消息
                                    log.info("bigGroupLongPolling: return new group msg");
                                    msg = handlerGroupMsg(msgInfo, false, false);
                                    msg && msgObjList.push(msg);
                                    msgCount = msgCount + 1;
                                    break;
                                case LONG_POLLINNG_EVENT_TYPE.GROUP_TIP: //群提示消息
                                case LONG_POLLINNG_EVENT_TYPE.GROUP_TIP2: //群提示消息
                                    log.info("bigGroupLongPolling: return new group tip");
                                    msg = handlerGroupMsg(msgInfo, false, false);
                                    msg && msgObjList.push(msg);
                                    //msgCount=msgCount+1;
                                    break;
                                case LONG_POLLINNG_EVENT_TYPE.GROUP_SYSTEM: //群系统消息
                                    log.info("bigGroupLongPolling: new group system msg");
                                    handlerGroupSystemMsg(msgInfo);
                                    break;
                                default:
                                    log.error("bigGroupLongPolling收到未知新消息类型: Event=" + event);
                                    break;
                            }
                        } // for loop
                        if (msgCount > 0) {
                            MsgManager.setBigGroupLongPollingMsgMap(msgInfo.ToGroupId, msgCount); //
                            log.warn("current bigGroupLongPollingMsgMap: " + JSON.stringify(bigGroupLongPollingMsgMap));
                        }
                    }
                    curBigGroupLongPollingRetErrorCount = 0;
                    //返回连接状态
                    var successInfo = {
                        'ActionStatus': ACTION_STATUS.OK,
                        'ErrorCode': CONNECTION_STATUS.ON,
                        'ErrorInfo': 'connection is ok...'
                    };
                    ConnManager.callBack(successInfo);

                    if (cbOk) cbOk(msgObjList);
                    else if (onBigGroupMsgCallback) onBigGroupMsgCallback(msgObjList); //返回新消息

                    //重新启动长轮询
                bigGroupLongPollingOn && MsgManager.bigGroupLongPolling( GroupId );

                }, function (err) {
                    if (err.ErrorCode == longPollingPackageTooLargeErrorCode) {
                    bigGroupLongPollingStartSeqMap[GroupId] = 0;
                    } else if (err.ErrorCode != longPollingTimeOutErrorCode) {
                        log.error(err.ErrorInfo);
                        //记录长轮询返回错误次数
                        curBigGroupLongPollingRetErrorCount++;
                    }
                    if (err.ErrorCode == longPollingKickedErrorCode) {
                        //登出
                        log.error("多实例登录，被kick");
                        if (onKickedEventCall) {
                            onKickedEventCall();
                        }
                    }
                    bigGroupLongPollingOn && MsgManager.bigGroupLongPolling( GroupId );
                    //累计超过一定次数，不再发起长轮询请求 - 去掉轮询次数限制的逻辑 SaxonGao
                    // if (curBigGroupLongPollingRetErrorCount < LONG_POLLING_MAX_RET_ERROR_COUNT) {
                    //     bigGroupLongPollingOn && MsgManager.bigGroupLongPolling( GroupId );
                    // } else {
                    //     var errInfo = {
                    //         'ActionStatus': ACTION_STATUS.FAIL,
                    //         'ErrorCode': CONNECTION_STATUS.OFF,
                    //         'ErrorInfo': 'connection is off'
                    //     };
                    //     ConnManager.callBack(errInfo);
                    // }
                    if (cbErr) cbErr(err);

                }, bigGroupLongPollingHoldTime * 1000);
            };

            //更新连接状态
            var updatecLongPollingStatus = function (errObj) {
                if (errObj.ErrorCode == 0 || errObj.ErrorCode == longPollingTimeOutErrorCode) {
                    curLongPollingRetErrorCount = 0;
                    longPollingOffCallbackFlag = false;
                    var errorInfo;
                    var isNeedCallback = false;
                    switch (curLongPollingStatus) {
                        case CONNECTION_STATUS.INIT:
                            isNeedCallback = true;
                            curLongPollingStatus = CONNECTION_STATUS.ON;
                            errorInfo = "create connection successfully(INIT->ON)";
                            break;
                        case CONNECTION_STATUS.ON:
                            errorInfo = "connection is on...(ON->ON)";
                            break;
                        case CONNECTION_STATUS.RECONNECT:
                            curLongPollingStatus = CONNECTION_STATUS.ON;
                            errorInfo = "connection is on...(RECONNECT->ON)";
                            break;
                        case CONNECTION_STATUS.OFF:
                            isNeedCallback = true;
                            curLongPollingStatus = CONNECTION_STATUS.RECONNECT;
                            errorInfo = "reconnect successfully(OFF->RECONNECT)";
                            break;
                    }
                    var successInfo = {
                        'ActionStatus': ACTION_STATUS.OK,
                        'ErrorCode': curLongPollingStatus,
                        'ErrorInfo': errorInfo
                    };
                    isNeedCallback && ConnManager.callBack(successInfo);
                    longPollingOn && MsgManager.longPolling();
                } else if (errObj.ErrorCode == longPollingKickedErrorCode) {
                    //登出
                    log.error("多实例登录，被kick");
                    if (onKickedEventCall) {
                        onKickedEventCall();
                    }
                } else {
                    //记录长轮询返回解析json错误次数
                    curLongPollingRetErrorCount++;
                    log.warn("longPolling接口第" + curLongPollingRetErrorCount + "次报错: " + errObj.ErrorInfo);
                    //累计超过一定次数
                    if (curLongPollingRetErrorCount <= LONG_POLLING_MAX_RET_ERROR_COUNT) {
                        setTimeout(startNextLongPolling, 100); //
                    } else {
                        curLongPollingStatus = CONNECTION_STATUS.OFF;
                        var errInfo = {
                            'ActionStatus': ACTION_STATUS.FAIL,
                            'ErrorCode': CONNECTION_STATUS.OFF,
                            'ErrorInfo': 'connection is off'
                        };
                        longPollingOffCallbackFlag == false && ConnManager.callBack(errInfo);
                        longPollingOffCallbackFlag = true;
                        log.warn(longPollingIntervalTime + "毫秒之后,SDK会发起新的longPolling请求...");
                        setTimeout(startNextLongPolling, longPollingIntervalTime); //长轮询接口报错次数达到一定值，每间隔5s发起新的长轮询
                    }
                }
            };

            //处理收到的普通C2C消息
            var handlerOrdinaryAndTipC2cMsgs = function (eventType, C2cMsgArray) {
                //处理c2c消息
                var notifyInfo = [];
                var msgInfos = [];
                msgInfos = C2cMsgArray; //返回的消息列表
                // MsgStore.cookie = resp.Cookie;//cookies，记录当前读到的最新消息位置

                for (var i in msgInfos) {
                    var msgInfo = msgInfos[i];
                var isSendMsg, id;
                var headUrl =  msgInfo.From_AccountHeadurl || '';
                    if (msgInfo.From_Account == ctx.identifier) { //当前用户发送的消息
                        isSendMsg = true;
                        id = msgInfo.To_Account; //读取接收者信息
                    } else { //当前用户收到的消息
                        isSendMsg = false;
                        id = msgInfo.From_Account; //读取发送者信息
                    }
                    var sess = MsgStore.sessByTypeId(SESSION_TYPE.C2C, id);
                    if (!sess) {
                        sess = new Session(SESSION_TYPE.C2C, id, id, headUrl, 0, 0);
                    }
                	var msg = new Msg(sess, isSendMsg, msgInfo.MsgSeq, msgInfo.MsgRandom, msgInfo.MsgTimeStamp, msgInfo.From_Account, C2C_MSG_SUB_TYPE.COMMON, msgInfo.From_AccountNick, headUrl);
                    var msgBody = null;
                    var msgContent = null;
                    var msgType = null;
                    for (var mi in msgInfo.MsgBody) {
                        msgBody = msgInfo.MsgBody[mi];
                        msgType = msgBody.MsgType;
                        switch (msgType) {
                            case MSG_ELEMENT_TYPE.TEXT:
                                msgContent = new Msg.Elem.Text(msgBody.MsgContent.Text);
                                break;
                            case MSG_ELEMENT_TYPE.FACE:
                                msgContent = new Msg.Elem.Face(
                                    msgBody.MsgContent.Index,
                                    msgBody.MsgContent.Data
                                );
                                break;
                            case MSG_ELEMENT_TYPE.IMAGE:
                                msgContent = new Msg.Elem.Images(
                                    msgBody.MsgContent.UUID,
                                    msgBody.MsgContent.ImageFormat || ""
                                );
                                for (var j in msgBody.MsgContent.ImageInfoArray) {
                                    var tempImg = msgBody.MsgContent.ImageInfoArray[j];
                                    msgContent.addImage(
                                        new Msg.Elem.Images.Image(
                                            tempImg.Type,
                                            tempImg.Size,
                                            tempImg.Width,
                                            tempImg.Height,
                                            tempImg.URL
                                        )
                                    );
                                }
                                break;
                            case MSG_ELEMENT_TYPE.SOUND:
                                if (msgBody.MsgContent) {
                                    msgContent = new Msg.Elem.Sound(
                                        msgBody.MsgContent.UUID,
                                        msgBody.MsgContent.Second,
                                        msgBody.MsgContent.Size,
                                        msgInfo.From_Account,
                                        msgInfo.To_Account,
                                        msgBody.MsgContent.Download_Flag,
                                        SESSION_TYPE.C2C,
                                        msgBody.MsgContent.Url || null
                                    );
                                } else {
                                    msgType = MSG_ELEMENT_TYPE.TEXT;
                                    msgContent = new Msg.Elem.Text('[语音消息]下载地址解析出错');
                                }
                                break;
                            case MSG_ELEMENT_TYPE.LOCATION:
                                msgContent = new Msg.Elem.Location(
                                    msgBody.MsgContent.Longitude,
                                    msgBody.MsgContent.Latitude,
                                    msgBody.MsgContent.Desc
                                );
                                break;
                            case MSG_ELEMENT_TYPE.FILE:
                            case MSG_ELEMENT_TYPE.FILE + " ":
                                msgType = MSG_ELEMENT_TYPE.FILE;
                                if (msgBody.MsgContent) {
                                    msgContent = new Msg.Elem.File(
                                        msgBody.MsgContent.UUID,
                                        msgBody.MsgContent.FileName,
                                        msgBody.MsgContent.FileSize,
                                        msgInfo.From_Account,
                                        msgInfo.To_Account,
                                        msgBody.MsgContent.Download_Flag,
                                        SESSION_TYPE.C2C
                                    );
                                } else {
                                    msgType = MSG_ELEMENT_TYPE.TEXT;
                                    msgContent = new Msg.Elem.Text('[文件消息下载地址解析出错]');
                                }
                                break;
                            case MSG_ELEMENT_TYPE.CUSTOM:
                                try {
                                    var data = JSON.parse(msgBody.MsgContent.Data);
                                    if (data && data.userAction && data.userAction == FRIEND_WRITE_MSG_ACTION.ING) { //过滤安卓或ios的正在输入自定义消息
                                        continue;
                                    }
                                } catch (e) {}

                                msgType = MSG_ELEMENT_TYPE.CUSTOM;
                                msgContent = new Msg.Elem.Custom(
                                    msgBody.MsgContent.Data,
                                    msgBody.MsgContent.Desc,
                                    msgBody.MsgContent.Ext
                                );
                                break;
                            default:
                                msgType = MSG_ELEMENT_TYPE.TEXT;
                                msgContent = new Msg.Elem.Text('web端暂不支持' + msgBody.MsgType + '消息');
                                break;
                        }
                        msg.elems.push(new Msg.Elem(msgType, msgContent));
                    }

                    if (msg.elems.length > 0 && MsgStore.addMsg(msg, true)) {
                        notifyInfo.push(msg);
                    }
                } // for loop
                if (notifyInfo.length > 0)
                    MsgStore.updateTimeline();
                if (notifyInfo.length > 0) {
                    if (onMsgCallback) onMsgCallback(notifyInfo);
                }
            };

            //发起新的长轮询请求
            var startNextLongPolling = function () {
                longPollingOn && MsgManager.longPolling();
            };

            //处理未决的加群申请消息列表
            var handlerApplyJoinGroupSystemMsgs = function (eventArray) {
                for (var i in eventArray) {
                    var e = eventArray[i];
                    handlerGroupSystemMsgs(e.GroupTips, true);
                    switch (e.Event) {
                        case LONG_POLLINNG_EVENT_TYPE.GROUP_SYSTEM: //（多终端同步）群系统消息
                            log.warn("handlerApplyJoinGroupSystemMsgs： handler new group system msg");
                            //true 表示 解决加群申请通知存在重复的问题（已处理的通知，下次登录还会拉到），需要判重
                            handlerGroupSystemMsgs(e.GroupTips, true);
                            break;
                        default:
                            log.error("syncMsgs收到未知的群系统消息类型: Event=" + e.Event);
                            break;
                    }
                }
            };

            //拉取c2c消息(包含加群未决消息，需要处理)
            this.syncMsgs = function (cbOk, cbErr) {
                var notifyInfo = [];
                var msgInfos = [];
                //读取C2C消息
                proto_getMsgs(MsgStore.cookie, MsgStore.syncFlag, function (resp) {
                    //拉取完毕
                    if (resp.SyncFlag == 2) {
                        MsgStore.syncFlag = 0;
                    }
                    //处理c2c消息
                    msgInfos = resp.MsgList; //返回的消息列表
                    MsgStore.cookie = resp.Cookie; //cookies，记录当前读到的最新消息位置

                    for (var i in msgInfos) {
                        var msgInfo = msgInfos[i];
                        var isSendMsg, id, headUrl;
                        if (msgInfo.From_Account == ctx.identifier) { //当前用户发送的消息
                            isSendMsg = true;
                            id = msgInfo.To_Account; //读取接收者信息
                            headUrl = '';
                        } else { //当前用户收到的消息
                            isSendMsg = false;
                            id = msgInfo.From_Account; //读取发送者信息
                            headUrl = '';
                        }
                        var sess = MsgStore.sessByTypeId(SESSION_TYPE.C2C, id);
                        if (!sess) {
                            sess = new Session(SESSION_TYPE.C2C, id, id, headUrl, 0, 0);
                        }
                    var msg = new Msg(sess, isSendMsg, msgInfo.MsgSeq, msgInfo.MsgRandom, msgInfo.MsgTimeStamp, msgInfo.From_Account, C2C_MSG_SUB_TYPE.COMMON, msgInfo.From_AccountNick, msgInfo.From_AccountHeadurl);
                        var msgBody = null;
                        var msgContent = null;
                        var msgType = null;
                        for (var mi in msgInfo.MsgBody) {
                            msgBody = msgInfo.MsgBody[mi];
                            msgType = msgBody.MsgType;
                            switch (msgType) {
                                case MSG_ELEMENT_TYPE.TEXT:
                                    msgContent = new Msg.Elem.Text(msgBody.MsgContent.Text);
                                    break;
                                case MSG_ELEMENT_TYPE.FACE:
                                    msgContent = new Msg.Elem.Face(
                                        msgBody.MsgContent.Index,
                                        msgBody.MsgContent.Data
                                    );
                                    break;
                                case MSG_ELEMENT_TYPE.IMAGE:
                                    msgContent = new Msg.Elem.Images(
                                        msgBody.MsgContent.UUID,
                                        msgBody.MsgContent.ImageFormat
                                    );
                                    for (var j in msgBody.MsgContent.ImageInfoArray) {
                                        var tempImg = msgBody.MsgContent.ImageInfoArray[j];
                                        msgContent.addImage(
                                            new Msg.Elem.Images.Image(
                                                tempImg.Type,
                                                tempImg.Size,
                                                tempImg.Width,
                                                tempImg.Height,
                                                tempImg.URL
                                            )
                                        );
                                    }
                                    break;
                                case MSG_ELEMENT_TYPE.SOUND:
                                    // var soundUrl = getSoundDownUrl(msgBody.MsgContent.UUID, msgInfo.From_Account);
                                    if (msgBody.MsgContent) {
                                        msgContent = new Msg.Elem.Sound(
                                            msgBody.MsgContent.UUID,
                                            msgBody.MsgContent.Second,
                                            msgBody.MsgContent.Size,
                                            msgInfo.From_Account,
                                            msgInfo.To_Account,
                                            msgBody.MsgContent.Download_Flag,
                                            SESSION_TYPE.C2C,
                                            msgBody.MsgContent.Url || null
                                        );
                                    } else {
                                        msgType = MSG_ELEMENT_TYPE.TEXT;
                                        msgContent = new Msg.Elem.Text('[语音消息]下载地址解析出错');
                                    }
                                    break;
                                case MSG_ELEMENT_TYPE.LOCATION:
                                    msgContent = new Msg.Elem.Location(
                                        msgBody.MsgContent.Longitude,
                                        msgBody.MsgContent.Latitude,
                                        msgBody.MsgContent.Desc
                                    );
                                    break;
                                case MSG_ELEMENT_TYPE.FILE:
                                case MSG_ELEMENT_TYPE.FILE + " ":
                                    msgType = MSG_ELEMENT_TYPE.FILE;
                                    // var fileUrl = getFileDownUrl(msgBody.MsgContent.UUID, msgInfo.From_Account, msgBody.MsgContent.FileName);
                                    if (msgBody.MsgContent) {
                                        msgContent = new Msg.Elem.File(
                                            msgBody.MsgContent.UUID,
                                            msgBody.MsgContent.FileName,
                                            msgBody.MsgContent.FileSize,
                                            msgInfo.From_Account,
                                            msgInfo.To_Account,
                                            msgBody.MsgContent.Download_Flag,
                                            SESSION_TYPE.C2C
                                        );
                                    } else {
                                        msgType = MSG_ELEMENT_TYPE.TEXT;
                                        msgContent = new Msg.Elem.Text('[文件消息下载地址解析出错]');
                                    }
                                    break;
                                case MSG_ELEMENT_TYPE.CUSTOM:
                                    try {
                                        var data = JSON.parse(msgBody.MsgContent.Data);
                                        if (data && data.userAction && data.userAction == FRIEND_WRITE_MSG_ACTION.ING) { //过滤安卓或ios的正在输入自定义消息
                                            continue;
                                        }
                                    } catch (e) {}

                                    msgType = MSG_ELEMENT_TYPE.CUSTOM;
                                    msgContent = new Msg.Elem.Custom(
                                        msgBody.MsgContent.Data,
                                        msgBody.MsgContent.Desc,
                                        msgBody.MsgContent.Ext
                                    );
                                    break;
                                default:
                                    msgType = MSG_ELEMENT_TYPE.TEXT;
                                    msgContent = new Msg.Elem.Text('web端暂不支持' + msgBody.MsgType + '消息');
                                    break;
                            }
                            msg.elems.push(new Msg.Elem(msgType, msgContent));
                        }

                        if (msg.elems.length > 0 && MsgStore.addMsg(msg, true)) {
                            notifyInfo.push(msg);
                        }
                    } // for loop

                    //处理加群未决申请消息
                    handlerApplyJoinGroupSystemMsgs(resp.EventArray);

                    if (notifyInfo.length > 0)
                        MsgStore.updateTimeline();
                    if (cbOk) cbOk(notifyInfo);
                    else if (notifyInfo.length > 0) {
                        if (onMsgCallback) onMsgCallback(notifyInfo);
                    }

                }, function (err) {
                    log.error("getMsgs failed:" + err.ErrorInfo);
                    if (cbErr) cbErr(err);
                });
            };


            //拉取C2C漫游消息
            this.getC2CHistoryMsgs = function (options, cbOk, cbErr) {

                if (!options.Peer_Account) {
                    if (cbErr) {
                        cbErr(tool.getReturnError("Peer_Account is empty", -13));
                        return;
                    }
                }
                if (!options.MaxCnt) {
                    options.MaxCnt = 15;
                }
                if (options.MaxCnt <= 0) {
                    if (cbErr) {
                        cbErr(tool.getReturnError("MaxCnt should be greater than 0", -14));
                        return;
                    }
                }
                if (options.MaxCnt > 15) {
                    if (cbErr) {
                        cbErr(tool.getReturnError("MaxCnt can not be greater than 15", -15));
                        return;
                    }
                    return;
                }
                if (options.MsgKey == null || options.MsgKey === undefined) {
                    options.MsgKey = '';
                }
                var opts = {
                    'Peer_Account': options.Peer_Account,
                    'MaxCnt': options.MaxCnt,
                    'LastMsgTime': options.LastMsgTime,
                    'MsgKey': options.MsgKey
                };
                //读取c2c漫游消息
                proto_getC2CHistoryMsgs(opts, function (resp) {
                    var msgObjList = [];
                    var msgInfos = [];
                    //处理c2c消息
                    msgInfos = resp.MsgList; //返回的消息列表
                    var sess = MsgStore.sessByTypeId(SESSION_TYPE.C2C, options.Peer_Account);
                    if (!sess) {
                        sess = new Session(SESSION_TYPE.C2C, options.Peer_Account, options.Peer_Account, '', 0, 0);
                    }
                    for (var i in msgInfos) {
                        var msgInfo = msgInfos[i];
                    var isSendMsg, id;
                    var headUrl = msgInfo.From_AccountHeadurl || '';
                        if (msgInfo.From_Account == ctx.identifier) { //当前用户发送的消息
                            isSendMsg = true;
                            id = msgInfo.To_Account; //读取接收者信息
                        } else { //当前用户收到的消息
                            isSendMsg = false;
                            id = msgInfo.From_Account; //读取发送者信息
                        }
                    var msg = new Msg(sess, isSendMsg, msgInfo.MsgSeq, msgInfo.MsgRandom, msgInfo.MsgTimeStamp, msgInfo.From_Account, C2C_MSG_SUB_TYPE.COMMON, msgInfo.From_AccountNick, headUrl);
                        var msgBody = null;
                        var msgContent = null;
                        var msgType = null;
                        for (var mi in msgInfo.MsgBody) {
                            msgBody = msgInfo.MsgBody[mi];
                            msgType = msgBody.MsgType;
                            switch (msgType) {
                                case MSG_ELEMENT_TYPE.TEXT:
                                    msgContent = new Msg.Elem.Text(msgBody.MsgContent.Text);
                                    break;
                                case MSG_ELEMENT_TYPE.FACE:
                                    msgContent = new Msg.Elem.Face(
                                        msgBody.MsgContent.Index,
                                        msgBody.MsgContent.Data
                                    );
                                    break;
                                case MSG_ELEMENT_TYPE.IMAGE:
                                    msgContent = new Msg.Elem.Images(
                                        msgBody.MsgContent.UUID,
                                        msgBody.MsgContent.ImageFormat
                                    );
                                    for (var j in msgBody.MsgContent.ImageInfoArray) {
                                        var tempImg = msgBody.MsgContent.ImageInfoArray[j];
                                        msgContent.addImage(
                                            new Msg.Elem.Images.Image(
                                                tempImg.Type,
                                                tempImg.Size,
                                                tempImg.Width,
                                                tempImg.Height,
                                                tempImg.URL
                                            )
                                        );
                                    }
                                    break;
                                case MSG_ELEMENT_TYPE.SOUND:

                                    // var soundUrl = getSoundDownUrl(msgBody.MsgContent.UUID, msgInfo.From_Account);

                                    if (msgBody.MsgContent) {
                                        msgContent = new Msg.Elem.Sound(
                                            msgBody.MsgContent.UUID,
                                            msgBody.MsgContent.Second,
                                            msgBody.MsgContent.Size,
                                            msgInfo.From_Account,
                                            msgInfo.To_Account,
                                            msgBody.MsgContent.Download_Flag,
                                            SESSION_TYPE.C2C,
                                            msgBody.MsgContent.Url || null
                                        );
                                    } else {
                                        msgType = MSG_ELEMENT_TYPE.TEXT;
                                        msgContent = new Msg.Elem.Text('[语音消息]下载地址解析出错');
                                    }
                                    break;
                                case MSG_ELEMENT_TYPE.LOCATION:
                                    msgContent = new Msg.Elem.Location(
                                        msgBody.MsgContent.Longitude,
                                        msgBody.MsgContent.Latitude,
                                        msgBody.MsgContent.Desc
                                    );
                                    break;
                                case MSG_ELEMENT_TYPE.FILE:
                                case MSG_ELEMENT_TYPE.FILE + " ":
                                    msgType = MSG_ELEMENT_TYPE.FILE;
                                    // var fileUrl = getFileDownUrl(msgBody.MsgContent.UUID, msgInfo.From_Account, msgBody.MsgContent.FileName);

                                    if (msgBody.MsgContent) {
                                        msgContent = new Msg.Elem.File(
                                            msgBody.MsgContent.UUID,
                                            msgBody.MsgContent.FileName,
                                            msgBody.MsgContent.FileSize,
                                            msgInfo.From_Account,
                                            msgInfo.To_Account,
                                            msgBody.MsgContent.Download_Flag,
                                            SESSION_TYPE.C2C
                                        );
                                    } else {
                                        msgType = MSG_ELEMENT_TYPE.TEXT;
                                        msgContent = new Msg.Elem.Text('[文件消息下载地址解析出错]');
                                    }
                                    break;
                                case MSG_ELEMENT_TYPE.CUSTOM:
                                    msgType = MSG_ELEMENT_TYPE.CUSTOM;
                                    msgContent = new Msg.Elem.Custom(
                                        msgBody.MsgContent.Data,
                                        msgBody.MsgContent.Desc,
                                        msgBody.MsgContent.Ext
                                    );

                                    break;
                                default:
                                    msgType = MSG_ELEMENT_TYPE.TEXT;
                                    msgContent = new Msg.Elem.Text('web端暂不支持' + msgBody.MsgType + '消息');
                                    break;
                            }
                            msg.elems.push(new Msg.Elem(msgType, msgContent));
                        }
                        MsgStore.addMsg(msg);
                        msgObjList.push(msg);
                    } // for loop

                    MsgStore.updateTimeline();
                    if (cbOk) {

                        var newResp = {
                            'Complete': resp.Complete,
                            'MsgCount': msgObjList.length,
                            'LastMsgTime': resp.LastMsgTime,
                            'MsgKey': resp.MsgKey,
                            'MsgList': msgObjList
                        };
                        sess.isFinished(resp.Complete);
                        cbOk(newResp);
                    }

                }, function (err) {
                    log.error("getC2CHistoryMsgs failed:" + err.ErrorInfo);
                    if (cbErr) cbErr(err);
                });
            };

            //拉群历史消息
            //不传cbOk 和 cbErr，则会调用新消息回调函数
            this.syncGroupMsgs = function (options, cbOk, cbErr) {
                if (options.ReqMsgSeq <= 0) {
                    if (cbErr) {
                        var errInfo = "ReqMsgSeq must be greater than 0";
                        var error = tool.getReturnError(errInfo, -16);
                        cbErr(error);
                    }
                    return;
                }
                var opts = {
                    'GroupId': options.GroupId,
                    'ReqMsgSeq': options.ReqMsgSeq,
                    'ReqMsgNumber': options.ReqMsgNumber
                };
                //读群漫游消息
                proto_getGroupMsgs(opts, function (resp) {
                    var notifyInfo = [];
                    var group_id = resp.GroupId; //返回的群id
                    var msgInfos = resp.RspMsgList; //返回的消息列表
                    var isFinished = resp.IsFinished;

                    if (msgInfos == null || msgInfos === undefined) {
                        if (cbOk) {
                            cbOk([]);
                        }
                        return;
                    }
                    for (var i = msgInfos.length - 1; i >= 0; i--) {
                        var msgInfo = msgInfos[i];
                        //如果是已经删除的消息或者发送者帐号为空或者消息内容为空
                        //IsPlaceMsg=1
                        if (msgInfo.IsPlaceMsg || !msgInfo.From_Account || !msgInfo.MsgBody || msgInfo.MsgBody.length == 0) {
                            continue;
                        }
                        var msg = handlerGroupMsg(msgInfo, true, true, isFinished);
                        if (msg) {
                            notifyInfo.push(msg);
                        }
                    } // for loop
                    if (notifyInfo.length > 0)
                        MsgStore.updateTimeline();
                    if (cbOk) cbOk(notifyInfo);
                    else if (notifyInfo.length > 0) {
                        if (onMsgCallback) onMsgCallback(notifyInfo);
                    }

                }, function (err) {
                    log.error("getGroupMsgs failed:" + err.ErrorInfo);
                    if (cbErr) cbErr(err);
                });
            };

            //处理群消息(普通消息+提示消息)
            //isSyncGroupMsgs 是否主动拉取群消息标志
            //isAddMsgFlag 是否需要保存到MsgStore，如果需要，这里会存在判重逻辑
            var handlerGroupMsg = function (msgInfo, isSyncGroupMsgs, isAddMsgFlag, isFinished) {
                if (msgInfo.IsPlaceMsg || !msgInfo.From_Account || !msgInfo.MsgBody || msgInfo.MsgBody.length == 0) {
                    return null;
                }
                var isSendMsg, id, headUrl, fromAccountNick, fromAccountHeadurl;
                var group_id = msgInfo.ToGroupId;
                var group_name = group_id;
                if (msgInfo.GroupInfo) { //取出群名称
                    if (msgInfo.GroupInfo.GroupName) {
                        group_name = msgInfo.GroupInfo.GroupName;
                    }
                }
                //取出成员昵称
                fromAccountNick = msgInfo.From_Account;
                //fromAccountHeadurl = msgInfo.GroupInfo.From_AccountHeadurl;
                if (msgInfo.GroupInfo) {
                    if (msgInfo.GroupInfo.From_AccountNick) {
                        fromAccountNick = msgInfo.GroupInfo.From_AccountNick;
                    }
                    if (msgInfo.GroupInfo.From_AccountHeadurl) {
                        fromAccountHeadurl = msgInfo.GroupInfo.From_AccountHeadurl;
                    } else {
                        fromAccountHeadurl = null;
                    }
                }
                if (msgInfo.From_Account == ctx.identifier) { //当前用户发送的消息
                    isSendMsg = true;
                    id = msgInfo.From_Account; //读取接收者信息
                    headUrl = '';
                } else { //当前用户收到的消息
                    isSendMsg = false;
                    id = msgInfo.From_Account; //读取发送者信息
                    headUrl = '';
                }
                var sess = MsgStore.sessByTypeId(SESSION_TYPE.GROUP, group_id);
                if (!sess) {
                    sess = new Session(SESSION_TYPE.GROUP, group_id, group_name, headUrl, 0, 0);
                }
                if (typeof isFinished !== "undefined") {
                    sess.isFinished(isFinished || 0);
                }
                var subType = GROUP_MSG_SUB_TYPE.COMMON; //消息类型
                //群提示消息,重新封装下
                if (LONG_POLLINNG_EVENT_TYPE.GROUP_TIP == msgInfo.Event || LONG_POLLINNG_EVENT_TYPE.GROUP_TIP2 == msgInfo.Event) {
                    subType = GROUP_MSG_SUB_TYPE.TIP;
                    var groupTip = msgInfo.MsgBody;
                    msgInfo.MsgBody = [];
                    msgInfo.MsgBody.push({
                        "MsgType": MSG_ELEMENT_TYPE.GROUP_TIP,
                        "MsgContent": groupTip
                    });
                } else if (msgInfo.MsgPriority) { //群点赞消息
                    if (msgInfo.MsgPriority == GROUP_MSG_PRIORITY_TYPE.REDPACKET) {
                        subType = GROUP_MSG_SUB_TYPE.REDPACKET;
                    } else if (msgInfo.MsgPriority == GROUP_MSG_PRIORITY_TYPE.LOVEMSG) {
                        subType = GROUP_MSG_SUB_TYPE.LOVEMSG;
                    }

                }
                var msg = new Msg(sess, isSendMsg, msgInfo.MsgSeq, msgInfo.MsgRandom, msgInfo.MsgTimeStamp, msgInfo.From_Account, subType, fromAccountNick, fromAccountHeadurl);
                var msgBody = null;
                var msgContent = null;
                var msgType = null;
                for (var mi in msgInfo.MsgBody) {
                    msgBody = msgInfo.MsgBody[mi];
                    msgType = msgBody.MsgType;
                    switch (msgType) {
                        case MSG_ELEMENT_TYPE.TEXT:
                            msgContent = new Msg.Elem.Text(msgBody.MsgContent.Text);
                            break;
                        case MSG_ELEMENT_TYPE.FACE:
                            msgContent = new Msg.Elem.Face(
                                msgBody.MsgContent.Index,
                                msgBody.MsgContent.Data
                            );
                            break;
                        case MSG_ELEMENT_TYPE.IMAGE:
                            msgContent = new Msg.Elem.Images(
                                msgBody.MsgContent.UUID,
                                msgBody.MsgContent.ImageFormat || ""
                            );
                            for (var j in msgBody.MsgContent.ImageInfoArray) {
                                msgContent.addImage(
                                    new Msg.Elem.Images.Image(
                                        msgBody.MsgContent.ImageInfoArray[j].Type,
                                        msgBody.MsgContent.ImageInfoArray[j].Size,
                                        msgBody.MsgContent.ImageInfoArray[j].Width,
                                        msgBody.MsgContent.ImageInfoArray[j].Height,
                                        msgBody.MsgContent.ImageInfoArray[j].URL
                                    )
                                );
                            }
                            break;
                        case MSG_ELEMENT_TYPE.SOUND:
                            if (msgBody.MsgContent) {
                                msgContent = new Msg.Elem.Sound(
                                    msgBody.MsgContent.UUID,
                                    msgBody.MsgContent.Second,
                                    msgBody.MsgContent.Size,
                                    msgInfo.From_Account,
                                    msgInfo.To_Account,
                                    msgBody.MsgContent.Download_Flag,
                                    SESSION_TYPE.GROUP,
                                    msgBody.MsgContent.Url || null
                                );
                            } else {
                                msgType = MSG_ELEMENT_TYPE.TEXT;
                                msgContent = new Msg.Elem.Text('[语音消息]下载地址解析出错');
                            }
                            break;
                        case MSG_ELEMENT_TYPE.LOCATION:
                            msgContent = new Msg.Elem.Location(
                                msgBody.MsgContent.Longitude,
                                msgBody.MsgContent.Latitude,
                                msgBody.MsgContent.Desc
                            );
                            break;
                        case MSG_ELEMENT_TYPE.FILE:
                        case MSG_ELEMENT_TYPE.FILE + " ":
                            msgType = MSG_ELEMENT_TYPE.FILE;
                            var fileUrl = getFileDownUrl(msgBody.MsgContent.UUID, msgInfo.From_Account, msgBody.MsgContent.FileName);

                            if (msgBody.MsgContent) {
                                msgContent = new Msg.Elem.File(
                                    msgBody.MsgContent.UUID,
                                    msgBody.MsgContent.FileName,
                                    msgBody.MsgContent.FileSize,
                                    msgInfo.From_Account,
                                    msgInfo.To_Account,
                                    msgBody.MsgContent.Download_Flag,
                                    SESSION_TYPE.GROUP
                                );
                            } else {
                                msgType = MSG_ELEMENT_TYPE.TEXT;
                                msgContent = new Msg.Elem.Text('[文件消息]地址解析出错');
                            }
                            break;
                        case MSG_ELEMENT_TYPE.GROUP_TIP:
                            var opType = msgBody.MsgContent.OpType;
                            msgContent = new Msg.Elem.GroupTip(
                                opType,
                                msgBody.MsgContent.Operator_Account,
                                group_id,
                                msgInfo.GroupInfo.GroupName,
                                msgBody.MsgContent.List_Account,
                                msgBody.MsgContent.MsgMemberExtraInfo
                            );
                            if (GROUP_TIP_TYPE.JOIN == opType || GROUP_TIP_TYPE.QUIT == opType) { //加群或退群时，设置最新群成员数
                                msgContent.setGroupMemberNum(msgBody.MsgContent.MemberNum);
                            } else if (GROUP_TIP_TYPE.MODIFY_GROUP_INFO == opType) { //群资料变更
                                var tempIsCallbackFlag = false;
                                var tempNewGroupInfo = {
                                    "GroupId": group_id,
                                    "GroupFaceUrl": null,
                                    "GroupName": null,
                                    "OwnerAccount": null,
                                    "GroupNotification": null,
                                    "GroupIntroduction": null
                                };
                                var msgGroupNewInfo = msgBody.MsgContent.MsgGroupNewInfo;
                                if (msgGroupNewInfo.GroupFaceUrl) {
                                    var tmpNGIFaceUrl = new Msg.Elem.GroupTip.GroupInfo(
                                        GROUP_TIP_MODIFY_GROUP_INFO_TYPE.FACE_URL,
                                        msgGroupNewInfo.GroupFaceUrl
                                    );
                                    msgContent.addGroupInfo(tmpNGIFaceUrl);
                                    tempIsCallbackFlag = true;
                                    tempNewGroupInfo.GroupFaceUrl = msgGroupNewInfo.GroupFaceUrl;
                                }
                                if (msgGroupNewInfo.GroupName) {
                                    var tmpNGIName = new Msg.Elem.GroupTip.GroupInfo(
                                        GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NAME,
                                        msgGroupNewInfo.GroupName
                                    );
                                    msgContent.addGroupInfo(tmpNGIName);
                                    tempIsCallbackFlag = true;
                                    tempNewGroupInfo.GroupName = msgGroupNewInfo.GroupName;
                                }
                                if (msgGroupNewInfo.Owner_Account) {
                                    var tmpNGIOwner = new Msg.Elem.GroupTip.GroupInfo(
                                        GROUP_TIP_MODIFY_GROUP_INFO_TYPE.OWNER,
                                        msgGroupNewInfo.Owner_Account
                                    );
                                    msgContent.addGroupInfo(tmpNGIOwner);
                                    tempIsCallbackFlag = true;
                                    tempNewGroupInfo.OwnerAccount = msgGroupNewInfo.Owner_Account;
                                }
                                if (msgGroupNewInfo.GroupNotification) {
                                    var tmpNGINotification = new Msg.Elem.GroupTip.GroupInfo(
                                        GROUP_TIP_MODIFY_GROUP_INFO_TYPE.NOTIFICATION,
                                        msgGroupNewInfo.GroupNotification
                                    );
                                    msgContent.addGroupInfo(tmpNGINotification);
                                    tempIsCallbackFlag = true;
                                    tempNewGroupInfo.GroupNotification = msgGroupNewInfo.GroupNotification;
                                }
                                if (msgGroupNewInfo.GroupIntroduction) {
                                    var tmpNGIIntroduction = new Msg.Elem.GroupTip.GroupInfo(
                                        GROUP_TIP_MODIFY_GROUP_INFO_TYPE.INTRODUCTION,
                                        msgGroupNewInfo.GroupIntroduction
                                    );
                                    msgContent.addGroupInfo(tmpNGIIntroduction);
                                    tempIsCallbackFlag = true;
                                    tempNewGroupInfo.GroupIntroduction = msgGroupNewInfo.GroupIntroduction;
                                }

                                //回调群资料变化通知方法
                                if (isSyncGroupMsgs == false && tempIsCallbackFlag && onGroupInfoChangeCallback) {
                                    onGroupInfoChangeCallback(tempNewGroupInfo);
                                }

                            } else if (GROUP_TIP_TYPE.MODIFY_MEMBER_INFO == opType) { //群成员变更
                                var memberInfos = msgBody.MsgContent.MsgMemberInfo;
                                for (var n in memberInfos) {
                                    var memberInfo = memberInfos[n];
                                    msgContent.addMemberInfo(
                                        new Msg.Elem.GroupTip.MemberInfo(
                                            memberInfo.User_Account, memberInfo.ShutupTime
                                        )
                                    );
                                }
                            }
                            break;
                        case MSG_ELEMENT_TYPE.CUSTOM:
                            msgType = MSG_ELEMENT_TYPE.CUSTOM;
                            msgContent = new Msg.Elem.Custom(
                                msgBody.MsgContent.Data,
                                msgBody.MsgContent.Desc,
                                msgBody.MsgContent.Ext
                            );
                            break;
                        default:
                            msgType = MSG_ELEMENT_TYPE.TEXT;
                            msgContent = new Msg.Elem.Text('web端暂不支持' + msgBody.MsgType + '消息');
                            break;
                    }
                    msg.elems.push(new Msg.Elem(msgType, msgContent));
                }

                if (isAddMsgFlag == false) { //不需要保存消息
                    return msg;
                }

                if (MsgStore.addMsg(msg, true)) {
                    msg.extraInfo = msgInfo.GroupInfo.MsgFrom_AccountExtraInfo
                    return msg;
                } else {
                    return null;
                }
            };

            //初始化
            this.init = function (listeners, cbOk, cbErr) {
                if (!listeners.onMsgNotify) {
                    log.warn('listeners.onMsgNotify is empty');
                }
                onMsgCallback = listeners.onMsgNotify;

                if (listeners.onBigGroupMsgNotify) {
                    onBigGroupMsgCallback = listeners.onBigGroupMsgNotify;
                } else {
                    log.warn('listeners.onBigGroupMsgNotify is empty');
                }

                if (listeners.onC2cEventNotifys) {
                    onC2cEventCallbacks = listeners.onC2cEventNotifys;
                } else {
                    log.warn('listeners.onC2cEventNotifys is empty');
                }
                if (listeners.onGroupSystemNotifys) {
                    onGroupSystemNotifyCallbacks = listeners.onGroupSystemNotifys;
                } else {
                    log.warn('listeners.onGroupSystemNotifys is empty');
                }
                if (listeners.onGroupInfoChangeNotify) {
                    onGroupInfoChangeCallback = listeners.onGroupInfoChangeNotify;
                } else {
                    log.warn('listeners.onGroupInfoChangeNotify is empty');
                }
                if (listeners.onFriendSystemNotifys) {
                    onFriendSystemNotifyCallbacks = listeners.onFriendSystemNotifys;
                } else {
                    log.warn('listeners.onFriendSystemNotifys is empty');
                }
                if (listeners.onProfileSystemNotifys) {
                    onProfileSystemNotifyCallbacks = listeners.onProfileSystemNotifys;
                } else {
                    log.warn('listeners.onProfileSystemNotifys is empty');
                }
                if (listeners.onKickedEventCall) {
                    onKickedEventCall = listeners.onKickedEventCall;
                } else {
                    log.warn('listeners.onKickedEventCall is empty');
                }
	    if (listeners.onLongPullingNotify) {
	        onLongPullingNotify = listeners.onLongPullingNotify;
            } else {
                log.warn('listeners.onKickedEventCall is empty');
            }

                if (listeners.onAppliedDownloadUrl) {
                    onAppliedDownloadUrl = listeners.onAppliedDownloadUrl;
                } else {
                    log.warn('listeners.onAppliedDownloadUrl is empty');
                }

                if (!ctx.identifier || !ctx.userSig) {
                    if (cbOk) {
                        var success = {
                            'ActionStatus': ACTION_STATUS.OK,
                            'ErrorCode': 0,
                            'ErrorInfo': "login success(no login state)"
                        };
                        cbOk(success);
                    }
                    return;
                }

                //初始化
                initMyGroupMaxSeqs(
                    function (resp) {
                        log.info('initMyGroupMaxSeqs success');
                        //初始化文件
                        initIpAndAuthkey(
                            function (initIpAndAuthkeyResp) {
                                log.info('initIpAndAuthkey success');
                                if (cbOk) {
                                    log.info('login success(have login state))');
                                    var success = {
                                        'ActionStatus': ACTION_STATUS.OK,
                                        'ErrorCode': 0,
                                        'ErrorInfo': "login success"
                                    };
                                    cbOk(success);
                                }
                                MsgManager.setLongPollingOn(true); //开启长轮询
                                longPollingOn && MsgManager.longPolling(cbOk);
                            }, cbErr);
                    }, cbErr);
            };

            //发消息（私聊或群聊）
            this.sendMsg = function (msg, cbOk, cbErr) {
                proto_sendMsg(msg, function (resp) {
                    //私聊时，加入自己的发的消息，群聊时，由于seq和服务器的seq不一样，所以不作处理
                    if (msg.sess.type() == SESSION_TYPE.C2C) {
                        MsgStore.addMsg(msg)
                        // 用以下注释代码会出现 C2C 发消息成功报 -17错误，原因：轮询的消息先入库后走到下面注释逻辑，导致命中判重逻辑
                        // if (!MsgStore.addMsg(msg)) {
                        //     var errInfo = "sendMsg: addMsg failed!";
                        //     var error = tool.getReturnError(errInfo, -17);
                        //     log.error(errInfo);
                        //     if (cbErr) cbErr(error);
                        //     return;
                        // }
                        //更新信息流时间
                        MsgStore.updateTimeline();
                    }
                    if (cbOk) cbOk(resp);
                }, function (err) {
                    if (cbErr) cbErr(err);
                });
            };
        };

        //上传文件
        var FileUploader = new function () {
            this.fileMd5 = null;
            //获取文件MD5
            var getFileMD5 = function (file, cbOk, cbErr) {

                //FileReader pc浏览器兼容性
                //Feature   Firefox (Gecko) Chrome  Internet Explorer   Opera   Safari
                //Basic support 3.6 7   10                      12.02   6.0.2
                var fileReader = null;
                try {
                    fileReader = new FileReader(); //分块读取文件对象
                } catch (e) {
                    if (cbErr) {
                        cbErr(tool.getReturnError('当前浏览器不支持FileReader', -18));
                        return;
                    }
                }
                //file的slice方法，注意它的兼容性，在不同浏览器的写法不同
                var blobSlice = File.prototype.mozSlice || File.prototype.webkitSlice || File.prototype.slice;
                if (!blobSlice) {
                    if (cbErr) {
                        cbErr(tool.getReturnError('当前浏览器不支持FileAPI', -19));
                        return;
                    }
                }

                var chunkSize = 2 * 1024 * 1024; //分块大小，2M
                var chunks = Math.ceil(file.size / chunkSize); //总块数
                var currentChunk = 0; //当前块数
                var spark = new SparkMD5(); //获取MD5对象

                fileReader.onload = function (e) { //数据加载完毕事件

                    var binaryStr = "";
                    var bytes = new Uint8Array(e.target.result);
                    var length = bytes.byteLength;
                    for (var i = 0; i < length; i++) {
                        binaryStr += String.fromCharCode(bytes[i]); //二进制转换字符串
                    }
                    spark.appendBinary(binaryStr);
                    currentChunk++;
                    if (currentChunk < chunks) {
                        loadNext(); //读取下一块数据
                    } else {
                        this.fileMd5 = spark.end(); //得到文件MD5值
                        if (cbOk) {
                            cbOk(this.fileMd5);
                        }
                    }
                };
                //分片读取文件

                function loadNext() {
                    var start = currentChunk * chunkSize,
                        end = start + chunkSize >= file.size ? file.size : start + chunkSize;
                    //根据开始和结束位置，切割文件
                    var b = blobSlice.call(file, start, end);
                    //readAsBinaryString ie浏览器不兼容此方法
                    //fileReader.readAsBinaryString(blobSlice.call(file, start, end));
                    fileReader.readAsArrayBuffer(b); //ie，chrome，firefox等主流浏览器兼容此方法

                }

                loadNext(); //开始读取
            };
            //上传图片或文件(用于高版本浏览器，支持FileAPI)
            this.uploadFile = function (options, cbOk, cbErr) {

                var file_upload = {
                    //初始化
                    init: function (options, cbOk, cbErr) {
                        var me = this;
                        me.file = options.file;
                        //分片上传进度回调事件
                        me.onProgressCallBack = options.onProgressCallBack;
                        //停止上传图片按钮
                        if (options.abortButton) {
                            options.abortButton.onclick = me.abortHandler;
                        }
                        me.total = me.file.size; //文件总大小
                        me.loaded = 0; //已读取字节数
                        me.step = 1080 * 1024; //分块大小，1080K
                        me.sliceSize = 0; //分片大小
                        me.sliceOffset = 0; //当前分片位置
                        me.timestamp = unixtime(); //当前时间戳
                        me.seq = nextSeq(); //请求seq
                        me.random = createRandom(); //请求随机数
                        me.fromAccount = ctx.identifier; //发送者
                        me.toAccount = options.To_Account; //接收者
                        me.fileMd5 = options.fileMd5; //文件MD5
                        me.businessType = options.businessType; //图片或文件的业务类型，群消息:1; c2c消息:2; 个人头像：3; 群头像：4;
                        me.fileType = options.fileType; //文件类型，不填为默认认为上传的是图片；1：图片；2：文件；3：短视频；4：PTT

                        me.cbOk = cbOk; //上传成功回调事件
                        me.cbErr = cbErr; //上传失败回调事件

                        me.reader = new FileReader(); //读取文件对象
                        me.blobSlice = File.prototype.mozSlice || File.prototype.webkitSlice || File.prototype.slice; //file的slice方法,不同浏览器不一样

                        me.reader.onloadstart = me.onLoadStart; //开始读取回调事件
                        me.reader.onprogress = me.onProgress; //读取文件进度回调事件
                        me.reader.onabort = me.onAbort; //停止读取回调事件
                        me.reader.onerror = me.onerror; //读取发生错误回调事件
                        me.reader.onload = me.onLoad; //分片加载完毕回调事件
                        me.reader.onloadend = me.onLoadEnd; //读取文件完毕回调事件
                    },
                    //上传方法
                    upload: function () {
                        var me = file_upload;
                        //读取第一块
                        me.readBlob(0);
                    },
                    onLoadStart: function () {
                        var me = file_upload;
                    },
                    onProgress: function (e) {
                        var me = file_upload;
                        me.loaded += e.loaded;
                        if (me.onProgressCallBack) {
                            me.onProgressCallBack(me.loaded, me.total);
                        }
                    },
                    onAbort: function () {
                        var me = file_upload;
                    },
                    onError: function () {
                        var me = file_upload;
                    },
                    onLoad: function (e) {
                        var me = file_upload;
                        if (e.target.readyState == FileReader.DONE) {
                            var slice_data_base64 = e.target.result;
                            //注意，一定要去除base64编码头部
                            var pos = slice_data_base64.indexOf(",");
                            if (pos != -1) {
                                slice_data_base64 = slice_data_base64.substr(pos + 1);
                            }
                            //封装上传图片接口的请求参数
                            var opt = {
                                'From_Account': me.fromAccount,
                                'To_Account': me.toAccount,
                                'Busi_Id': me.businessType,
                                'File_Type': me.fileType,
                                'File_Str_Md5': me.fileMd5,
                                'PkgFlag': UPLOAD_RES_PKG_FLAG.BASE64_DATA,
                                'File_Size': me.total,
                                'Slice_Offset': me.sliceOffset,
                                'Slice_Size': me.sliceSize,
                                'Slice_Data': slice_data_base64,
                                'Seq': me.seq,
                                'Timestamp': me.timestamp,
                                'Random': me.random
                            };

                            //上传成功的成功回调
                            var succCallback = function (resp) {
                                if (resp.IsFinish == 0) {
                                    me.loaded = resp.Next_Offset;
                                    if (me.loaded < me.total) {
                                        me.readBlob(me.loaded);
                                    } else {
                                        me.loaded = me.total;
                                    }
                                } else {

                                    if (me.cbOk) {
                                        var tempResp = {
                                            'ActionStatus': resp.ActionStatus,
                                            'ErrorCode': resp.ErrorCode,
                                            'ErrorInfo': resp.ErrorInfo,
                                            'File_UUID': resp.File_UUID,
                                            'File_Size': resp.Next_Offset,
                                            'URL_INFO': resp.URL_INFO,
                                            'Download_Flag': resp.Download_Flag
                                        };
                                        if (me.fileType == UPLOAD_RES_TYPE.FILE) { //如果上传的是文件，下载地址需要sdk内部拼接
                                            tempResp.URL_INFO = getFileDownUrl(resp.File_UUID, ctx.identifier, me.file.name);
                                        }
                                        me.cbOk(tempResp);
                                    }
                                }
                                Upload_Retry_Times = 0;
                            };
                            //上传失败的回调
                            var errorCallback = function (resp) {
                                if (Upload_Retry_Times < Upload_Retry_Max_Times) {
                                    Upload_Retry_Times++;
                                    setTimeout(function () {
                                        proto_uploadPic(opt, succCallback, errorCallback);
                                    }, 1000);
                                } else {
                                    me.cbErr(resp);
                                }
                                //me.cbErr
                            };
                            //分片上传图片接口
                            proto_uploadPic(opt, succCallback, errorCallback);
                        }
                    },
                    onLoadEnd: function () {
                        var me = file_upload;
                    },
                    //分片读取文件方法
                    readBlob: function (start) {
                        var me = file_upload;
                        var blob, file = me.file;
                        var end = start + me.step;
                        if (end > me.total) {
                            end = me.total;
                            me.sliceSize = end - start;
                        } else {
                            me.sliceSize = me.step;
                        }
                        me.sliceOffset = start;
                        //根据起始和结束位置，分片读取文件
                        blob = me.blobSlice.call(file, start, end);
                        //将分片的二进制数据转换为base64编码
                        me.reader.readAsDataURL(blob);
                    },
                    abortHandler: function () {
                        var me = file_upload;
                        if (me.reader) {
                            me.reader.abort();
                        }
                    }
                };

                //读取文件MD5
                getFileMD5(options.file,
                    function (fileMd5) {
                        log.info('fileMd5: ' + fileMd5);
                        options.fileMd5 = fileMd5;
                        //初始化上传参数
                        file_upload.init(options, cbOk, cbErr);
                        //开始上传文件
                        file_upload.upload();
                    },
                    cbErr
                );
            };
        };


        //web im 基础对象

        //常量对象

        //会话类型
        webim.SESSION_TYPE = SESSION_TYPE;

        webim.MSG_MAX_LENGTH = MSG_MAX_LENGTH;

        //c2c消息子类型
        webim.C2C_MSG_SUB_TYPE = C2C_MSG_SUB_TYPE;

        //群消息子类型
        webim.GROUP_MSG_SUB_TYPE = GROUP_MSG_SUB_TYPE;

        //消息元素类型
        webim.MSG_ELEMENT_TYPE = MSG_ELEMENT_TYPE;

        //群提示消息类型
        webim.GROUP_TIP_TYPE = GROUP_TIP_TYPE;

        //图片类型
        webim.IMAGE_TYPE = IMAGE_TYPE;

        //群系统消息类型
        webim.GROUP_SYSTEM_TYPE = GROUP_SYSTEM_TYPE;

        //好友系统通知子类型
        webim.FRIEND_NOTICE_TYPE = FRIEND_NOTICE_TYPE;

        //群提示消息-群资料变更类型
        webim.GROUP_TIP_MODIFY_GROUP_INFO_TYPE = GROUP_TIP_MODIFY_GROUP_INFO_TYPE;

        //浏览器信息
        webim.BROWSER_INFO = BROWSER_INFO;

        //表情对象
        webim.Emotions = webim.EmotionPicData = emotions;
        //表情标识符和index Map
        webim.EmotionDataIndexs = webim.EmotionPicDataIndex = emotionDataIndexs;

        //腾讯登录服务错误码(托管模式)
        webim.TLS_ERROR_CODE = TLS_ERROR_CODE;

        //连接状态
        webim.CONNECTION_STATUS = CONNECTION_STATUS;

        //上传图片业务类型
        webim.UPLOAD_PIC_BUSSINESS_TYPE = UPLOAD_PIC_BUSSINESS_TYPE;

        //最近联系人类型
        webim.RECENT_CONTACT_TYPE = RECENT_CONTACT_TYPE;

        //上传资源类型
        webim.UPLOAD_RES_TYPE = UPLOAD_RES_TYPE;


        /**************************************/

        //类对象
        //
        //工具对象
        webim.Tool = tool;
        //控制台打印日志对象
        webim.Log = log;

        //消息对象
        webim.Msg = Msg;
        //会话对象
        webim.Session = Session;
        //会话存储对象
        webim.MsgStore = {
            sessMap: function () {
                return MsgStore.sessMap();
            },
            sessCount: function () {
                return MsgStore.sessCount();
            },
            sessByTypeId: function (type, id) {
                return MsgStore.sessByTypeId(type, id);
            },
            delSessByTypeId: function (type, id) {
                return MsgStore.delSessByTypeId(type, id);
            },
            resetCookieAndSyncFlag: function () {
                return MsgStore.resetCookieAndSyncFlag();
            }
        };

        webim.Resources = Resources;

        /**************************************/

        // webim API impl
        //
        //基本接口
        //登录
        webim.login = webim.init = function (loginInfo, listeners, opts, cbOk, cbErr) {

            //初始化连接状态回调函数
            ConnManager.init(listeners.onConnNotify, cbOk, cbErr);

            //登录
            _login(loginInfo, listeners, opts, cbOk, cbErr);
        };
        //登出
        //需要传长轮询id
        //这样登出之后其他的登录实例还可以继续收取消息
        webim.logout = webim.offline = function (cbOk, cbErr) {
            return proto_logout('instance', cbOk, cbErr);
        };

        //登出
        //这种登出方式，所有的实例都将不会收到消息推送，直到重新登录
        webim.logoutAll = function (cbOk, cbErr) {
            return proto_logout('all', cbOk, cbErr);
        };


        //消息管理接口
        //发消息接口（私聊和群聊）
        webim.sendMsg = function (msg, cbOk, cbErr) {
            return MsgManager.sendMsg(msg, cbOk, cbErr);
        };
        //拉取未读c2c消息
        webim.syncMsgs = function (cbOk, cbErr) {
            return MsgManager.syncMsgs(cbOk, cbErr);
        };
        //拉取C2C漫游消息
        webim.getC2CHistoryMsgs = function (options, cbOk, cbErr) {
            return MsgManager.getC2CHistoryMsgs(options, cbOk, cbErr);
        };
        //拉取群漫游消息
        webim.syncGroupMsgs = function (options, cbOk, cbErr) {
            return MsgManager.syncGroupMsgs(options, cbOk, cbErr);
        };

        //上报c2c消息已读
        webim.c2CMsgReaded = function (options, cbOk, cbErr) {
            return MsgStore.c2CMsgReaded(options, cbOk, cbErr);
        };

        //上报群消息已读
        webim.groupMsgReaded = function (options, cbOk, cbErr) {
            return proto_groupMsgReaded(options, cbOk, cbErr);
        };

        //设置聊天会话自动标记已读
        webim.setAutoRead = function (selSess, isOn, isResetAll) {
            return MsgStore.setAutoRead(selSess, isOn, isResetAll);
        };

        //群组管理接口
        //
        //创建群
        webim.createGroup = function (options, cbOk, cbErr) {
            return proto_createGroup(options, cbOk, cbErr);
        };
        //创建群-高级接口
        webim.createGroupHigh = function (options, cbOk, cbErr) {
            return proto_createGroupHigh(options, cbOk, cbErr);
        };
        //申请加群
        webim.applyJoinGroup = function (options, cbOk, cbErr) {
            return proto_applyJoinGroup(options, cbOk, cbErr);
        };
        //处理加群申请(同意或拒绝)
        webim.handleApplyJoinGroupPendency = function (options, cbOk, cbErr) {
            return proto_handleApplyJoinGroupPendency(options, cbOk, cbErr);
        };

        //获取群组未决列表
        webim.getPendencyGroup = function (options, cbOk, cbErr) {
            return proto_getPendencyGroup(options, cbOk, cbErr);
        };

        //群未决已读上报
        webim.getPendencyGroupRead = function (options, cbOk, cbErr) {
            return proto_getPendencyGroupRead(options, cbOk, cbErr);
        };

        //处理邀请进群申请(同意或拒绝)
        webim.handleInviteJoinGroupRequest = function (options, cbOk, cbErr) {
            return proto_handleInviteJoinGroupRequest(options, cbOk, cbErr);
        };

        //删除加群申请
        webim.deleteApplyJoinGroupPendency = function (options, cbOk, cbErr) {
            return proto_deleteC2CMsg(options, cbOk, cbErr);
        };

        //删除群系统消息
        webim.deleteGroupSystemMsgs = function(options, cbOk, cbErr){
            options.DelMsgList.forEach(function(item){
                item.From_Account = '@TIM#SYSTEM'
            })
            return proto_deleteC2CMsg(options,cbOk,cbErr);
        }

        //主动退群
        webim.quitGroup = function (options, cbOk, cbErr) {
            return proto_quitGroup(options, cbOk, cbErr);
        };
        //搜索群组(根据名称)
        webim.searchGroupByName = function (options, cbOk, cbErr) {
            return proto_searchGroupByName(options, cbOk, cbErr);
        };
        //获取群组公开资料(根据群id搜索)
        webim.getGroupPublicInfo = function (options, cbOk, cbErr) {
            return proto_getGroupPublicInfo(options, cbOk, cbErr);
        };
        //获取群组详细资料-高级接口
        webim.getGroupInfo = function (options, cbOk, cbErr) {
            return proto_getGroupInfo(options, cbOk, cbErr);
        };
        //修改群基本资料
        webim.modifyGroupBaseInfo = function (options, cbOk, cbErr) {
            return proto_modifyGroupBaseInfo(options, cbOk, cbErr);
        };
        //获取群成员列表
        webim.getGroupMemberInfo = function (options, cbOk, cbErr) {
            return proto_getGroupMemberInfo(options, cbOk, cbErr);
        };
        //邀请好友加群
        webim.addGroupMember = function (options, cbOk, cbErr) {
            return proto_addGroupMember(options, cbOk, cbErr);
        };
        //修改群成员资料
        webim.modifyGroupMember = function (options, cbOk, cbErr) {
            return proto_modifyGroupMember(options, cbOk, cbErr);
        };
        //删除群成员
        webim.deleteGroupMember = function (options, cbOk, cbErr) {
            return proto_deleteGroupMember(options, cbOk, cbErr);
        };
        //解散群
        webim.destroyGroup = function (options, cbOk, cbErr) {
            return proto_destroyGroup(options, cbOk, cbErr);
        };
        //转让群组
        webim.changeGroupOwner = function (options, cbOk, cbErr) {
            return proto_changeGroupOwner(options, cbOk, cbErr);
        };

        //获取我的群组列表-高级接口
        webim.getJoinedGroupListHigh = function (options, cbOk, cbErr) {
            return proto_getJoinedGroupListHigh(options, cbOk, cbErr);
        };
        //获取群成员角色
        webim.getRoleInGroup = function (options, cbOk, cbErr) {
            return proto_getRoleInGroup(options, cbOk, cbErr);
        };
        //设置群成员禁言时间
        webim.forbidSendMsg = function (options, cbOk, cbErr) {
            return proto_forbidSendMsg(options, cbOk, cbErr);
        };
        //发送自定义群系统通知
        webim.sendCustomGroupNotify = function (options, cbOk, cbErr) {
            return proto_sendCustomGroupNotify(options, cbOk, cbErr);
        };

        //进入大群
        webim.applyJoinBigGroup = function (options, cbOk, cbErr) {
            return proto_applyJoinBigGroup(options, cbOk, cbErr);
        };
        //退出大群
        webim.quitBigGroup = function (options, cbOk, cbErr) {
            return proto_quitBigGroup(options, cbOk, cbErr);
        };

        //资料关系链管理接口
        //
        //获取个人资料接口，可用于搜索用户
        webim.getProfilePortrait = function (options, cbOk, cbErr) {
            return proto_getProfilePortrait(options, cbOk, cbErr);
        };
        //设置个人资料
        webim.setProfilePortrait = function (options, cbOk, cbErr) {
            return proto_setProfilePortrait(options, cbOk, cbErr);
        };
        //申请加好友
        webim.applyAddFriend = function (options, cbOk, cbErr) {
            return proto_applyAddFriend(options, cbOk, cbErr);
        };
        //获取好友申请列表
        webim.getPendency = function (options, cbOk, cbErr) {
            return proto_getPendency(options, cbOk, cbErr);
        };
        //好友申请列表已读上报
        webim.getPendencyReport = function (options, cbOk, cbErr) {
            return proto_getPendencyReport(options, cbOk, cbErr);
        };
        //删除好友申请
        webim.deletePendency = function (options, cbOk, cbErr) {
            return proto_deletePendency(options, cbOk, cbErr);
        };
        //处理好友申请
        webim.responseFriend = function (options, cbOk, cbErr) {
            return proto_responseFriend(options, cbOk, cbErr);
        };
        //获取我的好友
        webim.getAllFriend = function (options, cbOk, cbErr) {
            return proto_getAllFriend(options, cbOk, cbErr);
        };
        //删除会话
        webim.deleteChat = function (options, cbOk, cbErr) {
            return proto_deleteChat(options, cbOk, cbErr);
        };
        //删除好友
        webim.deleteFriend = function (options, cbOk, cbErr) {
            return proto_deleteFriend(options, cbOk, cbErr);
        };
        //拉黑
        webim.addBlackList = function (options, cbOk, cbErr) {
            return proto_addBlackList(options, cbOk, cbErr);
        };
        //删除黑名单
        webim.deleteBlackList = function (options, cbOk, cbErr) {
            return proto_deleteBlackList(options, cbOk, cbErr);
        };
        //获取我的黑名单
        webim.getBlackList = function (options, cbOk, cbErr) {
            return proto_getBlackList(options, cbOk, cbErr);
        };

        //获取最近会话
        webim.getRecentContactList = function (options, cbOk, cbErr) {
            return proto_getRecentContactList(options, cbOk, cbErr);
        };

        //图片或文件服务接口
        //
        //上传文件接口（高版本浏览器）
        webim.uploadFile = webim.uploadPic = function (options, cbOk, cbErr) {
            return FileUploader.uploadFile(options, cbOk, cbErr);
        };
        //提交上传图片表单接口（用于低版本ie）
        webim.submitUploadFileForm = function (options, cbOk, cbErr) {
            return FileUploader.submitUploadFileForm(options, cbOk, cbErr);
        };
        //上传图片或文件(Base64)接口
        webim.uploadFileByBase64 = webim.uploadPicByBase64 = function (options, cbOk, cbErr) {
            //请求参数
            var opt = {
                'To_Account': options.toAccount,
                'Busi_Id': options.businessType,
                'File_Type': options.File_Type,
                'File_Str_Md5': options.fileMd5,
                'PkgFlag': UPLOAD_RES_PKG_FLAG.BASE64_DATA,
                'File_Size': options.totalSize,
                'Slice_Offset': 0,
                'Slice_Size': options.totalSize,
                'Slice_Data': options.base64Str,
                'Seq': nextSeq(),
                'Timestamp': unixtime(),
                'Random': createRandom()
            };
            return proto_uploadPic(opt, cbOk, cbErr);
        };


        //获取长轮询ID
        webim.getLongPollingId = function (options, cbOk, cbErr) {
            return proto_getLongPollingId(options, cbOk, cbErr);
        };

        //获取下载地址
        webim.applyDownload = function (options, cbOk, cbErr) {
            return proto_applyDownload(options, cbOk, cbErr);
        };


        //检查是否登录
        webim.checkLogin = function (cbErr, isNeedCallBack) {
            return checkLogin(cbErr, isNeedCallBack);
        };
    })(webim);
    return webim;
}();
