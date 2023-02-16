import {
    TIMFriendType,
    TIMFriendResponseAction,
    TIMFriendPendencyType,
    TIMGenderType,
    TIMProfileAddPermission,
} from "../enum";

interface GetFriendProfileListParams {
    user_data?: string;
}
/**
* @brief 添加好友接口的参数
* @param params params
* @param user_data user_data: 用户自定义数据
* ```
*    params: {
        friendship_add_friend_param_identifier?: string; // 请求加好友对应的UserID
        friendship_add_friend_param_friend_type?: TIMFriendType; // 请求添加好友的好友类型
        friendship_add_friend_param_remark?: string; // 预备注
        friendship_add_friend_param_group_name?: string; // 预分组名
        friendship_add_friend_param_add_source?: string; // 加好友来源描述
        friendship_add_friend_param_add_wording?: string; // 加好友附言
    };
*
* ```
*/
interface AddFriendParams {
    params: {
        friendship_add_friend_param_identifier?: string;
        friendship_add_friend_param_friend_type?: TIMFriendType;
        friendship_add_friend_param_remark?: string;
        friendship_add_friend_param_group_name?: string;
        friendship_add_friend_param_add_source?: string;
        friendship_add_friend_param_add_wording?: string;
    };
    user_data?: string;
}

/**
* @brief 删除好友接口的参数
* @param user_data user_data: 用户自定义数据
* @param params params参数如下
* ```
*    params: {
        friendship_delete_friend_param_friend_type?: TIMFriendType; // 删除好友，指定删除的好友类型
        friendship_delete_friend_param_identifier_array?: [string]; // 删除好友UserID列表
    };
*
* ```
*/
interface DeleteFriendParams {
    params: {
        friendship_delete_friend_param_friend_type?: TIMFriendType;
        friendship_delete_friend_param_identifier_array?: [string];
    };
    user_data?: string;
}
/**
* @brief 修改好友资料接口的参数
* @param params params
* @param user_data user_data: 用户自定义数据
* ```
*    params: {
        friendship_modify_friend_profile_param_identifier?: string; // 被修改的好友的UserID
        friendship_modify_friend_profile_param_item?: FriendProfileItem; // 修改的好友资料各个选项
    };
*
* ```
*/
interface ModifyFriendProfileParams {
    params: {
        friendship_modify_friend_profile_param_identifier?: string;
        friendship_modify_friend_profile_param_item?: FriendProfileItem;
    };
    user_data?: string;
}

/**
* @brief 检测好友的类型接口的参数
* @param user_data user_data: 用户自定义数据
* @param params params的参数如下
* ```
*    params: {
        friendship_check_friendtype_param_check_type?: TIMFriendType; // 要检测的好友类型
        friendship_check_friendtype_param_identifier_array?: [string]; // 要检测的好友UserID列表
    };
*
* ```
*/
interface CheckFriendTypeParams {
    params: {
        friendship_check_friendtype_param_check_type?: TIMFriendType;
        friendship_check_friendtype_param_identifier_array?: [string];
    };
    user_data?: string;
}

/**
* @brief 好友分组信息
* @param user_data user_data: 用户自定义数据
* @param params params参数如下展示：
* ```
*    params: {
        friendship_create_friend_group_param_name_array?: [string]; // 创建分组的名称列表
        friendship_create_friend_group_param_identifier_array?: [string]; // 要放到创建的分组的好友UserID列表
    };
*
* ```
*/
interface CreateFriendGroupParams {
    params: {
        friendship_create_friend_group_param_name_array?: [string];
        friendship_create_friend_group_param_identifier_array?: [string];
    };
    user_data?: string;
}
/**
 * @param user_data user_data:用户自定义数据
 * @param params params 要删除的分组GroupNameList/黑名单是userIDList/好友也是userIDList
 */
interface FriendshipStringArrayParams {
    params: string[];
    user_data?: string;
}

/**
 * @param user_data user_data:用户自定义数据
 */
interface GetBlackListParams {
    user_data?: string;
}

/**
* @brief 好友添加的响应
* @param params params
* @param user_data user_data: 用户自定义数据
* ```
*    params: {
        friend_respone_identifier?: string; // 响应好友添加的UserID
        friend_respone_action?: TIMFriendResponseAction; // 响应好友添加的动作
        friend_respone_remark?: string; // 好友备注
        friend_respone_group_name?: string; // 好友分组列表
    };
*
* ```
*/
interface HandleFriendAddParams {
    params: {
        friend_respone_identifier?: string;
        friend_respone_action?: TIMFriendResponseAction;
        friend_respone_remark?: string;
        friend_respone_group_name?: string;
    };
    user_data?: string;
}

/**
* @brief 修改好友分组信息的接口参数
* @param params params
* @param user_data user_data: 用户自定义数据
* ```
*    params: {
        friendship_modify_friend_group_param_name?: string; // 要修改的分组名称
        friendship_modify_friend_group_param_new_name?: string; // 修改后的分组名称
        friendship_modify_friend_group_param_delete_identifier_array?: [string]; // 要从当前分组删除的好友UserID列表
        friendship_modify_friend_group_param_add_identifier_array?: [string]; // 当前分组要新增的好友UserID列表
    };
*
* ```
*/
interface ModifyFriendGroupParams {
    params: {
        friendship_modify_friend_group_param_name?: string;
        friendship_modify_friend_group_param_new_name?: string;
        friendship_modify_friend_group_param_delete_identifier_array?: [string];
        friendship_modify_friend_group_param_add_identifier_array?: [string];
    };
    user_data?: string;
}

/**
* @brief 翻页获取好友添加请求未决信息列表的参数
* @param params params
* @param user_data user_data: 用户自定义数据
* ```
*    params: {
        friendship_get_pendency_list_param_type?: number; // 获取好友添加请求未决类
        friendship_get_pendency_list_param_start_seq?: number; // 获取未决的起始seq 未决列表序列号。建议客户端保存 seq 和未决列表，请求时填入 server 返回的 seq 。如果 seq 是 server 最新的，则不返回数据
        friendship_get_pendency_list_param_start_time?: number; // 获取未决信息的开始时间戳
        friendship_get_pendency_list_param_limited_size?: number; // 获取未决信息列表，每页的数量
    };
*
* ```
*/
interface FriendshipGetPendencyListParams {
    params: {
        friendship_get_pendency_list_param_type?: number;
        friendship_get_pendency_list_param_start_seq?: number;
        friendship_get_pendency_list_param_start_time?: number;
        friendship_get_pendency_list_param_limited_size?: number;
    };
    user_data?: string;
}

/**
* @brief 删除好友添加请求未决信息接口的参数
* @param params params
* @param user_data user_data: 用户自定义数据
* ```
*    params: {
        friendship_delete_pendency_param_type?: TIMFriendPendencyType; // 删除好友添加请求未决的类型
        friendship_delete_pendency_param_identifier_array?: [string]; // 删除好友未决请求的UserID列表
    };
*
* ```
*/
interface DeletePendencyParams {
    params: {
        friendship_delete_pendency_param_type?: TIMFriendPendencyType;
        friendship_delete_pendency_param_identifier_array?: [string];
    };
    user_data?: string;
}
/**
 * @param timestamp timestamp:上报未决信息已读时间戳(单位秒)，填 0 默认会获取当前的时间戳
 * @param user_data user_data:用户自定义数据
 */
interface ReportPendencyReadedParams {
    timestamp?: number;
    user_data?: string;
}

/**
* @brief 搜索好友的参数
* @param params params
* @param user_data user_data: 用户自定义数据
* ```
*    params: {
        friendship_search_param_keyword_list?: [string]; // 关键字列表最多支持 5 个
        friendship_search_param_search_field_list?: [number]; // 好友搜索类型（如下）
        //    kTIMFriendshipSearchFieldKey_Identifier = 0x01,  // userid
        // kTIMFriendshipSearchFieldKey_NikeName = 0x01 << 1, // 昵称
        // kTIMFriendshipSearchFieldKey_Remark = 0x01 << 2, // 备注
    };
*
* ```
*/
interface SearchFriendsParams {
    params: {
        friendship_search_param_keyword_list?: [string];
        friendship_search_param_search_field_list?: [number];
    };
    user_data?: string;
}

interface ErrorResponse {
    code?: number;
    desc?: String;
    json_params?: String;
    user_data?: String;
}

/**
 * @brief 好友资料可修改的各个项
 * @param friend_profile_item_remark  friend_profile_item_remark：修改好友备注
 * @param friend_profile_item_group_name_array friend_profile_item_group_name_array： 修改好友分组名称列表
 * @param friend_profile_item_custom_string_array friend_profile_item_custom_string_array：修改[自定义好友字段](https://cloud.tencent.com/document/product/269/1501#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5)
 */
interface FriendProfileItem {
    friend_profile_item_remark?: string;
    friend_profile_item_group_name_array?: [];
    friend_profile_item_custom_string_array?: [FriendProfileCustemStringInfo];
}

/**
 * @brief 好友自定义资料字段
 * @param friend_profile_custom_string_info_key friend_profile_custom_string_info_key：好友自定义资料字段key
 * @param friend_profile_custom_string_info_value friend_profile_custom_string_info_value：好友自定义资料字段value
 * @param user_data user_data：用户自定义数据
 */
interface FriendProfileCustemStringInfo {
    user_data?: string;
    friend_profile_custom_string_info_key?: string;
    friend_profile_custom_string_info_value?: string;
}
/**
 * @param callback callback：添加好友回调
 * @param user_data user_data：用户自定义数据
 */
interface TIMOnAddFriendCallbackParams {
    callback: TIMOnAddFriendCallbackFunc;
    user_data?: string;
}
/**
 *  @param callback callback：设置删除好友的回调
 *  @param user_data user_data：用户自定义数据
 */
interface TIMOnDeleteFriendCallbackParams {
    callback: TIMOnDeleteFriendCallbackFunc;
    user_data?: string;
}
/**
 * @param callback callback：更新好友资料回调
 * @param user_data user_data：用户自定义数据
 */
interface TIMUpdateFriendProfileCallbackParams {
    callback: TIMUpdateFriendProfileCallbackFunc;
    user_data?: string;
}
/**
 * @param callback 好友请求回调
 * @param user_data 用户自定义数据
 */
interface TIMFriendAddRequestCallbackParams {
    callback: TIMFriendAddRequestCallbackFunc;
    user_data?: string;
}
/**
 * @param callback 设置好友申请删除的回调
 * @param user_data 用户自定义数据
 */
interface TIMFriendApplicationListDeletedCallbackParams {
    callback: TIMFriendApplicationListDeletedCallbackFunc;
    user_data?: string;
}
/**
 * @param callback 设置好友申请已读的回调
 * @param user_data 用户自定义数据
 */
interface TIMFriendApplicationListReadCallbackParams {
    callback: TIMFriendApplicationListReadCallbackFunc;
    user_data?: string;
}
/**
 * @param callback 黑名单新增的回调
 * @param user_data 用户自定义数据
 */
interface TIMFriendBlackListAddedCallbackParams {
    callback: TIMFriendBlackListAddedCallbackFunc;
    user_data?: string;
}
/**
 * @param callback 黑名单删除的回调
 * @param user_data 用户自定义数据
 */
interface TIMFriendBlackListDeletedCallbackParams {
    callback: TIMFriendBlackListDeletedCallbackFunc;
    user_data?: string;
}
/**
 * @param json_identifier_array json_identifier_array:添加好友列表(item是用户ID)
 * @param user_data user_data:用户自定义数据
 */
interface TIMOnAddFriendCallbackFunc {
    (json_identifier_array: string, user_data: string): void;
}
/**
 * @param json_identifier_array json_identifier_array：删除好友列表（item是用户ID)
 * @param user_data user_data：ImSDK负责透传的用户自定义数据，未做任何处理
 */
interface TIMOnDeleteFriendCallbackFunc {
    (json_identifier_array: string, user_data: string): void;
}
/**
 * @param json_friend_profile_update_array json_friend_profile_update_array:好友资料更新列表（item为[FriendProfileItem](./interface_friendshipinterface.friendprofileitem.html)）
 * @param user_data user_data：ImSDK负责透传的用户自定义数据，未做任何处理
 */
interface TIMUpdateFriendProfileCallbackFunc {
    (json_friend_profile_update_array: string, user_data: string): void;
}
/**
 * @param json_friend_add_request_pendency_array json_friend_add_request_pendency_array:好友添加请求未决信息列表(item参考[FriendAddPendency](./interface_friendshipinterface.friendaddpendency.html))
 * @param user_data user_data：ImSDK负责透传的用户自定义数据，未做任何处理
 */
interface TIMFriendAddRequestCallbackFunc {
    (json_friend_add_request_pendency_array: string, user_data: string): void;
}
/**
 * @param json_identifier_array json_identifier_array：json_identifier_array:删除好友请求的 userid 列表
 * @param user_data user_data：ImSDK负责透传的用户自定义数据，未做任何处理
 */
interface TIMFriendApplicationListDeletedCallbackFunc {
    (json_identifier_array: string, user_data: string): void;
}
/**
 * @param user_data ImSDK负责透传的用户自定义数据，未做任何处理
 */
interface TIMFriendApplicationListReadCallbackFunc {
    (user_data: string): void;
}
/**
 * @param json_friend_black_added_array  json_friend_black_added_array：新增黑名单列表（item参考[FriendProfile](./interface_friendshipinterface.friendprofile.html)）
 * @param user_data user_data：ImSDK负责透传的用户自定义数据，未做任何处理
 *
 */
interface TIMFriendBlackListAddedCallbackFunc {
    (json_friend_black_added_array: string, user_data: string): void;
}
/**
 * @param json_identifier_array  json_identifier_array：用户 ID 列表
 * @param user_data user_data：ImSDK负责透传的用户自定义数据，未做任何处理
 */
interface TIMFriendBlackListDeletedCallbackFunc {
    (json_identifier_array: string, user_data: string): void;
}

/*************************不在项目内使用的interface，文档中使用*************************************** */

/**
 * @brief 用户个人资料
 * @param {string} user_profile_item_nick_name user_profile_item_nick_name:修改用户昵称
 * @param {string} user_profile_item_gender user_profile_item_gender:修改用户性别
 * @param {string} user_profile_item_face_url user_profile_item_face_url:修改用户头像
 * @param {string} user_profile_item_self_signature user_profile_item_self_signature:修改用户签名
 * @param {string} user_profile_item_add_permission user_profile_item_add_permission:修改用户加好友的选项
 * @param {string} user_profile_item_location user_profile_item_location:修改位置
 * @param {string} user_profile_item_language user_profile_item_language:修改语言
 * @param {string} user_profile_item_birthday user_profile_item_birthday:修改生日
 * @param {string} user_profile_item_level user_profile_item_level:修改等级
 * @param {string} user_profile_item_role user_profile_item_role:修改角色
 * @param {string} user_profile_item_custom_string_array user_profile_item_custom_string_array:修改[自定义资料字段](https://cloud.tencent.com/document/product/269/1500#.E8.87.AA.E5.AE.9A.E4.B9.89.E8.B5.84.E6.96.99.E5.AD.97.E6.AE.B5)
 * @note 此interface只为了 方便用户展示返回值，项目中并不做使用
 */
interface UserProfile {
    user_profile_item_nick_name?: string;
    user_profile_item_gender?: TIMGenderType;
    user_profile_item_face_url?: string;
    user_profile_item_self_signature?: string;
    user_profile_item_add_permission?: TIMProfileAddPermission;
    user_profile_item_location?: number;
    user_profile_item_language?: number;
    user_profile_item_birthday?: number;
    user_profile_item_level?: number;
    user_profile_item_role?: number;
    user_profile_item_custom_string_array?: Array<UserProfileCustemStringInfo>;
}

/**
 * @brief 好友添加请求未决信息
 * @param friend_add_pendency_identifier friend_add_pendency_identifier:添加好友请求方的UserID
 * @param friend_add_pendency_nick_name friend_add_pendency_nick_name:添加好友请求方的昵称
 * @param friend_add_pendency_add_source friend_add_pendency_add_source:添加好友请求方的来源
 * @param friend_add_pendency_add_wording friend_add_pendency_add_wording:添加好友请求方的附言
 */
interface FriendAddPendency {
    friend_add_pendency_identifier: string; // 添加好友请求方的UserID
    friend_add_pendency_nick_name: string; // 添加好友请求方的昵称
    friend_add_pendency_add_source: string; // 添加好友请求方的来源
    friend_add_pendency_add_wording: string; // 添加好友请求方的附言
}

interface UserProfileCustemStringInfo {
    user_profile_custom_string_info_key: string;
    user_profile_custom_string_info_value: string;
}
/**
 * @param  friend_profile_identifier friend_profile_identifier:好友UserID
 * @param  friend_profile_group_name_array friend_profile_group_name_array:好友分组名称列表
 * @param  friend_profile_remark friend_profile_remark:好友备注，最大96字节，获取自己资料时，该字段为空
 * @param  friend_profile_add_wording friend_profile_add_wording:好友申请时的添加理由
 * @param  friend_profile_add_source friend_profile_add_source:好友申请时的添加来源
 * @param  friend_profile_add_time friend_profile_add_time:好友添加时间
 * @param  friend_profile_user_profile friend_profile_user_profile:好友的个人资料 [UserProfile](./interface_friendshipinterface.UserProfile.html))
 */
interface FriendProfile {
    friend_profile_identifier: string;
    friend_profile_group_name_array: Array<string>;
    friend_profile_remark: string;
    friend_profile_add_wording: string;
    friend_profile_add_source: string;
    friend_profile_add_time: number;
    friend_profile_user_profile: [UserProfile]; // [自定义好友字段](https://cloud.tencent.com/document/product/269/1501#.E8.87.AA.E5.AE.9A.E4.B9.89.E5.A5.BD.E5.8F.8B.E5.AD.97.E6.AE.B5)
}

export {
    ErrorResponse,
    GetFriendProfileListParams,
    AddFriendParams,
    DeleteFriendParams,
    ModifyFriendProfileParams,
    CheckFriendTypeParams,
    CreateFriendGroupParams,
    FriendshipStringArrayParams,
    GetBlackListParams,
    HandleFriendAddParams,
    ModifyFriendGroupParams,
    FriendshipGetPendencyListParams,
    DeletePendencyParams,
    ReportPendencyReadedParams,
    SearchFriendsParams,
    TIMOnAddFriendCallbackFunc,
    TIMOnDeleteFriendCallbackFunc,
    TIMUpdateFriendProfileCallbackFunc,
    TIMFriendAddRequestCallbackFunc,
    TIMFriendApplicationListDeletedCallbackFunc,
    TIMFriendApplicationListReadCallbackFunc,
    TIMFriendBlackListAddedCallbackFunc,
    TIMFriendBlackListDeletedCallbackFunc,
    TIMOnAddFriendCallbackParams,
    TIMOnDeleteFriendCallbackParams,
    TIMUpdateFriendProfileCallbackParams,
    TIMFriendAddRequestCallbackParams,
    TIMFriendApplicationListDeletedCallbackParams,
    TIMFriendApplicationListReadCallbackParams,
    TIMFriendBlackListAddedCallbackParams,
    TIMFriendBlackListDeletedCallbackParams,
    UserProfile,
    FriendProfileItem,
    FriendAddPendency,
    FriendProfile,
};
