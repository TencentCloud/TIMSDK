/**
 * 腾讯云 IM 在收发消息时默认不检查是不是好友关系，您可以在 [腾讯云IM官网](https://cloud.tencent.com/document/product/269/51940#.E5.A5.BD.E5.8F.8B.E7.AE.A1.E7.90.86.E7.9B.B8.E5.85.B3.E6.8E.A5.E5.8F.A3])
 * 控制台 >功能配置>登录与消息>好友关系检查中开启"发送单聊消息检查关系链"开关，并使用如下接口增删好友和管理好友列表。
 * @module FriendshipManager(好友管理相关接口)
 */
import type { NativeEventEmitter } from 'react-native';
import type V2TimFriendInfo from '../interface/v2TimFriendInfo';
import type V2TimValueCallback from '../interface/v2TimValueCallback';
import type V2TimFriendshipListener from '../interface/v2TimFriendshipListener';
import type V2TimFriendInfoResult from '../interface/v2TimFriendInfoResult';
import type { StringMap } from '../interface/commonInterface';
import type V2TimCallback from '../interface/v2TimCallback';
import type V2TimFriendOperationResult from '../interface/v2TimFriendOperationResult';
import type V2TimFriendCheckResult from '../interface/v2TimFriendCheckResult';
import type V2TimFriendApplicationResult from '../interface/v2TimFriendApplicationResult';
import type V2TimFriendGroup from '../interface/v2TimFriendGroup';
import type V2TimFriendSearchParam from '../interface/v2TimFriendSearchParam';
import type { FriendType } from '../enum/friendType';
import type { FriendResponseTypeEnum } from '../enum/friendResponseType';
import type { FriendApplicationTypeEnum } from '../enum/friendApplicationType';

export class V2TIMFriendshipManager {
    private manager: String = 'friendshipManager';
    private nativeModule: any;
    private friendListenerList: V2TimFriendshipListener[] = [];

    /** @hidden */
    constructor(eventEmitter: NativeEventEmitter, module: any) {
        this.nativeModule = module;
        this.addListener(eventEmitter);
    }

    private callFriendshipListener(eventType: String, data: any) {
        this.friendListenerList.forEach((listener) => {
            switch (eventType) {
                case 'onFriendApplicationListAdded':
                    listener.onFriendApplicationListAdded(data);
                    break;
                case 'onFriendApplicationListDeleted':
                    listener.onFriendApplicationListDeleted(data);
                    break;
                case 'onFriendApplicationListRead':
                    listener.onFriendApplicationListRead();
                    break;
                case 'onFriendListAdded':
                    listener.onFriendListAdded(data);
                    break;
                case 'onFriendListDeleted':
                    listener.onFriendListDeleted(data);
                    break;
                case 'onBlackListAdd':
                    listener.onBlackListAdd(data);
                    break;
                case 'onBlackListDeleted':
                    listener.onBlackListDeleted(data);
                    break;
                case 'onFriendInfoChanged':
                    listener.onFriendInfoChanged(data);
                    break;
            }
        });
    }

    private addListener(eventEmitter: NativeEventEmitter) {
        eventEmitter.addListener('friendListener', (response: any) => {
            const { type, data } = response;
            this.callFriendshipListener(type, data);
        });
    }

    /**
     * 添加关系链监听器
     * @category 事件监听
     * @param listener - 监听器
     */
    public addFriendListener(listener: V2TimFriendshipListener): void {
        if (this.friendListenerList.length == 0) {
            this.nativeModule.call(this.manager, 'addFriendListener', {});
        }
        this.friendListenerList.push(listener);
    }

    /**
     * 移除关系链监听器
     * @category 事件监听
     * @param listener - 监听器
     */
    public removeFriendListener(listener?: V2TimFriendshipListener): void {
        if (!listener) {
            this.friendListenerList = [];
        } else {
            this.friendListenerList = this.friendListenerList.filter(
                (item) => listener != item
            );
        }

        if (this.friendListenerList.length == 0) {
            this.nativeModule.call(this.manager, 'removeFriendListener', {});
        }
    }

    /**
     * 获取好友列表
     * @category 获取好友列表
     */
    public getFriendList(): Promise<V2TimValueCallback<V2TimFriendInfo[]>> {
        return this.nativeModule.call(this.manager, 'getFriendList', {});
    }

    /**
     * 获取指定好友资料
     * @category 获取好友信息
     * @param userIDList - 好友ID数组
     * - ID 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
     */
    public getFriendsInfo(
        userIDList: String[]
    ): Promise<V2TimValueCallback<V2TimFriendInfoResult[]>> {
        return this.nativeModule.call(this.manager, 'getFriendsInfo', {
            userIDList,
        });
    }

    /**
     * 设置指定好友资料
     * @category 设置指定好友资料
     * @param userID - 好友userID
     * @param friendRemark - 好友备注
     * @param friendCustomInfo - 好友自定义信息
     */
    public setFriendInfo(
        userID: String,
        friendRemark?: String,
        friendCustomInfo?: StringMap
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'setFriendInfo', {
            userID,
            friendRemark,
            friendCustomInfo,
        });
    }

    /**
     * ### 添加好友
     * @param userID - 好友userID
     * @param addType - 添加方式
     * @param remark - 好友备注
     * @param friendGroup - 好友分组
     * @param addWording - 添加简述
     * @param addSource - 来源描述
     */
    public addFriend(
        userID: String,
        addType: FriendType,
        remark?: String,
        friendGroup?: String,
        addWording?: String,
        addSource?: String
    ): Promise<V2TimValueCallback<V2TimFriendOperationResult>> {
        return this.nativeModule.call(this.manager, 'addFriend', {
            userID,
            addType,
            remark,
            friendGroup,
            addWording,
            addSource,
        });
    }

    /**
     * 删除好友
     * @param userIDList 要删除的好友 userID 列表
     * @param deleteType 删除类型
     */
    public deleteFromFriendList(
        userIDList: String[],
        deleteType: FriendType
    ): Promise<V2TimValueCallback<V2TimFriendOperationResult[]>> {
        return this.nativeModule.call(this.manager, 'deleteFromFriendList', {
            userIDList,
            deleteType,
        });
    }

    /**
     * 检查指定用户的好友关系
     * @param userIDList 要检查的userID 列表
     * @param checkType 检查类型
     *
     * @note
     * checkType 的使用需要注意：
     * - checkType 如果传入 V2TIM_FRIEND_TYPE_SINGLE，结果返回：V2TIM_FRIEND_RELATION_TYPE_NONE、V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST 两种情况
     * - checkType 如果传入 V2TIM_FRIEND_TYPE_BOTH，结果返回：V2TIM_FRIEND_RELATION_TYPE_NONE、V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST、 V2TIM_FRIEND_RELATION_TYPE_IN_OTHER_FRIEND_LIST、V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY 四种情况
     */
    public checkFriend(
        userIDList: String[],
        checkType: FriendType
    ): Promise<V2TimValueCallback<V2TimFriendCheckResult[]>> {
        return this.nativeModule.call(this.manager, 'checkFriend', {
            userIDList,
            checkType,
        });
    }

    /**
     * 获取好友申请列表
     */
    public getFriendApplicationList(): Promise<
        V2TimValueCallback<V2TimFriendApplicationResult>
    > {
        return this.nativeModule.call(
            this.manager,
            'getFriendApplicationList',
            {}
        );
    }

    /**
     * ### 同意好友申请
     * @param responseType - 建立单向/双向好友关系
     * @param type - 请求类型
     * @param userID - 用户ID
     */
    public acceptFriendApplication(
        responseType: FriendResponseTypeEnum,
        type: FriendApplicationTypeEnum,
        userID: String
    ): Promise<V2TimValueCallback<V2TimFriendOperationResult>> {
        return this.nativeModule.call(this.manager, 'acceptFriendApplication', {
            responseType,
            type,
            userID,
        });
    }

    /**
     * ### 拒绝好友申请
     * @param type 请求类型
     * @param userID 用户ID
     */
    public refuseFriendApplication(
        type: FriendApplicationTypeEnum,
        userID: String
    ): Promise<V2TimValueCallback<V2TimFriendOperationResult>> {
        return this.nativeModule.call(this.manager, 'refuseFriendApplication', {
            type,
            userID,
        });
    }

    /**
     * ### 删除好友申请
     * @param type 请求类型
     * @param userID 用户ID
     */
    public deleteFriendApplication(
        type: FriendApplicationTypeEnum,
        userID: String
    ): Promise<V2TimValueCallback<V2TimFriendOperationResult>> {
        return this.nativeModule.call(this.manager, 'deleteFriendApplication', {
            type,
            userID,
        });
    }

    /**
     * ### 设置好友申请已读
     */
    public setFriendApplicationRead(): Promise<V2TimCallback> {
        return this.nativeModule.call(
            this.manager,
            'setFriendApplicationRead',
            {}
        );
    }

    /**
     * 添加用户到黑名单
     * @param userIDList 用户userID 列表
     */
    public addToBlackList(
        userIDList: String[]
    ): Promise<V2TimValueCallback<V2TimFriendOperationResult[]>> {
        return this.nativeModule.call(this.manager, 'addToBlackList', {
            userIDList,
        });
    }

    /**
     * 把用户从黑名单中删除
     * @param userIDList 用户userID 列表
     */
    public deleteFromBlackList(
        userIDList: String[]
    ): Promise<V2TimValueCallback<V2TimFriendOperationResult[]>> {
        return this.nativeModule.call(this.manager, 'deleteFromBlackList', {
            userIDList,
        });
    }

    /**
     * ### 获取黑名单
     */
    public getBlackList(): Promise<V2TimValueCallback<V2TimFriendInfo[]>> {
        return this.nativeModule.call(this.manager, 'getBlackList', {});
    }

    /**
     * ### 创建好友分组
     * @param groupName - 分组名称
     * @param userIDList - 用户userID 列表
     */
    public createFriendGroup(
        groupName: String,
        userIDList?: String[]
    ): Promise<V2TimValueCallback<V2TimFriendOperationResult[]>> {
        return this.nativeModule.call(this.manager, 'createFriendGroup', {
            groupName,
            userIDList,
        });
    }

    /**
     * ### 获取分组信息
     * @param groupNameList - 要获取信息的好友分组名称列表,传入 null 获得所有分组信息
     */
    public getFriendGroups(
        groupNameList?: String[]
    ): Promise<V2TimValueCallback<V2TimFriendGroup[]>> {
        return this.nativeModule.call(this.manager, 'getFriendGroups', {
            groupNameList,
        });
    }

    /**
     * ### 删除好友分组
     * @param groupNameList - 分组名称列表
     */
    public deleteFriendGroup(groupNameList?: String[]): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'deleteFriendGroup', {
            groupNameList,
        });
    }

    /**
     * ### 好友分组重命名
     * @param oldName - 分组旧名称
     * @param newName - 分组新名称
     */
    public renameFriendGroup(
        oldName: String,
        newName: String
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'renameFriendGroup', {
            oldName,
            newName,
        });
    }

    /**
     * ### 添加好友到分组
     * @param groupName - 好友分组名称
     * @param userIDList - 用户userID 列表
     */
    public addFriendsToFriendGroup(
        groupName: String,
        userIDList: String[]
    ): Promise<V2TimValueCallback<V2TimFriendOperationResult[]>> {
        return this.nativeModule.call(this.manager, 'addFriendsToFriendGroup', {
            groupName,
            userIDList,
        });
    }

    /**
     * ### 把好友从好友分组中删除
     * @param groupName - 好友分组名称
     * @param userIDList - 用户userID 列表
     */
    public deleteFriendsFromFriendGroup(
        groupName: String,
        userIDList: String[]
    ): Promise<V2TimValueCallback<V2TimFriendOperationResult[]>> {
        return this.nativeModule.call(
            this.manager,
            'deleteFriendsFromFriendGroup',
            { groupName, userIDList }
        );
    }

    /**
     * ### 搜索好友
     * @param param0
     * @param param0.keywordList - 搜索关键字列表，关键字列表最多支持5个。
     * @param param0.isSearchNickName - 是否搜索昵称
     * @param param0.isSearchRemark - 是否搜索备注
     * @param param0.isSearchUserID - 是否搜索 userID
     *
     * @note
     * 需要购买旗舰版套餐
     */
    public searchFriends({
        keywordList,
        isSearchNickName = true,
        isSearchRemark = true,
        isSearchUserID = true,
    }: V2TimFriendSearchParam): Promise<
        V2TimValueCallback<V2TimFriendInfoResult[]>
    > {
        return this.nativeModule.call(this.manager, 'searchFriends', {
            searchParam: {
                keywordList,
                isSearchRemark,
                isSearchNickName,
                isSearchUserID,
            },
        });
    }
}
