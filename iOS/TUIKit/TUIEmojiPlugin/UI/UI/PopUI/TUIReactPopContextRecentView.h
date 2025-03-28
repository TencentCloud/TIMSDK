//
//  TUIReactPopContextRecentView.h
//  TUIChat
//
//  Created by wyl on 2022/10/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TUIChat/TUIChatPopContextController.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUIReactPopContextRecentView : UIView

@property(nonatomic, strong, readonly) NSMutableArray *faceGroups;
@property(nonatomic, assign) BOOL needShowbottomLine;
@property(nonatomic, strong) UIButton *arrowButton;
@property(nonatomic, weak) TUIChatPopContextController* delegateVC;
- (void)setData:(NSMutableArray *)data;

@end

NS_ASSUME_NONNULL_END
