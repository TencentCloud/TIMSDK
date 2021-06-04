/**********
 *
 *  本 DataProvider 的实现仿照 TIMUserProfile 与 TIMMessage 的 DataProvider 结构。
 *  有些函数在编写后发现使用场景不广（如名字、ID 等都可以直接访问），但还是留存了下来，以便以后扩展。
 *  本类实现的目的是提高复用率，使已有的 GroupInfoController 和 GroupMemberController 的共有代码（CanDelete 等函数）集中于此，在修改时也可达到同时修改的目的。
 *  同时为将来 TUIKit 的第三方使用者提供一个较为方便的数据使用方式，省去了很多数据转换的步骤。
 *
 *  在使用时，本类别和 TIMUserProfile 使用方式一样，在拉取了 TIMGroupInfo 后，通过 [myGroupInfo functionName] 即可使用。
 *
 **********/
#import "THeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface V2TIMGroupInfo(DataProvider)

/**
 *  获取本群名称
 */
-(NSString *) showGroupName;

/**
 *  获取本群 ID
 */
-(NSString *) showGroupID;

/**
 *  获取本群所有者（群管理）
 */
-(NSString *) showGroupOwner;

/**
 *  获取本群公告
 */
-(NSString *) showNotification;

/**
 *  获取本群简介
 */
-(NSString *) showIntroduction;

/**
 *  获取本群类型。
 *
 *  @return 根据群组类型，返回“讨论组”/“公开群”/“聊天室”。
*/
-(NSString *) showGroupType;

/**
 *  获取本群成员数
 */
-(uint32_t) showMemberNumber;

/**
 *  获取本群成员上限
 */
-(uint32_t) showMaxMemberNumber;

/**
 *  获取本群加群方式
 *
 *  @return 根据群组设置，返回“禁止加入”/“管理员审批”/“自动审批”。
 */
-(NSString *) showAddOption;

/**
 *  根据传入的 TIMGroupAddOpt，返回“禁止加入”/“管理员审批”/“自动审批”
 *  本函数若无特殊需求，不建议直接调用。
 *  本函数是为了在 pickerView 中返回对应的字符串，若想获取某一 groupInfo 的加群设置时，直接调用上面的 showAddOption 函数即可。
 *  TIMGroupAddOpt 枚举包含的内容：
 *  1、TIM_GROUP_ADD_FORBID 禁止加入
 *  2、TIM_GROUP_ADD_AUTH 需要管理员审批
 *  3、TIM_GROUP_ADD_ANY 任何人可以加入（自动审批）
 *
 *  @param option 加群方式
 */
-(NSString *) showAddOption:(V2TIMGroupAddOpt)option;

/**
 *  判断当前用户在对与当前 TIMGroupInfo 来说是否是管理。
 *
 *  @return YES：是管理；NO：不是管理
 */
-(BOOL) isMeOwner;

/**
 *  判断当前群是否是私有群。
 *
 *  @return YES：是私有群；NO：不是私有群
 */
-(BOOL) isPrivate;


/**
 *  判断当前用户在当前群能否邀请成员。
 *
 *  @return YES：能邀请；NO：不能邀请
 */
-(BOOL) canInviteMember;

/**
 *  判断当前用户在当前群能否踢出群成员。
 *
 *  @return YES：能踢出；NO：不能踢出
 */
-(BOOL) canRemoveMember;

/**
 *  判断当前用户能否删除（解散）当前群组。
 *
 *  @return YES：能删除；NO：不能删除
 */
-(BOOL) canDelete;
//-(TIMGroupSelfInfo *) getSelfInfo;


@end

NS_ASSUME_NONNULL_END
