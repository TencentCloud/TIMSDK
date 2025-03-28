// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaColorPanel.h"
#import <Masonry/Masonry.h>
#import "TUIMultimediaPlugin/TUIMultimediaColorCell.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaGeometry.h"

const static CGFloat CellMargin = 4;

@interface TUIMultimediaColorPanel () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    UICollectionView *_collectionView;
    NSInteger _selectIndex;
}

@end

@implementation TUIMultimediaColorPanel
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _colorList = @[
            UIColor.whiteColor,
            UIColor.blackColor,
            UIColor.grayColor,
            UIColor.redColor,
            UIColor.greenColor,
            UIColor.blueColor,
            UIColor.cyanColor,
            UIColor.yellowColor,
            UIColor.magentaColor,
            UIColor.orangeColor,
            UIColor.purpleColor,
            UIColor.brownColor,
        ];
        [self initUI];
    }
    return self;
}

- (void)initUI {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 2;

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = UIColor.clearColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:TUIMultimediaColorCell.class forCellWithReuseIdentifier:TUIMultimediaColorCell.reuseIdentifier];
    [self addSubview:_collectionView];

    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
      make.edges.equalTo(self);
    }];
}

#pragma mark - UICollectionViewDataSource protocol
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TUIMultimediaColorCell *cell = (TUIMultimediaColorCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TUIMultimediaColorCell.reuseIdentifier forIndexPath:indexPath];
    cell.color = _colorList[indexPath.item];
    cell.colorSelected = indexPath.item == _selectIndex;
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _colorList.count;
}

#pragma mark - UICollectionViewDelegateFlowLayout protocol
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    _selectIndex = indexPath.item;
    [_collectionView reloadData];

    UIColor *c = _colorList[indexPath.item];
    [_delegate onColorPanel:self selectColor:c];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)index {
    CGFloat len = collectionView.bounds.size.height - CellMargin;
    return CGSizeMake(len, len);
}

#pragma mark - Setters
- (void)setColorList:(NSArray<UIColor *> *)colorList {
    _colorList = colorList;
    _selectIndex = 0;
    if (_colorList.count > 0) {
        [_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndex:0]].selected = YES;
    }
    [_collectionView reloadData];
}

- (UIColor *)selectedColor {
    if (_selectIndex < 0 || _selectIndex >= _colorList.count) {
        return nil;
    }
    return _colorList[_selectIndex];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    if (selectedColor == nil) {
        _selectIndex = -1;
    } else {
        for (int i = 0; i < _colorList.count; i++) {
            if ([_colorList[i] isEqual:selectedColor]) {
                _selectIndex = i;
                break;
            }
        }
    }
    [_collectionView reloadData];
}
@end
