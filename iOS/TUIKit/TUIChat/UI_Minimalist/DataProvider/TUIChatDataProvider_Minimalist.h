
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TIMInputViewMoreActionProtocol.h>
#import "TUIChatBaseDataProvider.h"
#import "TUIChatConversationModel.h"
#import "TUIVideoMessageCellData_Minimalist.h"
@class TUICustomActionSheetItem;

@class TUIChatDataProvider_Minimalist;
NS_ASSUME_NONNULL_BEGIN

@interface TUIChatDataProvider_Minimalist : TUIChatBaseDataProvider

- (NSArray<TUICustomActionSheetItem *> *)getInputMoreActionItemList:(nullable NSString *)userID
                                                            groupID:(nullable NSString *)groupID
                                                             pushVC:(nullable UINavigationController *)pushVC
                                                   actionController:(id<TIMInputViewMoreActionProtocol>)actionController;

@end

NS_ASSUME_NONNULL_END
