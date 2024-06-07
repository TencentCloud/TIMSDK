//
//  TUICallRecordCallsCellViewModel.h
//  TUICallKit
//
//  Created by noah on 2023/2/28.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TUICallRecords;

NS_ASSUME_NONNULL_BEGIN

@interface TUICallRecordCallsCellViewModel : NSObject

/// 图标视图
@property (nonatomic, readonly, strong) UIImage *avatarImage;
/// 图标地址
@property (nonatomic, readonly, copy) NSString *faceURL;
/// 名称
@property (nonatomic, readonly, copy) NSString *titleLabelStr;
/// 通话媒体类型
@property (nonatomic, readonly, copy) NSString *mediaTypeImageStr;
/// 通话结果
@property (nonatomic, readonly, copy) NSString *resultLabelStr;
/// 通话时间
@property (nonatomic, readonly, copy) NSString *timeLabelStr;
/// 通话记录数据
@property (nonatomic, readonly, strong) TUICallRecords *callRecord;


- (instancetype)initWithCallRecord:(TUICallRecords *)callRecord;

@end

NS_ASSUME_NONNULL_END
