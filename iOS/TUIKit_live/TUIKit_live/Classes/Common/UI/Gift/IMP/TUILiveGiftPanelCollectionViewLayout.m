//
//  TUILiveGiftCollectionViewFlowLayout.m
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import "TUILiveGiftPanelCollectionViewLayout.h"

@interface TUILiveGiftPanelCollectionViewLayout ()

@property (nonatomic, strong) NSMutableArray *attributesArrayM;

@end

@implementation TUILiveGiftPanelCollectionViewLayout

- (void)prepareLayout
{
    [super prepareLayout];
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attributesArrayM addObject:attributes];
    }
}

- (CGSize)collectionViewContentSize
{
    // 获取item宽度和总个数
    CGFloat itemWidth = self.itemSize.width;
    NSInteger totals = [self.collectionView numberOfItemsInSection:0];
    
    // 理论上每页的个数
    NSInteger pageCount = self.rows * self.columns;
    
    // 页数
    NSInteger pages = totals / pageCount;
    NSInteger remain = totals % pageCount;
    if (totals <= pageCount) {
        pages = 1;
    }else {
        if (remain != 0) {
            pages = pages + 1;
        }
    }
    NSLog(@"总个数: %zd, 理论上每页的个数: %zd, 最后一页的个数: %zd, 页数:%zd", totals, pageCount, remain, pages);
    
    // 计算水平宽度
    CGFloat width = pages * self.columns * itemWidth;
    return CGSizeMake(width, 0);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // item的宽高
    CGFloat itemWidth = self.itemSize.width;
    CGFloat itemHeight = self.itemSize.height;
    
    // 计算当前item所在的页
    NSInteger pageIndex = indexPath.item / (self.rows * self.columns);
    NSInteger x = indexPath.item % self.columns + pageIndex * self.columns;
    NSInteger y = indexPath.item / self.columns - pageIndex * self.rows;
    
    // 计算item的坐标
    CGFloat itemX = itemWidth * x;
    CGFloat itemY = itemHeight * y;
    
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    attributes.frame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
    NSLog(@"计算的结果: %@, %@", indexPath, NSStringFromCGRect(attributes.frame));
    return attributes;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attributesArrayM;
}


- (NSMutableArray *)attributesArrayM
{
    if (_attributesArrayM == nil) {
        _attributesArrayM = [NSMutableArray array];
    }
    return _attributesArrayM;
}


@end
