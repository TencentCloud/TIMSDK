//
//  TUISearchResultHeaderFooterView.h
//  Pods
//
//  Created by harvy on 2020/12/24.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUISearchResultHeaderFooterView : UITableViewHeaderFooterView

@property(nonatomic, assign) BOOL isFooter;
@property(nonatomic, copy) NSString* __nullable title;
@property(nonatomic, copy) dispatch_block_t __nullable onTap;

@end

NS_ASSUME_NONNULL_END
