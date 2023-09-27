//
//  TUICallRecordCallsCell.m
//  TUICallKit
//
//  Created by noah on 2023/2/28.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICallRecordCallsCell.h"
#import "Masonry.h"
#import "TUICallRecordCallsCellViewModel.h"
#import "TUICallingCommon.h"
#import "UIImageView+WebCache.h"
#import "TUIConfig.h"
#import "TUICallEngineHeader.h"
#import "TUIThemeManager.h"

static NSString *const gRecordCallsCellViewModelKVOAvatarImage = @"avatarImage";
static NSString *const gRecordCallsCellViewModelKVOFaceURL = @"faceURL";
static NSString *const gRecordCallsCellViewModelKVOTitle = @"titleLabelStr";

@interface TUICallRecordCallsCell ()

@property (nonatomic, assign) BOOL isViewReady;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *mediaTypeImageView;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) TUICallRecordCallsCellViewModel *viewModel;

@end

@implementation TUICallRecordCallsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _isViewReady = NO;
        self.contentView.backgroundColor = TUICallKitDynamicColor(@"callkit_recents_cell_bg_color", @"#FFFFFF");
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_isViewReady) {
        return;
    }
    _isViewReady = YES;
    [self constructViewHierarchy];
    [self activateConstraints];
    [self bindInteraction];
}

- (void)dealloc {
    [self removeBindViewModel];
}

- (void)constructViewHierarchy {
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.mediaTypeImageView];
    [self.contentView addSubview:self.resultLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.moreButton];
}

- (void)activateConstraints {
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(8);
        make.width.height.mas_equalTo(40);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(14);
        make.leading.equalTo(self.avatarImageView.mas_trailing).offset(8);
        make.trailing.lessThanOrEqualTo(self.timeLabel.mas_leading).offset(-20);
    }];
    [self.mediaTypeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-14);
        make.leading.equalTo(self.avatarImageView.mas_trailing).offset(8);
        make.width.mas_equalTo(19);
        make.height.mas_equalTo(12);
    }];
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mediaTypeImageView);
        make.leading.equalTo(self.mediaTypeImageView.mas_trailing).offset(4);
        make.width.mas_equalTo(100);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.equalTo(self.moreButton.mas_leading).offset(-4);
        make.width.mas_equalTo(100);
    }];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.trailing.mas_equalTo(-8);
        make.width.height.mas_equalTo(24);
    }];
}

- (void)bindInteraction {
    [self.moreButton addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)bindViewModel {
    [self.viewModel addObserver:self forKeyPath:gRecordCallsCellViewModelKVOAvatarImage options:NSKeyValueObservingOptionNew context:nil];
    [self.viewModel addObserver:self forKeyPath:gRecordCallsCellViewModelKVOFaceURL options:NSKeyValueObservingOptionNew context:nil];
    [self.viewModel addObserver:self forKeyPath:gRecordCallsCellViewModelKVOTitle options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeBindViewModel {
    @try {
        [self.viewModel removeObserver:self forKeyPath:gRecordCallsCellViewModelKVOAvatarImage context:nil];
        [self.viewModel removeObserver:self forKeyPath:gRecordCallsCellViewModelKVOFaceURL context:nil];
        [self.viewModel removeObserver:self forKeyPath:gRecordCallsCellViewModelKVOTitle context:nil];
    }
    @catch (NSException *exception) {
    }
}

#pragma mark - bind data

- (void)bindViewModel:(TUICallRecordCallsCellViewModel *)viewModel {
    self.viewModel = viewModel;
    [self bindViewModel];
    
    self.titleLabel.text = viewModel.titleLabelStr;
    self.resultLabel.text = viewModel.resultLabelStr;
    self.timeLabel.text = viewModel.timeLabelStr;
    [self.mediaTypeImageView setImage:[TUICallingCommon getBundleImageWithName:viewModel.mediaTypeImageStr]];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:viewModel.faceURL] placeholderImage:viewModel.avatarImage];
    
    if (TUICallResultTypeMissed == viewModel.callRecord.result) {
        self.titleLabel.textColor = UIColor.redColor;
    } else {
        self.titleLabel.textColor = TUICallKitDynamicColor(@"callkit_recents_cell_title_color", @"#000000");
    }
}

#pragma mark - observeValueForKeyPath

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    TUICallRecordCallsCellViewModel *viewModel = (TUICallRecordCallsCellViewModel *)object;
    
    if ([keyPath isEqualToString:gRecordCallsCellViewModelKVOAvatarImage]) {
        [self.avatarImageView sd_setImageWithURL:nil placeholderImage:viewModel.avatarImage];
    } else if ([keyPath isEqualToString:gRecordCallsCellViewModelKVOFaceURL]) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:viewModel.faceURL] placeholderImage:nil];
    } else if ([keyPath isEqualToString:gRecordCallsCellViewModelKVOTitle]) {
        self.titleLabel.text = viewModel.titleLabelStr;
    }
}

#pragma mark - event action

- (void)moreButtonClick:(UIButton *)button {
    !self.moreBtnClickedHandler ?: self.moreBtnClickedHandler(self);
}

#pragma mark - getter and setter

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.layer.cornerRadius = 20;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont fontWithName:@"PingFangHK-Semibold" size:14];
        _titleLabel.textAlignment =  isRTL() ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UIImageView *)mediaTypeImageView {
    if (!_mediaTypeImageView) {
        _mediaTypeImageView = [[UIImageView alloc] init];
        _mediaTypeImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _mediaTypeImageView;
}

- (UILabel *)resultLabel {
    if (!_resultLabel) {
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _resultLabel.textColor = TUICallKitDynamicColor(@"callkit_recents_cell_subtitle_color", @"#888888");
        _resultLabel.font = [UIFont systemFontOfSize:12];
        _resultLabel.textAlignment =  isRTL() ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
    return _resultLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = TUICallKitDynamicColor(@"callkit_recents_cell_time_color", @"#BBBBBB");
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment =  isRTL() ? NSTextAlignmentLeft : NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setImage:[TUICallingCommon getBundleImageWithName:@"ic_recents_more"] forState:UIControlStateNormal];
        _moreButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _moreButton;
}

@end
