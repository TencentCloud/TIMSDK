//
//  TUIConversationCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//

#import "TUIConversationCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "TIMUserProfile+DataProvider.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "TUIKit.h"
#import "THeader.h"
#import "ReactiveObjC/ReactiveObjC.h"

@implementation TUIConversationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _headImageView = [[UIImageView alloc] init];
        [self addSubview:_headImageView];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.layer.masksToBounds = YES;
        [self addSubview:_timeLabel];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.layer.masksToBounds = YES;
        [self addSubview:_titleLabel];
        
        _unReadView = [[TUnReadView alloc] init];
        [self addSubview:_unReadView];
        
        _subTitleLabel = [[UILabel alloc] init];
        _subTitleLabel.layer.masksToBounds = YES;
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_subTitleLabel];
        
        [self setSeparatorInset:UIEdgeInsetsMake(0, TConversationCell_Margin, 0, 0)];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    return self;
}
- (void)fillWithData:(TUIConversationCellData *)convData
{
    [super fillWithData:convData];
    self.convData = convData;
    
    self.timeLabel.text = [convData.time tk_messageString];
    self.subTitleLabel.text = convData.subTitle;
    [self.unReadView setNum:convData.unRead];
    
    if (convData.isOnTop) {
        self.backgroundColor = RGB(245, 245, 248);
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    @weakify(self)
    [[[RACObserve(convData, title) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSString *x) {
        @strongify(self)
        self.titleLabel.text = x;
    }];
    [[RACObserve(convData, avatarUrl) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSURL *x) {
        @strongify(self)
        [self.headImageView sd_setImageWithURL:x placeholderImage:self.convData.avatarImage];
    }];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = [self.convData heightOfWidth:self.mm_w];
    self.mm_h = height;
    CGFloat imgHeight = height-2*TConversationCell_Margin;
    
    self.headImageView.mm_width(imgHeight).mm_height(imgHeight).mm_left(TConversationCell_Margin).mm_top(TConversationCell_Margin);
    
    if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRounded) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = imgHeight / 2;
    } else if ([TUIKit sharedInstance].config.avatarType == TAvatarTypeRadiusCorner) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = [TUIKit sharedInstance].config.avatarCornerRadius;
    }
    
    self.timeLabel.mm_sizeToFit().mm_top(TConversationCell_Margin_Text).mm_right(TConversationCell_Margin);
    self.titleLabel.mm_sizeToFitThan(120, 30).mm_top(TConversationCell_Margin_Text).mm_left(self.headImageView.mm_maxX+TConversationCell_Margin);
    self.unReadView.mm_right(TConversationCell_Margin_Text).mm_bottom(TConversationCell_Margin);
    self.subTitleLabel.mm_sizeToFit().mm_left(self.titleLabel.mm_x).mm_bottom(TConversationCell_Margin_Text).mm_flexToRight(self.mm_w-self.unReadView.mm_x);
}



@end
