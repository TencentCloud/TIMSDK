//
//  TAddCell.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TAddCell.h"
#import "THeader.h"

@implementation TAddCellData
@end

@implementation TAddCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews{

    [self setSeparatorInset:UIEdgeInsetsMake(0, TAddCell_Margin, 0, 0)];

    CGSize selectSize = TAddCell_Select_Size;
    _selectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(TAddCell_Margin, (TAddCell_Height - selectSize.height) * 0.5, selectSize.width, selectSize.height)];
    _selectImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_selectImageView];

    CGSize headSize = TAddCell_Head_Size;
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_selectImageView.frame.origin.x + _selectImageView.frame.size.width + 2 * TAddCell_Margin, (TAddCell_Height - headSize.height) * 0.5, headSize.width, headSize.height)];
    _headImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_headImageView];

    CGFloat width = self.frame.size.width - _headImageView.frame.size.width - _headImageView.frame.origin.x - 2 * TAddCell_Margin;
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.frame.origin.x + _headImageView.frame.size.width + TAddCell_Margin, 0, width, TAddCell_Height)];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    _nameLabel.textColor = [UIColor blackColor];
    [self addSubview:_nameLabel];
}

+ (CGFloat)getHeight
{
    return TAddCell_Height;
}

- (void)setData:(TAddCellData *)data
{
    _headImageView.image = [UIImage imageNamed:data.head];
    _nameLabel.text = data.name;
    if(data.state == TAddCell_State_Selected){
        _selectImageView.image = [UIImage imageNamed:TUIKitResource(@"add_selected")];
    }
    else if(data.state == TAddCell_State_UnSelect){
        _selectImageView.image = [UIImage imageNamed:TUIKitResource(@"add_unselect")];
    }
    else if(data.state == TAddCell_State_Solid){
        _selectImageView.image = [UIImage imageNamed:TUIKitResource(@"add_solid")];
    }
}
@end
