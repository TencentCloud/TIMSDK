/**
 * 腾讯云 IM SDK 支持四种预设的群组类型，每种类型都有其适用场景：<br>
 * > 工作群（Work）：类似普通微信群，创建后不能自由加入，必须由已经在群的用户邀请入群。<br>
 * > 公开群（Public）：类似 QQ 群，用户申请加入，但需要群主或管理员审批。  <br>
 * > 会议群（Meeting)：适合跟 TRTC 结合实现视频会议和在线教育等场景，支持随意进出，支持查看进群前的历史消息。  <br>
 * > 直播群（AVChatRoom）：适合直播弹幕聊天室等场景，支持随意进出，人数无上限  <br>
 * @module GroupManager(群组相关接口)
 */
import type { V2TimCallback } from '../interface/v2TimCallback';
import { GroupAddOptEnum } from '../enum/groupAddOpt';
import type { V2TimGroupInfo } from '../interface/v2TimGroupInfo';
import type { V2TimGroupInfoResult } from '../interface/v2TimGroupInfoResult';
import type { V2TimGroupMember } from '../interface/v2TimGroupMember';
import type { V2TimValueCallback } from '../interface/v2TimValueCallback';
import type { StringMap } from '../interface/commonInterface';
import type { GroupMemberFilterTypeEnum } from '../enum/groupMemberFilterType';
import type { V2TimGroupMemberInfoResult } from '../interface/v2TimGroupMemberInfoResult';
import type { V2TimGroupMemberFullInfo } from '../interface/v2TimGroupMemberFullInfo';
import type { V2TimGroupMemberOperationResult } from '../interface/v2TimGroupMemberOperationResult';
import type { GroupMemberRoleTypeEnum } from '../enum/groupMemberRoleType';
import type { V2TimGroupApplicationResult } from '../interface/v2TimGroupApplicationResult';
import { GroupApplicationTypeEnum } from '../enum/groupApplicationType';
import type { V2TimTopicInfo } from '../interface/v2TimTopicInfo';
import type { V2TimTopicInfoResult } from '../interface/v2TimTopicInfoResult';

export class V2TimGroupManager {
    private manager: string = 'groupManager';
    private nativeModule: any;

    /** @hidden */
    constructor(module: any) {
        this.nativeModule = module;
    }

    /**
     * ### 创建自定义群组
     */
    public createGroup({
        groupType,
        groupName,
        groupID,
        notification,
        introduction,
        faceUrl,
        isAllMuted,
        addOpt = GroupAddOptEnum.V2TIM_GROUP_ADD_AUTH,
        memberList,
        isSupportTopic = false,
    }: {
        groupType: string;
        groupName: string;
        groupID?: string;
        notification?: string;
        introduction?: string;
        faceUrl?: string;
        isAllMuted?: Boolean;
        isSupportTopic?: Boolean;
        addOpt: GroupAddOptEnum;
        memberList?: V2TimGroupMember[];
    }): Promise<V2TimValueCallback<string>> {
        return this.nativeModule.call(this.manager, 'createGroup', {
            groupType,
            groupName,
            groupID,
            notification,
            introduction,
            faceUrl,
            isAllMuted,
            addOpt,
            memberList,
            isSupportTopic,
        });
    }

    /**
     * ### 获取当前用户已经加入的群列表
     *
     * @note
     * 注意:
     * - 直播群（AVChatRoom）不支持该 API
     * - 该接口有频限检测，SDK 限制调用频率为 1 秒 10 次，超过限制后会报 ERR_SDK_COMM_API_CALL_FREQUENCY_LIMIT （7008）错误
     */
    public getJoinedGroupList(): Promise<V2TimValueCallback<V2TimGroupInfo[]>> {
        return this.nativeModule.call(this.manager, 'getJoinedGroupList', {});
    }

    /**
     * ### 拉取群资料
     * @param groupIDList - 群ID列表
     */
    public getGroupsInfo(
        groupIDList: string[]
    ): Promise<V2TimValueCallback<V2TimGroupInfoResult[]>> {
        return this.nativeModule.call(this.manager, 'getGroupsInfo', {
            groupIDList,
        });
    }

    /**
     * ### 设置群信息
     * @param info - 需要设置的群信息
     */
    public setGroupInfo(info: V2TimGroupInfo): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'setGroupInfo', {
            ...info,
        });
    }

    /**
     * ### 初始化群属性
     * @param groupID - 群ID
     * @param attributes - 属性
     *
     *
     * @note
     * 注意:
     *  - 目前只支持：直播群（ AVChatRoom）。
     */
    public initGroupAttributes(
        groupID: string,
        attributes: StringMap
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'initGroupAttributes', {
            groupID,
            attributes,
        });
    }

    /**
     * ### 设置群属性
     * @param groupID - 群ID
     * @param attributes - 属性
     *
     * @note
     * 注意:
     *  - 目前只支持：直播群（ AVChatRoom）。
     */
    public setGroupAttributes(
        groupID: string,
        attributes: StringMap
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'setGroupAttributes', {
            groupID,
            attributes,
        });
    }

    /**
     * ### 删除群指定属性
     * @param groupID - 群ID
     * @param keys - 群属性key
     *
     * @note
     * 注意:
     *  - 目前只支持：直播群（ AVChatRoom）。
     */
    public deleteGroupAttributes(
        groupID: string,
        keys: string[]
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'deleteGroupAttributes', {
            groupID,
            keys,
        });
    }

    /**
     * ### 获取群指定属性
     * @param groupID - 群ID
     * @param keys - 群属性key
     * @note
     * 注意:
     *  - 目前只支持：直播群（ AVChatRoom）。
     */
    public getGroupAttributes(
        groupID: string,
        keys?: string[]
    ): Promise<V2TimValueCallback<StringMap>> {
        return this.nativeModule.call(this.manager, 'getGroupAttributes', {
            groupID,
            keys,
        });
    }

    /**
     * ### 获取群在线人数
     * @param groupID - 群ID
     *
     * @note
     * 注意:
     *  - 目前只支持：直播群（ AVChatRoom）。
     */
    public getGroupOnlineMemberCount(
        groupID: string
    ): Promise<V2TimValueCallback<number>> {
        return this.nativeModule.call(
            this.manager,
            'getGroupOnlineMemberCount',
            {
                groupID,
            }
        );
    }

    /**
     * ### 获取群成员列表
     * @param groupID - 群ID
     * @param filter - 指定群成员类型
     * @param nextSeq - 分页拉取标志，第一次拉取填 0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为 0。
     * @param count - 拉群量
     * @param offset - 偏移量
     *
     * @note
     * 直播群（AVChatRoom）的特殊限制：
     * - 旗舰版支持拉取最近入群群成员最多 1000 人，新进来的成员排在前面。需要您购买旗舰版套餐且前往 控制台 开启开关。如果不开启开关，您只能像非旗舰版一样最多拉到 31 人（6.3 及以上版本支持）。
     * - 非旗舰版支持拉取最近入群群成员最多 31 人，新进来的成员排在前面。
     * - 程序重启后，请重新加入群组，否则拉取群成员会报 10007 错误码。
     * - 群成员资料信息仅支持 userID | nickName | faceURL | role 字段。
     * - filter 字段不支持管理员角色，即不支持管理员角色的拉取。如果您的业务逻辑依赖于管理员角色，可以使用群自定义字段 groupAttributes 管理该角色。
     */
    public getGroupMemberList(
        groupID: string,
        filter: GroupMemberFilterTypeEnum,
        nextSeq: string,
        count = 15,
        offset = 0
    ): Promise<V2TimValueCallback<V2TimGroupMemberInfoResult>> {
        return this.nativeModule.call(this.manager, 'getGroupMemberList', {
            groupID,
            filter,
            nextSeq,
            offset,
            count,
        });
    }

    /**
     * ### 指定的群成员资料
     * @param groupID - 群ID
     * @param memberList - 成员ID数组
     */
    public getGroupMembersInfo(
        groupID: string,
        memberList?: string[]
    ): Promise<V2TimValueCallback<V2TimGroupMemberFullInfo[]>> {
        return this.nativeModule.call(this.manager, 'getGroupMembersInfo', {
            groupID,
            memberList,
        });
    }

    /**
     * ### 修改指定的群成员资料
     * @param groupID - 群ID
     * @param userID - 用户ID
     * @param nameCard - 群名片
     * @param customInfo - 自定义信息
     */
    public setGroupMemberInfo(
        groupID: string,
        userID: string,
        nameCard?: string,
        customInfo?: StringMap
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'setGroupMemberInfo', {
            groupID,
            userID,
            nameCard,
            customInfo,
        });
    }

    /**
     * ### 禁言（只有管理员或群主能够调用）
     * @param groupID - 群ID
     * @param userID - 用户ID
     * @param seconds - 禁言时间
     */
    public muteGroupMember(
        groupID: string,
        userID: string,
        seconds: number
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'muteGroupMember', {
            groupID,
            userID,
            seconds,
        });
    }

    /**
     * 邀请用户进群
     * @param groupID - 群ID
     * @param userList - 用户ID数组
     */
    public inviteUserToGroup(
        groupID: string,
        userList: string[]
    ): Promise<V2TimValueCallback<V2TimGroupMemberOperationResult[]>> {
        return this.nativeModule.call(this.manager, 'inviteUserToGroup', {
            groupID,
            userList,
        });
    }

    /**
     * ### 踢用户出群
     * @param groupID - 群ID
     * @param memberList - 用户ID 数组
     */
    public kickGroupMember(
        groupID: string,
        memberList: string[]
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'kickGroupMember', {
            groupID,
            memberList,
        });
    }

    /**
     * ### 切换群成员的角色
     * @note
     * 请注意不同类型的群有如下限制：
     * - 公开群（Public）和会议群（Meeting）：只有群主才能对群成员进行普通成员和管理员之间的角色切换。
     * - 其他群不支持设置群成员角色。
     * - 转让群组请调用 transferGroupOwner 接口。
     * - 会议群（Meeting）切换群成员角色之后，不会有 onGrantAdministrator 和 onRevokeAdministrator 通知回调
     * - 切换的角色支持普通群成员（ V2TIM_GROUP_MEMBER_ROLE_MEMBER） 和管理员（V2TIM_GROUP_MEMBER_ROLE_ADMIN
     */
    public setGroupMemberRole(
        groupID: string,
        userID: string,
        role: GroupMemberRoleTypeEnum
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'setGroupMemberRole', {
            groupID,
            userID,
            role,
        });
    }

    /**
     * ### 转让群主
     *
     * @note
     * 请注意不同类型的群有如下限制：
     * - 普通类型的群（Work、Public、Meeting）：只有群主才有权限进行群转让操作。
     * - 直播群（AVChatRoom）：不支持转让群主。
     */
    public transferGroupOwner(
        groupID: string,
        userID: string
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'transferGroupOwner', {
            groupID,
            userID,
        });
    }

    /**
     * ### 获取加群申请列表
     */
    public getGroupApplicationList(): Promise<
        V2TimValueCallback<V2TimGroupApplicationResult>
    > {
        return this.nativeModule.call(
            this.manager,
            'getGroupApplicationList',
            {}
        );
    }

    /**
     * ### 同意某一条加群申请
     */
    public acceptGroupApplication(
        groupID: string,
        fromUser: string,
        toUser: string,
        reason?: string,
        addTime?: number,
        type = GroupApplicationTypeEnum.V2TIM_GROUP_APPLICATION_GET_TYPE_INVITE
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'acceptGroupApplication', {
            groupID,
            reason,
            fromUser,
            toUser,
            addTime,
            type,
        });
    }

    /**
     * ### 拒绝某一条加群申请
     */
    public refuseGroupApplication(
        groupID: string,
        fromUser: string,
        toUser: string,
        type?: GroupApplicationTypeEnum,
        addTime?: number,
        reason?: string
    ): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'refuseGroupApplication', {
            groupID,
            reason,
            fromUser,
            toUser,
            addTime,
            type,
        });
    }

    /**
     * ### 标记申请列表为已读
     */
    public setGroupApplicationRead(): Promise<V2TimCallback> {
        return this.nativeModule.call(
            this.manager,
            'setGroupApplicationRead',
            {}
        );
    }

    /**
     * ### 搜索群列表
     * SDK 会搜索群名称包含于关键字列表 keywordList 的所有群并返回群信息列表。关键字列表最多支持5个。
     * @note
     * 需要您购买旗舰版套餐
     */
    public searchGroups({
        keywordList,
        isSearchGroupID = true,
        isSearchGroupName = true,
    }: {
        keywordList: string[];
        isSearchGroupID?: boolean;
        isSearchGroupName?: boolean;
    }): Promise<V2TimValueCallback<V2TimGroupInfo[]>> {
        return this.nativeModule.call(this.manager, 'searchGroups', {
            searchParam: {
                keywordList,
                isSearchGroupID,
                isSearchGroupName,
            },
        });
    }

    /**
     * ### 搜索指定的群成员资料
     * SDK 会在本地搜索指定群 ID 列表中，群成员信息（名片、好友备注、昵称、userID）包含于关键字列表 keywordList 的所有群成员并返回群 ID 和群成员列表的 map，关键字列表最多支持5个。
     * @note
     * 需要您购买旗舰版套餐
     */
    public searchGroupMembers({
        keywordList,
        groupIDList,
        isSearchMemberUserID = true,
        isSearchMemberNickName = true,
        isSearchMemberNameCard = true,
        isSearchMemberRemark = true,
    }: {
        keywordList: string[];
        groupIDList?: string[];
        isSearchMemberUserID?: boolean;
        isSearchMemberNickName?: boolean;
        isSearchMemberRemark?: boolean;
        isSearchMemberNameCard?: boolean;
    }): Promise<
        V2TimValueCallback<{
            groupMemberSearchResultItems: StringMap;
        }>
    > {
        return this.nativeModule.call(this.manager, 'searchGroupMembers', {
            param: {
                keywordList,
                groupIDList,
                isSearchMemberNameCard,
                isSearchMemberNickName,
                isSearchMemberRemark,
                isSearchMemberUserID,
            },
        });
    }

    /**
     * ### 获取当前用户已经加入的支持话题的社群列表
     */
    public getJoinedCommunityList(): Promise<
        V2TimValueCallback<V2TimGroupInfo[]>
    > {
        return this.nativeModule.call(
            this.manager,
            'getJoinedCommunityList',
            {}
        );
    }

    /**
     * ### 创建话题
     */
    public createTopicInCommunity(
        groupID: string,
        topicInfo: V2TimTopicInfo
    ): Promise<V2TimValueCallback<string>> {
        return this.nativeModule.call(this.manager, 'createTopicInCommunity', {
            groupID,
            topicInfo,
        });
    }

    /**
     * ### 删除话题
     */
    public deleteTopicFromCommunity(groupID: string, topicIDList: string[]) {
        return this.nativeModule.call(
            this.manager,
            'deleteTopicFromCommunity',
            {
                groupID,
                topicIDList,
            }
        );
    }

    /**
     * ### 修改话题信息
     */
    public setTopicInfo(topicInfo: V2TimTopicInfo): Promise<V2TimCallback> {
        return this.nativeModule.call(this.manager, 'setTopicInfo', {
            topicInfo,
        });
    }

    /**
     * ### 获取话题列表
     *
     * @note
     * topicIDList 传空时，获取此社群下的所有话题列表
     */
    public getTopicInfoList(
        groupID: string,
        topicIDList: string[]
    ): Promise<V2TimValueCallback<V2TimTopicInfoResult>> {
        return this.nativeModule.call(this.manager, 'getTopicInfoList', {
            groupID,
            topicIDList,
        });
    }
}
