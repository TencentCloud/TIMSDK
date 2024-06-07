//
//  MenuView.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIMediaView.h"
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIMessageCell.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIGlobalization.h>
#import "TUIChatConversationModel.h"
#import "TUIImageCollectionCell.h"
#import "TUIMessageMediaDataProvider.h"
#import "TUIVideoCollectionCell.h"

#define ANIMATION_TIME 0.2

@interface TUIMediaView () <UICollectionViewDelegate,
                            UICollectionViewDataSource,
                            UICollectionViewDelegateFlowLayout,
                            UIScrollViewDelegate,
                            TUIMediaCollectionCellDelegate>
@property(strong, nonatomic) TUIMessageMediaDataProvider *dataProvider;
@property(strong, nonatomic) UICollectionView *menuCollectionView;
@property(strong, nonatomic) UIImage *saveBackgroundImage;
@property(strong, nonatomic) UIImage *saveShadowImage;
@property(strong, nonatomic) UIImageView *imageView;
@property(strong, nonatomic) UIImage *thumbImage;
@property(strong, nonatomic) UIView *coverView;
@property(strong, nonatomic) UIView *mediaView;
@property(assign, nonatomic) CGRect thumbFrame;
@property(assign, nonatomic) NSIndexPath *currentVisibleIndexPath;
@end

@implementation TUIMediaView {
    V2TIMMessage *_curMessage;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentVisibleIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return self;
}
- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];

    self.coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width * 3, Screen_Height * 3)];
    self.coverView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.coverView];

    self.mediaView = [[UIView alloc] initWithFrame:self.thumbFrame];
    self.mediaView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.mediaView];

    TUICollectionRTLFitFlowLayout *menuFlowLayout = [[TUICollectionRTLFitFlowLayout alloc] init];
    menuFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    menuFlowLayout.minimumLineSpacing = 0;
    menuFlowLayout.minimumInteritemSpacing = 0;
    menuFlowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

    self.menuCollectionView = [[UICollectionView alloc] initWithFrame:self.mediaView.bounds collectionViewLayout:menuFlowLayout];
    self.menuCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuCollectionView registerClass:[TUIImageCollectionCell class] forCellWithReuseIdentifier:TImageMessageCell_ReuseId];
    [self.menuCollectionView registerClass:[TUIVideoCollectionCell class] forCellWithReuseIdentifier:TVideoMessageCell_ReuseId];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kEnableAllRotationOrientationNotification object:nil];
    [self setupRotaionNotifications];
}

- (void)setupRotaionNotifications {
    if (@available(iOS 16.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDeviceOrientationChange:)
                                                     name:TUIMessageMediaViewDeviceOrientationChangeNotification
                                                   object:nil];
    } else {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onDeviceOrientationChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
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
              self.currentVisibleIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
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
    TUIMediaCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:data.reuseId forIndexPath:indexPath];
    if (cell) {
        cell.delegate = self;
        [cell fillWithData:data];
        if ([cell isKindOfClass:[TUIVideoCollectionCell class]]) {
            TUIVideoCollectionCell *videoCell = (TUIVideoCollectionCell *)cell;
            [videoCell reloadAllView];
        }
        else if ([cell isKindOfClass:[TUIImageCollectionCell class]]) {
            TUIImageCollectionCell *imageCell =  (TUIImageCollectionCell *)cell;
            [imageCell reloadAllView];
        }
        else {
            //empty
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self.menuCollectionView.collectionViewLayout invalidateLayout];
}
- (CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    UICollectionViewLayoutAttributes *attrs = [collectionView layoutAttributesForItemAtIndexPath:self.currentVisibleIndexPath];
    CGPoint newOriginForOldIndex = attrs.frame.origin;
    return newOriginForOldIndex.x == 0 ? proposedContentOffset : newOriginForOldIndex;
}
#pragma mark TUIMediaCollectionCellDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint center = CGPointMake(scrollView.contentOffset.x + (scrollView.frame.size.width / 2), scrollView.frame.size.height / 2);
    NSIndexPath *ip = [self.menuCollectionView indexPathForItemAtPoint:center];
    if (ip) {
        self.currentVisibleIndexPath = ip;
    }

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
    if ([cell isKindOfClass:[TUIVideoCollectionCell class]]) {
        TUIVideoCollectionCell *videoCell = (TUIVideoCollectionCell *)cell;
        [videoCell stopVideoPlayAndSave];
    }
}

#pragma mark TUIMediaCollectionCellDelegate
- (void)onCloseMedia:(TUIMediaCollectionCell *)cell {
    if (self.onClose) {
        self.onClose();
    }
    if (self.superview) {
        [self removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDisableAllRotationOrientationNotification object:nil];
}
- (void)applyRotaionFrame {
    self.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
    self.coverView.frame = CGRectMake(0, 0, Screen_Width * 3, Screen_Height * 3);
    self.mediaView.frame = self.frame;
    self.mediaView.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    self.menuCollectionView.frame = self.mediaView.frame;
    self.menuCollectionView.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    [self.menuCollectionView setNeedsLayout];
    self.imageView.frame = self.mediaView.frame;
    self.imageView.center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    [self.menuCollectionView
        performBatchUpdates:^{
        }
        completion:^(BOOL finished) {
          if (finished) {
              [self.menuCollectionView scrollToItemAtIndexPath:self.currentVisibleIndexPath atScrollPosition:(UICollectionViewScrollPositionLeft)animated:NO];
          }
        }];
    return;
}

- (void)onDeviceOrientationChange:(NSNotification *)noti {
    [UIView performWithoutAnimation:^{
      [self applyRotaionFrame];
    }];
}
@end
