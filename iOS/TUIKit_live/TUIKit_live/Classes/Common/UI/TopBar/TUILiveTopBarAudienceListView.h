//
//  TUILiveTopBarAudienceListView.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by coddyliu on 2020/9/19.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveAudienceAvatarCell : UICollectionViewCell
@property(nonatomic, strong) UIButton *avatarButton;
@property(nonatomic, strong) UILabel *weightLabel;
@end

@class TUILiveTopBarAudienceListView;
typedef void(^TUILiveAudienceListSelectedBlock)(TUILiveTopBarAudienceListView *listView, id info);
@interface TUILiveTopBarAudienceListView : UIView
@property(nonatomic, strong) NSArray *audienceList;
@property(nonatomic, strong)TUILiveAudienceListSelectedBlock onSelected;
@end

NS_ASSUME_NONNULL_END
