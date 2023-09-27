//
//  TUICallingCalleeView.m
//  TUICalling
//
//  Created by noah on 2022/5/25.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingCalleeView.h"
#import "UIColor+TUICallingHex.h"
#import "TUIDefine.h"
#import "Masonry.h"
#import "TUILogin.h"
#import "TUICallEngineHeader.h"
#import "CallingLocalized.h"
#import "TUICalleeGroupCell.h"
#import "TUICallingUserModel.h"

static CGFloat const kItemWidth = 32.0f;
static CGFloat const kSpacing = 5.0f;

@interface TUICallingCalleeView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UILabel *calleeTipLabel;
@property (nonatomic, strong) UICollectionView *calleeCollectionView;
@property (nonatomic, strong) NSMutableArray <CallingUserModel *> *listDate;

@end

@implementation TUICallingCalleeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.listDate = [NSMutableArray array];
        [self setupCalleeViewView];
        [self.calleeCollectionView registerClass:NSClassFromString(@"TUICalleeGroupCell") forCellWithReuseIdentifier:@"TUICalleeGroupCell"];
    }
    return self;
}

/// 多人通话，被呼叫方UI初始化
- (void)setupCalleeViewView {
    [self addSubview:self.calleeTipLabel];
    [self addSubview:self.calleeCollectionView];
    // 视图约束
    [self.calleeTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.top.equalTo(self);
        make.leading.equalTo(self).offset(20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@(20));
    }];
    [self.calleeCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.calleeTipLabel.mas_bottom).offset(15);
        make.leading.equalTo(self).offset(20);
        make.trailing.equalTo(self).offset(-20);
        make.height.equalTo(@(32));
    }];
}

- (void)updateViewWithUserList:(NSArray<CallingUserModel *> *)userList {
    [self.listDate removeAllObjects];
    [userList enumerateObjectsUsingBlock:^(CallingUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj.userId isEqualToString:TUILogin.getUserID]) {
            [self.listDate addObject:obj];
        }
    }];
    self.calleeTipLabel.hidden = !self.listDate.count;
    [self.calleeCollectionView reloadData];
}

- (void)userLeave:(CallingUserModel *)userModel {
    if (userModel) {
        [self.listDate removeObject:userModel];
        [self.calleeCollectionView reloadData];
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listDate.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUICalleeGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TUICalleeGroupCell class])
                                                                         forIndexPath:indexPath];
    CallingUserModel *model = self.listDate[indexPath.item];
    cell.model = model;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kItemWidth, kItemWidth);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 0.1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 0.1);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return kSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(nonnull UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    CGFloat totalCellWidth = kItemWidth * self.listDate.count;
    CGFloat totalSpacingWidth = kSpacing * (((float)self.listDate.count - 1) < 0 ? 0 :self.listDate.count - 1);
    CGFloat leftInset = (collectionView.bounds.size.width - (totalCellWidth + totalSpacingWidth)) / 2;
    CGFloat rightInset = leftInset;
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(0, leftInset, 0, rightInset);
    return sectionInset;
}

#pragma mark - Lazy

- (UILabel *)calleeTipLabel {
    if (!_calleeTipLabel) {
        _calleeTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _calleeTipLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        [_calleeTipLabel setTextColor:[UIColor t_colorWithHexString:@"#999999"]];
        [_calleeTipLabel setText:TUICallingLocalize(@"Demo.TRTC.Calling.calleeTip")];
        [_calleeTipLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _calleeTipLabel;
}

- (UICollectionView *)calleeCollectionView {
    if (!_calleeCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _calleeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _calleeCollectionView.delegate = self;
        _calleeCollectionView.dataSource = self;
        _calleeCollectionView.showsVerticalScrollIndicator = NO;
        _calleeCollectionView.showsHorizontalScrollIndicator = NO;
        _calleeCollectionView.backgroundColor = [UIColor clearColor];
    }
    return _calleeCollectionView;
}

@end
