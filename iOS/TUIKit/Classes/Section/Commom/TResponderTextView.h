//
//  TResponderTextView.h
//  TUIKit
//
//  Created by kennethmiao on 2018/10/25.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TResponderTextView : UITextView
@property (nonatomic, weak) UIResponder *overrideNextResponder;
@end
