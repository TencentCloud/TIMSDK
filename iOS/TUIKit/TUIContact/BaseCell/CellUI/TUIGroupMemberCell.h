
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>
#import <TIMCommon/TUICommonGroupInfoCellData.h>

@interface TUIGroupMemberCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *head;

@property(nonatomic, strong) UILabel *name;

+ (CGSize)getSize;

@property(nonatomic, strong) TUIGroupMemberCellData *data;

@end
