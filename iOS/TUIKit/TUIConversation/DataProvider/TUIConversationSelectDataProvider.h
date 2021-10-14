//
//  TUIConversationSelectModel.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/6/25.
//

#import <Foundation/Foundation.h>
#import "TUIConversationCellData.h"
#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIConversationSelectDataProvider : NSObject

/**
 * 会话数据
 */
@property (nonatomic, strong) NSArray<TUIConversationCellData *> *dataList;

/**
 * 拉取会话列表
 */
- (void)loadConversations;

/**
 * 根据联系人列表创建会议群组会话
 */
- (void)createMeetingGroupWithContacts:(NSArray<TUICommonContactSelectCellData *>  *)contacts completion:(void(^)(BOOL, TUIConversationCellData *convData))completion;
@end

NS_ASSUME_NONNULL_END
