/////////////////////////////////////////////////////////////////////
//
//                     腾讯云通信服务 IMSDK
//
//  模块名称：V2TIMManager+Group
//
//  群组高级接口，里面包含了群组的高级功能，比如群成员邀请、非群成员申请进群等操作接口。
//
/////////////////////////////////////////////////////////////////////

#import "V2TIMManager.h"
#import "V2TIMManager+Message.h"
@class V2TIMGroupMemberOperationResult;
@class V2TIMGroupApplicationResult;
@class V2TIMCreateGroupMemberInfo;
@class V2TIMGroupInfo;
@class V2TIMGroupInfoResult;
@class V2TIMGroupApplication;
@class V2TIMGroupSearchParam;
@class V2TIMGroupSearchResult;
@class V2TIMGroupMemberSearchParam;
@class V2TIMGroupMemberSearchResult;
@class V2TIMGroupAtInfo;

/////////////////////////////////////////////////////////////////////////////////
//
//                         群相关的高级接口
//
/////////////////////////////////////////////////////////////////////////////////

V2TIM_EXPORT @interface V2TIMManager (Group)

/// 获取已加入群列表成功回调
typedef void (^V2TIMGroupInfoListSucc)(NSArray<V2TIMGroupInfo *> *groupList);
/// 获取指定群列表成功回调
typedef void (^V2TIMGroupInfoResultListSucc)(NSArray<V2TIMGroupInfoResult *> *groupResultList);
/// 云端搜索群组的结果回调
typedef void (^V2TIMGroupSearchResultSucc)(V2TIMGroupSearchResult *searchResult);
/// 获取群属性列表成功回调
typedef void (^V2TIMGroupAttributeListSucc)(NSMutableDictionary<NSString *,NSString *> *groupAttributeList);
/// 获取群成员列表成功回调
typedef void (^V2TIMGroupMemberInfoListSucc)(NSArray<V2TIMGroupMemberFullInfo *> *memberList);
/// 获取指定群成员列表成功回调
typedef void (^V2TIMGroupMemberInfoResultSucc)(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *>  *memberList);
/// 搜索本地群成员列表成功回调
typedef void (^V2TIMGroupMemberInfoListSearchSucc)(NSDictionary<NSString *, NSArray<V2TIMGroupMemberFullInfo *> *> *memberList);
/// 搜索云端群成员列表成功回调
typedef void (^V2TIMGroupMemberSearchResultSucc)(V2TIMGroupMemberSearchResult *searchResult);
/// 群成员操作成功回调
typedef void (^V2TIMGroupMemberOperationResultListSucc)(NSArray<V2TIMGroupMemberOperationResult*> * resultList);
/// 获取好友申请列表成功回调
typedef void (^V2TIMGroupApplicationResultSucc)(V2TIMGroupApplicationResult *result);
/// 获取群在线人数成功回调
typedef void (^V2TIMGroupOnlineMemberCountSucc)(NSInteger count);
/// 群计数器操作成功的回调
typedef void (^V2TIMGroupCounterResultSucc)(NSDictionary<NSString *, NSNumber *> *groupCounters);

/// 加群选项
typedef NS_ENUM(NSInteger, V2TIMGroupAddOpt) {
    V2TIM_GROUP_ADD_FORBID                 = 0,  ///< 禁止加群
    V2TIM_GROUP_ADD_AUTH                   = 1,  ///< 需要管理员审批
    V2TIM_GROUP_ADD_ANY                    = 2,  ///< 任何人可以加入
};

///  群组操作结果
typedef NS_ENUM(NSInteger, V2TIMGroupMemberResult) {
    V2TIM_GROUP_MEMBER_RESULT_FAIL         = 0,  ///< 操作失败
    V2TIM_GROUP_MEMBER_RESULT_SUCC         = 1,  ///< 操作成功
    V2TIM_GROUP_MEMBER_RESULT_INVALID      = 2,  ///< 无效操作，加群时已经是群成员，移除群组时不在群内
    V2TIM_GROUP_MEMBER_RESULT_PENDING      = 3,  ///< 等待处理，邀请入群时等待审批
    V2TIM_GROUP_MEMBER_RESULT_OVERLIMIT    = 4,  ///< 操作失败，创建群指定初始群成员列表或邀请入群时，被邀请者加入的群总数超限
};

/// 群成员角色过滤方式
typedef NS_ENUM(NSInteger, V2TIMGroupMemberFilter) {
    V2TIM_GROUP_MEMBER_FILTER_ALL          = 0x00,  ///< 全部成员
    V2TIM_GROUP_MEMBER_FILTER_OWNER        = 0x01,  ///< 群主
    V2TIM_GROUP_MEMBER_FILTER_ADMIN        = 0x02,  ///< 管理员
    V2TIM_GROUP_MEMBER_FILTER_COMMON       = 0x04,  ///< 普通成员
};

/// 群组未决请求类型
typedef NS_ENUM(NSInteger, V2TIMGroupApplicationType) {
    V2TIM_GROUP_JOIN_APPLICATION_NEED_APPROVED_BY_ADMIN   = 0x0,         ///< 需要群主或管理员审批的申请加群请求
    V2TIM_GROUP_INVITE_APPLICATION_NEED_APPROVED_BY_INVITEE   = 0x1,     ///< 需要被邀请者同意的邀请入群请求
    V2TIM_GROUP_INVITE_APPLICATION_NEED_APPROVED_BY_ADMIN   = 0x2,       ///< 需要群主或管理员审批的邀请入群请求
};

/// 群组已决标志
typedef NS_ENUM(NSInteger, V2TIMGroupApplicationHandleStatus) {
    V2TIM_GROUP_APPLICATION_HANDLE_STATUS_UNHANDLED           = 0,  ///< 未处理
    V2TIM_GROUP_APPLICATION_HANDLE_STATUS_HANDLED_BY_OTHER    = 1,  ///< 被他人处理
    V2TIM_GROUP_APPLICATION_HANDLE_STATUS_HANDLED_BY_SELF     = 2,  ///< 自己已处理
};

/// 群组已决结果
typedef NS_ENUM(NSInteger, V2TIMGroupApplicationHandleResult) {
    V2TIM_GROUP_APPLICATION_HANDLE_RESULT_REFUSE = 0,  ///< 拒绝申请
    V2TIM_GROUP_APPLICATION_HANDLE_RESULT_AGREE  = 1,  ///< 同意申请
};

/////////////////////////////////////////////////////////////////////////////////
//                         群管理
/////////////////////////////////////////////////////////////////////////////////

/**
 *  1.1 创建自定义群组（高级版本：可以指定初始的群成员）
 *
 *  @param info 自定义群组信息，可以设置 groupID | groupType | groupName | notification | introduction | faceURL 字段
 *  @param memberList 指定初始的群成员（直播群 AVChatRoom 不支持指定初始群成员，memberList 请传 nil）
 *
 *  @note
 *  - 后台限制邀请的群成员个数不能超过 20
 *  - 其他限制请参考 V2TIMManager.h -> createGroup 注释
 */
- (void)createGroup:(V2TIMGroupInfo*)info memberList:(NSArray<V2TIMCreateGroupMemberInfo *>* _Nullable )memberList succ:(V2TIMCreateGroupSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(createGroup(info:memberList:succ:fail:));

/**
 *  1.2 获取当前用户已经加入的群列表
 *
 *  @note
 *  - 直播群（AVChatRoom）不支持该 API
 *  - 该接口有频限检测，SDK 限制调用频率为 1 秒 10 次，超过限制后会报 ERR_SDK_COMM_API_CALL_FREQUENCY_LIMIT （7008）错误
 */
- (void)getJoinedGroupList:(V2TIMGroupInfoListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getJoinedGroupList(succ:fail:));

/////////////////////////////////////////////////////////////////////////////////
//                         群资料管理
/////////////////////////////////////////////////////////////////////////////////

/**
 *  2.1 拉取群资料
 *
 *  @param groupIDList 群组 ID 列表
 */
- (void)getGroupsInfo:(NSArray<NSString *> *)groupIDList succ:(V2TIMGroupInfoResultListSucc)succ fail:(V2TIMFail)fail;

/**
 *  2.2 搜索本地群资料（5.4.666 及以上版本支持）
 * @note 该功能为 IM 旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17474)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17176#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)
 */
- (void)searchGroups:(V2TIMGroupSearchParam *)searchParam succ:(V2TIMGroupInfoListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(searchGroups(searchParam:succ:fail:));

/**
 *  2.3 搜索云端群资料（8.4 及以上版本支持）
 * @note 该功能为 IM 增值功能，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17176#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)
 */
- (void)searchCloudGroups:(V2TIMGroupSearchParam *)searchParam succ:(V2TIMGroupSearchResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(searchCloudGroups(searchParam:succ:fail:));

/**
 *  2.4 修改群资料
 */
- (void)setGroupInfo:(V2TIMGroupInfo *)info succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setGroupInfo(info:succ:fail:));

/**
 *  2.5 初始化群属性，会清空原有的群属性列表
 *
 * @note
 * attributes 的使用限制如下：
 *  - 6.7 及其以前版本，只支持 AVChatRoom 直播群；
 *  - 从 6.8 版本开始，同时支持 AVChatRoom、Public、Meeting、Work 四种群类型；
 *  - 从 7.0 版本开始，除了话题外，群属性支持所有的群类型；
 *  - key 最多支持 16 个，长度限制为 32 字节；
 *  - value 长度限制为 4k；
 *  - 总的 attributes（包括 key 和 value）限制为 16k；
 *  - initGroupAttributes、setGroupAttributes、deleteGroupAttributes 接口合并计算， SDK 限制为 5 秒 10 次，超过后回调 8511 错误码；后台限制 1 秒 5 次，超过后返回 10049 错误码；
 *  - getGroupAttributes 接口 SDK 限制 5 秒 20 次；
 *  - 从 5.6 版本开始，当每次APP启动后初次修改群属性时，请您先调用 getGroupAttributes 拉取到最新的群属性之后，再发起修改操作；
 *  - 从 5.6 版本开始，当多个用户同时修改同一个群属性时，只有第一个用户可以执行成功，其它用户会收到 10056 错误码；收到这个错误码之后，请您调用 getGroupAttributes 把本地保存的群属性更新到最新之后，再发起修改操作。
 */
- (void)initGroupAttributes:(NSString*)groupID attributes:(NSDictionary<NSString *,NSString *> *)attributes succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(initGroupAttributes(groupID:attributes:succ:fail:));

/**
 *  2.6 设置群属性，已有该群属性则更新其 value 值，没有该群属性则添加该群属性。
 *  @note
 *   - 6.7 及其以前版本，只支持 AVChatRoom 直播群；
 *   - 从 6.8 版本开始，同时支持 AVChatRoom、Public、Meeting、Work 四种群类型；
 *   - 从 7.0 版本开始，除了话题外，群属性支持所有的群类型。
 */
- (void)setGroupAttributes:(NSString*)groupID attributes:(NSDictionary<NSString *,NSString *> *)attributes succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setGroupAttributes(groupID:attributes:succ:fail:));

/**
 *  2.7 删除群指定属性，keys 传 nil 则清空所有群属性。
 *  @note
 *   - 6.7 及其以前版本，只支持 AVChatRoom 直播群；
 *   - 从 6.8 版本开始，同时支持 AVChatRoom、Public、Meeting、Work 四种群类型；
 *   - 从 7.0 版本开始，除了话题外，群属性支持所有的群类型。
 */
- (void)deleteGroupAttributes:(NSString*)groupID keys:(NSArray<NSString *> * _Nullable)keys succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(deleteGroupAttributes(groupID:keys:succ:fail:));

/**
 *  2.8 获取群指定属性，keys 传 nil 则获取所有群属性。
 *  @note
 *   - 6.7 及其以前版本，只支持 AVChatRoom 直播群；
 *   - 从 6.8 版本开始，同时支持 AVChatRoom、Public、Meeting、Work 四种群类型；
 *   - 从 7.0 版本开始，除了话题外，群属性支持所有的群类型。
 */
- (void)getGroupAttributes:(NSString*)groupID keys:(NSArray<NSString *> * _Nullable)keys succ:(V2TIMGroupAttributeListSucc)succ fail:(V2TIMFail)fail;

/**
 * 2.9 获取指定群在线人数
 *
 * @param groupID 群id
 * @param succ 成功回调
 * @param fail 失败回调
 *
 * @note
 * - IMSDK 7.3 以前的版本仅支持直播群（ AVChatRoom）；
 * - IMSDK 7.3 及其以后的版本支持所有群类型。
 */
- (void)getGroupOnlineMemberCount:(NSString*)groupID succ:(V2TIMGroupOnlineMemberCountSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getGroupOnlineMemberCount(groupID:succ:fail:));

/**
 * 2.10 设置群计数器（7.0 及其以上版本支持）
 *
 * @note
 *  - 该计数器的 key 如果存在，则直接更新计数器的 value 值；如果不存在，则添加该计数器的 key-value；
 *  - 当群计数器设置成功后，在 succ 回调中会返回最终成功设置的群计数器信息；
 *  - 除了社群和话题，群计数器支持所有的群组类型。
 */
- (void)setGroupCounters:(NSString *)groupID counters:(NSDictionary<NSString *, NSNumber *> *)counters succ:(V2TIMGroupCounterResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(setGroupCounters(groupID:counters:succ:fail:));

/**
 * 2.11 获取群计数器（7.0 及其以上版本支持）
 *
 * @note
 *  - 如果 keys 为空，则表示获取群内的所有计数器；
 *  - 除了社群和话题，群计数器支持所有的群组类型。
 */
- (void)getGroupCounters:(NSString *)groupID keys:(NSArray<NSString *> * _Nullable)keys succ:(V2TIMGroupCounterResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getGroupCounters(groupID:keys:succ:fail:));

/**
 * 2.12 递增群计数器（7.0 及其以上版本支持）
 *
 * @param groupID 群 ID
 * @param key 群计数器的 key
 * @param value 群计数器的递增的变化量，计数器 key 对应的 value 变更方式为： new_value = old_value + value
 * @param succ 成功后的回调，会返回当前计数器做完递增操作后的 value
 * @param fail 失败的回调
 *
 * @note
 *  - 该计数器的 key 如果存在，则直接在当前值的基础上根据传入的 value 作递增操作；反之，添加 key，并在默认值为 0 的基础上根据传入的 value 作递增操作；
 *  - 除了社群和话题，群计数器支持所有的群组类型。
 */
- (void)increaseGroupCounter:(NSString *)groupID key:(NSString *)key value:(NSInteger)value succ:(V2TIMGroupCounterResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(increaseGroupCounter(groupID:key:value:succ:fail:));

/**
 * 2.13 递减群计数器（7.0 及其以上版本支持）
 *
 * @param groupID 群 ID
 * @param key 群计数器的 key
 * @param value 群计数器的递减的变化量，计数器 key 对应的 value 变更方式为： new_value = old_value - value
 * @param succ 成功后的回调，会返回当前计数器做完递减操作后的 value
 * @param fail 失败的回调
 *
 * @note
 *  - 该计数器的 key 如果存在，则直接在当前值的基础上根据传入的 value 作递减操作；反之，添加 key，并在默认值为 0 的基础上根据传入的 value 作递减操作
 *  - 除了社群和话题，群计数器支持所有的群组类型。
 */
- (void)decreaseGroupCounter:(NSString *)groupID key:(NSString *)key value:(NSInteger)value succ:(V2TIMGroupCounterResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(decreaseGroupCounter(groupID:key:value:succ:fail:));

/////////////////////////////////////////////////////////////////////////////////
//                         群成员管理
/////////////////////////////////////////////////////////////////////////////////
/**
 *  3.1 获取群成员列表
 *
 *  @param filter   指定群成员类型。
 *  @param nextSeq  分页拉取标志，第一次拉取填 0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为 0。
 *
 *  @note
 *  - 普通群（工作群、会议群、公开群）的限制：
 *  1. filter 只能设置为 V2TIMGroupMemberFilter 定义的数值，SDK 会返回指定角色的成员。
 *
 *  - 直播群（AVChatRoom）的限制：
 *  1. 如果设置 filter 为 V2TIMGroupMemberFilter 定义的数值，SDK 返回全部成员。返回的人数规则为：拉取最近入群群成员最多 1000 人，新进来的成员排在前面，需要升级旗舰版，并且在 [控制台](https://console.cloud.tencent.com/im) 开启“直播群在线成员列表”开关（6.3 及以上版本支持）。
 *  2. 如果设置 filter 为群成员自定义标记，旗舰版支持拉取指定标记的成员列表。标记群成员的设置请参考 markGroupMemberList:memberList:markType:enableMark:succ:fail: API。
 *  3. 程序重启后，请重新加入群组，否则拉取群成员会报 10007 错误码。
 *  4. 群成员资料信息仅支持 userID | nickName | faceURL | role 字段。
 *
 *  - 社群（Community）的限制：
 *  1. 如果设置 filter 为 V2TIMGroupMemberFilter 定义的数值，SDK 返回指定角色的成员。
 *  2. 如果设置 filter 为群成员自定义标记，旗舰版支持拉取指定标记的成员列表(7.5 及以上版本支持）。标记群成员的设置请参考 markGroupMemberList:memberList:markType:enableMark:succ:fail: API。
 */
- (void)getGroupMemberList:(NSString*)groupID filter:(uint32_t)filter nextSeq:(uint64_t)nextSeq succ:(V2TIMGroupMemberInfoResultSucc)succ fail:(V2TIMFail)fail;

/**
 *  3.2 指定的群成员资料
 */
- (void)getGroupMembersInfo:(NSString*)groupID memberList:(NSArray<NSString*>*)memberList succ:(V2TIMGroupMemberInfoListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getGroupMembersInfo(groupID:memberList:succ:fail:));

/**
 *  3.3 搜索本地群成员资料（5.4.666 及以上版本支持）
 *
 * @param searchParam 搜索参数
 * @note 该功能为 IM 旗舰版功能，[购买旗舰版套餐包](https://buy.cloud.tencent.com/avc?from=17474)后可使用，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17176#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)
 */
- (void)searchGroupMembers:(V2TIMGroupMemberSearchParam *)searchParam succ:(V2TIMGroupMemberInfoListSearchSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(searchGroupMembers(searchParam:succ:fail:));

/**
 *  3.4 搜索云端群成员资料（8.4 及以上版本支持）
 *
 * @param searchParam 搜索参数
 * @note 该功能为 IM 增值功能，详见[价格说明](https://cloud.tencent.com/document/product/269/11673?from=17176#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85)
 */
- (void)searchCloudGroupMembers:(V2TIMGroupMemberSearchParam *)searchParam succ:(V2TIMGroupMemberSearchResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(searchCloudGroupMembers(searchParam:succ:fail:));

/**
 *  3.5 修改指定的群成员资料
 */
- (void)setGroupMemberInfo:(NSString*)groupID info:(V2TIMGroupMemberFullInfo *)info succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setGroupMemberInfo(groupID:info:succ:fail:));

/**
 *  3.6 禁言群成员（只有管理员或群主能够调用）
 *
 *  @param seconds 禁言时间长度，单位秒，表示调用该接口成功后多少秒内不允许被禁言用户再发言。
 */
- (void)muteGroupMember:(NSString*)groupID member:(NSString*)userID muteTime:(uint32_t)seconds succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(muteGroupMember(groupID:memberUserID:muteTimeSeconds:succ:fail:));

/**
 *  3.7 禁言全体群成员，只有管理员或群主能够调用（7.5 及以上版本支持）
 *
 * @param groupID 群组 ID
 * @param isMute YES 表示禁言，NO 表示解除禁言
 *
 * @note
 * - 禁言全体群成员没有时间限制，设置 isMute 为 NO 则解除禁言。
 * - 禁言或解除禁言后，会触发 V2TIMGroupListener 中的 onAllGroupMembersMuted:isMute: 回调。
 * - 群主和管理员可以禁言普通成员。普通成员不能操作禁言/解除禁言。
 */
- (void)muteAllGroupMembers:(NSString*)groupID isMute:(BOOL)isMute succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(muteAllGroupMembers(groupID:isMute:succ:fail:));

/**
 *  3.8 邀请他人入群
 *
 *  @note 请注意不同类型的群有如下限制：
 *  - 工作群（Work）：群里的任何人都可以邀请其他人进群。
 *  - 会议群（Meeting）和公开群（Public）：默认不允许邀请加入群，您可以修改群资料 V2TIMGroupInfo 的 groupApproveOpt 字段打开邀请入群方式。打开该选项之后，群里的任何人都可以邀请其他人进群。
 *  - 直播群（AVChatRoom）：不支持此功能。
 *  - 后台限制单次邀请的群成员个数不能超过 20。
 */
- (void)inviteUserToGroup:(NSString*)groupID userList:(NSArray<NSString *>*)userList succ:(V2TIMGroupMemberOperationResultListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(inviteUserToGroup(groupID:userList:succ:fail:));

/**
 *  3.9 踢人
 *
 *  @param groupID 群 id
 *  @param memberList 被踢用户的 userID 列表
 *  @param reason 被踢的原因
 *  @param duration 指定自被踢出群组开始算起，禁止被踢用户重新申请加群的时长，单位：秒
 *  @param succ 成功后的回调
 *  @param fail 失败后的回调
 *
 *  @note
 *  - 从 7.2 版本开始，支持设置一个时长参数，用于指定用户从被踢出群组开始算起，禁止重新申请加群的时长；
 *  - 工作群（Work）：只有群主或 APP 管理员可以踢人；
 *  - 公开群（Public）、会议群（Meeting）：群主、管理员和 APP 管理员可以踢人；
 *  - 直播群（AVChatRoom）：6.6 之前版本只支持禁言（muteGroupMember），不支持踢人。6.6 及以上版本支持禁言和踢人。需要您购买旗舰版套餐；
 *  - 该接口其他使用限制请查阅：https://cloud.tencent.com/document/product/269/75400#.E8.B8.A2.E4.BA.BA。
 */
- (void)kickGroupMember:(NSString *)groupID memberList:(NSArray<NSString *> *)memberList reason:(NSString * _Nullable)reason duration:(uint32_t)duration succ:(V2TIMGroupMemberOperationResultListSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(kickGroupMember(groupID:memberList:reason:duration:succ:fail:));

/**
 *  3.10 切换群成员的角色
 *
 *  @note 请注意不同类型的群有如下限制：
 *  - 工作群（Work）不支持设置群成员角色。
 *  - 只有群主才能对群成员进行普通成员和管理员之间的角色切换。
 *  - 转让群组请调用 @ref transferGroupOwner 接口。
 *  - 会议群（Meeting）切换群成员角色之后，不会有 onGrantAdministrator 和 onRevokeAdministrator 通知回调。
 *  - 切换的角色支持普通群成员（ V2TIM_GROUP_MEMBER_ROLE_MEMBER） 和管理员（V2TIM_GROUP_MEMBER_ROLE_ADMIN)。
 */
- (void)setGroupMemberRole:(NSString*)groupID member:(NSString *)userID newRole:(uint32_t)role succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setGroupMemberRole(groupID:memberUserID:newRole:succ:fail:));

/**
 *  3.11 标记群成员(需要您购买旗舰版套餐)
 *
 *  @param groupID 群 ID。
 *  @param memberList 群成员 ID 列表。
 *  @param markType 标记类型。数字类型，大于等于 1000，您可以自定义，一个群组里最多允许定义 10 个标记。
 *  @param enableMark YES 表示添加标记，NO 表示移除标记。
 *  @note
 *  - 直播群从 6.6 版本开始支持。
 *  - 社群从 7.5 版本开始支持。
 *  - 只有群主才有权限标记群组中其他人。
 */
- (void)markGroupMemberList:(NSString *)groupID memberList:(NSArray<NSString *> *)memberList markType:(uint32_t)markType enableMark:(BOOL)enableMark succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(markGroupMemberList(groupID:memberList:markType:enableMark:succ:fail:));

/**
 *  3.12 转让群主
 *
 *  @note 请注意不同类型的群有如下限制：
 *  - 普通类型的群（Work、Public、Meeting）：只有群主才有权限进行群转让操作。
 *  - 直播群（AVChatRoom）：不支持转让群主。
 */
- (void)transferGroupOwner:(NSString*)groupID member:(NSString*)userID succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(transferGroupOwner(groupID:memberUserID:succ:fail:));

/**
 *  3.13 踢人（直播群踢人从 6.6 版本开始支持，需要您购买旗舰版套餐）
 *
 *  @note 使用限制如下：
 * - 待废弃接口，请使用 kickGroupMember:memberList:reason:duration:succ:fail: 接口；
 * - 工作群（Work）：只有群主或 APP 管理员可以踢人；
 * - 公开群（Public）、会议群（Meeting）：群主、管理员和 APP 管理员可以踢人；
 * - 直播群（AVChatRoom）：6.6 之前版本只支持禁言（muteGroupMember），不支持踢人。6.6 及以上版本支持禁言和踢人；
 * - 该接口其他使用限制请查阅：https://cloud.tencent.com/document/product/269/75400#.E8.B8.A2.E4.BA.BA。
 */
- (void)kickGroupMember:(NSString *)groupID memberList:(NSArray<NSString *> *)memberList reason:(NSString * _Nullable)reason succ:(V2TIMGroupMemberOperationResultListSucc)succ fail:(V2TIMFail)fail __attribute__((deprecated("use kickGroupMember:memberList:reason:succ:fail:")));

/////////////////////////////////////////////////////////////////////////////////
//                         加群申请
/////////////////////////////////////////////////////////////////////////////////

/**
 * 4.1 获取加群申请列表
 * @note 最多支持50个
*/
- (void)getGroupApplicationList:(V2TIMGroupApplicationResultSucc)succ fail:(V2TIMFail)fail NS_SWIFT_NAME(getGroupApplicationList(succ:fail:));

/**
 *  4.2 同意某一条加群申请
 */
- (void)acceptGroupApplication:(V2TIMGroupApplication *)application reason:(NSString* _Nullable)reason succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(acceptGroupApplication(application:reason:succ:fail:));

/**
 *  4.3 拒绝某一条加群申请
 */
- (void)refuseGroupApplication:(V2TIMGroupApplication *)application reason:(NSString* _Nullable)reason succ:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(refuseGroupApplication(application:reason:succ:fail:));

/**
 *  4.4 标记申请列表为已读
 */
- (void)setGroupApplicationRead:(_Nullable V2TIMSucc)succ fail:(_Nullable V2TIMFail)fail NS_SWIFT_NAME(setGroupApplicationRead(succ:fail:));

@end

/////////////////////////////////////////////////////////////////////////////////
//
//             群基本资料（可以通过 getGroupInfo 获取，不支持由客户自行创建）
//
/////////////////////////////////////////////////////////////////////////////////
/// 群资料
V2TIM_EXPORT @interface V2TIMGroupInfo : NSObject

/**
 * 群组 ID
 *
 * @note 自定义群组 ID 必须为可打印 ASCII 字符（0x20-0x7e），最长 48 个字节，且前缀不能为 @TGS#（避免与默认分配的群组 ID 混淆）
 */
@property(nonatomic,strong,nullable) NSString* groupID;

/// 群类型
@property(nonatomic,strong,nullable) NSString* groupType;

/**
 * 社群是否支持创建话题
 * @note 只在群类型为 Community 时有效
 */
@property(nonatomic,assign) BOOL isSupportTopic;

/**
 * 群名称
 *
 * @note 群名称最长 100 字节，使用 UTF-8 编码
 */
@property(nonatomic,strong,nullable) NSString* groupName;

/**
 * 群公告
 *
 * @note 群公告最长 400 字节，使用 UTF-8 编码
 */
@property(nonatomic,strong,nullable) NSString* notification;

/**
 * 群简介
 *
 * @note 群简介最长 400 字节，使用 UTF-8 编码
 */
@property(nonatomic,strong,nullable) NSString* introduction;

/**
 * 群头像
 *
 * @note 群头像 URL 最长 500 字节，使用 UTF-8 编码
 */
@property(nonatomic,strong,nullable) NSString* faceURL;

/// 是否全员禁言
@property(nonatomic,assign) BOOL allMuted;

///设置群自定义字段需要两个步骤：
///1.在 [控制台](https://console.cloud.tencent.com/im) (功能配置 -> 群自定义字段) 配置群自定义字段的 key 值，Key 为 String 类型，长度不超过 16 字节。
///2.调用 setGroupInfo 接口设置该字段，value 为 NSData 数据，长度不超过 512 字节。
///@note 该字段主要用于 V1 和 V2 版本的兼容，如果您直接使用的是 V2 版本的 API ，建议使用 initGroupAttributes 接口设置群属性，其设置更灵活（无需控制台配置），支持的存储也更大（最大支持 16K）
@property(nonatomic,strong) NSDictionary<NSString *,NSData *>* customInfo;

/// 群创建人/管理员
@property(nonatomic,strong,readonly,nullable) NSString *owner;

/// 创建群组的 UTC 时间戳
@property(nonatomic,assign,readonly) uint32_t createTime;

/// 申请进群是否需要管理员审批：工作群（Work）默认值为 V2TIM_GROUP_ADD_FORBID，即默认不允许申请入群，您可以修改该字段打开申请入群方式。
@property(nonatomic,assign) V2TIMGroupAddOpt groupAddOpt;

/// 邀请进群是否需要管理员审批 （从 7.1 版本开始支持）
/// - 除工作群（Work）之外的其他群类型默认值都为 V2TIM_GROUP_ADD_FORBID，即默认不允许邀请入群，您可以修改该字段打开邀请入群方式。
/// - 直播群、社群和话题默认不允许邀请入群，也不支持修改。
@property(nonatomic,assign) V2TIMGroupAddOpt groupApproveOpt;

/// 上次修改群信息的 UTC 时间戳
@property(nonatomic,assign,readonly) uint32_t lastInfoTime;

/// 群最近一次发消息时间
@property(nonatomic,assign,readonly) uint32_t lastMessageTime;

/// 已加入的群成员数量
@property(nonatomic,assign,readonly) uint32_t memberCount;

/// 在线的群成员数量（待废弃字段，请使用 getGroupOnlineMemberCount:succ:fail: 接口获取群在线人数）
@property(nonatomic,assign,readonly) uint32_t onlineCount __attribute__((deprecated("use getGroupOnlineMemberCount:succ:fail: instead")));

/// 最多允许加入的群成员数量
/// @note 各类群成员人数限制详见: https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E9.99.90.E5.88.B6.E5.B7.AE.E5.BC.82
@property(nonatomic,assign,readonly) uint32_t memberMaxCount;

/// 当前用户在此群组中的角色（V2TIMGroupMemberRole），切换角色请调用 setGroupMemberRole 接口
@property(nonatomic,assign,readonly) uint32_t role;

/// 当前用户在此群组中的消息接收选项,修改群消息接收选项请调用 setGroupReceiveMessageOpt 接口
@property(nonatomic,assign,readonly) V2TIMReceiveMessageOpt recvOpt;

/// 当前用户加入此群的 UTC 时间戳，不支持设置，系统自动生成
@property(nonatomic,assign,readonly) uint32_t joinTime;

/// 是否开启权限组能力，仅支持社群，7.8 版本开始支持
/// 开启后，管理员角色的权限失效，用群权限、话题权限和权限组能力来对社群、话题进行管理。
@property(nonatomic,assign) BOOL enablePermissionGroup;

/// 群权限，仅支持社群，7.8 版本开始支持
/// 群成员在没有加入任何权限组时的默认权限，仅在 enablePermissionGroup = true 打开权限组之后生效
@property(nonatomic,assign) uint64_t defaultPermissions;

@end

/// 获取群组资料结果
V2TIM_EXPORT @interface V2TIMGroupInfoResult : NSObject

/// 结果 0：成功；非0：失败
@property(nonatomic,assign) int resultCode;

/// 如果获取失败，会返回错误信息
@property(nonatomic,strong,nullable) NSString *resultMsg;

/// 如果获取成功，会返回对应的 info
@property(nonatomic,strong) V2TIMGroupInfo *info;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//          群申请信息（可以通过 getGroupApplicationList 获取，不支持由客户自行创建）
//
/////////////////////////////////////////////////////////////////////////////////
/// 群申请信息
V2TIM_EXPORT @interface V2TIMGroupApplication : NSObject

/// 群组 ID
@property(nonatomic,strong,readonly,nullable) NSString* groupID;

/// 请求者 userID
@property(nonatomic,strong,readonly,nullable) NSString* fromUser;

/// 请求者昵称
@property(nonatomic,strong,readonly,nullable) NSString* fromUserNickName;

/// 请求者头像
@property(nonatomic,strong,readonly,nullable) NSString* fromUserFaceUrl;

/// 判决者id，有人请求加群:0，邀请其他人加群:被邀请人用户 ID
@property(nonatomic,strong,readonly,nullable) NSString* toUser;

/// 申请时间
@property(nonatomic,assign,readonly) uint64_t addTime;

/// 申请或邀请附加信息
@property(nonatomic,strong,readonly,nullable) NSString* requestMsg;

/// 审批信息：同意或拒绝信息
@property(nonatomic,strong,readonly,nullable) NSString* handledMsg;

/// 请求类型
@property(nonatomic,assign,readonly) V2TIMGroupApplicationType applicationType;

/// 处理标志
@property(nonatomic,assign,readonly) V2TIMGroupApplicationHandleStatus handleStatus;

/// 处理结果
@property(nonatomic,assign,readonly) V2TIMGroupApplicationHandleResult handleResult;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                        邀请其他人入群的操作结果
//
/////////////////////////////////////////////////////////////////////////////////
/// 邀请其他人入群的操作结果
V2TIM_EXPORT @interface V2TIMGroupMemberOperationResult : NSObject

/// 被操作成员
@property(nonatomic,strong,nullable) NSString* userID;

/// 返回状态
@property(nonatomic,assign) V2TIMGroupMemberResult result;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                        创建群时指定群成员
//
/////////////////////////////////////////////////////////////////////////////////
/// 创建群时指定群成员
V2TIM_EXPORT @interface V2TIMCreateGroupMemberInfo : NSObject

/// 被操作成员
@property(nonatomic,strong,nullable) NSString* userID;

/** 群成员类型，需要注意一下事项：
 * 1. role 不设置或则设置为 V2TIM_GROUP_MEMBER_UNDEFINED，进群后默认为群成员。
 * 2. 工作群（Work）不支持设置 role 为管理员。
 * 3. 所有的群都不支持设置 role 为群主。
 */
@property(nonatomic,assign) uint32_t role;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                        加群申请列表（包含已处理和待处理的）
//
/////////////////////////////////////////////////////////////////////////////////
/// 加群申请列表
V2TIM_EXPORT @interface V2TIMGroupApplicationResult : NSObject

/// 未读的申请数量
@property(nonatomic,assign) uint64_t unreadCount;

/// 加群申请的列表
@property(nonatomic,strong) NSMutableArray<V2TIMGroupApplication *> * applicationList;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                        群搜索
//
/////////////////////////////////////////////////////////////////////////////////
V2TIM_EXPORT @interface V2TIMGroupSearchParam : NSObject
/// 搜索关键字列表，最多支持5个。
/// 如果是本地搜索，您需主动设置 keyword 是否匹配群 ID、群名称。
/// 如果是云端搜索，keyword 会自动匹配群 ID、群名称。
@property(nonatomic, strong) NSArray<NSString *> *keywordList;

/// 设置是否搜索群 ID（仅本地搜索有效）
@property(nonatomic, assign) BOOL isSearchGroupID;

/// 设置是否搜索群名称（仅本地搜索有效）
@property(nonatomic, assign) BOOL isSearchGroupName;

/// 指定关键字列表匹配类型，可设置为“或”关系搜索或者“与”关系搜索（仅云端搜索有效）
/// 取值分别为 V2TIM_KEYWORD_LIST_MATCH_TYPE_OR 和 V2TIM_KEYWORD_LIST_MATCH_TYPE_AND，默认为“或”关系搜索。
@property(nonatomic,assign) V2TIMKeywordListMatchType keywordListMatchType;

/// 设置每次云端搜索返回结果的条数（必须大于 0，最大支持 100，默认 20，仅云端搜索有效）
@property(nonatomic,assign) NSUInteger searchCount;

/// 设置每次云端搜索的起始位置。第一次填空字符串，续拉时填写 V2TIMGroupSearchResult 中的返回值（仅云端搜索有效）
@property(nonatomic,strong) NSString *searchCursor;

@end

V2TIM_EXPORT @interface V2TIMGroupSearchResult : NSObject
/// 满足搜索条件的群列表是否已经全部返回
@property(nonatomic,assign) BOOL isFinished;

/// 满足搜索条件的群总数量
@property(nonatomic,assign) NSUInteger totalCount;

/// 下一次云端搜索的起始位置
@property(nonatomic,strong,nullable) NSString *nextCursor;

/// 当前一次云端搜索返回的群列表
@property(nonatomic,strong) NSArray<V2TIMGroupInfo *> *groupList;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                        群成员搜索
//
/////////////////////////////////////////////////////////////////////////////////
V2TIM_EXPORT @interface V2TIMGroupMemberSearchParam : NSObject
/// 搜索关键字列表，最多支持 5 个
/// 如果是本地搜索，您需主动设置 keyword 是否匹配群成员 ID、昵称、备注、群名片。
/// 如果是云端搜索，keyword 会自动匹配群成员 ID、昵称、群名片。
@property(nonatomic, strong) NSArray<NSString *> *keywordList;

/// 指定群 ID 列表，若为 null 则搜索全部群中的群成员
@property(nonatomic, strong,nullable) NSArray<NSString *> *groupIDList;

/// 设置是否搜索群成员 userID（仅本地搜索有效）
@property(nonatomic, assign) BOOL isSearchMemberUserID;

/// 设置是否搜索群成员昵称（仅本地搜索有效）
@property(nonatomic, assign) BOOL isSearchMemberNickName;

/// 设置是否搜索群成员备注（仅本地搜索有效）
@property(nonatomic, assign) BOOL isSearchMemberRemark;

/// 设置是否搜索群成员名片（仅本地搜索有效）
@property(nonatomic, assign) BOOL isSearchMemberNameCard;

/// 指定关键字列表匹配类型，可设置为“或”关系搜索或者“与”关系搜索（仅云端搜索有效）
/// 取值分别为 V2TIM_KEYWORD_LIST_MATCH_TYPE_OR 和 V2TIM_KEYWORD_LIST_MATCH_TYPE_AND，默认为“或”关系搜索。
@property(nonatomic,assign) V2TIMKeywordListMatchType keywordListMatchType;

/// 设置每次云端搜索返回结果的条数（必须大于 0，最大支持 100，默认 20，仅云端搜索有效）
@property(nonatomic,assign) NSUInteger searchCount;

/// 设置每次云端搜索的起始位置。第一次填空字符串，续拉时填写 V2TIMGroupMemberSearchResult 中的返回值（仅云端搜索有效）
@property(nonatomic,strong) NSString *searchCursor;

@end

V2TIM_EXPORT @interface V2TIMGroupMemberSearchResult : NSObject
/// 满足搜索条件的群成员列表是否已经全部返回
@property(nonatomic,assign) BOOL isFinished;

/// 满足搜索条件的群成员总数量
@property(nonatomic,assign) NSUInteger totalCount;

/// 下一次云端搜索的起始位置
@property(nonatomic,strong,nullable) NSString *nextCursor;

/// 当前一次云端搜索返回的群成员列表
@property(nonatomic,strong) NSDictionary<NSString *, NSArray<V2TIMGroupMemberFullInfo *> *> *memberList;

@end
