//
//  TUIGroupMembersCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIGroupMembersCell.h"
#import "TUIGroupMemberCell.h"
#import "THeader.h"
#import "UIColor+TUIDarkMode.h"

@implementation TGroupMembersCellData
@end


@interface TUIGroupMembersCell () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@end


@implementation TUIGroupMembersCell
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
    self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
    _memberFlowLayout = [[UICollectionViewFlowLayout alloc] init];
//    _memberFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    CGSize cellSize = [TUIGroupMemberCell getSize];
    _memberFlowLayout.itemSize = cellSize;
    _memberFlowLayout.minimumInteritemSpacing = (Screen_Width - cellSize.width * TGroupMembersCell_Column_Count - 2*TGroupMembersCell_Margin) / (TGroupMembersCell_Column_Count - 1);
    _memberFlowLayout.minimumLineSpacing = TGroupMembersCell_Margin;
    _memberFlowLayout.sectionInset = UIEdgeInsetsMake(TGroupMembersCell_Margin, TGroupMembersCell_Margin, TGroupMembersCell_Margin, TGroupMembersCell_Margin);

    _memberCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_memberFlowLayout];
    [_memberCollectionView registerClass:[TUIGroupMemberCell class] forCellWithReuseIdentifier:TGroupMemberCell_ReuseId];
    _memberCollectionView.collectionViewLayout = _memberFlowLayout;
    _memberCollectionView.delegate = self;
    _memberCollectionView.dataSource = self;
    _memberCollectionView.showsHorizontalScrollIndicator = NO;
    _memberCollectionView.showsVerticalScrollIndicator = NO;
    _memberCollectionView.backgroundColor = self.backgroundColor;
    [self.contentView addSubview:_memberCollectionView];
    [self setSeparatorInset:UIEdgeInsetsMake(0, TGroupMembersCell_Margin, 0, 0)];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)updateLayout
{
    CGFloat height = [TUIGroupMembersCell getHeight:_data];
    _memberCollectionView.frame = CGRectMake(0, 0, Screen_Width, height);
}

- (void)setData:(TGroupMembersCellData *)data
{
    _data = data;

    [self updateLayout];
    [_memberCollectionView reloadData];
}

+ (CGFloat)getHeight:(TGroupMembersCellData *)data{
    NSInteger row = ceil(data.members.count * 1.0 / TGroupMembersCell_Column_Count);
    if(row > TGroupMembersCell_Row_Count){
        row = TGroupMembersCell_Row_Count;
    }
    CGFloat height = row * [TUIGroupMemberCell getSize].height + (row + 1) * TGroupMembersCell_Margin;
    return height;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _data.members.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TUIGroupMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TGroupMemberCell_ReuseId forIndexPath:indexPath];
    TGroupMemberCellData *data = nil;
    data = _data.members[indexPath.item];
    [cell setData:data];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(_delegate && [_delegate respondsToSelector:@selector(groupMembersCell:didSelectItemAtIndex:)]){
        [_delegate groupMembersCell:self didSelectItemAtIndex:indexPath.section * TGroupMembersCell_Column_Count + indexPath.row];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [TUIGroupMemberCell getSize];
}
@end
