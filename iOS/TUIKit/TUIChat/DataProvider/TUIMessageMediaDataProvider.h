
#import "TUIMessageDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageMediaDataProvider : TUIMessageDataProvider
@property (nonatomic, strong) NSMutableArray *medias;

- (instancetype)initWithConversationModel:(nullable TUIChatConversationModel *)conversationModel;

/**
 * 根据当前消息拉取前后各 20 条视频（图片）消息
 * Pull 20 video (picture) messages before and after the current message
 */
- (void)loadMediaWithMessage:(V2TIMMessage *)curMessage;

/**
 * 拉取更老的 20 条视频（图片）消息
 * Pull older 20 video (image) messages
 */
- (void)loadOlderMedia;

/**
 * 拉取更新的 20 条视频（图片）消息
 * Pull the last 20 video (image) messages
 */
- (void)loadNewerMedia;


- (void)removeCache;


+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
