//
//  TGroupMembersCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TGroupMembersCell.h"
#import "TGroupMemberCell.h"
#import "THeader.h"

@implementation TGroupMembersCellData
@end


@interface TGroupMembersCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) TGroupMembersCellData *data;
@property (nonatomic, strong) NSMutableDictionary *itemIndexs;
@end


@implementation TGroupMembersCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    
    _memberFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    _memberFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _memberFlowLayout.minimumLineSpacing = 0;
    _memberFlowLayout.minimumInteritemSpacing = 0;
    
    _memberCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_memberFlowLayout];
    [_memberCollectionView registerClass:[TGroupMemberCell class] forCellWithReuseIdentifier:TGroupMemberCell_ReuseId];
    _memberCollectionView.collectionViewLayout = _memberFlowLayout;
    _memberCollectionView.delegate = self;
    _memberCollectionView.dataSource = self;
    _memberCollectionView.showsHorizontalScrollIndicator = NO;
    _memberCollectionView.showsVerticalScrollIndicator = NO;
    _memberCollectionView.backgroundColor = self.backgroundColor;
    [self addSubview:_memberCollectionView];
    [self setSeparatorInset:UIEdgeInsetsMake(0, TGroupMembersCell_Margin, 0, 0)];
}

- (void)updateLayout
{
    CGFloat height = [TGroupMembersCell getHeight:_data];
    _memberCollectionView.frame = CGRectMake(TGroupMembersCell_Margin, TGroupMembersCell_Margin, Screen_Width - 2 * TGroupMembersCell_Margin, height - 2 * TGroupMembersCell_Margin);
    CGSize cellSize = [TGroupMemberCell getSize];
    _memberFlowLayout.minimumInteritemSpacing = (_memberCollectionView.frame.size.height - cellSize.height * TGroupMembersCell_Row_Count) / (TGroupMembersCell_Row_Count - 1);
    _memberFlowLayout.minimumLineSpacing = (_memberCollectionView.frame.size.width - cellSize.width * TGroupMembersCell_Column_Count) / (TGroupMembersCell_Column_Count - 1);
}

- (void)setData:(TGroupMembersCellData *)data
{
    _data = data;
    
    NSInteger rowCount = ceil(_data.members.count * 1.0 / TGroupMembersCell_Column_Count);
    if(rowCount > TGroupMembersCell_Row_Count){
        rowCount = TGroupMembersCell_Row_Count;
    }
    NSInteger itemCount = TGroupMembersCell_Column_Count * rowCount;

    _itemIndexs = [NSMutableDictionary dictionary];
    for (NSInteger itemIndex = 0; itemIndex < itemCount; ++itemIndex) {
        // transpose line/row
        NSInteger row = itemIndex % rowCount;
        NSInteger column = itemIndex / rowCount;
        NSInteger reIndex = TGroupMembersCell_Column_Count * row + column;
        [_itemIndexs setObject:@(reIndex) forKey:[NSIndexPath indexPathForRow:itemIndex inSection:0]];
    }
    
    [self updateLayout];
    [_memberCollectionView reloadData];
}

+ (CGFloat)getHeight:(TGroupMembersCellData *)data{
    NSInteger row = ceil(data.members.count * 1.0 / TGroupMembersCell_Column_Count);
    if(row > TGroupMembersCell_Row_Count){
        row = TGroupMembersCell_Row_Count;
    }
    CGFloat height = row * [TGroupMemberCell getSize].height + (row + 1) * TGroupMembersCell_Margin;
    return height;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger rowCount = ceil(_data.members.count * 1.0 / TGroupMembersCell_Column_Count);
    if(rowCount > TGroupMembersCell_Row_Count){
        rowCount = TGroupMembersCell_Row_Count;
    }
    return TGroupMembersCell_Column_Count * rowCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGroupMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TGroupMemberCell_ReuseId forIndexPath:indexPath];
    TGroupMemberCellData *data = nil;
    NSNumber *index = _itemIndexs[indexPath];
    if(index.integerValue < _data.members.count){
        data = _data.members[index.integerValue];
    }
    [cell setData:data];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *index = _itemIndexs[indexPath];
    if(index.integerValue < _data.members.count){
        if(_delegate && [_delegate respondsToSelector:@selector(groupMembersCell:didSelectItemAtIndex:)]){
            [_delegate groupMembersCell:self didSelectItemAtIndex:index.integerValue];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [TGroupMemberCell getSize];
}
@end
