//
//  TUICallingGroupDelegateManager.m
//  TUICalling
//
//  Created by noah on 2021/8/23.
//  Copyright © 2021 Tencent. All rights reserved
//

#import "TUICallingGroupDelegateManager.h"
#import "TUICallingGroupCell.h"
#import "TUICallEngineHeader.h"
#import "TUICallingUserModel.h"

@interface TUICallingGroupDelegateManager()

@property (nonatomic, copy) NSArray <CallingUserModel *> *listDate;

@end

@implementation TUICallingGroupDelegateManager

- (void)reloadCallingGroupWithModel:(NSArray<CallingUserModel *> *)models {
    self.listDate = models;
}

- (__kindof TUIVideoView *)getRenderViewFromUser:(NSString *)userId {
    __block NSInteger index = -1;
    [self.listDate enumerateObjectsUsingBlock:^(CallingUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:userId]) {
            index = idx;
            *stop = YES;
        }
    }];
    if (index >= 0) {
        TUICallingGroupCell *cell = (TUICallingGroupCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index
                                                                                                                           inSection:0]];
        return cell.renderView;
    }
    return nil;
}

- (void)reloadGroupCellWithIndex:(NSInteger)index {
    if (index >= 0 && (self.listDate.count > index)) {
        TUICallingGroupCell *cell = (TUICallingGroupCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index
                                                                                                                           inSection:0]];
        cell.model = self.listDate[index];
    }
}


#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listDate.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = [NSString stringWithFormat:@"TUICallingGroupCell_%d", (int)indexPath.item];
    TUICallingGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                          forIndexPath:indexPath];
    CallingUserModel *model = self.listDate[indexPath.item];
    cell.model = model;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat side = collectionView.bounds.size.width / 2.0 - 0.5;
    if (self.listDate.count >= 5) {
        side = collectionView.bounds.size.width / 3.0 - 0.5;
    }
    return CGSizeMake(side, side);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 0.1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, 0.1);
}

@end
