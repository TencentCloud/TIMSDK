//
//  TUICustomerServicePluginEvaluationCellData.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/5/30.
//

#import <TIMCommon/TUIMessageCell.h>
#import <TIMCommon/TUIMessageCellData.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICustomerServicePluginEvaluationCellData : TUIMessageCellData

@property (nonatomic, copy) NSString *header;
@property (nonatomic, copy) NSString *tail;

@property (nonatomic, assign) NSInteger totalScore;
@property (nonatomic, assign) NSInteger score;

@property (nonatomic, assign) NSInteger type; // 1:star, 2:number
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) NSString *sessionID;
@property (nonatomic, assign) NSTimeInterval expireTime;
@property (nonatomic, assign) BOOL isExpired;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableDictionary *itemDict;

@end

NS_ASSUME_NONNULL_END
