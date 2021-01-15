//
//  TUIGroupLiveMessageCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by coddyliu on 2020/9/14.
//

#import "TUIGroupLiveMessageCell.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "UIColor+TUIDarkMode.h"
#import "THeader.h"
#import "SDWebImage.h"
#import "UIImage+TUIKIT.h"
#import "NSBundle+TUIKIT.h"

@interface TUIGroupLiveMessageCell ()
//@property(nonatomic, strong) UILabel *titleLabel;
//@property(nonatomic, strong) UILabel *statusLabel;
//@property(nonatomic, strong) UIButton *tagButton;
@property(nonatomic, strong) UIView *seprateLine;
@end

@implementation TUIGroupLiveMessageCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.container.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        [self.container addSubview:self.titleLabel];

        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 100, 30)];
        self.statusLabel.numberOfLines = 1;
        self.statusLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.statusLabel.font = [UIFont systemFontOfSize:14];
        self.statusLabel.textColor = [UIColor lightGrayColor];
        [self.container addSubview:self.statusLabel];

        self.seprateLine = [[UIView alloc] initWithFrame:CGRectMake(0, 75, 100, 0.5)];
        self.seprateLine.backgroundColor = [UIColor lightGrayColor];
        self.seprateLine.alpha = 0.5;
        [self.container addSubview:self.seprateLine];
        
        self.roomCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        self.roomCoverImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.container addSubview:self.roomCoverImageView];
        
        self.tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 70, 20)];
        self.tagLabel.numberOfLines = 1;
        self.tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.tagLabel.font = [UIFont systemFontOfSize:13];
        self.tagLabel.textColor = [UIColor lightGrayColor];
        self.tagLabel.text = [@" " stringByAppendingString:TUILocalizableString(TUIKitMoreGroupLive)]; // @" 群直播";
        [self.container addSubview:self.tagLabel];
        
        [self.container.layer setMasksToBounds:YES];
        [self.container.layer setBorderColor:[UIColor d_systemGrayColor].CGColor];
        [self.container.layer setBorderWidth:1];
        [self.container.layer setCornerRadius:5];
    }
    return self;
}

- (void)fillWithData:(TUIGroupLiveMessageCellData *)data
{
    [super fillWithData:data];
    self.customData = data;
    NSString *name = data.anchorName;
    NSString *statusStr = [data.roomInfo[@"roomStatus"] boolValue]?TUILocalizableString(Living):TUILocalizableString(Live-finished);
    if (name.length > 0) {
        self.titleLabel.text = [NSString stringWithFormat:TUILocalizableString(TUIKitWhosLiveFormat), name];
    } else {
        self.titleLabel.text = [NSString stringWithFormat:TUILocalizableString(TUIKitWhosLiveFormat), data.roomInfo[@"anchorId"]];
    }
    self.statusLabel.text = statusStr;
    if ([data.roomInfo[@"roomCover"] length] > 0) {
        NSURL *imageUrl = [NSURL URLWithString:data.roomInfo[@"roomCover"]];
        [self.roomCoverImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage tk_imageNamed:@"thumb_1"]];
    } else {
        [self.roomCoverImageView setImage:[UIImage tk_imageNamed:@"thumb_1"]];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.mm_left(10).mm_top(10).mm_height(20).mm_flexToRight(20);
    self.statusLabel.mm_left(10).mm_top(40).mm_height(20).mm_flexToRight(20);
    self.seprateLine.mm_left(10).mm_top(65).mm_height(0.5).mm_flexToRight(20);
    self.roomCoverImageView.mm_left(10).mm_top(72.5).mm_height(15).mm_width(15);
    self.tagLabel.mm_left(25).mm_top(70);
}

@end
