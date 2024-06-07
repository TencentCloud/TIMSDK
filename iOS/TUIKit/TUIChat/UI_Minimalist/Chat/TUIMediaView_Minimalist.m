//
//  MenuView.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIMediaView_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIMessageCell.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIGlobalization.h>
#import "TUIChatConversationModel.h"
#import "TUIImageCollectionCell_Minimalist.h"
#import "TUIMessageMediaDataProvider.h"
#import "TUIVideoCollectionCell_Minimalist.h"

#define ANIMATION_TIME 0.2

@interface TUIMediaView_Minimalist () <UICollectionViewDelegate,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout,
                                       UIScrollViewDelegate,
                                       TUIMediaCollectionCellDelegate_Minimalist>
@property(strong, nonatomic) TUIMessageMediaDataProvider *dataProvider;
@property(strong, nonatomic) UICollectionView *menuCollectionView;
@property(strong, nonatomic) UIImage *saveBackgroundImage;
@property(strong, nonatomic) UIImage *saveShadowImage;
@property(strong, nonatomic) UIImageView *imageView;
@property(strong, nonatomic) UIImage *thumbImage;
@property(strong, nonatomic) UIView *coverView;
@property(strong, nonatomic) UIView *mediaView;
@property(assign, nonatomic) CGRect thumbFrame;
@end

@implementation TUIMediaView_Minimalist {
    V2TIMMessage *_curMessage;
}

- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];

    self.coverView = [[UIView alloc] initWithFrame:self.bounds];
    self.coverView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.coverView];

    self.mediaView = [[UIView alloc] initWithFrame:self.thumbFrame];
    self.mediaView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.mediaView];

    UICollectionViewFlowLayout *menuFlowLayout = [[TUICollectionRTLFitFlowLayout alloc] init];
    menuFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    menuFlowLayout.minimumLineSpacing = 0;
    menuFlowLayout.minimumInteritemSpacing = 0;
    menuFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

    self.menuCollectionView = [[UICollectionView alloc] initWithFrame:self.mediaView.bounds collectionViewLayout:menuFlowLayout];
    self.menuCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuCollectionView registerClass:[TUIImageCollectionCell_Minimalist class] forCellWithReuseIdentifier:TImageMessageCell_ReuseId];
    [self.menuCollectionView registerClass:[TUIVideoCollectionCell_Minimalist class] forCellWithReuseIdentifier:TVideoMessageCell_ReuseId];
    self.menuCollectionView.pagingEnabled = YES;
    self.menuCollectionView.delegate = self;
    self.menuCollectionView.dataSource = self;
    self.menuCollectionView.showsHorizontalScrollIndicator = NO;
    self.menuCollectionView.showsVerticalScrollIndicator = NO;
    self.menuCollectionView.alwaysBounceHorizontal = YES;
    self.menuCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.menuCollectionView.backgroundColor = [UIColor clearColor];
    self.menuCollectionView.hidden = YES;
    [self.mediaView addSubview:self.menuCollectionView];

    self.imageView = [[UIImageView alloc] initWithFrame:self.mediaView.bounds];
    self.imageView.layer.cornerRadius = 5.0;
    [self.imageView.layer setMasksToBounds:YES];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.image = self.thumbImage;
    [self.mediaView addSubview:self.imageView];

    [UIView animateWithDuration:ANIMATION_TIME
                     animations:^{
                       self.mediaView.frame = self.bounds;
                     }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ANIMATION_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [self.imageView removeFromSuperview];
      self.menuCollectionView.hidden = NO;
    });
}

- (void)setThumb:(UIImageView *)thumb frame:(CGRect)frame {
    self.thumbImage = thumb.image;
    self.thumbFrame = frame;
    [self setupViews];
}

- (void)setCurMessage:(V2TIMMessage *)curMessage {
    _curMessage = curMessage;
    TUIChatConversationModel *model = [[TUIChatConversationModel alloc] init];
    model.userID = _curMessage.userID;
    model.groupID = _curMessage.groupID;
    self.dataProvider = [[TUIMessageMediaDataProvider alloc] initWithConversationModel:model];
    [self.dataProvider loadMediaWithMessage:_curMessage];

    @weakify(self);
    [RACObserve(self.dataProvider, medias) subscribeNext:^(NSArray *x) {
      @strongify(self);
      [self.menuCollectionView reloadData];
      for (int i = 0; i < self.dataProvider.medias.count; i++) {
          TUIMessageCellData *data = self.dataProvider.medias[i];
          if ([data.innerMessage.msgID isEqualToString:self->_curMessage.msgID]) {
              [self.menuCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                              atScrollPosition:(UICollectionViewScrollPositionLeft)animated:NO];
              return;
          }
      }
    }];
}

- (void)setCurMessage:(V2TIMMessage *)curMessage allMessages:(NSArray<V2TIMMessage *> *)allMessages {
    _curMessage = curMessage;

    NSMutableArray *medias = [NSMutableArray array];
    for (V2TIMMessage *message in allMessages) {
        TUIMessageCellData *data = [TUIMessageMediaDataProvider getMediaCellData:message];
        if (data) {
            [medias addObject:data];
        }
    }

    self.dataProvider = [[TUIMessageMediaDataProvider alloc] initWithConversationModel:nil];
    self.dataProvider.medias = medias;

    [self.menuCollectionView reloadData];
    for (int i = 0; i < self.dataProvider.medias.count; i++) {
        TUIMessageCellData *data = self.dataProvider.medias[i];
        if ([data.innerMessage.msgID isEqualToString:_curMessage.msgID]) {
            [self.menuCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                            atScrollPosition:(UICollectionViewScrollPositionLeft)animated:NO];
            return;
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataProvider.medias.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIMessageCellData *data = self.dataProvider.medias[indexPath.row];
    TUIMediaCollectionCell_Minimalist *cell = [collectionView dequeueReusableCellWithReuseIdentifier:data.reuseId forIndexPath:indexPath];
    if (cell) {
        cell.delegate = self;
        [cell fillWithData:data];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

#pragma mark TUIMediaCollectionCellDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSArray *indexPaths = [self.menuCollectionView indexPathsForVisibleItems];
    NSIndexPath *indexPath = indexPaths.firstObject;
    TUIMessageCellData *data = self.dataProvider.medias[indexPath.row];
    _curMessage = data.innerMessage;
    if (indexPath.row <= self.dataProvider.pageCount / 2) {
        [self.dataProvider loadOlderMedia];
    }
    if (indexPath.row >= self.dataProvider.medias.count - self.dataProvider.pageCount / 2) {
        [self.dataProvider loadNewerMedia];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSArray *indexPaths = [self.menuCollectionView indexPathsForVisibleItems];
    NSIndexPath *indexPath = indexPaths.firstObject;
    UICollectionViewCell *cell = [self.menuCollectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[TUIVideoCollectionCell_Minimalist class]]) {
        TUIVideoCollectionCell_Minimalist *videoCell = (TUIVideoCollectionCell_Minimalist *)cell;
        [videoCell stopVideoPlayAndSave];
    }
}

#pragma mark TUIMediaCollectionCellDelegate
- (void)onCloseMedia:(TUIMediaCollectionCell_Minimalist *)cell {
    if (self.onClose) {
        self.onClose();
    }
    if (self.superview) {
        [self removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDisableAllRotationOrientationNotification object:nil];
}

@end
