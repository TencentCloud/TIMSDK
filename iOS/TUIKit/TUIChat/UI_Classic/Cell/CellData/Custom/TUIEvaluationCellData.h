//
//  TUIEvaluationCellData.h
//  TUIChat
//
//  Created by xia on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TUIBubbleMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIEvaluationCellData : TUIBubbleMessageCellData

@property(nonatomic, assign) NSInteger score;
@property(nonatomic, copy) NSString *desc;
@property(nonatomic, copy) NSString *comment;

@end

NS_ASSUME_NONNULL_END
