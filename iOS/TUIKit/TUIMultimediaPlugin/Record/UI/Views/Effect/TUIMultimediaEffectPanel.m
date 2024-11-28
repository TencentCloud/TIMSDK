// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaEffectPanel.h"
#import <Masonry/Masonry.h>
#import "TUIMultimediaEffectCell.h"
#import "TUIMultimediaPlugin/TUIMultimediaBeautifySettings.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"

static const CGSize EffectItemSize = TUIMultimediaConstCGSize(60, 86);

@interface TUIMultimediaEffectPanel () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    NSArray<TUIMultimediaEffectItem *> *_items;
    UICollectionView *_collectionView;
}
@end

@implementation TUIMultimediaEffectPanel
@dynamic items;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _selectedIndex = -1;
        _items = @[];
        [self initUI];
    }
    return self;
}

- (void)initUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 10;
    layout.itemSize = EffectItemSize;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:TUIMultimediaEffectCell.class forCellWithReuseIdentifier:TUIMultimediaEffectCell.reuseIdentifier];
    [self addSubview:_collectionView];

    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, EffectItemSize.height /* + self.safeAreaInsets.bottom*/);
}

#pragma mark - Properties
- (NSArray<TUIMultimediaEffectItem *> *)items {
    return _items;
}
- (void)setItems:(NSArray<TUIMultimediaEffectItem *> *)value {
    _items = value;
    _selectedIndex = -1;
    [_collectionView reloadData];
}
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [_collectionView reloadData];
}
- (void)setIconSize:(CGSize)iconSize {
    _iconSize = iconSize;
    [_collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout protocol

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIMultimediaEffectCell *cell = (TUIMultimediaEffectCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TUIMultimediaEffectCell.reuseIdentifier
                                                                                           forIndexPath:indexPath];
    cell.image = _items[indexPath.item].iconImage;
    cell.text = _items[indexPath.item].name;
    cell.effectSelected = (indexPath.item == _selectedIndex);
    cell.iconSize = _iconSize;
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _items.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 立刻反选此cell，不使用CollectionView自带的选中逻辑
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    _selectedIndex = indexPath.item;
    [collectionView reloadData];

    [_delegate effectPanelSelectionChanged:self];
}

@end
