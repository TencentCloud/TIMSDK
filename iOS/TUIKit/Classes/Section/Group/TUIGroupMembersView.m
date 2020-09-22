//
//  TUIGroupMembersView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/11.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIGroupMembersView.h"
#import "THeader.h"

@interface TUIGroupMembersView () <UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray *data;
@end

@implementation TUIGroupMembersView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    self.backgroundColor = [UIColor whiteColor];
    /*
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, SearchBar_Height)];
    _searchBar.placeholder = @"搜索";
    _searchBar.backgroundImage = [UIImage new];
    _searchBar.backgroundColor = TGroupMembersController_Background_Color;
    _searchBar.delegate = self;
    [self addSubview:_searchBar];
    */
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.headerReferenceSize = CGSizeMake(self.frame.size.width, TGroupMembersController_Margin);
    CGSize cellSize = [TUIGroupMemberCell getSize];

    CGFloat y = _searchBar.frame.origin.y + _searchBar.frame.size.height;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(TGroupMembersController_Margin, y, self.frame.size.width - 2 * TGroupMembersController_Margin, self.frame.size.height - y) collectionViewLayout:_flowLayout];
    [_collectionView registerClass:[TUIGroupMemberCell class] forCellWithReuseIdentifier:TGroupMemberCell_ReuseId];
    _collectionView.collectionViewLayout = _flowLayout;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    [self addSubview:_collectionView];

    _flowLayout.minimumLineSpacing = (_collectionView.frame.size.width - cellSize.width * TGroupMembersController_Row_Count) / (TGroupMembersController_Row_Count - 1);;
    _flowLayout.minimumInteritemSpacing = _flowLayout.minimumLineSpacing;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TUIGroupMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TGroupMemberCell_ReuseId forIndexPath:indexPath];
    TGroupMemberCellData *data = _data[indexPath.row];
    [cell setData:data];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [TUIGroupMemberCell getSize];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
    UIButton *cancleBtn = [searchBar valueForKey:@"cancelButton"];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    [_collectionView reloadData];
}

- (void)setData:(NSMutableArray *)data
{
    _data = data;
    [_collectionView reloadData];
}
@end
