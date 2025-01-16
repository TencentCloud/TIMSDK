package com.tencent.qcloud.tuikit.tuichat.presenter;

import com.tencent.imsdk.v2.V2TIMFriendCheckResult;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.FriendProfileBean;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonUtil;
import com.tencent.qcloud.tuikit.tuichat.interfaces.FriendProfileListener;
import com.tencent.qcloud.tuikit.tuichat.model.ProfileProvider;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FriendProfilePresenter {
    private static final String TAG = "FriendProfilePresenter";

    private final ProfileProvider provider = new ProfileProvider();

    private FriendProfileListener profileListener;

    public void setProfileListener(FriendProfileListener profileListener) {
        this.profileListener = profileListener;
    }

    public void loadFriendProfile(String userID) {
        List<String> userIDs = Collections.singletonList(userID);
        provider.getFriendsProfile(userIDs, new TUIValueCallback<List<FriendProfileBean>>() {
            @Override
            public void onSuccess(List<FriendProfileBean> object) {
                if (object == null || !object.isEmpty()) {
                    if (profileListener != null) {
                        profileListener.onFriendProfileLoaded(object.get(0));
                    }
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "loadFriendProfile error, code = " + errorCode + ", desc = " + errorMessage);
            }
        });

        checkFriend(userID, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                if (profileListener != null) {
                    profileListener.onFriendCheckResult(object);
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });

        checkBlackList(userID, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                if (profileListener != null) {
                    profileListener.onBlackListCheckResult(object);
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });

        checkConversationPinned(userID, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                if (profileListener != null) {
                    profileListener.onConversationPinnedCheckResult(object);
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });

        checkMessageHasNotification(userID, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                if (profileListener != null) {
                    profileListener.onMessageHasNotificationCheckResult(!object);
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    public void checkFriend(String userID, TUIValueCallback<Boolean> callback) {
        List<String> userIDs = Collections.singletonList(userID);
        provider.checkFriend(userIDs, new TUIValueCallback<Map<String, Integer>>() {
            @Override
            public void onSuccess(Map<String, Integer> object) {
                Integer integer = object.get(userID);
                if (integer != null
                    && (integer == V2TIMFriendCheckResult.V2TIM_FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST
                        || integer == V2TIMFriendCheckResult.V2TIM_FRIEND_RELATION_TYPE_BOTH_WAY)) {
                    TUIValueCallback.onSuccess(callback, true);
                } else {
                    TUIValueCallback.onSuccess(callback, false);
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "checkFriend error, code = " + errorCode + ", desc = " + errorMessage);
                TUIValueCallback.onError(callback, errorCode, errorMessage);
            }
        });
    }

    public void checkBlackList(String userID, TUIValueCallback<Boolean> callback) {
        provider.checkBlackList(userID, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                TUIValueCallback.onSuccess(callback, object);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "checkBlackList error, code = " + errorCode + ", desc = " + errorMessage);
            }
        });
    }

    public void checkConversationPinned(String userID, TUIValueCallback<Boolean> callback) {
        provider.checkoutConversationPinned(userID, false, new TUIValueCallback<Boolean>() {
            @Override
            public void onSuccess(Boolean object) {
                TUIValueCallback.onSuccess(callback, object);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "checkConversationPinned error, code = " + errorCode + ", desc = " + errorMessage);
                TUIValueCallback.onError(callback, errorCode, errorMessage);
            }
        });
    }

    public void checkMessageHasNotification(String userID, TUIValueCallback<Boolean> callback) {
        List<String> userIDs = Collections.singletonList(userID);
        provider.getC2CReceiveMessageOpt(userIDs, new TUIValueCallback<Map<String, Integer>>() {
            @Override
            public void onSuccess(Map<String, Integer> object) {
                Integer opt = object.get(userID);
                if (opt != null) {
                    TUIValueCallback.onSuccess(callback, opt == V2TIMMessage.V2TIM_RECEIVE_MESSAGE);
                }
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "checkMessageHasNotification error, code = " + errorCode + ", desc = " + errorMessage);
                TUIValueCallback.onError(callback, errorCode, errorMessage);
            }
        });
    }

    public void setMessageHasNotification(String userID, boolean hasNotification) {
        int opt = hasNotification ? V2TIMMessage.V2TIM_RECEIVE_MESSAGE : V2TIMMessage.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE;
        List<String> userIDs = Collections.singletonList(userID);
        provider.setC2CReceiveMessageOpt(userIDs, opt, new TUICallback() {
            @Override
            public void onSuccess() {

            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "setMessageHasNotification error, code = " + errorCode + ", desc = " + errorMessage);
            }
        });
    }

    public void modifyFriendRemark(String userID, String remark) {
        provider.modifyFriendRemark(userID, remark, new TUICallback() {
            @Override
            public void onSuccess() {
                Map<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.FRIEND_ID, userID);
                param.put(TUIConstants.TUIContact.FRIEND_REMARK, remark);
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED, TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED, param);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    public void removeFriend(String userID) {
        List<String> userIDs = Collections.singletonList(userID);
        provider.removeFriends(userIDs, new TUIValueCallback<Map<String, Integer>>() {
            @Override
            public void onSuccess(Map<String, Integer> object) {
                String conversationId = TIMCommonUtil.getConversationIdByID(userID, false);
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIConversation.CONVERSATION_ID, conversationId);
                param.put(TUIConstants.TUIChat.CHAT_ID, userID);
                param.put(TUIConstants.TUIChat.IS_GROUP_CHAT, false);
                TUICore.callService(TUIConstants.TUIConversation.SERVICE_NAME, TUIConstants.TUIConversation.METHOD_DELETE_CONVERSATION, param);
                TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_EXIT_CHAT, param);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "removeFriend error, code = " + errorCode + ", desc = " + errorMessage);
            }
        });
    }

    public void deleteFromBlackList(String userID) {
        List<String> userIDs = Collections.singletonList(userID);
        provider.deleteFromBlackList(userIDs, new TUICallback() {
            @Override
            public void onSuccess() {}

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    public void addToBlackList(String userID) {
        List<String> userIDs = Collections.singletonList(userID);
        provider.addToBlackList(userIDs, new TUIValueCallback<Map<String, Integer>>() {
            @Override
            public void onSuccess(Map<String, Integer> object) {}

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    public void pinConversation(String userID, boolean isPinned) {
        String conversationID = TIMCommonUtil.getConversationIdByID(userID, false);
        provider.pinConversation(conversationID, isPinned, new TUICallback() {
            @Override
            public void onSuccess() {}

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }

    public void clearHistoryMessage(String userID) {
        Map<String, Object> hashMap = new HashMap<>();
        hashMap.put(TUIConstants.TUIContact.FRIEND_ID, userID);
        TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_USER, TUIConstants.TUIContact.EVENT_SUB_KEY_CLEAR_C2C_MESSAGE, hashMap);
        provider.clearHistoryMessage(userID, false, new TUICallback() {
            @Override
            public void onSuccess() {}

            @Override
            public void onError(int errorCode, String errorMessage) {}
        });
    }
}
