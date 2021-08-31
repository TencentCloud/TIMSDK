package com.tencent.qcloud.tim.uikit.modules.conversation;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationResult;
import com.tencent.imsdk.v2.V2TIMGroupAtInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberFullInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfoResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.config.TUIKitConfigs;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.DraftInfo;
import com.tencent.qcloud.tim.uikit.modules.conversation.interfaces.ILoadConversationCallback;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.modules.message.MessageRevokedManager;
import com.tencent.qcloud.tim.uikit.utils.DateTimeUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ConversationManagerKit {

    private final static String TAG = ConversationManagerKit.class.getSimpleName();
    private final static String SP_IMAGE = "_conversation_group_face";
    private final static int GET_CONVERSATION_COUNT = 100;

    private static ConversationManagerKit instance = new ConversationManagerKit();

    private ConversationProvider mProvider;
    private List<MessageUnreadWatcher> mUnreadWatchers = new ArrayList<>();
    private int mUnreadTotal;

    private ConversationManagerKit() {
        init();
    }

    public static ConversationManagerKit getInstance() {
        return instance;
    }

    private void init() {
        TUIKitLog.i(TAG, "init");
    }

    /**
     * 加载会话信息
     *
     * @param nextSeq 分页拉取的游标，第一次默认取传 0，后续分页拉传上一次分页拉取成功回调里的 nextSeq
     * @param callBack 拉取会话的回调
     */
    public void loadConversation(long nextSeq, final ILoadConversationCallback callBack) {
        TUIKitLog.i(TAG, "loadConversation callBack:" + callBack);
        //mProvider初始化值为null,用户注销时会销毁，登录完成进入需再次实例化
        if (mProvider == null) {
            mProvider = new ConversationProvider();
        }

        V2TIMManager.getConversationManager().getConversationList(nextSeq, GET_CONVERSATION_COUNT, new V2TIMValueCallback<V2TIMConversationResult>() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.v(TAG, "loadConversation getConversationList error, code = " + code + ", desc = " + desc);
            }

            @Override
            public void onSuccess(V2TIMConversationResult v2TIMConversationResult) {
                List<V2TIMConversation> v2TIMConversationList = v2TIMConversationResult.getConversationList();
                onRefreshConversation(v2TIMConversationList);
                boolean isFinished = v2TIMConversationResult.isFinished();
                long nextSeq = v2TIMConversationResult.getNextSeq();
                if (callBack != null) {
                    callBack.onSuccess(mProvider, isFinished, nextSeq);
                }

                // 更新消息未读总数
                V2TIMManager.getConversationManager().getTotalUnreadMessageCount(new V2TIMValueCallback<Long>() {
                    @Override
                    public void onSuccess(Long aLong) {
                        mUnreadTotal = aLong.intValue();
                        updateUnreadTotal(mUnreadTotal);
                    }

                    @Override
                    public void onError(int code, String desc) {

                    }
                });
            }
        });
    }

    /**
     * 部分会话刷新（包括多终端已读上报同步）
     *
     * @param v2TIMConversationList 需要刷新的会话列表
     */
    public void onRefreshConversation(List<V2TIMConversation> v2TIMConversationList) {
        TUIKitLog.i(TAG, "onRefreshConversation conversations:" + v2TIMConversationList);
        if (mProvider == null) {
            return;
        }
        ArrayList<ConversationInfo> infos = new ArrayList<>();
        for (int i = 0; i < v2TIMConversationList.size(); i++) {
            V2TIMConversation v2TIMConversation = v2TIMConversationList.get(i);
            TUIKitLog.v(TAG, "refreshConversation v2TIMConversation " + v2TIMConversation.toString());
            ConversationInfo conversationInfo = TIMConversation2ConversationInfo(v2TIMConversation);
            if (conversationInfo != null && !V2TIMManager.GROUP_TYPE_AVCHATROOM.equals(v2TIMConversation.getGroupType())) {
                infos.add(conversationInfo);
            }
        }
        if (infos.size() == 0) {
            return;
        }
        List<ConversationInfo> dataSource = mProvider.getDataSource();
        ArrayList exists = new ArrayList();
        for (int j = 0; j < infos.size(); j++) {
            ConversationInfo update = infos.get(j);
            for (int i = 0; i < dataSource.size(); i++) {
                ConversationInfo cacheInfo = dataSource.get(i);
                //单个会话刷新时找到老的会话数据，替换，这里需要增加群组类型的判断，防止好友id与群组id相同
                if (cacheInfo.getId().equals(update.getId()) && cacheInfo.isGroup() == update.isGroup()) {
                    dataSource.remove(i);
                    dataSource.add(i, update);
                    exists.add(update);
                    //infos.remove(j);
                    break;
                }
            }
        }
        infos.removeAll(exists);
        if (infos.size() > 0) {
            dataSource.addAll(infos);
        }
        Collections.sort(dataSource);
        ArrayList<ConversationInfo> conversationInfos = new ArrayList<>();
        conversationInfos.addAll(dataSource);
        mProvider.setDataSource(conversationInfos);
    }

    public void updateTotalUnreadMessageCount(long totalUnreadCount) {
        mUnreadTotal = (int)totalUnreadCount;
        updateUnreadTotal(mUnreadTotal);
    }

    /**
     * TIMConversation转换为ConversationInfo
     *
     * @param conversation
     * @return
     */
    private ConversationInfo TIMConversation2ConversationInfo(final V2TIMConversation conversation) {
        if (conversation == null) {
            return null;
        }
        TUIKitLog.i(TAG, "TIMConversation2ConversationInfo id:" + conversation.getConversationID()
                + "|name:" + conversation.getShowName()
                + "|unreadNum:" + conversation.getUnreadCount());
        final ConversationInfo info = new ConversationInfo();
        int type = conversation.getType();
        if (type != V2TIMConversation.V2TIM_C2C && type != V2TIMConversation.V2TIM_GROUP) {
            return null;
        }

        boolean isGroup = type == V2TIMConversation.V2TIM_GROUP;

        String draftText = conversation.getDraftText();
        if (!TextUtils.isEmpty(draftText)) {
            DraftInfo draftInfo = new DraftInfo();
            draftInfo.setDraftText(draftText);
            draftInfo.setDraftTime(conversation.getDraftTimestamp());
            info.setDraft(draftInfo);
        }
        V2TIMMessage message = conversation.getLastMessage();
        if (message == null) {
            long time = DateTimeUtil.getStringToDate("0001-01-01 00:00:00", "yyyy-MM-dd HH:mm:ss");
            info.setLastMessageTime(time);
        } else {
            info.setLastMessageTime(message.getTimestamp());
        }
        MessageInfo messageInfo = MessageInfoUtil.TIMMessage2MessageInfo(message);
        if (messageInfo != null) {
            info.setLastMessage(messageInfo);
        }

        int atInfoType = getAtInfoType(conversation);
        switch (atInfoType){
            case V2TIMGroupAtInfo.TIM_AT_ME:
                info.setAtInfoText(TUIKit.getAppContext().getString(R.string.ui_at_me));
                break;
            case V2TIMGroupAtInfo.TIM_AT_ALL:
                info.setAtInfoText(TUIKit.getAppContext().getString(R.string.ui_at_all));
                break;
            case V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME:
                info.setAtInfoText(TUIKit.getAppContext().getString(R.string.ui_at_all_me));
                break;
            default:
                info.setAtInfoText("");
                break;

        }

        info.setTitle(conversation.getShowName());
        List<Object> faceList = new ArrayList<>();
        if (isGroup) {
            if (!TextUtils.isEmpty(conversation.getFaceUrl())) {
                faceList.add(conversation.getFaceUrl());
            }
        } else {
            if (TextUtils.isEmpty(conversation.getFaceUrl())) {
                faceList.add(R.drawable.default_user_icon);
            } else {
                faceList.add(conversation.getFaceUrl());
            }
        }
        info.setIconUrlList(faceList);
        if (isGroup) {
            info.setId(conversation.getGroupID());
            info.setGroupType(conversation.getGroupType());
        } else {
            info.setId(conversation.getUserID());
        }

        info.setShowDisturbIcon(conversation.getRecvOpt() == V2TIMMessage.V2TIM_NOT_RECEIVE_MESSAGE ? true : false);
        info.setConversationId(conversation.getConversationID());
        info.setGroup(isGroup);
        // AVChatRoom 不支持未读数。
        if (!V2TIMManager.GROUP_TYPE_AVCHATROOM.equals(conversation.getGroupType())) {
            info.setUnRead(conversation.getUnreadCount());
        }
        info.setTop(conversation.isPinned());
        info.setOrderKey(conversation.getOrderKey());
        return info;
    }

    private int getAtInfoType(V2TIMConversation conversation){
        int atInfoType = 0;
        boolean atMe = false;
        boolean atAll = false;

        List<V2TIMGroupAtInfo> atInfoList = conversation.getGroupAtInfoList();

        if (atInfoList == null || atInfoList.isEmpty()){
            return V2TIMGroupAtInfo.TIM_AT_UNKNOWN;
        }

        for(V2TIMGroupAtInfo atInfo : atInfoList){
            if (atInfo.getAtType() == V2TIMGroupAtInfo.TIM_AT_ME){
                atMe = true;
                continue;
            }
            if (atInfo.getAtType() == V2TIMGroupAtInfo.TIM_AT_ALL){
                atAll = true;
                continue;
            }
            if (atInfo.getAtType() == V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME){
                atMe = true;
                atAll = true;
                continue;
            }
        }

        if (atAll && atMe){
            atInfoType = V2TIMGroupAtInfo.TIM_AT_ALL_AT_ME;
        } else if (atAll){
            atInfoType = V2TIMGroupAtInfo.TIM_AT_ALL;
        } else if (atMe){
            atInfoType = V2TIMGroupAtInfo.TIM_AT_ME;
        } else {
            atInfoType = V2TIMGroupAtInfo.TIM_AT_UNKNOWN;
        }

        return atInfoType;
    }


    /**
     * 将某个会话置顶
     *
     * @param conversation
     */
    public void setConversationTop(final ConversationInfo conversation, final IUIKitCallBack callBack) {
        TUIKitLog.i(TAG, "setConversationTop" + "|conversation:" + conversation);
        final boolean setTop = !conversation.isTop();

            V2TIMManager.getConversationManager().pinConversation(conversation.getConversationId(), setTop, new V2TIMCallback() {
                @Override
                public void onSuccess() {
                    conversation.setTop(setTop);
                    mProvider.setDataSource(sortConversations(mProvider.getDataSource()));
                }

                @Override
                public void onError(int code, String desc) {
                    TUIKitLog.e(TAG, "setConversationTop code:" + code + "|desc:" + desc);
                    if (callBack != null) {
                        callBack.onError("setConversationTop", code, desc);
                    }
                }
            });
    }

    /**
     * 会话置顶操作
     *
     * @param id   会话ID
     * @param isTop 是否置顶
     */
    public void setConversationTop(String id, final boolean isTop, final IUIKitCallBack callBack) {
        TUIKitLog.i(TAG, "setConversationTop id:" + id + "|isTop:" + isTop);
        ConversationInfo conversation = null;
        List<ConversationInfo> conversationInfos = mProvider.getDataSource();
        for (int i = 0; i < conversationInfos.size(); i++) {
            ConversationInfo info = conversationInfos.get(i);
            if (info.getId().equals(id)) {
                conversation = info;
                break;
            }
        }
        if (conversation == null) {
            return;
        }
        final String conversationID = conversation.getConversationId();
        V2TIMManager.getConversationManager().pinConversation(conversation.getConversationId(), isTop, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                List<ConversationInfo> conversationInfoList = mProvider.getDataSource();
                for (int i = 0; i < conversationInfoList.size(); i++) {
                    ConversationInfo info = conversationInfoList.get(i);
                    if (info.getId().equals(conversationID)) {
                        info.setTop(isTop);
                        break;
                    }
                }
                mProvider.setDataSource(sortConversations(mProvider.getDataSource()));
            }

            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "setConversationTop code:" + code + "|desc:" + desc);
                if (callBack != null) {
                    callBack.onError("setConversationTop", code, desc);
                }
            }
        });
    }

    /**
     * 删除会话，会将本地会话数据从imsdk中删除
     *
     * @param index        在数据源中的索引
     * @param conversation 会话信息
     */
    public void deleteConversation(int index, ConversationInfo conversation) {
        TUIKitLog.i(TAG, "deleteConversation index:" + index + "|conversation:" + conversation);
        V2TIMManager.getConversationManager().deleteConversation(conversation.getConversationId(), new V2TIMCallback() {
            @Override
            public void onError(int code, String desc) {
                TUIKitLog.e(TAG, "deleteConversation error:" + code + ", desc:" + desc);
            }

            @Override
            public void onSuccess() {
                TUIKitLog.i(TAG, "deleteConversation success");
            }
        });
        if (mProvider != null) {
            mProvider.deleteConversation(index);
        }
    }

    /**
     * 清空会话
     *
     * @param index        在数据源中的索引
     * @param conversation 会话信息
     */
    public void clearConversationMessage(int index, ConversationInfo conversation) {
        if (conversation == null || TextUtils.isEmpty(conversation.getConversationId())) {
            TUIKitLog.e(TAG, "clearConversationMessage error: invalid conversation");
        }

        TUIKitLog.i(TAG, "clearConversationMessage index:" + index + "|conversation:" + conversation);
        if (conversation.isGroup()) {
            V2TIMManager.getMessageManager().clearGroupHistoryMessage(conversation.getId(), new V2TIMCallback() {
                @Override
                public void onError(int code, String desc) {
                    TUIKitLog.e(TAG, "clearConversationMessage error:" + code + ", desc:" + desc);
                }

                @Override
                public void onSuccess() {
                    TUIKitLog.i(TAG, "clearConversationMessage success");
                }
            });
        } else {
            V2TIMManager.getMessageManager().clearC2CHistoryMessage(conversation.getId(), new V2TIMCallback() {
                @Override
                public void onError(int code, String desc) {
                    TUIKitLog.e(TAG, "clearConversationMessage error:" + code + ", desc:" + desc);
                }

                @Override
                public void onSuccess() {
                    TUIKitLog.i(TAG, "clearConversationMessage success");
                }
            });
        }
    }

    /**
     * 删除会话，只删除数据源中的会话信息
     *
     * @param id C2C：对方的 userID；Group：群 ID
     */
    public void deleteConversation(String id, boolean isGroup) {
        TUIKitLog.i(TAG, "deleteConversation id:" + id + "|isGroup:" + isGroup);
        String conversationID = "";
        if (mProvider != null) {
            List<ConversationInfo> conversationInfoList = mProvider.getDataSource();
            for (ConversationInfo conversationInfo : conversationInfoList) {
                if (isGroup == conversationInfo.isGroup() && conversationInfo.getId().equals(id)) {
                    conversationID = conversationInfo.getConversationId();
                    break;
                }
            }
            if (!TextUtils.isEmpty(conversationID)) {
                mProvider.deleteConversation(conversationID);
            }
        }
        if (!TextUtils.isEmpty(conversationID)) {
            V2TIMManager.getConversationManager().deleteConversation(conversationID, new V2TIMCallback() {
                @Override
                public void onError(int code, String desc) {
                    TUIKitLog.i(TAG, "deleteConversation error:" + code + ", desc:" + desc);
                }

                @Override
                public void onSuccess() {
                    TUIKitLog.i(TAG, "deleteConversation success");
                }
            });
        }
    }

    /**
     * 添加会话
     *
     * @param conversationInfo
     * @return
     */
    public boolean addConversation(ConversationInfo conversationInfo) {
        List<ConversationInfo> conversationInfos = new ArrayList<>();
        conversationInfos.add(conversationInfo);
        return mProvider.addConversations(conversationInfos);
    }

    /**
     * 会话数据排序，添加了置顶标识的处理
     *
     * @param sources
     * @return
     */
    private List<ConversationInfo> sortConversations(List<ConversationInfo> sources) {
        ArrayList<ConversationInfo> conversationInfos = new ArrayList<>();
        List<ConversationInfo> normalConversations = new ArrayList<>();
        List<ConversationInfo> topConversations = new ArrayList<>();

        for (int i = 0; i <= sources.size() - 1; i++) {
            ConversationInfo conversation = sources.get(i);
            if (conversation.isTop()) {
                topConversations.add(conversation);
            } else {
                normalConversations.add(conversation);
            }
        }

        if(topConversations != null && topConversations.size() > 1) {
            Collections.sort(topConversations); // 置顶会话列表页也需要按照最后一条时间排序，由新到旧，如果旧会话收到新消息，会排序到前面
        }
        conversationInfos.addAll(topConversations);
        if(normalConversations != null && normalConversations.size() > 1) {
            Collections.sort(normalConversations); // 正常会话也是按照最后一条消息时间排序，由新到旧
        }
        conversationInfos.addAll(normalConversations);
        return conversationInfos;
    }

    /**
     * 更新会话未读计数
     *
     * @param unreadTotal
     */
    public void updateUnreadTotal(int unreadTotal) {
        TUIKitLog.i(TAG, "updateUnreadTotal:" + unreadTotal);
        mUnreadTotal = unreadTotal;
        for (int i = 0; i < mUnreadWatchers.size(); i++) {
            mUnreadWatchers.get(i).updateUnread(mUnreadTotal);
        }
    }

    /**
     * 获取会话总的未读数
     *
     * @return 未读数量
     */
    public int getUnreadTotal() {
        return mUnreadTotal;
    }

    public boolean isTopConversation(String conversationID) {
        List<ConversationInfo> conversationInfos = mProvider.getDataSource();
        for (int i = 0; i < conversationInfos.size(); i++) {
            ConversationInfo info = conversationInfos.get(i);
            if (info.getId().equals(conversationID)) {
                return info.isTop();
            }
        }
        return false;
    }

    /**
     * 添加未读计数监听器
     *
     * @param messageUnreadWatcher
     */
    public void addUnreadWatcher(MessageUnreadWatcher messageUnreadWatcher) {
        TUIKitLog.i(TAG, "addUnreadWatcher:" + messageUnreadWatcher);
        if (!mUnreadWatchers.contains(messageUnreadWatcher)) {
            mUnreadWatchers.add(messageUnreadWatcher);
            messageUnreadWatcher.updateUnread(mUnreadTotal);
        }
    }

    /**
     * 移除未读计数监听器
     *
     * @param messageUnreadWatcher
     */
    public void removeUnreadWatcher(MessageUnreadWatcher messageUnreadWatcher) {
        TUIKitLog.i(TAG, "removeUnreadWatcher:" + messageUnreadWatcher);
        if (messageUnreadWatcher == null) {
            mUnreadWatchers.clear();
        } else {
            mUnreadWatchers.remove(messageUnreadWatcher);
        }
    }

    /**
     * 与UI做解绑操作，避免内存泄漏
     */
    public void destroyConversation() {
        TUIKitLog.i(TAG, "destroyConversation");
        if (mProvider != null) {
            mProvider.clear();
        }
        if (mUnreadWatchers != null) {
            mUnreadWatchers.clear();
        }
    }

    public String getGroupConversationAvatar(String conversationId) {
        SharedPreferences sp = TUIKit.getAppContext().getSharedPreferences(
                TUIKitConfigs.getConfigs().getGeneralConfig().getSDKAppId() + SP_IMAGE, Context.MODE_PRIVATE);
        final String savedIcon = sp.getString(conversationId, "");
        if (!TextUtils.isEmpty(savedIcon) && new File(savedIcon).isFile() && new File(savedIcon).exists()) {
            return savedIcon;
        }
        return "";
    }

    public void setGroupConversationAvatar(String conversationId, String url) {
        SharedPreferences sp = TUIKit.getAppContext().getSharedPreferences(
                TUIKitConfigs.getConfigs().getGeneralConfig().getSDKAppId() + SP_IMAGE, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        editor.putString(conversationId, url);
        boolean success = editor.commit();
        if (!success) {
            TUIKitLog.e(TAG, "setGroupConversationAvatar failed , id : " + conversationId + " , url : " + url);
        }
    }

    /**
     * 会话未读计数变化监听器
     */
    public interface MessageUnreadWatcher {
        void updateUnread(int count);
    }

}