//
//  TUIFoldListViewController.h
//  TUIChat
//
//  Created by wyl on 2022/7/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIFoldListViewController : UIViewController

@property (nonatomic,copy) void(^dismissCallback)(NSMutableAttributedString * foldStr,NSArray *sortArr, NSArray *needRemoveFromCacheMapArray);

@end

NS_ASSUME_NONNULL_END
