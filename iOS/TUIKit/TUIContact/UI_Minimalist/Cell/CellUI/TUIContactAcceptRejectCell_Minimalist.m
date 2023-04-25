//
//  TUIContactAcceptRejectCell_Minimalist.m
//  TUIContact
//
//  Created by wyl on 2023/1/5.
//

#import "TUIContactAcceptRejectCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>


@implementation TUIContactAcceptRejectCell_Minimalist

-  (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.agreeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.agreeButton.titleLabel.font = [UIFont systemFontOfSize:kScale390(14)];
    [self.agreeButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
    [self.agreeButton addTarget:self action:@selector(agreeClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.rejectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.rejectButton.titleLabel.font = [UIFont systemFontOfSize:kScale390(14)];
    [self.rejectButton setTitleColor:TIMCommonDynamicColor(@"form_title_color", @"#000000") forState:UIControlStateNormal];
    [self.rejectButton addTarget:self action:@selector(rejectClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.agreeButton];
    [self.contentView addSubview:self.rejectButton];

}
- (void)fillWithData:(TUIContactAcceptRejectCellData_Minimalist *)data {
    [super fillWithData:data];
    self.acceptRejectData = data;
    
    if (data.isAccepted) {
        [self.agreeButton setTitle:TIMCommonLocalizableString(Agreed) forState:UIControlStateNormal];
        self.agreeButton.enabled = NO;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.agreeButton.layer.cornerRadius = kScale390(10);
        [self.agreeButton setTitleColor:TIMCommonDynamicColor(@"", @"#999999") forState:UIControlStateNormal];
        self.agreeButton.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];
    } else {
        [self.agreeButton setTitle:TIMCommonLocalizableString(Agree) forState:UIControlStateNormal];
        self.agreeButton.enabled = YES;
        self.agreeButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.agreeButton.layer.borderWidth = 1;
        self.agreeButton.layer.cornerRadius = kScale390(10);
        [self.agreeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        self.agreeButton.backgroundColor = TIMCommonDynamicColor(@"primary_theme_color", @"#147AFF");
    }
    
    if (data.isRejected) {
        [self.rejectButton setTitle:TIMCommonLocalizableString(Disclined) forState:UIControlStateNormal];
        self.rejectButton.enabled = NO;
        self.rejectButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.rejectButton.layer.cornerRadius = kScale390(10);
        [self.rejectButton setTitleColor:TIMCommonDynamicColor(@"", @"#999999") forState:UIControlStateNormal];
        self.rejectButton.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];
    } else {
        [self.rejectButton setTitle:TIMCommonLocalizableString(Discline) forState:UIControlStateNormal];
        self.rejectButton.enabled = YES;
        self.rejectButton.layer.borderColor = TIMCommonDynamicColor(@"", @"#DDDDDD").CGColor;
        self.rejectButton.layer.borderWidth = 1;
        self.rejectButton.layer.cornerRadius = kScale390(10);
        [self.rejectButton setTitleColor:TIMCommonDynamicColor(@"", @"#FF584C") forState:UIControlStateNormal];
        self.rejectButton.backgroundColor = [UIColor tui_colorWithHex:@"f9f9f9"];

    }
    
    CGFloat margin = kScale390(25);
    CGFloat padding = kScale390(20);
    CGFloat btnWidth = (self.contentView.frame.size.width - 2 * margin -padding ) *0.5;
    CGFloat btnHeight = kScale390(42);
    self.agreeButton.frame = CGRectMake(margin, 0, btnWidth, btnHeight);
    self.rejectButton.frame = CGRectMake(margin + btnWidth + padding, 0, btnWidth, btnHeight);
    
    if (data.isRejected && !data.isAccepted) {
        self.agreeButton.hidden = YES;
        self.rejectButton.hidden = NO;
        self.rejectButton.frame = CGRectMake(margin, 0, 2 *btnWidth + padding, btnHeight);
    } else if (data.isAccepted && !data.isRejected) {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = YES;
        self.agreeButton.frame = CGRectMake(margin, 0, 2 *btnWidth + padding, btnHeight);
    } else {
        self.agreeButton.hidden = NO;
        self.rejectButton.hidden = NO;
    }
}

- (void)agreeClick {
    if(self.acceptRejectData.agreeClickCallback) {
        self.acceptRejectData.agreeClickCallback();
    }
}

- (void)rejectClick {
    if(self.acceptRejectData.rejectClickCallback) {
        self.acceptRejectData.rejectClickCallback();
    }
}
@end
