
#import "TUIMessageDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageMediaDataProvider : TUIMessageDataProvider
@property (nonatomic, strong) NSMutableArray *medias;
/// 初始化 DataProvider
- (instancetype)initWithConversationModel:(nullable TUIChatConversationModel *)conversationModel;
/// 根据当前消息拉取前后各 20 条视频（图片）消息
- (void)loadMediaWithMessage:(V2TIMMessage *)curMessage;
/// 拉取更老的 20 条视频（图片）消息
- (void)loadOlderMedia;
/// 拉取更新的 20 条视频（图片）消息
- (void)loadNewerMedia;
/// 清除缓存
- (void)removeCache;
/// 根据消息获取可展示的 cellData 数据
+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
