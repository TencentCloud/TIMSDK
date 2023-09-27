//
//  TUIGroupNoticeCell.m
//  TUIGroup
//
//  Created by harvy on 2022/1/11.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIGroupNoticeCell.h"
#import <TUICore/TUIThemeManager.h>
#import <TIMCommon/TIMDefine.h>

@implementation TUIGroupNoticeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    self.contentView.backgroundColor = TIMCommonDynamicColor(@"form_bg_color", @"#FFFFFF");
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.descLabel];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapRecognizer.delegate = self;
    tapRecognizer.cancelsTouchesInView = NO;
    [self.contentView addGestureRecognizer:tapRecognizer];
}

- (void)tapGesture:(UIGestureRecognizer *)gesture {
    if (self.cellData.selector && self.cellData.target) {
        if ([self.cellData.target respondsToSelector:self.cellData.selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.cellData.target performSelector:self.cellData.selector];
#pragma clang diagnostic pop
        }
    }
}

- (void)setCellData:(TUIGroupNoticeCellData *)cellData {
    _cellData = cellData;

    self.nameLabel.text = cellData.name;
    self.descLabel.text = cellData.desc;
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
    
    [self.nameLabel sizeToFit];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.mas_equalTo(12);
        make.trailing.mas_lessThanOrEqualTo(self.contentView).mas_offset(-20);
        make.size.mas_equalTo(self.nameLabel.frame.size);
    }];
    [self.descLabel sizeToFit];
    [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(4);
        make.trailing.mas_lessThanOrEqualTo(self.contentView).mas_offset(-30);
        make.size.mas_equalTo(self.descLabel.frame.size);
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"";
        _nameLabel.textColor = TIMCommonDynamicColor(@"form_key_text_color", @"#888888");
        _nameLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _nameLabel;
}

- (UILabel *)descLabel {
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.text = @"neirong";
        _descLabel.textColor = TIMCommonDynamicColor(@"form_subtitle_color", @"#BBBBBB");
        _descLabel.font = [UIFont systemFontOfSize:12.0];
    }
    return _descLabel;
}

@end
