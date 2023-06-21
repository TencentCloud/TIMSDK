
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <UIKit/UIKit.h>
#import "TUIGroupMembersCellData.h"

@class TUIGroupMembersCell;

/////////////////////////////////////////////////////////////////////////////////
//
//                        TUIGroupMembersCellDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIGroupMembersCellDelegate <NSObject>

- (void)groupMembersCell:(TUIGroupMembersCell *)cell didSelectItemAtIndex:(NSInteger)index;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                        TUIGroupMembersCell
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIGroupMembersCell : UITableViewCell

@property(nonatomic, strong) UICollectionView *memberCollectionView;

@property(nonatomic, strong) UICollectionViewFlowLayout *memberFlowLayout;

@property(nonatomic, weak) id<TUIGroupMembersCellDelegate> delegate;

@property(nonatomic) TUIGroupMembersCellData *data;

+ (CGFloat)getHeight:(TUIGroupMembersCellData *)data;

@end
