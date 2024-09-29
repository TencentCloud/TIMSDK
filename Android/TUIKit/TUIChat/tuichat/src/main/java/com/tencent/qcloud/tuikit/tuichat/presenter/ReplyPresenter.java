package com.tencent.qcloud.tuikit.tuichat.presenter;

import android.text.TextUtils;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.MessageRepliesBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.C2CChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.GroupChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ReplyMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.GroupChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IReplyMessageHandler;
import com.tencent.qcloud.tuikit.tuichat.model.ChatProvider;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.ArrayList;
import java.util.Collections;
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
    private TUIMessageBean messageBean;
    private IReplyMessageHandler replyHandler;

    public ReplyPresenter() {
        provider = new ChatProvider();
    }

    public void setMessageBean(TUIMessageBean messageBean) {
        this.messageBean = messageBean;
        TUIChatUtils.notifyProcessMessage(Collections.singletonList(messageBean));
    }

    public void setChatInfo(ChatInfo chatInfo) {
        this.chatInfo = chatInfo;
        if (chatInfo instanceof C2CChatInfo) {
            chatPresenter = new C2CChatPresenter();
            ((C2CChatPresenter) chatPresenter).setChatInfo((C2CChatInfo) chatInfo);
        } else {
            chatPresenter = new GroupChatPresenter();
            ((GroupChatPresenter) chatPresenter).setGroupInfo((GroupChatInfo) chatInfo);
        }
    }

    public ChatPresenter getChatPresenter() {
        return chatPresenter;
    }

    public void setChatEventListener() {
        if (chatPresenter instanceof C2CChatPresenter) {
            c2CChatEventListener = new C2CChatEventListener() {
                @Override
                public void onRecvMessageModified(TUIMessageBean changedMessage) {
                    if (changedMessage != null && messageBean != null && TextUtils.equals(messageBean.getId(), changedMessage.getId())) {
                        messageBean.setMessageRepliesBean(changedMessage.getMessageRepliesBean());
                        onMessageModified(messageBean);
                    }
                }

                @Override
                public void onMessageChanged(TUIMessageBean messageBean, int dataChangeType) {
                    onRecvMessageModified(messageBean);
                }
            };
            TUIChatService.getInstance().addC2CChatEventListener(c2CChatEventListener);
        } else {
            groupChatEventListener = new GroupChatEventListener() {
                @Override
                public void onRecvMessageModified(TUIMessageBean changedMessage) {
                    if (changedMessage != null && messageBean != null && TextUtils.equals(messageBean.getId(), changedMessage.getId())) {
                        messageBean.setMessageRepliesBean(changedMessage.getMessageRepliesBean());
                        onMessageModified(messageBean);
                    }
                }

                @Override
                public void onMessageChanged(TUIMessageBean messageBean, int dataChangeType) {
                    onRecvMessageModified(messageBean);
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
        provider.findMessages(msgIdList, new TUIValueCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> data) {
                for (MessageRepliesBean.ReplyBean replyBean : replyBeanList) {
                    Iterator<TUIMessageBean> iterator = data.listIterator();
                    while (iterator.hasNext()) {
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
            public void onError(int errCode, String errMsg) {
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
        chatPresenter.getUserBean(userIDSet, new IUIKitCallback<Map<String, UserBean>>() {
            @Override
            public void onSuccess(Map<String, UserBean> data) {
                for (Map.Entry<String, UserBean> dataEntry : data.entrySet()) {
                    if (dataEntry.getValue() != null) {
                        String userID = dataEntry.getKey();
                        UserBean userBean = dataEntry.getValue();
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
        chatPresenter.sendMessage(replyMessageBean, false, false, new IUIKitCallback<TUIMessageBean>() {
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
}
