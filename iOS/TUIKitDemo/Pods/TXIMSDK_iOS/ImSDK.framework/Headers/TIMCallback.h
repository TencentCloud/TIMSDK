//
//  TIMCallback.h
//  ImSDK
//
//  Created by bodeng on 30/3/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMCallback_h
#define ImSDK_TIMCallback_h

#import "TIMComm.h"

@class TIMMessage;
@class TIMGroupTipsElem;
@class TIMGroupInfo;
@class TIMSNSChangeInfo;
@class TIMFriendPendencyInfo;

/**
 *  连接通知回调
 */
@protocol TIMConnListener <NSObject>
@optional

/**
 *  网络连接成功
 */
- (void)onConnSucc;

/**
 *  网络连接失败
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onConnFailed:(int)code err:(NSString*)err;

/**
 *  网络连接断开（断线只是通知用户，不需要重新登录，重连以后会自动上线）
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onDisconnect:(int)code err:(NSString*)err;


/**
 *  连接中
 */
- (void)onConnecting;

@end


/**
 *  用户在线状态通知
 */
@protocol TIMUserStatusListener <NSObject>
@optional
/**
 *  踢下线通知
 */
- (void)onForceOffline;

/**
 *  断线重连失败
 */
- (void)onReConnFailed:(int)code err:(NSString*)err;

/**
 *  用户登录的userSig过期（用户需要重新获取userSig后登录）
 */
- (void)onUserSigExpired;
@end

/**
 *  页面刷新接口（如有需要未读计数刷新，会话列表刷新等）
 */
@protocol TIMRefreshListener <NSObject>
@optional
/**
 *  刷新会话
 */
- (void)onRefresh;

/**
 *  刷新部分会话
 *
 *  @param conversations 会话（TIMConversation*）列表
 */
- (void)onRefreshConversations:(NSArray<TIMConversation *>*)conversations;
@end

/**
 *  消息回调
 */
@protocol TIMMessageListener <NSObject>
@optional
/**
 *  新消息回调通知
 *
 *  @param msgs 新消息列表，TIMMessage 类型数组
 */
- (void)onNewMessage:(NSArray*)msgs;
@end

@protocol TIMMessageReceiptListener <NSObject>
@optional
/**
 *  收到了已读回执
 *
 *  @param receipts 已读回执（TIMMessageReceipt*）列表
 */
- (void) onRecvMessageReceipts:(NSArray*)receipts;
@end

/**
 *  消息修改回调
 */
@protocol TIMMessageUpdateListener <NSObject>
@optional
/**
 *  消息修改通知
 *
 *  @param msgs 修改的消息列表，TIMMessage 类型数组
 */
- (void)onMessageUpdate:(NSArray*) msgs;
@end


@protocol TIMMessageRevokeListener <NSObject>
@optional
/**
 *  消息撤回通知
 *
 *  @param locator 被撤回消息的标识
 */
- (void)onRevokeMessage:(TIMMessageLocator*)locator;

@end

/**
 *  上传进度回调
 */
@protocol TIMUploadProgressListener <NSObject>
@optional
/**
 *  上传进度回调
 *
 *  @param msg      正在上传的消息
 *  @param elemidx  正在上传的elem的索引
 *  @param taskid   任务id
 *  @param progress 上传进度
 */
- (void)onUploadProgressCallback:(TIMMessage*)msg elemidx:(uint32_t)elemidx taskid:(uint32_t)taskid progress:(uint32_t)progress;
@end

/**
 *  群事件通知回调
 */
@protocol TIMGroupEventListener <NSObject>
@optional
/**
 *  群tips回调
 *
 *  @param elem  群tips消息
 */
- (void)onGroupTipsEvent:(TIMGroupTipsElem*)elem;
@end

/**
 *  好友代理事件回调
 */
@protocol TIMFriendshipListener <NSObject>
@optional

/**
 *  添加好友通知
 *
 *  @param users 好友列表（NSString*）
 */
- (void)onAddFriends:(NSArray*)users;

/**
 *  删除好友通知
 *
 *  @param identifiers 用户id列表（NSString*）
 */
- (void)onDelFriends:(NSArray*)identifiers;

/**
 *  好友资料更新通知
 *
 *  @param profiles 资料列表（TIMSNSChangeInfo *）
 */
- (void)onFriendProfileUpdate:(NSArray<TIMSNSChangeInfo *> *)profiles;

/**
 *  好友申请通知
 *
 *  @param reqs 好友申请者id列表（TIMFriendPendencyInfo *）
 */
- (void)onAddFriendReqs:(NSArray<TIMFriendPendencyInfo *> *)reqs;

@end

#endif
