package com.tencent.qcloud.tuikit.tuiemojiplugin.model;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReaction;
import com.tencent.imsdk.v2.V2TIMMessageReactionResult;
import com.tencent.imsdk.v2.V2TIMMessageReactionUserResult;
import com.tencent.imsdk.v2.V2TIMUserInfo;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionUserBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.ReactionBean;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class TUIEmojiProvider {
    public void addMessageReaction(TUIMessageBean messageBean, String reactionID, TUICallback callback) {
        V2TIMMessage message = messageBean.getV2TIMMessage();
        V2TIMManager.getMessageManager().addMessageReaction(message, reactionID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void removeMessageReaction(TUIMessageBean messageBean, String reactionID, TUICallback callback) {
        V2TIMMessage message = messageBean.getV2TIMMessage();
        V2TIMManager.getMessageManager().removeMessageReaction(message, reactionID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                TUICallback.onSuccess(callback);
            }

            @Override
            public void onError(int code, String desc) {
                TUICallback.onError(callback, code, desc);
            }
        });
    }

    public void getMessageReactions(List<TUIMessageBean> messageBeans, int countPerReaction, TUIValueCallback<List<MessageReactionBean>> callback) {
        if (messageBeans == null) {
            return;
        }
        List<V2TIMMessage> messages = new ArrayList<>();
        for (TUIMessageBean messageBean : messageBeans) {
            if (messageBean.getStatus() == TUIMessageBean.MSG_STATUS_SEND_FAIL) {
                continue;
            }
            messages.add(messageBean.getV2TIMMessage());
        }
        V2TIMManager.getMessageManager().getMessageReactions(messages, countPerReaction, new V2TIMValueCallback<List<V2TIMMessageReactionResult>>() {
            @Override
            public void onSuccess(List<V2TIMMessageReactionResult> v2TIMMessageReactionResults) {
                List<MessageReactionBean> messageReactionBeanList = new ArrayList<>();
                for (V2TIMMessageReactionResult reactionResult : v2TIMMessageReactionResults) {
                    MessageReactionBean messageReactionBean = new MessageReactionBean();
                    messageReactionBean.setMessageID(reactionResult.getMessageID());
                    List<V2TIMMessageReaction> v2TIMMessageReactionList = reactionResult.getReactionList();
                    Map<String, ReactionBean> reactionBeanMap = new LinkedHashMap<>();
                    if (v2TIMMessageReactionList != null) {
                        for (V2TIMMessageReaction reaction : v2TIMMessageReactionList) {
                            ReactionBean reactionBean = new ReactionBean();
                            reactionBean.setReactionID(reaction.getReactionID());
                            reactionBean.setByMySelf(reaction.getReactedByMyself());
                            reactionBean.setTotalUserCount(reaction.getTotalUserCount());
                            List<V2TIMUserInfo> v2TIMUserInfoList = reaction.getPartialUserList();
                            List<UserBean> userBeanList = new ArrayList<>();
                            if (v2TIMUserInfoList != null) {
                                for (V2TIMUserInfo v2TIMUserInfo : v2TIMUserInfoList) {
                                    UserBean reactUserBean = new UserBean();
                                    reactUserBean.setUserId(v2TIMUserInfo.getUserID());
                                    reactUserBean.setNikeName(v2TIMUserInfo.getNickName());
                                    reactUserBean.setFaceUrl(v2TIMUserInfo.getFaceUrl());
                                    userBeanList.add(reactUserBean);
                                }
                                reactionBean.setPartialUserList(userBeanList);
                            }
                            reactionBeanMap.put(reactionBean.getReactionID(), reactionBean);
                        }
                    }
                    messageReactionBean.setMessageReactionBeanMap(reactionBeanMap);
                    messageReactionBeanList.add(messageReactionBean);
                }
                if (callback != null) {
                    callback.onSuccess(messageReactionBeanList);
                }
            }

            @Override
            public void onError(int code, String desc) {
                if (callback != null) {
                    callback.onError(code, desc);
                }
            }
        });
    }

    public void getAllUserListOfMessageReaction(
        TUIMessageBean messageBean, String reactionID, int nextSeq, int count, TUIValueCallback<MessageReactionUserBean> callback) {
        V2TIMMessage message = messageBean.getV2TIMMessage();
        V2TIMManager.getMessageManager().getAllUserListOfMessageReaction(
            message, reactionID, nextSeq, count, new V2TIMValueCallback<V2TIMMessageReactionUserResult>() {
                @Override
                public void onSuccess(V2TIMMessageReactionUserResult v2TIMMessageReactionUserResult) {
                    MessageReactionUserBean resultBean = new MessageReactionUserBean();
                    resultBean.setFinished(v2TIMMessageReactionUserResult.getIsFinished());
                    resultBean.setNextSeq(v2TIMMessageReactionUserResult.getNextSeq());
                    List<UserBean> userBeanList = new ArrayList<>();
                    List<V2TIMUserInfo> v2TIMUserInfoList = v2TIMMessageReactionUserResult.getUserInfoList();
                    if (v2TIMUserInfoList != null) {
                        for (V2TIMUserInfo userInfo : v2TIMUserInfoList) {
                            UserBean reactUserBean = new UserBean();
                            reactUserBean.setUserId(userInfo.getUserID());
                            reactUserBean.setNikeName(userInfo.getNickName());
                            reactUserBean.setFaceUrl(userInfo.getFaceUrl());
                            userBeanList.add(reactUserBean);
                        }
                    }
                    resultBean.setUserBeanList(userBeanList);
                    if (callback != null) {
                        callback.onSuccess(resultBean);
                    }
                }

                @Override
                public void onError(int code, String desc) {
                    if (callback != null) {
                        callback.onError(code, desc);
                    }
                }
            });
    }
}
