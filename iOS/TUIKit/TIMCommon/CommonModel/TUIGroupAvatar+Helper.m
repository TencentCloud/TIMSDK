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
     * 修改默认头像
     * Setup default avatar
     */
    UIImage *avatarImage = nil;
    if (groupID.length > 0) {
        /**
         * 群组, 则将群组默认头像修改成上次使用的头像
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
         * 群组头像
         * Group avatar
         */
        if (IS_NOT_EMPTY_NSSTRING(faceUrl)) {
            /**
             * 外部有手动设置群头像
             * The group avatar has been manually set externally
             */
            [targetView sd_setImageWithURL:[NSURL URLWithString:faceUrl] placeholderImage:originAvatarImage];
        } else {
            /**
             * 外部未设置群头像，如果允许合成头像，则采用合成头像；反之则使用默认头像
             * The group avatar has not been set externally. If the synthetic avatar is allowed, the synthetic avatar will be used; otherwise, the default
             * avatar will be used.
             */
            if (TUIConfig.defaultConfig.enableGroupGridAvatar) {
                /**
                 * 允许合成头像，则采用合成头像
                 * 1. 异步根据群成员个数来获取缓存的合成头像
                 * 2. 如果有缓存，则直接使用缓存的合成头像
                 * 3. 如果没有缓存，则重新合成新头像
                 *
                 * 注意：
                 * 1. 由于「异步获取缓存」和「合成头像」耗时较长，容易引起 cell 的复用问题，故需要根据 groupID 来确认是否直接赋值。
                 * 2. 使用 SDWebImage 来实现占位，因为 SDWebImage 内部已经处理了 cell 的复用问题
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

                // 1. 获取缓存
                // 1. Obtain group avatar from cache

                // fix: 由于 getCacheGroupAvatar 需要请求网络，断网时，由于并没有设置
                // headImageView，此时当前会话发消息，会话会上移，复用了第一条会话的头像，导致头像错乱 fix: The getCacheGroupAvatar needs to request the
                // network. When the network is disconnected, since the headImageView is not set, the current conversation sends a message, the conversation is
                // moved up, and the avatar of the first conversation is reused, resulting in confusion of the avatar.
                [targetView sd_setImageWithURL:nil placeholderImage:originAvatarImage];
                [TUIGroupAvatar getCacheGroupAvatar:groupID
                                           callback:^(UIImage *avatar, NSString *groupID) {
                                             if ([groupID isEqualToString:groupID]) {
                                                 // 1.1 callback 回调时，cell 未被复用
                                                 // 1.1 When the callback is invoked, the cell is not reused

                                                 if (avatar != nil) {
                                                     // 2. 有缓存，直接赋值
                                                     // 2. Hit the cache and assign directly
                                                     [targetView sd_setImageWithURL:nil placeholderImage:avatar];
                                                 } else {
                                                     // 3. 没有缓存，异步合成新头像
                                                     // 3. Synthesize new avatars asynchronously without hitting cache

                                                     [targetView sd_setImageWithURL:nil placeholderImage:originAvatarImage];
                                                     [TUIGroupAvatar
                                                         fetchGroupAvatars:groupID
                                                               placeholder:originAvatarImage
                                                                  callback:^(BOOL success, UIImage *image, NSString *groupID) {
                                                                    if ([groupID isEqualToString:groupID]) {
                                                                        // callback 回调时，cell 未被复用
                                                                        // When the callback is invoked, the cell is not reused
                                                                        [targetView
                                                                            sd_setImageWithURL:nil
                                                                              placeholderImage:success ? image : DefaultGroupAvatarImageByGroupType(groupType)];
                                                                    } else {
                                                                        // callback 回调时，cell 已经被复用至其他的 groupID。由于新的 groupID
                                                                        // 合成头像时会触发新的 callback，此处忽略 When the callback is invoked, the cell has
                                                                        // been reused to other groupIDs. Since a new callback will be triggered when the new
                                                                        // groupID synthesizes new avatar, it is ignored here
                                                                    }
                                                                  }];
                                                 }
                                             } else {
                                                 // 1.2 callback 回调时，cell 已经被复用至其他的 groupID。由于新的 groupID 获取缓存时会触发新的
                                                 // callback，此处忽略 1.2 When the callback is invoked, the cell has been reused to other groupIDs. Since a new
                                                 // callback will be triggered when the new groupID gets the cache, it is ignored here
                                             }
                                           }];
            } else {
                /**
                 * 不允许使用合成头像，直接使用默认头像
                 * Synthetic avatars are not allowed, use the default avatar directly
                 */
                [targetView sd_setImageWithURL:nil placeholderImage:originAvatarImage];
            }
        }
    } else {
        /**
         * 个人头像
         * Personal avatar
         */
        [targetView sd_setImageWithURL:[NSURL URLWithString:faceUrl] placeholderImage:originAvatarImage];
    }
}
@end
