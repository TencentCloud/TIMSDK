//
//  TRecordView.m
//  UIKit
//
//  Created by kennethmiao on 2018/10/9.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIRecordView.h"
#import "THeader.h"
#import "NSBundle+TUIKIT.h"

@implementation TUIRecordView
- (id)init
{
    self = [super init];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor clearColor];

    _background = [[UIView alloc] init];
    _background.backgroundColor = Record_Background_Color;
    _background.layer.cornerRadius = 5;
    [_background.layer setMasksToBounds:YES];
    [self addSubview:_background];

    _recordImage = [[UIImageView alloc] init];
    _recordImage.image = [UIImage imageNamed:TUIKitResource(@"record_1")];
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
}

- (void)defaultLayout
{
    CGSize backSize = Record_Background_Size;
    _title.text = TUILocalizableString(TUIKitInputRecordSlideToCancel);
    CGSize titleSize = [_title sizeThatFits:CGSizeMake(Screen_Width, Screen_Height)];
    if(titleSize.width > backSize.width){
        backSize.width = titleSize.width + 2 * Record_Margin;
    }

    _background.frame = CGRectMake((Screen_Width - backSize.width) * 0.5, (Screen_Height - backSize.height) * 0.5, backSize.width, backSize.height);
    CGFloat imageHeight = backSize.height - titleSize.height - 2 * Record_Margin;
    _recordImage.frame = CGRectMake(0, 0, backSize.width, imageHeight);
    CGFloat titley = _recordImage.frame.origin.y + imageHeight;
    _title.frame = CGRectMake(0, titley, backSize.width, backSize.height - titley);
}

- (void)setStatus:(RecordStatus)status
{
    switch (status) {
        case Record_Status_Recording:
        {
            _title.text = TUILocalizableString(TUIKitInputRecordSlideToCancel);
            _title.backgroundColor = [UIColor clearColor];
            break;
        }
        case Record_Status_Cancel:
        {
            _title.text = TUILocalizableString(TUIKitInputRecordReleaseToCancel);
            _title.backgroundColor = Record_Title_Background_Color;
            break;
        }
        case Record_Status_TooShort:
        {
            _title.text = TUILocalizableString(TUIKitInputRecordTimeshort);
            _title.backgroundColor = [UIColor clearColor];
            break;
        }
        case Record_Status_TooLong:
        {
            _title.text = TUILocalizableString(TUIKitInputRecordTimeLong);
            _title.backgroundColor = [UIColor clearColor];
            break;
        }
        default:
            break;
    }
}

- (void)setPower:(NSInteger)power
{
    NSString *imageName = [self getRecordImage:power];
    _recordImage.image = [UIImage imageNamed:TUIKitResource(imageName)];
}

- (NSString *)getRecordImage:(NSInteger)power
{
    // 关键代码
    power = power + 60;
    int index = 0;
    if (power < 25){
        index = 1;
    } else{
        index = ceil((power - 25) / 5.0) + 1;
    }

    return [NSString stringWithFormat:@"record_%d", index];
}




@end
