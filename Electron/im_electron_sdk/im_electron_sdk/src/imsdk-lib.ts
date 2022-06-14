import { getFFIPath } from "./utils/utils";

const ffi = require("ffi-napi");
const ffiPath = getFFIPath();
const voidPtrType = function () {
    return ffi.types.CString;
};
const charPtrType = function () {
    return ffi.types.CString;
};
const intType = function () {
    return ffi.types.int;
};

const uint64Type = function () {
    return ffi.types.uint64;
};
const voidType = function () {
    return ffi.types.void;
};
const boolType = function () {
    return ffi.types.bool;
};
const callback = function () {
    return "pointer";
};

const Imsdklib = ffi.Library(ffiPath, {
    // timbaseManager start
    // 回调
    TIMSetNetworkStatusListenerCallback: [
        voidType(),
        [callback(), voidPtrType()],
    ],
    TIMSetKickedOfflineCallback: [voidType(), [callback(), voidPtrType()]],
    TIMSetUserSigExpiredCallback: [voidType(), [callback(), voidPtrType()]],
    TIMSetLogCallback: [voidType(), [callback(), voidPtrType()]],
    TIMSetConfig: [intType(), [charPtrType(), callback(), voidPtrType()]],
    callExperimentalAPI: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMProfileGetUserProfileList: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMProfileModifySelfUserProfile: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGetSDKVersion: [charPtrType(), []],
    TIMInit: [intType(), [uint64Type(), charPtrType()]],
    TIMLogin: [
        intType(),
        [charPtrType(), charPtrType(), callback(), voidPtrType()],
    ],

    TIMUninit: [intType(), []],
    TIMGetServerTime: [uint64Type(), []],
    TIMLogout: [intType(), [callback(), voidPtrType()]],
    TIMGetLoginStatus: [intType(), []],
    TIMGetLoginUserID: [intType(), [charPtrType()]],
    // timbaseManager end
    // conversationManager start
    // 已废弃
    TIMConvCreate: [
        intType(),
        [charPtrType(), intType(), callback(), voidPtrType()],
    ],
    TIMConvGetConvList: [intType(), [callback(), voidPtrType()]],
    TIMConvDelete: [
        intType(),
        [charPtrType(), intType(), callback(), voidPtrType()],
    ],
    TIMConvSetDraft: [intType(), [charPtrType(), intType(), charPtrType()]],
    TIMConvCancelDraft: [intType(), [charPtrType(), intType()]],
    TIMConvGetConvInfo: [intType(), [charPtrType(), callback(), voidPtrType()]],
    TIMConvPinConversation: [
        intType(),
        [charPtrType(), intType(), boolType(), callback(), voidPtrType()],
    ],
    TIMSetConvEventCallback: [voidType(), [callback(), voidPtrType()]],
    TIMConvGetTotalUnreadMessageCount: [intType(), [callback(), voidPtrType()]],
    TIMSetConvTotalUnreadMessageCountChangedCallback: [
        voidType(),
        [callback(), voidPtrType()],
    ],
    // conversationManager end
    // groupManager start
    TIMGroupCreate: [intType(), [charPtrType(), callback(), voidPtrType()]],
    TIMGroupDelete: [intType(), [charPtrType(), callback(), voidPtrType()]],
    TIMGroupJoin: [
        intType(),
        [charPtrType(), charPtrType(), callback(), voidPtrType()],
    ],

    TIMGroupQuit: [intType(), [charPtrType(), callback(), voidPtrType()]],
    TIMGroupInviteMember: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupDeleteMember: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupGetJoinedGroupList: [intType(), [callback(), voidPtrType()]],
    TIMGroupGetGroupInfoList: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupModifyGroupInfo: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupGetMemberInfoList: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupModifyMemberInfo: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupGetPendencyList: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupReportPendencyReaded: [
        intType(),
        [uint64Type(), callback(), voidPtrType()],
    ],
    TIMGroupHandlePendency: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupGetOnlineMemberCount: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupSearchGroups: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupSearchGroupMembers: [
        intType(),
        [charPtrType(), callback(), charPtrType()],
    ],
    TIMGroupInitGroupAttributes: [
        intType(),
        [charPtrType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupSetGroupAttributes: [
        intType(),
        [charPtrType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupDeleteGroupAttributes: [
        intType(),
        [charPtrType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMGroupGetGroupAttributes: [
        intType(),
        [charPtrType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMSetGroupTipsEventCallback: [voidType(), [callback(), voidPtrType()]],
    TIMSetGroupAttributeChangedCallback: [
        voidType(),
        [callback(), voidPtrType()],
    ],
    // groupManager end

    // friendship begin
    TIMFriendshipGetFriendProfileList: [intType(), [callback(), voidPtrType()]],
    TIMFriendshipAddFriend: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipHandleFriendAddRequest: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipModifyFriendProfile: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipDeleteFriend: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipCheckFriendType: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipCreateFriendGroup: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipGetFriendGroupList: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipModifyFriendGroup: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipDeleteFriendGroup: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipAddToBlackList: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipGetBlackList: [intType(), [callback(), voidPtrType()]],
    TIMFriendshipDeleteFromBlackList: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipGetPendencyList: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipDeletePendency: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipReportPendencyReaded: [
        intType(),
        [uint64Type(), callback(), voidPtrType()],
    ],
    TIMFriendshipSearchFriends: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMFriendshipGetFriendsInfo: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgSendMessage: [
        intType(),
        [
            charPtrType(),
            intType(),
            charPtrType(),
            charPtrType(),
            callback(),
            voidPtrType(),
        ],
    ],
    TIMMsgCancelSend: [
        intType(),
        [charPtrType(), intType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgFindMessages: [intType(), [charPtrType(), callback(), voidPtrType()]],
    TIMMsgReportReaded: [
        intType(),
        [charPtrType(), intType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgRevoke: [
        intType(),
        [charPtrType(), intType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgFindByMsgLocatorList: [
        intType(),
        [charPtrType(), intType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgImportMsgList: [
        intType(),
        [charPtrType(), intType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgSaveMsg: [
        intType(),
        [charPtrType(), intType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgGetMsgList: [
        intType(),
        [charPtrType(), intType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgDelete: [
        intType(),
        [charPtrType(), intType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgListDelete: [
        intType(),
        [charPtrType(), intType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgClearHistoryMessage: [
        intType(),
        [charPtrType(), intType(), callback(), voidPtrType()],
    ],
    TIMMsgSetC2CReceiveMessageOpt: [
        intType(),
        [charPtrType(), intType(), callback(), voidPtrType()],
    ],
    TIMMsgGetC2CReceiveMessageOpt: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgSetGroupReceiveMessageOpt: [
        intType(),
        [charPtrType(), intType(), callback(), voidPtrType()],
    ],
    TIMMsgDownloadElemToPath: [
        intType(),
        [charPtrType(), charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgDownloadMergerMessage: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgSendMessageReadReceipts: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgGetMessageReadReceipts: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMMsgGetGroupMessageReadMemberList: [
        intType(),
        [
            charPtrType(),
            intType(),
            uint64Type(),
            intType(),
            callback(),
            voidPtrType(),
        ],
    ],
    TIMMsgBatchSend: [intType(), [charPtrType(), callback(), voidPtrType()]],
    TIMMsgSearchLocalMessages: [
        intType(),
        [charPtrType(), callback(), voidPtrType()],
    ],
    TIMAddRecvNewMsgCallback: [voidType(), [callback(), voidPtrType()]],
    TIMRemoveRecvNewMsgCallback: [voidType(), [callback()]],
    TIMSetMsgReadedReceiptCallback: [voidType(), [callback(), voidPtrType()]],
    TIMSetMsgRevokeCallback: [voidType(), [callback(), voidPtrType()]],
    TIMSetMsgElemUploadProgressCallback: [
        voidType(),
        [callback(), voidPtrType()],
    ],
    TIMSetOnAddFriendCallback: [voidType(), [callback(), voidPtrType()]],
    TIMSetOnDeleteFriendCallback: [voidType(), [callback(), voidPtrType()]],
    TIMSetUpdateFriendProfileCallback: [
        voidType(),
        [callback(), voidPtrType()],
    ],
    TIMSetFriendAddRequestCallback: [voidType(), [callback(), voidPtrType()]],
    TIMSetFriendApplicationListDeletedCallback: [
        voidType(),
        [callback(), voidPtrType()],
    ],
    TIMSetFriendApplicationListReadCallback: [
        voidType(),
        [callback(), voidPtrType()],
    ],
    TIMSetFriendBlackListAddedCallback: [
        voidType(),
        [callback(), voidPtrType()],
    ],
    TIMSetFriendBlackListDeletedCallback: [
        voidType(),
        [callback(), voidPtrType()],
    ],
    TIMSetMsgUpdateCallback: [voidType(), [callback(), voidPtrType()]],
    // friendship end
});

export default Imsdklib;
