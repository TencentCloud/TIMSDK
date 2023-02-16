/**
 * @brief 群组成员信息自定义字段
 * @param group_info_custom_string_info_key group_info_custom_string_info_key: 自定义字段的key
 * @param group_info_custom_string_info_value group_info_custom_string_info_value: 自定义字段的value
 */
interface GroupInfoCustemString {
    group_info_custom_string_info_key: string;
    group_info_custom_string_info_value: string;
}
/**
 * @brief 群组成员信息自定义字段
 * @param group_member_info_custom_string_info_key group_member_info_custom_string_info_key：自定义字段的key
 * @param group_member_info_custom_string_info_key group_member_info_custom_string_info_key： 自定义字段的value
 */
interface GroupMemberInfoCustemString {
    group_member_info_custom_string_info_key: string;
    group_member_info_custom_string_info_value: string;
}
/**
 * @brief 群组成员信息
 * @param group_member_info_identifier group_member_info_identifier 群组成员ID
 * @param group_member_info_join_time group_member_info_join_time 群组成员加入时间
 * @param group_member_info_member_role group_member_info_member_role 群组成员角色
 * @param group_member_info_msg_flag group_member_info_msg_flag 成员接收消息的选项
 * @param group_member_info_msg_seq group_member_info_msg_seq 消息序列号
 * @param group_member_info_shutup_time group_member_info_shutup_time 成员禁言时间
 * @param group_member_info_name_card group_member_info_name_card 成员群名片
 * @param group_member_info_custom_info group_member_info_custom_info 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
 */
interface GroupMemberInfo {
    group_member_info_identifier: string;
    group_member_info_join_time?: number;
    group_member_info_member_role?: string;
    group_member_info_msg_flag?: number;
    group_member_info_msg_seq?: number;
    group_member_info_shutup_time?: number;
    group_member_info_name_card?: string;
    group_member_info_custom_info?: Array<GroupMemberInfoCustemString>;
}
/**
 * @param create_group_param_group_name create_group_param_group_name： 群组名称（必填）
 * @param create_group_param_group_id create_group_param_group_id： 群组ID,不填时创建成功回调会返回一个后台分配的群ID
 * @param create_group_param_group_type create_group_param_group_type 群组类型,默认为Public
 * @param create_group_param_group_member_array create_group_param_group_member_array 群组初始成员数组
 * @param create_group_param_notification create_group_param_notification 群组公告
 * @param create_group_param_introduction create_group_param_introduction 群组简介
 * @param create_group_param_face_url create_group_param_face_url 群组头像URL
 * @param create_group_param_add_option create_group_param_add_option 加群选项，默认为Any
 * @param create_group_param_max_member_num create_group_param_max_member_num 群组最大成员数
 * @param create_group_param_custom_info create_group_param_custom_info 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
 */
interface GroupParams {
    create_group_param_group_name: string;
    create_group_param_group_id?: string;
    create_group_param_group_type?: number;
    create_group_param_group_member_array?: Array<GroupMemberInfo>;
    create_group_param_notification?: string;
    create_group_param_introduction?: string;
    create_group_param_face_url?: string;
    create_group_param_add_option?: number;
    create_group_param_max_member_num?: number;
    create_group_param_custom_info?: Array<GroupInfoCustemString>;
}

/**
 * @param {groupId} groupId groupId 要删除的群组ID
 * @param {string} data data  用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 */
interface DeleteGroupParams {
    groupId: string;
    data?: string;
}
/**
 * @param GroupParams params:创建组接口参数
 * @param data data: 用户自定义数据
 */
interface CreateGroupParams {
    params: GroupParams;
    data?: string;
}

/**
 * @param groupId groupId：群组ID
 * @param helloMsg helloMsg: 打招呼消息
 * @param data data：用户自定义消息
 */
interface JoinGroupParams {
    groupId: string;
    helloMsg?: string;
    data?: string;
}
/**
 * @param {groupId} groupId groupId 要删除的群组ID
 * @param {string} data data  用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 */
interface QuitGroupParams extends DeleteGroupParams {}
/** 
    @param data  data：用户自定义数据
    @param params params：邀请加入群组的Json

    @note params 的interface如下
 * ```
 *  params {
 *      group_invite_member_param_group_id: string; // 群组ID
 *      group_invite_member_param_identifier_array: Array<string>; //被邀请加入群组用户ID数组
 *       group_invite_member_param_user_data?: string; //用于自定义数据
 *      };
        ```
*/
interface InviteMemberParams {
    params: {
        group_invite_member_param_group_id: string;
        group_invite_member_param_identifier_array: Array<string>;
        group_invite_member_param_user_data?: string;
    };
    data?: string;
}

/** 
    @param data  data：用户自定义数据
    @param params 删除群组成员的Json

    @note params 的interface如下
 * ```
 *  params {
 *      group_delete_member_param_group_id: string; // 群组ID
        group_delete_member_param_identifier_array: Array<string>; // 被删除群组成员数组
        group_delete_member_param_user_data?: string; // 用于自定义数据
 *      };
        ```
*/
interface DeleteMemberParams {
    params: {
        group_delete_member_param_group_id: string;
        group_delete_member_param_identifier_array: Array<string>;
        group_delete_member_param_user_data?: string;
    };
    data?: string;
}

interface GetGroupListParams {
    groupIds: Array<string>;
    data?: string;
}
/**
 * @note 下方都是params中的字段，参数格式请参考最下方
 * @param group_modify_info_param_group_id group_modify_info_param_group_id: 群组ID
 * @param group_modify_info_param_modify_flag group_modify_info_param_modify_flag: 修改标识,可设置多个值按位
 * @param group_modify_info_param_group_name group_modify_info_param_group_name: 修改群组名称
 * @param group_modify_info_param_notification group_modify_info_param_notification: 修改群公告
 * @param group_modify_info_param_introduction group_modify_info_param_introduction: 修改群简介
 * @param group_modify_info_param_face_url group_modify_info_param_face_url: 修改群头像URL
 * @param group_modify_info_param_add_option group_modify_info_param_add_option 修改群组添加选项
 * @param group_modify_info_param_max_member_num group_modify_info_param_max_member_num 修改群最大成员数
 * @param group_modify_info_param_visible group_modify_info_param_visible 修改群是否可见
 * @param group_modify_info_param_searchable group_modify_info_param_searchable 修改群是否被搜索
 * @param group_modify_info_param_is_shutup_all group_modify_info_param_is_shutup_all 修改群组名称
 * @param group_modify_info_param_owner group_modify_info_param_owner 修改群主所有者
 * @param group_modify_info_param_custom_info group_modify_info_param_custom_info:请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
 *
 * @param data 用户自定以字段
 */
interface ModifyGroupParams {
    params: {
        group_modify_info_param_group_id: string;
        group_modify_info_param_modify_flag: number;
        group_modify_info_param_group_name?: string;
        group_modify_info_param_notification?: string;
        group_modify_info_param_introduction?: string;
        group_modify_info_param_face_url?: string;
        group_modify_info_param_add_option?: number;
        group_modify_info_param_max_member_num?: number;
        group_modify_info_param_visible?: number;
        group_modify_info_param_searchable?: number;
        group_modify_info_param_is_shutup_all?: boolean;
        group_modify_info_param_owner?: string;
        group_modify_info_param_custom_info?: Array<GroupInfoCustemString>;
    };
    data?: string;
}

/**
 * @param group_get_members_info_list_param_group_id group_get_members_info_list_param_group_id:群组ID
 * @param group_get_members_info_list_param_identifier_array group_get_members_info_list_param_identifier_array: 群成员ID列表
 * @param group_get_members_info_list_param_next_seq group_get_members_info_list_param_next_seq:分页拉取标志,第一次拉取填0,回调成功如果不为零,需要分页,调用接口传入再次拉取,直至为0
 * @param data data: 用户自定义参数
 *
 * `group_get_members_info_list_param_option参数如下
 * ```
 * @param group_get_members_info_list_param_option
 * {
 *     group_member_get_info_option_info_flag?: number; // 根据想要获取的信息过滤，默认值为0xffffffff(获取全部信息)
 *     group_member_get_info_option_role_flag?: number; //根据成员角色过滤，默认值为kTIMGroupMemberRoleFlag_All，获取所有角色
 *     group_member_get_info_option_custom_array?: Array<string>; // 请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
 *  };
 * ```
 */
interface GetGroupMemberInfoParams {
    params: {
        group_get_members_info_list_param_group_id: string;
        group_get_members_info_list_param_identifier_array?: Array<string>;
        group_get_members_info_list_param_option?: {
            group_member_get_info_option_info_flag?: number;
            group_member_get_info_option_role_flag?: number;
            group_member_get_info_option_custom_array?: Array<string>;
        };
        group_get_members_info_list_param_next_seq?: number;
    };
    data?: string;
}

/**
 * @note 注意是以下字段是params，具体参数格式请参考最下方
 * @param group_modify_member_info_group_id group_modify_member_info_group_id:群组ID
 * @param group_modify_member_info_identifier group_modify_member_info_identifier: 被设置信息的成员ID
 * @param group_modify_member_info_modify_flag group_modify_member_info_modify_flag:修改类型,可设置多个值按位或
 * @param group_modify_member_info_msg_flag group_modify_member_info_msg_flag:修改消息接收选项
 * @param group_modify_member_info_member_role group_modify_member_info_member_role:修改成员角色, 当 modify_flag 包含 kTIMGroupMemberModifyFlag_MemberRole 时必填,其他情况不用填
 * @param group_modify_member_info_shutup_time group_modify_member_info_shutup_time:修改禁言时间
 * @param group_modify_member_info_name_card group_modify_member_info_name_card:修改群名片
 * @param group_modify_member_info_custom_info group_modify_member_info_custom_info:请参考[自定义字段](https://cloud.tencent.com/document/product/269/1502#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.AD.97.E6.AE.B5)
 *
 * @param data data：用户自定参数（与params同级别）
 */
interface ModifyMemberInfoParams {
    params: {
        group_modify_member_info_group_id: string;
        group_modify_member_info_identifier: string;
        group_modify_member_info_modify_flag?: number;
        group_modify_member_info_msg_flag?: number;
        group_modify_member_info_member_role?: number;
        group_modify_member_info_shutup_time?: number;
        group_modify_member_info_name_card?: string;
        group_modify_member_info_custom_info?: Array<GroupMemberInfoCustemString>;
    };
    data?: string;
}

/**
 * @param data data(可选)：用户自定义数据
 * 
 * @param params params参数如下：
 * ```
 *  params {
        group_pendency_option_start_time: number; //设置拉取时间戳,第一次请求填0,后边根据server返回的[GroupPendencyResult]()键kTIMGroupPendencyResultNextStartTime指定的时间戳进行填写
        group_pendency_option_max_limited: number; // 拉取的建议数量,server可根据需要返回或多或少,不能作为完成与否的标志
    }
    ```
 */
interface GetPendencyListParams {
    params: {
        group_pendency_option_start_time: number;
        group_pendency_option_max_limited: number;
    };
    data?: string;
}

/**
 * @param {number} timeStamp timeStamp:已读时间戳(单位秒)。与GroupPendency键 kTIMGroupPendencyAddTime 指定的时间比较
 * @param {string} data data: 用户自定义消息
 */
interface ReportParams {
    timeStamp: number;
    data?: string;
}

/**
 * @brief 群未决消息
 * @param data data(可选)
 * 
 * params参数如下
 * ```
 * @param params: {
        group_handle_pendency_param_is_accept?: boolean; // 选填, true表示接受，false表示拒绝。默认为false
        group_handle_pendency_param_handle_msg?: string; // 选填，同意或拒绝信息,默认为空字符串
        group_handle_pendency_param_pendency: {
            group_pendency_group_id: string; // 群组ID
            group_pendency_form_identifier: string; // 请求者的ID,例如：请求加群:请求者,邀请加群:邀请人
            group_pendency_add_time: number; // 未决信息添加时间
            group_pendency_to_identifier: string; // 判决者的ID,请求加群:"",邀请加群:被邀请人
            group_pendency_pendency_type: number; // 未决请求类型
            group_pendency_handled: number; // 群未决处理状态
            group_pendency_handle_result: number; // 群未决处理操作类型
            group_pendency_apply_invite_msg: string; // 申请或邀请附加信息
            group_pendency_form_user_defined_data: string; //  申请或邀请者自定义字段
            group_pendency_approval_msg: string; // 审批信息：同意或拒绝信息
            group_pendency_to_user_defined_data: string; // 审批者自定义字段
            group_pendency_authentication: string; // 签名信息，客户不用关心
            group_pendency_self_identifier: string; // 自己的ID
            group_pendency_key: string; // 签名信息，客户不用关心
        };
    };
        ```
 */
interface HandlePendencyParams {
    params: {
        group_handle_pendency_param_is_accept?: boolean;
        group_handle_pendency_param_handle_msg?: string;
        group_handle_pendency_param_pendency: {
            group_pendency_group_id: string;
            group_pendency_form_identifier: string;
            group_pendency_add_time: number;
            group_pendency_to_identifier: string;
            group_pendency_pendency_type: number;
            group_pendency_handled: number;
            group_pendency_handle_result: number;
            group_pendency_apply_invite_msg: string;
            group_pendency_form_user_defined_data: string;
            group_pendency_approval_msg: string;
            group_pendency_to_user_defined_data: string;
            group_pendency_authentication: string;
            group_pendency_self_identifier: string;
            group_pendency_key: string;
        };
    };
    data?: string;
}

/**
 * @param {string} groupId groupId:要查询的groupId
 * @param {string} data data: 用户自定义数据
 */
interface GetOnlineMemberCountParams {
    groupId: string;
    data?: string;
}
/**
 * @brief  群搜索参数
 * @param  group_search_params_keyword_list group_search_params_keyword_list： 搜索关键字列表，最多支持5个
 * @param group_search_params_field_list group_search_params_field_list：搜索域列表表
 */
interface GroupSearchParams {
    group_search_params_keyword_list: Array<string>;
    group_search_params_field_list: Array<number>;
}
/**
 * @param  group_search_member_params_groupid_list group_search_member_params_groupid_list 列表，若为不填则搜索全部群中的群成员
 * @param group_search_member_params_keyword_list group_search_member_params_keyword_list：搜索关键字列表，最多支持5个
 * @param group_search_member_params_field_list group_search_member_params_field_list： 搜索域列表
 */
interface MemberSearchParams {
    group_search_member_params_groupid_list: Array<string>;
    group_search_member_params_keyword_list: Array<string>;
    group_search_member_params_field_list: Array<number>;
}

/**
 * @brief  群搜索参数
 * @param  group_atrribute_key group_atrribute_key 群属性 map 的 key
 * @param group_atrribute_value group_atrribute_value 群属性 map 的 value
 */
interface GroupAttributes {
    group_atrribute_key: string;
    group_atrribute_value: string;
}

interface SearchGroupParams {
    searchParams: GroupSearchParams;
    data?: string;
}

interface SearchMemberParams {
    searchParams: MemberSearchParams;
    data?: string;
}
/**
 * @param {string} groupId groupId:群组ID
 * @param attributes attributes： 群属性列表的参数
 * @param data data:用户自定义字段
 */
interface InitGroupAttributeParams {
    groupId: string;
    attributes: Array<GroupAttributes>;
    data?: string;
}

interface DeleteAttributeParams {
    groupId: string;
    attributesKey: Array<string>;
    data?: string;
}
/** 
 @param callback callback：回调
 @param data data：用户自定义数据
*/
interface GroupTipsCallbackParams {
    callback: GroupTipCallBackFun;
    data?: string;
}

/** 
 @param json_group_tip_array json_group_tip_array：群提示列表
 @param user_data user_data： ImSDK负责透传的用户自定义数据，未做任何处理
*/
interface GroupTipCallBackFun {
    (json_group_tip_array: string, user_data: string): void;
}

/** 
 @param callback callback：回调
 @param data data：用户自定义数据
*/
interface GroupAttributeCallbackParams {
    callback: GroupAttributeCallbackFun;
    data?: string;
}

/** 
*@param group_id group_id:  群组ID
 @param json_group_attibute_array json_group_attibute_array:变更的群属性列表
 @param user_data user_data:用于自定义数据
*/
// TODO json_group_attibute_array 类型也有问题
interface GroupAttributeCallbackFun {
    (
        group_id: string,
        json_group_attibute_array: string,
        user_data: string
    ): void;
}
interface MsgGroupReadReceiptCallback {
    (json_msg_readed_receipt_array: string, user_data: string): void;
}
interface MsgSendGroupMessageReceiptsParam {
    json_msg_array: string;
    user_data: string;
}
interface MsgGetGroupMessageReceiptsParam {
    json_msg_array: string;
    user_data: string;
}
interface MsgGetGroupMessageReadMembersParam {
    json_msg: string;
    filter: number;
    next_seq: string;
    count: number;
    user_data: string;
}
interface MsgGroupMessageReceiptCallbackParam {
    callback: MsgGroupReadReceiptCallback;
    user_data?: string;
}
export {
    MsgGroupMessageReceiptCallbackParam,
    MsgSendGroupMessageReceiptsParam,
    MsgGetGroupMessageReceiptsParam,
    MsgGetGroupMessageReadMembersParam,
    GroupMemberInfo,
    GroupParams,
    CreateGroupParams,
    DeleteGroupParams,
    JoinGroupParams,
    QuitGroupParams,
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
    GroupTipsCallbackParams,
    GroupTipCallBackFun,
    GroupAttributeCallbackParams,
    GroupAttributeCallbackFun,
    GroupSearchParams,
    MemberSearchParams,
    GroupAttributes,
    GroupInfoCustemString,
    GroupMemberInfoCustemString,
};
