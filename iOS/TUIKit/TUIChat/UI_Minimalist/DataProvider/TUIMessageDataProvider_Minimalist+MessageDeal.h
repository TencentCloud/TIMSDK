//
//  TUIMessageDataProvider+MessageDeal.h
//  TUIChat
//
//  Created by wyl on 2022/3/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageDataProvider_Minimalist.h"
#import "TUIReplyMessageCellData_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageDataProvider_Minimalist (MessageDeal)
- (void)loadOriginMessageFromReplyData:(TUIReplyMessageCellData_Minimalist *)replycellData dealCallback:(void (^)(void))callback;
@end

NS_ASSUME_NONNULL_END
