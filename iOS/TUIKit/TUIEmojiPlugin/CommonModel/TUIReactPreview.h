//
//  TUIReactPreview.h
//  TUIChat
//
//  Created by wyl on 2022/5/26.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TUIMessageCell;
@class TUIReactModel;
NS_ASSUME_NONNULL_BEGIN

@interface TUIReactPreview : UIView

/// datasource
@property(nonatomic, strong) NSMutableArray *listArrM;

/// Select the model for the TAB
@property(nonatomic, copy) void (^emojiClickCallback)(TUIReactModel *model);

@property(nonatomic, copy) void (^userClickCallback)(TUIReactModel *model);

@property(nonatomic, weak) TUIMessageCell *delegateCell;

- (void)updateView;

- (void)refreshByArray:(NSMutableArray *)tagsArray;
- (void)notifyReactionChanged;
@end
NS_ASSUME_NONNULL_END
