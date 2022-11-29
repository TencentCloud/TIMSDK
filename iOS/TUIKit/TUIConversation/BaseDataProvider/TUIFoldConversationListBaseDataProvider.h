//
//  TUIFoldConversationListBaseDataProvider.h
//  TUIConversation
//
//  Created by wyl on 2022/7/21.
//

#import "TUIConversationListBaseDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIFoldConversationListBaseDataProvider : TUIConversationListBaseDataProvider

@property (nonatomic, strong) NSMutableArray *needRemoveConversationList;

@end

NS_ASSUME_NONNULL_END
