//
//  TUICallRecordCallsViewModel.h
//  TUICallKit
//
//  Created by noah on 2023/2/28.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 通话结果
typedef NS_ENUM(NSUInteger, TUICallRecordCallsType) {
    TUICallRecordCallsTypeAll,
    TUICallRecordCallsTypeMissed,
};

/// UI 风格类型
typedef NS_ENUM(NSUInteger, TUICallKitRecordCallsUIStyle) {
    TUICallKitRecordCallsUIStyleClassic, // 经典风格
    TUICallKitRecordCallsUIStyleMinimalist, // 简约风格
};

@class TUICallRecordCallsCellViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUICallRecordCallsViewModel : NSObject

@property (nonatomic, readonly, strong) NSMutableArray<TUICallRecordCallsCellViewModel *> *dataSource;

@property (nonatomic, assign) TUICallKitRecordCallsUIStyle recordCallsUIStyle;

- (void)repeatCall:(NSIndexPath *)indexPath;

- (void)jumpUserInfoController:(NSIndexPath *)indexPath navigationController:(UINavigationController *)nav;

- (void)queryRecentCalls;

- (void)switchRecordCallsType:(TUICallRecordCallsType)recordCallsType;

- (void)deleteRecordCall:(NSIndexPath *)indexPath;

- (void)clearAllRecordCalls;

@end

NS_ASSUME_NONNULL_END
