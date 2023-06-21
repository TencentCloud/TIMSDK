//
//  TUIMessageDataProvider+MessageDeal.h
//  TUIChat
//
//  Created by wyl on 2022/3/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageDataProvider.h"
#import "TUIReplyMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageDataProvider (MessageDeal)
- (void)loadOriginMessageFromReplyData:(TUIReplyMessageCellData *)replycellData dealCallback:(void (^)(void))callback;
@end

NS_ASSUME_NONNULL_END
