/**
 * 腾讯云 IM SDK 支持四种预设的群组类型，每种类型都有其适用场景：<br>
 * > 工作群（Work）：类似普通微信群，创建后不能自由加入，必须由已经在群的用户邀请入群。<br>
 * > 公开群（Public）：类似 QQ 群，用户申请加入，但需要群主或管理员审批。  <br>
 * > 会议群（Meeting)：适合跟 TRTC 结合实现视频会议和在线教育等场景，支持随意进出，支持查看进群前的历史消息。  <br>
 * > 直播群（AVChatRoom）：适合直播弹幕聊天室等场景，支持随意进出，人数无上限  <br>
 * @module GroupManager(群组相关接口)
 */
import {
    sdkconfig,
    libMethods,
    CreateGroupParams,
    DeleteGroupParams,
    JoinGroupParams,
    QuitGroupParams,
    CommonCallbackFun,
    commonResponse,
    InviteMemberParams,
    DeleteMemberParams,
    GetGroupListParams,
    ModifyGroupParams,
    GetGroupMemberInfoParams,
    ModifyMemberInfoParams,
    GetPendencyListParams,
    ReportParams,
    HandlePendencyParams,
    GetOnlineMemberCountParams,
    SearchGroupParams,
    SearchMemberParams,
    InitGroupAttributeParams,
    DeleteAttributeParams,
    ErrorResponse,
    GroupTipsCallbackParams,
    GroupAttributeCallbackParams,
    cache,
    MsgSendGroupMessageReceiptsParam,
    MsgGetGroupMessageReceiptsParam,
    MsgGetGroupMessageReadMembersParam,
    MsgGroupMessageReceiptCallbackParam,
    GroupReadMembersCallback,
} from "../interface";
import log from "../utils/log";
import {
    nodeStrigToCString,
    jsFuncToFFIFun,
    transformGroupTipFun,
    transformGroupAttributeFun,
    randomString,
    jsFuncToFFIFunForGroupRead,
} from "../utils/utils";

class GroupManager {
    private _imskdLib: libMethods;
    private _callback: Map<String, Function> = new Map();
    private _ffiCallback: Map<String, Buffer> = new Map();
    private _cache: Map<String, Map<string, cache>> = new Map();
    /** @internal */
    constructor(config: sdkconfig) {
        this._imskdLib = config.Imsdklib;
    }

    private stringFormator = (str: string | undefined): string =>
        str ? nodeStrigToCString(str) : nodeStrigToCString("");

    private getErrorResponse(params: ErrorResponse) {
        return {
            code: params.code || -1,
            desc: params.desc || "error",
            json_params: params.json_params || "",
            user_data: params.user_data || "",
        };
    }

    /**
     * @brief 创建群组
     * @param createGroupParams
     * @category 创建群组
     * @return  {Promise<commonResponse>} Promise的response返回值为：{ code, desc, json_param, user_data}
     * @note
     * &emsp;
     * > 创建群组时可以指定群ID，若未指定时IM通讯云服务器会生成一个唯一的ID，以便后续操作，群组ID通过创建群组时传入的回调返回
     */
    TIMGroupCreate(
        createGroupParams: CreateGroupParams
    ): Promise<commonResponse> {
        const { params, data } = createGroupParams;
        const paramsForCString = nodeStrigToCString(JSON.stringify(params));
        const userData = this.stringFormator(data);
        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupCreate")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupCreate");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupCreate", cacheMap);
            const code = this._imskdLib.TIMGroupCreate(
                paramsForCString,
                this._cache.get("TIMGroupCreate")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 删除(解散)群组
     * @param DeleteGroupParams
     * @category 删除（解散）群组
     * @return {Promise<commonResponse>} Promise的response返回值为：{ code, desc, json_param, user_data}
     *
     * @note
     * &emsp;
     * > 权限说明：
     * >   对于私有群，任何人都无法解散群组。
     * >   对于公开群、聊天室和直播大群，群主可以解散群组。
     */
    TIMGroupDelete(deleteParams: DeleteGroupParams): Promise<commonResponse> {
        const { groupId, data } = deleteParams;
        const groupID = nodeStrigToCString(groupId);
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupDelete")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);

            let cacheMap = this._cache.get("TIMGroupDelete");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupDelete", cacheMap);
            const code = this._imskdLib.TIMGroupDelete(
                groupID,
                this._cache.get("TIMGroupDelete")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 申请加入群组
     * @param JoinGroupParams
     * @return {Promise<commonResponse>}  Promise的response返回值为：{ code, desc, json_param, user_data}
     * @category 加入群组
     * @note &emsp;
     * > 权限说明：
     * > 私有群不能由用户主动申请入群。
     * > 公开群和聊天室可以主动申请进入。
     * +  如果群组设置为需要审核，申请后管理员和群主会受到申请入群系统消息，需要等待管理员或者群主审核，如果群主设置为任何人可加入，则直接入群成功。
     *    直播大群可以任意加入群组。
     */
    TIMGroupJoin(joinGroupParams: JoinGroupParams): Promise<commonResponse> {
        const { groupId, helloMsg, data } = joinGroupParams;
        const groupID = nodeStrigToCString(groupId);
        const userData = this.stringFormator(data);
        const msg = this.stringFormator(helloMsg);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupJoin")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupJoin");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupJoin", cacheMap);
            const code = this._imskdLib.TIMGroupJoin(
                groupID,
                msg,
                this._cache.get("TIMGroupJoin")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 退出群组
     * @category 退出群组
     * @param QuitGroupParams
     * @return {Promise<commonResponse>}
     *
     * @note
     *&emsp;
     * > 权限说明：
     * >   对于私有群，全员可退出群组。
     * >   对于公开群、聊天室和直播大群，群主不能退出。
     * > 退出指定群组groupId的接口，退出成功与否可根据回调cb的参数判断。
     */
    TIMGroupQuit(quitGroupParams: QuitGroupParams): Promise<commonResponse> {
        const { groupId, data } = quitGroupParams;
        const groupID = nodeStrigToCString(groupId);
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupQuit")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupQuit");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupQuit", cacheMap);
            const code = this._imskdLib.TIMGroupQuit(
                groupID,
                this._cache.get("TIMGroupQuit")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 邀请加入群组
     * @category 加入群组
     * @param InviteMemberParams
     * @return {Promise<commonResponse>}
     */
    TIMGroupInviteMember(
        inviteMemberParams: InviteMemberParams
    ): Promise<commonResponse> {
        const { params, data } = inviteMemberParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupInviteMember")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupInviteMember");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupInviteMember", cacheMap);
            const code = this._imskdLib.TIMGroupInviteMember(
                nodeStrigToCString(JSON.stringify(params)),
                this._cache.get("TIMGroupInviteMember")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }
    /**
     * @brief 删除群组成员
     * @category 删除群组成员
     * @param DeleteMemberParams
     * @return {Promise<commonResponse>}
     * @note 权限说明：
     *
     * >   对于私有群：只有创建者可删除群组成员。
     * >   对于公开群和聊天室：只有管理员和群主可以踢人。
     * >   对于直播大群：不能踢人。
     */
    TIMGroupDeleteMember(
        deleteMemberParams: DeleteMemberParams
    ): Promise<commonResponse> {
        const { params, data } = deleteMemberParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupDeleteMember")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupDeleteMember");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupDeleteMember", cacheMap);
            const code = this._imskdLib.TIMGroupDeleteMember(
                nodeStrigToCString(JSON.stringify(params)),
                this._cache.get("TIMGroupDeleteMember")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief  获取已加入群组列表
     * @category 群组信息相关接口
     * @param data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
     * @return {Promise<commonResponse>}
     *
     * @note
     * &emsp;
     * > 权限说明：
     * >   此接口可以获取自己所加入的群列表
     * >   此接口只能获得加入的部分直播大群的列表。
     */
    TIMGroupGetJoinedGroupList(data?: string): Promise<commonResponse> {
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupGetJoinedGroupList")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupGetJoinedGroupList");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupGetJoinedGroupList", cacheMap);
            const code = this._imskdLib.TIMGroupGetJoinedGroupList(
                this._cache.get("TIMGroupGetJoinedGroupList")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
    * @brief  获取群组信息列表
    * @category 群组信息相关接口
    * @param json_group_getinfo_param 获取群组信息列表参数的Json字符串
    * @param cb 获取群组信息列表成功与否的回调。回调函数定义和参数解析请参考 [TIMCommCallback](TIMCloudCallback.h)
    * @param user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
    * @return {Promise<commonResponse>} 其中get_groups_info_result_code 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](../../doc/enums/timresult.html)
    *
    * @note
    * 此接口用于获取指定群ID列表的群详细信息。具体返回的含义请暂时参考下方
    * 
    * ```
    * // 群组详细信息
    * static const char* kTIMGroupDetialInfoGroupId          = "group_detial_info_group_id";           // string, 只读, 群组ID
    static const char* kTIMGroupDetialInfoGroupType        = "group_detial_info_group_type";         // uint [TIMGroupType](), 只读, 群组类型
    static const char* kTIMGroupDetialInfoGroupName        = "group_detial_info_group_name";         // string, 只读, 群组名称
    static const char* kTIMGroupDetialInfoNotification     = "group_detial_info_notification";       // string, 只读, 群组公告
    static const char* kTIMGroupDetialInfoIntroduction     = "group_detial_info_introduction";       // string, 只读, 群组简介
    static const char* kTIMGroupDetialInfoFaceUrl          = "group_detial_info_face_url";           // string, 只读, 群组头像URL
    static const char* kTIMGroupDetialInfoCreateTime       = "group_detial_info_create_time";        // uint,   只读, 群组创建时间
    static const char* kTIMGroupDetialInfoInfoSeq          = "group_detial_info_info_seq";           // uint,   只读, 群资料的Seq，群资料的每次变更都会增加这个字段的值
    static const char* kTIMGroupDetialInfoLastInfoTime     = "group_detial_info_last_info_time";     // uint,   只读, 群组信息最后修改时间
    static const char* kTIMGroupDetialInfoNextMsgSeq       = "group_detial_info_next_msg_seq";       // uint,   只读, 群最新消息的Seq
    static const char* kTIMGroupDetialInfoLastMsgTime      = "group_detial_info_last_msg_time";      // uint,   只读, 最新群组消息时间
    static const char* kTIMGroupDetialInfoMemberNum        = "group_detial_info_member_num";         // uint,   只读, 群组当前成员数量
    static const char* kTIMGroupDetialInfoMaxMemberNum     = "group_detial_info_max_member_num";     // uint,   只读, 群组最大成员数量
    static const char* kTIMGroupDetialInfoAddOption        = "group_detial_info_add_option";         // uint [TIMGroupAddOption](), 只读, 群组加群选项
    static const char* kTIMGroupDetialInfoOnlineMemberNum  = "group_detial_info_online_member_num";  // uint,   只读, 群组在线成员数量
    static const char* kTIMGroupDetialInfoVisible          = "group_detial_info_visible";            // uint,   只读, 群组成员是否对外可见
    static const char* kTIMGroupDetialInfoSearchable       = "group_detial_info_searchable";         // uint,   只读, 群组是否能被搜索
    static const char* kTIMGroupDetialInfoIsShutupAll      = "group_detial_info_is_shutup_all";      // bool,   只读, 群组是否被设置了全员禁言
    static const char* kTIMGroupDetialInfoOwnerIdentifier  = "group_detial_info_owener_identifier";  // string, 只读, 群组所有者ID
    static const char* kTIMGroupDetialInfoCustomInfo       = "group_detial_info_custom_info";        // array [GroupInfoCustemString](), 只读, 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)

    //获取已加入群组列表接口的返回(群组基础信息)
    static const char* kTIMGroupBaseInfoGroupId      = "group_base_info_group_id";       // string, 只读, 群组ID
    static const char* kTIMGroupBaseInfoGroupName    = "group_base_info_group_name";     // string, 只读, 群组名称
    static const char* kTIMGroupBaseInfoGroupType    = "group_base_info_group_type";     // uint [TIMGroupType](), 只读, 群组类型
    static const char* kTIMGroupBaseInfoFaceUrl      = "group_base_info_face_url";       // string, 只读, 群组头像URL
    static const char* kTIMGroupBaseInfoInfoSeq      = "group_base_info_info_seq";       // uint,   只读, 群资料的Seq，群资料的每次变更都会增加这个字段的值
    static const char* kTIMGroupBaseInfoLastestSeq   = "group_base_info_lastest_seq";    // uint,   只读, 群最新消息的Seq。群组内每一条消息都有一条唯一的消息Seq，且该Seq是按照发消息顺序而连续的。从1开始，群内每增加一条消息，LastestSeq就会增加1
    static const char* kTIMGroupBaseInfoReadedSeq    = "group_base_info_readed_seq";     // uint,   只读, 用户所在群已读的消息Seq
    static const char* kTIMGroupBaseInfoMsgFlag      = "group_base_info_msg_flag";       // uint,   只读, 消息接收选项
    static const char* kTIMGroupBaseInfoIsShutupAll  = "group_base_info_is_shutup_all";  // bool,   只读, 当前群组是否设置了全员禁言
    static const char* kTIMGroupBaseInfoSelfInfo     = "group_base_info_self_info";      // object [GroupSelfInfo](), 只读, 用户所在群的个人信息
    * ```
    */
    TIMGroupGetGroupInfoList(
        getGroupListParams: GetGroupListParams
    ): Promise<commonResponse> {
        const { groupIds, data } = getGroupListParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupGetGroupInfoList")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupGetGroupInfoList");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupGetGroupInfoList", cacheMap);
            const code = this._imskdLib.TIMGroupGetGroupInfoList(
                nodeStrigToCString(JSON.stringify(groupIds)),
                this._cache.get("TIMGroupGetGroupInfoList")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief  修改群信息
     * @param ModifyGroupParams
     * @category 群组信息相关接口
     * @return {Promise<commonResponse>}
     * @note
     * &emsp;
     * > 修改群主（群转让）的权限说明：
     * >   只有群主才有权限进行群转让操作。
     * >   直播大群不能进行群转让操作。
     * >   修改群其他信息的权限说明:
     * >   对于公开群、聊天室和直播大群，只有群主或者管理员可以修改群简介。
     * >   对于私有群，任何人可修改群简介。
     */
    TIMGroupModifyGroupInfo(
        modifyGroupParams: ModifyGroupParams
    ): Promise<commonResponse> {
        const { params, data } = modifyGroupParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupModifyGroupInfo")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupModifyGroupInfo");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupModifyGroupInfo", cacheMap);
            const code = this._imskdLib.TIMGroupModifyGroupInfo(
                nodeStrigToCString(JSON.stringify(params)),
                this._cache.get("TIMGroupModifyGroupInfo")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }
    /**
     * @brief 获取群成员信息列表
     * @category 群组信息相关接口
     * @param GetGroupMemberInfoParams
     * @return {Promise<commonResponse> }
     * @note 权限说明：
     * >   任何群组类型都可以获取成员列表。
     * >   直播大群只能拉取部分成员列表：包括群主、管理员和部分成员。
     */
    TIMGroupGetMemberInfoList(
        getGroupMemberInfoParams: GetGroupMemberInfoParams
    ): Promise<commonResponse> {
        const { params, data } = getGroupMemberInfoParams;

        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupGetMemberInfoList")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupGetMemberInfoList");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupGetMemberInfoList", cacheMap);
            const code = this._imskdLib.TIMGroupGetMemberInfoList(
                nodeStrigToCString(JSON.stringify(params)),
                this._cache.get("TIMGroupGetMemberInfoList")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0)
                reject(this.getErrorResponse({ code, user_data: data }));
        });
    }
    /**
     * @brief 修改群成员信息
     * @param ModifyMemberInfoParams
     * @category 群组信息相关接口
     * @return {Promise<commonResponse>}
     * @note 权限说明：
     * > 只有群主或者管理员可以进行对群成员的身份进行修改。
     * > 直播大群不支持修改用户群内身份。
     * > 只有群主或者管理员可以进行对群成员进行禁言。
     * > kTIMGroupModifyMemberInfoParamModifyFlag 可以按位或设置多个值，不同的flag设置不同的键。请参考interface下的 ModifyMemberInfoParams
     */
    TIMGroupModifyMemberInfo(
        modifyMemberInfoParams: ModifyMemberInfoParams
    ): Promise<commonResponse> {
        const { params, data } = modifyMemberInfoParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupModifyMemberInfo")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupModifyMemberInfo");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupModifyMemberInfo", cacheMap);
            const code = this._imskdLib.TIMGroupModifyMemberInfo(
                nodeStrigToCString(JSON.stringify(params)),
                this._cache.get("TIMGroupModifyMemberInfo")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }
    /**
     * @brief  获取群未决信息列表
     *         &emsp;
     *        群未决信息是指还没有处理的操作，例如，邀请加群或者请求加群操作还没有被处理，称之为群未决信息
     * @param GetPendencyListParams
     * @category 群组信息相关接口
     *  @note 注意
     * > 此处的群未决消息泛指所有需要审批的群相关的操作。例如：加群待审批，拉人入群待审批等等。即便审核通过或者拒绝后，该条信息也可通过此接口拉回，拉回的信息中有已决标志。
     * > UserA申请加入群GroupA，则群管理员可获取此未决相关信息，UserA因为没有审批权限，不需要获取此未决信息。
     * > 如果AdminA拉UserA进去GroupA，则UserA可以拉取此未决相关信息，因为该未决信息待UserA审批
     * > 权限说明：
     * > 只有审批人有权限拉取相关未决信息。
     * > kTIMGroupPendencyOptionStartTime 设置拉取时间戳,第一次请求填0,后边根据server返回的 GroupPendencyResult键 kTIMGroupPendencyResultNextStartTime （参考下方）指定的时间戳进行填写。
     * > kTIMGroupPendencyOptionMaxLimited 拉取的建议数量,server可根据需要返回或多或少,不能作为完成与否的标志
     *      * @return {Promise<commonResponse>}
     * ```
     * // 获取群未决信息列表的返回(GroupPendencyResult JsonKey)
     *  kTIMGroupPendencyResultNextStartTime = "group_pendency_result_next_start_time";  // number, 只读, 下一次拉取的起始时戳,server返回0表示没有更多的数据,否则在下次获取数据时以这个时间戳作为开始时间戳
     *  kTIMGroupPendencyResultReadTimeSeq   = "group_pendency_result_read_time_seq";    // number, 只读, 已读上报的时间戳
     *  kTIMGroupPendencyResultUnReadNum     = "group_pendency_result_unread_num";       // number,   只读, 未决请求的未读数
     *  kTIMGroupPendencyResultPendencyArray = "group_pendency_result_pendency_array";   // array [GroupPendency](), 只读, 群未决信息列表
     * ```
     */
    TIMGroupGetPendencyList(
        getPendencyListParams: GetPendencyListParams
    ): Promise<commonResponse> {
        const { params, data } = getPendencyListParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupGetPendencyList")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupGetPendencyList");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupGetPendencyList", cacheMap);
            const code = this._imskdLib.TIMGroupGetPendencyList(
                nodeStrigToCString(JSON.stringify(params)),
                this._cache.get("TIMGroupGetPendencyList")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }
    /**
     * @brief 上报群未决信息已读
     * @category 群组信息相关接口
     * @param ReportParams
     * @return  {Promise<commonResponse>}
     *
     * @note
     * 时间戳time_stamp以前的群未决请求都将置为已读。上报已读后，仍然可以拉取到这些未决信息，但可通过对已读时戳的判断判定未决信息是否已读。
     */
    TIMGroupReportPendencyReaded(
        reportParams: ReportParams
    ): Promise<commonResponse> {
        const { timeStamp, data } = reportParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                log.info(`delete TIMGroupReportPendencyReaded Func ${now}`);
                this._cache.get("TIMGroupReportPendencyReaded")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupReportPendencyReaded");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupReportPendencyReaded", cacheMap);
            log.info(`set TIMGroupReportPendencyReaded Func ${now}`);
            log.info(`TIMGroupReportPendencyReaded ${callback}`);
            const code = this._imskdLib.TIMGroupReportPendencyReaded(
                timeStamp,
                this._cache.get("TIMGroupReportPendencyReaded")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 处理群未决信息
     * @param HandlePendencyParams
     * @category 群组信息相关接口
     * @return {Promise<commonResponse>}
     * @note 注意
     * > 对于群的未决信息，ImSDK增加了处理接口。审批人可以选择对单条信息进行同意或者拒绝。已处理成功过的未决信息不能再次处理。
     * > 处理未决信息时需要带一个未决信息[HandlePendencyParams](../../doc/interfaces/interface_groupinterface.handlependencyparams.html),
     * > 可以在接口[TIMGroupGetPendencyList](./manager_groupmanager.default.html#timgroupgetpendencylist)返回的未决信息列表将未决信息保存下来，
     * > 在处理未决信息的时候将GroupPendency传入键 group_handle_pendency_param_pendency 。
     */
    TIMGroupHandlePendency(
        handlePendencyParams: HandlePendencyParams
    ): Promise<commonResponse> {
        const { params, data } = handlePendencyParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupHandlePendency")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupHandlePendency");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupHandlePendency", cacheMap);
            const code = this._imskdLib.TIMGroupHandlePendency(
                nodeStrigToCString(JSON.stringify(params)),
                this._cache.get("TIMGroupHandlePendency")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 获取指定群在线人数
     * @category 群组信息相关接口
     * @param SearchGroupParams
     * @return {Promise<commonResponse>}
     * @note 请注意
     * - 目前只支持：直播群（ AVChatRoom）。
     * - 该接口有频限检测，SDK 限制调用频率为60秒1次
     */
    TIMGroupGetOnlineMemberCount(
        params: GetOnlineMemberCountParams
    ): Promise<commonResponse> {
        const { groupId, data } = params;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupGetOnlineMemberCount")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupGetOnlineMemberCount");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupGetOnlineMemberCount", cacheMap);
            const code = this._imskdLib.TIMGroupGetOnlineMemberCount(
                nodeStrigToCString(groupId),
                this._cache.get("TIMGroupGetOnlineMemberCount")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 搜索群列表
     *
     * @param SearchGroupParams  群列表参数
     * @return {Promise<commonResponse>}
     * @category 搜索群列表
     * @note
     *  SDK 会搜索群名称包含于关键字列表 keywordList 的所有群并返回群信息列表。关键字列表最多支持5个。
     */
    TIMGroupSearchGroups(
        searchGroupsParams: SearchGroupParams
    ): Promise<commonResponse> {
        const { searchParams, data } = searchGroupsParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupSearchGroups")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupSearchGroups");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupSearchGroups", cacheMap);
            const code = this._imskdLib.TIMGroupSearchGroups(
                nodeStrigToCString(JSON.stringify(searchParams)),
                this._cache.get("TIMGroupSearchGroups")?.get(now)?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 搜索群成员列表
     * @category 搜索群成员列表
     * @param SearchMemberParams
     * @return {Promise<commonResponse>}
     * @note
     * SDK 会在本地搜索指定群 ID 列表中，群成员信息（名片、好友备注、昵称、userID）包含于关键字列表 keywordList 的所有群成员并返回群 ID 和群成员列表的 map，关键字列表最多支持5个。
     */
    TIMGroupSearchGroupMembers(
        searchMemberParams: SearchMemberParams
    ): Promise<commonResponse> {
        const { searchParams, data } = searchMemberParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupSearchGroupMembers")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupSearchGroupMembers");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupSearchGroupMembers", cacheMap);
            const code = this._imskdLib.TIMGroupSearchGroupMembers(
                nodeStrigToCString(JSON.stringify(searchParams)),
                this._cache.get("TIMGroupSearchGroupMembers")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 初始化群属性，会清空原有的群属性列表
     * @category 群属性相关接口
     * @param InitGroupAttributeParams
     * @return {Promise<commonResponse>}
     */
    TIMGroupInitGroupAttributes(
        initAttributesParams: InitGroupAttributeParams
    ): Promise<commonResponse> {
        const { groupId, attributes, data } = initAttributesParams;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupInitGroupAttributes")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupInitGroupAttributes");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupInitGroupAttributes", cacheMap);
            const code = this._imskdLib.TIMGroupInitGroupAttributes(
                nodeStrigToCString(groupId),
                nodeStrigToCString(JSON.stringify(attributes)),
                this._cache.get("TIMGroupInitGroupAttributes")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }
    TIMMsgSendGroupMessageReceipts(
        msgSendGroupMessageReceipts: MsgSendGroupMessageReceiptsParam
    ): Promise<commonResponse> {
        const { json_msg_array, user_data } = msgSendGroupMessageReceipts;
        const userData = this.stringFormator(user_data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMMsgSendGroupMessageReceipts")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMMsgSendGroupMessageReceipts");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMMsgSendGroupMessageReceipts", cacheMap);
            const code = this._imskdLib.TIMMsgSendGroupMessageReceipts(
                nodeStrigToCString(json_msg_array),
                this._cache.get("TIMMsgSendGroupMessageReceipts")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }
    TIMMsgGetGroupMessageReceipts(
        msgGetGroupMessageReceipts: MsgGetGroupMessageReceiptsParam
    ): Promise<commonResponse> {
        const { json_msg_array, user_data } = msgGetGroupMessageReceipts;
        const userData = this.stringFormator(user_data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                console.log(code, desc, json_param, user_data);
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMMsgGetGroupMessageReceipts")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMMsgGetGroupMessageReceipts");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMMsgGetGroupMessageReceipts", cacheMap);
            const code = this._imskdLib.TIMMsgGetGroupMessageReceipts(
                this.stringFormator(json_msg_array),
                this._cache.get("TIMMsgGetGroupMessageReceipts")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }
    TIMMsgGetGroupMessageReadMembers(
        msgGetGroupMessageReadMembers: MsgGetGroupMessageReadMembersParam
    ): Promise<commonResponse> {
        const { json_msg, user_data, filter, next_seq, count } =
            msgGetGroupMessageReadMembers;
        const userData = this.stringFormator(user_data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: GroupReadMembersCallback = (
                json_group_member_array,
                next_seq,
                is_finished,
                user_data
            ) => {
                console.log(
                    json_group_member_array,
                    next_seq,
                    is_finished,
                    user_data
                );
                resolve({
                    code: 0,
                    desc: "",
                    json_param: JSON.stringify({
                        json_group_member_array,
                        next_seq,
                        is_finished,
                    }),
                    user_data,
                });
                this._cache
                    .get("TIMMsgGetGroupMessageReadMembers")
                    ?.delete(now);
            };
            const callback = jsFuncToFFIFunForGroupRead(successCallback);
            let cacheMap = this._cache.get("TIMMsgGetGroupMessageReadMembers");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMMsgGetGroupMessageReadMembers", cacheMap);

            const code = this._imskdLib.TIMMsgGetGroupMessageReadMembers(
                nodeStrigToCString(json_msg),
                filter,
                next_seq,
                count,
                this._cache.get("TIMMsgGetGroupMessageReadMembers")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 设置群属性，已有该群属性则更新其 value 值，没有该群属性则添加该群属性
     * @category 群属性相关接口
     * @param DeleteAttributeParams
     * @return {Promise<commonResponse>}
     */
    TIMGroupSetGroupAttributes(
        params: InitGroupAttributeParams
    ): Promise<commonResponse> {
        const { groupId, attributes, data } = params;
        const userData = this.stringFormator(data);

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupSetGroupAttributes")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupSetGroupAttributes");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupSetGroupAttributes", cacheMap);
            const code = this._imskdLib.TIMGroupSetGroupAttributes(
                nodeStrigToCString(groupId),
                nodeStrigToCString(JSON.stringify(attributes)),
                this._cache.get("TIMGroupSetGroupAttributes")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 删除群属性
     * @category 群属性相关接口
     * @param DeleteAttributeParams
     * @return {Promise<commonResponse>}
     */
    TIMGroupDeleteGroupAttributes(
        params: DeleteAttributeParams
    ): Promise<commonResponse> {
        const { groupId, attributesKey, data } = params;
        const userData = this.stringFormator(data);
        const formatedGroupId = nodeStrigToCString(groupId);
        const formatedAttributesKey = nodeStrigToCString(
            JSON.stringify(attributesKey)
        );

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupDeleteGroupAttributes")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupDeleteGroupAttributes");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupDeleteGroupAttributes", cacheMap);
            const code = this._imskdLib.TIMGroupDeleteGroupAttributes(
                formatedGroupId,
                formatedAttributesKey,
                this._cache.get("TIMGroupDeleteGroupAttributes")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }

    /**
     * @brief 获取群指定属性，keys 传 null 则获取所有群属性。
     * @category 群属性相关接口
     * @param DeleteAttributeParams
     * @return {Promise<commonResponse>}
     */
    TIMGroupGetGroupAttributes(
        params: DeleteAttributeParams
    ): Promise<commonResponse> {
        const { groupId, attributesKey, data } = params;
        const userData = this.stringFormator(data);
        const formatedGroupId = nodeStrigToCString(groupId);
        const formatedAttributesKey = nodeStrigToCString(
            JSON.stringify(attributesKey)
        );

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const successCallback: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                code === 0
                    ? resolve({ code, desc, json_param, user_data })
                    : reject(this.getErrorResponse({ code, desc }));
                this._cache.get("TIMGroupGetGroupAttributes")?.delete(now);
            };
            const callback = jsFuncToFFIFun(successCallback);
            let cacheMap = this._cache.get("TIMGroupGetGroupAttributes");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: successCallback,
                callback: callback,
            });
            this._cache.set("TIMGroupGetGroupAttributes", cacheMap);
            const code = this._imskdLib.TIMGroupGetGroupAttributes(
                formatedGroupId,
                formatedAttributesKey,
                this._cache.get("TIMGroupGetGroupAttributes")?.get(now)
                    ?.callback,
                userData
            );
            if (code !== 0) reject(this.getErrorResponse({ code }));
        });
    }
    private groupTipsEventCallback(
        json_group_tip_array: string,
        user_data: string
    ) {
        const fn = this._callback.get("TIMSetGroupTipsEventCallback");
        fn && fn(json_group_tip_array, user_data);
    }
    private groupAttributeChangedCallback(
        group_id: string,
        json_group_attibute_array: string,
        user_data: string
    ) {
        const fn = this._callback.get("TIMSetGroupAttributeChangedCallback");
        fn && fn(group_id, json_group_attibute_array, user_data);
    }
    /**
     * @brief 设置群组系统消息回调
     * @category 群组相关回调(callback)
     * @param GroupTipsCallbackParams
     * @note
     * 群组系统消息事件包括 加入群、退出群、踢出群、设置管理员、取消管理员、群资料变更、群成员资料变更。此消息是针对所有群组成员下发的
     */
    async TIMSetGroupTipsEventCallback(
        params: GroupTipsCallbackParams
    ): Promise<any> {
        const { callback, data } = params;
        const userData = this.stringFormator(data);
        const c_callback = transformGroupTipFun(
            this.groupTipsEventCallback.bind(this)
        );
        this._ffiCallback.set("TIMSetGroupTipsEventCallback", c_callback);
        this._callback.set("TIMSetGroupTipsEventCallback", callback);

        this._imskdLib.TIMSetGroupTipsEventCallback(
            this._ffiCallback.get("TIMSetGroupTipsEventCallback") as Buffer,
            userData
        );
    }
    private msgGroupMessageReceiptCallback(
        json_msg_readed_receipt_array: string,
        user_data: string
    ) {
        console.log("msgGroupMessageReceiptCallback called");

        const fn = this._callback.get("TIMSetMsgGroupMessageReceiptCallback");
        fn && fn(json_msg_readed_receipt_array, user_data);
    }
    async TIMSetMsgGroupMessageReceiptCallback(
        params: MsgGroupMessageReceiptCallbackParam
    ): Promise<any> {
        const { callback, user_data } = params;
        console.log(params);
        const userData = this.stringFormator(user_data);
        const c_callback = transformGroupTipFun(
            this.msgGroupMessageReceiptCallback.bind(this)
        );
        this._ffiCallback.set(
            "TIMSetMsgGroupMessageReceiptCallback",
            c_callback
        );
        this._callback.set("TIMSetMsgGroupMessageReceiptCallback", callback);

        this._imskdLib.TIMSetMsgGroupMessageReceiptCallback(
            this._ffiCallback.get(
                "TIMSetMsgGroupMessageReceiptCallback"
            ) as Buffer,
            userData
        );
        return Promise.resolve({});
    }

    /**
     * @brief 设置群组属性变更回调
     * @category 群组相关回调(callback)
     * @param GroupAttributeCallbackParams
     * @note
     * 某个已加入的群的属性被修改了，会返回所在群组的所有属性（该群所有的成员都能收到）
     */
    async TIMSetGroupAttributeChangedCallback(
        params: GroupAttributeCallbackParams
    ): Promise<any> {
        const { callback, data } = params;
        const userData = this.stringFormator(data);
        const c_callback = transformGroupAttributeFun(
            this.groupAttributeChangedCallback.bind(this)
        );
        this._ffiCallback.set(
            "TIMSetGroupAttributeChangedCallback",
            c_callback
        );
        this._callback.set("TIMSetGroupAttributeChangedCallback", callback);
        this._imskdLib.TIMSetGroupAttributeChangedCallback(
            this._ffiCallback.get(
                "TIMSetGroupAttributeChangedCallback"
            ) as Buffer,
            userData
        );
    }
}
export default GroupManager;
