//
//  TUITypingStatusCellData.h
//  TUIChat
//
//  Created by wyl on 2022/7/4.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUITypingStatusCellData : TUIMessageCellData

@property(nonatomic, assign) NSInteger typingStatus;

@end

NS_ASSUME_NONNULL_END
