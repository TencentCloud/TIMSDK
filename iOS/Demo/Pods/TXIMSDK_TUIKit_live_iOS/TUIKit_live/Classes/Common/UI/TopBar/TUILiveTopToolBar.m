//
//  TUILiveTopToolBar.m
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveTopToolBar.h"
#import "SDWebImage.h"
#import <QuickLook/QuickLook.h>
#import "Masonry.h"
#import "TUILiveColor.h"

@interface TUILiveTopToolBar ()
@property(nonatomic, assign) NSTimeInterval audienceUpdateTimesamp;
@property(atomic, strong) dispatch_block_t audienceListUpdateBlock;
+ (UIButton *)newAvatarButton:(NSString *)avatarUrl defaultImage:(UIImage *)image;
@end

@implementation TUILiveTopToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutUI];
        [self bindInteraction];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configCornerRadius:self.onLineNumButton];
        [self configCornerRadius:self.anchorInfoBackgroundView];
        [self configCornerRadius:self.avatarButton];
        [self configCornerRadius:self.followButton];
        [self configCornerRadius:self.tagButton];
    });
}

- (void)layoutUI {
    if (!self.anchorInfoBackgroundView) {
        [self layoutAnchorInfoView];
        [self layoutAudienceInfoView];
#ifdef DEBUG
//        self.anchorInfo = [[TUILiveAnchorInfo alloc] init];
//        self.anchorInfo.nickName = @"怪兽";
//        self.anchorInfo.weightValue = 20134.0;
#endif
        [self updateUIInfo];
    }
}

- (void)setHasFollowed:(BOOL)hasFollowed {
    _hasFollowed = hasFollowed;
    if (hasFollowed) {
        [self.anchorInfoBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.anchorInfoBackgroundView.mas_height).multipliedBy(145/44.0);
        }];
    } else {
        [self.anchorInfoBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.anchorInfoBackgroundView.mas_height).multipliedBy(190/44.0);
        }];
    }
    self.followButton.hidden = hasFollowed;
}

- (void)layoutAnchorInfoView {
    if (self.anchorInfoBackgroundView) {
        return;
    }
    self.anchorInfoBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    [self addSubview:self.anchorInfoBackgroundView];
    self.anchorInfoBackgroundView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.7];
    [self.anchorInfoBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(14);
        make.height.mas_equalTo(40);
        make.centerY.equalTo(self);
        make.width.equalTo(self.anchorInfoBackgroundView.mas_height).multipliedBy(190/44.0);
    }];
    ///主播头像
    self.avatarButton = [self.class newAvatarButton:self.anchorInfo.avatarUrl defaultImage:nil];
    [self.anchorInfoBackgroundView addSubview:self.avatarButton];
    [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(self.anchorInfoBackgroundView.mas_height);
        make.left.equalTo(self.anchorInfoBackgroundView);
        make.centerY.equalTo(self.anchorInfoBackgroundView);
    }];
    [self.avatarButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    
    /// 主播名
    self.nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    [self.anchorInfoBackgroundView addSubview:self.nicknameLabel];
    [self.nicknameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarButton.mas_right).offset(5);
        make.bottom.equalTo(self.anchorInfoBackgroundView.mas_centerY);
        make.height.equalTo(@14);
        make.width.equalTo(self.mas_height).multipliedBy(145/44.0);
    }];
    self.nicknameLabel.backgroundColor = [UIColor clearColor];
    self.nicknameLabel.textColor = [UIColor whiteColor];
    self.nicknameLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
    self.nicknameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.tagButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 20)];
    [self.anchorInfoBackgroundView addSubview:self.tagButton];
    self.tagButton.backgroundColor = [UIColor clearColor];
    self.tagButton.titleLabel.font = [UIFont systemFontOfSize:11];
    self.tagButton.clipsToBounds = YES;
    [self.tagButton setTitle:@"在线：" forState:UIControlStateNormal];
    [self.tagButton setTitle:@"在线：" forState:UIControlStateHighlighted];
    [self.tagButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.avatarButton.mas_right).offset(5);
        make.top.equalTo(self.anchorInfoBackgroundView.mas_centerY);
        make.height.equalTo(@18);
        make.right.mas_equalTo(self.avatarButton.mas_right).offset(36);
    }];

    /// 关注
    self.followButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    [self.anchorInfoBackgroundView addSubview:self.followButton];
    [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.anchorInfoBackgroundView).offset(-5.0);
        make.height.equalTo(self.anchorInfoBackgroundView.mas_height).multipliedBy(3.5/5.0);
        make.centerY.equalTo(self.anchorInfoBackgroundView.mas_centerY);
        make.width.equalTo(self.anchorInfoBackgroundView.mas_height).multipliedBy(0.9);
    }];
    self.followButton.backgroundColor = [UIColor whiteColor];
    [self.followButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    self.followButton.clipsToBounds = YES;
    self.followButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.followButton setTitle:@"关注" forState:UIControlStateNormal];
    [self.followButton setTitle:@"关注" forState:UIControlStateHighlighted];
    [self.followButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutAudienceInfoView {
    /// 观众人数
    self.onLineNumButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 12)];
    [self.onLineNumButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:11]];
    [self.onLineNumButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self addSubview:self.onLineNumButton];
    [self.onLineNumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tagButton.mas_right);
        make.height.equalTo(@12);
        make.centerY.equalTo(self.tagButton);
        make.right.equalTo(self.anchorInfoBackgroundView);
    }];
    self.onLineNumButton.backgroundColor = [UIColor clearColor];
    [self.onLineNumButton addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.audienceListView = [[TUILiveTopBarAudienceListView alloc] initWithFrame:self.bounds];
    [self addSubview:self.audienceListView];
    [self.audienceListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.anchorInfoBackgroundView.mas_right).offset(5);
        make.height.equalTo(self.anchorInfoBackgroundView);
        make.centerY.equalTo(self.anchorInfoBackgroundView);
        make.right.equalTo(self).offset(-5);
    }];
    [self bringSubviewToFront:self.onLineNumButton];
}

- (void)bindInteraction {
    __weak typeof(self) weakSelf = self;
    [self.audienceListView setOnSelected:^(TUILiveTopBarAudienceListView * _Nonnull listView, id  _Nonnull info) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf callBack:strongSelf.onClickAudience sender:strongSelf info:info];
        }
    }];
}

- (void)setAnchorInfo:(TUILiveAnchorInfo *)anchorInfo {
    _anchorInfo = anchorInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUIInfo];
    });
}

- (void)updateUIInfo {
    /// 主播信息
    [self config:self.avatarButton avatarUrl:self.anchorInfo.avatarUrl defaultImage:[UIImage imageNamed:@"live_anchor_default_avatar"]];
    self.nicknameLabel.text = self.anchorInfo.nickName.length>0?self.anchorInfo.nickName:self.anchorInfo.userId;
    if ([self.nicknameLabel.text length] == 0) {
        self.nicknameLabel.text = @"主播";
    }
    [self updateAudienceListUI];
}

- (void)updateAudienceListUI {
    dispatch_block_t updateUI = ^() {
        NSArray *audienceList = self.audienceList;
        self.audienceListView.audienceList = audienceList;
        [self.onLineNumButton setTitle:[self formatStringWithNum:audienceList.count] forState:UIControlStateNormal];
    };
    if ([NSThread isMainThread]) {
        updateUI();
    } else {
        dispatch_async(dispatch_get_main_queue(), updateUI);
    }
}

- (void)config:(UILabel *)label weight:(CGFloat)weightValue {
    if (weightValue < 10000.0) {
        label.text = [NSString stringWithFormat:@"%0.1f", weightValue];
    } else {
        NSString *weightStr = [NSString stringWithFormat:@"%0.1f万", weightValue/10000.0];
        label.text = weightStr;
    }
}

- (void)configCornerRadius:(UIView *)view {
    view.layer.cornerRadius = view.bounds.size.height/2.0;
    view.clipsToBounds = YES;
}

- (NSString *)formatStringWithNum:(NSInteger)num {
    if (num >= 10000) {
        return [NSString stringWithFormat:@"%0.1f万人", num/10000.0];
    } else {
        return [NSString stringWithFormat:@"%ld人", num];
    }
}

#pragma mark - setter
- (void)setAudienceList:(NSArray<TUILiveAnchorInfo *> *)audienceList {
    _audienceList = audienceList;
    NSTimeInterval timesamp = [[NSDate date] timeIntervalSince1970];
    if (timesamp - self.audienceUpdateTimesamp < 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setAudienceList:self.audienceList];
        });
    } else {
        [self updateAudienceListUI];
        self.audienceUpdateTimesamp = timesamp;
    }
}

#pragma mark - Actions
- (IBAction)onClick:(UIButton *)sender {
    if ([sender isEqual:self.avatarButton]) {
        [self callBack:self.onClickAnchorAvator sender:self info:self.anchorInfo];
    } else if ([sender isEqual:self.followButton]) {
        [self callBack:self.onClickFollow sender:self info:self.anchorInfo];
    } else if ([sender isEqual:self.onLineNumButton]) {
        [self callBack:self.onClickOnlineNum sender:self info:self.anchorInfo];
    }
}

- (void)callBack:(TUILiveTopToolBarClickBlock)block sender:(id)sender info:(id)info {
    if (block) {
        block(sender, info);
    }
}

#pragma mark -
- (void)config:(UIButton *)button avatarUrl:(NSString *)avatarUrl defaultImage:(UIImage *)defaultImage {
    [button sd_setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateNormal placeholderImage:defaultImage];
    [button sd_setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateHighlighted placeholderImage:defaultImage];
}

+ (UIButton *)newAvatarButton:(NSString *)avatarUrl defaultImage:(UIImage *)image {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    button.clipsToBounds = YES;
    [button sd_setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateNormal placeholderImage: image];
    [button sd_setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateHighlighted placeholderImage: image];
    return button;
}

@end
