//
//  TestForGroupAttributeViewController.m
//  TUIKitDemo
//
//  Created by harvy on 2021/8/11.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TestForGroupAttributeViewController.h"
#import "TUIDefine.h"
#import "TUITool.h"

@interface TestForGroupAttributeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *groupIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *keysTextField;
@property (weak, nonatomic) IBOutlet UITextField *valuesTextField;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;


@end

@implementation TestForGroupAttributeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onGroupAttributeChanged:) name:@"V2TIMGroupNotify_onGroupAttributeChanged" object:nil];
    
    self.groupIDTextField.text = @"harvy_test_avchatroom_01";
}

- (void)onGroupAttributeChanged:(NSNotification *)notice {
    [self closeKeyboard:nil];
    NSDictionary *userInfo = notice.userInfo;
    NSString *groupID = userInfo[@"groupID"];
    NSDictionary *attributes = userInfo[@"attributes"];
    
    __block NSString *printStr = [NSString stringWithFormat:@"收到通知:\ngroupId: %@\n", groupID];
    [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
        printStr = [printStr stringByAppendingFormat:@"%@:%@\n", key, value];
    }];
    self.resultLabel.text = printStr;
}

- (IBAction)createGroup:(id)sender {
    [self closeKeyboard:nil];
    V2TIMGroupInfo *info = [[V2TIMGroupInfo alloc] init];
    info.groupID = self.groupIDTextField.text;
    info.groupType = @"AVChatRoom";
    info.groupName = @"创建一个直播群";
    info.groupAddOpt = V2TIM_GROUP_ADD_ANY;
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance createGroup:info memberList:nil succ:^(NSString *groupID) {
        weakSelf.groupIDTextField.text = groupID;
        [TUITool makeToast:@"成功创建群聊"];
    } fail:^(int code, NSString *desc) {
        [weakSelf.view makeToast:@"创建群聊失败"];
    }];
}

- (IBAction)joinGroup:(id)sender {
    [self closeKeyboard:nil];
    [V2TIMManager.sharedInstance joinGroup:self.groupIDTextField.text msg:@"" succ:^{
        [TUITool makeToast:@"成功加入群聊"];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToast:@"加入群聊失败"];
    }];
}

- (IBAction)dismissGrouo:(id)sender {
    [V2TIMManager.sharedInstance dismissGroup:self.groupIDTextField.text succ:^{
        [TUITool makeToast:@"成功解散群聊"];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToast:@"解散群聊失败"];
    }];
}


- (IBAction)reset:(id)sender {
    [self closeKeyboard:nil];
    NSString *keys = self.keysTextField.text?:@"";
    NSString *values = self.valuesTextField.text?:@"";
    
    NSArray *keyM = [keys componentsSeparatedByString:@","];
    NSArray *valueM = [values componentsSeparatedByString:@","];
    NSMutableDictionary *attributeM = [NSMutableDictionary dictionary];
    for (int i = 0; i < keyM.count; i++) {
        NSString *key = keyM[i];
        NSString *value = @"";
        if (i < valueM.count) {
            value = valueM[i];
        }
        if (key.length && value.length) {
            attributeM[key] = value;
        }
    }
    
    [V2TIMManager.sharedInstance initGroupAttributes:self.groupIDTextField.text attributes:attributeM succ:^{
        [TUITool makeToast:@"重置属性成功"];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToast:[NSString stringWithFormat:@"重置属性失败, %d, %@", code, desc]];
    }];
}

- (IBAction)delete:(id)sender {
    [self closeKeyboard:nil];
    NSString *keys = self.keysTextField.text.length?self.keysTextField.text:nil;
    NSArray *keyM = [keys componentsSeparatedByString:@","];
    
    [V2TIMManager.sharedInstance deleteGroupAttributes:self.groupIDTextField.text keys:keyM succ:^{
        [TUITool makeToast:keyM.count ? @"删除群属性成功" : @"删除所有群属性成功"];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToast:[NSString stringWithFormat:@"删除群属性失败，%d, %@", code, desc]];
    }];
    
}

- (IBAction)update:(id)sender {
    [self closeKeyboard:nil];
    NSString *keys = self.keysTextField.text?:@"";
    NSString *values = self.valuesTextField.text?:@"";
    
    NSArray *keyM = [keys componentsSeparatedByString:@","];
    NSArray *valueM = [values componentsSeparatedByString:@","];
    NSMutableDictionary *attributeM = [NSMutableDictionary dictionary];
    for (int i = 0; i < keyM.count; i++) {
        NSString *key = keyM[i];
        NSString *value = @"";
        if (i < valueM.count) {
            value = valueM[i];
        }
        if (key.length && value.length) {
            attributeM[key] = value;
        }
    }
    [V2TIMManager.sharedInstance setGroupAttributes:self.groupIDTextField.text attributes:attributeM succ:^{
        [TUITool makeToast:@"更新群属性成功"];
    } fail:^(int code, NSString *desc) {
        [TUITool makeToast:[NSString stringWithFormat:@"更新群属性失败，%d, %@", code, desc]];
    }];
}

- (IBAction)get:(id)sender {
    [self closeKeyboard:nil];
    NSString *keys = self.keysTextField.text.length?self.keysTextField.text:nil;
    NSArray *keyM = [keys componentsSeparatedByString:@","];
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance getGroupAttributes:self.groupIDTextField.text keys:keyM succ:^(NSMutableDictionary<NSString *,NSString *> *groupAttributeList) {
        
        __block NSString *printStr = [NSString stringWithFormat:@"groupId: %@\n", weakSelf.groupIDTextField.text];
        [groupAttributeList enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
            printStr = [printStr stringByAppendingFormat:@"%@:%@\n", key, value];
        }];
        weakSelf.resultLabel.text = printStr;
        
    } fail:^(int code, NSString *desc) {
        [TUITool makeToast:[NSString stringWithFormat:@"获取群属性失败，%d, %@", code, desc]];
    }];
}
- (IBAction)clear:(id)sender {
    
    self.resultLabel.text = @"";
}
- (IBAction)closeKeyboard:(id)sender {
    [self.view endEditing:YES];
    [self.valuesTextField resignFirstResponder];
    [self.keysTextField resignFirstResponder];
    [self.groupIDTextField resignFirstResponder];
}

- (IBAction)fillKeys:(id)sender {
    self.keysTextField.text = @"key1,key2,key3,key4,key5,key6,key7,key8,key9,key10";
}
- (IBAction)clearKeys:(id)sender {
    self.keysTextField.text = nil;
}

- (IBAction)fillvalues:(id)sender {
    self.valuesTextField.text = @"value1,value2,value3,value4,value5,value6,value7,value8,value9,value10";
}
- (IBAction)clearvalues:(id)sender {
    self.valuesTextField.text = nil;
}



@end
