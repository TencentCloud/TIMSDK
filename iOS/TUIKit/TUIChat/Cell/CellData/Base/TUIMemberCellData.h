/******************************************************************************
 *
 *  本文件声明了 TUIMemberCellData 类。
 *  作用是为 TUIMemberCell 类提供数据源，主要应用于消息已读成员列表组件界面等。
 *
 ******************************************************************************/

#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMemberCellData : TUICommonCellData

@property (nonatomic, copy) NSString *title;  // member's display name
@property (nonatomic, copy) NSURL *avatarUrL; // member's avatar image url
@property (nonatomic, copy) NSString *detail; // optional, used to display more info

- (instancetype)initWithUserID:(nonnull NSString *)userID
                      nickName:(nullable NSString *)nickName
                  friendRemark:(nullable NSString *)friendRemark
                      nameCard:(nullable NSString *)nameCard
                     avatarUrl:(nonnull NSString *)avatarUrl
                        detail:(nullable NSString *)detail;

@end

NS_ASSUME_NONNULL_END

