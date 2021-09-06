/*eslint-disable*/
const TYPES = {
  // /**
  //  * 消息类型
  //  * @property {String} TEXT 文本
  //  * @property {String} IMAGE 图片
  //  * @property {String} SOUND 音频
  //  * @property {String} FILE 文件
  //  * @property {String} CUSTOM 自定义消息
  //  * @property {String} GROUP_TIP 群提示消息
  //  * @property {String} GROUP_SYSTEM_NOTICE 群系统消息
  //  * @memberOf module:TYPES
  //  */
  // MESSAGE_TYPES: MESSAGE.ELEMENT_TYPES,
  /**
   * @description 消息类型：文本消息
   * @memberof module:TYPES
   */
  MSG_TEXT: 'TIMTextElem',
  
  /**
   * @description 消息类型：图片消息
   * @memberof module:TYPES
   */
  MSG_IMAGE: 'TIMImageElem',
  
  /**
   * @description 消息类型：音频消息
   * @memberof module:TYPES
   */
  MSG_SOUND: 'TIMSoundElem',
  
  /**
   * @description 消息类型：文件消息
   * @memberof module:TYPES
   */
  MSG_FILE: 'TIMFileElem',
  
  /**
   * @private
   * @description 消息类型：表情消息
   * @memberof module:TYPES
   */
  MSG_FACE: 'TIMFaceElem',
  
  /**
   * @private
   * @description 消息类型：视频消息
   * @memberof module:TYPES
   */
  MSG_VIDEO: 'TIMVideoElem',
  
  /**
   * @private
   * @description 消息类型：位置消息
   * @memberof module:TYPES
   */
  MSG_GEO: 'TIMLocationElem',
  
  /**
   * @description 消息类型：群提示消息
   * @memberof module:TYPES
   */
  MSG_GRP_TIP: 'TIMGroupTipElem',
  
  /**
   * @description 消息类型：群系统通知消息
   * @memberof module:TYPES
   */
  MSG_GRP_SYS_NOTICE: 'TIMGroupSystemNoticeElem',
  
  /**
   * @description 消息类型：自定义消息
   * @memberof module:TYPES
   */
  MSG_CUSTOM: 'TIMCustomElem',
  
  // /**
  //  * 会话类型
  //  * @property {String} C2C C2C 会话类型
  //  * @property {String} GROUP 群组会话类型
  //  * @property {String} SYSTEM 系统会话类型
  //  * @memberOf module:TYPES
  //  */
  // // CONVERSATION_TYPES,
  /**
   * @description 会话类型：C2C(Client to Client, 端到端) 会话
   * @memberof module:TYPES
   */
  CONV_C2C: 'C2C',
  /**
   * @description 会话类型：GROUP(群组) 会话
   * @memberof module:TYPES
   */
  CONV_GROUP: 'GROUP',
  /**
   * @description 会话类型：SYSTEM(系统) 会话
   * @memberof module:TYPES
   */
  CONV_SYSTEM: '@TIM#SYSTEM',
  
  /**
   * 群组类型
   * @property {String} PRIVATE 私有群
   * @property {String} PUBLIC 公开群
   * @property {String} CHATROOM 聊天室
   * @property {String} AVCHATROOM 音视频聊天室
   * @memberOf module:TYPES
   */
  // GROUP_TYPES,
  /**
   * @description 群组类型：私有群
   * @memberof module:TYPES
   */
  GRP_PRIVATE: 'Private',
  
  /**
   * @description 群组类型：公开群
   * @memberof module:TYPES
   */
  GRP_PUBLIC: 'Public',
  
  /**
   * @description 群组类型：聊天室
   * @memberof module:TYPES
   */
  GRP_CHATROOM: 'ChatRoom',
  
  /**
   * @description 群组类型：音视频聊天室
   * @memberof module:TYPES
   */
  GRP_AVCHATROOM: 'AVChatRoom',
  
  /**
   * 群成员身份类型常量及含义
   * @property {String} OWNER 群主
   * @property {String} ADMIN 管理员
   * @property {String} MEMBER 普通群成员
   * @memberOf module:TYPES
   */
  // GROUP_MEMBER_ROLE_TYPES,
  
  /**
   * @description 群成员角色：群主
   * @memberof module:TYPES
   */
  GRP_MBR_ROLE_OWNER: 'Owner',
  
  /**
   * @description 群成员角色：管理员
   * @memberof module:TYPES
   */
  GRP_MBR_ROLE_ADMIN: 'Admin',
  
  /**
   * @description 群成员角色：普通群成员
   * @memberof module:TYPES
   */
  GRP_MBR_ROLE_MEMBER: 'Member',
  
  /**
   * 群提示消息类型常量含义
   * @property {Number} MEMBER_JOIN 有群成员加群
   * @property {Number} MEMBER_QUIT 有群成员退群
   * @property {Number} MEMBER_KICKED_OUT 有群成员被踢出群
   * @property {Number} MEMBER_SET_ADMIN 有群成员被设为管理员
   * @property {Number} MEMBER_CANCELED_ADMIN 有群成员被撤销管理员
   * @property {Number} GROUP_INFO_MODIFIED 群组资料变更
   * @property {Number} MEMBER_INFO_MODIFIED 群成员资料变更
   * @memberOf module:TYPES
   */
  // GROUP_TIP_TYPES,
  
  /**
   * @description 群提示：有成员加群
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_JOIN: 1,
  
  /**
   * @description 群提示：有群成员退群
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_QUIT: 2,
  
  /**
   * @description 群提示：有群成员被踢出群
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_KICKED_OUT: 3,
  
  /**
   * @description 群提示：有群成员被设为管理员
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_SET_ADMIN: 4, //被设置为管理员
  
  /**
   * @description 群提示：有群成员被撤销管理员
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_CANCELED_ADMIN: 5, //被取消管理员
  
  /**
   * @description 群提示：群组资料变更
   * @memberof module:TYPES
   */
  GRP_TIP_GRP_PROFILE_UPDATED: 6, //修改群资料，转让群组为该类型，msgBody.msgGroupNewInfo.ownerAccount表示新群主的ID
  
  /**
   * @description 群提示：群成员资料变更
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_PROFILE_UPDATED: 7, //修改群成员信息
  
  /**
   * 群系统通知类型常量及含义
   * @property {Number} JOIN_GROUP_REQUEST 有用户申请加群。群管理员/群主接收
   * @property {Number} JOIN_GROUP_ACCEPT 申请加群被同意。申请加群的用户接收
   * @property {Number} JOIN_GROUP_REFUSE 申请加群被拒绝。申请加群的用户接收
   * @property {Number} KICKED_OUT 被踢出群组。被踢出的用户接收
   * @property {Number} GROUP_DISMISSED 群组被解散。全体群成员接收
   * @property {Number} GROUP_CREATED 创建群组。创建者接收
   * @property {Number} QUIT 退群。退群者接收
   * @property {Number} SET_ADMIN 设置管理员。被设置方接收
   * @property {Number} CANCELED_ADMIN 取消管理员。被取消方接收
   * @property {Number} CUSTOM 自定义系统通知。全员接收
   * @memberOf module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_TYPES,
  /**
   * @private
   * @description 有用户申请加群。群管理员/群主接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_JOIN_GROUP_REQUEST: 1, //申请加群请求（只有管理员会收到）
  
  /**
   * @private
   * @description 申请加群被同意。申请加群的用户接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_JOIN_GROUP_ACCEPT: 2, //申请加群被同意（只有申请人能够收到）
  
  /**
   * @private
   * @description 申请加群被拒绝。申请加群的用户接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_JOIN_GROUP_REFUSE: 3, //申请加群被拒绝（只有申请人能够收到）
  
  /**
   * @private
   * @description 被踢出群组。被踢出的用户接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_KICKED_OUT: 4, //被管理员踢出群(只有被踢者接收到)
  
  /**
   * @private
   * @description 群组被解散。全体群成员接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_GROUP_DISMISSED: 5, //群被解散(全员接收)
  
  /**
   * @private
   * @description 创建群组。创建者接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_GROUP_CREATED: 6, //创建群(创建者接收, 不展示)
  
  /**
   * @private
   * @description 邀请加群(被邀请者接收)
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_INVITED_JOIN_GROUP_REQUEST: 7, //邀请加群(被邀请者接收)。
  
  /**
   * @private
   * @description 退群。退群者接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_QUIT: 8, //主动退群(主动退出者接收, 不展示)
  
  /**
   * @private
   * @description 设置管理员。被设置方接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_SET_ADMIN: 9, //设置管理员(被设置者接收)
  
  /**
   * @private
   * @description 取消管理员。被取消方接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_CANCELED_ADMIN: 10, //取消管理员(被取消者接收)
  
  /**
   * @private
   * @description 群已被回收(全员接收, 不展示)
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_REVOKE: 11, //群已被回收(全员接收, 不展示)
  
  /**
   * @private
   * @description 邀请加群(被邀请者需同意)
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_INVITED_JOIN_GROUP_REQUEST_AGREE: 12, //邀请加群(被邀请者需同意)
  
  /**
   * @private
   * @description 群消息已读同步
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_READED: 15, //群消息已读同步
  
  /**
   * @private
   * @description 用户自定义通知(默认全员接收)
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_CUSTOM: 255, //用户自定义通知(默认全员接收)
  
  /**
   * 群消息提示类型常量及含义
   * @property {String} ACCEPT_AND_NOTIFY 通知并提示
   * @property {String} ACCEPT_NOT_NOTIFY 通知但不提示
   * @property {String} DISCARD 拒收消息
   * @memberOf module:TYPES
   */
  // MESSAGE_REMIND_TYPES,
  /**
   * @description 群消息提示类型：SDK 接收消息并通知接入侧，接入侧做提示
   * @memberof module:TYPES
   */
  MSG_REMIND_ACPT_AND_NOTE: 'AcceptAndNotify',
  
  /**
   * @description 群消息提示类型：SDK 接收消息并通知接入侧，接入侧不做提示
   * @memberof module:TYPES
   */
  MSG_REMIND_ACPT_NOT_NOTE: 'AcceptNotNotify',
  
  /**
   * @description 群消息提示类型：SDK 拒收消息
   * @memberof module:TYPES
   */
  MSG_REMIND_DISCARD: 'Discard',
  
  /**
   * 性别类型常量及含义
   * @property {String} MALE 男
   * @property {String} FEMALE 女
   * @property {String} UNKNOWN 未设置性别
   * @memberOf module:TYPES
   */
  // GENDER_TYPES,
  /**
   * @description 性别：未设置性别
   * @memberOf module:TYPES
   */
  GENDER_UNKNOWN: 'Gender_Type_Unknown',
  
  /**
   * @description 性别：女性
   * @memberOf module:TYPES
   */
  GENDER_FEMALE: 'Gender_Type_Female',
  
  /**
   * @description 性别：男性
   * @memberOf module:TYPES
   */
  GENDER_MALE: 'Gender_Type_Male',
  
  /**
   * 被踢类型常量及含义
   * @property {String} MUTIPLE_ACCOUNT 多账号登录被踢
   * @memberOf module:TYPES
   */
  // KICKED_OUT_TYPES,
  
  /**
   * @description 被踢类型：多账号登录被踢
   * @memberOf module:TYPES
   */
  KICKED_OUT_MULT_ACCOUNT: 'mutipleAccount',
  
  /**
   * @private
   */
  KICKED_OUT_MULT_DEVICE: 'mutipleDevice',
  
  /**
   * @description 当被人加好友时：允许任何人添加自己为好友
   * @memberOf module:TYPES
   */
  ALLOW_TYPE_ALLOW_ANY: 'AllowType_Type_AllowAny',
  
  /**
   * @description 当被人加好友时：需要经过自己确认才能添加自己为好友
   * @memberOf module:TYPES
   */
  ALLOW_TYPE_NEED_CONFIRM: 'AllowType_Type_NeedConfirm',
  
  /**
   * @description 当被人加好友时：不允许任何人添加自己为好友
   * @memberOf module:TYPES
   */
  ALLOW_TYPE_DENY_ANY: 'AllowType_Type_DenyAny',
  
  /**
   * @description 管理员禁止加好友标识：默认值，允许加好友
   * @memberOf module:TYPES
   */
  FORBID_TYPE_NONE: 'AdminForbid_Type_None',
  
  /**
   * @description 管理员禁止加好友标识：禁止该用户发起加好友请求
   * @memberOf module:TYPES
   */
  FORBID_TYPE_SEND_OUT: 'AdminForbid_Type_SendOut',
  
  /**
   * @description 加群选项：自由加入
   * @memberOf module:TYPES
   */
  JOIN_OPTIONS_FREE_ACCESS: 'FreeAccess',
  
  /**
   * @description 加群选项：需要管理员同意
   * @memberOf module:TYPES
   */
  JOIN_OPTIONS_NEED_PERMISSION: 'NeedPermission',
  
  /**
   * @description 加群选项：不允许加群
   * @memberOf module:TYPES
   */
  JOIN_OPTIONS_DISABLE_APPLY: 'DisableApply',
  
  /**
   * @description 加群申请状态：加群成功
   * @memberOf module:TYPES
   */
  JOIN_STATUS_SUCCESS: 'JoinedSuccess',
  
  /**
   * @description 加群申请状态：等待管理员同意
   * @memberOf module:TYPES
   */
  JOIN_STATUS_WAIT_APPROVAL: 'WaitAdminApproval',
  
};

export default TYPES;
