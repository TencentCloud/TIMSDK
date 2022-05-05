/******************************************************************************
 *
 *  本文件声明了 TUIMemberCellData 类。
 *  作用是为 TUIMemberCell 类提供数据源，主要应用于消息已读成员列表组件界面等。
 *
 ******************************************************************************/

#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@class V2TIMGroupMemberInfo;
@interface TUIMemberCellData : TUICommonCellData

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *avatarURL;
@property (nonatomic, strong) V2TIMGroupMemberInfo *member;

- (instancetype)initWithMember:(V2TIMGroupMemberInfo *)member;

@end

NS_ASSUME_NONNULL_END

