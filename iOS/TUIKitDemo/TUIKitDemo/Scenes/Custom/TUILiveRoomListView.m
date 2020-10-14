//
//  TUILiveRoomListView.m
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/9.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import "TUILiveRoomListView.h"
#import "TUILiveRoomListCell.h"
#import "TUILiveRoomInfo.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import "TUILiveRoomInfo.h"

@interface TUILiveRoomListView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, assign)CGFloat scrollviewBaseContentOffsetY;
@property(nonatomic, strong)UICollectionView *roomListCollection;

@end

@implementation TUILiveRoomListView{
    BOOL _isVewReady;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
         [self bindInteraction];
    }
    return self;
}

- (UICollectionView *)roomListCollection {
    if (!_roomListCollection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 40.0 - 5.0) / 2.0;
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        layout.minimumLineSpacing = 5.0;
        layout.minimumInteritemSpacing = 5.0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 80, 20);
        _roomListCollection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_roomListCollection registerClass:[TUILiveRoomListCell class] forCellWithReuseIdentifier:@"TUILiveRoomListCell"];
        _roomListCollection.backgroundColor = UIColor.clearColor;
        _roomListCollection.bounces = YES;
    }
    return _roomListCollection;
}

#pragma mark - 视图生命周期
- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (_isVewReady) {
        return;
    }
    [self constructViewHierarchy];
    [self layoutUI];
    _isVewReady = YES;
}

- (void)constructViewHierarchy {
    [self addSubview:self.roomListCollection];
}

- (void)layoutUI {
    [self.roomListCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(self);
    }];
}

- (void)bindInteraction {
    self.roomListCollection.delegate = self;
    self.roomListCollection.dataSource = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshAction)];
    [header setTitle:@"下拉刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中" forState:MJRefreshStateRefreshing];
    [header setTitle:@"" forState:MJRefreshStateIdle];
    self.roomListCollection.mj_header = header;
}

- (void)refreshAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshRoomListData)]) {
        [self.delegate refreshRoomListData];
    }
}

#pragma mark - UI事件
- (void)refreshList {
    [self.roomListCollection reloadData];
}

- (void)endRefreshState {
    [self.roomListCollection.mj_header endRefreshing];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 触发进入房间的点击事件
    if (self.delegate && [self.delegate respondsToSelector:@selector(enterRoom:)]) {
        TUILiveRoomInfo* roomInfo = [self.delegate roomList][indexPath.row];
        [self.delegate enterRoom:roomInfo];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (!self.delegate) {
        return 0;
    }
    return [self.delegate roomList].count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TUILiveRoomListCell" forIndexPath:indexPath];
    if ([cell isKindOfClass:[TUILiveRoomListCell class]]) {
        TUILiveRoomListCell* roomCell = (TUILiveRoomListCell *)cell;
        if (self.delegate) {
            TUILiveRoomInfo* roomInfo = [self.delegate roomList][indexPath.row];
            [roomCell setCellWithRoomInfo:roomInfo];
        }
    }
    return cell;
}


@end
