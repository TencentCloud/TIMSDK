//
//  SearchFriendViewController.h
//  TIMChat
//
//  Created by AlexiChen on 16/2/29.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//
/** 腾讯云IM Demo查找好友视图
 *  本文件实现了查找好友的视图控制器，使用户能够根据用户ID查找指定用户
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 */
#import <UIKit/UIKit.h>

@interface SearchFriendSearchResultViewController : UIViewController

@end


@interface SearchFriendViewController : UIViewController

@property (nonatomic,retain) UISearchController *searchController;

@end
