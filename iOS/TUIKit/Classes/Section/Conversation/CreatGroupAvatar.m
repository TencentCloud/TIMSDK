//
//  CreatGroupAvatar.m
//  THeadImgs
//
//  Created by ITD on 2017/3/25.
//  Copyright © 2017年 ITD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreatGroupAvatar.h"
#import "THeader.h"
#import "TUIKit.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ReactiveObjC.h"

#define groupAvatarWidth (48*[[UIScreen mainScreen] scale])

@implementation CreatGroupAvatar

+ (void)createGroupAvatar:(NSArray *)group finished:(void (^)(UIImage *groupAvatar))finished
{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger avatarCount = group.count > 9 ? 9 : group.count;
        CGFloat width = groupAvatarWidth / 3 * 0.90;
        CGFloat space3 = (groupAvatarWidth - width * 3) / 4;                      // 三张图时的边距（图与图之间的边距）
        CGFloat space2 = (groupAvatarWidth - width * 2 + space3) / 2;             // 两张图时的边距
        CGFloat space1 = (groupAvatarWidth - width) / 2;                          // 一张图时的边距
        __block CGFloat y = avatarCount > 6 ? space3 : (avatarCount > 3 ? space2 : space1);
        __block CGFloat x = avatarCount  % 3 == 0 ? space3 : (avatarCount % 3 == 2 ? space2 : space1);
        width = avatarCount > 4 ? width : (avatarCount > 1 ? (groupAvatarWidth - 3 * space3) / 2 : groupAvatarWidth );  // 重新计算width；
        
        if (avatarCount == 1) {                                          // 1,2,3,4 张图不同
            x = 0;
            y = 0;
        }
        if (avatarCount == 2) {
            x = space3;
        } else if (avatarCount == 3) {
            x = (groupAvatarWidth -width)/2;
            y = space3;
        } else if (avatarCount == 4) {
            x = space3;
            y = space3;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, groupAvatarWidth, groupAvatarWidth)];
            [view setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:0.6]];
            view.layer.cornerRadius = 6;
            __block NSInteger count = 0;               //下载图片完成的计数
            for (NSInteger i = avatarCount - 1; i >= 0; i--) {
                NSString *avatarUrl = [group objectAtIndex:i];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, width)];
                [view addSubview:imageView];
                [imageView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:DefaultAvatarImage completed:^(UIImage * _Nullable image,
                                                                                                                              NSError * _Nullable error,
                                                                                                                              SDImageCacheType cacheType,
                                                                                                                              NSURL * _Nullable imageURL) {
                    count ++ ;
                    if (count == avatarCount) {     //图片全部下载完成
                        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 2.0);
                        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
                        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndPDFContext();
                        CGImageRef imageRef = image.CGImage;
                        CGImageRef imageRefRect = CGImageCreateWithImageInRect(imageRef, CGRectMake(0, 0, view.frame.size.width*2, view.frame.size.height*2));
                        UIImage *ansImage = [[UIImage alloc] initWithCGImage:imageRefRect];
                        CGImageRelease(imageRefRect);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (finished) {
                                finished(ansImage);
                            }
                        });
                    }
                    
                }];
                
                if (avatarCount == 3) {
                    if (i == 2) {
                        y = width + space3*2;
                        x = space3;
                    } else {
                        x += width + space3;
                    }
                } else if (avatarCount == 4) {
                    if (i % 2 == 0) {
                        y += width +space3;
                        x = space3;
                    } else {
                        x += width +space3;
                    }
                } else {
                    if (i % 3 == 0 ) {
                        y += (width + space3);
                        x = space3;
                    } else {
                        x += (width + space3);
                    }
                }
            }
        });
        
    });
    
}

+ (void)fetchGroupAvatars:(NSString *)groupID placeholder:(UIImage *)placeholder callback:(void(^)(BOOL success, UIImage *image, NSString *groupID))callback
{
    // 获取群组前9个成员的头像url
    @weakify(self)
    [[V2TIMManager sharedInstance] getGroupMemberList:groupID filter:V2TIM_GROUP_MEMBER_FILTER_ALL nextSeq:0 succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
        @strongify(self)
        int i = 0;
        NSMutableArray *groupMemberAvatars = [NSMutableArray arrayWithCapacity:1];
        for (V2TIMGroupMemberFullInfo* member in memberList) {
            if (member.faceURL.length > 0) {
                [groupMemberAvatars addObject:member.faceURL];
                i++;
            }
            if (i == 9) {
                break;
            }
        }
        
        // 存储当前获取到的群组头像信息
        NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", groupID];
        [NSUserDefaults.standardUserDefaults setInteger:groupMemberAvatars.count forKey:key];
        [NSUserDefaults.standardUserDefaults synchronize];
        
        // 创建九宫格头像
        [CreatGroupAvatar createGroupAvatar:groupMemberAvatars finished:^(UIImage *groupAvatar) {
            @strongify(self)
            // 缓存
            UIImage *avatar = groupAvatar;
            [self cacheGroupAvatar:avatar number:(UInt32)groupMemberAvatars.count groupID:groupID];
            
            // 回调
            if (callback) {
                callback(YES, avatar, groupID);
            }
        }];
        
    } fail:^(int code, NSString *msg) {
        if (callback) {
            callback(NO, placeholder, groupID);
        }
    }];
}

/// 缓存群组头像
/// @param avatar 图片
/// 取缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化取不到缓存
+ (void)cacheGroupAvatar:(UIImage*)avatar number:(UInt32)memberNum groupID:(NSString *)groupID
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{    
        if (groupID == nil || groupID.length == 0) {
            return;
        }
        NSString* tempPath = NSTemporaryDirectory();
        NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath, groupID, memberNum];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // check to delete old file
        NSNumber *oldValue = [defaults objectForKey:groupID];
        if ( oldValue != nil) {
            UInt32 oldMemberNum = [oldValue unsignedIntValue];
            NSString *oldFilePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%d.png",tempPath, groupID, oldMemberNum];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:oldFilePath error:nil];
        }
        
        // Save image.
        BOOL success = [UIImagePNGRepresentation(avatar) writeToFile:filePath atomically:YES];
        if (success) {
            [defaults setObject:@(memberNum) forKey:groupID];
        }
    });
}

/// 获取缓存群组头像
/// 缓存的维度是按照会议室ID & 会议室人数来定的，
/// 人数变化要引起头像改变
+ (void)getCacheGroupAvatar:(NSString *)groupID callback:(void(^)(UIImage *))imageCallBack {
    if (groupID == nil || groupID.length == 0) {
        if (imageCallBack) {
            imageCallBack(nil);
        }
        return;
    }
    [[V2TIMManager sharedInstance] getGroupsInfo:@[groupID] succ:^(NSArray<V2TIMGroupInfoResult *> *groupResultList) {
        V2TIMGroupInfoResult *groupInfo = groupResultList.firstObject;
        if (!groupInfo) {
            imageCallBack(nil);
            return;
        }
        UInt32 memberNum = groupInfo.info.memberCount;
        //限定1-9的范围
        memberNum = MAX(1, memberNum);
        memberNum = MIN(memberNum, 9);;
        NSString* tempPath = NSTemporaryDirectory();
        NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png",tempPath, groupID, (unsigned int)memberNum];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        UIImage *avatar = nil;
        BOOL success = [fileManager fileExistsAtPath:filePath];

        if (success) {
            avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
            // 存储当前获取到的群组头像信息
            NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", groupID];
            [NSUserDefaults.standardUserDefaults setInteger:memberNum forKey:key];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        imageCallBack(avatar);
    } fail:^(int code, NSString *msg) {
        imageCallBack(nil);
    }];
}


/// 同步获取本地缓存的群组头像
/// @param groupId 群id
/// @param memberNum 群成员个数, 最多返回9个成员的拼接头像
+ (UIImage *)getCacheAvatarForGroup:(NSString *)groupId number:(UInt32)memberNum
{
    //限定1-9的范围
    memberNum = MAX(1, memberNum);
    memberNum = MIN(memberNum, 9);;
    NSString* tempPath = NSTemporaryDirectory();
    NSString *filePath = [NSString stringWithFormat:@"%@groupAvatar_%@_%u.png",tempPath,
                          groupId,(unsigned int)memberNum];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    UIImage *avatar = nil;
    BOOL success = [fileManager fileExistsAtPath:filePath];

    if (success) {
        avatar= [[UIImage alloc] initWithContentsOfFile:filePath];
    }
    return avatar;
}


@end
