//
//  TUISelectedUserCollectionViewCell.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/UIView+TUILayout.h>
#import <UIKit/UIKit.h>

@interface TUIMemberPanelCell : UICollectionViewCell
- (void)fillWithData:(TUIUserModel *)model;
@end
