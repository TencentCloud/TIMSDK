//
//  TRecordView.m
//  UIKit
//
//  Created by kennethmiao on 2018/10/9.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIRecordView.h"
#import <TIMCommon/TIMDefine.h>

@implementation TUIRecordView
- (id)init {
    self = [super init];
    if (self) {
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];

    _background = [[UIView alloc] init];
    _background.backgroundColor = Record_Background_Color;
    _background.layer.cornerRadius = 5;
    [_background.layer setMasksToBounds:YES];
    [self addSubview:_background];

    _recordImage = [[UIImageView alloc] init];
    _recordImage.image = [UIImage imageNamed:TUIChatImagePath(@"record_1")];
    _recordImage.alpha = 0.8;
    _recordImage.contentMode = UIViewContentModeCenter;
    [_background addSubview:_recordImage];

    _title = [[UILabel alloc] init];
    _title.font = [UIFont systemFontOfSize:14];
    _title.textColor = [UIColor whiteColor];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.layer.cornerRadius = 5;
    [_title.layer setMasksToBounds:YES];
    [_background addSubview:_title];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.layer.cornerRadius = 5;
    _timeLabel.text = @"60\"";
    [_background addSubview:_timeLabel];
}

- (void)defaultLayout {
    CGSize backSize = CGSizeMake(150, 150);
    _title.text = TIMCommonLocalizableString(TUIKitInputRecordSlideToCancel);
    CGSize titleSize = [_title sizeThatFits:CGSizeMake(Screen_Width, Screen_Height)];
    CGSize timeSize = CGSizeMake(100, 15);
    if (titleSize.width > backSize.width) {
        backSize.width = titleSize.width + 2 * Record_Margin;
    }
    CGFloat imageHeight = backSize.height - titleSize.height - 2 * Record_Margin;

    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.top.mas_equalTo(self.background).mas_offset(10);
      make.width.mas_equalTo(100);
      make.height.mas_equalTo(10);
      make.centerX.mas_equalTo(self.background);
    }];
    [self.recordImage mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(-13);
      make.centerX.mas_equalTo(self.background);
      make.width.mas_equalTo(backSize.width);
      make.height.mas_equalTo(imageHeight);
    }];
    [self.title mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.centerX.mas_equalTo(self.background);
      make.top.mas_equalTo(self.recordImage.mas_bottom);
      make.width.mas_equalTo(backSize.width);
      make.height.mas_equalTo(15);
    }];
    [self.background mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.top.mas_equalTo(self.timeLabel.mas_top).mas_offset(-3);
      make.bottom.mas_equalTo(self.title.mas_bottom).mas_offset(3);
      make.center.mas_equalTo(self);
      make.width.mas_equalTo(backSize.width);
    }];
}

- (void)setStatus:(RecordStatus)status {
    switch (status) {
        case Record_Status_Recording: {
            _title.text = TIMCommonLocalizableString(TUIKitInputRecordSlideToCancel);
            _title.backgroundColor = [UIColor clearColor];
            break;
        }
        case Record_Status_Cancel: {
            _title.text = TIMCommonLocalizableString(TUIKitInputRecordReleaseToCancel);
            _title.backgroundColor = [UIColor clearColor];
            break;
        }
        case Record_Status_TooShort: {
            _title.text = TIMCommonLocalizableString(TUIKitInputRecordTimeshort);
            _title.backgroundColor = [UIColor clearColor];
            break;
        }
        case Record_Status_TooLong: {
            _title.text = TIMCommonLocalizableString(TUIKitInputRecordTimeLong);
            _title.backgroundColor = [UIColor clearColor];
            break;
        }
        default:
            break;
    }
}

- (void)setPower:(NSInteger)power {
    NSString *imageName = [self getRecordImage:power];
    _recordImage.image = [UIImage imageNamed:TUIChatImagePath(imageName)];
}

- (NSString *)getRecordImage:(NSInteger)power {
    power = power + 60;
    int index = 0;
    if (power < 25) {
        index = 1;
    } else {
        index = ceil((power - 25) / 5.0) + 1;
    }
    index = MIN(index, 8);
    return [NSString stringWithFormat:@"record_%d", index];
}

@end
