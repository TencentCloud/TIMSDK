package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageListGetOption;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageParser;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ImageVideoScanProvider {
    private static final String TAG = ImageVideoScanProvider.class.getSimpleName();
    public static final int SCAN_MESSAGE_NUM = 10;
    public static final int SCAN_MESSAGE_REQUEST_NUM = 20;

    public void initMessageList(String chatId, boolean isGroup, TUIMessageBean locateMessageInfo, IUIKitCallback<List<TUIMessageBean>> callBack) {
        if (locateMessageInfo.getStatus() == TUIMessageBean.MSG_STATUS_SENDING) {
            return;
        }
        // 1、先向后拉取 SCAN_MESSAGE_REQUEST_NUM 条, 新消息方向
        // Pull back SCAN_MESSAGE_REQUEST_NUM numbers first, new message direction
        loadLocalMediaMessageList(
            chatId, isGroup, SCAN_MESSAGE_REQUEST_NUM, locateMessageInfo, TUIChatConstants.GET_MESSAGE_BACKWARD, new IUIKitCallback<List<TUIMessageBean>>() {
                @Override
                public void onSuccess(List<TUIMessageBean> firstData) {
                    firstData.add(0, locateMessageInfo);
                    // 2、再向前拉取 SCAN_MESSAGE_REQUEST_NUM 条，旧消息方向
                    // pull forward SCAN_MESSAGE_REQUEST_NUM numbers, old message direction
                    loadLocalMediaMessageList(chatId, isGroup, SCAN_MESSAGE_REQUEST_NUM, locateMessageInfo, TUIChatConstants.GET_MESSAGE_FORWARD,
                        new IUIKitCallback<List<TUIMessageBean>>() {
                            @Override
                            public void onSuccess(List<TUIMessageBean> secondData) {
                                Collections.reverse(secondData);
                                secondData.addAll(firstData);
                                TUIChatUtils.callbackOnSuccess(callBack, secondData);
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                TUIChatUtils.callbackOnSuccess(callBack, firstData);
                                TUIChatLog.e(
                                    TAG, "loadChatMessages getHistoryMessageList GET_MESSAGE_FORWARD failed, code = " + errCode + ", desc = " + errMsg);
                            }
                        });
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatUtils.callbackOnError(callBack, TAG, errCode, errMsg);
                    TUIChatLog.e(TAG, "loadChatMessages getHistoryMessageList GET_MESSAGE_BACKWARD failed, code = " + errCode + ", desc = " + errMsg);
                }
            });
    }

    public void loadLocalMediaMessageForward(String chatId, boolean isGroup, TUIMessageBean locateMessageInfo, IUIKitCallback<List<TUIMessageBean>> callBack) {
        loadLocalMediaMessageList(
            chatId, isGroup, SCAN_MESSAGE_REQUEST_NUM, locateMessageInfo, TUIChatConstants.GET_MESSAGE_FORWARD, new IUIKitCallback<List<TUIMessageBean>>() {
                @Override
                public void onSuccess(List<TUIMessageBean> secondData) {
                    Collections.reverse(secondData);
                    TUIChatUtils.callbackOnSuccess(callBack, secondData);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatUtils.callbackOnError(callBack, TAG, errCode, errMsg);
                    TUIChatLog.e(TAG, "loadChatMessages loadLocalMediaMessageForward failed, code = " + errCode + ", desc = " + errMsg);
                }
            });
    }

    public void loadLocalMediaMessageBackward(String chatId, boolean isGroup, TUIMessageBean locateMessageInfo, IUIKitCallback<List<TUIMessageBean>> callBack) {
        loadLocalMediaMessageList(
            chatId, isGroup, SCAN_MESSAGE_REQUEST_NUM, locateMessageInfo, TUIChatConstants.GET_MESSAGE_BACKWARD, new IUIKitCallback<List<TUIMessageBean>>() {
                @Override
                public void onSuccess(List<TUIMessageBean> firstData) {
                    TUIChatUtils.callbackOnSuccess(callBack, firstData);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatUtils.callbackOnError(callBack, TAG, errCode, errMsg);
                    TUIChatLog.e(TAG, "loadChatMessages loadLocalMediaMessageBackward failed, code = " + errCode + ", desc = " + errMsg);
                }
            });
    }

    public void loadLocalMediaMessageList(
        String chatId, boolean isGroup, int loadCount, TUIMessageBean locateMessageInfo, int getType, IUIKitCallback<List<TUIMessageBean>> callBack) {
        V2TIMMessageListGetOption optionBackward = new V2TIMMessageListGetOption();
        optionBackward.setCount(loadCount);
        List<Integer> messageTypeList = new ArrayList<>();
        messageTypeList.add(V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE);
        messageTypeList.add(V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO);
        optionBackward.setMessageTypeList(messageTypeList);
        if (getType == TUIChatConstants.GET_MESSAGE_FORWARD) {
            optionBackward.setGetType(V2TIMMessageListGetOption.V2TIM_GET_LOCAL_OLDER_MSG);
        } else if (getType == TUIChatConstants.GET_MESSAGE_BACKWARD) {
            optionBackward.setGetType(V2TIMMessageListGetOption.V2TIM_GET_LOCAL_NEWER_MSG);
        }
        if (locateMessageInfo != null) {
            optionBackward.setLastMsg(locateMessageInfo.getV2TIMMessage());
        }
        if (isGroup) {
            optionBackward.setGroupID(chatId);
        } else {
            optionBackward.setUserID(chatId);
        }

        V2TIMManager.getMessageManager().getHistoryMessageList(optionBackward, new V2TIMValueCallback<List<V2TIMMessage>>() {
            @Override
            public void onError(int code, String desc) {
                TUIChatUtils.callbackOnError(callBack, TAG, code, desc);
                TUIChatLog.e(TAG, "loadChatMessages getHistoryMessageList optionBackward failed, code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(List<V2TIMMessage> v2TIMMessages) {
                if (v2TIMMessages.isEmpty()) {
                    TUIChatLog.d(TAG, "getHistoryMessageList is null");
                    TUIChatUtils.callbackOnSuccess(callBack, new ArrayList<>());
                    return;
                }

                List<V2TIMMessage> timMessages = new ArrayList<>();
                for (V2TIMMessage timMessage : v2TIMMessages) {
                    TUIChatLog.d(TAG, "loadLocalMediaMessageList getType = " + getType + "timMessage seq = " + timMessage.getSeq());
                    int status = timMessage.getStatus();
                    if (status == V2TIMMessage.V2TIM_MSG_STATUS_HAS_DELETED || status == V2TIMMessage.V2TIM_MSG_STATUS_LOCAL_REVOKED) {
                        continue;
                    }
                    timMessages.add(timMessage);
                }

                List<TUIMessageBean> messageInfoList = ChatMessageParser.parseMessageList(timMessages);
                TUIChatUtils.callbackOnSuccess(callBack, messageInfoList);
            }
        });
    }
}
