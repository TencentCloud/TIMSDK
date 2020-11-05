//
//  TUILiveGiftInfoCell.h
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import <UIKit/UIKit.h>

@class TUILiveGiftInfo;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUILiveGiftInfoCellSendCallback)(TUILiveGiftInfo *gift);

@interface TUILiveGiftPanelCell : UICollectionViewCell

@property (nonatomic, strong) TUILiveGiftInfo *giftInfo;
@property (nonatomic, copy) TUILiveGiftInfoCellSendCallback onSendGift;
    
@end

NS_ASSUME_NONNULL_END
