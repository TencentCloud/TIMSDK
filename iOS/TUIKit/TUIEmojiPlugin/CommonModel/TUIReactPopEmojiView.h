//
//  TUIReactPopEmojiView.h
//  TUIChat
//
//  Created by wyl on 2022/4/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TUIChat/TUIFaceView.h>
#import <TUIChat/TUIChatPopMenuDefine.h>
#import <TUIChat/TUIChatPopMenu.h>
NS_ASSUME_NONNULL_BEGIN

@interface TUIReactPopEmojiView : TUIFaceView

@property(nonatomic, weak) TUIChatPopMenu *delegateView;

@end
NS_ASSUME_NONNULL_END
