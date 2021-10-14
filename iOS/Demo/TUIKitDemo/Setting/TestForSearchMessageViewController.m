//
//  TestForSearchMessageViewController.m
//  TUIKitDemo
//
//  Created by harvy on 2021/6/24.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TestForSearchMessageViewController.h"
#import <TUIDefine.h>

@interface TestForSearchMessageViewController () <UIScrollViewDelegate>

#pragma mark - Common
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

#pragma mark - 消息搜索
@property (weak, nonatomic) IBOutlet UITextField *msg_conversationIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *msg_senderOneTextField;
@property (weak, nonatomic) IBOutlet UITextField *msg_sendTwoTextField;
@property (weak, nonatomic) IBOutlet UITextField *msg_keywordOneTextField;
@property (weak, nonatomic) IBOutlet UITextField *msg_keywordTwoTextField;
@property (weak, nonatomic) IBOutlet UISwitch *msg_OrAndSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *msg_isSearchtextSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *msg_isSearchCustomSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *msg_isSearchImageSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *msg_isSearchVoiceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *msg_isSearchVideoSwtich;
@property (weak, nonatomic) IBOutlet UISwitch *msg_isSearchFileSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *msg_isSearchLocationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *msg_isSearchForwardSwitch;
@property (weak, nonatomic) IBOutlet UITextField *msg_searchTimeBeginTextField;
@property (weak, nonatomic) IBOutlet UITextField *msg_searchTimePeriodTextField;
@property (weak, nonatomic) IBOutlet UITextField *msg_searchPageTextField;
@property (weak, nonatomic) IBOutlet UITextField *msg_searchCountTextField;
@property (weak, nonatomic) IBOutlet UILabel *msg_searchResultLabel;

#pragma mark - 群组搜索

@property (weak, nonatomic) IBOutlet UITextField *group_keywordOneTextField;
@property (weak, nonatomic) IBOutlet UITextField *group_keywordTwoTextField;
@property (weak, nonatomic) IBOutlet UISwitch *group_isSearchGroupIdSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *group_isSearchGroupNameSwitch;
@property (weak, nonatomic) IBOutlet UILabel *group_searchResultLabel;

#pragma mark - 群成员搜索

@property (weak, nonatomic) IBOutlet UITextField *groupMember_groupIDOneTextField;
@property (weak, nonatomic) IBOutlet UITextField *groupMember_groupTwoTextField;
@property (weak, nonatomic) IBOutlet UITextField *groupMember_keywordOneTextField;
@property (weak, nonatomic) IBOutlet UITextField *groupMember_keywordTwoTextField;
@property (weak, nonatomic) IBOutlet UISwitch *groupMember_isSearchUserIDSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *groupMember_isSearchNickSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *groupMember_isSearchRemarkSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *groupMember_isSearchNameCardSwitch;
@property (weak, nonatomic) IBOutlet UILabel *groupMember_searchResultLabel;

#pragma mark - 好友搜索

@property (weak, nonatomic) IBOutlet UITextField *friend_keywordOneTextField;
@property (weak, nonatomic) IBOutlet UITextField *friend_keywordTwoTextField;
@property (weak, nonatomic) IBOutlet UISwitch *friend_isSearchUserIDSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *friend_isSearchNickSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *friend_isSearchRemarkSwitch;
@property (weak, nonatomic) IBOutlet UILabel *friend_searchResultLabel;

@end

@implementation TestForSearchMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.scrollView.delegate = self;
    
}

- (IBAction)actionSearchMessage:(id)sender {
    __weak typeof(self) weakSelf = self;
    
    NSString *conversationID = nil;
    if (self.msg_conversationIDTextField.text.length) {
        conversationID = self.msg_conversationIDTextField.text;
    }
    BOOL isAnd = self.msg_OrAndSwitch.isOn;
    
    
    NSMutableArray *keywordList = [NSMutableArray array];
    if (self.msg_keywordOneTextField.text.length) {
        [keywordList addObject:self.msg_keywordOneTextField.text];
    }
    if (self.msg_keywordTwoTextField.text.length) {
        [keywordList addObject:self.msg_keywordTwoTextField.text];
    }
    
    V2TIMKeywordListMatchType matchType = V2TIM_KEYWORD_LIST_MATCH_TYPE_OR;
    if (isAnd) {
        matchType = V2TIM_KEYWORD_LIST_MATCH_TYPE_AND;
    }
    
    
    NSMutableArray *senderUSerIDList = [NSMutableArray array];
    if (self.msg_senderOneTextField.text.length) {
        [senderUSerIDList addObject:self.msg_senderOneTextField.text];
    }
    if (self.msg_sendTwoTextField.text.length) {
        [senderUSerIDList addObject:self.msg_sendTwoTextField.text];
    }
    
    NSMutableArray *messageTypeList = [NSMutableArray array];
    if (self.msg_isSearchtextSwitch.isOn) {
        [messageTypeList addObject:@(V2TIM_ELEM_TYPE_TEXT)];
    }
    if (self.msg_isSearchCustomSwitch.isOn) {
        [messageTypeList addObject:@(V2TIM_ELEM_TYPE_CUSTOM)];
    }
    if (self.msg_isSearchImageSwitch.isOn) {
        [messageTypeList addObject:@(V2TIM_ELEM_TYPE_IMAGE)];
    }
    if (self.msg_isSearchVoiceSwitch.isOn) {
        [messageTypeList addObject:@(V2TIM_ELEM_TYPE_SOUND)];
    }
    if (self.msg_isSearchVideoSwtich.isOn) {
        [messageTypeList addObject:@(V2TIM_ELEM_TYPE_VIDEO)];
    }
    if (self.msg_isSearchFileSwitch.isOn) {
        [messageTypeList addObject:@(V2TIM_ELEM_TYPE_FILE)];
    }
    if (self.msg_isSearchLocationSwitch.isOn) {
        [messageTypeList addObject:@(V2TIM_ELEM_TYPE_LOCATION)];
    }
    if (self.msg_isSearchForwardSwitch.isOn) {
        [messageTypeList addObject:@(V2TIM_ELEM_TYPE_MERGER)];
    }
    
    
    V2TIMMessageSearchParam *param = [[V2TIMMessageSearchParam alloc] init];
    param.conversationID = conversationID;
    param.searchTimePosition = self.msg_searchTimeBeginTextField.text.length?[self.msg_searchTimeBeginTextField.text integerValue]:0;
    param.searchTimePeriod = self.msg_searchTimePeriodTextField.text.length?[self.msg_searchTimePeriodTextField.text integerValue]:0;
    param.pageIndex = self.msg_searchPageTextField.text.length?[self.msg_searchPageTextField.text integerValue]:0;
    param.pageSize = self.msg_searchCountTextField.text.length?[self.msg_searchCountTextField.text integerValue]:0;
    param.messageTypeList = messageTypeList.count?messageTypeList:nil;
    param.senderUserIDList = senderUSerIDList.count?senderUSerIDList:nil;
    param.keywordListMatchType = matchType;
    param.keywordList = keywordList.count?keywordList:nil;
    [V2TIMManager.sharedInstance searchLocalMessages:param succ:^(V2TIMMessageSearchResult *searchResult) {
        NSArray<V2TIMMessageSearchResultItem *> *messageSearchResultItems = searchResult.messageSearchResultItems;
        NSString *desc = [NSString stringWithFormat:@"结果:%@", messageSearchResultItems.count == 0?@"无":@(messageSearchResultItems.count)];
        for (V2TIMMessageSearchResultItem *resultItem in messageSearchResultItems) {
            NSString *conversationID = resultItem.conversationID;
            NSUInteger messageCount = resultItem.messageCount;
            desc = [desc stringByAppendingFormat:@"\nconversationID:%@, \nmessageCount:%zd", conversationID, messageCount];
            for (V2TIMMessage *v2TIMMessage in resultItem.messageList) {
                V2TIMElemType elemType = v2TIMMessage.elemType;
                NSString *content = @"";
                if (elemType == V2TIM_ELEM_TYPE_TEXT) {
                    content = [NSString stringWithFormat:@"text elem:%@", v2TIMMessage.textElem.text];
                } else if (elemType == V2TIM_ELEM_TYPE_CUSTOM) {
                    content = [NSString stringWithFormat:@"custom elem:%@", v2TIMMessage.customElem];
                } else if (elemType == V2TIM_ELEM_TYPE_IMAGE) {
                    content = [NSString stringWithFormat:@"image elem:%@", v2TIMMessage.imageElem];
                } else if (elemType == V2TIM_ELEM_TYPE_SOUND) {
                    content = [NSString stringWithFormat:@"sound elem:%@", v2TIMMessage.soundElem];
                } else if (elemType == V2TIM_ELEM_TYPE_VIDEO) {
                    content = [NSString stringWithFormat:@"video elem:%@", v2TIMMessage.videoElem];
                } else if (elemType == V2TIM_ELEM_TYPE_FILE) {
                    content = [NSString stringWithFormat:@"file elem:%@", v2TIMMessage.fileElem];
                } else if (elemType == V2TIM_ELEM_TYPE_LOCATION) {
                    content = [NSString stringWithFormat:@"location elem:%@", v2TIMMessage.locationElem];
                } else if (elemType == V2TIM_ELEM_TYPE_MERGER) {
                    content = [NSString stringWithFormat:@"merger elem:%@", v2TIMMessage.mergerElem];
                }
                desc = [desc stringByAppendingFormat:@"\n\t\t%@", content];
            }
            desc = [desc stringByAppendingFormat:@"\n", nil];
        }
        weakSelf.msg_searchResultLabel.text = desc;
    } fail:^(int code, NSString *desc) {
        weakSelf.msg_searchResultLabel.text = [NSString stringWithFormat:@"结果: code=%d, err=%@", code, desc];
    }];
}
- (IBAction)actionClearMessage:(id)sender {
    self.msg_searchResultLabel.text = @"结果:";
}

- (IBAction)actionSearchGroup:(id)sender {
    
    NSMutableArray *keywordList = [NSMutableArray array];
    if (self.group_keywordOneTextField.text.length) {
        [keywordList addObject:self.group_keywordOneTextField.text];
    }
    if (self.group_keywordTwoTextField.text.length) {
        [keywordList addObject:self.group_keywordTwoTextField.text];
    }
    
    V2TIMGroupSearchParam *param = [[V2TIMGroupSearchParam alloc] init];
    param.isSearchGroupID = self.group_isSearchGroupIdSwitch.isOn;
    param.isSearchGroupName = self.group_isSearchGroupNameSwitch.isOn;
    param.keywordList = keywordList.count?keywordList:nil;
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance searchGroups:param succ:^(NSArray<V2TIMGroupInfo *> *groupList) {
        NSString *desc = [NSString stringWithFormat:@"结果:%@", groupList.count == 0?@"无":@""];
        for (V2TIMGroupInfo *groupInfo in groupList) {
            desc = [desc stringByAppendingFormat:@"groupID:%@, groupName:%@\n\n", groupInfo.groupID, groupInfo.groupName];
        }
        weakSelf.group_searchResultLabel.text = desc;
    } fail:^(int code, NSString *desc) {
        weakSelf.group_searchResultLabel.text = [NSString stringWithFormat:@"结果: code=%d, err=%@", code, desc];
    }];
}

- (IBAction)actionClearGroup:(id)sender {
    self.group_searchResultLabel.text = @"结果:";
}

- (IBAction)actionSearchGroupMember:(id)sender {
    
    NSMutableArray *groupIDList = [NSMutableArray array];
    if (self.groupMember_groupIDOneTextField.text.length) {
        [groupIDList addObject:self.groupMember_groupIDOneTextField.text];
    }
    if (self.groupMember_groupTwoTextField.text.length) {
        [groupIDList addObject:self.groupMember_groupTwoTextField.text];
    }
    
    NSMutableArray *keywordList = [NSMutableArray array];
    if (self.groupMember_keywordOneTextField.text.length) {
        [keywordList addObject:self.groupMember_keywordOneTextField.text];
    }
    if (self.groupMember_keywordTwoTextField.text.length) {
        [keywordList addObject:self.groupMember_keywordTwoTextField.text];
    }
    
    V2TIMGroupMemberSearchParam *param = [[V2TIMGroupMemberSearchParam alloc] init];
    param.groupIDList = groupIDList.count?groupIDList:nil;
    param.keywordList = keywordList.count?keywordList:nil;
    param.isSearchMemberUserID = self.groupMember_isSearchUserIDSwitch.isOn;
    param.isSearchMemberNickName = self.groupMember_isSearchNickSwitch.isOn;
    param.isSearchMemberRemark = self.groupMember_isSearchRemarkSwitch.isOn;
    param.isSearchMemberNameCard = self.groupMember_isSearchNameCardSwitch.isOn;
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance searchGroupMembers:param succ:^(NSDictionary<NSString *,NSArray<V2TIMGroupMemberFullInfo *> *> *memberList) {
        __block NSString *desc = [NSString stringWithFormat:@"结果:%@", memberList.count == 0?@"无":@""];
        [memberList enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<V2TIMGroupMemberFullInfo *> * _Nonnull obj, BOOL * _Nonnull stop) {
            NSString *groupID = key;
            desc = [desc stringByAppendingFormat:@"groupID:%@", groupID];
            NSArray *list = obj;
            for (V2TIMGroupMemberFullInfo *memberFullInfo in list) {
                desc = [desc stringByAppendingFormat:@"\n\tmemberID:%@, memberNickname:%@, memberRemark:%@, memberNameCard:%@", memberFullInfo.userID, memberFullInfo.nickName, memberFullInfo.friendRemark, memberFullInfo.nameCard];
            }
            desc = [desc stringByAppendingFormat:@"\n\n", nil];
        }];
        weakSelf.groupMember_searchResultLabel.text = desc;
    } fail:^(int code, NSString *desc) {
        weakSelf.groupMember_searchResultLabel.text = [NSString stringWithFormat:@"结果: code=%d, err=%@", code, desc];
    }];
    
}

- (IBAction)actionClearGroupMember:(id)sender {
    self.groupMember_searchResultLabel.text = @"结果:";
}
- (IBAction)actionSearchFriend:(id)sender {
    
    NSMutableArray *keywordList = [NSMutableArray array];
    if (self.friend_keywordOneTextField.text.length) {
        [keywordList addObject:self.friend_keywordOneTextField.text];
    }
    if (self.friend_keywordTwoTextField.text.length) {
        [keywordList addObject:self.friend_keywordTwoTextField.text];
    }
    
    V2TIMFriendSearchParam *param = [[V2TIMFriendSearchParam alloc] init];
    param.keywordList = keywordList?keywordList:nil;
    param.isSearchUserID = self.friend_isSearchUserIDSwitch.isOn;
    param.isSearchNickName = self.friend_isSearchNickSwitch.isOn;
    param.isSearchRemark = self.friend_isSearchRemarkSwitch.isOn;
    __weak typeof(self) weakSelf = self;
    [V2TIMManager.sharedInstance searchFriends:param succ:^(NSArray<V2TIMFriendInfoResult *> *resultList) {
        NSString *desc = [NSString stringWithFormat:@"结果:%@", resultList.count == 0?@"无":@""];
        for (V2TIMFriendInfoResult *friendInfoResult in resultList) {
            V2TIMFriendInfo *friendInfo = friendInfoResult.friendInfo;
            desc = [desc stringByAppendingFormat:@"userID:%@, nickname:%@, remark:%@", friendInfo.userID, friendInfo.userFullInfo.nickName, friendInfo.friendRemark];
        }
        weakSelf.friend_searchResultLabel.text = desc;
    } fail:^(int code, NSString *desc) {
        weakSelf.friend_searchResultLabel.text = [NSString stringWithFormat:@"结果: code=%d, err=%@", code, desc];
    }];
}

- (IBAction)actionClearFriend:(id)sender {
    
    self.friend_searchResultLabel.text = @"结果:";
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
