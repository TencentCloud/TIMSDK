//
//  TUITagsView.h
//  TUIChat
//
//  Created by wyl on 2022/5/26.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TUITagsModel;
NS_ASSUME_NONNULL_BEGIN

@interface TUITagsView : UIView

/// datasource
@property(nonatomic, strong) NSMutableArray *listArrM;

/// Height callback after refreshing collectionView
@property(nonatomic, copy) void (^reloadCollectionView)(CGFloat updateHeight);

/// Select the model for the TAB
@property(nonatomic, copy) void (^signSelectTag)(TUITagsModel *model);

@property(nonatomic, copy) void (^emojiClickCallback)(TUITagsModel *model);

@property(nonatomic, copy) void (^userClickCallback)(TUITagsModel *model);

- (void)updateView;

- (void)updateRTLView;
@end
NS_ASSUME_NONNULL_END
