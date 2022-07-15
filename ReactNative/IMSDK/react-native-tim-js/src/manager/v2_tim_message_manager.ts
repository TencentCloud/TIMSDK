/**
 * 如果您需要收发图片、视频、文件等富媒体消息，并需要撤回消息、标记已读、查询历史消息等高级功能，推荐使用下面这套高级消息接口（简单消息接口和高级消息接口请不要混用）。
 * @module MessageManager(高级消息收发接口)
 */
import type { NativeEventEmitter } from 'react-native';
import type { V2TimAdvancedMsgListener } from '../interface/v2TimAdvancedMsgListener';
import type { GetGroupMessageReadMemberListFilter } from '../enum/getGroupMessageReadMemberListFilter';
import { HistoryMsgGetTypeEnum } from '../enum/historyMsgGetTypeEnum';
import { MessageElemType } from '../enum/messageElemType';
import { MessagePriorityEnum } from '../enum/messagePriority';
import type { ReceiveMsgOptEnum } from '../enum/receiveMsgOptEnum';
import type { V2TimCallback } from '../interface/v2TimCallback';
import type { V2TimGroupMessageReadMemberList } from '../interface/v2TimGroupMessageReadMemberList';
import type { V2TimMessage } from '../interface/v2TimMessage';
import type { V2TimMessageChangeInfo } from '../interface/v2TimMessageChangeInfo';
import type { V2TimMessageReceipt } from '../interface/v2TimMessageReceipt';
import type { V2TimMessageSearchParam } from '../interface/v2TimMessageSearchParam';
import type { V2TimMessageSearchResult } from '../interface/v2TimMessageSearchResult';
import type { V2TimMsgCreateInfoResult } from '../interface/v2TimMsgCreateInfoResult';
import type { V2TimOfflinePushInfo } from '../interface/v2TimOfflinePushInfo';
import type { V2TimReceiveMessageOptInfo } from '../interface/v2TimReceiveMessageOptInfo';
import type { V2TimValueCallback } from '../interface/v2TimValueCallback';

export class V2TIMMessageManager {
    private manager: string = 'messageManager';

    private nativeModule: any;
    private messageListenerList: V2TimAdvancedMsgListener[] = [];

    /** @hidden */
    constructor(eventEmitter: NativeEventEmitter, module: any) {
        this.nativeModule = module;
        this.addListener(eventEmitter);
    }

    private callListener(eventType: string, data: any) {
        this.messageListenerList.forEach((listener) => {
            switch (eventType) {
                case 'onRecvNewMessage':
                    listener.onRecvNewMessage &&
                        listener.onRecvNewMessage(data);
                    break;
                case 'onRecvMessageReadReceipts':
                    listener.onRecvMessageReadReceipts &&
                        listener.onRecvMessageReadReceipts(data);
                    break;
                case 'onRecvC2CReadReceipt':
                    listener.onRecvC2CReadReceipt &&
                        listener.onRecvC2CReadReceipt(data);
                    break;
                case 'onRecvMessageRevoked':
                    listener.onRecvMessageRevoked &&
                        listener.onRecvMessageRevoked(data);
                    break;
                case 'onRecvMessageModified':
                    listener.onRecvMessageModified &&
                        listener.onRecvMessageModified(data);
                    break;
            }
        });
    }

    private addListener(eventEmitter: NativeEventEmitter) {
        eventEmitter.addListener('messageListener', (response: any) => {
            // console.log(data);
            const { type, data } = response;
            this.callListener(type, data);
        });
    }

    /**
     * ### 添加高级消息的事件监听器
     * @param listener
     */
    public addAdvancedMsgListener(listener: V2TimAdvancedMsgListener): void {
        if (this.messageListenerList.length === 0) {
            this.nativeModule.call(this.manager, 'addAdvancedMsgListener', {});
        }
        this.messageListenerList.push(listener);
    }

    /**
     * ### 移除高级消息监听器
     * @param listener
     */
    public removeAdvancedMsgListener(
        listener?: V2TimAdvancedMsgListener
    ): void {
        if (!listener) {
            this.messageListenerList = [];
        } else {
            this.messageListenerList = this.messageListenerList.filter(
                (item) => item != listener
            );
        }

        if (this.messageListenerList.length == 0) {
            this.nativeModule.call(
                this.manager,
                'removeAdvancedMsgListener',
                {}
            )
        }
    }

    /**
     * ### 创建文本消息
     */
    public createTextMessage(
        text: string
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createTextMessage', {
            text,
        });
    }

    /**
     * ### 创建定向群消息
     * 如果您需要在群内给指定群成员列表发消息，可以创建一条定向群消息，定向群消息只有指定群成员才能收到。
     * @param id - 原始消息对象ID
     * @param receiverList - 消息接收者列表
     *
     * @note
     * 请注意:
     * - 原始消息对象不支持群 @ 消息。
     * - 社群（Community）和直播群（AVChatRoom）不支持发送定向群消息。
     * - 定向群消息默认不计入群会话的未读计数。
     */
    public createTargetedGroupMessage(
        id: string,
        receiverList: string[]
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(
            this.manager,
            'createTargetedGroupMessage',
            {
                id,
                receiverList,
            }
        );
    }

    /**
     * ### 添加多Element消息
     */
    public appendMessage(
        createMessageBaseId: string,
        createMessageAppendId: string
    ): V2TimValueCallback<V2TimMessage> {
        return this.nativeModule.call(this.manager, 'appendMessage', {
            createMessageAppendId,
            createMessageBaseId,
        });
    }

    /**
     * ### 创建自定义消息
     * @param param0
     * @param param0.data - 自定义消息
     * @param param0.desc - 自定义消息描述信息，做离线Push时文本展示
     * @param param0.extension - 离线 Push 时扩展字段信息。
     */
    public createCustomMessage({
        data,
        desc = '',
        extension = '',
    }: {
        data: string;
        desc?: string;
        extension?: string;
    }): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createCustomMessage', {
            data,
            desc,
            extension,
        });
    }

    /**
     * ### 创建图片消息
     * @param imagePath - 图片地址
     */
    public createImageMessage(
        imagePath: string
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createImageMessage', {
            imagePath,
        });
    }

    /**
     * ### 创建语音消息
     * @param soundPath - 音频文件地址
     * @param duration - 音频时长
     */
    public createSoundMessage(
        soundPath: string,
        duration: number
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createSoundMessage', {
            soundPath,
            duration,
        });
    }

    /**
     * ### 创建视频消息
     * @param videoFilePath - 视频文件地址
     * @param type - 视频类型，例如mp4
     * @param duration - 视频时长
     * @param snapshotPath - 视频第一帧截图，用于封面展示
     */
    public createVideoMessage(
        videoFilePath: string,
        type: string,
        duration: number,
        snapshotPath: string
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createVideoMessage', {
            videoFilePath,
            type,
            duration,
            snapshotPath,
        });
    }

    /**
     * ### 创建文本消息，并且可以附带 @ 提醒功能
     * @param text - 文本消息
     * @param atUserList - 需要提醒的用户列表
     *
     * @note
     * 请注意:
     * - 默认情况下，最多支持 @ 30个用户，超过限制后，消息会发送失败。
     * - atUserList 的总数不能超过默认最大数，包括 @ALL。
     * - 直播群（AVChatRoom）不支持发送 @ 消息。
     */
    public createTextAtMessage(
        text: string,
        atUserList: string[]
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createTextAtMessage', {
            text,
            atUserList,
        });
    }

    /**
     * ### 创建文件消息
     * @param filePath - 文件地址
     * @param fileName - 文件名称
     */
    public createFileMessage(
        filePath: string,
        fileName: string
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createFileMessage', {
            filePath,
            fileName,
        });
    }

    /**
     * ### 创建地理位置消息
     * @param desc - 位置描述
     * @param longitude - 经度
     * @param latitude - 纬度
     */
    public createLocationMessage(
        desc: string,
        longitude: number,
        latitude: number
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createLocationMessage', {
            desc,
            longitude,
            latitude,
        });
    }

    /**
     * ### 创建表情消息
     * SDK 并不提供表情包，如果开发者有表情包，可使用 index 存储表情在表情包中的索引， 或者直接使用 data 存储表情二进制信息以及字符串 key，都由用户自定义，SDK 内部只做透传。
     * @param index - 表情索引
     * @param data - 自定义数据
     */
    public createFaceMessage(
        index: number,
        data: string
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createFaceMessage', {
            index,
            data,
        });
    }

    /**
     * ### 创建合并消息
     * @param msgIDList - 消息列表（最大支持 300 条，消息对象必须是 V2TIM_MSG_STATUS_SEND_SUCC 状态，消息类型不能为 V2TIMGroupTipsElem）
     * @param title - 合并消息的来源，比如 "vinson 和 lynx 的聊天记录"、"xxx 群聊的聊天记录"。
     * @param abstractList - 合并消息的摘要列表(最大支持 5 条摘要，每条摘要的最大长度不超过 100 个字符),不同的消息类型可以设置不同的摘要信息，比如: 文本消息可以设置为：sender：text，图片消息可以设置为：sender：[图片]，文件消息可以设置为：sender：[文件]。
     * @param compatibleText - 合并消息兼容文本，低版本 SDK 如果不支持合并消息，默认会收到一条文本消息，文本消息的内容为 compatibleText， 该参数不能为 null。
     *
     * @note
     * 多条被转发的消息可以被创建成一条合并消息 V2TIMMessage，然后调用 sendMessage 接口发送，实现步骤如下：
     * - 1. 调用 createMergerMessage 创建一条合并消息 V2TIMMessage。
     * - 2. 调用 sendMessage 发送转发消息 V2TIMMessage。
     * 收到合并消息解析步骤：
     * - 1. 通过 V2TIMMessage 获取 mergerElem。
     * - 2. 通过 mergerElem 获取 title 和 abstractList UI 展示。
     * - 3. 当用户点击摘要信息 UI 的时候，调用 downloadMessageList 接口获取转发消息列表。
     */
    public createMergerMessage(
        msgIDList: string[],
        title: string,
        abstractList: string[],
        compatibleText: string
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createMergerMessage', {
            msgIDList,
            title,
            abstractList,
            compatibleText,
        });
    }

    /**
     * ### 创建转发消息
     * 如果需要转发一条消息，不能直接调用 sendMessage 接口发送原消息，需要先 createForwardMessage 创建一条转发消息再发送。
     * @param msgID - 待转发的消息对象ID
     */
    public createForwardMessage(
        msgID: string
    ): V2TimValueCallback<V2TimMsgCreateInfoResult> {
        return this.nativeModule.call(this.manager, 'createForwardMessage', {
            msgID,
        });
    }

    /**
     * ### 发送高级消息
     * @param param0
     * @param param0.id - 待发送的消息对象ID，需要通过对应的 createXXXMessage 接口进行创建。
     * @param param0.receiver - 消息接收者的 userID, 如果是发送 C2C 单聊消息，只需要指定 receiver 即可。
     * @param param0.groupID - 目标群组 ID，如果是发送群聊消息，只需要指定 groupID 即可。
     * @param param0.priority - 消息优先级，仅针对群聊消息有效。请把重要消息设置为高优先级（比如红包、礼物消息），高频且不重要的消息设置为低优先级（比如点赞消息）。
     * @param param0.onlineUserOnly - 是否只有在线用户才能收到，如果设置为 true ，接收方历史消息拉取不到，常被用于实现“对方正在输入”或群组里的非重要提示等弱提示功能，该字段不支持 AVChatRoom。
     * @param param0.isExcludedFromLastMessage - 是否在会话中不展示
     * @param param0.isExcludedFromUnreadCount - 是否不计入未读数
     * @param param0.needReadReceipt - 是否需要回执，只有群组消息有效，需要购买旗舰套餐
     * @param param0.offlinePushInfo - 离线推送消息描述
     * @param param0.cloudCustomData - 云端自定义数据
     * @param param0.localCustomData - 本地自定义数据
     *
     * @note
     * 注意：
     * - 6.0 及以上版本支持 groupID 和 receiver 同时设置，如果同时设置，表示在群内给 receiver 发送定向消息，如果需要给多个 receiver 发送定向消息，请先调用 createTargetedGroupMessage 接口创建定向消息，再调用 sendMessage 接口发送。
     * - 设置 offlinePushInfo 字段，需要先在 V2TIMOfflinePushManager 开启推送，推送开启后，除了自定义消息，其他消息默认都会推送。
     * - 如果自定义消息也需要推送，请设置 offlinePushInfo 的 desc 字段，设置成功后，推送的时候会默认展示 desc 信息。
     * - AVChatRoom 群聊不支持 onlineUserOnly 字段，如果是 AVChatRoom 请将该字段设置为 false。
     * - 如果设置 onlineUserOnly 为 true 时，该消息为在线消息且不会被计入未读计数。
     */
    public sendMessage({
        id,
        receiver,
        groupID,
        onlineUserOnly = false,
        isExcludedFromLastMessage = false,
        isExcludedFromUnreadCount = false,
        needReadReceipt = false,
        offlinePushInfo,
        cloudCustomData,
        localCustomData,
        priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    }: {
        id: string;
        receiver: string;
        groupID: string;
        onlineUserOnly?: boolean;
        isExcludedFromUnreadCount?: boolean;
        isExcludedFromLastMessage?: boolean;
        needReadReceipt?: boolean;
        offlinePushInfo?: V2TimOfflinePushInfo;
        cloudCustomData?: string;
        localCustomData?: string;
        priority?: MessagePriorityEnum;
    }): V2TimValueCallback<V2TimMessage> {
        return this.nativeModule.call(this.manager, 'sendMessage', {
            id,
            receiver,
            onlineUserOnly,
            groupID,
            isExcludedFromLastMessage,
            isExcludedFromUnreadCount,
            needReadReceipt,
            offlinePushInfo,
            cloudCustomData,
            localCustomData,
            priority,
        });
    }

    private _getAbstractMessage(message: V2TimMessage): string {
        const elemType = message.elemType;
        switch (elemType) {
            case MessageElemType.V2TIM_ELEM_TYPE_FACE:
                return '[表情消息]';
            case MessageElemType.V2TIM_ELEM_TYPE_CUSTOM:
                return '[自定义消息]';
            case MessageElemType.V2TIM_ELEM_TYPE_FILE:
                return '[文件消息]';
            case MessageElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
                return '[群消息]';
            case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
                return '[图片消息]';
            case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
                return '[位置消息]';
            case MessageElemType.V2TIM_ELEM_TYPE_MERGER:
                return '[合并消息]';
            case MessageElemType.V2TIM_ELEM_TYPE_NONE:
                return '[没有元素]';
            case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
                return '[语音消息]';
            case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
                return '[文本消息]';
            case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
                return '[视频消息]';
            default:
                return '';
        }
    }

    /**
     * ### 发送转发消息
     */
    public sendReplyMessage({
        id,
        receiver,
        groupID,
        onlineUserOnly = false,
        isExcludedFromLastMessage = false,
        isExcludedFromUnreadCount = false,
        needReadReceipt = false,
        offlinePushInfo,
        localCustomData,
        replyMessage,
        priority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    }: {
        id: string;
        receiver: string;
        groupID: string;
        replyMessage: V2TimMessage;
        onlineUserOnly?: boolean;
        isExcludedFromUnreadCount?: boolean;
        isExcludedFromLastMessage?: boolean;
        needReadReceipt?: boolean;
        offlinePushInfo?: V2TimOfflinePushInfo;
        localCustomData?: string;
        priority: MessagePriorityEnum;
    }): V2TimValueCallback<V2TimMessage> {
        const hasNickName =
            replyMessage.nickName && replyMessage.nickName !== '';
        const cloudCustomData = {
            messageReply: {
                messageID: replyMessage.msgID,
                messageAbstract: this._getAbstractMessage(replyMessage),
                messageSender: hasNickName
                    ? replyMessage.nickName
                    : replyMessage.sender,
                messageType: replyMessage.elemType,
                version: 1,
            },
        };

        return this.nativeModule.call(this.manager, 'sendMessage', {
            id,
            receiver,
            onlineUserOnly,
            groupID,
            isExcludedFromLastMessage,
            isExcludedFromUnreadCount,
            needReadReceipt,
            offlinePushInfo,
            cloudCustomData: JSON.stringify(cloudCustomData),
            localCustomData,
            priority,
        });
    }

    /**
     * ### 消息重发
     * @param msgID - 需要重发的消息ID
     * @param onlineUserOnly - 是否仅在线用户接收
     */
    public reSendMessage(
        msgID: string,
        onlineUserOnly = false
    ): V2TimValueCallback<V2TimMessage> {
        return this.nativeModule.call(this.manager, 'reSendMessage', {
            msgID,
            onlineUserOnly,
        });
    }

    /**
     * ### 设置针对某个用户的 C2C 消息接收选项
     * @param userIDList - 需要设置消息接收选项的用户ID列表
     * @param opt - 消息接收选项
     *
     * @note
     * 注意：
     * - 该接口支持批量设置，您可以通过参数 userIDList 设置一批用户，但一次最大允许设置 30 个用户。
     * - 该接口调用频率被限制为1秒内最多调用5次。
     */
    public setC2CReceiveMessageOpt(
        userIDList: string[],
        opt: ReceiveMsgOptEnum
    ): V2TimCallback {
        return this.nativeModule.call(this.manager, 'setC2CReceiveMessageOpt', {
            userIDList,
            opt,
        });
    }

    /**
     * ###  查询针对某个用户的 C2C 消息接收选项
     * @param userIDList - 需要获取消息选项的用户ID列表
     */
    public getC2CReceiveMessageOpt(
        userIDList: string[]
    ): V2TimValueCallback<V2TimReceiveMessageOptInfo> {
        return this.nativeModule.call(this.manager, 'getC2CReceiveMessageOpt', {
            userIDList,
        });
    }

    /**
     * ### 设置群消息的接收选项
     */
    public setGroupReceiveMessageOpt(
        groupID: string,
        opt: ReceiveMsgOptEnum
    ): V2TimCallback {
        return this.nativeModule.call(
            this.manager,
            'setGroupReceiveMessageOpt',
            {
                groupID,
                opt,
            }
        );
    }

    /**
     * ### 设置消息自定义数据（本地保存，不会发送到对端，程序卸载重装后失效）
     */
    public setLocalCustomData(
        msgID: string,
        localCustomData: string
    ): V2TimCallback {
        return this.nativeModule.call(this.manager, 'setLocalCustomData', {
            msgID,
            localCustomData,
        });
    }

    /**
     * ### 设置消息自定义数据，可以用来标记语音、视频消息是否已经播放（本地保存，不会发送到对端，程序卸载重装后失效）
     */
    public setLocalCustomInt(
        msgID: string,
        localCustomInt: number
    ): V2TimCallback {
        return this.nativeModule.call(this.manager, 'setLocalCustomInt', {
            msgID,
            localCustomInt,
        });
    }

    /**
     * ### 获取单聊历史消息
     * @param userID - 需要获取消息的用户ID
     * @param count - 拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
     * @param lastMsgID - 获取消息的起始消息，如果传 nil，起始消息为会话的最新消息
     */
    public getC2CHistoryMessageList(
        userID: string,
        count: number,
        lastMsgID?: string
    ): V2TimValueCallback<V2TimMessage[]> {
        return this.nativeModule.call(
            this.manager,
            'getC2CHistoryMessageList',
            {
                userID,
                count,
                lastMsgID,
            }
        );
    }

    /**
     * ### 获取群组历史消息
     * @param groupID - 群ID
     * @param count - 拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
     * @param lastMsgID - 获取消息的起始消息，如果传 nil，起始消息为会话的最新消息
     *
     * @note
     * - 如果 SDK 检测到没有网络，默认会直接返回本地数据
     * - 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
     */
    public getGroupHistoryMessageList(
        groupID: string,
        count: number,
        lastMsgID?: string
    ): V2TimValueCallback<V2TimMessage[]> {
        return this.nativeModule.call(
            this.manager,
            'getGroupHistoryMessageList',
            {
                groupID,
                count,
                lastMsgID,
            }
        );
    }

    /**
     * ### 撤回消息
     * @note
     * 请注意:
     * - 撤回消息的时间限制默认 2 minutes，超过 2 minutes 的消息不能撤回，您也可以在 控制台（功能配置 -> 登录与消息 -> 消息撤回设置）自定义撤回时间限制。
     * - 仅支持单聊和群组中发送的普通消息，无法撤销 onlineUserOnly 为 true 即仅在线用户才能收到的消息，也无法撤销直播群（AVChatRoom）中的消息。
     * - 如果发送方撤回消息，已经收到消息的一方会收到 V2TIMAdvancedMsgListener -> onRecvMessageRevoked 回调。
     */
    public revokeMessage(msgID: string): V2TimCallback {
        return this.nativeModule.call(this.manager, 'revokeMessage', {
            msgID,
        });
    }

    /**
     * ### 标记单聊会话已读
     * @param userID
     * @note
     * 注意：
     * - 该接口调用成功后，自己的未读数会清 0，对端用户会收到 onRecvC2CReadReceipt 回调，回调里面会携带标记会话已读的时间。
     */
    public markC2CMessageAsRead(userID: string): V2TimCallback {
        return this.nativeModule.call(this.manager, 'markC2CMessageAsRead', {
            userID,
        });
    }

    /**
     * ### 标记群组会话已读
     * @param groupID
     * @note
     * 注意：
     * - 该接口调用成功后，自己的未读数会清 0。
     */
    public markGroupMessageAsRead(groupID: string): V2TimCallback {
        return this.nativeModule.call(this.manager, 'markGroupMessageAsRead', {
            groupID,
        });
    }

    /**
     * ### 获取历史消息高级接口
     * @note
     * 请注意:
     * - 如果设置为拉取云端消息，当 SDK 检测到没有网络，默认会直接返回本地数据
     * - 只有会议群（Meeting）才能拉取到进群前的历史消息，直播群（AVChatRoom）消息不存漫游和本地数据库，调用这个接口无效
     */
    public getHistoryMessageList(
        count: number,
        getType = HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG,
        userID?: string,
        groupID?: string,
        lastMsgSeq = -1,
        lastMsgID?: string,
        messageTypeList?: number[]
    ): V2TimValueCallback<V2TimMessage[]> {
        return this.nativeModule.call(this.manager, 'getHistoryMessageList', {
            count,
            getType,
            userID,
            groupID,
            lastMsgID,
            lastMsgSeq,
            messageTypeList: messageTypeList ?? [],
        });
    }

    /**
     * ### 删除本地消息
     * @note
     * 注意：
     * 该接口只能删除本地历史，消息删除后，SDK 会在本地把这条消息标记为已删除状态，getHistoryMessage 不能再拉取到，如果程序卸载重装，本地会失去对这条消息的删除标记，getHistoryMessage 还能再拉取到该条消息。
     */
    public deleteMessageFromLocalStorage(msgID: string): V2TimCallback {
        return this.nativeModule.call(
            this.manager,
            'deleteMessageFromLocalStorage',
            {
                msgID,
            }
        );
    }

    /**
     * ### 删除本地及云端的消息
     * @note
     * 该接口会在 deleteMessageFromLocalStorage 的基础上，同步删除云端存储的消息，且无法恢复。需要注意的是：
     * - 一次最多只能删除 30 条消息
     * - 要删除的消息必须属于同一会话
     * - 一秒钟最多只能调用一次该接口
     * - 如果该账号在其他设备上拉取过这些消息，那么调用该接口删除后，这些消息仍然会保存在那些设备上，即删除消息不支持多端同步。
     */
    public deleteMessages(msgIDs: string[]): V2TimCallback {
        return this.nativeModule.call(this.manager, 'deleteMessages', {
            msgIDs,
        });
    }

    /**
     * ### 向群组消息列表中添加一条消息
     * 该接口主要用于满足向群组聊天会话中插入一些提示性消息的需求，比如“您已经退出该群”，这类消息有展示 在聊天消息区的需求，但并没有发送给其他人的必要。 所以 insertGroupMessageToLocalStorage() 相当于一个被禁用了网络发送能力的 sendMessage() 接口。
     * @param data
     * @param groupID
     * @param sender
     * @note
     * 注意:
     * - 通过该接口 save 的消息只存本地，程序卸载后会丢失。
     */
    public insertGroupMessageToLocalStorage(
        data: string,
        groupID: string,
        sender: string
    ): V2TimValueCallback<V2TimMessage> {
        return this.nativeModule.call(
            this.manager,
            'insertGroupMessageToLocalStorage',
            {
                data,
                groupID,
                sender,
            }
        );
    }

    /**
     * ### 向C2C消息列表中添加一条消息
     * 该接口主要用于满足向C2C聊天会话中插入一些提示性消息的需求，比如“您已成功发送消息”，这类消息有展示 在聊天消息区的需求，但并没有发送给对方的必要。 所以 insertC2CMessageToLocalStorage()相当于一个被禁用了网络发送能力的 sendMessage() 接口。
     * @param data
     * @param userID
     * @param sender
     * @note
     * 注意:
     * - 通过该接口 save 的消息只存本地，程序卸载后会丢失。
     */
    public insertC2CMessageToLocalStorage(
        data: string,
        userID: string,
        sender: string
    ): V2TimValueCallback<V2TimMessage> {
        return this.nativeModule.call(
            this.manager,
            'insertC2CMessageToLocalStorage',
            {
                data,
                userID,
                sender,
            }
        );
    }

    /**
     * ### 清空单聊本地及云端的消息（不删除会话）
     * @param userID
     * @note
     * 注意:
     * - 会话内的消息在本地删除的同时，在服务器也会同步删除。
     */
    public clearC2CHistoryMessage(userID: string): V2TimCallback {
        return this.nativeModule.call(this.manager, 'clearC2CHistoryMessage', {
            userID,
        });
    }

    /**
     * ### 清空群聊本地及云端的消息（不删除会话）
     * @param groupID
     * @note
     * 注意:
     * - 会话内的消息在本地删除的同时，在服务器也会同步删除。
     */
    public clearGroupHistoryMessage(groupID: string): V2TimCallback {
        return this.nativeModule.call(
            this.manager,
            'clearGroupHistoryMessage',
            {
                groupID,
            }
        );
    }

    /**
     * 标记所有会话为已读
     */
    public markAllMessageAsRead(): V2TimCallback {
        return this.nativeModule.call(this.manager, 'markAllMessageAsRead', {});
    }

    /**
     * ###  搜索本地消息
     * @param param0
     * @param param0.keywordList - 关键字列表，最多支持5个。当消息发送者以及消息类型均未指定时，关键字列表必须非空；否则，关键字列表可以为空。
     * @param param0.type - 指定关键字列表匹配类型，可设置为“或”关系搜索或者“与”关系搜索. 取值分别为 0 和 1，默认为“或”关系搜索。
     * @param param0.userIDList - 指定 userID 发送的消息，最多支持5个。
     * @param param0.messageTypeList - 指定搜索的消息类型集合，传 nil 表示搜索支持的全部类型消息（V2TIMFaceElem 和 V2TIMGroupTipsElem 不支持）取值详见 @V2TIMElemType。
     * @param param0.conversationID - 搜索“全部会话”还是搜索“指定的会话”：如果设置 conversationID == nil，代表搜索全部会话。
     * @param param0.searchTimePeriod - 从起始时间点开始的过去时间范围，单位秒。默认为0即代表不限制时间范围，传24x60x60代表过去一天。
     * @param param0.searchTimePosition - 搜索的起始时间点。默认为0即代表从现在开始搜索。UTC 时间戳，单位：秒
     * @param param0.pageIndex - 分页的页号：用于分页展示查找结果，从零开始起步。 比如：您希望每页展示 10 条结果，请按照如下规则调用：
     * - 首次调用：通过参数 pageSize = 10, pageIndex = 0 调用 searchLocalMessage，从结果回调中的 totalCount 可以获知总共有多少条结果。
     * - 计算页数：可以获知总页数：totalPage = (totalCount % pageSize == 0) ? (totalCount / pageSize) : (totalCount / pageSize + 1) 。
     * - 再次调用：可以通过指定参数 pageIndex （pageIndex < totalPage）返回后续页号的结果。
     * @param param0.pageSize - 每页结果数量：用于分页展示查找结果，如不希望分页可将其设置成 0，但如果结果太多，可能会带来性能问题。
     * @returns
     */
    public searchLocalMessages({
        conversationID,
        keywordList,
        type,
        userIDList = [],
        messageTypeList = [],
        searchTimePeriod,
        searchTimePosition,
        pageIndex = 0,
        pageSize = 100,
    }: V2TimMessageSearchParam): V2TimValueCallback<V2TimMessageSearchResult> {
        return this.nativeModule.call(this.manager, 'searchLocalMessages', {
            searchParam: {
                conversationID,
                keywordList,
                type,
                userIDList,
                messageTypeList,
                searchTimePeriod,
                searchTimePosition,
                pageIndex,
                pageSize,
            },
        });
    }

    /**
     * ### 发送消息已读回执
     * @param messageIDList
     * @note
     * 注意:
     * - messageList 里的消息必须在同一个会话中。
     * - 该接口调用成功后，会话未读数不会变化，消息发送者会收到 onRecvMessageReadReceipts 回调，回调里面会携带消息的最新已读信息。
     */
    public sendMessageReadReceipts(messageIDList: string[]): V2TimCallback {
        return this.nativeModule.call(this.manager, 'sendMessageReadReceipts', {
            messageIDList,
        });
    }

    /**
     * ### 获取消息已读回执
     * @param messageIDList
     * @note
     * 注意:
     * - messageList 里的消息必须在同一个会话中。
     */
    public getMessageReadReceipts(
        messageIDList: string[]
    ): V2TimValueCallback<V2TimMessageReceipt[]> {
        return this.nativeModule.call(this.manager, 'getMessageReadReceipts', {
            messageIDList,
        });
    }

    /**
     * ### 获取群消息已读群成员列表
     * @param messageID - 群消息ID
     * @param filter - 指定拉取已读或未读群成员列表。
     * @param nextSeq - 分页拉取的游标，第一次默认取传 0，后续分页拉传上一次分页拉取成功回调里的 nextSeq。
     * @param count - 分页拉取的个数，最大支持 100 个。
     */
    public getGroupMessageReadMemberList(
        messageID: string,
        filter: GetGroupMessageReadMemberListFilter,
        nextSeq = 0,
        count = 100
    ): V2TimValueCallback<V2TimGroupMessageReadMemberList> {
        return this.nativeModule.call(
            this.manager,
            'getGroupMessageReadMemberList',
            {
                messageID,
                filter,
                nextSeq,
                count,
            }
        );
    }

    /**
     * ### 根据 messageID 查询指定会话中的本地消息
     * @param messageIDList
     */
    public findMessages(
        messageIDList: string[]
    ): V2TimValueCallback<V2TimMessage[]> {
        return this.nativeModule.call(this.manager, 'findMessages', {
            messageIDList,
        });
    }

    /**
     * ### 消息变更
     * @param message
     * @note
     * 请注意:
     * - 如果消息修改成功，自己和对端用户（C2C）或群组成员（Group）都会收到 onRecvMessageModified 回调。
     * - 如果在修改消息过程中，消息已经被其他人修改，completion 会返回 ERR_SDK_MSG_MODIFY_CONFLICT 错误。
     * - 消息无论修改成功或则失败，completion 都会返回最新的消息对象。
     */
    public modifyMessage(
        message: V2TimMessage
    ): V2TimValueCallback<V2TimMessageChangeInfo> {
        return this.nativeModule.call(this.manager, 'modifyMessage', {
            message,
        });
    }

    /**
     * ### 下载被合并的消息列表
     * @param msgID
     */
    public downloadMergerMessage(
        msgID: string
    ): V2TimValueCallback<V2TimMessage[]> {
        return this.nativeModule.call(this.manager, 'downloadMergerMessage', {
            msgID,
        });
    }
}
