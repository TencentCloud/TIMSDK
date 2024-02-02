//
//  TUIEmojiExtensionObserver.m
//  TUIEmojiPlugin
//
//  Created by cologne on 2023/11/22.
//

#import "TUIEmojiExtensionObserver.h"

#import <TIMCommon/TIMPopActionProtocol.h>
#import <TIMCommon/TUIMessageCell.h>
#import <TUIChat/TUIChatPopMenu.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>
#import <TUICore/UIView+TUILayout.h>
#import <TUICore/TUILogin.h>
#import "TUIReactPopRecentView.h"
#import "TUIReactPopEmojiView.h"
#import "TUIReactPreview.h"
#import "TUIReactModel.h"
#import "TUIEmojiReactDataProvider.h"
#import "TUIMessageCellData+Reaction.h"
#import "TUIReactPreview_Minimalist.h"
#import "TUIReactMembersController.h"
#import "TUIReactPopContextRecentView.h"
#import <TUIChat/TUIChatPopContextController.h>
#import "TUIEmojiMessageReactPreLoadProvider.h"
#import "TUIReactUtil.h"

@interface TUIEmojiExtensionObserver () <TUIExtensionProtocol>

@property(nonatomic, weak) UINavigationController *navVC;
@property(nonatomic, weak) TUICommonTextCellData *cellData;

@end

@implementation TUIEmojiExtensionObserver

static id gShareInstance = nil;

+ (void)load {

    // UI extensions in pop menu when message is long pressed.
    
    [TUICore registerExtension:TUICore_TUIChatExtension_ChatPopMenuReactRecentView_ClassicExtensionID object:TUIEmojiExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIChatExtension_ChatPopMenuReactRecentView_MinimalistExtensionID object:TUIEmojiExtensionObserver.shareInstance];

    [TUICore registerExtension:TUICore_TUIChatExtension_ChatPopMenuReactDetailView_ClassicExtensionID object:TUIEmojiExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIChatExtension_ChatPopMenuReactDetailView_MinimalistExtensionID object:TUIEmojiExtensionObserver.shareInstance];

    
    [TUICore registerExtension:TUICore_TUIChatExtension_ChatMessageReactPreview_ClassicExtensionID object:TUIEmojiExtensionObserver.shareInstance];
    [TUICore registerExtension:TUICore_TUIChatExtension_ChatMessageReactPreview_MinimalistExtensionID object:TUIEmojiExtensionObserver.shareInstance];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      gShareInstance = [[self alloc] init];
    });
    return gShareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setupNotify];
    }
    return self;
}

- (void)setupNotify {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchReactListByCellDatas:)
                                                 name:@"TUIKitFetchReactNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSucceeded) name:TUILoginSuccessNotification object:nil];

}
#pragma mark - TUIKitFetchReactNotification

- (void)fetchReactListByCellDatas:(NSNotification *)notification {
    
    NSArray<TUIMessageCellData *> *uiMsgs = notification.object;
    
    TUIEmojiMessageReactPreLoadProvider * preLoadProvider = [[TUIEmojiMessageReactPreLoadProvider alloc] init];
    
    [preLoadProvider getMessageReactions:uiMsgs maxUserCountPerReaction:5 succ:^{
        for (TUIMessageCellData *cellData in uiMsgs) {
            if (cellData.msgID) {
                if (cellData.reactValueChangedCallback) {
                    cellData.reactValueChangedCallback(cellData.reactdataProvider.reactArray);
                }
            }
        }
    } fail:^(int code, NSString *desc) {
        
    }];
}
#pragma mark - TUIExtensionProtocol
- (BOOL)onRaiseExtension:(NSString *)extensionID parentView:(UIView *)parentView param:(nullable NSDictionary *)param {
    if ([extensionID isEqualToString:TUICore_TUIChatExtension_ChatPopMenuReactRecentView_ClassicExtensionID]) {
        TUIChatPopMenu *delegateView = [param objectForKey:TUICore_TUIChatExtension_ChatPopMenuReactRecentView_Delegate];
        if (![parentView isKindOfClass:UIView.class]) {
            return NO;
        }
        
        TUIReactPopRecentView * emojiRecentView = [[TUIReactPopRecentView alloc] initWithFrame:CGRectZero];
        [parentView addSubview:emojiRecentView];
        emojiRecentView.frame = CGRectMake(0, 0, parentView.mm_w, 44);
        emojiRecentView.backgroundColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF");
        emojiRecentView.needShowbottomLine = YES;
        if ([delegateView isKindOfClass:TUIChatPopMenu.class]) {
            emojiRecentView.delegateView = delegateView;
        }
        return YES;
    }
    else if ([extensionID isEqualToString:TUICore_TUIChatExtension_ChatPopMenuReactDetailView_ClassicExtensionID]) {

        TUIChatPopMenu *delegateView = [param objectForKey:TUICore_TUIChatExtension_ChatPopMenuReactRecentView_Delegate];
        if (![parentView isKindOfClass:UIView.class]) {
            return NO;
        }
        
        TUIReactPopEmojiView *emojiAdvanceView = [[TUIReactPopEmojiView alloc] initWithFrame:CGRectMake(0, 44 - 0.5, parentView.mm_w, TChatEmojiView_CollectionHeight + 10 + TChatEmojiView_Page_Height)];
        [parentView addSubview:emojiAdvanceView];
        [emojiAdvanceView setData:(id)[TIMConfig defaultConfig].chatPopDetailGroups];
        if (delegateView) {
            emojiAdvanceView.delegateView = delegateView;
        }
        emojiAdvanceView.alpha = 0;
        emojiAdvanceView.faceCollectionView.scrollEnabled = YES;
        emojiAdvanceView.faceCollectionView.delaysContentTouches = NO;
        emojiAdvanceView.backgroundColor = TUIChatDynamicColor(@"chat_pop_menu_bg_color", @"#FFFFFF");
        emojiAdvanceView.faceCollectionView.backgroundColor = emojiAdvanceView.backgroundColor;

        return YES;
    }
    else if ([extensionID isEqualToString:TUICore_TUIChatExtension_ChatMessageReactPreview_ClassicExtensionID]) {

        TUIMessageCell *delegateView = [param objectForKey:TUICore_TUIChatExtension_ChatMessageReactPreview_Delegate];
        NSMutableDictionary *cacheMap = parentView.tui_extValueObj;
        TUIReactPreview *cacheView = nil;
        if (!cacheMap){
            cacheMap = [NSMutableDictionary dictionaryWithCapacity:3];
        }
        else if ([cacheMap isKindOfClass:NSDictionary.class]) {
            cacheView = [cacheMap objectForKey:NSStringFromClass(TUIReactPreview.class)];
        }
        else {
            //cacheMap is not a dic ;
        }
        if (cacheView) {
            [cacheView removeFromSuperview];
            cacheView = nil;
        }
        TUIReactPreview *tagView = [[TUIReactPreview alloc] init];
        [parentView addSubview:tagView];
        [cacheMap setObject:tagView forKey:NSStringFromClass(TUIReactPreview.class)];
        parentView.tui_extValueObj  = cacheMap;

        __weak typeof(self) weakSelf = self;
        __weak typeof(tagView) weakTagView = tagView;

        if (delegateView) {
            tagView.delegateCell = (id)delegateView;
            if (!delegateView.messageData.reactdataProvider) {
                [delegateView.messageData setupReactDataProvider];
            }
            delegateView.messageData.reactValueChangedCallback = ^(NSArray<TUIReactModel *> * _Nonnull tagsArray) {
                if (weakTagView) {
                    [weakTagView refreshByArray:(id)tagsArray];
                }
            };
        }
        
        if (delegateView.messageData.reactdataProvider.reactArray.count > 0) {
            weakTagView.listArrM = [NSMutableArray arrayWithArray:delegateView.messageData.reactdataProvider.reactArray];
            [weakTagView updateView];
            if (!CGSizeEqualToSize(CGSizeZero, delegateView.messageData.messageContainerAppendSize)) {
                delegateView.messageData.messageContainerAppendSize = weakTagView.frame.size;
                [weakTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(parentView);
                    make.leading.mas_equalTo(parentView);
                    make.width.mas_equalTo(parentView);
                    make.height.mas_equalTo(delegateView.messageData.messageContainerAppendSize);
                }];
            }
            else{
                delegateView.messageData.messageContainerAppendSize = weakTagView.frame.size;
                [weakTagView notifyReactionChanged];
            }
        }
        
        tagView.emojiClickCallback = ^(TUIReactModel *_Nonnull model) {
            [weakSelf emojiClick:parentView ReactMessage:delegateView.messageData faceList:weakTagView.listArrM];
        };
        
        tagView.userClickCallback = ^(TUIReactModel * _Nonnull model) {
            [weakSelf emojiClick:parentView ReactMessage:delegateView.messageData faceList:weakTagView.listArrM];
        };
        
        return YES;
    }
    
    //Minimalist
    else if ([extensionID isEqualToString:TUICore_TUIChatExtension_ChatPopMenuReactRecentView_MinimalistExtensionID]) {
        
        TUIChatPopContextController *delegateVC = [param objectForKey:TUICore_TUIChatExtension_ChatPopMenuReactRecentView_Delegate];
        if (![parentView isKindOfClass:UIView.class]) {
            return NO;
        }
    
        TUIReactPopContextRecentView * emojiRecentView = [[TUIReactPopContextRecentView alloc] initWithFrame:CGRectZero];
        [parentView addSubview:emojiRecentView];
        emojiRecentView.frame = CGRectMake(0, 0,MAX(kTIMDefaultEmojiSize.width *8,parentView.mm_w), parentView.mm_h);
        emojiRecentView.backgroundColor = [UIColor whiteColor];
        emojiRecentView.needShowbottomLine = YES;
        if ([delegateVC isKindOfClass:TUIChatPopContextController.class]) {
            emojiRecentView.delegateVC = delegateVC;
        }
        return YES;
    }
    else if ([extensionID isEqualToString:TUICore_TUIChatExtension_ChatMessageReactPreview_MinimalistExtensionID]) {
        
        TUIMessageCell *delegateView = [param objectForKey:TUICore_TUIChatExtension_ChatMessageReactPreview_Delegate];
        NSMutableDictionary *cacheMap = parentView.tui_extValueObj;
        TUIReactPreview_Minimalist *cacheView = nil;
        if (!cacheMap){
            cacheMap = [NSMutableDictionary dictionaryWithCapacity:3];
        }
        else if ([cacheMap isKindOfClass:NSDictionary.class]) {
            cacheView = [cacheMap objectForKey:NSStringFromClass(TUIReactPreview_Minimalist.class)];
        }
        else {
            //cacheMap is not a dic ;
        }
        if (cacheView) {
            [cacheView removeFromSuperview];
            cacheView = nil;
        }

        TUIReactPreview_Minimalist *tagView = [[TUIReactPreview_Minimalist alloc] init];
        [parentView addSubview:tagView];
        [cacheMap setObject:tagView forKey:NSStringFromClass(TUIReactPreview_Minimalist.class)];
        parentView.tui_extValueObj  = cacheMap;

        __weak typeof(self) weakSelf = self;
        __weak typeof(tagView) weakTagView = tagView;

        if (delegateView) {
            tagView.delegateCell = (id)delegateView;
            if (!delegateView.messageData.reactdataProvider) {
                [delegateView.messageData setupReactDataProvider];
            }
            delegateView.messageData.reactValueChangedCallback = ^(NSArray<TUIReactModel *> * _Nonnull tagsArray) {
                if (weakTagView) {
                    [weakTagView refreshByArray:(id)tagsArray];
                }
            };
        }
        
        if (delegateView.messageData.reactdataProvider.reactArray.count > 0) {
            weakTagView.reactlistArr = [NSMutableArray arrayWithArray:delegateView.messageData.reactdataProvider.reactArray];
            [weakTagView updateView];
            [weakTagView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (delegateView.messageData.direction == MsgDirectionIncoming) {
                    make.leading.mas_greaterThanOrEqualTo(delegateView.container).mas_offset(kScale390(16));
                } else {
                    make.trailing.mas_lessThanOrEqualTo(delegateView.container).mas_offset(-kScale390(16));
                }
                make.width.mas_equalTo(delegateView.container);
                make.top.mas_equalTo(delegateView.container.mas_bottom).mas_offset(-4);
                make.height.mas_equalTo(20);
            }];
            if (CGSizeEqualToSize(CGSizeZero, delegateView.messageData.messageContainerAppendSize)) {
                if (weakTagView) {
                    [weakTagView refreshByArray:delegateView.messageData.reactdataProvider.reactArray];
                }
            }
        }
        
        tagView.emojiClickCallback = ^(TUIReactModel *_Nonnull model) {
            // goto detailPage
            [weakSelf emojiClick:parentView ReactMessage:delegateView.messageData faceList:weakTagView.reactlistArr];
        };
        
        return YES;
    }
    return NO;
}


- (void)emojiClick:(UIView *)view
    ReactMessage:(TUIMessageCellData *)data
                 faceList:(NSArray<TUIReactModel *> *)listModel {
    TUIReactMembersController *detailController = [[TUIReactMembersController alloc] init];
    detailController.modalPresentationStyle = UIModalPresentationCustom;
    detailController.tagsArray = listModel;
    detailController.originData = data;
    [view.mm_viewController presentViewController:detailController animated:YES completion:nil];
}

- (void)onLoginSucceeded {
    [TUIReactUtil checkCommercialAbility];
}

@end
