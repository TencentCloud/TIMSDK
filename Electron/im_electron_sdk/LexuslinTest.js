const TIM = require('./im_electron_sdk/dist/index.umd')

let tim = null;

class LexuslinTest {
    constructor(tim) {
        this.tim = tim;
        this.friendshipManager = tim.getFriendshipManager();
        this.advanceMessageManager = tim.getAdvanceMessageManager();
    }
    async start() {
        try {
            this.TIMAddRecvNewMsgCallback()  
            // this.TIMRemoveRecvNewMsgCallback()
            this.TIMSetMsgReadedReceiptCallback()
            this.TIMSetMsgRevokeCallback()
            this.TIMSetMsgElemUploadProgressCallback()
            this.TIMSetOnAddFriendCallback()
            this.TIMSetOnDeleteFriendCallback()
            // this.TIMSetUpdateFriendProfileCallback()
            // this.TIMSetFriendAddRequestCallback()
            // this.TIMSetFriendApplicationListDeletedCallback()
            // this.TIMSetFriendApplicationListReadCallback()
            this.TIMSetFriendBlackListAddedCallback()
            this.TIMSetFriendBlackListDeletedCallback()
            this.TIMSetMsgUpdateCallback()

            // let res = await this.TIMFriendshipGetFriendProfileList()
            // let res = await this.TIMFriendshipAddFriend()
            // let res = await this.TIMFriendshipHandleFriendAddRequest()
            // let res = await this.TIMFriendshipModifyFriendProfile()
            // let res = await this.TIMFriendshipDeleteFriend()
            // let res = await this.TIMFriendshipCheckFriendType()
            // let res = await this.TIMFriendshipCreateFriendGroup()
            // let res = await this.TIMFriendshipGetFriendGroupList()
            // let res = await this.TIMFriendshipModifyFriendGroup()
            // let res = await this.TIMFriendshipDeleteFriendGroup()
            // let res = await this.TIMFriendshipAddToBlackList()
            // let res = await this.TIMFriendshipGetBlackList()
            // let res = await this.TIMFriendshipDeleteFromBlackList()
            // let res = await this.TIMFriendshipGetPendencyList()
            // let res = await this.TIMFriendshipDeletePendency()
            // let res = await this.TIMFriendshipReportPendencyReaded()
            // let res = await this.TIMFriendshipSearchFriends()
            // let res = await this.TIMFriendshipGetFriendsInfo()
            // let res = await this.TIMMsgSendMessage()
            // let res = await this.TIMMsgCancelSend()
            // let res = await this.TIMMsgFindMessages()
            // let res = await this.TIMMsgReportReaded()
            // let res = await this.TIMMsgRevoke()
            // let res = await this.TIMMsgFindByMsgLocatorList()
            // let res = await this.TIMMsgImportMsgList()
            // let res = await this.TIMMsgSaveMsg()
            // let res = await this.TIMMsgGetMsgList()
            // let res = await this.TIMMsgDelete()
            // let res = await this.TIMMsgListDelete()
            // let res = await this.TIMMsgClearHistoryMessage()
            // await this.TIMMsgSetC2CReceiveMessageOpt()
            let res = await this.TIMMsgGetC2CReceiveMessageOpt()
            // let res = await this.TIMMsgSetGroupReceiveMessageOpt()
            // let res = await this.TIMMsgDownloadElemToPath()
            // let res = await this.TIMMsgDownloadMergerMessage()
            // let res = await this.TIMMsgBatchSend()
            // let res = await this.TIMMsgSearchLocalMessages()

            
            // some api reture json_params=""
            console.log("==========> 成功了：", res.json_params === "" ? "none" : JSON.parse(res.json_params))
        } catch(e) {
            console.log("==========> 出错了：", e)
        }
    }
    // 1
    TIMFriendshipGetFriendProfileList() {
        return this.friendshipManager.TIMFriendshipGetFriendProfileList("user data")
    }
    // 1
    TIMFriendshipAddFriend() {
        return this.friendshipManager.TIMFriendshipAddFriend({
            friendship_add_friend_param_identifier: "lexuslin3",
            friendship_add_friend_param_friend_type: 1,
            friendship_add_friend_param_remark: "xxx",
            friendship_add_friend_param_group_name: "",
            friendship_add_friend_param_add_source: "Windows",
            friendship_add_friend_param_add_wording: "xxx",
        }, "user data")
    }
    // 1
    TIMFriendshipHandleFriendAddRequest() {
        return this.friendshipManager.TIMFriendshipHandleFriendAddRequest({
            friend_respone_identifier: "lexuslin3",
            friend_respone_action: 1,
            friend_respone_remark: "xx",
            friend_respone_group_name: "xx",
        }, "user data")
    }
    // 1
    TIMFriendshipModifyFriendProfile() {
        return this.friendshipManager.TIMFriendshipModifyFriendProfile({
            friendship_modify_friend_profile_param_identifier: "lexuslin3",
            friendship_modify_friend_profile_param_item: {
                friend_profile_item_remark: "xx",
                friend_profile_item_group_name_array: ["xx"],
                friend_profile_item_custom_string_array: [{
                    friend_profile_custom_string_info_key: "xx",
                    friend_profile_custom_string_info_value: "xx"
                }]
            }
        }, "user data")
    }
    // 1
    TIMFriendshipDeleteFriend() {
        return this.friendshipManager.TIMFriendshipDeleteFriend({
            friendship_delete_friend_param_friend_type: 1,
            friendship_delete_friend_param_identifier_array: ["lexuslin3"]
        }, "user data")
    }
    // 1
    TIMFriendshipCheckFriendType() {
        return this.friendshipManager.TIMFriendshipCheckFriendType({
            friendship_check_friendtype_param_check_type: 0,
            friendship_check_friendtype_param_identifier_array: ["lexuslin3"]
        }, "user data")
    }
    // 1
    TIMFriendshipCreateFriendGroup() {
        return this.friendshipManager.TIMFriendshipCreateFriendGroup({
            friendship_create_friend_group_param_name_array: ["ggg1"],
            friendship_create_friend_group_param_identifier_array: ["lexuslin3"],
        }, "user data")
    }
    // 1
    TIMFriendshipGetFriendGroupList() {
        return this.friendshipManager.TIMFriendshipGetFriendGroupList(["ggg2"], "user data")
    }
    // 1
    TIMFriendshipModifyFriendGroup() {
        return this.friendshipManager.TIMFriendshipModifyFriendGroup({
            friendship_modify_friend_group_param_name: "ggg2",
            // friendship_modify_friend_group_param_new_name: "ggg2",
            friendship_modify_friend_group_param_delete_identifier_array: ["lexuslin3"],
            // friendship_modify_friend_group_param_add_identifier_array: ["lexuslin3"]
        }, "user data")
    }
    // 1
    TIMFriendshipDeleteFriendGroup() {
        return this.friendshipManager.TIMFriendshipDeleteFriendGroup(["ggg2"], "user data")
    }
    // 1
    TIMFriendshipAddToBlackList() {
        return this.friendshipManager.TIMFriendshipAddToBlackList(["lexuslin2"], "user data")
    }
    // 1
    TIMFriendshipGetBlackList() {
        return this.friendshipManager.TIMFriendshipGetBlackList("user data")
    }
    // 1
    TIMFriendshipDeleteFromBlackList() {
        return this.friendshipManager.TIMFriendshipDeleteFromBlackList(["lexuslin2"], "user data")
    }
    // 1
    TIMFriendshipGetPendencyList() {
        return this.friendshipManager.TIMFriendshipGetPendencyList({
            friendship_get_pendency_list_param_type: 1,
            friendship_get_pendency_list_param_start_seq: 0,
            friendship_get_pendency_list_param_start_time: 0,
            friendship_get_pendency_list_param_limited_size: 10,
        }, "user data")
    }
    // 1
    TIMFriendshipDeletePendency() {
        return this.friendshipManager.TIMFriendshipDeletePendency({
            friendship_delete_pendency_param_type: 1,
            friendship_delete_pendency_param_identifier_array: ["test1"]
        }, "user data")
    }
    // 1
    TIMFriendshipReportPendencyReaded() {
        let timestamp =  Math.floor(+new Date/1000)
        return this.friendshipManager.TIMFriendshipReportPendencyReaded(timestamp, "user data")
    }
    // 1
    TIMFriendshipSearchFriends() {
        return this.friendshipManager.TIMFriendshipSearchFriends({
            friendship_search_param_keyword_list: ["lexus"],
            friendship_search_param_search_field_list: [1, 2, 4]
        }, "user data")
    }
    // 1
    TIMFriendshipGetFriendsInfo() {
        return this.friendshipManager.TIMFriendshipGetFriendsInfo(["lexuslin3"], "user data")
    }
    // 1, 需要设置timeout
    TIMMsgSendMessage() {
        // groupid, 1lexuslin127
        return this.advanceMessageManager.TIMMsgSendMessage("lexuslin3", 1, {
            message_elem_array: [{
                elem_type: 0,
                text_elem_content: "xxx"
            }],
            message_sender: "lexuslin"
        }, "", "user data")
        
        // return this.advanceMessageManager.TIMMsgSendMessage("1lexuslin127", 2, {
        //     message_elem_array: [{
        //         elem_type: 9,
        //         video_elem_video_type: "mov",
        //         video_elem_video_duration: 15,
        //         video_elem_video_path: "./c3b94cee5c318b590b5cff79a712af23.MOV",
        //         // video_elem_level: 0
        //     }],
        //     message_sender: "lexuslin"
        // }, "", "user data") 
    }
    // 1
    TIMMsgCancelSend() {
        return this.advanceMessageManager.TIMMsgCancelSend("lexuslin3", 1, "144115231469886159-1623751826-4234216750", "user data") // TIMConvType: 0无效1个人2群组3系统会话
    }
    // 1
    TIMMsgFindMessages() {
        return this.advanceMessageManager.TIMMsgFindMessages(["144115231469886159-1623751826-4234216750"], "user data")
    }
    // 1
    TIMMsgReportReaded() {
        return this.advanceMessageManager.TIMMsgReportReaded("lexuslin3", 1, "144115231469886159-1623751826-4234216750", "user data")
    }
    // 1
    TIMMsgRevoke() {
        return this.advanceMessageManager.TIMMsgRevoke("1lexuslin127", 2, "lexuslin-1624606470-2477778201", "user data")
    }
    // 0, TODOs, 先用TIMMsgFindMessages
    TIMMsgFindByMsgLocatorList() {
        return this.advanceMessageManager.TIMMsgFindByMsgLocatorList({
            attr1: "xxxx",
            attr1: "xxxx",
            attr1: "xxxx"
        }, "user data")
    }
    // 1
    TIMMsgImportMsgList() {
        return this.advanceMessageManager.TIMMsgImportMsgList("1lexuslin127", 2, [{
            message_elem_array: [{
                elem_type: 0,
                text_elem_content: "xxx"
            }],
            // message_conv_id: "lexuslin3",
            message_sender: "lexuslin",
        }], "user data")
    }
    // 1
    TIMMsgSaveMsg() {
        return this.advanceMessageManager.TIMMsgSaveMsg("1lexuslin127", 2, {
            message_elem_array: [{
                elem_type: 0,
                text_elem_content: "xxx"
            }],
            message_sender: "lexuslin"
        }, "user data")
    }
    // 1
    TIMMsgGetMsgList() {
        // 所有参数选填
        return this.advanceMessageManager.TIMMsgGetMsgList("lexuslin3", 1, {
            msg_getmsglist_param_last_msg: "144115225971632901-1624882630-707997467",
            msg_getmsglist_param_count: 100,
            // msg_getmsglist_param_is_remble: false,
            // msg_getmsglist_param_is_forward: true,
            // msg_getmsglist_param_last_msg_seq: 3444972625,
            // msg_getmsglist_param_time_begin: 0,
            // msg_getmsglist_param_time_period: 100000,
        }, "user data")
    }
    // 1
    TIMMsgDelete() {
        return this.advanceMessageManager.TIMMsgDelete("lexuslin3", 1, {
            msg_delete_param_msg: "144115231469886159-1624848680-2873600283",
            msg_delete_param_is_remble: true
        }, "user data")
    }
    // 0, error, code -3
    TIMMsgListDelete() {
        return this.advanceMessageManager.TIMMsgListDelete("1lexuslin127", 2, ["lexuslin-1624848891-212071158"], "user data")
    }
    // 1
    TIMMsgClearHistoryMessage() {
        return this.advanceMessageManager.TIMMsgClearHistoryMessage("lexuslin3", 1, "user data")
    }
    // 1, 初始化登陆后，还原为0
    TIMMsgSetC2CReceiveMessageOpt() {
        // TIMReceiveMessageOpt
        return this.advanceMessageManager.TIMMsgSetC2CReceiveMessageOpt(["lexuslin3"], 2, "user data")
    }
    // 1
    TIMMsgGetC2CReceiveMessageOpt() {
        return this.advanceMessageManager.TIMMsgGetC2CReceiveMessageOpt(["lexuslin3"], "user data")
    }
    // 6017, invalid params
    TIMMsgSetGroupReceiveMessageOpt() {
        return this.advanceMessageManager.TIMMsgSetGroupReceiveMessageOpt("1lexuslin127", 2, "user data")
    }
    // 1, id business等选填字段可以不填
    TIMMsgDownloadElemToPath() {
        // 参数在消息元素里面取出来
        return this.advanceMessageManager.TIMMsgDownloadElemToPath({
            msg_download_elem_param_flag: 2,
            msg_download_elem_param_type: 2,
            // msg_download_elem_param_id: "1400187352_lexuslin3_c3b94cee5c318b590b5cff79a712af23.MOV",
            // msg_download_elem_param_business_id: 0,
            msg_download_elem_param_url: "https://cos.ap-shanghai.myqcloud.com/0345-1400187352-1303031839/b310-lexuslin3/c3b94cee5c318b590b5cff79a712af23.MOV",
        }, "/home/lexuslin/Downloads/111.mov", "user data")
    }
    TIMMsgDownloadMergerMessage() {
        return this.advanceMessageManager.TIMMsgDownloadMergerMessage("144115231469886159-1623751826-4234216750", "user data")
    }
    // 0，20003跟send一样，（注：不能发群）
    TIMMsgBatchSend() {
        return this.advanceMessageManager.TIMMsgBatchSend({
            msg_batch_send_param_identifier_array: ["lexuslin3", "13675"],
            msg_batch_send_param_msg: {
                message_elem_array: [{
                    elem_type: 0,
                    text_elem_content: "xxx"
                }],
                message_sender: "lexuslin"
            }
        }, "user data")
    }
    // 1
    TIMMsgSearchLocalMessages() {
        return this.advanceMessageManager.TIMMsgSearchLocalMessages({
            msg_search_param_keyword_array: ["1"],
            msg_search_param_message_type_array: [0],
            msg_search_param_conv_id: "lexuslin3",
            msg_search_param_conv_type: 1,
            // msg_search_param_search_time_position: 0,
            // msg_search_param_search_time_period: 24*60*60*7,
            // msg_search_param_page_index: 0,
            // msg_search_param_page_size: 100,
        }, "user data")
    }
    // callback begin
    // 1
    TIMAddRecvNewMsgCallback() {
        this.advanceMessageManager.TIMAddRecvNewMsgCallback((json_msg_array, user_data) => {
            console.log("TIMAddRecvNewMsgCallback", json_msg_array)
        }, "user data")
    }
    // TODO:设置无效
    TIMRemoveRecvNewMsgCallback() {
        this.advanceMessageManager.TIMRemoveRecvNewMsgCallback()
    }
    TIMSetMsgReadedReceiptCallback() {
        this.advanceMessageManager.TIMSetMsgReadedReceiptCallback((json_msg_readed_receipt_array, user_data) => {
            console.log("TIMSetMsgReadedReceiptCallback", json_msg_readed_receipt_array)
        }, "user data")
    }
    TIMSetMsgRevokeCallback() {
        this.advanceMessageManager.TIMSetMsgRevokeCallback((json_msg_locator_array, user_data) => {
            console.log("TIMSetMsgRevokeCallback", json_msg_locator_array)
        }, "user data")
    }
    TIMSetMsgElemUploadProgressCallback() {
        this.advanceMessageManager.TIMSetMsgElemUploadProgressCallback((json_msg, index, cur_size, total_size, user_data) => {
            console.log("TIMSetMsgElemUploadProgressCallback", json_msg, index, cur_size, total_size)
        }, "user data")
    }
    TIMSetOnAddFriendCallback() {
        this.friendshipManager.TIMSetOnAddFriendCallback((json_identifier_array, user_data) => {
            console.log("TIMSetOnAddFriendCallback", json_identifier_array)
        }, "user data")
    }
    TIMSetOnDeleteFriendCallback() {
        this.friendshipManager.TIMSetOnDeleteFriendCallback((json_identifier_array, user_data) => {
            console.log("TIMSetOnDeleteFriendCallback", json_identifier_array)
        }, "user data")
    }
    TIMSetUpdateFriendProfileCallback() {
        this.friendshipManager.TIMSetUpdateFriendProfileCallback((json_friend_profile_update_array, user_data) => {
            console.log("TIMSetUpdateFriendProfileCallback", json_friend_profile_update_array)
        }, "user data")
    }
    TIMSetFriendAddRequestCallback() {
        this.friendshipManager.TIMSetFriendAddRequestCallback((json_friend_add_request_pendency_array, user_data) => {
            console.log("TIMSetFriendAddRequestCallback", json_friend_add_request_pendency_array)
        }, "user data")
    }
    TIMSetFriendApplicationListDeletedCallback() {
        this.friendshipManager.TIMSetFriendApplicationListDeletedCallback((json_identifier_array, user_data) => {
            console.log("TIMSetFriendApplicationListDeletedCallback", json_identifier_array)
        }, "user data")
    }
    TIMSetFriendApplicationListReadCallback() {
        this.friendshipManager.TIMSetFriendApplicationListReadCallback((user_data) => {
            console.log("TIMSetFriendApplicationListReadCallback", "TIMSetFriendApplicationListReadCallback")
        }, "user data")
    }
    TIMSetFriendBlackListAddedCallback() {
        this.friendshipManager.TIMSetFriendBlackListAddedCallback((json_friend_black_added_array, user_data) => {
            console.log("TIMSetFriendBlackListAddedCallback", json_friend_black_added_array)
        }, "user data")
    }
    TIMSetFriendBlackListDeletedCallback() {
        this.friendshipManager.TIMSetFriendBlackListDeletedCallback((json_identifier_array, user_data) => {
            console.log("TIMSetFriendBlackListDeletedCallback", json_identifier_array)
        }, "user data")
    }
    TIMSetMsgUpdateCallback() {
        this.advanceMessageManager.TIMSetMsgUpdateCallback((json_msg_array, user_data) => {
            console.log("TIMSetMsgUpdateCallback", json_msg_array)
        }, "user data")
    } 
}

module.exports = {
    LexuslinTest
}