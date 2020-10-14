//
//  TUILiveRoomListCell.h
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUILiveRoomInfo;
@interface TUILiveRoomListCell : UICollectionViewCell

- (void)setCellWithRoomInfo:(TUILiveRoomInfo *)info;

@end

NS_ASSUME_NONNULL_END
