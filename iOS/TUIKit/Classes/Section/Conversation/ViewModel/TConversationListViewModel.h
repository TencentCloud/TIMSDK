//
//  TConversationListViewModel.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/17.
//

#import <Foundation/Foundation.h>
#import "TUIConversationCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^ConversationListFilterBlock)(TUIConversationCellData *data);


@interface TConversationListViewModel : NSObject

/**
 * 会话数据
 */
@property (strong) NSArray<TUIConversationCellData *> *dataList;
/**
 * 过滤器
 */
@property (copy) ConversationListFilterBlock listFilter;

/**
 * 加载会话数据
 */
- (void)loadConversation;

/**
 * 删除会话数据
 */
- (void)removeData:(TUIConversationCellData *)data;

@end

NS_ASSUME_NONNULL_END
