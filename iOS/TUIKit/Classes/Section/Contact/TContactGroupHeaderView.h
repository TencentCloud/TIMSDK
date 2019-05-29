//
//  TContactGroupHeaderView.h
//  TUIKit
//
//  Created by annidyfeng on 2019/4/22.
//  Copyright © 2019年 kennethmiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@import ImSDK;

NS_ASSUME_NONNULL_BEGIN

@interface TContactGroupHeaderData : NSObject

@property NSString *groupName;
@property NSInteger userCnt;
@property BOOL isFold;
@property NSArray<TIMUserProfile *> *subProfiles;

@end

@interface TContactGroupHeaderView : UITableViewHeaderFooterView

@property UIImageView *icon;
@property UILabel *name;
@property UILabel *count;
@property UIView *line;

@property (nonatomic) TContactGroupHeaderData *data;

@end

NS_ASSUME_NONNULL_END
