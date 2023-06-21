
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUIMessageBaseMediaDataProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageMediaDataProvider : TUIMessageBaseMediaDataProvider
+ (TUIMessageCellData *)getMediaCellData:(V2TIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
