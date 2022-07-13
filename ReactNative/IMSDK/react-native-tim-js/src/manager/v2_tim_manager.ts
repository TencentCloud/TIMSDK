/**
 * 基础接口，包括基本的登陆，发送简单消息，回调等功能
 * @module BaseManager(基础接口)
 */
import { NativeEventEmitter } from 'react-native';
import type V2TimSDKListener from '../interface/v2TimSDKListener';
import type V2TimGroupListener from '../interface/v2TimGroupListener';
import type V2TimSimpleMsgListener from '../interface/v2TimSimpleMsgListener';
import type V2TimUserFullInfo from '../interface/v2TimUserFullInfo';
import { V2TIMFriendshipManager } from './v2_tim_friendship_manager';
import { V2TimGroupManager } from './v2_tim_group_manager';
import { V2TIMMessageManager } from './v2_tim_message_manager';
import { V2TIMConversationManager } from './v2_tim_conversation_manager';
import { V2TIMOfflinePushManager } from './v2_tim_offline_push_manager';
import { V2TIMSignalingManager } from './v2_tim_signaling_manager';
import type V2TimCallback from '../interface/v2TimCallback';
import type V2TimValueCallback from '../interface/v2TimValueCallback';
import type V2TimUserStatus from '../interface/v2TimUserStatus';
import type V2TimMessage from '../interface/v2TimMessage';
import type { LogLevelEnum } from '../enum/logLevel';
import type { MessagePriorityEnum } from '../enum/messagePriority';

export class V2TIMManager {
    private manager: String = 'sdkManager';
    private nativeModule: any;
    private simpleMsgListenerList: V2TimSimpleMsgListener[] = [];
    private groupListenerList: V2TimGroupListener[] = [];
    private v2TIMFriendshipManager!: V2TIMFriendshipManager;
    private v2TIMGroupManager!: V2TimGroupManager;
    private v2TIMMessageManager!: V2TIMMessageManager;
    private v2TIMConversationManager!: V2TIMConversationManager;
    private v2TIMOfflinePushManager!: V2TIMOfflinePushManager;
    private v2timSignalingManager!: V2TIMSignalingManager;

    private sdkListener?: V2TimSDKListener;
    // private logEmitterSubscription?: EmitterSubscription;

    /** @hidden */
    constructor(module: any) {
        this.nativeModule = module;
        const eventEmitter = new NativeEventEmitter(module);
        this.v2TIMFriendshipManager = new V2TIMFriendshipManager(
            eventEmitter,
            module
        );
        this.v2TIMGroupManager = new V2TimGroupManager(module);
        this.v2TIMMessageManager = new V2TIMMessageManager(
            eventEmitter,
            module
        );
        this.v2TIMConversationManager = new V2TIMConversationManager(
            eventEmitter,
            module
        );
        this.v2TIMOfflinePushManager = new V2TIMOfflinePushManager(module);
        this.v2timSignalingManager = new V2TIMSignalingManager(
            module,
            eventEmitter
        );
        this.addListener(eventEmitter);
    }

    private addListener(eventEmitter: NativeEventEmitter) {
        this.addLogListener(eventEmitter);
        this.addSDKListener(eventEmitter);
        this._addSimpleMsgListener(eventEmitter);
        this._addGroupListener(eventEmitter);
    }

    private addLogListener(eventEmitter: NativeEventEmitter) {
        eventEmitter.addListener('logFromNative', (data: any) => {
            const { logs } = data;
            console.log('======log from native module======', logs);
        });
    }

    private addSDKListener(eventEmitter: NativeEventEmitter) {
        eventEmitter.addListener('sdkListener', (response: any) => {
            const { type, data } = response;
            switch (type) {
                case 'onConnecting':
                    this.sdkListener?.onConnecting();
                    break;
                case 'onConnectSuccess':
                    this.sdkListener?.onConnectSuccess();
                    break;
                case 'onConnectFailed':
                    this.sdkListener?.onConnectFailed(data.code, data.desc);
                    break;
                case 'onKickedOffline':
                    this.sdkListener?.onKickedOffline();
                    break;
                case 'onUserSigExpired':
                    this.sdkListener?.onUserSigExpired();
                    break;
                case 'onSelfInfoUpdated':
                    this.sdkListener?.onSelfInfoUpdated(data);
                    break;
                case 'onUserStatusChanged':
                    this.sdkListener?.onUserStatusChanged(data);
                    break;
            }
        });
    }

    private callSimpleMsgCalbackFunc(eventType: String, data: any) {
        this.simpleMsgListenerList.forEach((listener) => {
            switch (eventType) {
                case 'onRecvC2CTextMessage':
                    listener.onRecvC2CTextMessage(
                        data.msgID,
                        data.sender,
                        data.text
                    );
                    break;
                case 'onRecvC2CCustomMessage':
                    listener.onRecvC2CCustomMessage(
                        data.msgID,
                        data.sender,
                        data.customData
                    );
                    break;
                case 'onRecvGroupTextMessage':
                    listener.onRecvGroupTextMessage(
                        data.msgID,
                        data.groupID,
                        data.sender,
                        data.text
                    );
                    break;
                case 'onRecvGroupCustomMessage':
                    listener.onRecvGroupCustomMessage(
                        data.msgID,
                        data.groupID,
                        data.sender,
                        data.customData
                    );
                    break;
            }
        });
    }

    private callGroupListenerCallbackFunc(eventType: String, data: any) {
        this.groupListenerList.forEach((listener) => {
            switch (eventType) {
                case 'onMemberEnter':
                    listener.onMemberEnter(data.groupID, data.memberList);
                    break;
                case 'onMemberLeave':
                    listener.onMemberLeave(data.groupID, data.member);
                    break;
                case 'onMemberInvited':
                    listener.onMemberInvited(
                        data.groupID,
                        data.opUser,
                        data.memberList
                    );
                    break;
                case 'onMemberKicked':
                    listener.onMemberKicked(
                        data.groupID,
                        data.opUser,
                        data.memberList
                    );
                    break;
                case 'onMemberInfoChanged':
                    listener.onMemberInfoChanged(
                        data.groupID,
                        data.groupMemberChangeInfoList
                    );
                    break;
                case 'onGroupCreated':
                    listener.onGroupCreated(data.groupID);
                    break;
                case 'onGroupRecycled':
                    listener.onGroupRecycled(data.groupID, data.opUser);
                    break;
                case 'onGroupInfoChanged':
                    listener.onGroupInfoChanged(
                        data.groupID,
                        data.groupChangeInfoList
                    );
                    break;
                case 'onReceiveJoinApplication':
                    listener.onReceiveJoinApplication(
                        data.groupID,
                        data.member,
                        data.opReason
                    );
                    break;
                case 'onApplicationProcessed':
                    listener.onApplicationProcessed(
                        data.groupID,
                        data.opUser,
                        data.isAgreeJoin,
                        data.opReason
                    );
                    break;
                case 'onGrantAdministrator':
                    listener.onGrantAdministrator(
                        data.groupID,
                        data.opUser,
                        data.memberList
                    );
                    break;
                case 'onRevokeAdministrator':
                    listener.onRevokeAdministrator(
                        data.groupID,
                        data.opUser,
                        data.memberList
                    );
                    break;
                case 'onQuitFromGroup':
                    listener.onQuitFromGroup(data.groupID);
                    break;
                case 'onReceiveRESTCustomData':
                    listener.onReceiveRESTCustomData(
                        data.groupID,
                        data.customData
                    );
                    break;
                case 'onGroupAttributeChanged':
                    listener.onGroupAttributeChanged(
                        data.groupID,
                        data.groupAttributeMap
                    );
                    break;
            }
        });
    }

    private _addSimpleMsgListener(eventEmitter: NativeEventEmitter) {
        eventEmitter.addListener('simpleMsgListener', (response: any) => {
            const { type, data } = response;
            this.callSimpleMsgCalbackFunc(type, data);
        });
    }

    private _addGroupListener(eventEmitter: NativeEventEmitter) {
        eventEmitter.addListener('groupListener', (response: any) => {
            const { type, data } = response;
            this.callGroupListenerCallbackFunc(type, data);
        });
    }

    /**
     * ### 初始化SDK
     * @category SDK相关(如初始化)
     * @param sdkAppID - 应用 ID，必填项，可以在控制台中获取
     * @param loglevel - 配置信息
     * @param listener - SDK回调
     */
    public initSDK(
        sdkAppID: number,
        logLevel: LogLevelEnum,
        listener?: V2TimSDKListener
    ): Promise<V2TimValueCallback<boolean>> {
        this.sdkListener = listener;
        return this.nativeModule.call(this.manager, 'initSDK', {
            sdkAppID,
            logLevel,
        });
    }

    /**
     * ### 登录
     * 登录需要设置用户名 userID 和用户签名 userSig，userSig 生成请参考 [UserSig 后台 API](https://cloud.tencent.com/document/product/269/32688)。
     * @category 登录相关
     * @param userID - 用户ID
     * @param userSig - 用户签名
     *
     * @note
     * 请注意如下特殊逻辑:
     * - 登陆时票据过期：login 函数的回调会返回 ERR_USER_SIG_EXPIRED（6206）或者 ERR_SVR_ACCOUNT_USERSIG_EXPIRED（70001） 错误码，此时请您生成新的 userSig 重新登录。
     * - 在线时票据过期：用户在线期间也可能收到 V2TIMListener -> onUserSigExpired 回调，此时也是需要您生成新的 userSig 并重新登录。
     * - 在线时被踢下线：用户在线情况下被踢，SDK 会通过 V2TIMListener -> onKickedOffline 回调通知给您，此时可以 UI 提示用户，并再次调用 login() 重新登录。
     */
    public login(userID: String, userSig: String): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'login', {
            userID,
            userSig,
        });
    }

    /**
     * ### ImSDK卸载
     * @category SDK相关(如初始化)
     */
    public unInitSDK(): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'unInitSDK', {});
    }

    /**
     * ### 获取ImSDK版本号
     * @category SDK相关(如初始化)
     * @return  String 返回ImSDK的版本号
     */
    public getVersion(): Promise<V2TimValueCallback<String>> {
        return this.nativeModule.call(this.manager, 'getVersion', {});
    }

    /**
     * 获取服务器当前时间
     * @category SDK相关(如初始化)
     * @note
     * 可用于信令离线推送场景下超时判断
     */
    public getServerTime(): Promise<V2TimValueCallback<number>> {
        return this.nativeModule.call(this.manager, 'getServerTime', {});
    }

    /**
     * ### 登出
     * 退出登录，如果切换账号，需要 logout 回调成功或者失败后才能再次 login，否则 login 可能会失败。
     * @category 登录相关
     *
     */
    public logout(): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'logout', {});
    }

    /**
     * ### 获取登录用户ID
     * 退出登录，如果切换账号，需要 logout 回调成功或者失败后才能再次 login，否则 login 可能会失败。
     * @category 登录相关
     *
     */
    public getLoginUser(): Promise<V2TimValueCallback<String>> {
        return this.nativeModule.call(this.manager, 'getLoginUser', {});
    }

    /**
     * ### 发送C2C文本消息
     * @category 消息发送
     * @param userID - 接受消息端用户ID
     * @param text - 文本消息
     */
    public sendC2CTextMessage(
        userID: String,
        text: String
    ): Promise<V2TimValueCallback<V2TimMessage>> {
        return this.nativeModule.call(this.manager, 'sendC2CTextMessage', {
            userID,
            text,
        });
    }

    /**
     * ### 发送C2C自定义消息
     * @category 消息发送
     * @param userID - 接受消息端用户ID
     * @param customData - 自定义消息
     */
    public sendC2CCustomMessage(
        userID: String,
        customData: String
    ): Promise<V2TimValueCallback<V2TimMessage>> {
        return this.nativeModule.call(this.manager, 'sendC2CCustomMessage', {
            userID,
            customData,
        });
    }

    /**
     * ### 发送群组文本消息
     * @category 消息发送
     * @param groupID - 接受消息端群组ID
     * @param text - 文本消息
     * @param priority - 消息优先级,默认为`MessagePriorityEnum.V2TIM_PRIORITY_NORMAL`
     */
    public sendGroupTextMessage(
        groupID: String,
        text: String,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL
    ): Promise<V2TimValueCallback<V2TimMessage>> {
        return this.nativeModule.call(this.manager, 'sendGroupTextMessage', {
            groupID,
            text,
            priority,
        });
    }

    /**
     * ### 发送群组自定义消息
     * @category 消息发送
     * @param groupID - 接受消息端群组ID
     * @param customData - 自定义消息
     * @param priority - 消息优先级,默认为`MessagePriorityEnum.V2TIM_PRIORITY_NORMAL`
     */
    public sendGroupCustomMessage(
        groupID: String,
        customData: String,
        priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL
    ): Promise<V2TimValueCallback<V2TimMessage>> {
        return this.nativeModule.call(this.manager, 'sendGroupCustomMessage', {
            groupID,
            customData,
            priority,
        });
    }

    /**
     * ### 创建群组
     * @category 群组相关
     * @param groupName - 群名称
     * @param groupType - 群类型，我们为您预定义好了几种常用的群类型，您也可以在控制台定义自己需要的群类型：
                        - "Work" ：工作群，成员上限 200 人，不支持由用户主动加入，需要他人邀请入群，适合用于类似微信中随意组建的工作群（对应老版本的 Private 群）。
                        - "Public" ：公开群，成员上限 2000 人，任何人都可以申请加群，但加群需群主或管理员审批，适合用于类似 QQ 中由群主管理的兴趣群。
                        - "Meeting" ：会议群，成员上限 6000 人，任何人都可以自由进出，且加群无需被审批，适合用于视频会议和在线培训等场景（对应老版本的 ChatRoom 群）。
                        - "Community" ：社群，成员上限 100000 人，任何人都可以自由进出，且加群无需被审批，适合用于知识分享和游戏交流等超大社区群聊场景。5.8 版本开始支持，需要您购买旗舰版套餐。
                        - "AVChatRoom" ：直播群，人数无上限，任何人都可以自由进出，消息吞吐量大，适合用作直播场景中的高并发弹幕聊天室。
     * @param groupID - 群ID
     *
     * @note
     * 请注意如下特殊逻辑:
     * - 不支持在同一个 SDKAPPID 下创建两个相同 groupID 的群。
     * - 直播群（AVChatRoom）：在进程重启或重新登录之后，如果想继续接收直播群的消息，请您调用 joinGroup 重新加入直播群。
     */
    public createGroup(
        groupName: String,
        groupType: String,
        groupID?: String
    ): Promise<V2TimValueCallback<String>> {
        return this.nativeModule.call(this.manager, 'createGroup', {
            groupID,
            groupName,
            groupType,
        });
    }

    /**
     * ### 加入群组
     * @category 群组相关
     * @param groupID - 群ID
     * @param message - 申请入群信息
     *
     * @note
     * 请注意如下特殊逻辑:
     * - 工作群（Work）：不能主动入群，只能通过群成员调用 V2TIMManager.getGroupManager().inviteUserToGroup() 接口邀请入群。
     * - 公开群（Public）：申请入群后，需要管理员审批，管理员在收到 V2TIMGroupListener -> onReceiveJoinApplication 回调后调用 V2TIMManager.getGroupManager().getGroupApplicationList() 接口处理加群请求.
     * - 其他群：可以直接入群。
     * - 直播群（AVChatRoom）：在进程重启或重新登录之后，如果想继续接收直播群的消息，请您调用 joinGroup 重新加入直播群。
     */
    public joinGroup(groupID: String, message: String): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'joinGroup', {
            groupID,
            message,
        });
    }

    /**
     * ### 退群
     * @category 群组相关
     * @param groupID - 群ID
     *
     * @note
     * 在公开群（Public）、会议（Meeting）和直播群（AVChatRoom）中，群主是不可以退群的，群主只能调用 dismissGroup 解散群组。
     */
    public quitGroup(groupID: String): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'joinGroup', {
            groupID,
        });
    }

    /**
     * ### 解散群
     * @category 群组相关
     * @param groupID - 群ID
     *
     * @note
     * 请注意如下特殊逻辑:
     * - 好友工作群（Work）的解散最为严格，即使群主也不能随意解散，只能由您的业务服务器调用 解散群组 REST API 解散。
     * - 其他类型群的群主可以解散群组。
     */
    public dismissGroup(groupID: String): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'dismissGroup', {
            groupID,
        });
    }

    /**
     * ### 获取用户资料
     * @category 资料相关
     * @param userIDList - 需要获取资料的用户ID数组
     *
     * @note
     * 请注意:
     * - 获取自己的资料，传入自己的 ID 即可。
     * - userIDList 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
     */
    public getUsersInfo(
        userIDList: String[]
    ): Promise<V2TimValueCallback<V2TimUserFullInfo[]>> {
        return this.nativeModule.call(this.manager, 'getUsersInfo', {
            userIDList,
        });
    }

    /**
     * ### 修改个人资料
     * @category 资料相关
     * @param userFullInfo - 个人资料信息
     *
     */
    public setSelfInfo(
        userFullInfo: V2TimUserFullInfo
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'setSelfInfo', {
            ...userFullInfo,
        });
    }

    /**
     * ### 实验性 API 接口
     * @category 实验性接口
     * @param api - 接口名称
     * @param param - 接口参数
     *
     */
    public callExperimentalAPI(api: String, param?: Object) {
        return this.nativeModule.call(this.manager, 'callExperimentalAPI', {
            api,
            param,
        });
    }

    /**
     * ### 设置基本消息（文本消息和自定义消息）的事件监听器
     * @category 事件监听
     * @param listener - 监听回调
     *
     * @note
     * 图片消息、视频消息、语音消息等高级消息的监听。
     */
    public addSimpleMsgListener(listener: V2TimSimpleMsgListener): void {
        if (this.simpleMsgListenerList.length == 0) {
            this.nativeModule.call(this.manager, 'addSimpleMsgListener', {});
        }
        this.simpleMsgListenerList.push(listener);
    }

    /**
     * ### 移除基本消息（文本消息和自定义消息）的事件监听器
     * @category 事件监听
     * @param listener - 监听回调
     *
     */
    public removeSimpleMsgListener(listener?: V2TimSimpleMsgListener): void {
        if (!listener) {
            this.simpleMsgListenerList = [];
        } else {
            this.simpleMsgListenerList = this.simpleMsgListenerList.filter(
                (item) => listener != item
            );
        }
        if (this.simpleMsgListenerList.length === 0) {
            this.nativeModule.call(this.manager, 'removeSimpleMsgListener', {});
        }
    }
    /**
     * ### 添加群组监听器
     * @category 事件监听
     * @param listener - 监听回调
     *
     */
    public addGroupListener(listener: V2TimGroupListener): void {
        if (this.groupListenerList.length == 0) {
            this.nativeModule.call(this.manager, 'addGroupListener', {});
        }
        this.groupListenerList.push(listener);
    }
    /**
     * ### 移除群组监听器
     * @category 事件监听
     * @param listener - 监听回调
     *
     */
    public removeGroupListener(listener?: V2TimGroupListener): void {
        if (!listener) {
            this.groupListenerList = [];
        } else {
            this.groupListenerList = this.groupListenerList.filter(
                (item) => listener != item
            );
        }

        if (this.groupListenerList.length == 0) {
            this.nativeModule.call(this.manager, 'removeGroupListener', {});
        }
    }

    /**
     * ### 设置自己的状态
     * @category 资料相关
     * @param status - 待设置的自定义状态
     *
     */
    public setSelfStatus(status: String): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'setSelfStatus', {
            status,
        });
    }

    /**
     * ### 查询用户状态
     * @category 资料相关
     * @param userIDList - 需要获取的用户 ID
     *
     * @note
     * - 如果您想查询自己的自定义状态，您只需要传入自己的 userID 即可
     * - 当您批量查询时，接口只会返回查询成功的用户状态信息；当所有用户均查询失败时，接口会报错
     */
    public getUserStatus(
        userIDList: String[]
    ): Promise<V2TimValueCallback<V2TimUserStatus>> {
        return this.nativeModule.call(this.manager, 'getUserStatus', {
            userIDList,
        });
    }

    /**
     * ### 获取登录状态
     * @category 登录相关
     *
     */
    public getLoginStatus(): Promise<V2TimValueCallback<number>> {
        return this.nativeModule.call(this.manager, 'getLoginStatus', {});
    }

    /**
     * 设置 APNS 监听
     * @category APNS
     */
    public setAPNSListener(): void {
        this.nativeModule.call(this.manager, 'setAPNSListener', {});
    }

    /**
     * ### 关系链功能入口
     * @category 功能入口
     * @returns 关系链管理类实例
     */
    public getFriendshipManager(): V2TIMFriendshipManager {
        return this.v2TIMFriendshipManager;
    }

    /**
     * ### 高级群组功能入口
     * @category 功能入口
     * @returns 高级群组管理类实例
     */
    public getGroupManager(): V2TimGroupManager {
        return this.v2TIMGroupManager;
    }

    /**
     * ### 高级消息功能入口
     * @category 功能入口
     * @returns 高级消息管理类实例
     */
    public getMessageManager(): V2TIMMessageManager {
        return this.v2TIMMessageManager;
    }

    /**
     * ### 会话功能入口
     * @category 功能入口
     * @returns 会话管理类实例
     */
    public getConversationManager(): V2TIMConversationManager {
        return this.v2TIMConversationManager;
    }

    /**
     * ### 离线推送功能入口
     * @category 功能入口
     * @returns 离线推送管理类实例
     */
    public getOfflinePushManager(): V2TIMOfflinePushManager {
        return this.v2TIMOfflinePushManager;
    }

    /**
     * ### 信令入口
     * @category 功能入口
     * @returns 信令管理类实例
     */
    public getSignalingManager(): V2TIMSignalingManager {
        return this.v2timSignalingManager;
    }
}
