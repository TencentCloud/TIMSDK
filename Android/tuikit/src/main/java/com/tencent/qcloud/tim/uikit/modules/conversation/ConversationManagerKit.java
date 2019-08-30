package com.tencent.qcloud.tim.uikit.modules.conversation;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;

import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMElem;
import com.tencent.imsdk.TIMElemType;
import com.tencent.imsdk.TIMFriendshipManager;
import com.tencent.imsdk.TIMGroupManager;
import com.tencent.imsdk.TIMGroupMemberInfo;
import com.tencent.imsdk.TIMGroupSystemElem;
import com.tencent.imsdk.TIMGroupSystemElemType;
import com.tencent.imsdk.TIMManager;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMRefreshListener;
import com.tencent.imsdk.TIMUserProfile;
import com.tencent.imsdk.TIMValueCallBack;
import com.tencent.imsdk.ext.group.TIMGroupDetailInfo;
import com.tencent.imsdk.ext.message.TIMMessageLocator;
import com.tencent.imsdk.friendship.TIMFriend;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.IUIKitCallBack;
import com.tencent.qcloud.tim.uikit.modules.conversation.base.ConversationInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.modules.message.MessageRevokedManager;
import com.tencent.qcloud.tim.uikit.utils.SharedPreferenceUtils;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

public class ConversationManagerKit implements TIMRefreshListener, MessageRevokedManager.MessageRevokeHandler {

    private final static String TAG = ConversationManagerKit.class.getSimpleName();
    private final static String SP_NAME = "top_conversion_list";
    private final static String TOP_LIST = "top_list";

    private static ConversationManagerKit instance = new ConversationManagerKit();

    private ConversationProvider mProvider;
    private List<MessageUnreadWatcher> mUnreadWatchers = new ArrayList<>();
    private SharedPreferences mConversationPreferences;
    private LinkedList<ConversationInfo> mTopLinkedList = new LinkedList<>();
    private int mUnreadTotal;

    public static ConversationManagerKit getInstance() {
        return instance;
    }

    private void init() {
        TUIKitLog.i(TAG, "init");
        mConversationPreferences = TUIKit.getAppContext().getSharedPreferences(TIMManager.getInstance().getLoginUser() + SP_NAME, Context.MODE_PRIVATE);
        mTopLinkedList = SharedPreferenceUtils.getListData(mConversationPreferences, TOP_LIST, ConversationInfo.class);
        MessageRevokedManager.getInstance().addHandler(this);
    }

    private ConversationManagerKit() {
        init();
    }

    /**
     * 加载会话信息
     *
     * @param callBack
     */
    public void loadConversation(IUIKitCallBack callBack) {
        TUIKitLog.i(TAG, "loadConversation callBack:" + callBack);
        mUnreadTotal = 0;
        //mProvider初始化值为null,用户注销时会销毁，登录完成进入需再次实例化
        if (mProvider == null) {
            mProvider = new ConversationProvider();
        }
        List<TIMConversation> TIMConversations = TIMManager.getInstance().getConversationList();
        ArrayList<ConversationInfo> infos = new ArrayList<>();
        for (int i = 0; i < TIMConversations.size(); i++) {
            TIMConversation conversation = TIMConversations.get(i);
            //将imsdk TIMConversation转换为UIKit ConversationInfo
            ConversationInfo conversationInfo = TIMConversation2ConversationInfo(conversation);
            if (conversationInfo != null) {
                mUnreadTotal = mUnreadTotal + conversationInfo.getUnRead();
                conversationInfo.setType(ConversationInfo.TYPE_COMMON); //
                infos.add(conversationInfo);
            }
        }
        //排序，imsdk加载处理的已按时间排序，但应用层有置顶会话操作，所有需根据置顶标识再次排序（置顶可考虑做到imsdk同步到服务器？）
        mProvider.setDataSource(sortConversations(infos));
        SharedPreferenceUtils.putListData(mConversationPreferences, TOP_LIST, mTopLinkedList);
        //更新消息未读总数
        updateUnreadTotal(mUnreadTotal);
        if (callBack != null) {
            callBack.onSuccess(mProvider);
        }
    }

    /**
     * 数据刷新通知回调（如未读计数，会话列表等）
     */
    @Override
    public void onRefresh() {

    }


    /**
     * 部分会话刷新（包括多终端已读上报同步）
     *
     * @param conversations 需要刷新的会话列表
     */
    @Override
    public void onRefreshConversation(List<TIMConversation> conversations) {
        TUIKitLog.i(TAG, "onRefreshConversation conversations:" + conversations);
        if (mProvider == null) {
            return;
        }
        ArrayList<ConversationInfo> infos = new ArrayList<>();
        for (int i = 0; i < conversations.size(); i++) {
            TIMConversation conversation = conversations.get(i);
            TUIKitLog.i(TAG, "onRefreshConversation TIMConversation " + conversation.toString());
            ConversationInfo conversationInfo = TIMConversation2ConversationInfo(conversation);
            if (conversation.getType() == TIMConversationType.System) {
                TIMMessage message = conversation.getLastMsg();
                if (message.getElementCount() > 0) {
                    TIMElem ele = message.getElement(0);
                    TIMElemType eleType = ele.getType();
                    if (eleType == TIMElemType.GroupSystem) {
                        TIMGroupSystemElem groupSysEle = (TIMGroupSystemElem) ele;
                        if (groupSysEle.getSubtype() == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_INVITED_TO_GROUP_TYPE) {
                            String group = conversation.getGroupName();
                            if (TextUtils.isEmpty(group)) {
                                group = groupSysEle.getGroupId();
                            }
                            ToastUtil.toastLongMessage("您已经被邀请进群【" + group + "】，请到我的群聊里面查看！");
                        }
                    }
                }
            }
            if (conversationInfo != null) {
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
            boolean exist = false;
            for (int i = 0; i < dataSource.size(); i++) {
                ConversationInfo cacheInfo = dataSource.get(i);
                //单个会话刷新时找到老的会话数据，替换
                if (cacheInfo.getId().equals(update.getId())) {
                    dataSource.remove(i);
                    dataSource.add(i, update);
                    exists.add(update);
                    //infos.remove(j);
                    //需同步更新未读计数
                    mUnreadTotal = mUnreadTotal - cacheInfo.getUnRead() + update.getUnRead();
                    TUIKitLog.i(TAG, "onRefreshConversation after mUnreadTotal = " + mUnreadTotal);
                    exist = true;
                    break;
                }
            }
            if (!exist) {
                mUnreadTotal += update.getUnRead();
                TUIKitLog.i(TAG, "onRefreshConversation exist = " + exist + ", mUnreadTotal = " + mUnreadTotal);
            }
        }
        updateUnreadTotal(mUnreadTotal);
        infos.removeAll(exists);
        if (infos.size() > 0) {
            dataSource.addAll(infos);
        }
        mProvider.setDataSource(sortConversations(dataSource));
        SharedPreferenceUtils.putListData(mConversationPreferences, TOP_LIST, mTopLinkedList);
    }

    /**
     * TIMConversation转换为ConversationInfo
     *
     * @param conversation
     * @return
     */
    private ConversationInfo TIMConversation2ConversationInfo(final TIMConversation conversation) {
        if (conversation == null) {
            return null;
        }
        TUIKitLog.i(TAG, "loadConversation conversation peer " + conversation.getPeer() + ", groupName " + conversation.getGroupName());
        TIMMessage message = conversation.getLastMsg();
        if (message == null) {
            return null;
        }
        final ConversationInfo info = new ConversationInfo();
        TIMConversationType type = conversation.getType();
        if (type == TIMConversationType.System) {
            if (message.getElementCount() > 0) {
                TIMElem ele = message.getElement(0);
                TIMElemType eleType = ele.getType();
                if (eleType == TIMElemType.GroupSystem) {
                    TIMGroupSystemElem groupSysEle = (TIMGroupSystemElem) ele;
                    groupSystMsgHandle(groupSysEle);
                }
            }
            return null;
        }

        boolean isGroup = type == TIMConversationType.Group;
        info.setLastMessageTime(message.timestamp() * 1000);
        List<MessageInfo> list = MessageInfoUtil.TIMMessage2MessageInfo(message, isGroup);
        if (list != null && list.size() > 0) {
            info.setLastMessage(list.get(list.size() - 1));
        }
        if (isGroup) {
            info.setTitle(conversation.getGroupName());
            TIMGroupDetailInfo groupDetailInfo = TIMGroupManager.getInstance().queryGroupInfo(conversation.getPeer());
            if (groupDetailInfo != null && !TextUtils.isEmpty(groupDetailInfo.getFaceUrl())) {
                info.setIconUrl(groupDetailInfo.getFaceUrl());
            }
        } else {
            String title = conversation.getPeer();
            String faceUrl = null;
            final ArrayList<String> ids = new ArrayList<>();
            ids.add(conversation.getPeer());
            TIMUserProfile profile = TIMFriendshipManager.getInstance().queryUserProfile(conversation.getPeer());
            if (profile == null) {
                TIMFriendshipManager.getInstance().getUsersProfile(ids, false, new TIMValueCallBack<List<TIMUserProfile>>() {
                    @Override
                    public void onError(int code, String desc) {
                        TUIKitLog.e(TAG, "getUsersProfile failed! code: " + code + " desc: " + desc);
                    }

                    @Override
                    public void onSuccess(List<TIMUserProfile> timUserProfiles) {
                        if (timUserProfiles == null || timUserProfiles.size() != 1) {
                            TUIKitLog.i(TAG, "No TIMUserProfile");
                            return;
                        }
                        TIMUserProfile profile = timUserProfiles.get(0);
                        String faceUrl = null;
                        if (profile != null && !TextUtils.isEmpty(profile.getFaceUrl())) {
                            faceUrl = profile.getFaceUrl();
                        }
                        String title = conversation.getPeer();
                        if (profile != null && !TextUtils.isEmpty(profile.getNickName())) {
                            title = profile.getNickName();
                        }
                        info.setTitle(title);
                        info.setIconUrl(faceUrl);
                        mProvider.updateAdapter();
                    }
                });
            } else {
                if (!TextUtils.isEmpty(profile.getNickName())) {
                    title = profile.getNickName();
                }
                if (!TextUtils.isEmpty(profile.getFaceUrl())) {
                    faceUrl = profile.getFaceUrl();
                }
                info.setTitle(title);
                info.setIconUrl(faceUrl);
            }

            TIMFriend friend = TIMFriendshipManager.getInstance().queryFriend(conversation.getPeer());
            if (friend == null) {
                TIMFriendshipManager.getInstance().getFriendList(new TIMValueCallBack<List<TIMFriend>>() {
                    @Override
                    public void onError(int code, String desc) {
                        TUIKitLog.e(TAG, "getFriendList failed! code: " + code + " desc: " + desc);
                    }

                    @Override
                    public void onSuccess(List<TIMFriend> timFriends) {
                        String remark = "";
                        if (timFriends == null || timFriends.size() == 0) {
                            TUIKitLog.i(TAG, "No Friends");
                            return;
                        }
                        for (TIMFriend friend : timFriends) {
                            if (TextUtils.equals(conversation.getPeer(), friend.getIdentifier())) {
                                if (!TextUtils.isEmpty(friend.getRemark())) {
                                    info.setTitle(friend.getRemark());
                                }
                                info.setTitle(remark);
                                mProvider.updateAdapter();
                                return;
                            }
                        }
                        TUIKitLog.i(TAG, conversation.getPeer() + " is not my friend");
                    }
                });
            } else {
                if (!TextUtils.isEmpty(friend.getRemark())) {
                    title = friend.getRemark();
                    info.setTitle(title);
                }
            }
        }
        info.setId(conversation.getPeer());
        info.setGroup(conversation.getType() == TIMConversationType.Group);
        if (conversation.getUnreadMessageNum() > 0) {
            info.setUnRead((int) conversation.getUnreadMessageNum());
        }
        TUIKitLog.i(TAG, "onRefreshConversation ext.getUnreadMessageNum() " + conversation.getUnreadMessageNum());
        return info;
    }


    /**
     * 群系统消息处理，不需要显示信息的
     *
     * @param groupSysEle
     */
    private void groupSystMsgHandle(TIMGroupSystemElem groupSysEle) {
        TIMGroupSystemElemType type = groupSysEle.getSubtype();
        //群组解散或者被踢出群组
        if (type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_KICK_OFF_FROM_GROUP_TYPE
                || type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE) {
            //imsdk会自动删除持久化的数据，应用层只需删除会话数据源中的即可
            deleteConversation(groupSysEle.getGroupId(), true);
        }
    }


    /**
     * 将某个会话置顶
     *
     * @param index
     * @param conversation
     */
    public void setConversationTop(int index, ConversationInfo conversation) {
        TUIKitLog.i(TAG, "setConversationTop index:" + index + "|conversation:" + conversation);
        if (!conversation.isTop()) {
            mTopLinkedList.remove(conversation);
            mTopLinkedList.addFirst(conversation);
            conversation.setTop(true);
        } else {
            conversation.setTop(false);
            mTopLinkedList.remove(conversation);
        }
        mProvider.setDataSource(sortConversations(mProvider.getDataSource()));
        SharedPreferenceUtils.putListData(mConversationPreferences, TOP_LIST, mTopLinkedList);
    }

    /**
     * 会话置顶操作
     *
     * @param id   会话ID
     * @param flag 是否置顶
     */
    public void setConversationTop(String id, boolean flag) {
        TUIKitLog.i(TAG, "setConversationTop id:" + id + "|flag:" + flag);
        handleTopData(id, flag);
        mProvider.setDataSource(sortConversations(mProvider.getDataSource()));
        SharedPreferenceUtils.putListData(mConversationPreferences, TOP_LIST, mTopLinkedList);
    }

    private boolean isTop(String id) {
        if (mTopLinkedList == null || mTopLinkedList.size() == 0) {
            return false;
        }
        for (ConversationInfo info : mTopLinkedList) {
            if (TextUtils.equals(info.getId(), id)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 会话置顶的本地储存操作，目前用SharePreferences来持久化置顶信息
     *
     * @param id
     * @param flag
     */
    private void handleTopData(String id, boolean flag) {
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
        if (flag) {
            if (!isTop(conversation.getId())) {
                mTopLinkedList.remove(conversation);
                mTopLinkedList.addFirst(conversation);
                conversation.setTop(true);
            } else {
                return;
            }
        } else {
            if (isTop(conversation.getId())) {
                conversation.setTop(false);
                mTopLinkedList.remove(conversation);
            } else {
                return;
            }
        }
        SharedPreferenceUtils.putListData(mConversationPreferences, TOP_LIST, mTopLinkedList);
    }

    /**
     * 删除会话，会将本地会话数据从imsdk中删除
     *
     * @param index        在数据源中的索引
     * @param conversation 会话信息
     */
    public void deleteConversation(int index, ConversationInfo conversation) {
        TUIKitLog.i(TAG, "deleteConversation index:" + index + "|conversation:" + conversation);
        boolean status = TIMManager.getInstance().deleteConversation(conversation.isGroup() ? TIMConversationType.Group : TIMConversationType.C2C, conversation.getId());
        if (status) {
            handleTopData(conversation.getId(), false);
            mProvider.deleteConversation(index);
            updateUnreadTotal(mUnreadTotal - conversation.getUnRead());
        }
    }

    /**
     * 删除会话，只删除数据源中的会话信息
     *
     * @param id 会话id
     */
    public void deleteConversation(String id, boolean isGroup) {
        TUIKitLog.i(TAG, "deleteConversation id:" + id + "|isGroup:" + isGroup);
        handleTopData(id, false);
        List<ConversationInfo> conversationInfos = mProvider.getDataSource();
        for (int i = 0; i < conversationInfos.size(); i++) {
            ConversationInfo info = conversationInfos.get(i);
            if (info.getId().equals(id)) {
                updateUnreadTotal(mUnreadTotal - info.getUnRead());
                break;
            }
        }
        if (mProvider != null) {
            mProvider.deleteConversation(id);
        }
        TIMManager.getInstance().deleteConversation(isGroup ? TIMConversationType.Group : TIMConversationType.C2C, id);
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
            if (isTop(conversation.getId())) {
                conversation.setTop(true);
                topConversations.add(conversation);
            } else {
                normalConversations.add(conversation);
            }
        }

        mTopLinkedList.clear();
        mTopLinkedList.addAll(topConversations);
        Collections.sort(topConversations); // 置顶会话列表页也需要按照最后一条时间排序，由新到旧，如果旧会话收到新消息，会排序到前面
        conversationInfos.addAll(topConversations);
        Collections.sort(normalConversations); // 正常会话也是按照最后一条消息时间排序，由新到旧
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

    public boolean isTopConversation(String groupId) {
        TUIKitLog.i(TAG, "isTopConversation:" + groupId);
        return isTop(groupId);
    }

    /**
     * 消息撤回回调
     *
     * @param locator
     */
    @Override
    public void handleInvoke(TIMMessageLocator locator) {
        TUIKitLog.i(TAG, "handleInvoke:" + locator);
        if (mProvider != null) {
            loadConversation(null);
        }
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
        }
    }


    /**
     * 销毁会话列表模块，退出登录时调用
     */
    public void destroyConversation() {
        TUIKitLog.i(TAG, "destroyConversation");
        if (mProvider != null) {
            mProvider.clear();
        }
        mProvider = null;
        if (mUnreadWatchers != null) {
            mUnreadWatchers.clear();
        }
        mUnreadTotal = 0;
    }


    /**
     * 会话未读计数变化监听器
     */
    public interface MessageUnreadWatcher {
        void updateUnread(int count);
    }

}