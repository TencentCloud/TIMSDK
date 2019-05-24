//
//  NotifySetupController.m
//  MyDemo
//
//  Created by wilderliao on 15/12/2.
//  Copyright © 2015年 sofawang. All rights reserved.
//

#import "NotifySetupController.h"
#import "TRichMenuCell.h"

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
    
    [self setupSubviewEnable:_configState.openPush];
}

- (void)configOwnViews
{
    _dataDictionary = @{}.mutableCopy;

    __weak NotifySetupController *ws = self;
    //开启通知section
    TRichMenuCellData *notifySwitch = [[TRichMenuCellData alloc] init];
    notifySwitch.type = ERichCell_Switch;
    notifySwitch.desc = @"开启通知";
    notifySwitch.descColor = [UIColor blackColor];
    notifySwitch.margin = 20;
    notifySwitch.switchValue = _configState.openPush;
    notifySwitch.onSelectAction = ^(TRichMenuCellData *menu, TRichMenuCell *cell) {
        [ws onNotifySwitch:menu cell:cell];
    };
    [_dataDictionary setObject:@[notifySwitch] forKey:@"开启通知"];
    
    //C2C消息设置
    TRichMenuCellData *c2cOpenSound = [[TRichMenuCellData alloc] init];
    c2cOpenSound.type = ERichCell_Switch;
    c2cOpenSound.desc = @"开启声音";
    c2cOpenSound.descColor = [UIColor blackColor];
    c2cOpenSound.margin = 20;
    c2cOpenSound.switchValue = _configState.c2cOpenSound;
    c2cOpenSound.onSelectAction = ^(TRichMenuCellData *menu, TRichMenuCell *cell) {
        [ws onC2CSoundConfig:menu cell:cell];
    };
    
    TRichMenuCellData *c2cOpenShake = [[TRichMenuCellData alloc] init];
    c2cOpenShake.type = ERichCell_Switch;
    c2cOpenShake.desc = @"开启震动";
    c2cOpenShake.descColor = [UIColor blackColor];
    c2cOpenShake.margin = 20;
    c2cOpenShake.switchValue = _configState.c2cOpenShake;
    c2cOpenShake.onSelectAction = ^(TRichMenuCellData *menu, TRichMenuCell *cell) {
        [ws onC2CShakeConfig:menu cell:cell];
    };
    [_dataDictionary setObject:@[c2cOpenSound, c2cOpenShake] forKey:@"C2C消息设置"];
    
    //Group消息设置
    
    TRichMenuCellData *groupOpenSound = [[TRichMenuCellData alloc] init];
    groupOpenSound.type = ERichCell_Switch;
    groupOpenSound.desc = @"开启声音";
    groupOpenSound.descColor = [UIColor blackColor];
    groupOpenSound.margin = 20;
    groupOpenSound.switchValue = _configState.groupOpenSound;
    groupOpenSound.onSelectAction = ^(TRichMenuCellData *menu, TRichMenuCell *cell) {
        [ws onGroupShakeConfig:menu cell:cell];
    };
    TRichMenuCellData *groupOpenShake = [[TRichMenuCellData alloc] init];
    groupOpenShake.type = ERichCell_Switch;
    groupOpenShake.desc = @"开启震动";
    groupOpenShake.descColor = [UIColor blackColor];
    groupOpenShake.margin = 20;
    groupOpenShake.switchValue = _configState.groupOpenShake;
    groupOpenShake.onSelectAction = ^(TRichMenuCellData *menu, TRichMenuCell *cell) {
        [ws onGroupShakeConfig:menu cell:cell];
    };
    [_dataDictionary setObject:@[groupOpenSound, groupOpenShake] forKey:@"Group消息设置"];
}

- (void)onNotifySwitch:(TRichMenuCellData *)menu cell:(UITableViewCell *)cell
{
    __weak NotifySetupController *ws = self;
    __weak ConfigState *wc = _configState;
    
    uint32_t openPush = (!menu.switchValue) ? 1 : 2;
    [self setApns:openPush type:nil soundName:nil succ:^{
        
        menu.switchValue = !menu.switchValue;
        ((TRichMenuCell *)cell).onSwitch.on = menu.switchValue;
        
        wc.openPush = menu.switchValue;
        [ws setupSubviewEnable:menu.switchValue];
    }];
}

- (void)onC2CSoundConfig:(TRichMenuCellData *)menu cell:(UITableViewCell *)cell
{
    __weak ConfigState *wc = _configState;
    
    NSString *fileName = [self selectFileName:!menu.switchValue shakeSwitchOn:_configState.c2cOpenShake];
    
    [self setApns:0 type:@"c2cSound" soundName:fileName succ:^{
        
        menu.switchValue = !menu.switchValue;
        ((TRichMenuCell *)cell).onSwitch.on = menu.switchValue;
        
        wc.c2cOpenSound = menu.switchValue;
    }];
}

- (void)onC2CShakeConfig:(TRichMenuCellData *)menu cell:(UITableViewCell *)cell
{
    __weak ConfigState *wc = _configState;
    
    NSString *fileName = [self selectFileName:_configState.c2cOpenSound shakeSwitchOn:!menu.switchValue];
    
    [self setApns:0 type:@"c2cSound" soundName:fileName succ:^{
        
        menu.switchValue = !menu.switchValue;
        ((TRichMenuCell *)cell).onSwitch.on = menu.switchValue;
        
        wc.c2cOpenShake = menu.switchValue;
    }];
}

- (void)onGroupSoundConfig:(TRichMenuCellData *)menu cell:(UITableViewCell *)cell
{
    __weak ConfigState *wc = _configState;
    
    NSString *fileName = [self selectFileName:!menu.switchValue shakeSwitchOn:_configState.groupOpenShake];
    
    [self setApns:0 type:@"groupSound" soundName:fileName succ:^{
        
        menu.switchValue = !menu.switchValue;
        ((TRichMenuCell *)cell).onSwitch.on = menu.switchValue;
        
        wc.groupOpenSound = menu.switchValue;
    }];
}

- (void)onGroupShakeConfig:(TRichMenuCellData *)menu cell:(UITableViewCell *)cell
{
    __weak ConfigState *wc = _configState;
    
    NSString *fileName = [self selectFileName:_configState.groupOpenSound shakeSwitchOn:!menu.switchValue];
    
    [self setApns:0 type:@"groupSound" soundName:fileName succ:^{
        
        menu.switchValue = !menu.switchValue;
        ((TRichMenuCell *)cell).onSwitch.on = menu.switchValue;
        
        wc.groupOpenShake = menu.switchValue;
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

- (void)setupSubviewEnable:(BOOL)isEnable
{
    NSArray *keys = [_dataDictionary allKeys];
    
    for(NSString *key in keys)
    {
        NSArray *items = (NSArray *)[_dataDictionary objectForKey:key];
        for (TRichMenuCellData *item in items)
        {
            if (![item.desc isEqualToString:@"开启通知"])
            {
                continue;
            }
            item.switchValue = isEnable;
        }
    }
    if (isEnable) {
        _groupArray = @[@"开启通知",@"C2C消息设置",@"Group消息设置"].mutableCopy;
    } else {
        _groupArray = @[@"开启通知"].mutableCopy;
    }
    [self.tableView reloadData];
}

#pragma mark - tableview delegate

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
    TRichMenuCellData *data = array[indexPath.row];
    
    static NSString *reuseId = @"TRichMenuCell";
    TRichMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell) {
        cell = [[TRichMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    cell.data = data;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _groupArray.count;
}

@end

@implementation ConfigState

@end
