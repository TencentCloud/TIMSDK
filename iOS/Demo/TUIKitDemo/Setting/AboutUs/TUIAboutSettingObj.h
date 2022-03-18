//
//  TUIAboutSettingObj.h
//  TUIKitDemo
//
//  Created by wyl on 2022/2/9.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^CellClickedAction)(UITableView *tableview, NSIndexPath *path);

@interface TUIAboutSettingObj : NSObject
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *subtitle;
@property(nonatomic, strong) Class cellClass;
@property(nonatomic, assign) CGFloat cellHeight;
@property(nonatomic, strong) CellClickedAction cellClickedAction;

@end

NS_ASSUME_NONNULL_END
