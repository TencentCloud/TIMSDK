import TimRender from "../../../im_electron_sdk/dist/renderer";
// import TimRender from "im_electron_sdk/dist/renderer";
const timRenderInstance = new TimRender();

const friendShipManager = {
    TIMFriendshipGetFriendProfileList: () => {
        return timRenderInstance.TIMFriendshipGetFriendProfileList({
            user_data: "123"
        });
    },
    TIMFriendshipAddFriend: () => {

        return timRenderInstance.TIMFriendshipAddFriend({ 
            params: {
                friendship_add_friend_param_identifier: "test_jinhui",
                friendship_add_friend_param_friend_type: 1,
                friendship_add_friend_param_remark: "test_jinhui",
                friendship_add_friend_param_group_name: "",
                friendship_add_friend_param_add_source: "Windows",
                friendship_add_friend_param_add_wording: "Hi好",
            },
            user_data: "121"
        });
    },
    TIMFriendshipHandleFriendAddRequest: () => {
        return timRenderInstance.TIMFriendshipHandleFriendAddRequest({ 
            params: {
                friend_respone_identifier: "940928",
                friend_respone_action: 1,
                friend_respone_remark: "xx",
                friend_respone_group_name: "xx",
            },
            user_data: "1234"
        });
    },
    TIMFriendshipModifyFriendProfile: () => {
        return timRenderInstance.TIMFriendshipModifyFriendProfile({ 
            params: {
                friendship_modify_friend_profile_param_identifier: "940928",
                friendship_modify_friend_profile_param_item: {
                    friend_profile_item_remark: "xx",
                    friend_profile_item_group_name_array: ["xx"], 
                }
            },
            user_data: "1234"
        });
    },
    TIMFriendshipDeleteFriend: () => {
        return timRenderInstance.TIMFriendshipDeleteFriend({ 
            params: {
                friendship_delete_friend_param_friend_type: 1,
                friendship_delete_friend_param_identifier_array: ["940928"]
            },
            user_data: "1234"
        });
    },
    TIMFriendshipCheckFriendType: () => {
        return timRenderInstance.TIMFriendshipAddFriend({ 
            params: {
                friendship_check_friendtype_param_check_type: 0,
                friendship_check_friendtype_param_identifier_array: ["940928"]  
            },
            user_data: "1234"
        });
    },
    TIMFriendshipCreateFriendGroup: () => {
        return timRenderInstance.TIMFriendshipCreateFriendGroup({ 
            params: {
                friendship_create_friend_group_param_name_array: ["ggg1"],
                friendship_create_friend_group_param_identifier_array: ["940928"],
            },
            user_data: "1234"
        });
    },
    TIMFriendshipGetFriendGroupList: () => {
        return timRenderInstance.TIMFriendshipGetFriendGroupList({ 
            params: ["ggg1"],
            user_data: "1234"
        });
    },
    TIMFriendshipModifyFriendGroup: () => {
        return timRenderInstance.TIMFriendshipModifyFriendGroup({ 
            params: {
                friendship_modify_friend_group_param_name: "ggg1",
                friendship_modify_friend_group_param_delete_identifier_array: ["940928"],
            },
            user_data: "1234"
        });
    },
    TIMFriendshipDeleteFriendGroup: () => {
        return timRenderInstance.TIMFriendshipDeleteFriendGroup({ 
            params: ["ggg1"],
            user_data: "1234"
        });
    },
    TIMFriendshipAddToBlackList: () => {
        return timRenderInstance.TIMFriendshipAddToBlackList({ 
            params: ["940928"],
            user_data: "1234"
        });
    },
    TIMFriendshipGetBlackList: () => {
        return timRenderInstance.TIMFriendshipGetBlackList({ 
            user_data: "1234"
        });
    },
    TIMFriendshipDeleteFromBlackList:() => {
        return timRenderInstance.TIMFriendshipDeleteFromBlackList({ 
            params: ["940928"],
            user_data: "1234"
        });
    },
    TIMFriendshipGetPendencyList: () => {
        return timRenderInstance.TIMFriendshipGetPendencyList({ 
            params: {
                friendship_get_pendency_list_param_type: 1,
                friendship_get_pendency_list_param_start_seq: 0,
                friendship_get_pendency_list_param_start_time: 0,
                friendship_get_pendency_list_param_limited_size: 10,
            },
            user_data: "1234"
        });
    },
    TIMFriendshipDeletePendency: () => {
        return timRenderInstance.TIMFriendshipDeletePendency({ 
            params: {
                friendship_delete_pendency_param_type: 1,
                friendship_delete_pendency_param_identifier_array: ["test1"]
            },
            user_data: "1234"
        });
    },
    TIMFriendshipReportPendencyReaded: () => {
        return timRenderInstance.TIMFriendshipReportPendencyReaded({ 
            timestamp: Math.floor(+new Date/1000),
            user_data: "1234"
        });
    },
    TIMFriendshipSearchFriends: () => {
        return timRenderInstance.TIMFriendshipSearchFriends({ 
            params: {
                friendship_search_param_keyword_list: ["940928"],
                friendship_search_param_search_field_list: [1, 2, 4]    
            },
            user_data: "1234"
        });
    },
    TIMFriendshipGetFriendsInfo: () => {
        return timRenderInstance.TIMFriendshipGetFriendsInfo({ 
            params: ["940928"],
            user_data: "1234"
        });
    },
    TIMSetOnAddFriendCallback: (callback) => {
        return timRenderInstance.TIMSetOnAddFriendCallback({
            callback: (...args) => {
                const [[data,user_data]] = args;
                callback(JSON.stringify({
                    data,user_data
                }))
            }
        })
    },
    TIMSetOnDeleteFriendCallback: (callback) => {
        return timRenderInstance.TIMSetOnDeleteFriendCallback({
            callback: (...args) => {
                const [[data,user_data]] = args;
                callback(JSON.stringify({
                    data,user_data
                }))
            }
        })
    }, 
    TIMSetUpdateFriendProfileCallback: (callback) => {
        return timRenderInstance.TIMSetUpdateFriendProfileCallback({
            callback: (...args) => {
                const [[data,user_data]] = args;
                callback(JSON.stringify({
                    data,user_data
                }))
            }
        })
    }, 
    TIMSetFriendAddRequestCallback: (callback) => {
        return timRenderInstance.TIMSetFriendAddRequestCallback({
            callback: (...args) => {
                const [[data,user_data]] = args;
                callback(JSON.stringify({
                    data,user_data
                }))
            }
        })
    }, 
    TIMSetFriendApplicationListDeletedCallback: (callback) => {
        return timRenderInstance.TIMSetFriendApplicationListDeletedCallback({
            callback: (...args) => {
                const [[data,user_data]] = args;
                callback(JSON.stringify({
                    data,user_data
                }))
            }
        })
    }, 
    TIMSetFriendApplicationListReadCallback: (callback) => {
        return timRenderInstance.TIMSetFriendApplicationListReadCallback({
            callback: (...args) => {
                const [[data,user_data]] = args;
                callback(JSON.stringify({
                    data,user_data
                }))
            }
        })
    }, 
    TIMSetFriendBlackListAddedCallback: (callback) => {
        return timRenderInstance.TIMSetFriendBlackListAddedCallback({
            callback: (...args) => {
                const [[data,user_data]] = args;
                callback(JSON.stringify({
                    data,user_data
                }))
            }
        })
    }, 
    TIMSetFriendBlackListDeletedCallback: (callback) => {
        return timRenderInstance.TIMSetFriendBlackListDeletedCallback({
            callback: (...args) => {
                const [[data,user_data]] = args;
                callback(JSON.stringify({
                    data,user_data
                }))
            }
        })
    },
}

export default friendShipManager;
