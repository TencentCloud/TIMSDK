//
//  TUIChatbotMessageCellData.h
//  TUIChat
//
//  Created by Yiliang Wang on 2025/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITextMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatbotMessageCellData : TUITextMessageCellData
@property(nonatomic, strong) dispatch_source_t timer;
@property(nonatomic, strong) UIFont *contentFont;
@property(nonatomic, strong) NSAttributedString *contentString;
@property(nonatomic, assign) NSInteger displayedContentLength;
@property(nonatomic, assign) BOOL isFinished;
@property(nonatomic, assign) long src;
@end
NS_ASSUME_NONNULL_END
