//
//  TUIGroupPinCell.m
//  TUIChat
//
//  Created by Tencent on 2024/05/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIMessageDataProvider.h"
#import "TUIGroupPinCell.h"

@implementation TUIGroupPinCellView
- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)fillWithData:(TUIMessageCellData *)cellData {
    self.cellData = cellData;
    self.titleLabel.text = [TUIMessageDataProvider getShowName:cellData.innerMessage];
    self.content.text = [TUIMessageDataProvider getDisplayString:cellData.innerMessage];
    
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
    [self.leftIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(6);
        make.top.bottom.mas_equalTo(self);
    }];
    
    [self.titleLabel sizeToFit];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.leftIcon.mas_trailing).mas_offset(8);
        make.trailing.mas_lessThanOrEqualTo(self.removeButton.mas_leading);
        make.width.mas_equalTo(self.titleLabel.frame.size.width);
        make.height.mas_equalTo(self.titleLabel.frame.size.height);
        make.top.mas_equalTo(self).mas_offset(9);
    }];
    
    [self.content sizeToFit];
    [self.content mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.leftIcon.mas_trailing).mas_offset(8);
        make.trailing.mas_lessThanOrEqualTo(self.removeButton.mas_leading);
        make.width.mas_equalTo(self.content.frame.size.width);
        make.height.mas_equalTo(self.content.frame.size.height);
        make.bottom.mas_equalTo(self).mas_offset(-9);
    }];
    
    [self.removeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-10);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    [self.removeButton.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.removeButton);
        make.width.mas_equalTo(14);
        make.height.mas_equalTo(14);
    }];
    
    [self.multiAnimationView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading);
        make.trailing.mas_equalTo(self.mas_trailing);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.mas_bottom);
    }];
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint newP = [self convertPoint:point toView:self.multiAnimationView];
    if ([self.multiAnimationView pointInside:newP withEvent:event]) {
        return self.multiAnimationView;
     }
    return [super hitTest:point withEvent:event];

}
- (void)setupView {
    self.backgroundColor = TUIChatDynamicColor(@"chat_pop_group_pin_back_color", @"#F9F9F9");
    [self addSubview:self.leftIcon];
    [self addSubview:self.titleLabel];
    [self addSubview:self.content];
    [self addSubview:self.removeButton];
    [self addSubview:self.multiAnimationView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self addGestureRecognizer:tap];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (UIImageView *)leftIcon {
    if (!_leftIcon) {
        _leftIcon = [[UIImageView alloc] init];
        _leftIcon.backgroundColor = TUIChatDynamicColor(@"chat_pop_group_pin_left_color", @"#D9D9D9");
    }
    return _leftIcon;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = TUIChatDynamicColor(@"chat_pop_group_pin_title_color", @"#141516");
        _titleLabel.font = [UIFont systemFontOfSize:16.0];
    }
    return _titleLabel;
}
- (UILabel *)content {
    if (!_content) {
        _content = [[UILabel alloc] init];
        _content.textColor = [TUIChatDynamicColor(@"chat_pop_group_pin_subtitle_color", @"#000000")
                              colorWithAlphaComponent:0.6];
        _content.font = [UIFont systemFontOfSize:14.0];
    }
    return _content;
}

- (UIButton *)removeButton {
    if (!_removeButton) {
        _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];;
        [_removeButton setImage:[UIImage imageNamed:TUIChatImagePath(@"chat_group_del_icon")] forState:UIControlStateNormal];
        [_removeButton addTarget:self action:@selector(removeCurrentGroupPin) forControlEvents:UIControlEventTouchUpInside];
    }
    return _removeButton;
}

 
- (UIView *)multiAnimationView {
    if (!_multiAnimationView) {
        _multiAnimationView = [[UIView alloc] initWithFrame:CGRectZero];
        _multiAnimationView.alpha = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        _multiAnimationView.userInteractionEnabled = YES;
        [_multiAnimationView addGestureRecognizer:tap];
        UIView *arrowBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        arrowBackgroundView.backgroundColor = [UIColor clearColor];
        arrowBackgroundView.layer.cornerRadius = 5;
        [_multiAnimationView addSubview:arrowBackgroundView];
        _multiAnimationView.clipsToBounds = YES;
        UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectZero];
        arrow.image = TUIChatBundleThemeImage(@"chat_pop_group_pin_down_arrow_img", @"chat_down_arrow_icon");
        [arrowBackgroundView addSubview:arrow];
            
        [arrowBackgroundView  mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(_multiAnimationView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(arrowBackgroundView);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
    }
    return _multiAnimationView;
}
- (void)removeCurrentGroupPin {
    if (self.onClickRemove) {
        self.onClickRemove(self.cellData.innerMessage);
    }
}
- (void)onTap:(id)sender {
    if (self.onClickCellView) {
        self.onClickCellView(self.cellData.innerMessage);
    }
}
- (void)hiddenMultiAnimation {
    self.multiAnimationView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    _multiAnimationView.alpha = 0;
}
    
- (void)showMultiAnimation {
    self.multiAnimationView.backgroundColor = TUIChatDynamicColor(@"chat_pop_group_pin_back_color", @"#F9F9F9");
    _multiAnimationView.alpha = 1;
}

@end

@interface TUIGroupPinCell ()
@property (nonatomic, strong) UIView *separatorView;
@end
@implementation TUIGroupPinCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.cellView];
    [self.contentView addSubview:self.separatorView];
}

- (TUIGroupPinCellView *)cellView {
    if (!_cellView) {
        _cellView = [[TUIGroupPinCellView alloc] init];
        _cellView.isFirstPage = NO;
    }
    return _cellView;
}
- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = TUIChatDynamicColor(@"chat_pop_group_pin_line_color", @"#DDDDDD");
    }
    return _separatorView;
}

- (void)fillWithData:(TUIMessageCellData *)cellData {
    [self.cellView fillWithData:cellData];
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

    [self.cellView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
    }];
    
    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).mas_offset(6);
        make.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
