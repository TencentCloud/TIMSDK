//
//  TGroupMembersView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/11.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGroupMemberCell.h"

@class TGroupMembersView;
@protocol TGroupMembersViewDelegate <NSObject>
- (void)groupMembersView:(TGroupMembersView *)groupMembersView didSelectGroupMember:(TGroupMemberCellData *)groupMember;
@end

@interface TGroupMembersView : UIView
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) id<TGroupMembersViewDelegate> delegate;
- (void)setData:(NSMutableArray<TGroupMemberCellData *> *)data;
@end
