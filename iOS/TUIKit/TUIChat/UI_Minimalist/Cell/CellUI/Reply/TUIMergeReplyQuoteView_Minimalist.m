//
//  TUIMergeReplyQuoteView_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIMergeReplyQuoteView_Minimalist.h"
#import "TUIMergeReplyQuoteViewData_Minimalist.h"
#import <TUICore/TUIDarkModel.h>
#import <TUICore/UIView+TUILayout.h>

@implementation TUIMergeReplyQuoteView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"title";
        _titleLabel.font = [UIFont systemFontOfSize:10.0];
        _titleLabel.textColor = [UIColor d_systemGrayColor];
        _titleLabel.numberOfLines = 1;
        
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.text = @"1\n2";
        _subTitleLabel.font = [UIFont systemFontOfSize:10.0];
        _subTitleLabel.textColor = [UIColor d_systemGrayColor];
        _subTitleLabel.numberOfLines = 2;
        
        [self addSubview:_titleLabel];
        [self addSubview:_subTitleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.mm_x = 0;
    self.titleLabel.mm_y = 0;
    self.titleLabel.mm_sizeToFit();
    self.titleLabel.mm_w = self.mm_w - self.titleLabel.mm_x;
    
    self.subTitleLabel.mm_x = self.titleLabel.mm_x;
    self.subTitleLabel.mm_y = CGRectGetMaxY(self.titleLabel.frame) + 3;
    self.subTitleLabel.mm_flexToRight(8).mm_sizeToFit();
}

- (void)fillWithData:(TUIReplyQuoteViewData_Minimalist *)data
{
    [super fillWithData:data];
    
    if (![data isKindOfClass:TUIMergeReplyQuoteViewData_Minimalist.class]) {
        return;
    }
    
    TUIMergeReplyQuoteViewData_Minimalist *myData = (TUIMergeReplyQuoteViewData_Minimalist *)data;
    self.titleLabel.text = myData.title;
    self.subTitleLabel.text = myData.abstract;
}

- (void)reset
{
    [super reset];
    self.titleLabel.text = @"";
    self.subTitleLabel.text = @"";
}

@end
