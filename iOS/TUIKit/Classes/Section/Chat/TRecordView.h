//
//  TRecordView.h
//  UIKit
//
//  Created by kennethmiao on 2018/10/9.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RecordStatus) {
    Record_Status_TooShort,
    Record_Status_TooLong,
    Record_Status_Recording,
    Record_Status_Cancel,
};
@interface TRecordView : UIView
@property (nonatomic, strong) UIImageView *recordImage;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *background;
- (void)setPower:(NSInteger)power;
- (void)setStatus:(RecordStatus)status;
@end
