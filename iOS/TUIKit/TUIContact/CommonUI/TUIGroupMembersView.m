//
//  TUIGroupMembersView.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/11.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIGroupMembersView.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIGlobalization.h>

@interface TUIGroupMembersView () <UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property(nonatomic, strong) NSMutableArray<TUIGroupMemberCellData *> *data;
@end

@implementation TUIGroupMembersView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [UIColor whiteColor];
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.headerReferenceSize = CGSizeMake(self.frame.size.width, TGroupMembersController_Margin);
    CGSize cellSize = [TUIGroupMemberCell getSize];

    CGFloat y = _searchBar.frame.origin.y + _searchBar.frame.size.height;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(TGroupMembersController_Margin, y,
                                                                         self.frame.size.width - 2 * TGroupMembersController_Margin, self.frame.size.height - y)
                                         collectionViewLayout:_flowLayout];
    [_collectionView registerClass:[TUIGroupMemberCell class] forCellWithReuseIdentifier:TGroupMemberCell_ReuseId];
    _collectionView.collectionViewLayout = _flowLayout;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, TMessageController_Header_Height, 0);
    [self addSubview:_collectionView];

    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.hidesWhenStopped = YES;
    [self.collectionView addSubview:_indicatorView];

    _flowLayout.minimumLineSpacing =
        (_collectionView.frame.size.width - cellSize.width * TGroupMembersController_Row_Count) / (TGroupMembersController_Row_Count - 1);
    ;
    _flowLayout.minimumInteritemSpacing = _flowLayout.minimumLineSpacing;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIGroupMemberCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TGroupMemberCell_ReuseId forIndexPath:indexPath];
    TUIGroupMemberCellData *data = _data[indexPath.row];
    [cell setData:data];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [TUIGroupMemberCell getSize];
}

#pragma mark - Load
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 0 && (scrollView.contentOffset.y >= scrollView.bounds.origin.y)) {
        [self loadMoreData];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    UIButton *cancleBtn = [searchBar valueForKey:@"cancelButton"];
    [cancleBtn setTitle:TIMCommonLocalizableString(Cancel) forState:UIControlStateNormal];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    [self reloadData];
}

- (void)setData:(NSMutableArray<TUIGroupMemberCellData *> *)data {
    _data = data;
    [self reloadData];
}

- (void)reloadData {
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    self.indicatorView.frame = CGRectMake(0, self.collectionView.contentSize.height, self.collectionView.bounds.size.width, TMessageController_Header_Height);
    if (self.collectionView.contentSize.height > self.collectionView.frame.size.height) {
        [self.indicatorView startAnimating];
    } else {
        [self.indicatorView stopAnimating];
    }
}

- (void)loadMoreData {
    if (![self.delegate respondsToSelector:@selector(groupMembersView:didLoadMoreData:)]) {
        CGPoint point = self.collectionView.contentOffset;
        point.y -= TMessageController_Header_Height;
        [self.collectionView setContentOffset:point animated:YES];
        return;
    }

    static BOOL isLoading = NO;
    if (isLoading) {
        return;
    }
    isLoading = YES;
    __weak typeof(self) weakSelf = self;
    [self.delegate groupMembersView:self
                    didLoadMoreData:^(NSArray<TUIGroupMemberCellData *> *moreData) {
                      isLoading = NO;
                      [weakSelf.data addObjectsFromArray:moreData];
                      CGPoint point = self.collectionView.contentOffset;
                      point.y -= TMessageController_Header_Height;
                      [weakSelf.collectionView setContentOffset:point animated:YES];
                      [weakSelf reloadData];
                    }];
}

@end
