//
//  TUIContactActionCell_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIContactActionCell_Minimalist.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "TUICommonContactCellData_Minimalist.h"

@interface TUIContactActionCell_Minimalist ()
@property TUIContactActionCellData_Minimalist *actionData;
@property(nonatomic, strong) UIView *line;
@end

@implementation TUIContactActionCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.textColor = TIMCommonDynamicColor(@"", @"#000000");
        self.titleLabel.font = [UIFont systemFontOfSize:kScale390(16)];
        self.unRead = [[TUIUnReadView alloc] init];
        [self.contentView addSubview:self.unRead];

        self.line = [[UIView alloc] init];
        [self.contentView addSubview:self.line];
        self.line.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
        self.contentView.backgroundColor = [UIColor tui_colorWithHex:@"#f9f9f9"];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        //[self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)fillWithData:(TUIContactActionCellData_Minimalist *)actionData {
    [super fillWithData:actionData];
    self.actionData = actionData;
    self.titleLabel.text = actionData.title;
    @weakify(self);
    [[RACObserve(self.actionData, readNum) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
      @strongify(self);
      [self.unRead setNum:[x integerValue]];
    }];
    self.line.hidden = self.actionData.needBottomLine ? NO : YES;
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    [self.titleLabel sizeToFit];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(kScale390(16));
        make.width.mas_equalTo(self.titleLabel.frame.size.width);
        make.height.mas_equalTo(self.titleLabel.frame.size.height);
    }];
    
    [self.unRead.unReadLabel sizeToFit];
    [self.unRead mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-5);
        make.width.mas_equalTo(kScale375(20));
        make.height.mas_equalTo(kScale375(20));
    }];
    [self.unRead.unReadLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.unRead);
        make.size.mas_equalTo(self.unRead.unReadLabel);
    }];
    self.unRead.layer.cornerRadius = kScale375(10);
    [self.unRead.layer masksToBounds];
    
    [self.line mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-1);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(1);
        make.leading.mas_equalTo(self.contentView.mas_leading);
    }];    
}
@end
