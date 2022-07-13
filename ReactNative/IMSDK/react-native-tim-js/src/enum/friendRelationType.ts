/**
 * @module enum
 */

export enum FriendRelationType {
    /**
     * 不是好友
     */
    V2TIM_FRIEND_RELATION_TYPE_NONE = 0,

    /**
     * 对方在我的好友列表中
     */
    V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST,
    /**
     * 我在对方的好友列表中
     */
    V2TIM_FRIEND_RELATION_TYPE_IN_OTHER_FRIEND_LIST,
    /**
     * 互为好友
     */
    V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY,
}
