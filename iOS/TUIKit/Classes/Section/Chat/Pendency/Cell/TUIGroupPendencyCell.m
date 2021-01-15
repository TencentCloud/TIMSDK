//
//  TUIGroupPendencyCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/18.
//

#import "TUIGroupPendencyCell.h"
#import "MMLayout/UIView+MMLayout.h"
#import "THeader.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "MMLayout/UIView+MMLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "NSBundle+TUIKIT.h"

@implementation TUIGroupPendencyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    self.avatarView = [[UIImageView alloc] initWithImage:DefaultAvatarImage];
    [self.contentView addSubview:self.avatarView];
    self.avatarView.mm_width(54).mm_height(54).mm__centerY(38).mm_left(12);

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.titleLabel];
    self.titleLabel.textColor = [UIColor darkTextColor];
    self.titleLabel.mm_left(self.avatarView.mm_maxX+12).mm_top(14).mm_height(20).mm_width(120);

    self.addWordingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.addWordingLabel];
    self.addWordingLabel.textColor = [UIColor lightGrayColor];
    self.addWordingLabel.font = [UIFont systemFontOfSize:15];
    self.addWordingLabel.mm_left(self.titleLabel.mm_x).mm_top(self.titleLabel.mm_maxY+6).mm_height(15).mm_width(self.mm_w - self.titleLabel.mm_x - 80);

    self.agreeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.accessoryView = self.agreeButton;
    [self.agreeButton addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];

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

- (void)fillWithData:(TUIGroupPendencyCellData *)pendencyData
{
    [super fillWithData:pendencyData];

    self.pendencyData = pendencyData;
    self.titleLabel.text = pendencyData.title;
    self.addWordingLabel.text = pendencyData.requestMsg;
    self.avatarView.image = DefaultAvatarImage;
    if (pendencyData.avatarUrl) {
        [self.avatarView sd_setImageWithURL:pendencyData.avatarUrl placeholderImage:[UIImage imageNamed:TUIKitResource(@"default_c2c_head")]];
    }

    @weakify(self)
    [[RACObserve(pendencyData, isAccepted) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *isAccepted) {
        @strongify(self)
        if ([isAccepted boolValue]) {
            [self.agreeButton setTitle:TUILocalizableString(Agreed) forState:UIControlStateNormal];
            self.agreeButton.enabled = NO;
            [self.agreeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }];
    [[RACObserve(pendencyData, isRejectd) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *isAccepted) {
        @strongify(self)
        if ([isAccepted boolValue]) {
            [self.agreeButton setTitle:TUILocalizableString(Disclined) forState:UIControlStateNormal];
            self.agreeButton.enabled = NO;
            [self.agreeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }];

    if (!(pendencyData.isAccepted || pendencyData.isRejectd)) {
        [self.agreeButton setTitle:TUILocalizableString(Agree) forState:UIControlStateNormal];
        self.agreeButton.enabled = YES;
        [self.agreeButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        self.agreeButton.layer.borderColor = [UIColor grayColor].CGColor;
        self.agreeButton.layer.borderWidth = 1;
    }
    self.agreeButton.mm_sizeToFit().mm_width(self.agreeButton.mm_w+20);
}

- (void)agreeClick
{
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ((touch.view == self.agreeButton)) {
        return NO;
    }
    return YES;
}

@end
