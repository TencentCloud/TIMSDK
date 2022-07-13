/**
 * 信令相关功能，主要用于音视频通话信令的发送。
 * @module SignalingManager(高级消息收发接口)
 */
import type V2TimCallback from '../interface/v2TimCallback';
import type V2TimSignalingInfo from 'src/interface/v2TimSignalingInfo';
import type V2TimOfflinePushInfo from '../interface/v2TimOfflinePushInfo';
import type V2TimValueCallback from '../interface/v2TimValueCallback';
import type V2TimSignalingListener from '../interface/v2TimSignalingListener';
import type { NativeEventEmitter } from 'react-native';

export class V2TIMSignalingManager {
    private manager: String = 'signalingManager';
    private nativeModule: any;
    private listenerList: V2TimSignalingListener[] = [];

    /** @hidden */
    constructor(module: any, eventEmitter: NativeEventEmitter) {
        this.nativeModule = module;
        eventEmitter.addListener('signalingListener', (response: any) => {
            const { type, data } = response;
            this.listenerList.forEach((listener) => {
                switch (type) {
                    case 'onReceiveNewInvitation':
                        listener.onReceiveNewInvitation &&
                            listener.onReceiveNewInvitation(
                                data.inviteID,
                                data.inviter,
                                data.groupID,
                                data.inviteeList,
                                data.data
                            );
                        break;
                    case 'onInviteeAccepted':
                        listener.onInviteeAccepted &&
                            listener.onInviteeAccepted(
                                data.inviteID,
                                data.invitee,
                                data.data
                            );
                        break;
                    case 'onInviteeRejected':
                        listener.onInviteeRejected &&
                            listener.onInviteeRejected(
                                data.inviteID,
                                data.invitee,
                                data.data
                            );
                        break;
                    case 'onInvitationCancelled':
                        listener.onInvitationCancelled &&
                            listener.onInvitationCancelled(
                                data.inviteID,
                                data.inviter,
                                data.data
                            );
                        break;
                    case 'onInvitationTimeout':
                        listener.onInvitationTimeout &&
                            listener.onInvitationTimeout(
                                data.inviteID,
                                data.inviteeList
                            );
                        break;
                }
            });
        });
    }

    /**
     * ### 添加信令监听
     */
    public addSignalingListener(listener: V2TimSignalingListener): void {
        if (this.listenerList.length == 0) {
            this.nativeModule.call(this.manager, 'addSignalingListener', {});
        }
        this.listenerList.push(listener);
    }
    /**
     * ### 移除信令监听
     */
    public removeSignalingListener(listener?: V2TimSignalingListener): void {
        if (!listener) {
            this.listenerList = [];
        } else {
            this.listenerList = this.listenerList.filter(
                (item) => item != listener
            );
        }
        if (this.listenerList.length == 0) {
            this.nativeModule.call(this.manager, 'removeSignalingListener', {});
        }
    }

    /**
     * 邀请某个人
     * @param invitee - 被邀请人用户 ID
     * @param data - 自定义数据
     * @param timeout - 超时时间，单位秒，如果设置为 0，SDK 不会做超时检测，也不会触发 onInvitationTimeout 回调
     * @param onlineUserOnly - 是否只有在线用户才能收到邀请，如果设置为 true，只有在线用户才能收到， 并且 invite 操作也不会产生历史消息（针对该次 invite 的后续 cancel、accept、reject、timeout 操作也同样不会产生历史消息）。
     * @param offlinePushInfo - 离线推送信息，其中 desc 为必填字段，推送的时候会默认展示 desc 信息。
     */
    public invite(
        invitee: String,
        data: String,
        timeout = 30,
        onlineUserOnly = false,
        offlinePushInfo?: V2TimOfflinePushInfo
    ): Promise<V2TimValueCallback<String>> {
        return this.nativeModule.call(this.manager, 'invite', {
            invitee,
            data,
            timeout,
            onlineUserOnly,
            offlinePushInfo,
        });
    }

    /**
     * ### 邀请群内的某些人
     * @param groupID - 发起邀请所在群组
     * @param inviteeList - 被邀请人列表，inviteeList 必须已经在 groupID 群里，否则邀请无效
     * @param data - 自定义数据
     * @param timeout - 超时时间，单位秒，如果设置为 0，SDK 不会做超时检测，也不会触发 onInvitationTimeout 回调
     * @param onlineUserOnly - 是否只有在线用户才能收到邀请，如果设置为 true，只有在线用户才能收到， 并且 invite 操作也不会产生历史消息（针对该次 invite 的后续 cancel、accept、reject、timeout 操作也同样不会产生历史消息）。
     * @note
     * 群邀请暂不支持离线推送，如果您需要离线推送，可以针对被邀请的用户单独发离线推送自定义消息，
     */
    public inviteInGroup(
        groupID: String,
        inviteeList: String[],
        data: String,
        timeout = 30,
        onlineUserOnly = false
    ): Promise<V2TimValueCallback<String>> {
        return this.nativeModule.call(this.manager, 'inviteInGroup', {
            groupID,
            inviteeList,
            data,
            timeout,
            onlineUserOnly,
        });
    }

    /**
     * ### 邀请方取消邀请
     * @note
     * 如果所有被邀请人都已经处理了当前邀请（包含超时），不能再取消当前邀请。
     */
    public cancel(inviteID: String, data?: String): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'cancel', {
            inviteID,
            data,
        });
    }

    /**
     * ### 接收方接收邀请
     * @note
     * 不能接受不是针对自己的邀请，请在收到 onReceiveNewInvitation 回调的时候先判断 inviteeList 有没有自己，如果没有自己，不能 accept 邀请。
     */
    public accept(inviteID: String, data?: String): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'accept', {
            inviteID,
            data,
        });
    }

    /**
     * ### 接收方拒绝邀请
     * @note
     * 不能拒绝不是针对自己的邀请，请在收到 onReceiveNewInvitation 回调的时候先判断 inviteeList 有没有自己，如果没有自己，不能 reject 邀请。
     */
    public reject(inviteID: String, data?: String): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'reject', {
            inviteID,
            data,
        });
    }

    /**
     * ### 获取信令信息
     * 如果 invite 设置 onlineUserOnly 为 false，每次信令操作（包括 invite、cancel、accept、reject、timeout）都会产生一条自定义消息， 该消息会通过 V2TIMAdvancedMsgListener -> onRecvNewMessage 抛给用户，用户也可以通过历史消息拉取，如果需要根据信令信息做自定义化文本展示，可以调用下面接口获取信令信息。
     */
    public getSignalingInfo(
        msgID: String
    ): Promise<V2TimValueCallback<V2TimSignalingInfo>> {
        return this.nativeModule.call(this.manager, 'getSignalingInfo', {
            msgID,
        });
    }

    /**
     * ### 添加邀请信令（可以用于群离线推送消息触发的邀请信令）
     * 在离线推送的场景下：
     * - 针对 1V1 信令邀请，被邀请者 APP 如果被 Kill，当 APP 收到信令离线推送再次启动后，SDK 可以自动同步到邀请信令，如果邀请还没超时， 用户会收到 onReceiveNewInvitation 回调，如果邀请已经超时，用户还会收到 onInvitationTimeout 回调。
     * - 针对群信令邀请，被邀请者 APP 如果被 Kill，当 APP 收到离线推送再次启动后，SDK 无法自动同步到邀请信令（邀请信令本质上就是一条自定义消息，群离线消息在程序启动后无法自动同步）， 也就没法处理该邀请信令。如果被邀请者需要处理该邀请信令，可以让邀请者在发起信令的时候对针对每个被邀请者再单独发送一条 C2C 离线推送消息，消息里面携带 V2TIMSignalingInfo 信息， 被邀请者收到离线推送的时候把 V2TIMSignalingInfo 信息再通过 addInvitedSignaling 接口告知 SDK。
     * - TUIKit 音视频通话离线推送功能基于这个接口实现，详细实现方法请参考文档：[集成音视频通话](https://cloud.tencent.com/document/product/647)
     */
    public addInvitedSignaling(
        info: V2TimSignalingInfo
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'addInvitedSignaling', {
            info,
        });
    }
}
