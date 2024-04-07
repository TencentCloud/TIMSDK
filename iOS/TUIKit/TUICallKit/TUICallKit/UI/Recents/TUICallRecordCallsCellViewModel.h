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

@property (nonatomic, readonly, strong) UIImage *avatarImage;
@property (nonatomic, readonly, copy) NSString *faceURL;
@property (nonatomic, readonly, copy) NSString *titleLabelStr;
@property (nonatomic, readonly, copy) NSString *mediaTypeImageStr;
@property (nonatomic, readonly, copy) NSString *resultLabelStr;
@property (nonatomic, readonly, copy) NSString *timeLabelStr;
@property (nonatomic, readonly, strong) TUICallRecords *callRecord;

- (instancetype)initWithCallRecord:(TUICallRecords *)callRecord;

@end

NS_ASSUME_NONNULL_END
