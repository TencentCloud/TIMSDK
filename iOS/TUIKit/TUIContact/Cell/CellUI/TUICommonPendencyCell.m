//
//  TCommonPendencyCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TUICommonPendencyCell.h"
#import "TUIDefine.h"
#import "TUIThemeManager.h"

@implementation TUICommonPendencyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
        [self.contentView addSubview:self.avatarView];
        self.avatarView.mm_width(70).mm_height(70).mm__centerY(43).mm_left(12);
        if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRounded) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = self.avatarView.frame.size.height / 2;
        } else if ([TUIConfig defaultConfig].avatarType == TAvatarTypeRadiusCorner) {
            self.avatarView.layer.masksToBounds = YES;
            self.avatarView.layer.cornerRadius = [TUIConfig defaultConfig].avatarCornerRadius;
        }
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = TUICoreDynamicColor(@"form_title_color", @"#000000");
        self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_top(14).mm_height(20).mm_width(120);
        
        self.addSourceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.addSourceLabel];
        self.addSourceLabel.textColor = [UIColor d_systemGrayColor];
        self.addSourceLabel.font = [UIFont systemFontOfSize:15];
        self.addSourceLabel.mm_left(self.titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY+6).mm_height(15).mm_width(120);
        
        self.addWordingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.addWordingLabel];
        self.addWordingLabel.textColor = [UIColor d_systemGrayColor];
        self.addWordingLabel.font = [UIFont systemFontOfSize:15];
        self.addWordingLabel.mm_left(self.addSourceLabel.mm_x).mm_top(self.addSourceLabel.mm_maxY+6).mm_height(15).mm_width(120);
        
        self.agreeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.agreeButton setTitleColor:TUICoreDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
        [self.agreeButton addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];
        
        self.rejectButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.rejectButton setTitleColor:TUICoreDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
        [self.rejectButton addTarget:self action:@selector(rejectClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIStackView *stackView = [[UIStackView alloc] init];
        [stackView addSubview:self.agreeButton];
        [stackView addSubview:self.rejectButton];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.alignment = UIStackViewAlignmentCenter;
        [stackView sizeToFit];
        self.stackView = stackView;
        self.accessoryView = stackView;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillWithData:(TUICommonPendencyCellData *)pendencyData {
    [super fillWithData:pendencyData];

    self.pendencyData = pendencyData;
    self.titleLabel.text = pendencyData.title;
    self.addSourceLabel.text = pendencyData.addSource;
    self.addWordingLabel.text = pendencyData.addWording;
    self.avatarView.image = DefaultAvatarImage;
    if (pendencyData.avatarUrl) {
         [self.avatarView sd_setImageWithURL:pendencyData.avatarUrl];
    }
    if (pendencyData.isAccepted) {
        [self.agreeButton setTitle:TUIKitLocalizableString(Agreed) forState:UIControlStateNormal];
        self.agreeButton.enabled = NO;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        [self.agreeButton setTitleColor:TUICoreDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
        self.agreeButton.backgroundColor = TUICoreDynamicColor(@"form_bg_color", @"#FFFFFF");
    } else {
        [self.agreeButton setTitle:TUIKitLocalizableString(Agree) forState:UIControlStateNormal];
        self.agreeButton.enabled = YES;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.agreeButton.layer.borderWidth = 1;
        [self.agreeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        self.agreeButton.backgroundColor = TUICoreDynamicColor(@"primary_theme_color", @"#147AFF");
    }
    
    if (pendencyData.isRejected) {
        [self.rejectButton setTitle:TUIKitLocalizableString(Disclined) forState:UIControlStateNormal];
        self.rejectButton.enabled = NO;
        self.rejectButton.layer.borderColor = [UIColor clearColor].CGColor;
        [self.rejectButton setTitleColor:TUICoreDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
    } else {
        [self.rejectButton setTitle:TUIKitLocalizableString(Discline) forState:UIControlStateNormal];
        self.rejectButton.enabled = YES;
        self.rejectButton.layer.borderColor = TUIDemoDynamicColor(@"separator_color", @"#DBDBDB").CGColor;
        self.rejectButton.layer.borderWidth = 0.2;
        [self.rejectButton setTitleColor:TUICoreDynamicColor(@"primary_theme_color", @"#147AFF") forState:UIControlStateNormal];
    }
    
    self.agreeButton.mm_sizeToFit().mm_width(self.agreeButton.mm_w+20);
    self.rejectButton.mm_left(CGRectGetMaxX(self.agreeButton.frame) + 10).mm_sizeToFit().mm_width(self.rejectButton.mm_w+20);
    self.stackView.bounds = CGRectMake(0, 0, 2 * self.agreeButton.mm_w + 10, self.agreeButton.mm_h);
    
    
    if (self.pendencyData.isRejected && !self.pendencyData.isAccepted) {
        self.agreeButton.hidden = YES;
        self.rejectButton.hidden = NO;
    } else if (self.pendencyData.isAccepted && !self.pendencyData.isRejected) {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = YES;
    } else {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = NO;
    }
    
    self.addSourceLabel.hidden = self.pendencyData.hideSource;
}

- (void)agreeClick {
    if (self.pendencyData.cbuttonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.pendencyData.cbuttonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.pendencyData.cbuttonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }

}

- (void)rejectClick {
    if (self.pendencyData.cRejectButtonSelector) {
        UIViewController *vc = self.mm_viewController;
        if ([vc respondsToSelector:self.pendencyData.cRejectButtonSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [vc performSelector:self.pendencyData.cRejectButtonSelector withObject:self];
#pragma clang diagnostic pop
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ((touch.view == self.agreeButton)) {
        return NO;
    } else if (touch.view == self.rejectButton) {
        return NO;
    }
    return YES;
}
@end
