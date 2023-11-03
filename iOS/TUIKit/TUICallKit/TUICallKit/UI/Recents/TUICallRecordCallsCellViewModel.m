//
//  TUICallRecordCallsCellViewModel.m
//  TUICallKit
//
//  Created by noah on 2023/2/28.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICallRecordCallsCellViewModel.h"
#import "TUICallEngineHeader.h"
#import "TUITool.h"
#import "TUIConfig.h"
#import "CallingLocalized.h"
#import "TUICallKitUserInfoUtils.h"
#import "TUICallingUserModel.h"

@interface TUICallRecordCallsCellViewModel ()

@property (nonatomic, readwrite, strong) UIImage *avatarImage;
@property (nonatomic, readwrite, copy) NSString *faceURL;
@property (nonatomic, readwrite, copy) NSString *titleLabelStr;
@property (nonatomic, readwrite, copy) NSString *mediaTypeImageStr;
@property (nonatomic, readwrite, copy) NSString *resultLabelStr;
@property (nonatomic, readwrite, copy) NSString *timeLabelStr;
@property (nonatomic, readwrite, strong) TUICallRecords *callRecord;

@end

@implementation TUICallRecordCallsCellViewModel

- (instancetype)initWithCallRecord:(TUICallRecords *)callRecord {
    self = [super init];
    if (self) {
        _callRecord = callRecord;
        [self configAvatarImage:callRecord];
        [self configResultWith:callRecord.result];
        [self configMediaTypeImageNameWith:callRecord.mediaType];
        [self configTitleWith:callRecord];
        [self configTimeWith:callRecord];
    }
    return self;
}

- (void)configAvatarImage:(TUICallRecords *)callRecord {
    if (TUICallSceneGroup == callRecord.scene) {
        NSMutableSet *inviteList = [NSMutableSet setWithArray:callRecord.inviteList ?: @[]];
        if (callRecord.inviter) {
            [inviteList addObject:callRecord.inviter];
        }
        [self configGroupAvatarImage:[inviteList allObjects]];
    } else if (TUICallSceneSingle == callRecord.scene)  {
        [self configSingleAvatarImage:callRecord];
    } else {
        self.avatarImage = DefaultGroupAvatarImage;
    }
}

- (void)configGroupAvatarImage:(NSArray *)inviteList {
    if (!inviteList || inviteList.count <= 0) {
        self.avatarImage = DefaultGroupAvatarImage;
        return;
    }
    
    NSString *inviteStr = [inviteList componentsJoinedByString:@"#"];
    
    __weak __typeof(self) weakSelf = self;
    [self getCacheAvatarForInviteStr:inviteStr callback:^(UIImage *avatar) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (avatar != nil) {
            strongSelf.avatarImage = avatar;
        } else {
            [[V2TIMManager sharedInstance] getUsersInfo:inviteList succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
                NSMutableArray *avatarsList = [NSMutableArray array];
                
                for (V2TIMUserFullInfo *userFullInfo in infoList) {
                    if (userFullInfo.faceURL.length > 0) {
                        [avatarsList addObject:userFullInfo.faceURL];
                    } else {
                        [avatarsList addObject:@"http://placeholder"];
                    }
                }
                
                [TUIGroupAvatar createGroupAvatar:[avatarsList copy] finished:^(UIImage *image) {
                    __strong __typeof(weakSelf) strongSelf = weakSelf;
                    strongSelf.avatarImage = image ?: DefaultGroupAvatarImage;
                    [strongSelf cacheGroupCallAvatar:image inviteStr:inviteStr];
                }];
            } fail:^(int code, NSString *desc) {
            }];
        }
    }];
}

- (void)configSingleAvatarImage:(TUICallRecords *)callRecord {
    self.avatarImage = DefaultAvatarImage;
    NSString *useId = callRecord.inviter ?: @"";
    
    if (TUICallRoleCall == callRecord.role) {
        useId = [callRecord.inviteList firstObject];
    }
    
    if (useId) {
        __weak __typeof(self) weakSelf = self;
        [[V2TIMManager sharedInstance] getUsersInfo:@[useId] succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            V2TIMUserFullInfo *userFullInfo = infoList.firstObject;
            if (userFullInfo.faceURL && userFullInfo.faceURL.length > 0 && [userFullInfo.faceURL hasPrefix:@"http"]) {
                strongSelf.faceURL = userFullInfo.faceURL;
            }
        } fail:nil];
    }
}

- (void)configResultWith:(TUICallResultType)callResultType {
    self.resultLabelStr = @"";
    switch (callResultType) {
        case TUICallResultTypeMissed:
            self.resultLabelStr = TUICallingLocalize(@"TUICallKit.Recents.missed");
            break;
        case TUICallResultTypeIncoming:
            self.resultLabelStr = TUICallingLocalize(@"TUICallKit.Recents.incoming");
            break;
        case TUICallResultTypeOutgoing:
            self.resultLabelStr = TUICallingLocalize(@"TUICallKit.Recents.outgoing");
            break;
        case TUICallResultTypeUnknown:
        default:
            break;
    }
}

- (void)configMediaTypeImageNameWith:(TUICallMediaType)callMediaType {
    if (callMediaType == TUICallMediaTypeAudio) {
        self.mediaTypeImageStr = @"ic_recents_audio";
    } else if (callMediaType == TUICallMediaTypeVideo) {
        self.mediaTypeImageStr = @"ic_recents_video";
    }
}

- (void)configTitleWith:(TUICallRecords *)callRecord {
    self.titleLabelStr = @"";
    NSMutableArray *allUsers = [NSMutableArray array];
    
    switch (callRecord.scene) {
        case TUICallSceneSingle:
            if (callRecord.role == TUICallRoleCall) {
                if (callRecord.inviteList) {
                    [allUsers addObjectsFromArray:callRecord.inviteList];
                }
            } else if (callRecord.role == TUICallRoleCalled) {
                if (callRecord.inviter) {
                    [allUsers addObject:callRecord.inviter];
                }
            }
            break;
        case TUICallSceneGroup:
            if (callRecord.inviter) {
                [allUsers addObject:callRecord.inviter];
            }
            if (callRecord.inviteList) {
                [allUsers addObjectsFromArray:callRecord.inviteList];
            }
            break;
        case TUICallSceneMulti:
        default:
            break;
    }
    
    self.titleLabelStr = [[allUsers copy] componentsJoinedByString:@", "];
    
    __weak __typeof(self) weakSelf = self;
    [TUICallKitUserInfoUtils getUserInfo:[allUsers copy] succ:^(NSArray<CallingUserModel *> * _Nonnull modelList) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSMutableArray *titleArray = [NSMutableArray array];
        for (CallingUserModel *userModel in modelList) {
            [titleArray addObject:userModel.name];
        }
        strongSelf.titleLabelStr = [titleArray componentsJoinedByString:@", "];
    } fail:^(int code, NSString * _Nullable errMsg) {
    }];
}

- (void)configTimeWith:(TUICallRecords *)callRecord {
    NSTimeInterval beginTime = callRecord.beginTime / 1000;
    if (beginTime <= 0) {
        return;
    }
    self.timeLabelStr = [TUITool convertDateToStr:[NSDate dateWithTimeIntervalSince1970:beginTime]];
}

#pragma mark - 私有方法

- (void)cacheGroupCallAvatar:(UIImage*)avatar inviteStr:(NSString *)inviteStr {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (inviteStr == nil || inviteStr.length == 0) {
            return;
        }
        NSString* tempPath = NSTemporaryDirectory();
        NSString *filePath = [NSString stringWithFormat:@"%@groupCallAvatar_%@.png",tempPath, inviteStr];
        [UIImagePNGRepresentation(avatar) writeToFile:filePath atomically:YES];
    });
}

- (void)getCacheAvatarForInviteStr:(NSString *)inviteStr callback:(void(^)(UIImage *))imageCallBack {
    if (inviteStr == nil || inviteStr.length == 0) {
        if (imageCallBack) {
            imageCallBack(nil);
        }
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* tempPath = NSTemporaryDirectory();
        NSString *filePath = [NSString stringWithFormat:@"%@groupCallAvatar_%@.png",tempPath, inviteStr];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        UIImage *avatar = nil;
        BOOL success = [fileManager fileExistsAtPath:filePath];
        
        if (success) {
            avatar = [[UIImage alloc] initWithContentsOfFile:filePath];
        }
        
        if (imageCallBack) {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageCallBack(avatar);
            });
        }
    });
}

@end
