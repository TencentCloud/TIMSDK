//监听 好友表添加 系统通知
/*notify对数示例：
 {
 'Type':1,//通知类型
 'Accounts':['jim','bob']//用户ID列表
 }
 */
function onFriendAddNotify(notify) {
    webim.Log.info("执行 好友表添加 回调：" + JSON.stringify(notify));
    //好友表发生变化，需要重新加载好友列表或者单独添加notify.Accounts好友帐号
    //getAllFriend(getAllFriendsCallbackOK);
    var typeCh = "[好友表添加]";
    var content = "新增以下好友：" + notify.Accounts;
    addFriendSystemMsg(notify.Type, typeCh, content);
}

//监听 好友表删除 系统通知
/*notify对数示例：
 {
 'Type':2,//通知类型
 'Accounts':['jim','bob']//用户ID列表
 }
 */
function onFriendDeleteNotify(notify) {
    webim.Log.info("执行 好友表删除 回调：" + JSON.stringify(notify));
    //好友表发生变化，需要重新加载好友列表或者单独删除notify.Accounts好友帐号
    //getAllFriend(getAllFriendsCallbackOK);
    var typeCh = "[好友表删除]";
    var content = "减少以下好友：" + notify.Accounts;
    addFriendSystemMsg(notify.Type, typeCh, content);
}

//监听 未决添加 系统通知
/*notify对象示例：
 {
 "Type":3,//通知类型
 "PendencyList":[
 {
 "PendencyAdd_Account": "peaker1",//对方帐号
 "ProfileImNic": "匹克1",//对方昵称
 "AddSource": "AddSource_Type_Unknow",//来源
 "AddWording": "你好"//申请附言
 },
 {
 "PendencyAdd_Account": "peaker2",//对方帐号
 "ProfileImNic": "匹克2",//对方昵称
 "AddSource": "AddSource_Type_Unknow",//来源
 "AddWording": "你好"//申请附言
 }
 ]
 }
 */
function onPendencyAddNotify(notify) {
    webim.Log.info("执行 未决添加 回调：" + JSON.stringify(notify));
    //收到加好友申请，弹出拉取好友申请列表
    getPendency(true);
    var typeCh = "[未决添加]";
    var pendencyList = notify.PendencyList;
    var content = "收到以下加好友申请：" + JSON.stringify(pendencyList);
    addFriendSystemMsg(notify.Type, typeCh, content);
}

//监听 未决删除 系统通知
/*notify对数示例：
 {
 'Type':4,//通知类型
 'Accounts':['jim','bob']//用户ID列表
 }
 */
function onPendencyDeleteNotify(notify) {
    webim.Log.info("执行 未决删除 回调：" + JSON.stringify(notify));
    var typeCh = "[未决删除]";
    var content = "以下好友未决已被删除：" + notify.Accounts;
    addFriendSystemMsg(notify.Type, typeCh, content);
}

//监听 好友黑名单添加 系统通知
/*notify对数示例：
 {
 'Type':5,//通知类型
 'Accounts':['jim','bob']//用户ID列表
 }
 */
function onBlackListAddNotify(notify) {
    webim.Log.info("执行 黑名单添加 回调：" + JSON.stringify(notify));
    var typeCh = "[黑名单添加]";
    var content = "新增以下黑名单：" + notify.Accounts;
    addFriendSystemMsg(notify.Type, typeCh, content);
}

//监听 好友黑名单删除 系统通知
/*notify对数示例：
 {
 'Type':6,//通知类型
 'Accounts':['jim','bob']//用户ID列表
 }
 */
function onBlackListDeleteNotify(notify) {
    webim.Log.info("执行 黑名单删除 回调：" + JSON.stringify(notify));
    var typeCh = "[黑名单删除]";
    var content = "减少以下黑名单：" + notify.Accounts;
    addFriendSystemMsg(notify.Type, typeCh, content);
}
//初始化我的好友系统消息表格
function initGetMyFriendSystemMsgs(data) {
    $('#get_my_friend_system_msgs_table').bootstrapTable({
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
        columns: [
            {field: "Type", title: "类型", align: "center", valign: "middle", sortable: "false", visible: false},
            {field: "TypeCh", title: "类型", align: "center", valign: "middle", sortable: "true"},
            {field: "MsgContent", title: "内容", align: "center", valign: "middle", sortable: "true"}
        ],
        data: data,
        formatNoMatches: function () {
            return '无符合条件的记录';
        }
    });
}

//查看我的好友系统消息
function getMyFriendSystemMsgs() {
    $('#get_my_friend_system_msgs_dialog').modal('show');
}

//增加一条好友系统消息
function addFriendSystemMsg(type, typeCh, msgContent) {
    var data = [];
    data.push({
        "Type": type,
        "TypeCh": typeCh,
        "MsgContent": webim.Tool.formatText2Html(msgContent)
    });
    $('#get_my_friend_system_msgs_table').bootstrapTable('append', data);
}