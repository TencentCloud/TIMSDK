//
//  TMoreCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/22.
//

#import "TUIInputMoreCell.h"
#import "TUIDefine.h"

@implementation TUIInputMoreCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    _image = [[UIImageView alloc] init];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_image];

    _title = [[UILabel alloc] init];
    [_title setFont:[UIFont systemFontOfSize:14]];
    [_title setTextColor:[UIColor grayColor]];
    _title.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_title];
}

- (void)fillWithData:(TUIInputMoreCellData *)data
{
    //set data
    _data = data;
    _image.image = data.image;
    [_title setText:data.title];
    //update layout
    CGSize menuSize = TMoreCell_Image_Size;
    _image.frame = CGRectMake(0, 0, menuSize.width, menuSize.height);
    _title.frame = CGRectMake(0, _image.frame.origin.y + _image.frame.size.height, _image.frame.size.width + 10, TMoreCell_Title_Height);
    _title.center = CGPointMake(_image.center.x, _title.center.y);
    if (data.extentionView) {
        [self addSubview:data.extentionView];
    }
}

+ (CGSize)getSize
{
    CGSize menuSize = TMoreCell_Image_Size;
    return CGSizeMake(menuSize.width, menuSize.height + TMoreCell_Title_Height);
}
@end
