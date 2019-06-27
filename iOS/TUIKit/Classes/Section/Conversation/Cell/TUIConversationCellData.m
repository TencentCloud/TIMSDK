//
//  TUIConversationCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/16.
//

#import "TUIConversationCellData.h"
#import "THeader.h"
#import "UIImage+TUIKIT.h"
#import "TIMUserProfile+DataProvider.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TIMMessage+DataProvider.h"
#import "TUIKit.h"

@implementation TUIConversationCellData

- (instancetype)initWithConversation:(TIMConversation *)conv
{
    self = [super init];
    
    _unRead = [conv getUnReadMessageNum];
    _subTitle = [self getLastDisplayString:conv];
    _convId = [conv getReceiver];
    _convType = [conv getType];
    _title = _convId;
    if([conv getType] == TIM_C2C){
        @weakify(self)
        TIMUserProfile *user = [[TIMFriendshipManager sharedInstance] queryUserProfile:_convId];
        if (user) {
            _title = [user showName];
            _avatarUrl = [NSURL URLWithString:user.faceURL];
        } else {
            [[TIMFriendshipManager sharedInstance] getUsersProfile:@[_convId] forceUpdate:YES succ:^(NSArray<TIMUserProfile *> *profiles) {
                @strongify(self)
                TIMUserProfile *user = profiles.firstObject;
                if (user) {
                    self.title = [user showName];
                    self.avatarUrl = [NSURL URLWithString:user.faceURL];
                }
            } fail:nil];
        }
        _avatarImage = DefaultAvatarImage;
    } else if([conv getType] == TIM_GROUP){
        _avatarImage = DefaultGroupAvatarImage;
        _title = [conv getGroupName];
    }
    _time = [conv getLastMsg].timestamp;
    
    [self observeNotification];
    
    return self;
}
- (CGFloat)heightOfWidth:(CGFloat)width
{
    return TConversationCell_Height;
}

- (NSString *)getLastDisplayString:(TIMConversation *)conv
{
    NSString *str = @"";
    TIMMessageDraft *draft = [conv getDraft];
    if(draft){
        for (int i = 0; i < draft.elemCount; ++i) {
            TIMElem *elem = [draft getElem:i];
            if([elem isKindOfClass:[TIMTextElem class]]){
                TIMTextElem *text = (TIMTextElem *)elem;
                str = [NSString stringWithFormat:@"[草稿]%@", text.text];
                break;
            }
            else{
                continue;
            }
        }
        return str;
    }
    
    TIMMessage *msg = [conv getLastMsg];
    str = [msg getDisplayString];
    return str;
}

- (void)observeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(convChanged:)
                                                 name:TUIKitNotification_TIMRefreshListener
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)convChanged:(NSNotification *)no
{
    NSArray *array = no.object;
    if ([array isKindOfClass:[NSArray class]]) {
        for (TIMConversation *conv in array) {
            if ([conv isKindOfClass:[TIMConversation class]]) {
                if ([[conv getReceiver] isEqualToString:_convId]) {
                    if(_convType == TIM_C2C){
                        @weakify(self)
                        TIMUserProfile *user = [[TIMFriendshipManager sharedInstance] queryUserProfile:_convId];
                        if (user) {
                            self.title = [user showName];
                            self.avatarUrl = [NSURL URLWithString:user.faceURL];
                        } else {
                            [[TIMFriendshipManager sharedInstance] getUsersProfile:@[_convId] forceUpdate:YES succ:^(NSArray<TIMUserProfile *> *profiles) {
                                @strongify(self)
                                TIMUserProfile *user = profiles.firstObject;
                                if (user) {
                                    self.title = [user showName];
                                    self.avatarUrl = [NSURL URLWithString:user.faceURL];
                                }
                            } fail:nil];
                        }
                    } else if(_convType == TIM_GROUP){
                        self.title = [conv getGroupName];
                    }
                }
            }
        }
    }
}

@end
