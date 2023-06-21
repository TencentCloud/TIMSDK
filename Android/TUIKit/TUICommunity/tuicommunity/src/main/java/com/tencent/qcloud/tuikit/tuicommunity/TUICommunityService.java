package com.tencent.qcloud.tuikit.tuicommunity;

import android.content.Context;
import android.content.Intent;
import android.text.TextUtils;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMTopicInfo;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUILoginListener;
import com.tencent.qcloud.tuikit.tuicommunity.bean.CommunityChangeBean;
import com.tencent.qcloud.tuikit.tuicommunity.bean.TopicBean;
import com.tencent.qcloud.tuikit.tuicommunity.interfaces.CommunityEventListener;
import com.tencent.qcloud.tuikit.tuicommunity.ui.page.TopicInfoActivity;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityParser;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityUtil;
import com.tencent.qcloud.tuikit.tuicommunity.utils.TUICommunityLog;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class TUICommunityService extends ServiceInitializer implements ITUINotification, ITUIExtension {
    private static final String TAG = TUICommunityService.class.getSimpleName();
    private static TUICommunityService instance;

    public static TUICommunityService getInstance() {
        return instance;
    }

    private final List<WeakReference<CommunityEventListener>> communityEventList = new ArrayList<>();

    @Override
    public void init(Context context) {
        instance = this;
        initEvent();
        initExtension();
        initSdkListener();
    }

    private void initEvent() {
        TUICore.registerEvent(TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT, TUIConstants.TUIChat.EVENT_SUB_KEY_SEND_MESSAGE_SUCCESS, this);
        TUICore.registerEvent(TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT, TUIConstants.TUIChat.EVENT_SUB_KEY_REPLY_MESSAGE_SUCCESS, this);
        TUICore.registerEvent(TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE, TUIConstants.TUICommunity.EVENT_SUB_KEY_CREATE_COMMUNITY, this);
        TUICore.registerEvent(TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE, TUIConstants.TUICommunity.EVENT_SUB_KEY_ADD_COMMUNITY, this);
        TUICore.registerEvent(TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE, TUIConstants.TUICommunity.EVENT_SUB_KEY_DISBAND_COMMUNITY, this);
        TUICore.registerEvent(TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE, TUIConstants.TUICommunity.EVENT_SUB_KEY_CREATE_TOPIC, this);
        TUICore.registerEvent(TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE, TUIConstants.TUICommunity.EVENT_SUB_KEY_DELETE_TOPIC, this);
        TUICore.registerEvent(TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_INFO_UPDATED, this);
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID, this);
    }

    private void initSdkListener() {
        TUILogin.addLoginListener(new TUILoginListener() {
            @Override
            public void onConnecting() {
                List<CommunityEventListener> listeners = getCommunityEventListenerList();
                for (CommunityEventListener communityEventListener : listeners) {
                    communityEventListener.onNetworkStateChanged(CommunityConstants.COMMUNITY_NETWORK_STATE_CONNECTING);
                }
            }

            @Override
            public void onConnectSuccess() {
                List<CommunityEventListener> listeners = getCommunityEventListenerList();
                for (CommunityEventListener communityEventListener : listeners) {
                    communityEventListener.onNetworkStateChanged(CommunityConstants.COMMUNITY_NETWORK_STATE_CONNECTED);
                }
            }

            @Override
            public void onConnectFailed(int code, String error) {
                List<CommunityEventListener> listeners = getCommunityEventListenerList();
                for (CommunityEventListener communityEventListener : listeners) {
                    communityEventListener.onNetworkStateChanged(CommunityConstants.COMMUNITY_NETWORK_STATE_CONNECT_FAILED);
                }
            }
        });

        V2TIMManager.getInstance().addGroupListener(new V2TIMGroupListener() {
            @Override
            public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
                if (CommunityUtil.isCommunityGroup(groupID)) {
                    String selfID = V2TIMManager.getInstance().getLoginUser();
                    for (V2TIMGroupMemberInfo memberInfo : memberList) {
                        if (TextUtils.equals(memberInfo.getUserID(), selfID)) {
                            List<CommunityEventListener> listeners = getCommunityEventListenerList();
                            for (CommunityEventListener communityEventListener : listeners) {
                                communityEventListener.onJoinedCommunity(groupID);
                            }
                            break;
                        }
                    }
                }
            }

            @Override
            public void onGroupCreated(String groupID) {
                if (CommunityUtil.isCommunityGroup(groupID)) {
                    List<CommunityEventListener> listeners = getCommunityEventListenerList();
                    for (CommunityEventListener communityEventListener : listeners) {
                        communityEventListener.onCommunityCreated(groupID);
                    }
                }
            }

            @Override
            public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
                if (CommunityUtil.isCommunityGroup(groupID)) {
                    List<CommunityEventListener> listeners = getCommunityEventListenerList();
                    for (CommunityEventListener communityEventListener : listeners) {
                        communityEventListener.onCommunityDeleted(groupID);
                    }
                }
            }

            @Override
            public void onGroupRecycled(String groupID, V2TIMGroupMemberInfo opUser) {
                if (CommunityUtil.isCommunityGroup(groupID)) {
                    List<CommunityEventListener> listeners = getCommunityEventListenerList();
                    for (CommunityEventListener communityEventListener : listeners) {
                        communityEventListener.onCommunityDeleted(groupID);
                    }
                }
            }

            @Override
            public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
                if (CommunityUtil.isCommunityGroup(groupID)) {
                    TUICommunityLog.i(TAG, "onGroupInfoChanged groupID = " + groupID);
                    List<CommunityEventListener> listeners = getCommunityEventListenerList();
                    List<CommunityChangeBean> communityChangeBeans = new ArrayList<>();
                    for (V2TIMGroupChangeInfo v2TIMGroupChangeInfo : changeInfos) {
                        CommunityChangeBean communityChangeBean = new CommunityChangeBean();
                        communityChangeBean.setV2TIMGroupChangeInfo(v2TIMGroupChangeInfo);
                        communityChangeBeans.add(communityChangeBean);
                    }

                    for (CommunityEventListener communityEventListener : listeners) {
                        communityEventListener.onCommunityInfoChanged(groupID, communityChangeBeans);
                    }
                }
            }

            @Override
            public void onQuitFromGroup(String groupID) {
                if (CommunityUtil.isCommunityGroup(groupID)) {
                    List<CommunityEventListener> listeners = getCommunityEventListenerList();
                    for (CommunityEventListener communityEventListener : listeners) {
                        communityEventListener.onCommunityDeleted(groupID);
                    }
                }
            }

            @Override
            public void onMemberKicked(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                if (CommunityUtil.isCommunityGroup(groupID)) {
                    String selfID = V2TIMManager.getInstance().getLoginUser();
                    for (V2TIMGroupMemberInfo memberInfo : memberList) {
                        if (TextUtils.equals(memberInfo.getUserID(), selfID)) {
                            List<CommunityEventListener> listeners = getCommunityEventListenerList();
                            for (CommunityEventListener communityEventListener : listeners) {
                                communityEventListener.onCommunityDeleted(groupID);
                            }
                            break;
                        }
                    }
                }
            }

            @Override
            public void onGroupAttributeChanged(String groupID, Map<String, String> groupAttributeMap) {
                if (CommunityUtil.isCommunityGroup(groupID)) {
                    TUICommunityLog.i(TAG, "onGroupAttributeChanged groupID = " + groupID);
                    List<CommunityEventListener> listeners = getCommunityEventListenerList();
                    for (CommunityEventListener communityEventListener : listeners) {
                        communityEventListener.onGroupAttrChanged(groupID, groupAttributeMap);
                    }
                }
            }

            @Override
            public void onTopicCreated(String groupID, String topicID) {
                List<CommunityEventListener> listeners = getCommunityEventListenerList();
                for (CommunityEventListener communityEventListener : listeners) {
                    communityEventListener.onTopicCreated(groupID, topicID);
                }
            }

            @Override
            public void onTopicDeleted(String groupID, List<String> topicIDList) {
                List<CommunityEventListener> listeners = getCommunityEventListenerList();
                for (CommunityEventListener communityEventListener : listeners) {
                    communityEventListener.onTopicDeleted(groupID, topicIDList);
                }
                for (String topicID : topicIDList) {
                    HashMap<String, Object> param = new HashMap<>();
                    param.put(TUIConstants.TUIGroup.GROUP_ID, topicID);
                    TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_DISMISS, param);
                }
            }

            @Override
            public void onTopicInfoChanged(String groupID, V2TIMTopicInfo topicInfo) {
                List<CommunityEventListener> listeners = getCommunityEventListenerList();
                for (CommunityEventListener communityEventListener : listeners) {
                    TopicBean topicBean = CommunityParser.parseTopicBean(topicInfo);
                    communityEventListener.onTopicChanged(groupID, topicBean);
                }
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIGroup.GROUP_ID, topicInfo.getTopicID());
                param.put(TUIConstants.TUIGroup.GROUP_NAME, topicInfo.getTopicName());
                TUICore.notifyEvent(TUIConstants.TUIGroup.EVENT_GROUP, TUIConstants.TUIGroup.EVENT_SUB_KEY_GROUP_INFO_CHANGED, param);
            }
        });
    }

    public List<CommunityEventListener> getCommunityEventListenerList() {
        List<CommunityEventListener> listeners = new ArrayList<>();
        Iterator<WeakReference<CommunityEventListener>> iterator = communityEventList.listIterator();
        while (iterator.hasNext()) {
            WeakReference<CommunityEventListener> listenerWeakReference = iterator.next();
            CommunityEventListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    public void addCommunityEventListener(CommunityEventListener communityListener) {
        if (communityListener == null) {
            return;
        }
        for (WeakReference<CommunityEventListener> listenerWeakReference : communityEventList) {
            if (listenerWeakReference.get() == communityListener) {
                return;
            }
        }
        communityEventList.add(new WeakReference<>(communityListener));
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (TextUtils.equals(key, TUIConstants.TUIChat.EVENT_KEY_MESSAGE_EVENT)) {
            String experienceName = null;
            if (param != null && !param.isEmpty()) {
                String chatId = (String) param.get(TUIConstants.TUIChat.CHAT_ID);
                if (CommunityUtil.isTopicGroup(chatId)) {
                    if (TextUtils.equals(subKey, TUIConstants.TUIChat.EVENT_SUB_KEY_SEND_MESSAGE_SUCCESS)) {
                        experienceName = CommunityConstants.COMMUNITY_EXPERIENCE_SEND_MESSAGE_IN_TOPIC_KEY;
                    } else if (TextUtils.equals(subKey, TUIConstants.TUIChat.EVENT_SUB_KEY_REPLY_MESSAGE_SUCCESS)) {
                        experienceName = CommunityConstants.COMMUNITY_EXPERIENCE_REPLY_MESSAGE_IN_TOPIC_KEY;
                    }
                }
            }
            if (!TextUtils.isEmpty(experienceName)) {
                List<CommunityEventListener> listeners = getCommunityEventListenerList();
                for (CommunityEventListener communityEventListener : listeners) {
                    communityEventListener.onCommunityExperienceChanged(experienceName);
                }
            }
        } else if (TextUtils.equals(key, TUIConstants.TUICommunity.EVENT_KEY_COMMUNITY_EXPERIENCE)) {
            String experienceName = null;
            if (TextUtils.equals(subKey, TUIConstants.TUICommunity.EVENT_SUB_KEY_CREATE_COMMUNITY)) {
                experienceName = CommunityConstants.COMMUNITY_EXPERIENCE_CREATE_COMMUNITY_KEY;
            } else if (TextUtils.equals(subKey, TUIConstants.TUICommunity.EVENT_SUB_KEY_ADD_COMMUNITY)) {
                experienceName = CommunityConstants.COMMUNITY_EXPERIENCE_ADD_COMMUNITY_KEY;
            } else if (TextUtils.equals(subKey, TUIConstants.TUICommunity.EVENT_SUB_KEY_DISBAND_COMMUNITY)) {
                experienceName = CommunityConstants.COMMUNITY_EXPERIENCE_DISBAND_COMMUNITY_KEY;
            } else if (TextUtils.equals(subKey, TUIConstants.TUICommunity.EVENT_SUB_KEY_CREATE_TOPIC)) {
                experienceName = CommunityConstants.COMMUNITY_EXPERIENCE_CREATE_TOPIC_KEY;
            } else if (TextUtils.equals(subKey, TUIConstants.TUICommunity.EVENT_SUB_KEY_DELETE_TOPIC)) {
                experienceName = CommunityConstants.COMMUNITY_EXPERIENCE_DELETE_TOPIC_KEY;
            }
            if (!TextUtils.isEmpty(experienceName)) {
                List<CommunityEventListener> listeners = getCommunityEventListenerList();
                for (CommunityEventListener communityEventListener : listeners) {
                    communityEventListener.onCommunityExperienceChanged(experienceName);
                }
            }
        } else if (TextUtils.equals(key, TUIConstants.TUILogin.EVENT_LOGIN_STATE_CHANGED)) {
            if (TextUtils.equals(subKey, TUIConstants.TUILogin.EVENT_SUB_KEY_USER_INFO_UPDATED)) {
                if (param != null) {
                    String faceUrl = (String) param.get(TUIConstants.TUILogin.SELF_FACE_URL);
                    List<CommunityEventListener> listeners = getCommunityEventListenerList();
                    for (CommunityEventListener communityEventListener : listeners) {
                        communityEventListener.onSelfFaceChanged(faceUrl);
                    }
                }
            }
        }
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID)) {
            Object topicID = param.get(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.TOPIC_ID);
            if (topicID instanceof String) {
                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                extensionInfo.setIcon(R.drawable.community_chat_extension_title_bar_more_menu_light);
                extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                    @Override
                    public void onClicked(Map<String, Object> param) {
                        Intent intent = new Intent(getAppContext(), TopicInfoActivity.class);
                        intent.putExtra(TUIConstants.TUICommunity.TOPIC_ID, (String) topicID);
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        getAppContext().startActivity(intent);
                    }
                });
                return Collections.singletonList(extensionInfo);
            }
        }
        return null;
    }
}
