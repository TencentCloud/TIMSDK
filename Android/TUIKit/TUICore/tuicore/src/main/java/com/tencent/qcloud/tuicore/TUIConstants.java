package com.tencent.qcloud.tuicore;

import com.tencent.imsdk.BaseConstants;

/**
 * TUI constants
 */
public final class TUIConstants {

    public static final class GroupType {
        public static final String TYPE = "type";
        public static final String IS_GROUP = "isGroup";

        public static final String TYPE_PRIVATE = "Private";
        public static final String TYPE_WORK = "Work";
        public static final String TYPE_PUBLIC = "Public";

        public static final String TYPE_CHAT_ROOM = "ChatRoom";
        public static final String TYPE_MEETING = "Meeting";
        public static final String TYPE_COMMUNITY = "Community";
    }

    public static final class Service {
        public static final String TUI_CHAT = "TUIChatService";
        public static final String TUI_CONVERSATION = "TUIConversationService";
        public static final String TUI_CONTACT = "TUIContactService";
        public static final String TUI_SEARCH = "TUISearchService";
        public static final String TUI_GROUP = "TUIGroupService";
        public static final String TUI_CALLING = "TUICallingService";
        public static final String TUI_AUDIO_RECORD = "TUIAudioMessageRecordService";
        public static final String TUI_LIVE = "TUILiveService";
        public static final String TUI_BEAUTY = "TUIBeauty";
        public static final String TUI_OFFLINEPUSH = "TUIOfflinePushService";
        public static final String TUI_COMMUNITY = "TUICommunityService";
    }

    public static final class TUILogin {

        // User login status change broadcast
        public static final String EVENT_LOGIN_STATE_CHANGED = "eventLoginStateChanged";
        // User kicked offline
        public static final String EVENT_SUB_KEY_USER_KICKED_OFFLINE = "eventSubKeyUserKickedOffline";
        // User ticket expired
        public static final String EVENT_SUB_KEY_USER_SIG_EXPIRED = "eventSubKeyUserSigExpired";
        // Changes in user personal information
        public static final String EVENT_SUB_KEY_USER_INFO_UPDATED = "eventSubKeyUserInfoUpdated";

        // Imsdk initialize state change
        public static final String EVENT_IMSDK_INIT_STATE_CHANGED = "eventIMSDKInitStateChanged";
        // Init
        public static final String EVENT_SUB_KEY_START_INIT = "eventSubKeyStartInit";
        // Uint
        public static final String EVENT_SUB_KEY_START_UNINIT = "eventSubKeyStartUnInit";
        // Login success
        public static final String EVENT_SUB_KEY_USER_LOGIN_SUCCESS = "eventSubKeyUserLoginSuccess";
        // Logout success
        public static final String EVENT_SUB_KEY_USER_LOGOUT_SUCCESS = "eventSubKeyUserLogoutSuccess";

        public static final String SELF_ID = "selfId";
        public static final String SELF_SIGNATURE = "selfSignature";
        public static final String SELF_FACE_URL = "selfFaceUrl";
        public static final String SELF_NICK_NAME = "selfNickName";
        public static final String SELF_LEVEL = "selfLevel";
        public static final String SELF_GENDER = "selfGender";
        public static final String SELF_ROLE = "selfRole";
        public static final String SELF_BIRTHDAY = "selfBirthday";
        public static final String SELF_ALLOW_TYPE = "selfAllowType";
    }

    public static final class TUIChat {
        public static final String SERVICE_NAME = Service.TUI_CHAT;

        // Send message
        public static final String METHOD_SEND_MESSAGE = "sendMessage";
        // Exit chat
        public static final String METHOD_EXIT_CHAT = "exitChat";
        // Get a message digest to display in the conversation list
        public static final String METHOD_GET_DISPLAY_STRING = "getDisplayString";
        // add message to chat list
        public static final String METHOD_ADD_MESSAGE_TO_CHAT = "addMessageToChat";
        // 处理完群申请 // Process the group application
        public static final String METHOD_GROUP_APPLICAITON_PROCESSED = "groupApplicationProcessed";

        // More actions
        public static final String EXTENSION_INPUT_MORE_CUSTOM_MESSAGE = "inputMoreCustomMessage";
        public static final String EXTENSION_INPUT_MORE_LIVE = "inputMoreLive";
        public static final String EXTENSION_INPUT_MORE_VIDEO_CALL = "inputMoreVideoCall";
        public static final String EXTENSION_INPUT_MORE_AUDIO_CALL = "inputMoreAudioCall";

        public static final String EVENT_KEY_RECEIVE_MESSAGE = "eventReceiveMessage";
        public static final String EVENT_SUB_KEY_CONVERSATION_ID = "eventConversationID";

        public static final String EVENT_KEY_INPUT_MORE = "eventKeyInputMore";
        public static final String EVENT_SUB_KEY_ON_CLICK = "eventSubKeyOnClick";

        public static final String EVENT_KEY_MESSAGE_EVENT = "eventKeyMessageEvent";
        public static final String EVENT_SUB_KEY_SEND_MESSAGE_SUCCESS = "eventSubKeySendMessageSuccess";
        public static final String EVENT_SUB_KEY_REPLY_MESSAGE_SUCCESS = "eventSubKeyReplyMessageSuccess";

        public static final String C2C_CHAT_ACTIVITY_NAME = "TUIC2CChatActivity";
        public static final String GROUP_CHAT_ACTIVITY_NAME = "TUIGroupChatActivity";
        public static final String CHAT_ID = "chatId";
        public static final String CHAT_NAME = "chatName";
        public static final String CHAT_TYPE = "chatType";
        public static final String GROUP_NAME = "groupName";
        public static final String GROUP_TYPE = "groupType";
        public static final String DRAFT_TEXT = "draftText";
        public static final String DRAFT_TIME = "draftTime";
        public static final String IS_TOP_CHAT = "isTopChat";
        public static final String LOCATE_MESSAGE = "locateMessage";
        public static final String AT_INFO_LIST = "atInfoList";
        public static final String FACE_URL = "faceUrl";
        public static final String FACE_URL_LIST = "faceUrlList";
        public static final String JOIN_TYPE = "joinType";
        public static final String MEMBER_COUNT = "memberCount";
        public static final String RECEIVE_OPTION = "receiveOption";
        public static final String NOTICE = "notice";
        public static final String OWNER = "owner";
        public static final String MEMBER_DETAILS = "memberDetails";
        public static final String IS_GROUP_CHAT = "isGroupChat";
        public static final String V2TIMMESSAGE = "v2TIMMessage";
        public static final String MESSAGE_BEAN = "messageBean";
        public static final String GROUP_APPLY_NUM = "groupApplicaitonNumber";
        public static final String CONVERSATION_ID = "conversationID";
        public static final String IS_TYPING_MESSAGE = "isTypingMessage";

        // Send custom message fields
        public static final String MESSAGE_CONTENT = "messageContent";
        public static final String MESSAGE_DESCRIPTION = "messageDescription";
        public static final String MESSAGE_EXTENSION = "messageExtension";

        // More input button extension field
        public static final String CONTEXT = "context";
        public static final String INPUT_MORE_ICON = "icon";
        public static final String INPUT_MORE_TITLE = "title";
        public static final String INPUT_MORE_ACTION_ID = "actionId";
        public static final String INPUT_MORE_VIEW = "inputMoreView";

        // Background
        public static final String CHAT_CONVERSATION_BACKGROUND_URL = "https://sdk-im-1252463788.file.myqcloud.com/download/tuikit-resource/conversation-backgroundImage/backgroundImage_%s_full.png";
        public static final String CHAT_CONVERSATION_BACKGROUND_THUMBNAIL_URL = "https://sdk-im-1252463788.file.myqcloud.com/download/tuikit-resource/conversation-backgroundImage/backgroundImage_%s.png";
        public static final int CHAT_CONVERSATION_BACKGROUND_COUNT = 7;
        public static final String CHAT_CONVERSATION_BACKGROUND_DEFAULT_URL = "chat/conversation/background/default/url";
        public static final int CHAT_REQUEST_BACKGROUND_CODE = 1001;
        public static final String METHOD_UPDATE_DATA_STORE_CHAT_URI = "updateDatastoreChatUri";
        public static final String CHAT_BACKGROUND_URI = "chatBackgroundUri";
    }

    public static final class TUIConversation {
        public static final String SERVICE_NAME = Service.TUI_CONVERSATION;


        public static final String METHOD_IS_TOP_CONVERSATION = "isTopConversation";
        public static final String METHOD_SET_TOP_CONVERSATION = "setTopConversation";
        public static final String METHOD_GET_TOTAL_UNREAD_COUNT = "getTotalUnreadCount";
        public static final String METHOD_UPDATE_TOTAL_UNREAD_COUNT = "updateTotalUnreadCount";
        public static final String METHOD_DELETE_CONVERSATION = "deleteConversation";
        public static final String METHOD_CLEAR_CONVERSATION_MESSAGE = "clearConversationMessage";

        public static final String EVENT_UNREAD = "eventTotalUnreadCount";
        public static final String EVENT_SUB_KEY_UNREAD_CHANGED = "unreadCountChanged";

        public static final String EXTENSION_CLASSIC_SEARCH = "extensionClassicSearch";
        public static final String EXTENSION_MINIMALIST_SEARCH = "extensionMinimalistSearch";

        public static final String CHAT_ID = "chatId";
        public static final String CONVERSATION_ID = "conversationId";
        public static final String IS_SET_TOP = "isSetTop";
        public static final String IS_TOP = "isTop";
        public static final String IS_GROUP = "isGroup";
        public static final String TOTAL_UNREAD_COUNT = "totalUnreadCount";
        public static final String CONTEXT = "context";
        public static final String SEARCH_VIEW = "searchView";

        public static final String CONVERSATION_C2C_PREFIX = "c2c_";
        public static final String CONVERSATION_GROUP_PREFIX = "group_";

        public static final String EVENT_KEY_MESSAGE_SEND_FOR_CONVERSATION = "eventKeyMessageSendForConversation";
        public static final String EVENT_SUB_KEY_MESSAGE_SEND_FOR_CONVERSATION = "eventSubKeyMessageSendForConversation";
    }

    public static final class TUIContact {
        public static final String SERVICE_NAME = Service.TUI_CONTACT;

        public static final String EVENT_FRIEND_STATE_CHANGED = "eventFriendStateChanged";
        public static final String EVENT_FRIEND_INFO_CHANGED = "eventFriendInfoChanged";
        public static final String EVENT_USER = "eventUser";
        public static final String EVENT_SUB_KEY_FRIEND_REMARK_CHANGED = "eventFriendRemarkChanged";
        public static final String EVENT_SUB_KEY_FRIEND_DELETE = "eventSubKeyFriendDelete";
        public static final String EVENT_SUB_KEY_CLEAR_MESSAGE = "eventSubKeyC2CClearMessage";

        public static final String FRIEND_ID_LIST = "friendIdList";
        public static final String FRIEND_ID = "friendId";
        public static final String FRIEND_REMARK = "friendRemark";

        public static final String GROUP_TYPE_KEY = "type";
        public static final String COMMUNITY_SUPPORT_TOPIC_KEY = "communitySupportTopic";

        public static final int GROUP_TYPE_PRIVATE = 0;
        public static final int GROUP_TYPE_PUBLIC = 1;
        public static final int GROUP_TYPE_CHAT_ROOM = 2;
        public static final int GROUP_TYPE_COMMUNITY = 3;

        public static final String GROUP_FACE_URL = "https://im.sdk.cloud.tencent.cn/download/tuikit-resource/group-avatar/group_avatar_%s.png";
        public static final int GROUP_FACE_COUNT = 24;
    }

    public static final class TUICalling {
        public static final String SERVICE_NAME = Service.TUI_CALLING;

        public static final String METHOD_NAME_CALL = "call";
        public static final String METHOD_NAME_RECEIVEAPNSCALLED = "receiveAPNSCalled";
        public static final String METHOD_NAME_ENABLE_FLOAT_WINDOW = "methodEnableFloatWindow";
        public static final String METHOD_NAME_ENABLE_MULTI_DEVICE = "methodEnableMultiDeviceAbility";

        public static final String PARAM_NAME_TYPE = "type";
        public static final String PARAM_NAME_USERIDS = "userIDs";
        public static final String PARAM_NAME_GROUPID = "groupId";
        public static final String PARAM_NAME_CALLMODEL = "call_model_data";
        public static final String PARAM_NAME_ENABLE_FLOAT_WINDOW = "enableFloatWindow";
        public static final String PARAM_NAME_ENABLE_MULTI_DEVICE = "enableMultiDeviceAbility";

        public static final String METHOD_START_CALL = "startCall";

        public static final String CUSTOM_MESSAGE_BUSINESS_ID = "av_call";
        public static final Double CALL_TIMEOUT_BUSINESS_ID = 1.0;

        public static final String CALL_ID = "callId";
        public static final String SENDER = "sender";
        public static final String GROUP_ID = "groupId";
        public static final String INVITED_LIST = "invitedList";
        public static final String DATA = "data";

        public static final String TYPE_AUDIO = "audio";
        public static final String TYPE_VIDEO = "video";

        public static final int ACTION_ID_AUDIO_CALL = 1;
        public static final int ACTION_ID_VIDEO_CALL = 2;

        public static final String EVENT_KEY_CALLING = "calling";
        public static final String EVENT_KEY_NAME = "event_name";
        public static final String EVENT_ACTIVE_HANGUP = "active_hangup";

        public static final String SERVICE_NAME_AUDIO_RECORD              = Service.TUI_AUDIO_RECORD;
        public static final String METHOD_NAME_START_RECORD_AUDIO_MESSAGE = "methodStartRecordAudioMessage";
        public static final String METHOD_NAME_STOP_RECORD_AUDIO_MESSAGE  = "methodStopRecordAudioMessage";

        public static final String EVENT_KEY_RECORD_AUDIO_MESSAGE = "eventRecordAudioMessage";
        public static final String EVENT_SUB_KEY_RECORD_START     = "eventSubKeyStartRecordAudioMessage";
        public static final String EVENT_SUB_KEY_RECORD_STOP      = "eventSubKeyStopRecordAudioMessage";

        public static final String PARAM_NAME_SDK_APP_ID      = "sdkappid";
        public static final String PARAM_NAME_AUDIO_SIGNATURE = "signature";
        public static final String PARAM_NAME_AUDIO_PATH      = "path";

        //Error Code
        public static final int ERROR_NONE                       = 0;     // init success or record success
        public static final int ERROR_INVALID_PARAM              = -1001; // param is invalid
        public static final int ERROR_STATUS_IN_CALL             = -1002; // recording rejected, currently in call
        public static final int ERROR_STATUS_IS_AUDIO_RECORDING  = -1003; // recording rejected, the current recording is not finished
        public static final int ERROR_MIC_PERMISSION_REFUSED     = -1004; // recording rejected, failed to obtain microphone permission
        public static final int ERROR_REQUEST_AUDIO_FOCUS_FAILED = -1005; // recording rejected, failed to obtain audio focus
        public static final int ERROR_RECORD_INIT_FAILED         = -2001; // -1, init failed(onLocalRecordBegin)
        public static final int ERROR_PATH_FORMAT_NOT_SUPPORT    = -2002; // -2, file format is invalid(onLocalRecordBegin)
        public static final int ERROR_RECORD_FAILED              = -2003; // -1, record failed(onLocalRecordComplete)
        public static final int ERROR_NO_MESSAGE_TO_RECORD       = -2004; // -3, The audio data has not arrived(onLocalRecordComplete)
        public static final int ERROR_SIGNATURE_ERROR            = -3001; // -4, signature error(onLocalRecordBegin)
        public static final int ERROR_SIGNATURE_EXPIRED          = -3002; // -5, signature expired(onLocalRecordBegin)
        //TRTC-SDK MIC Error Code
        public static final int ERR_MIC_START_FAIL               = -1302; // start microphone failed
        public static final int ERR_MIC_NOT_AUTHORIZED           = -1317; // microphone authorize failed
        public static final int ERR_MIC_SET_PARAM_FAIL           = -1318; // microphone param is invalid
        public static final int ERR_MIC_OCCUPY                   = -1319; // microphone is occupied
    }

    public static final class TUILive {
        public static final String SERVICE_NAME = Service.TUI_LIVE;


        public static final String METHOD_LOGIN = "methodLogin";
        public static final String METHOD_LOGOUT = "methodLogout";
        public static final String METHOD_START_ANCHOR = "methodStartAnchor";
        public static final String METHOD_START_AUDIENCE = "methodStartAudience";

        public static final String CUSTOM_MESSAGE_BUSINESS_ID = "group_live";
        public static final String SDK_APP_ID = "sdkAppId";
        public static final String USER_ID = "userId";
        public static final String USER_SIG = "userSig";

        public static final String GROUP_ID = "groupId";
        public static final String ROOM_ID = "roomId";
        public static final String ROOM_NAME    = "roomName";
        public static final String ROOM_STATUS = "roomStatus";
        public static final String ROOM_COVER     = "roomCover";
        public static final String USE_CDN_PLAY  = "use_cdn_play";
        public static final String ANCHOR_ID     = "anchorId";
        public static final String ANCHOR_NAME     = "anchorName";
        public static final String PUSHER_NAME   = "pusherName";
        public static final String COVER_PIC     = "coverPic";
        public static final String PUSHER_AVATAR = "pusherAvatar";

        public static final int ACTION_ID_LIVE = 0;

    }

    public static final class TUIGroup {
        public static final String SERVICE_NAME = Service.TUI_GROUP;


        public static final String EVENT_GROUP = "eventGroup";
        public static final String EVENT_SUB_KEY_EXIT_GROUP = "eventExitGroup";
        public static final String EVENT_SUB_KEY_MEMBER_KICKED_GROUP = "eventMemberKickedGroup";
        public static final String EVENT_SUB_KEY_GROUP_RECYCLE = "eventMemberGroupRecycle";
        public static final String EVENT_SUB_KEY_GROUP_DISMISS = "eventMemberGroupDismiss";
        public static final String EVENT_SUB_KEY_JOIN_GROUP = "eventSubKeyJoinGroup";
        public static final String EVENT_SUB_KEY_INVITED_GROUP = "eventSubKeyInvitedGroup";
        public static final String EVENT_SUB_KEY_GROUP_INFO_CHANGED = "eventSubKeyGroupInfoChanged";
        public static final String EVENT_SUB_KEY_CLEAR_MESSAGE = "eventSubKeyGroupClearMessage";
        public static final String EVENT_SUB_KEY_GROUP_MEMBER_SELECTED = "eventSubKeyGroupMemberSelected";

        public static final String GROUP_ID = "groupId";
        public static final String GROUP_NAME = "groupName";
        public static final String GROUP_FACE_URL = "groupFaceUrl";
        public static final String GROUP_OWNER = "groupOwner";
        public static final String GROUP_INTRODUCTION = "groupIntroduction";
        public static final String GROUP_NOTIFICATION= "groupNotification";
        public static final String GROUP_MEMBER_ID_LIST= "groupMemberIdList";

        public static final String SELECT_FRIENDS = "select_friends";
        public static final String SELECT_FOR_CALL = "isSelectForCall";
        public static final String USER_DATA = "userData";
        public static final String IS_SELECT_MODE = "isSelectMode";
        public static final String EXCLUDE_LIST = "excludeList";
        public static final String SELECTED_LIST = "selectedList";
        public static final String CONTENT = "content";
        public static final String TYPE = "type";
        public static final String TITLE = "title";
        public static final String LIST = "list";
        public static final String LIMIT = "limit";
        public static final String FILTER = "filter";
        public static final String JOIN_TYPE_INDEX = "joinTypeIndex";

    }


    public static final class TUIBeauty {
        public static final String SERVICE_NAME = Service.TUI_BEAUTY;

        public static final String PARAM_NAME_CONTEXT        = "context";
        public static final String PARAM_NAME_LICENSE_KEY    = "licenseKey";
        public static final String PARAM_NAME_LICENSE_URL    = "licenseUrl";
        public static final String PARAM_NAME_FRAME_WIDTH    = "frameWidth";
        public static final String PARAM_NAME_FRAME_HEIGHT   = "frameHeight";
        public static final String PARAM_NAME_SRC_TEXTURE_ID = "srcTextureId";

        public static final String METHOD_PROCESS_VIDEO_FRAME = "processVideoFrame";
        public static final String METHOD_INIT_XMAGIC         = "setLicense";
        public static final String METHOD_DESTROY_XMAGIC      = "destroy";
    }
    
    public static final class TUIOfflinePush {
        public static final String SERVICE_NAME = Service.TUI_OFFLINEPUSH;
        public static final String METHOD_UNREGISTER_PUSH = "unRegiterPush";

        public static final String EVENT_NOTIFY = "offlinePushNotifyEvent";
        public static final String EVENT_NOTIFY_NOTIFICATION = "notifyNotificationEvent";
        public static final String NOTIFICATION_INTENT_KEY = "notificationIntentKey";
        public static final String NOTIFICATION_EXT_KEY = "ext";

        public static final String NOTIFICATION_BROADCAST_ACTION = "com.tencent.tuiofflinepush.BROADCAST_PUSH_RECEIVER";
    }

    public static final class TUICommunity {
        public static final String SERVICE_NAME = Service.TUI_COMMUNITY;

        public static final String TOPIC_ID = "topic_id";

        public static final String EVENT_KEY_COMMUNITY_EXPERIENCE= "eventKeyCommunityExperience";
        public static final String EVENT_SUB_KEY_ADD_COMMUNITY = "eventSubKeyAddCommunity";
        public static final String EVENT_SUB_KEY_CREATE_COMMUNITY = "eventSubKeyCreateCommunity";
        public static final String EVENT_SUB_KEY_DISBAND_COMMUNITY = "eventSubKeyDisbandCommunity";
        public static final String EVENT_SUB_KEY_CREATE_TOPIC = "eventSubKeyCreateTopic";
        public static final String EVENT_SUB_KEY_DELETE_TOPIC = "eventSubKeyDeleteTopic";
    }

    public static final class Message {
        public static final String CUSTOM_BUSINESS_ID_KEY = "businessID";
        public static final String CALLING_TYPE_KEY = "call_type";
    }

    public static final class NetworkConnection {
        public static final String EVENT_CONNECTION_STATE_CHANGED = "eventConnectionStateChanged";
        public static final String EVENT_SUB_KEY_CONNECTING       = "eventSubKeyConnecting";
        public static final String EVENT_SUB_KEY_CONNECT_SUCCESS  = "eventSubKeyConnectSuccess";
        public static final String EVENT_SUB_KEY_CONNECT_FAILED   = "eventSubKeyConnectFailed";
    }


    public static final class BuyingFeature {
        public static final int ERR_SDK_INTERFACE_NOT_SUPPORT = BaseConstants.ERR_SDK_INTERFACE_NOT_SUPPORT;
        public static final String BUYING_GUIDELINES_EN = "https://intl.cloud.tencent.com/document/product/1047/36021?lang=en&pg=#changing-configuration";
        public static final String BUYING_GUIDELINES = "https://cloud.tencent.com/document/product/269/32458";

        public static final String BUYING_PRICE_DESC_EN = "https://www.tencentcloud.com/document/product/1047/34349#basic-services";
        public static final String BUYING_PRICE_DESC = "https://cloud.tencent.com/document/product/269/11673?from=17219#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85";


        public static final String BUYING_FEATURE_MESSAGE_RECEIPT = "buying_chat_message_read_receipt";
        public static final String BUYING_FEATURE_COMMUNITY = "buying_community";
        public static final String BUYING_FEATURE_SEARCH = "buying_search";
        public static final String BUYING_FEATURE_ONLINE_STATUS = "buying_online_status";
    }

    // localBroadcast
    public static final String CONVERSATION_UNREAD_COUNT_ACTION = "conversation_unread_count_action";
    public static final String UNREAD_COUNT_EXTRA = "unread_count_extra";
}
