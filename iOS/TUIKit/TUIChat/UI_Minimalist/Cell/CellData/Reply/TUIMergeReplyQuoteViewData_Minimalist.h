//
//  TUIMergeReplyQuoteViewData_Minimalist.h
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReplyMessageCellData_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMergeReplyQuoteViewData_Minimalist : TUIReplyQuoteViewData_Minimalist

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *abstract;

@end

NS_ASSUME_NONNULL_END
