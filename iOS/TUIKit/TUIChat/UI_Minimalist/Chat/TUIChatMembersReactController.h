//
//  TUIChatMembersReactController.h
//  TUIChat
//
//  Created by wyl on 2022/10/31.
//

#import "TUIChatFlexViewController.h"
#import "TUITagsModel.h"
#import "TUIEmojiCellData.h"
#import "TUIMessageCellData.h"
#import "TUIChatConversationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatMembersReactSubController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray<TUIEmojiCellData *> *data;

@property (nonatomic,strong) TUIMessageCellData *originData;

@end

@interface TUIChatMembersReactController : TUIChatFlexViewController

@property (nonatomic,strong) TUIMessageCellData *originData;

@property (nonatomic,strong) NSArray <TUITagsModel *>* tagsArray;

@property (nonatomic, strong) TUIChatConversationModel *conversationData;

- (instancetype)initWithChatConversationModel:(TUIChatConversationModel *) conversationData ;
@end

NS_ASSUME_NONNULL_END
