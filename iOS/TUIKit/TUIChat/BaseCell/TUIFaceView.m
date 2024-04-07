//
//  TUIFaceView.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIFaceView.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@interface TUIFaceView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) NSMutableArray *sectionIndexInGroup;
@property(nonatomic, strong) NSMutableArray *pageCountInGroup;
@property(nonatomic, strong) NSMutableArray *groupIndexInSection;
@property(nonatomic, strong) NSMutableDictionary *itemIndexs;
@property(nonatomic, assign) NSInteger sectionCount;
@property(nonatomic, assign) NSInteger curGroupIndex;
@end

@implementation TUIFaceView

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
    _faceFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _faceFlowLayout.minimumLineSpacing = TFaceView_Margin;
    _faceFlowLayout.minimumInteritemSpacing = TFaceView_Margin;
    _faceFlowLayout.sectionInset = UIEdgeInsetsMake(0, TFaceView_Page_Padding, 0, TFaceView_Page_Padding);

    _faceCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_faceFlowLayout];
    [_faceCollectionView registerClass:[TUIFaceCell class] forCellWithReuseIdentifier:TFaceCell_ReuseId];
    _faceCollectionView.collectionViewLayout = _faceFlowLayout;
    _faceCollectionView.pagingEnabled = YES;
    _faceCollectionView.delegate = self;
    _faceCollectionView.dataSource = self;
    _faceCollectionView.showsHorizontalScrollIndicator = NO;
    _faceCollectionView.showsVerticalScrollIndicator = NO;
    _faceCollectionView.backgroundColor = self.backgroundColor;
    _faceCollectionView.alwaysBounceHorizontal = YES;
    [self addSubview:_faceCollectionView];

    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor = TIMCommonDynamicColor(@"separator_color", @"#DBDBDB");

    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPageIndicatorTintColor = TUIChatDynamicColor(@"chat_face_page_control_current_color", @"#7D7D7D");
    _pageControl.pageIndicatorTintColor = TUIChatDynamicColor(@"chat_face_page_control_color", @"#DEDEDE");
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self defaultLayout];
}

- (void)defaultLayout {
    _lineView.frame = CGRectMake(0, 0, self.frame.size.width, TLine_Heigh);
    _pageControl.frame = CGRectMake(0, self.frame.size.height - TFaceView_Page_Height, self.frame.size.width, TFaceView_Page_Height);
    _faceCollectionView.frame = CGRectMake(0, _lineView.frame.origin.y + _lineView.frame.size.height + TFaceView_Margin, self.frame.size.width,
                                           self.frame.size.height - _pageControl.frame.size.height - _lineView.frame.size.height - 2 * TFaceView_Margin);
}

- (void)setData:(NSMutableArray *)data {
    _faceGroups = data;
    [self defaultLayout];

    _sectionIndexInGroup = [NSMutableArray array];
    _groupIndexInSection = [NSMutableArray array];
    _itemIndexs = [NSMutableDictionary dictionary];
    _pageCountInGroup = [NSMutableArray array];

    NSInteger sectionIndex = 0;
    for (NSInteger groupIndex = 0; groupIndex < _faceGroups.count; ++groupIndex) {
        TUIFaceGroup *group = _faceGroups[groupIndex];
        [_sectionIndexInGroup addObject:@(sectionIndex)];
        int itemCount = group.rowCount * group.itemCountPerRow;
        int sectionCount = ceil(group.faces.count * 1.0 / (itemCount - (group.needBackDelete ? 1 : 0)));
        [_pageCountInGroup addObject:@(sectionCount)];
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
        NSInteger itemCount = face.rowCount * face.itemCountPerRow - face.needBackDelete;
        NSInteger groupSection = curSection - groupSectionIndex.integerValue;
        for (NSInteger itemIndex = 0; itemIndex < itemCount; ++itemIndex) {
            // transpose line/row
            NSInteger row = itemIndex % face.rowCount;
            NSInteger column = itemIndex / face.rowCount;
            NSInteger reIndex = face.itemCountPerRow * row + column + groupSection * itemCount;
            [_itemIndexs setObject:@(reIndex) forKey:[NSIndexPath indexPathForRow:itemIndex inSection:curSection]];
        }
    }

    _curGroupIndex = 0;
    if (_pageCountInGroup.count != 0) {
        _pageControl.numberOfPages = [_pageCountInGroup[0] intValue];
    }
    [_faceCollectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _sectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int groupIndex = [_groupIndexInSection[section] intValue];
    TUIFaceGroup *group = _faceGroups[groupIndex];
    return group.rowCount * group.itemCountPerRow;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TFaceCell_ReuseId forIndexPath:indexPath];
    int groupIndex = [_groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = _faceGroups[groupIndex];
    int itemCount = group.rowCount * group.itemCountPerRow;
    if (indexPath.row == itemCount - 1 && group.needBackDelete) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        data.path = TUIChatFaceImagePath(@"del_normal");
        [cell setData:data];
        cell.face.image  = [cell.face.image rtl_imageFlippedForRightToLeftLayoutDirection];
    } else {
        NSNumber *index = [_itemIndexs objectForKey:indexPath];
        if (index.integerValue < group.faces.count) {
            TUIFaceCellData *data = group.faces[index.integerValue];
            [cell setData:data];
        } else {
            [cell setData:nil];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int groupIndex = [_groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *faces = _faceGroups[groupIndex];
    int itemCount = faces.rowCount * faces.itemCountPerRow;
    if (indexPath.row == itemCount - 1 && faces.needBackDelete) {
        if (_delegate && [_delegate respondsToSelector:@selector(faceViewDidBackDelete:)]) {
            [_delegate faceViewDidBackDelete:self];
        }
    } else {
        NSNumber *index = [_itemIndexs objectForKey:indexPath];
        if (index.integerValue < faces.faces.count) {
            if (_delegate && [_delegate respondsToSelector:@selector(faceView:didSelectItemAtIndexPath:)]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index.integerValue inSection:groupIndex];
                [_delegate faceView:self didSelectItemAtIndexPath:indexPath];
            }
        } else {
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int groupIndex = [_groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = _faceGroups[groupIndex];
    CGFloat width = (self.frame.size.width - TFaceView_Page_Padding * 2 - TFaceView_Margin * (group.itemCountPerRow - 1)) / group.itemCountPerRow;
    CGFloat height = (collectionView.frame.size.height - TFaceView_Margin * (group.rowCount - 1)) / group.rowCount;
    return CGSizeMake(width, height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger curSection = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    if (curSection >= _groupIndexInSection.count) {
        return;
    }
    NSNumber *groupIndex = _groupIndexInSection[curSection];
    NSNumber *startSection = _sectionIndexInGroup[groupIndex.integerValue];
    NSNumber *pageCount = _pageCountInGroup[groupIndex.integerValue];
    if (_curGroupIndex != groupIndex.integerValue) {
        _curGroupIndex = groupIndex.integerValue;
        _pageControl.numberOfPages = pageCount.integerValue;
        if (_delegate && [_delegate respondsToSelector:@selector(faceView:scrollToFaceGroupIndex:)]) {
            [_delegate faceView:self scrollToFaceGroupIndex:_curGroupIndex];
        }
    }
    _pageControl.currentPage = curSection - startSection.integerValue;
}

- (void)scrollToFaceGroupIndex:(NSInteger)index {
    if (index > _sectionIndexInGroup.count) {
        return;
    }
    NSNumber *start = _sectionIndexInGroup[index];
    NSNumber *count = _pageCountInGroup[index];
    NSInteger curSection = ceil(_faceCollectionView.contentOffset.x / _faceCollectionView.frame.size.width);
    if (curSection > start.integerValue && curSection < start.integerValue + count.integerValue) {
        return;
    }
    CGRect rect =
        CGRectMake(start.integerValue * _faceCollectionView.frame.size.width, 0, _faceCollectionView.frame.size.width, _faceCollectionView.frame.size.height);
    [_faceCollectionView scrollRectToVisible:rect animated:NO];
    [self scrollViewDidScroll:_faceCollectionView];
}
@end
