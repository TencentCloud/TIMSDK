//
//  AddC2CViewController.m
//  TUIKit
//
//  Created by kennethmiao on 2018/10/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "AddC2CController.h"
#import "TAddC2CController.h"
#import "TAddCell.h"
#import "ChatViewController.h"
#import "TUIKit.h"

@interface AddC2CController () <TAddC2CControllerDelegate>

@end

@implementation AddC2CController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *datas = [NSMutableArray array];
//    for (NSString *item in [[TUIKit sharedInstance] testUser]) {
//        TAddCellData *data = [[TAddCellData alloc] init];
//        data.head = TUIKitResource(@"default_head");
//        data.name = item;
//        data.identifier = item;
//        [datas addObject:data];
//    }
    TAddC2CController *add = [[TAddC2CController alloc] init];
    add.delegate = self;
    //add.data = datas;
    [self addChildViewController:add];
    [self.view addSubview:add.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didCancelInAddC2CController:(TAddC2CController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addC2CController:(TAddC2CController *)controller didCreateChat:(NSString *)user
{
    TConversationCellData *data = [[TConversationCellData alloc] init];
    data.convId = user;
    data.convType = TConv_Type_C2C;
    data.title = user;
    ChatViewController *chat = [[ChatViewController alloc] init];
    chat.conversation = data;
    [self dismissViewControllerAnimated:NO completion:nil];
    [((UITabBarController *)self.presentingViewController).selectedViewController pushViewController:chat animated:YES];
}

@end
