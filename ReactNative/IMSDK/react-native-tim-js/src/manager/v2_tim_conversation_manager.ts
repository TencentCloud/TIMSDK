/**
 * 会话，即登录微信或 QQ 后首屏看到的一个个聊天会话，包含会话节点、会话名称、群名称、最后一条消息以及未读消息数等元素。
 * @module ConversationManager(会话相关接口)
 */
import type { NativeEventEmitter } from 'react-native';
import type V2TimCallback from '../interface/v2TimCallback';
import type V2TimConversation from '../interface/v2TimConversation';
import type V2TimConversationListener from '../interface/v2TimConversationListener';
import type V2TimValueCallback from '../interface/v2TimValueCallback';

export class V2TIMConversationManager {
    private manager: String = 'conversationManager';
    private nativeModule: any;
    private conversationListenerList: V2TimConversationListener[] = [];

    /** @hidden */
    constructor(eventEmitter: NativeEventEmitter, module: any) {
        this.nativeModule = module;
        this.addListener(eventEmitter);
    }

    private addListener(eventEmitter: NativeEventEmitter) {
        eventEmitter.addListener('conversationListener', (response: any) => {
            const { type, data } = response;
            this.conversationListenerList.forEach((listener) => {
                switch (type) {
                    case 'onConversationChanged':
                        listener.onConversationChanged &&
                            listener.onConversationChanged(data);
                        break;
                    case 'onNewConversation':
                        listener.onNewConversation &&
                            listener.onNewConversation(data);
                        break;
                    case 'onSyncServerStart':
                        listener.onSyncServerStart &&
                            listener.onSyncServerStart();
                        break;
                    case 'onSyncServerFinish':
                        listener.onSyncServerFinish &&
                            listener.onSyncServerFinish();
                        break;
                    case 'onSyncServerFailed':
                        listener.onSyncServerFailed &&
                            listener.onSyncServerFailed();
                        break;
                    case 'onTotalUnreadMessageCountChanged':
                        listener.onTotalUnreadMessageCountChanged &&
                            listener.onTotalUnreadMessageCountChanged(data);
                        break;
                }
            });
        });
    }

    /**
     * ### 添加会话监听器
     * @category 事件监听
     * @param listener - 监听器
     *
     */
    public addConversationListener(listener: V2TimConversationListener): void {
        if (this.conversationListenerList.length == 0) {
            this.nativeModule.call(this.manager, 'addConversationListener', {});
        }
        this.conversationListenerList.push(listener);
    }

    /**
     * ### 移除会话监听器
     * @category 事件监听
     * @param listener - 监听器
     *
     */
    public removeConversationListener(
        listener?: V2TimConversationListener
    ): void {
        if (!listener) {
            this.conversationListenerList = [];
        } else {
            this.conversationListenerList =
                this.conversationListenerList.filter(
                    (item) => item != listener
                );
        }

        if (this.conversationListenerList.length == 0) {
            this.nativeModule.call(
                this.manager,
                'removeConversationListener',
                {}
            );
        }
    }

    /**
     * ### 获取会话列表
     * - 一个会话对应一个聊天窗口，比如跟一个好友的 1v1 聊天，或者一个聊天群，都是一个会话。
     * - 由于历史的会话数量可能很多，所以该接口希望您采用分页查询的方式进行调用，每次分页拉取的个数建议为 100 个。
     * - 该接口拉取的是本地缓存的会话，如果服务器会话有更新，SDK 内部会自动同步，然后在 V2TIMConversationListener 回调告知客户。
     * - 如果会话全部拉取完毕，成功回调里面 V2TIMConversationResult 中的 isFinished 获取字段值为 true。
     * @category 获取会话信息
     * @param count - 分页拉取的个数，一次分页拉取不宜太多，会影响拉取的速度，建议每次拉取 100 个会话
     * @param nextSeq - 分页拉取的游标，第一次默认取传 0，后续分页拉传上一次分页拉取成功回调里的 nextSeq
     *
     */
    public getConversationList(
        count: number,
        nextSeq: String
    ): Promise<
        V2TimValueCallback<{
            nextSeq?: String;
            isFinished?: boolean;
            conversationList?: V2TimConversation[];
        }>
    > {
        return this.nativeModule.call(this.manager, 'getConversationList', {
            count,
            nextSeq,
        });
    }

    /**
     * ### 获取指定会话信息
     * @category 获取会话信息
     * @param conversationIDList - 会话ID
     *
     */
    public getConversationListByConversaionIds(
        conversationIDList: String[]
    ): Promise<V2TimValueCallback<V2TimConversation[]>> {
        return this.nativeModule.call(
            this.manager,
            'getConversationListByConversaionIds',
            { conversationIDList }
        );
    }

    /**
     * ### 会话置顶
     * @category 会话置顶
     * @param conversationID - 会话ID
     * @param isPinned - 是否置顶
     *
     */
    public pinConversation(
        conversationID: String,
        isPinned: boolean
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'pinConversation', {
            conversationID,
            isPinned,
        });
    }

    /**
     * ### 获取会话未读总数
     * @category 获取会话未读总数
     *
     */
    public getTotalUnreadMessageCount(): Promise<V2TimValueCallback<number>> {
        return this.nativeModule.call(
            this.manager,
            'getTotalUnreadMessageCount',
            {}
        );
    }

    /**
     * ### 获取单个会话
     * @category 获取会话信息
     * @param conversationID - 会话唯一 ID，C2C 单聊组成方式为: String.format("c2c_%s", "userID")；群聊组成方式为: String.format("group_%s", "groupID")
     *
     */
    public getConversation(
        conversationID: String
    ): Promise<V2TimValueCallback<V2TimConversation>> {
        return this.nativeModule.call(this.manager, 'getConversation', {
            conversationID,
        });
    }

    /**
     * ### 删除会话
     * @category 删除会话
     * @param conversationID - 会话唯一 ID，C2C 单聊组成方式为: String.format("c2c_%s", "userID")；群聊组成方式为: String.format("group_%s", "groupID")
     *
     * @note
     * 请注意:
     * - 删除会话会在本地删除的同时，在服务器也会同步删除。
     * - 会话内的消息在本地删除的同时，在服务器也会同步删除。
     *
     */
    public deleteConversation(conversationID: String): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'deleteConversation', {
            conversationID,
        });
    }

    /**
     * ### 设置会话草稿
     * 只在本地保存，不会存储 Server，不能多端同步，程序卸载重装会失效。
     * @category 会话草稿
     * @param conversationID - 会话唯一 ID，C2C 单聊组成方式为: String.format("c2c_%s", "userID")；群聊组成方式为: String.format("group_%s", "groupID")
     * @param draftText - 草稿内容, 为 null 则表示取消草稿
     */
    public setConversationDraft(
        conversationID: String,
        draftText?: String
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'setConversationDraft', {
            conversationID,
            draftText,
        });
    }
}
