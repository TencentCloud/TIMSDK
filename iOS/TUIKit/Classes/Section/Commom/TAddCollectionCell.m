//
//  TAddCollectionCell.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/16.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TAddCollectionCell.h"
#import "THeader.h"

@implementation TAddCollectionCell

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
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:_headImageView];
}

- (void)setImage:(NSString *)image
{
    _headImageView.image = [UIImage imageNamed:image];
}

+ (CGSize)getSize
{
    return TAddCollectionCell_Size;
}
@end
