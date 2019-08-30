//
//  NotifySetupController.m
//  MyDemo
//
//  Created by wilderliao on 15/12/2.
//  Copyright © 2015年 sofawang. All rights reserved.
//
/** 腾讯云IM Demo消息提醒设置视图
 *  在用户需要自定义APP提醒模式时，向用户提供UI
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 *
 */
#import "NotifySetupController.h"
#import "TCommonSwitchCell.h"

@implementation NotifySetupController
{
    NSMutableDictionary *_dataDictionary;
    NSMutableArray *_groupArray;
}

- (instancetype)init:(TIMAPNSConfig *)config
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        [self configState:config];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"消息提醒设置";
    [self configOwnViews];
}

- (void)configOwnViews
{
    _dataDictionary = @{}.mutableCopy;
    _groupArray = @[].mutableCopy;

    //开启通知section
    TCommonSwitchCellData *notifySwitch = [[TCommonSwitchCellData alloc] init];
    notifySwitch.title = @"开启通知";
    notifySwitch.on = _configState.openPush;
    notifySwitch.cswitchSelector = @selector(onNotifySwitch:);
    [_dataDictionary setObject:@[notifySwitch] forKey:@"开启通知"];
    [_groupArray addObject:@"开启通知"];
    if (!_configState.openPush) {
        [self.tableView reloadData];
        return;
    }
    //C2C消息设置
    TCommonSwitchCellData *c2cOpenSound = [[TCommonSwitchCellData alloc] init];
    c2cOpenSound.title = @"开启声音";
    c2cOpenSound.on = _configState.c2cOpenSound;
    c2cOpenSound.cswitchSelector = @selector(onC2CSoundConfig:);

    TCommonSwitchCellData *c2cOpenShake = [[TCommonSwitchCellData alloc] init];
    c2cOpenShake.title = @"开启震动";
    c2cOpenShake.on = _configState.c2cOpenShake;
    c2cOpenShake.cswitchSelector = @selector(onC2CShakeConfig:);
    [_dataDictionary setObject:@[c2cOpenSound, c2cOpenShake] forKey:@"C2C消息设置"];
    [_groupArray addObject:@"C2C消息设置"];
    //Group消息设置

    TCommonSwitchCellData *groupOpenSound = [[TCommonSwitchCellData alloc] init];
    groupOpenSound.title = @"开启声音";
    groupOpenSound.on = _configState.groupOpenSound;
    groupOpenSound.cswitchSelector = @selector(onGroupSoundConfig:);

    TCommonSwitchCellData *groupOpenShake = [[TCommonSwitchCellData alloc] init];
    groupOpenShake.title = @"开启震动";
    groupOpenShake.on = _configState.groupOpenShake;
    groupOpenShake.cswitchSelector = @selector(onGroupShakeConfig:);

    [_dataDictionary setObject:@[groupOpenSound, groupOpenShake] forKey:@"Group消息设置"];
    [_groupArray addObject:@"Group消息设置"];
    [self.tableView reloadData];
}

- (void)onNotifySwitch:(TCommonSwitchCell *)cell
{
    _configState.openPush = cell.switcher.on;
    uint32_t openPush = (cell.switcher.on) ? 1 : 2;
    [self setApns:openPush type:nil soundName:nil succ:^{

    }];
    [self configOwnViews];
}

- (void)onC2CSoundConfig:(TCommonSwitchCell *)cell
{
    _configState.c2cOpenSound = cell.switcher.on;
    NSString *fileName = [self selectFileName:_configState.c2cOpenSound shakeSwitchOn:_configState.c2cOpenShake];


    [self setApns:0 type:@"c2cSound" soundName:fileName succ:^{
    }];
}

- (void)onC2CShakeConfig:(TCommonSwitchCell *)cell
{
    _configState.c2cOpenShake = cell.switcher.on;
    NSString *fileName = [self selectFileName:_configState.c2cOpenSound shakeSwitchOn:_configState.c2cOpenShake];

    [self setApns:0 type:@"c2cSound" soundName:fileName succ:^{
    }];
}

- (void)onGroupSoundConfig:(TCommonSwitchCell *)cell
{
    _configState.groupOpenSound = cell.switcher.on;
    NSString *fileName = [self selectFileName:_configState.groupOpenSound shakeSwitchOn:_configState.groupOpenShake];

    [self setApns:0 type:@"groupSound" soundName:fileName succ:^{

    }];
}

- (void)onGroupShakeConfig:(TCommonSwitchCell *)cell
{
    _configState.groupOpenShake = cell.switcher.on;
    NSString *fileName = [self selectFileName:_configState.groupOpenSound shakeSwitchOn:_configState.groupOpenShake];

    [self setApns:0 type:@"groupSound" soundName:fileName succ:^{
    }];
}

- (void)configState:(TIMAPNSConfig *)config
{
    _configState = [[ConfigState alloc] init];

    //设置默认值
    if (config == nil)
    {
        _configState.openPush = NO;
        _configState.c2cOpenSound = NO;
        _configState.c2cOpenShake = NO;
        _configState.groupOpenSound = NO;
        _configState.groupOpenShake = NO;
//        _configState.videoOpenSound = NO;
//        _configState.videoOpenShake = NO;
        return;
    }

    _configState.openPush = (config.openPush==1) ? YES : NO;

    //根据当前配置文件名，修改App的通知模式
    if ([config.c2cSound isEqualToString:@"00.caf"] || config.c2cSound.length==0)
    {
        _configState.c2cOpenSound = NO;
        _configState.c2cOpenShake = NO;
    }
    else if ([config.c2cSound isEqualToString:@"01.caf"])
    {
        _configState.c2cOpenSound = NO;
        _configState.c2cOpenShake = YES;
    }
    else if ([config.c2cSound isEqualToString:@"10.caf"])
    {
        _configState.c2cOpenSound = YES;
        _configState.c2cOpenShake = NO;
    }
    else if ([config.c2cSound isEqualToString:@"11.caf"])
    {
        _configState.c2cOpenSound = YES;
        _configState.c2cOpenShake = YES;
    }

    if ([config.groupSound isEqualToString:@"00.caf"] || config.groupSound.length==0)
    {
        _configState.groupOpenSound = NO;
        _configState.groupOpenShake = NO;
    }
    else if ([config.groupSound isEqualToString:@"01.caf"])
    {
        _configState.groupOpenSound = NO;
        _configState.groupOpenShake = YES;
    }
    else if ([config.groupSound isEqualToString:@"10.caf"])
    {
        _configState.groupOpenSound = YES;
        _configState.groupOpenShake = NO;
    }
    else if ([config.groupSound isEqualToString:@"11.caf"])
    {
        _configState.groupOpenSound = YES;
        _configState.groupOpenShake = YES;
    }

//    if ([config.videoSound isEqualToString:@"00.caf"] || config.videoSound.length==0) {
//        _configState.videoOpenSound = NO;
//        _configState.videoOpenShake = NO;
//    }
//    else if ([config.videoSound isEqualToString:@"01.caf"]) {
//        _configState.videoOpenSound = NO;
//        _configState.videoOpenShake = YES;
//    }
//    else if ([config.videoSound isEqualToString:@"10.caf"]) {
//        _configState.videoOpenSound = YES;
//        _configState.videoOpenShake = NO;
//    }
//    else if ([config.videoSound isEqualToString:@"11.caf"]) {
//        _configState.videoOpenSound = YES;
//        _configState.videoOpenShake = YES;
//    }

}

/**
 *  根据当前App设置，修改配置文件名
 */
- (NSString *)selectFileName:(BOOL)soundOn shakeSwitchOn:(BOOL)shakeOn
{
    if (!soundOn && !shakeOn)
    {
        return @"00.caf";
    }
    else if (!soundOn && shakeOn)
    {
        return @"01.caf";
    }
    else if (soundOn && !shakeOn)
    {
        return @"10.caf";
    }
    else if (soundOn && shakeOn)
    {
        return @"11.caf";
    }
    else
    {
        return nil;
    }
}

- (void)saveObject:(BOOL)obj key:(NSString*)key
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:obj] forKey:key];
}

//openPush:0-不进行设置 1-开启推送 2-关闭推送
- (void)setApns:(uint32_t)openPush type:(NSString *)type soundName:(NSString *)name succ:(TIMSucc)succ
{
    TIMAPNSConfig * apnsConfig = [[TIMAPNSConfig alloc] init];
    apnsConfig.openPush = openPush;
    if ([type isEqualToString:@"c2cSound"])
    {
        apnsConfig.c2cSound = name;
    }
    if ([type isEqualToString:@"groupSound"])
    {
        apnsConfig.groupSound = name;
    }
    if ([type isEqualToString:@"videoSound"])
    {
        apnsConfig.videoSound = name;
    }


    [[TIMManager sharedInstance] setAPNS:apnsConfig succ:^()
     {
         if (succ)
         {
             succ();
         }
     } fail:^(int code, NSString *err)
     {

     }];
}

#pragma mark - tableview delegate
/**
 *  tableView委托函数
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = _groupArray[section];
    NSArray *array = _dataDictionary[key];
    return array.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *key = _groupArray[section];
    return key;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = _groupArray[indexPath.section];
    NSArray *array = _dataDictionary[key];
    TCommonSwitchCellData *data = array[indexPath.row];

    static NSString *reuseId = @"SwitchCell";
    TCommonSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[TCommonSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    [cell fillWithData:data];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _groupArray.count;
}

@end

@implementation ConfigState

@end
