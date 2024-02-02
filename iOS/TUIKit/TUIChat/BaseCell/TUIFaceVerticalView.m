//
//  TUIFaceVerticalView.m
//  TUIChat
//
//  Created by wyl on 2023/11/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFaceVerticalView.h"

@interface TUIFaceVerticalView () <UICollectionViewDelegate,
                                   UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout,
                                   UIPopoverPresentationControllerDelegate>
@property(nonatomic, strong) NSMutableArray *sectionIndexInGroup;
@property(nonatomic, strong) NSMutableArray *groupIndexInSection;
@property(nonatomic, strong) NSMutableDictionary *itemIndexs;
@property(nonatomic, assign) NSInteger sectionCount;
@property(nonatomic, assign) NSInteger curGroupIndex;

@property(nonatomic, strong) UIView *floatCtrlView;
@property(nonatomic, strong) UIButton *sendButton;
@property(nonatomic, strong) UIButton *deleteButton;

//preview
@property (nonatomic, strong) UIImageView *dispalyView;
@property (nonatomic, strong) UIImageView *dispalyImage;
@property (nonatomic, assign) BOOL hasPreViewShow;
@end

@implementation TUIFaceVerticalView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = TUIChatDynamicColor(@"chat_input_controller_bg_color", @"#EBF0F6");

    _faceFlowLayout = [[TUICollectionRTLFitFlowLayout alloc] init];
    _faceFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _faceFlowLayout.minimumLineSpacing = TFaceView_Margin;
    _faceFlowLayout.minimumInteritemSpacing = TFaceView_Margin;
    _faceFlowLayout.sectionInset = UIEdgeInsetsMake(0, TFaceView_Page_Padding, 0, TFaceView_Page_Padding);

    _faceCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_faceFlowLayout];
    [_faceCollectionView registerClass:[TUIFaceCell class] forCellWithReuseIdentifier:TFaceCell_ReuseId];
    [_faceCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    _faceCollectionView.collectionViewLayout = _faceFlowLayout;
    _faceCollectionView.pagingEnabled = NO;
    _faceCollectionView.delegate = self;
    _faceCollectionView.dataSource = self;
    _faceCollectionView.showsHorizontalScrollIndicator = NO;
    _faceCollectionView.showsVerticalScrollIndicator = NO;
    _faceCollectionView.backgroundColor = self.backgroundColor;
    _faceCollectionView.alwaysBounceVertical = YES;
    [self addSubview:_faceCollectionView];

    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");
    [self addSubview:_lineView];

    [self setupfloatCtrlView];
}
- (void)setupfloatCtrlView {
    _floatCtrlView = [[UIView alloc] init];
    [self addSubview:_floatCtrlView];
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendButton setTitle:TIMCommonLocalizableString(Send)forState:UIControlStateNormal];
    _sendButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.sendButton addTarget:self action:@selector(didSelectSendButton:) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.backgroundColor = TIMCommonDynamicColor(@"", @"#0069F6");
    self.sendButton.layer.cornerRadius = 2;
    [_floatCtrlView addSubview:self.sendButton];

    _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteButton setImage:[UIImage imageWithContentsOfFile:TUIChatFaceImagePath(@"del_normal")] forState:UIControlStateNormal];
    [_deleteButton setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    _deleteButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _deleteButton.layer.cornerRadius = 2;
    [_deleteButton addTarget:self action:@selector(didSelectDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.backgroundColor = [UIColor whiteColor];
    [_floatCtrlView addSubview:_deleteButton];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self defaultLayout];
}

- (void)defaultLayout {
    _lineView.frame = CGRectMake(0, 0, self.frame.size.width, TLine_Heigh);
    [_faceCollectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [_floatCtrlView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(20);
        make.height.mas_equalTo(88);
        make.leading.mas_equalTo(self.deleteButton.mas_leading);
    }];
    
    [self.sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.floatCtrlView.mas_trailing);
        make.top.mas_equalTo(self.floatCtrlView);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(50);
    }];
    [self.deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.sendButton.mas_leading).mas_offset(-10);
        make.top.mas_equalTo(self.floatCtrlView);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(50);
    }];
}

- (void)setData:(NSMutableArray *)data {
    _faceGroups = data;
    [self defaultLayout];

    _sectionIndexInGroup = [NSMutableArray array];
    _groupIndexInSection = [NSMutableArray array];
    _itemIndexs = [NSMutableDictionary dictionary];

    NSInteger sectionIndex = 0;
    for (NSInteger groupIndex = 0; groupIndex < _faceGroups.count; ++groupIndex) {
        TUIFaceGroup *group = _faceGroups[groupIndex];
        [_sectionIndexInGroup addObject:@(sectionIndex)];
        int itemCount = group.faces.count;
        int sectionCount = ceil(group.faces.count * 1.0 / itemCount);
        for (int sectionIndex = 0; sectionIndex < sectionCount; ++sectionIndex) {
            [_groupIndexInSection addObject:@(groupIndex)];
        }
        sectionIndex += sectionCount;
    }
    _sectionCount = sectionIndex;

    for (NSInteger curSection = 0; curSection < _sectionCount; ++curSection) {
        NSNumber *groupIndex = _groupIndexInSection[curSection];
        NSNumber *groupSectionIndex = _sectionIndexInGroup[groupIndex.integerValue];
        TUIFaceGroup *face = _faceGroups[groupIndex.integerValue];
        NSInteger itemCount = face.faces.count;
        NSInteger groupSection = curSection - groupSectionIndex.integerValue;
        for (NSInteger itemIndex = 0; itemIndex < itemCount; ++itemIndex) {
            // transpose line/row
            NSInteger reIndex = itemIndex;
            [_itemIndexs setObject:@(reIndex) forKey:[NSIndexPath indexPathForRow:itemIndex inSection:curSection]];
        }
    }

    _curGroupIndex = 0;

    [_faceCollectionView reloadData];
    
    TUIFaceGroup *group = _faceGroups[0];
    if (!group.isNeedAddInInputBar) {
        _floatCtrlView.hidden = YES;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjustEmotionsAlpha];
    });
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _sectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int groupIndex = [_groupIndexInSection[section] intValue];
    TUIFaceGroup *group = _faceGroups[groupIndex];
    return group.faces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TFaceCell_ReuseId forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    cell.longPressCallback = ^(UILongPressGestureRecognizer * _Nonnull recognizer) {
        if (weakSelf.hasPreViewShow) {
            return;
        }
        [self showDisplayView:0 display_y:0 targetView:[UIApplication sharedApplication].keyWindow.rootViewController.view faceCell:weakCell];
    };
    int groupIndex = [_groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = _faceGroups[groupIndex];
    int itemCount = group.faces.count;

    NSNumber *index = [_itemIndexs objectForKey:indexPath];
    if (index.integerValue < group.faces.count) {
        TUIFaceCellData *data = group.faces[index.integerValue];
        [cell setData:data];
    } else {
        [cell setData:nil];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int groupIndex = [_groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *faces = _faceGroups[groupIndex];
    NSNumber *index = [_itemIndexs objectForKey:indexPath];
    if (index.integerValue < faces.faces.count) {
        if (_delegate && [_delegate respondsToSelector:@selector(faceView:didSelectItemAtIndexPath:)]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index.integerValue inSection:groupIndex];
            [_delegate faceView:self didSelectItemAtIndexPath:indexPath];
        }
    } else {
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int groupIndex = [_groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = _faceGroups[groupIndex];
    CGFloat width = (self.frame.size.width - TFaceView_Page_Padding * 2 - TFaceView_Margin * (group.itemCountPerRow - 1)) / group.itemCountPerRow;
    CGFloat height = width + TFaceView_Margin;
    return CGSizeMake(width, height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section {
    TUIFaceGroup *group = _faceGroups[section];
    if (group.groupName.length > 0) {
        return CGSizeMake(self.frame.size.width, 20);
    }
    else {
        return CGSizeMake(self.frame.size.width, 0);
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:@"headerView"
                                                                                     forIndexPath:indexPath];
    
    for (UIView *view in headerView.subviews) {
        if (view) {
            [view removeFromSuperview];
        }
    }
    UILabel *view = [[UILabel alloc]initWithFrame:CGRectMake(TFaceView_Page_Padding, 0, self.frame.size.width, 17)];
    view.font = [UIFont systemFontOfSize:12];
    view.textColor = TIMCommonDynamicColor(@"", @"#444444");
    [headerView addSubview:view];
    TUIFaceGroup *group = _faceGroups[indexPath.section];
    if (group.groupName.length > 0 ){
        view.text = group.groupName;
    }
    return headerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger curSection = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (curSection >= _groupIndexInSection.count) {
        return;
    }
    NSNumber *groupIndex = _groupIndexInSection[curSection];
    NSNumber *startSection = _sectionIndexInGroup[groupIndex.integerValue];
    if (_curGroupIndex != groupIndex.integerValue) {
        _curGroupIndex = groupIndex.integerValue;
        if (_delegate && [_delegate respondsToSelector:@selector(faceView:scrollToFaceGroupIndex:)]) {
            [_delegate faceView:self scrollToFaceGroupIndex:_curGroupIndex];
        }
    }
    
    if (scrollView == self.faceCollectionView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self adjustEmotionsAlpha];
        });
    }
}

- (void)scrollToFaceGroupIndex:(NSInteger)index {
    if (index > _sectionIndexInGroup.count) {
        return;
    }
    NSNumber *start = _sectionIndexInGroup[index];
    NSInteger curSection = ceil(_faceCollectionView.contentOffset.x / _faceCollectionView.frame.size.width);
    if (curSection > start.integerValue && curSection < start.integerValue ) {
        return;
    }
    CGRect rect =
        CGRectMake(start.integerValue * _faceCollectionView.frame.size.width, 0, _faceCollectionView.frame.size.width, _faceCollectionView.frame.size.height);
    [_faceCollectionView scrollRectToVisible:rect animated:NO];
    [self scrollViewDidScroll:_faceCollectionView];
}
#pragma mark - floatCtrlView
- (void)adjustEmotionsAlpha {
    if (self.floatCtrlView.isHidden) {
        return;
    }
    CGRect buttonGruopRect = self.floatCtrlView.frame;
    CGRect floatingRect = [self.faceCollectionView convertRect:buttonGruopRect fromView:self];
    for (UICollectionViewCell *visibleCell in self.faceCollectionView.visibleCells) {
        CGRect cellInCollection = [self.faceCollectionView convertRect:visibleCell.frame toView:self.faceCollectionView];
        BOOL ischongdie = CGRectIntersectsRect(floatingRect,cellInCollection);
        if(ischongdie){
            CGPoint emojiCenterPoint = CGPointMake(CGRectGetMidX(cellInCollection), CGRectGetMidY(cellInCollection));
            BOOL containsHalf = CGRectContainsPoint(floatingRect,emojiCenterPoint);
            if (containsHalf) {
                visibleCell.alpha = 0;
            } else {
                visibleCell.alpha = 0.5;
            }
        }
        else {
            visibleCell.alpha = 1;
        }
    }
}

- (void)setFloatCtrlViewAllowSendSwitch:(BOOL)isAllow {
    if (isAllow) {
        self.deleteButton.enabled = YES;
        self.sendButton.enabled = YES;
        self.deleteButton.alpha = 1;
        self.sendButton.alpha = 1;
    }
    else {
        self.deleteButton.enabled = NO;
        self.sendButton.enabled = NO;
        self.deleteButton.alpha = 0.5;
        self.sendButton.alpha = 0.5;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self adjustEmotionsAlpha];
    });
    
}

- (void)didSelectSendButton:(id)btn {
    if (_delegate && [_delegate respondsToSelector:@selector(faceViewClickSendMessageBtn)]) {
        [_delegate faceViewClickSendMessageBtn];
    }
}
- (void)didSelectDeleteButton:(id)btn {
    if (_delegate && [_delegate respondsToSelector:@selector(faceViewDidBackDelete:)]) {
        [_delegate faceViewDidBackDelete:(id)self];
    }
}

- (void)showDisplayView:(CGFloat)display_x
              display_y:(CGFloat)display_y
             targetView:(UIView *)targetView
               faceCell: (TUIFaceCell *)faceCell{
        
    self.hasPreViewShow = YES;

    UIViewController *contentViewController = [[UIViewController alloc] init];
    [contentViewController.view addSubview:self.dispalyView];
    self.dispalyImage.image = (faceCell.gifImage?:faceCell.face.image);
    CGFloat dispalyImagex = 5;
    CGFloat dispalyImagey = 5;
    CGFloat dispalyImagew = MIN(faceCell.face.image.size.width, 150)  ;
    CGFloat dispalyImagewh =  MIN(faceCell.face.image.size.height, 150);

    self.dispalyView.frame = CGRectMake(display_x, display_y, dispalyImagew + 10, dispalyImagewh + 10);
    _dispalyImage.frame = CGRectMake(dispalyImagex, dispalyImagey, dispalyImagewh, dispalyImagewh);

    contentViewController.view.backgroundColor = [UIColor clearColor
    ];
    contentViewController.preferredContentSize = CGSizeMake(self.dispalyView.frame.size.width, self.dispalyView.frame.size.height);
    contentViewController.modalPresentationStyle = UIModalPresentationPopover;

    UIPopoverPresentationController *popoverController = contentViewController.popoverPresentationController;
    
    popoverController.sourceView = self;
    popoverController.sourceRect = CGRectMake(0, -10, self.frame.size.width, 0);
    popoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    popoverController.delegate = self;
    popoverController.canOverlapSourceViewRect = NO;
    [self.mm_viewController presentViewController:contentViewController animated:YES completion:nil];
    popoverController.backgroundColor = [UIColor whiteColor];

}
- (UIImageView *)dispalyView {
    if (!_dispalyView) {
        _dispalyView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
        _dispalyView.contentMode = UIViewContentModeScaleToFill;
        _dispalyView.backgroundColor = [UIColor whiteColor];
        [_dispalyView addSubview:self.dispalyImage];
    }
    return _dispalyView;
    
}
- (UIImageView *)dispalyImage {
    if (!_dispalyImage) {
        _dispalyImage = [[UIImageView alloc] init];
    }
    return _dispalyImage;
}
#pragma mark - UIPopoverPresentationControllerDelegate

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
    self.hasPreViewShow = NO;
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}
@end
