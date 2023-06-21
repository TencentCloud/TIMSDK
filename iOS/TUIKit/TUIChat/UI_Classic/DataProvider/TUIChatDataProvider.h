
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TIMInputViewMoreActionProtocol.h>
#import "TUIChatBaseDataProvider.h"
#import "TUIChatConversationModel.h"
#import "TUIInputMoreCellData.h"
#import "TUIVideoMessageCellData.h"

@class TUIChatDataProvider;
NS_ASSUME_NONNULL_BEGIN

@interface TUIChatDataProvider : TUIChatBaseDataProvider

#pragma mark - CellData
- (NSMutableArray<TUIInputMoreCellData *> *)moreMenuCellDataArray:(NSString *)groupID
                                                           userID:(NSString *)userID
                                                 actionController:(id<TIMInputViewMoreActionProtocol>)actionController;

@end

NS_ASSUME_NONNULL_END
