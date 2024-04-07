//
//  TUIConversationSelectController.m
//  Pods
//
//  Created by harvy on 2020/12/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIConversationSelectController.h"
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSDictionary+TUISafe.h>
#import <TUICore/TUICore.h>
#import "TUIConversationCell.h"
#import "TUIConversationCellData.h"
#import "TUIConversationSelectDataProvider.h"

typedef void (^TUIConversationSelectCompletHandler)(BOOL);

@interface TUIConversationSelectController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) TUIContactListPicker *pickerView;
@property(nonatomic, strong) TUICommonTableViewCell *headerView;

@property(nonatomic, assign) BOOL enableMuliple;
@property(nonatomic, strong) NSMutableArray<TUIConversationCellData *> *currentSelectedList;

@property(nonatomic, strong) TUIConversationSelectDataProvider *dataProvider;

@property(nonatomic, weak) UIViewController *showContactSelectVC;

@end

@implementation TUIConversationSelectController

static NSString *const Id = @"con";

#pragma mark - Life
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateLayout];
}

- (TUIConversationSelectDataProvider *)dataProvider {
    if (!_dataProvider) {
        _dataProvider = [[TUIConversationSelectDataProvider alloc] init];
        [_dataProvider loadConversations];
    }
    return _dataProvider;
}

- (void)dealloc {
    NSLog(@"%s dealloc", __FUNCTION__);
}

#pragma mark - API
+ (instancetype)showIn:(UIViewController *)presentVC {
    TUIConversationSelectController *vc = [[TUIConversationSelectController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    UIViewController *pVc = presentVC;
    if (pVc == nil) {
        pVc = UIApplication.sharedApplication.keyWindow.rootViewController;
    }
    [pVc presentViewController:nav animated:YES completion:nil];
    return vc;
}

#pragma mark - UI
- (void)setupViews {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TIMCommonLocalizableString(Cancel)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(doCancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:TIMCommonLocalizableString(Multiple)
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(doMultiple)];

    self.view.backgroundColor = [UIColor whiteColor];

    _headerView = [[TUICommonTableViewCell alloc] init];
    _headerView.textLabel.text = TIMCommonLocalizableString(TUIKitRelayTargetCreateNewChat);
    _headerView.textLabel.font = [UIFont systemFontOfSize:15.0];
    _headerView.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [_headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCreateSessionOrSelectContact)]];

    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = self.headerView;
    [_tableView registerClass:TUIConversationCell.class forCellReuseIdentifier:Id];
    [self.view addSubview:_tableView];

    _pickerView = [[TUIContactListPicker alloc] init];

    [_pickerView setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [_pickerView setHidden:YES];
    [_pickerView.accessoryBtn addTarget:self action:@selector(doPickerDone) forControlEvents:UIControlEventTouchUpInside];
    __weak typeof(self) weakSelf = self;
    _pickerView.onCancel = ^(TUICommonContactSelectCellData *data) {
      TUIConversationCellData *tmp = nil;
      for (TUIConversationCellData *convCellData in weakSelf.currentSelectedList) {
          if ([convCellData.conversationID isEqualToString:data.identifier]) {
              tmp = convCellData;
              break;
          }
      }
      if (tmp == nil) {
          return;
      }

      tmp.selected = NO;
      [weakSelf.currentSelectedList removeObject:tmp];
      [weakSelf updatePickerView];
      [weakSelf.tableView reloadData];
    };
    [self.view addSubview:_pickerView];

    @weakify(self);
    [RACObserve(self.dataProvider, dataList) subscribeNext:^(id _Nullable x) {
      @strongify(self);
      [self.tableView reloadData];
    }];
}

- (void)updateLayout {
    [self.pickerView setHidden:!self.enableMuliple];
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 55);
    _headerView.textLabel.text =
        self.enableMuliple ? TIMCommonLocalizableString(TUIKitRelayTargetSelectFromContacts) : TIMCommonLocalizableString(TUIKitRelayTargetCreateNewChat);

    if (!self.enableMuliple) {
        self.tableView.frame = self.view.bounds;
        return;
    }

    CGFloat pH = 55;
    CGFloat pMargin = 0;
    if (@available(iOS 11.0, *)) {
        pMargin = self.view.safeAreaInsets.bottom;
    }
    [self.pickerView setFrame:CGRectMake(0, self.view.bounds.size.height - pH - pMargin, self.view.bounds.size.width, pH + pMargin)];
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - pH - pMargin);
}

- (void)updatePickerView {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (TUIConversationCellData *convCellData in self.currentSelectedList) {
        TUICommonContactSelectCellData *data = [[TUICommonContactSelectCellData alloc] init];
        data.avatarUrl = [NSURL URLWithString:convCellData.faceUrl];
        data.avatarImage = convCellData.avatarImage;
        data.title = convCellData.title;
        data.identifier = convCellData.conversationID;
        [arrayM addObject:data];
    }
    self.pickerView.selectArray = [NSArray arrayWithArray:arrayM];
}

#pragma mark - Action
- (void)doCancel {
    if (self.enableMuliple) {
        self.enableMuliple = NO;

        for (TUIConversationCellData *cellData in self.dataProvider.dataList) {
            cellData.selected = NO;
        }

        [self.currentSelectedList removeAllObjects];
        self.pickerView.selectArray = @[];
        [self updatePickerView];
        [self updateLayout];
        [self.tableView reloadData];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)doMultiple {
    self.enableMuliple = YES;
    [self updateLayout];
    [self.tableView reloadData];
}

- (void)onCreateSessionOrSelectContact {
    NSMutableArray *ids = NSMutableArray.new;
    for (TUIConversationCellData *cd in self.currentSelectedList) {
        if (![cd.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            if (cd.userID.length > 0) {
                [ids addObject:cd.userID];
            }
        }
    }

    @weakify(self);
    void (^selectContactCompletion)(NSArray<TUICommonContactSelectCellData *> *) = ^(NSArray<TUICommonContactSelectCellData *> *array) {
      @strongify(self);
      [self dealSelectBlock:array];
    };

    UIViewController *vc = [TUICore createObject:TUICore_TUIContactObjectFactory
                                             key:TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod
                                           param:@{
                                               TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_DisableIdsKey : ids,
                                               TUICore_TUIContactObjectFactory_GetContactSelectControllerMethod_CompletionKey : selectContactCompletion,
                                           }];

    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];
    self.showContactSelectVC = vc;
}

- (void)dealSelectBlock:(NSArray<TUICommonContactSelectCellData *> *)array {
    NSArray<TUICommonContactSelectCellData *> *selectArray = array;
    if (![selectArray.firstObject isKindOfClass:TUICommonContactSelectCellData.class]) {
        NSAssert(NO, @"Error value type");
    }
    if (self.enableMuliple) {
        /**
         * Multiple selection: Select from address book -> Create conversation for each contact -> Every contact will be displayed in pickerView
         */
        for (TUICommonContactSelectCellData *contact in selectArray) {
            if ([self existInSelectedArray:contact.identifier]) {
                continue;
            }
            TUIConversationCellData *conv = [self findItemInDataListArray:contact.identifier];
            if (!conv) {
                conv = [[TUIConversationCellData alloc] init];
                conv.conversationID = contact.identifier;
                conv.userID = contact.identifier;
                conv.groupID = @"";
                conv.avatarImage = contact.avatarImage;
                conv.faceUrl = contact.avatarUrl.absoluteString;
            } else {
                conv.selected = !conv.selected;
            }

            [self.currentSelectedList addObject:conv];
        }
        [self updatePickerView];
        [self.tableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        /**
         * Single Choice: Create a new chat (or a group chat if there are multiple people) -> Create a group chat for the selected contact -> Forward directly
         */
        if (selectArray.count <= 1) {
            TUICommonContactSelectCellData *contact = selectArray.firstObject;
            if (contact) {
                TUIConversationCellData *conv = [[TUIConversationCellData alloc] init];
                conv.conversationID = contact.identifier;
                conv.userID = contact.identifier;
                conv.groupID = @"";
                conv.avatarImage = contact.avatarImage;
                conv.faceUrl = contact.avatarUrl.absoluteString;
                self.currentSelectedList = [NSMutableArray arrayWithArray:@[ conv ]];
                [self tryFinishSelected:^(BOOL finished) {
                  if (finished) {
                      [self notifyFinishSelecting];
                      [self dismissViewControllerAnimated:YES completion:nil];
                  }
                }];
            }
            return;
        }
        [self tryFinishSelected:^(BOOL finished) {
          if (finished) {
              [self createGroupWithContacts:selectArray
                                 completion:^(BOOL success) {
                                   if (success) {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   }
                                 }];
          }
        }];
    }
}
- (BOOL)existInSelectedArray:(NSString *)identifier {
    for (TUIConversationCellData *cellData in self.currentSelectedList) {
        if (cellData.userID.length && [cellData.userID isEqualToString:identifier]) {
            return YES;
        }
    }
    return NO;
}

- (TUIConversationCellData *)findItemInDataListArray:(NSString *)identifier {
    for (TUIConversationCellData *cellData in self.dataProvider.dataList) {
        if (cellData.userID.length && [cellData.userID isEqualToString:identifier]) {
            return cellData;
        }
    }
    return nil;
}

- (void)doPickerDone {
    __weak typeof(self) weakSelf = self;
    [self tryFinishSelected:^(BOOL finished) {
      if (finished) {
          [self notifyFinishSelecting];
          [weakSelf dismissViewControllerAnimated:YES completion:nil];
      }
    }];
}

// confirm whether to forward or not
- (void)tryFinishSelected:(TUIConversationSelectCompletHandler)handler {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:TIMCommonLocalizableString(TUIKitRelayConfirmForward)
                                                                     message:nil
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alertVc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Cancel)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                         if (handler) {
                                                             handler(NO);
                                                         }
                                                       }]];
    [alertVc tuitheme_addAction:[UIAlertAction actionWithTitle:TIMCommonLocalizableString(Confirm)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                         if (handler) {
                                                             handler(YES);
                                                         }
                                                       }]];
    [self presentViewController:alertVc animated:YES completion:nil];
}

// notify others that the user has finished selecting conversations
- (void)notifyFinishSelecting {
    if (self.navigateValueCallback) {
        NSMutableArray *temMArr = [NSMutableArray arrayWithCapacity:self.currentSelectedList.count];
        for (TUIConversationCellData *cellData in self.currentSelectedList) {
            [temMArr addObject:@{
                TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_ConversationID : cellData.conversationID ?: @"",
                TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_Title : cellData.title ?: @"",
                TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_UserID : cellData.userID ?: @"",
                TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList_GroupID : cellData.groupID ?: @"",
            }];
        }
        self.navigateValueCallback(@{TUICore_TUIConversationObjectFactory_ConversationSelectVC_ResultList : temMArr});
    }
}

// create a new group to receive the forwarding messages
- (void)createGroupWithContacts:(NSArray *)contacts completion:(void (^)(BOOL success))completion {
    @weakify(self);
    void (^createGroupCompletion)(BOOL, NSString *, NSString *) = ^(BOOL success, NSString *groupID, NSString *groupName) {
      @strongify(self);
      if (!success) {
          [TUITool makeToast:TIMCommonLocalizableString(TUIKitRelayTargetCrateGroupError)];
          if (completion) {
              completion(NO);
          }
          return;
      }
      TUIConversationCellData *cellData = [[TUIConversationCellData alloc] init];
      cellData.groupID = groupID;
      cellData.title = groupName;
      self.currentSelectedList = [NSMutableArray arrayWithArray:@[ cellData ]];
      [self notifyFinishSelecting];
      if (completion) {
          completion(YES);
      }
    };
    NSDictionary *param = @{
        TUICore_TUIGroupService_CreateGroupMethod_GroupTypeKey : GroupType_Meeting,
        TUICore_TUIGroupService_CreateGroupMethod_OptionKey : @(V2TIM_GROUP_ADD_ANY),
        TUICore_TUIGroupService_CreateGroupMethod_ContactsKey : contacts,
        TUICore_TUIGroupService_CreateGroupMethod_CompletionKey : createGroupCompletion
    };
    [TUICore callService:TUICore_TUIGroupService method:TUICore_TUIGroupService_CreateGroupMethod param:param];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataProvider.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TUIConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:Id forIndexPath:indexPath];
    if (indexPath.row < 0 || indexPath.row >= self.dataProvider.dataList.count) {
        return cell;
    }
    TUIConversationCellData *cellData = self.dataProvider.dataList[indexPath.row];
    cellData.showCheckBox = self.enableMuliple;
    [cell fillWithData:cellData];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    TUIConversationCellData *cellData = self.dataProvider.dataList[indexPath.row];
    cellData.selected = !cellData.selected;
    if (!self.enableMuliple) {
        self.currentSelectedList = [NSMutableArray arrayWithArray:@[ cellData ]];
        __weak typeof(self) weakSelf = self;
        [self tryFinishSelected:^(BOOL finished) {
          if (finished) {
              [self notifyFinishSelecting];
              [weakSelf dismissViewControllerAnimated:YES completion:nil];
          }
        }];
        return;
    }

    if ([self.currentSelectedList containsObject:cellData]) {
        [self.currentSelectedList removeObject:cellData];
    } else {
        [self.currentSelectedList addObject:cellData];
    }

    [self updatePickerView];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *titleView = [[UIView alloc] init];
    titleView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    titleView.bounds = CGRectMake(0, 0, self.tableView.bounds.size.width, 30);
    UILabel *label = [[UILabel alloc] init];
    label.text = TIMCommonLocalizableString(TUIKitRelayRecentMessages);
    label.font = [UIFont systemFontOfSize:12.0];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentLeft;
    [titleView addSubview:label];
    label.frame = CGRectMake(10, 0, self.tableView.bounds.size.width - 10, 30);
    return titleView;
}

#pragma mark - Lazy

- (NSMutableArray<TUIConversationCellData *> *)currentSelectedList {
    if (_currentSelectedList == nil) {
        _currentSelectedList = [NSMutableArray array];
    }
    return _currentSelectedList;
}

@end
