//
//  NotifySetupController.h
//  MyDemo
//
//  Created by wilderliao on 15/12/2.
//  Copyright © 2015年 sofawang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIMManager.h"

@class ConfigState;
@interface NotifySetupController : UITableViewController
{
//    UITableView           *_tableView;
    
    NSMutableArray        *_sectionTitle;
//    NSMutableDictionary   *_datas;
    
    BOOL                  _isOpenApns;
    
    BOOL                  _isEnableSwitch;
    
    ConfigState           *_configState;
}

- (instancetype)init:(TIMAPNSConfig *)config;

@end

@interface ConfigState : NSObject

@property BOOL openPush;

@property BOOL c2cOpenSound;
@property BOOL c2cOpenShake;

@property BOOL groupOpenSound;
@property BOOL groupOpenShake;

//没有来电，暂时屏蔽
//@property BOOL videoOpenSound;
//@property BOOL videoOpenShake;


@end
