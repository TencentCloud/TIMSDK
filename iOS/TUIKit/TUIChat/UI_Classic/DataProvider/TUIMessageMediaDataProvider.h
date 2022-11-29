
#import "TUIMessageBaseMediaDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageMediaDataProvider : TUIMessageBaseMediaDataProvider
+ (TUIMessageCellData *)getMediaCellData:(V2TIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
