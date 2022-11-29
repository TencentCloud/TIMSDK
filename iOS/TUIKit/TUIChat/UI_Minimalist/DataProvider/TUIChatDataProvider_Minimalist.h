
#import <Foundation/Foundation.h>
#import "TUIChatBaseDataProvider.h"
#import "TUIVideoMessageCellData_Minimalist.h"
#import "TUIInputMoreCellData_Minimalist.h"
#import "TUIChatConversationModel.h"
#import "TUIDefine.h"

@class TUIChatDataProvider_Minimalist;
NS_ASSUME_NONNULL_BEGIN

@interface TUIChatDataProvider_Minimalist : TUIChatBaseDataProvider

#pragma mark - CellData
+ (NSMutableArray<TUIInputMoreCellData_Minimalist *> *)moreMenuCellDataArray:(NSString *)groupID
                                                                      userID:(NSString *)userID
                                                             isNeedVideoCall:(BOOL)isNeedVideoCall
                                                             isNeedAudioCall:(BOOL)isNeedAudioCall
                                                             isNeedGroupLive:(BOOL)isNeedGroupLive
                                                                  isNeedLink:(BOOL)isNeedLink;

@end


NS_ASSUME_NONNULL_END
