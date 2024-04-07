//
//  TUIGroupAvatar+Helper.m
//  TIMCommon
//
//  Created by wyl on 2023/4/27.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TUICore/TUIConfig.h>
#import "TUIGroupAvatar+Helper.h"

@implementation TUIGroupAvatar (Helper)

+ (UIImage *)getNormalGroupCacheAvatar:(NSString *)groupID groupType:(NSString *)groupType {
    /**
     * 
     * Setup default avatar
     */
    UIImage *avatarImage = nil;
    if (groupID.length > 0) {
        /**
         * If it is a group, change the group default avatar to the last used avatar
         */
        UIImage *avatar = nil;
        if (TUIConfig.defaultConfig.enableGroupGridAvatar) {
            NSString *key = [NSString stringWithFormat:@"TUIConversationLastGroupMember_%@", groupID];
            NSInteger member = [NSUserDefaults.standardUserDefaults integerForKey:key];
            avatar = [TUIGroupAvatar getCacheAvatarForGroup:groupID number:(UInt32)member];
        }
        avatarImage = avatar ? avatar : DefaultGroupAvatarImageByGroupType(groupType);
        ;
        return avatarImage;
    }
    return avatarImage;
}
+ (void)configAvatarByParam:(NSDictionary *)param targetView:(UIImageView *)targetView {
    NSString *groupID = param[@"groupID"];
    NSString *faceUrl = param[@"faceUrl"];
    NSString *groupType = param[@"groupType"];
    UIImage *originAvatarImage = param[@"originAvatarImage"];
    if (groupID.length > 0) {
        /**
         * 
         * Group avatar
         */
        if (IS_NOT_EMPTY_NSSTRING(faceUrl)) {
            /**
             * 
             * The group avatar has been manually set externally
             */
            [targetView sd_setImageWithURL:[NSURL URLWithString:faceUrl] placeholderImage:originAvatarImage];
        } else {
            /**
             * The group avatar has not been set externally. If the synthetic avatar is allowed, the synthetic avatar will be used; otherwise, the default
             * avatar will be used.
             */
            if (TUIConfig.defaultConfig.enableGroupGridAvatar) {
                /**
                 *
                 * If the synthetic avatar is allowed, the synthetic avatar will be used
                 * 1. Asynchronously obtain the cached synthetic avatar according to the number of group members
                 * 2. If the cache is hit, use the cached synthetic avatar directly
                 * 3. If the cache is not hit, recompose a new avatar
                 *
                 * Note:
                 * 1. Since "asynchronously obtaining cached avatars" and "synthesizing avatars" take a long time, it is easy to cause cell reuse problems, so
                 * it is necessary to confirm whether to assign values directly according to groupID.
                 * 2. Use SDWebImage to implement placeholder, because SDWebImage has already dealt with the problem of cell reuse
                 */
 
                // 1. Obtain group avatar from cache

                // fix: The getCacheGroupAvatar needs to request the
                // network. When the network is disconnected, since the headImageView is not set, the current conversation sends a message, the conversation is
                // moved up, and the avatar of the first conversation is reused, resulting in confusion of the avatar.
                [targetView sd_setImageWithURL:nil placeholderImage:originAvatarImage];
                [TUIGroupAvatar getCacheGroupAvatar:groupID
                                           callback:^(UIImage *avatar, NSString *groupID) {
                                             if ([groupID isEqualToString:groupID]) {
                                                 // 1.1 When the callback is invoked, the cell is not reused

                                                 if (avatar != nil) {
                                                     // 2. Hit the cache and assign directly
                                                     [targetView sd_setImageWithURL:nil placeholderImage:avatar];
                                                 } else {
                                                     // 3. Synthesize new avatars asynchronously without hitting cache

                                                     [targetView sd_setImageWithURL:nil placeholderImage:originAvatarImage];
                                                     [TUIGroupAvatar
                                                         fetchGroupAvatars:groupID
                                                               placeholder:originAvatarImage
                                                                  callback:^(BOOL success, UIImage *image, NSString *groupID) {
                                                                    if ([groupID isEqualToString:groupID]) {
                                                                        // When the callback is invoked, the cell is not reused
                                                                        [targetView
                                                                            sd_setImageWithURL:nil
                                                                              placeholderImage:success ? image : DefaultGroupAvatarImageByGroupType(groupType)];
                                                                    } else {
                                                                        //  callback， When the callback is invoked, the cell has
                                                                        // been reused to other groupIDs. Since a new callback will be triggered when the new
                                                                        // groupID synthesizes new avatar, it is ignored here
                                                                    }
                                                                  }];
                                                 }
                                             } else {
                                                 // 1.2 callback ，cell  groupID。 groupID 
                                                 // callback， 1.2 When the callback is invoked, the cell has been reused to other groupIDs. Since a new
                                                 // callback will be triggered when the new groupID gets the cache, it is ignored here
                                             }
                                           }];
            } else {
                /**
                 * Synthetic avatars are not allowed, use the default avatar directly
                 */
                [targetView sd_setImageWithURL:nil placeholderImage:originAvatarImage];
            }
        }
    } else {
        /**
         * Personal avatar
         */
        [targetView sd_setImageWithURL:[NSURL URLWithString:faceUrl] placeholderImage:originAvatarImage];
    }
}
@end
