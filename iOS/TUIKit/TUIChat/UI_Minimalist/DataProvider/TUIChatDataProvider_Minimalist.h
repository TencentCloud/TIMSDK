
#import <Foundation/Foundation.h>
#import "TUIChatBaseDataProvider.h"
#import "TUIVideoMessageCellData_Minimalist.h"
#import "TUIChatConversationModel.h"
#import <TIMCommon/TIMDefine.h>

@class TUICustomActionSheetItem;

@class TUIChatDataProvider_Minimalist;
NS_ASSUME_NONNULL_BEGIN

@interface TUIChatDataProvider_Minimalist : TUIChatBaseDataProvider

- (NSArray<TUICustomActionSheetItem *> *)getInputMoreActionItemList:(nullable NSString *)userID
                                                            groupID:(nullable NSString *)groupID
                                                             pushVC:(nullable UINavigationController *)pushVC;

@end


NS_ASSUME_NONNULL_END
