//
//  TUIReactMemberCell.m
//  TUIChat
//
//  Created by wyl on 2022/5/26.
//  Copyright © 2023 Tencent. All rights reserved.
//
#import "TUIReactMemberCell.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMCommonModel.h>
#import "TUIReactMemberCellData.h"

#define Avatar_Size 40

@interface TUIReactMemberCell ()
@property(nonatomic, strong) UIImageView *avatar;
@property(nonatomic, strong) UILabel *displayName;
@property(nonatomic, strong) UILabel *tapToRemoveLabel;
@property(nonatomic, strong) UIImageView *emoji;
@property(nonatomic, strong) TUIReactMemberCellData *data;
@end

@implementation TUIReactMemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _avatar = [[UIImageView alloc] init];
        _avatar.layer.cornerRadius = Avatar_Size / 2.0;
        _avatar.layer.masksToBounds = YES;
        [self addSubview:_avatar];

        _displayName = [[UILabel alloc] init];
        _displayName.font = [UIFont boldSystemFontOfSize:kScale390(16)];
        _displayName.textColor = [UIColor tui_colorWithHex:@"#666666"];
        _displayName.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        [self addSubview:_displayName];

        _tapToRemoveLabel = [[UILabel alloc] init];
        _tapToRemoveLabel.font = [UIFont systemFontOfSize:kScale390(12)];
        _tapToRemoveLabel.textColor = [UIColor tui_colorWithHex:@"#666666"];
        _tapToRemoveLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        [self addSubview:_tapToRemoveLabel];

        _emoji = [[UIImageView alloc] init];
        [self addSubview:_emoji];
    }
    return self;
}

#pragma mark - UI
- (void)prepareUI {
    self.layer.cornerRadius = 12.0f;
    self.layer.masksToBounds = YES;
}

- (void)fillWithData:(TUIReactMemberCellData *)data {
    self.data = data;
    [_avatar sd_setImageWithURL:[NSURL URLWithString:data.faceURL] placeholderImage:DefaultAvatarImage];
    _displayName.text = data.displayName;
    _tapToRemoveLabel.text = @"";
    if (data.isCurrentUser) {
        _displayName.text = TIMCommonLocalizableString(You);
        _tapToRemoveLabel.text = TIMCommonLocalizableString(TUIKitChatTap2Remove);
    }
    
    [_emoji setImage:[data.emojiName getEmojiImage]];
    
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

    CGFloat avatarSize = kScale390(40);
    
    [_avatar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(kScale390(26));
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(avatarSize);
    }];

    [_displayName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_avatar.mas_trailing).mas_offset(kScale390(16));
        make.trailing.mas_equalTo(-kScale390(60));
        make.height.mas_equalTo(kScale390(22));
        make.centerY.mas_equalTo(self.contentView);
    }];

    if (self.data.isCurrentUser) {
        [_displayName mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(_avatar.mas_trailing).mas_offset(kScale390(16));
            make.top.mas_equalTo(_avatar.mas_top);
            make.trailing.mas_equalTo(-kScale390(60));
            make.height.mas_equalTo(kScale390(22));
        }];
        [_tapToRemoveLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(_displayName.mas_leading);
            make.top.mas_equalTo(_displayName.mas_bottom).mas_offset(kScale390(4));
            make.trailing.mas_equalTo(-kScale390(60));
            make.height.mas_equalTo(kScale390(12));
        }];
    }

    [_emoji mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-kScale390(32));
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(kScale390(16));
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
