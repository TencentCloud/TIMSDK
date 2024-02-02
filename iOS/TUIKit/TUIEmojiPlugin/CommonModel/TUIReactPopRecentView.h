//
//  TUIReactPopRecentView.h
//  TUIChat
//
//  Created by wyl on 2022/5/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TUIChat/TUIChatPopMenuDefine.h>
#import <TUIChat/TUIChatPopMenu.h>
@class TUIReactPopRecentView;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReactPopRecentView : UIView
@property(nonatomic, strong, readonly) NSMutableArray *faceGroups;
@property(nonatomic, assign) BOOL needShowbottomLine;
@property(nonatomic, strong) UIButton *arrowButton;
@property(nonatomic, weak) TUIChatPopMenu *delegateView;
- (void)setData:(NSMutableArray *)data;

@end

NS_ASSUME_NONNULL_END
