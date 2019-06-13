//
//  TUIGroupConversationListModel.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/11.
//

#import <Foundation/Foundation.h>
#import "TUIConversationCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupConversationListViewModel : NSObject

@property (readonly) NSDictionary<NSString *, NSArray<TUIConversationCellData *> *> *dataDict;
@property (readonly) NSArray *groupList;

@property (readonly) BOOL isLoadFinished;
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
