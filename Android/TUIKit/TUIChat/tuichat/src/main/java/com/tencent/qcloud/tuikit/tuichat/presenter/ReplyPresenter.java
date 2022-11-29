package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageReactBean;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.tuichat.bean.ReactUserBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IReplyMessageHandler;
import com.tencent.qcloud.tuikit.tuichat.model.ChatProvider;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;


public class ReplyPresenter {
    private ChatProvider provider;
    private GroupChatEventListener groupChatEventListener;
    private C2CChatEventListener c2CChatEventListener;
    private ChatPresenter chatPresenter;
    private ChatInfo chatInfo;
    private String messageId;
    private IReplyMessageHandler replyHandler;
    public ReplyPresenter() {
        provider = new ChatProvider();
    }

    public void setMessageId(String messageId) {
        this.messageId = messageId;
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
        if (chatInfo.getType() == ChatInfo.TYPE_C2C) {
            chatPresenter = new C2CChatPresenter();
            ((C2CChatPresenter) chatPresenter).setChatInfo(chatInfo);
        } else {
            chatPresenter = new GroupChatPresenter();
            ((GroupChatPresenter) chatPresenter).setGroupInfo((GroupInfo) chatInfo);
        }
    }

    public ChatPresenter getChatPresenter() {
        return chatPresenter;
    }

    public void setChatEventListener() {
        if (chatPresenter instanceof C2CChatPresenter) {
            c2CChatEventListener = new C2CChatEventListener() {

                @Override
                public void onRecvMessageModified(TUIMessageBean messageBean) {
                    if (TextUtils.equals(messageBean.getId(), messageId)) {
                        onMessageModified(messageBean);
                    }
                }
            };
            TUIChatService.getInstance().addC2CChatEventListener(c2CChatEventListener);
        } else {
            groupChatEventListener = new GroupChatEventListener() {

                @Override
                public void onRecvMessageModified(TUIMessageBean messageBean) {
                    if (TextUtils.equals(messageBean.getId(), messageId)) {
                        onMessageModified(messageBean);
                    }
                }
            };
            TUIChatService.getInstance().addGroupChatEventListener(groupChatEventListener);
        }
    }

    public void findReplyMessages(MessageRepliesBean repliesBean) {
        if (repliesBean == null || repliesBean.getRepliesSize() == 0) {
            return;
        }
        List<MessageRepliesBean.ReplyBean> replyBeanList = repliesBean.getReplies();
        List<String> msgIdList = new ArrayList<>(replyBeanList.size());
        for (MessageRepliesBean.ReplyBean replyBean : replyBeanList) {
            msgIdList.add(replyBean.getMessageID());
        }
        Map<MessageRepliesBean.ReplyBean, TUIMessageBean> messageBeanMap = new LinkedHashMap<>();
        for (MessageRepliesBean.ReplyBean replyBean : replyBeanList) {
            messageBeanMap.put(replyBean, null);
        }
        chatPresenter.findMessage(msgIdList, new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> data) {
                for (MessageRepliesBean.ReplyBean replyBean : replyBeanList) {
                    Iterator<TUIMessageBean> iterator = data.listIterator();
                    while(iterator.hasNext()) {
                        TUIMessageBean messageBean = iterator.next();
                        if (TextUtils.equals(messageBean.getId(), replyBean.getMessageID())) {
                            messageBeanMap.put(replyBean, messageBean);
                            iterator.remove();
                            break;
                        }
                    }
                }
                processReplyBeanList(messageBeanMap);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                processReplyBeanList(messageBeanMap);
            }
        });
    }

    private void processReplyBeanList(Map<MessageRepliesBean.ReplyBean, TUIMessageBean> replyBeanDataMap) {
        Set<String> userIDSet = new HashSet<>();
        for (Map.Entry<MessageRepliesBean.ReplyBean, TUIMessageBean> entry : replyBeanDataMap.entrySet()) {
            if (entry.getValue() == null) {
                userIDSet.add(entry.getKey().getMessageSender());
            }
        }
        if (userIDSet.isEmpty()) {
            if (replyHandler != null) {
                replyHandler.onRepliesMessageFound(replyBeanDataMap);
            }
            return;
        }
        chatPresenter.getReactUserBean(userIDSet, new IUIKitCallback<Map<String, ReactUserBean>>() {
            @Override
            public void onSuccess(Map<String, ReactUserBean> data) {
                for (Map.Entry<String, ReactUserBean> dataEntry : data.entrySet()) {
                    if (dataEntry.getValue() != null) {
                        String userID = dataEntry.getKey();
                        ReactUserBean userBean = dataEntry.getValue();
                        for (Map.Entry<MessageRepliesBean.ReplyBean, TUIMessageBean> entry : replyBeanDataMap.entrySet()) {
                            if (TextUtils.equals(entry.getKey().getMessageSender(), userID)) {
                                entry.getKey().setSenderShowName(userBean.getDisplayString());
                                entry.getKey().setSenderFaceUrl(userBean.getFaceUrl());
                            }
                        }
                    }
                }
                if (replyHandler != null) {
                    replyHandler.onRepliesMessageFound(replyBeanDataMap);
                }
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                if (replyHandler != null) {
                    replyHandler.onRepliesMessageFound(replyBeanDataMap);
                }
            }
        });
    }

    public void setReplyHandler(IReplyMessageHandler replyHandler) {
        this.replyHandler = replyHandler;
    }

    private void onMessageModified(TUIMessageBean messageBean) {
        if (replyHandler != null) {
            replyHandler.updateData(messageBean);
        }
    }

    public void sendReplyMessage(TUIMessageBean replyMessageBean, IUIKitCallback<TUIMessageBean> callback) {
        chatPresenter.sendMessage(replyMessageBean, false, new IUIKitCallback<TUIMessageBean>() {
            @Override
            public void onSuccess(TUIMessageBean data) {
                Map<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIChat.CHAT_ID, chatInfo.getId());
                param.put(TUIConstants.TUIChat.MESSAGE_BEAN, data);
                param.put(TUIConstants.TUIChat.IS_GROUP_CHAT, chatInfo.getType() == ChatInfo.TYPE_GROUP);
                TUICore.callService(TUIConstants.TUIChat.SERVICE_NAME, TUIConstants.TUIChat.METHOD_ADD_MESSAGE_TO_CHAT, param);
                chatPresenter.modifyRootMessageToAddReplyInfo((ReplyMessageBean) data, new IUIKitCallback<Void>() {
                    @Override
                    public void onError(String module, int errCode, String errMsg) {
                        TUIChatUtils.callbackOnError(callback, errCode, errMsg);
                    }
                });
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

    public void getReactUserBean(TUIMessageBean messageBean, IUIKitCallback<Void> callback) {
        List<TUIMessageBean> messageBeanList = new ArrayList<>();
        messageBeanList.add(messageBean);
        Set<String> userIdSet = chatPresenter.getReactUserNames(messageBeanList);
        if (userIdSet.isEmpty()) {
            TUIChatUtils.callbackOnSuccess(callback, null);
            return;
        }
        chatPresenter.getReactUserBean(userIdSet, new IUIKitCallback<Map<String, ReactUserBean>>() {
            @Override
            public void onSuccess(Map<String, ReactUserBean> map) {
                for (TUIMessageBean messageBean : messageBeanList) {
                    MessageReactBean reactBean = messageBean.getMessageReactBean();
                    if (reactBean != null) {
                        reactBean.setReactUserBeanMap(map);
                    }
                }
                TUIChatUtils.callbackOnSuccess(callback, null);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatUtils.callbackOnError(callback, errCode, errMsg);
            }
        });
    }

}
