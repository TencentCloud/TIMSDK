//
//  TUIGroupMembersView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/11.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIGroupMemberCell.h"

@class TUIGroupMembersView;
@protocol TGroupMembersViewDelegate <NSObject>
- (void)groupMembersView:(TUIGroupMembersView *)groupMembersView didSelectGroupMember:(TGroupMemberCellData *)groupMember;
@end

@interface TUIGroupMembersView : UIView
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) id<TGroupMembersViewDelegate> delegate;
- (void)setData:(NSMutableArray<TGroupMemberCellData *> *)data;
@end
