//
//  TMoreCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIInputMoreCell.h"
#import <TIMCommon/TIMDefine.h>

@implementation TUIInputMoreCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];

    _title = [[UILabel alloc] init];
    [_title setFont:[UIFont systemFontOfSize:10]];
    [_title setTextColor:[UIColor grayColor]];
    _title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_title];
}

- (void)fillWithData:(TUIInputMoreCellData *)data {
    // set data
    _data = data;
    self.hidden = (data == nil) ? YES : NO;
    _image.image = data.image;
    [_title setText:data.title];
    // update layout
    CGSize menuSize = TMoreCell_Image_Size;
    _image.frame = CGRectMake(0, 0, menuSize.width, menuSize.height);
    _title.frame = CGRectMake(0, _image.frame.origin.y + _image.frame.size.height, _image.frame.size.width + 10, TMoreCell_Title_Height);
    _title.center = CGPointMake(_image.center.x, _title.center.y);
}

+ (CGSize)getSize {
    CGSize menuSize = TMoreCell_Image_Size;
    return CGSizeMake(menuSize.width, menuSize.height + TMoreCell_Title_Height);
}
@end

@interface IUChatView : UIView
@property(nonatomic, strong) UIView *view;
@end

@implementation IUChatView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self addSubview:self.view];
    }
    return self;
}
@end
