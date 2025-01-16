
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>
#import "TUIGroupMemberCell.h"

@class TUIGroupMembersView;

/////////////////////////////////////////////////////////////////////////////////
//
//                     TUIGroupMembersViewDelegate
//
/////////////////////////////////////////////////////////////////////////////////
@protocol TUIGroupMembersViewDelegate <NSObject>

- (void)groupMembersView:(TUIGroupMembersView *)groupMembersView didSelectGroupMember:(TUIGroupMemberCellData *)groupMember;
- (void)groupMembersView:(TUIGroupMembersView *)groupMembersView didLoadMoreData:(void (^)(NSArray<TUIGroupMemberCellData *> *))completion;

@end

/////////////////////////////////////////////////////////////////////////////////
//
//                       TUIGroupMembersView
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIGroupMembersView : UIView

@property(nonatomic, strong) UISearchBar *searchBar;

@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property(nonatomic, weak) id<TUIGroupMembersViewDelegate> delegate;

@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;

- (void)setData:(NSMutableArray<TUIGroupMemberCellData *> *)data;
@end
