
#import <Foundation/Foundation.h>
#import "TUIChatBaseDataProvider.h"
#import "TUIVideoMessageCellData.h"
#import "TUIInputMoreCellData.h"
#import "TUIChatConversationModel.h"
#import <TIMCommon/TIMDefine.h>

@class TUIChatDataProvider;
NS_ASSUME_NONNULL_BEGIN

@interface TUIChatDataProvider : TUIChatBaseDataProvider

#pragma mark - CellData
- (NSMutableArray<TUIInputMoreCellData *> *)moreMenuCellDataArray:(NSString *)groupID
                                                           userID:(NSString *)userID
                                                  isNeedVideoCall:(BOOL)isNeedVideoCall
                                                  isNeedAudioCall:(BOOL)isNeedAudioCall
                                                  isNeedGroupLive:(BOOL)isNeedGroupLive
                                                       isNeedLink:(BOOL)isNeedLink;

@end


NS_ASSUME_NONNULL_END
