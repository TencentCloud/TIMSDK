package com.tencent.qcloud.uikit.business.session.model;

import android.content.Context;
import android.content.SharedPreferences;

import com.tencent.qcloud.uikit.common.IUIKitCallBack;
import com.tencent.imsdk.TIMConversation;
import com.tencent.imsdk.TIMConversationType;
import com.tencent.imsdk.TIMElem;
import com.tencent.imsdk.TIMElemType;
import com.tencent.imsdk.TIMGroupSystemElem;
import com.tencent.imsdk.TIMGroupSystemElemType;
import com.tencent.imsdk.TIMMessage;
import com.tencent.imsdk.TIMRefreshListener;
import com.tencent.imsdk.ext.message.TIMConversationExt;
import com.tencent.imsdk.ext.message.TIMManagerExt;
import com.tencent.imsdk.ext.message.TIMMessageLocator;
import com.tencent.imsdk.log.QLog;
import com.tencent.qcloud.uikit.TUIKit;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.business.chat.model.MessageInfoUtil;
import com.tencent.qcloud.uikit.operation.UIKitMessageRevokedManager;
import com.tencent.qcloud.uikit.operation.message.UIKitRequestDispatcher;
import com.tencent.qcloud.uikit.operation.message.UIKitRequestHandler;
import com.tencent.qcloud.uikit.operation.message.UIKitRequest;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Created by valexhuang on 2018/7/17.
 */

public class SessionManager implements UIKitRequestHandler, TIMRefreshListener, UIKitMessageRevokedManager.MessageRevokeHandler {
    private final static String TAG = "SessionManager";
    private final static String TOP_LIST = "top_list";
    private SessionProvider mProvider;
    private List<MessageUnreadWatcher> mUnreadWatchers = new ArrayList<>();
    private SessionStartChat chatStarter;
    private static SessionManager instance = new SessionManager();
    private Set<String> mTopList;
    private SharedPreferences mSessionPreferences;

    private int mUnreadTotal;

    public static SessionManager getInstance() {
        return instance;
    }

    public void init() {
        mSessionPreferences = TUIKit.getAppContext().getSharedPreferences(TAG, Context.MODE_PRIVATE);
        mTopList = mSessionPreferences.getStringSet(TOP_LIST, new HashSet<String>());
        UIKitRequestDispatcher.getInstance().registerHandler(UIKitRequestDispatcher.MODEL_SESSION, this);
        UIKitMessageRevokedManager.getInstance().addHandler(this);
    }

    private SessionManager() {

    }

    /**
     * 加载会话信息
     *
     * @param callBack
     */
    public void loadSession(IUIKitCallBack callBack) {
        mUnreadTotal = 0;
        //mProvider初始化值为null,用户注销时会销毁，登录完成进入需再次实例化
        if (mProvider == null)
            mProvider = new SessionProvider();
        else
            mProvider.clear();
        List<TIMConversation> TIMSessions = TIMManagerExt.getInstance().getConversationList();
        ArrayList<SessionInfo> infos = new ArrayList<>();
        for (int i = 0; i < TIMSessions.size(); i++) {
            TIMConversation conversation = TIMSessions.get(i);
            //将imsdk TIMConversation转换为UIKit SessionInfo
            SessionInfo sessionInfo = TIMConversation2SessionInfo(conversation);
            if (sessionInfo != null) {
                mUnreadTotal = mUnreadTotal + sessionInfo.getUnRead();
                infos.add(sessionInfo);
            }
        }
        //排序，imsdk加载处理的已按时间排序，但应用层有置顶会话操作，所有需根据置顶标识再次排序（置顶可考虑做到imsdk同步到服务器？）
        mProvider.setDataSource(sortSessions(infos));
        //更新消息未读总数
        updateUnreadTotal(mUnreadTotal);
        if (callBack != null)
            callBack.onSuccess(mProvider);
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

        if (mProvider == null)
            return;
        ArrayList<SessionInfo> infos = new ArrayList<>();
        for (int i = 0; i < conversations.size(); i++) {
            TIMConversation conversation = conversations.get(i);
            QLog.i(TAG, "onRefreshConversation::" + conversation);
            SessionInfo sessionInfo = TIMConversation2SessionInfo(conversation);
            if (sessionInfo != null)
                infos.add(sessionInfo);
        }
        if (infos.size() == 0)
            return;
        List<SessionInfo> dataSource = mProvider.getDataSource();
        ArrayList exists = new ArrayList();
        for (int j = 0; j < infos.size(); j++) {
            SessionInfo update = infos.get(j);
            boolean exist = false;
            for (int i = 0; i < dataSource.size(); i++) {
                SessionInfo cacheInfo = dataSource.get(i);
                //单个会话刷新时找到老的会话数据，替换
                if (cacheInfo.getPeer().equals(update.getPeer())) {
                    dataSource.remove(i);
                    dataSource.add(i, update);
                    exists.add(update);
                    //infos.remove(j);
                    //需同步更新未读计数
                    mUnreadTotal = mUnreadTotal - cacheInfo.getUnRead() + update.getUnRead();
                    exist = true;
                    break;
                }
            }
            if (!exist) {
                mUnreadTotal += update.getUnRead();
            }
        }
        updateUnreadTotal(mUnreadTotal);
        infos.removeAll(exists);
        if (infos.size() > 0) {
            dataSource.addAll(infos);
        }
        mProvider.setDataSource(sortSessions(dataSource));
    }

    /**
     * TIMConversation转换为SessionInfo
     *
     * @param session
     * @return
     */
    private SessionInfo TIMConversation2SessionInfo(TIMConversation session) {
        TIMConversationExt ext = new TIMConversationExt(session);
        TIMMessage message = ext.getLastMsg();
        if (message == null)
            return null;
        SessionInfo info = new SessionInfo();
        TIMConversationType type = session.getType();
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
        MessageInfo msg = MessageInfoUtil.TIMMessage2MessageInfo(message, isGroup);
        info.setLastMessage(msg);
        if (isGroup)
            info.setTitle(session.getGroupName());
        else
            info.setTitle(session.getPeer());
        info.setPeer(session.getPeer());
        info.setGroup(session.getType() == TIMConversationType.Group);
        if (ext.getUnreadMessageNum() > 0)
            info.setUnRead((int) ext.getUnreadMessageNum());
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
        if (type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_KICK_OFF_FROM_GROUP_TYPE || type == TIMGroupSystemElemType.TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE) {
            //imsdk会自动删除持久化的数据，应用层只需删除会话数据源中的即可
            deleteSession(groupSysEle.getGroupId());
        }
    }


    /**
     * 将某个会话置顶
     *
     * @param index
     * @param session
     */
    public void setSessionTop(int index, SessionInfo session) {
        if (!session.isTop()) {
            mTopList.add(session.getPeer());
            session.setTop(true);

        } else {
            session.setTop(false);
            mTopList.remove(session.getPeer());
        }
        mSessionPreferences.edit().putStringSet(TOP_LIST, mTopList).commit();
        mProvider.setDataSource(sortSessions(mProvider.getDataSource()));
    }

    /**
     * 会话置顶操作
     *
     * @param peer 会话ID
     * @param flag 是否置顶
     */
    private void setSessionTop(String peer, boolean flag) {
        handleTopData(peer, flag);
        mProvider.setDataSource(sortSessions(mProvider.getDataSource()));

    }

    /**
     * 会话置顶的本地储存操作，目前用SharePreferences来持久化置顶信息
     *
     * @param peer
     * @param flag
     */
    private void handleTopData(String peer, boolean flag) {
        SessionInfo session = null;
        List<SessionInfo> sessionInfos = mProvider.getDataSource();
        for (int i = 0; i < sessionInfos.size(); i++) {
            SessionInfo info = sessionInfos.get(i);
            if (info.getPeer().equals(peer)) {
                session = info;
            }
            break;
        }
        if (session == null)
            return;
        if (flag) {
            if (!mTopList.contains(peer)) {
                mTopList.add(peer);
                session.setTop(true);
            } else {
                return;
            }
        } else {
            if (mTopList.contains(peer)) {
                session.setTop(false);
                mTopList.remove(session.getPeer());
            } else {
                return;
            }
        }
        mSessionPreferences.edit().putStringSet(TOP_LIST, mTopList).commit();
    }

    /**
     * 删除会话，会将本地会话数据从imsdk中删除
     *
     * @param index   在数据源中的索引
     * @param session 会话信息
     */
    public void deleteSession(int index, SessionInfo session) {
        boolean status = TIMManagerExt.getInstance().deleteConversationAndLocalMsgs(session.isGroup() ? TIMConversationType.Group : TIMConversationType.C2C, session.getPeer());
        if (status) {
            handleTopData(session.getPeer(), false);
            mProvider.deleteSession(index);
        }
    }

    /**
     * 删除会话，只删除数据源中的会话信息
     *
     * @param peer 会话id
     */
    public void deleteSession(String peer) {
        handleTopData(peer, false);
        if (mProvider != null)
            mProvider.deleteSession(peer);
    }

    /**
     * 添加会话
     *
     * @param sessionInfo
     * @return
     */
    public boolean addSession(SessionInfo sessionInfo) {
        List<SessionInfo> sessionInfos = new ArrayList<>();
        sessionInfos.add(sessionInfo);
        return mProvider.addSessions(sessionInfos);
    }

    /**
     * 会话数据排序，添加了置顶标识的处理
     *
     * @param sources
     * @return
     */
    private ArrayList<SessionInfo> sortSessions(List<SessionInfo> sources) {
        ArrayList<SessionInfo> sessionInfos = new ArrayList<>();
        List<SessionInfo> topSessions = new ArrayList<>();
        List<SessionInfo> normalSessions = new ArrayList<>();

        for (int i = 0; i < sources.size(); i++) {
            SessionInfo session = sources.get(i);
            if (mTopList.contains(session.getPeer())) {
                session.setTop(true);
                topSessions.add(session);
            } else {
                normalSessions.add(session);
            }

        }
        Collections.sort(topSessions);
        Collections.sort(normalSessions);
        sessionInfos.addAll(topSessions);
        sessionInfos.addAll(normalSessions);
        return sessionInfos;
    }

    /**
     * 更新会话未读计数
     *
     * @param unreadTotal
     */
    public void updateUnreadTotal(int unreadTotal) {
        mUnreadTotal = unreadTotal;
        for (int i = 0; i < mUnreadWatchers.size(); i++) {
            mUnreadWatchers.get(i).updateUnread(mUnreadTotal);
        }
    }

    public boolean isTopSession(String peer) {
        return mTopList.contains(peer);
    }


    /**
     * 处理其它模块的会话处理，在Chat模块中置顶相关操作，已经退群，解散群等操作，需同步更新会话列表
     *
     * @param msg
     * @return
     */
    @Override
    public Object handleRequest(UIKitRequest msg) {
        //获取该会话是否为置顶状态
        if (msg.getAction().equals(UIKitRequestDispatcher.SESSION_ACTION_GET_TOP)) {
            return isTopSession(msg.getRequest().toString());
        }
        //会话置顶操作
        else if (msg.getAction().equals(UIKitRequestDispatcher.SESSION_ACTION_SET_TOP)) {
            Map requestMap = (Map) msg.getRequest();
            setSessionTop(requestMap.get("peer").toString(), (Boolean) requestMap.get("topFlag"));
        }
        //解散、退出群时需删除对应会话
        else if (msg.getAction().equals(UIKitRequestDispatcher.SESSION_DELETE)) {
            deleteSession(msg.getRequest().toString());
        }
        //刷新会话列表，目前C2C消息撤回有用到
        else if (msg.getAction().equals(UIKitRequestDispatcher.SESSION_REFRESH)) {
            loadSession(null);
        }
        //其他模块的会话跳转
        else if (msg.getAction().equals(UIKitRequestDispatcher.SESSION_ACTION_START_CHAT)) {
            SessionInfo sessionInfo = (SessionInfo) msg.getRequest();
            if (sessionInfo != null) {
                if (chatStarter != null)
                    chatStarter.startChat(sessionInfo);
                if (!sessionInfo.isGroup())
                    addSession(sessionInfo);
            }

        }
        return null;
    }

    /**
     * 消息撤销回调
     *
     * @param locator
     */
    @Override
    public void handleInvoke(TIMMessageLocator locator) {
        if (mProvider != null)
            loadSession(null);
    }


    /**
     * 添加未读计数监听器
     *
     * @param messageUnreadWatcher
     */
    public void addUnreadWatcher(MessageUnreadWatcher messageUnreadWatcher) {
        if (!mUnreadWatchers.contains(messageUnreadWatcher))
            mUnreadWatchers.add(messageUnreadWatcher);
    }


    public void addStartChat(SessionStartChat starter) {
        chatStarter = starter;
    }

    /**
     * 销毁会话列表模块，退出登录时调用
     */
    public void destroySession() {
        if (mProvider != null)
            mProvider.clear();
        mProvider = null;
        if (mUnreadWatchers != null)
            mUnreadWatchers.clear();
        mUnreadTotal = 0;
    }


    /**
     * 会话未读计数变化监听器
     */
    public interface MessageUnreadWatcher {
        public void updateUnread(int count);
    }


    /**
     * 会话未读计数变化监听器
     */
    public interface SessionStartChat {
        public void startChat(SessionInfo sessionInfo);
    }
}
