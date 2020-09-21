//
//  TUIMoreView.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/21.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIMoreView.h"
#import "TUIInputMoreCell.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"

@interface TUIMoreView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSMutableDictionary *itemIndexs;
@property (nonatomic, assign) NSInteger sectionCount;
@property (nonatomic, assign) NSInteger itemsInSection;
@property (nonatomic, assign) NSInteger rowCount;
@end

@implementation TUIMoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor d_colorWithColorLight:TInput_Background_Color dark:TInput_Background_Color_Dark];

    _moreFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _moreFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _moreFlowLayout.minimumLineSpacing = 0;
    _moreFlowLayout.minimumInteritemSpacing = 0;
    _moreFlowLayout.sectionInset = UIEdgeInsetsMake(0, TMoreView_Section_Padding, 0, TMoreView_Section_Padding);

    _moreCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_moreFlowLayout];
    [_moreCollectionView registerClass:[TUIInputMoreCell class] forCellWithReuseIdentifier:TMoreCell_ReuseId];
    _moreCollectionView.collectionViewLayout = _moreFlowLayout;
    _moreCollectionView.pagingEnabled = YES;
    _moreCollectionView.delegate = self;
    _moreCollectionView.dataSource = self;
    _moreCollectionView.showsHorizontalScrollIndicator = NO;
    _moreCollectionView.showsVerticalScrollIndicator = NO;
    _moreCollectionView.backgroundColor = self.backgroundColor;
    _moreCollectionView.alwaysBounceHorizontal = YES;
    [self addSubview:_moreCollectionView];

    _lineView = [[UIView alloc] init];
    _lineView.backgroundColor =  [UIColor d_colorWithColorLight:TLine_Color dark:TLine_Color_Dark];
    [self addSubview:_lineView];

    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPageIndicatorTintColor = [UIColor d_colorWithColorLight:TPage_Current_Color dark:TPage_Current_Color_Dark];
    _pageControl.pageIndicatorTintColor = [UIColor d_colorWithColorLight:TPage_Color dark:TPage_Color_Dark];;
    [self addSubview:_pageControl];
}

- (void)defaultLayout
{
    CGSize cellSize = [TUIInputMoreCell getSize];
    CGFloat collectionHeight = cellSize.height * _rowCount + TMoreView_Margin * (_rowCount - 1);

    _lineView.frame = CGRectMake(0, 0, self.frame.size.width, TLine_Heigh);
    _moreCollectionView.frame = CGRectMake(0, _lineView.frame.origin.y + _lineView.frame.size.height + TMoreView_Margin, self.frame.size.width, collectionHeight);

    if(_sectionCount > 1){
        _pageControl.frame = CGRectMake(0, _moreCollectionView.frame.origin.y + _moreCollectionView.frame.size.height, self.frame.size.width, TMoreView_Page_Height);
        _pageControl.hidden = NO;
    }
    else{
        _pageControl.hidden = YES;
    }
    if(_rowCount > 1){
        _moreFlowLayout.minimumInteritemSpacing = (_moreCollectionView.frame.size.height - cellSize.height * _rowCount) / (_rowCount - 1);
    }
    _moreFlowLayout.minimumLineSpacing = (_moreCollectionView.frame.size.width - cellSize.width * TMoreView_Column_Count - 2 * TMoreView_Section_Padding) / (TMoreView_Column_Count - 1);


    CGFloat height = _moreCollectionView.frame.origin.y + _moreCollectionView.frame.size.height + TMoreView_Margin;
    if(_sectionCount > 1){
        height = _pageControl.frame.origin.y + _pageControl.frame.size.height;
    }
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setData:(NSArray *)data
{
    _data = data;

    if(_data.count > TMoreView_Column_Count){
        _rowCount = 2;
    }
    else{
        _rowCount = 1;
    }
    _itemsInSection = TMoreView_Column_Count * _rowCount;
    _sectionCount = ceil(_data.count * 1.0 / _itemsInSection);
    _pageControl.numberOfPages = _sectionCount;

    _itemIndexs = [NSMutableDictionary dictionary];
    for (NSInteger curSection = 0; curSection < _sectionCount; ++curSection) {
        for (NSInteger itemIndex = 0; itemIndex < _itemsInSection; ++itemIndex) {
            // transpose line/row
            NSInteger row = itemIndex % _rowCount;
            NSInteger column = itemIndex / _rowCount;
            NSInteger reIndex = TMoreView_Column_Count * row + column + curSection * _itemsInSection;
            [_itemIndexs setObject:@(reIndex) forKey:[NSIndexPath indexPathForRow:itemIndex inSection:curSection]];
        }
    }

    [_moreCollectionView reloadData];

    [self defaultLayout];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _sectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _itemsInSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TUIInputMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TMoreCell_ReuseId forIndexPath:indexPath];
    TUIInputMoreCellData *data;
    NSNumber *index = _itemIndexs[indexPath];
    if(index.integerValue >= _data.count){
        data = nil;
    }
    else{
        data = _data[index.integerValue];
    }
    [cell fillWithData:data];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell =[collectionView cellForItemAtIndexPath:indexPath];

    if(_delegate && [_delegate respondsToSelector:@selector(moreView:didSelectMoreCell:)]){
        if ([cell isKindOfClass:[TUIInputMoreCell class]]) {
            [_delegate moreView:self didSelectMoreCell:(TUIInputMoreCell *)cell];;
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [TUIInputMoreCell getSize];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentOffset = scrollView.contentOffset.x;
    float page = contentOffset / scrollView.frame.size.width;
    if((int)(page * 10) % 10 == 0){
        _pageControl.currentPage = page;
    }
}

@end
