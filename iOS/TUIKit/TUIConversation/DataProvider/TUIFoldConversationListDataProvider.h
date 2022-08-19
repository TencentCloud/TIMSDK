//
//  TUIFoldConversationListDataProvider.h
//  TUIConversation
//
//  Created by wyl on 2022/7/21.
//

#import "TUIConversationListDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIFoldConversationListDataProvider : TUIConversationListDataProvider

@property (nonatomic, strong) NSMutableArray *needRemoveConversationList;

@end

NS_ASSUME_NONNULL_END
