package com.tencent.qcloud.tuikit.tuicontact;

import android.content.Context;

import com.google.auto.service.AutoService;
import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerDependency;
import com.tencent.qcloud.tuicore.annotations.TUIInitializerID;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.interfaces.ITUIService;
import com.tencent.qcloud.tuicore.interfaces.TUIInitializer;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.ContactEventListener;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.GroupEventListener;
import com.tencent.qcloud.tuikit.tuicontact.util.ContactUtils;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@AutoService(TUIInitializer.class)
@TUIInitializerDependency("TIMCommon")
@TUIInitializerID("TUIContact")
public class TUIContactService implements TUIInitializer, ITUIService, ITUINotification {
    public static final String TAG = TUIContactService.class.getSimpleName();

    private static TUIContactService instance;

    public static TUIContactService getInstance() {
        return instance;
    }

    private final List<WeakReference<ContactEventListener>> contactEventListenerList = new ArrayList<>();
    private final List<WeakReference<GroupEventListener>> groupEventListenerList = new ArrayList<>();

    @Override
    public void init(Context context) {
        instance = this;
        initTheme();
        initService();
        initEvent();
        initIMListener();
    }

    @Override
    public Object onCall(String method, Map<String, Object> param) {
        return null;
    }

    private void initService() {
        TUICore.registerService(TUIConstants.TUIContact.SERVICE_NAME, this);
    }

    private void initEvent() {
        TUICore.registerEvent(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED, TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED, this);
    }

    @Override
    public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
        if (key.equals(TUIConstants.TUIContact.EVENT_FRIEND_INFO_CHANGED)) {
            if (subKey.equals(TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_REMARK_CHANGED)) {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                if (param == null || param.isEmpty()) {
                    return;
                }
                String id = (String) param.get(TUIConstants.TUIContact.FRIEND_ID);
                String remark = (String) param.get(TUIConstants.TUIContact.FRIEND_REMARK);
                for (ContactEventListener contactEventListener : contactEventListenerList) {
                    contactEventListener.onFriendRemarkChanged(id, remark);
                }
            }
        }
    }

    private void initIMListener() {
        V2TIMManager.getFriendshipManager().addFriendListener(new V2TIMFriendshipListener() {
            @Override
            public void onFriendApplicationListAdded(List<V2TIMFriendApplication> applicationList) {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                List<FriendApplicationBean> friendApplicationBeanList = new ArrayList<>();
                for (V2TIMFriendApplication v2TIMFriendApplication : applicationList) {
                    FriendApplicationBean friendApplicationBean = new FriendApplicationBean();
                    friendApplicationBean.convertFromTimFriendApplication(v2TIMFriendApplication);
                    friendApplicationBeanList.add(friendApplicationBean);
                }
                for (ContactEventListener contactEventListener : contactEventListenerList) {
                    contactEventListener.onFriendApplicationListAdded(friendApplicationBeanList);
                }
            }

            @Override
            public void onFriendApplicationListDeleted(List<String> userIDList) {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                for (ContactEventListener contactEventListener : contactEventListenerList) {
                    contactEventListener.onFriendApplicationListDeleted(userIDList);
                }
            }

            @Override
            public void onFriendApplicationListRead() {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                for (ContactEventListener contactEventListener : contactEventListenerList) {
                    contactEventListener.onFriendApplicationListRead();
                }
            }

            @Override
            public void onFriendListAdded(List<V2TIMFriendInfo> users) {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                List<ContactItemBean> contactItemBeanList = new ArrayList<>();
                for (V2TIMFriendInfo v2TIMFriendInfo : users) {
                    ContactItemBean contactItemBean = new ContactItemBean();
                    contactItemBean.setFriend(true);
                    contactItemBean.covertTIMFriend(v2TIMFriendInfo);
                    contactItemBeanList.add(contactItemBean);
                }
                for (ContactEventListener contactEventListener : contactEventListenerList) {
                    contactEventListener.onFriendListAdded(contactItemBeanList);
                }
            }

            @Override
            public void onFriendListDeleted(List<String> userList) {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                for (ContactEventListener contactEventListener : contactEventListenerList) {
                    contactEventListener.onFriendListDeleted(userList);
                }
                HashMap<String, Object> bundle = new HashMap<>();
                bundle.put(TUIConstants.TUIContact.FRIEND_ID_LIST, new ArrayList<>(userList));
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_FRIEND_STATE_CHANGED, TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_DELETE, bundle);
            }

            @Override
            public void onBlackListAdd(List<V2TIMFriendInfo> infoList) {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                List<ContactItemBean> contactItemBeanList = new ArrayList<>();
                for (V2TIMFriendInfo v2TIMFriendInfo : infoList) {
                    ContactItemBean contactItemBean = new ContactItemBean();
                    contactItemBean.covertTIMFriend(v2TIMFriendInfo);
                    contactItemBeanList.add(contactItemBean);
                }
                for (ContactEventListener contactEventListener : contactEventListenerList) {
                    contactEventListener.onBlackListAdd(contactItemBeanList);
                }
            }

            @Override
            public void onBlackListDeleted(List<String> userList) {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                for (ContactEventListener contactEventListener : contactEventListenerList) {
                    contactEventListener.onBlackListDeleted(userList);
                }
            }

            @Override
            public void onFriendInfoChanged(List<V2TIMFriendInfo> infoList) {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                List<ContactItemBean> contactItemBeanList = new ArrayList<>();
                for (V2TIMFriendInfo v2TIMFriendInfo : infoList) {
                    ContactItemBean contactItemBean = new ContactItemBean();
                    contactItemBean.setFriend(true);
                    contactItemBean.covertTIMFriend(v2TIMFriendInfo);
                    contactItemBeanList.add(contactItemBean);
                }
                for (ContactEventListener contactEventListener : contactEventListenerList) {
                    contactEventListener.onFriendInfoChanged(contactItemBeanList);
                }
            }
        });

        V2TIMSDKListener v2TIMSDKListener = new V2TIMSDKListener() {
            @Override
            public void onUserStatusChanged(List<V2TIMUserStatus> userStatusList) {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                for (ContactEventListener contactEventListener : contactEventListenerList) {
                    contactEventListener.onUserStatusChanged(userStatusList);
                }
            }
        };
        V2TIMManager.getInstance().addIMSDKListener(v2TIMSDKListener);

        V2TIMManager.getInstance().addGroupListener(new V2TIMGroupListener() {

            @Override
            public void onAllGroupMembersMuted(String groupID, boolean isMute) {
                super.onAllGroupMembersMuted(groupID, isMute);
            }

            @Override
            public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.GROUP_ID, groupID);
                ArrayList<String> userIds = new ArrayList<>();
                for (V2TIMGroupMemberInfo memberInfo : memberList) {
                    userIds.add(memberInfo.getUserID());
                }
                param.put(TUIConstants.TUIContact.GROUP_MEMBER_ID_LIST, userIds);
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_GROUP, TUIConstants.TUIContact.EVENT_SUB_KEY_JOIN_GROUP, param);

                List<GroupEventListener> groupEventListeners = getGroupEventListenerList();
                for (GroupEventListener groupEventListener : groupEventListeners) {
                    groupEventListener.onGroupMemberCountChanged(groupID);
                }
            }

            @Override
            public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
                super.onMemberLeave(groupID, member);
                List<GroupEventListener> groupEventListeners = getGroupEventListenerList();
                for (GroupEventListener groupEventListener : groupEventListeners) {
                    groupEventListener.onGroupMemberCountChanged(groupID);
                }
            }

            @Override
            public void onMemberInvited(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.GROUP_ID, groupID);
                ArrayList<String> userIds = new ArrayList<>();
                for (V2TIMGroupMemberInfo memberInfo : memberList) {
                    userIds.add(memberInfo.getUserID());
                }
                param.put(TUIConstants.TUIContact.GROUP_MEMBER_ID_LIST, userIds);
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_GROUP, TUIConstants.TUIContact.EVENT_SUB_KEY_INVITED_GROUP, param);

                List<GroupEventListener> groupEventListeners = getGroupEventListenerList();
                for (GroupEventListener groupEventListener : groupEventListeners) {
                    groupEventListener.onGroupMemberCountChanged(groupID);
                }
            }

            @Override
            public void onMemberKicked(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.GROUP_ID, groupID);
                ArrayList<String> userIds = new ArrayList<>();
                for (V2TIMGroupMemberInfo memberInfo : memberList) {
                    userIds.add(memberInfo.getUserID());
                }
                param.put(TUIConstants.TUIContact.GROUP_MEMBER_ID_LIST, userIds);
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_GROUP, TUIConstants.TUIContact.EVENT_SUB_KEY_MEMBER_KICKED_GROUP, param);
                if (userIds.contains(TUILogin.getLoginUser())) {
                    ContactUtils.toastGroupEvent(ContactUtils.GROUP_EVENT_TIP_KICKED, groupID);
                }
                List<GroupEventListener> groupEventListeners = getGroupEventListenerList();
                for (GroupEventListener groupEventListener : groupEventListeners) {
                    groupEventListener.onGroupMemberCountChanged(groupID);
                }
            }

            @Override
            public void onMemberInfoChanged(String groupID, List<V2TIMGroupMemberChangeInfo> v2TIMGroupMemberChangeInfoList) {
                super.onMemberInfoChanged(groupID, v2TIMGroupMemberChangeInfoList);
            }

            @Override
            public void onGroupCreated(String groupID) {
                super.onGroupCreated(groupID);
            }

            @Override
            public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.GROUP_ID, groupID);
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_GROUP, TUIConstants.TUIContact.EVENT_SUB_KEY_GROUP_DISMISS, param);
                ContactUtils.toastGroupEvent(ContactUtils.GROUP_EVENT_TIP_DISBANDED, groupID);
            }

            @Override
            public void onGroupRecycled(String groupID, V2TIMGroupMemberInfo opUser) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.GROUP_ID, groupID);
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_GROUP, TUIConstants.TUIContact.EVENT_SUB_KEY_GROUP_RECYCLE, param);
            }

            @Override
            public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
                List<GroupEventListener> groupEventListeners = getGroupEventListenerList();
                for (GroupEventListener groupEventListener : groupEventListeners) {
                    groupEventListener.onGroupInfoChanged(groupID);
                }

                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.GROUP_ID, groupID);
                for (V2TIMGroupChangeInfo changeInfo : changeInfos) {
                    if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME) {
                        param.put(TUIConstants.TUIContact.GROUP_NAME, changeInfo.getValue());
                    } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE_URL) {
                        param.put(TUIConstants.TUIContact.GROUP_FACE_URL, changeInfo.getValue());
                    } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER) {
                        param.put(TUIConstants.TUIContact.GROUP_OWNER, changeInfo.getValue());
                    } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION) {
                        param.put(TUIConstants.TUIContact.GROUP_NOTIFICATION, changeInfo.getValue());
                    } else if (changeInfo.getType() == V2TIMGroupChangeInfo.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION) {
                        param.put(TUIConstants.TUIContact.GROUP_INTRODUCTION, changeInfo.getValue());
                    } else {
                        return;
                    }
                }
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_GROUP, TUIConstants.TUIContact.EVENT_SUB_KEY_GROUP_INFO_CHANGED, param);
            }

            @Override
            public void onReceiveJoinApplication(String groupID, V2TIMGroupMemberInfo member, String opReason) {
                TUICore.notifyEvent(TUIConstants.TUIContact.Event.GroupApplication.KEY_GROUP_APPLICATION,
                        TUIConstants.TUIContact.Event.GroupApplication.SUB_KEY_GROUP_APPLICATION_NUM_CHANGED, null);
            }

            @Override
            public void onApplicationProcessed(String groupID, V2TIMGroupMemberInfo opUser, boolean isAgreeJoin, String opReason) {
                TUICore.notifyEvent(TUIConstants.TUIContact.Event.GroupApplication.KEY_GROUP_APPLICATION,
                        TUIConstants.TUIContact.Event.GroupApplication.SUB_KEY_GROUP_APPLICATION_NUM_CHANGED, null);
            }

            @Override
            public void onGrantAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                super.onGrantAdministrator(groupID, opUser, memberList);
            }

            @Override
            public void onRevokeAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
                super.onRevokeAdministrator(groupID, opUser, memberList);
            }

            @Override
            public void onQuitFromGroup(String groupID) {
                HashMap<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIContact.GROUP_ID, groupID);
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_GROUP, TUIConstants.TUIContact.EVENT_SUB_KEY_EXIT_GROUP, param);
            }

            @Override
            public void onReceiveRESTCustomData(String groupID, byte[] customData) {
                super.onReceiveRESTCustomData(groupID, customData);
            }

            @Override
            public void onGroupAttributeChanged(String groupID, Map<String, String> groupAttributeMap) {
                super.onGroupAttributeChanged(groupID, groupAttributeMap);
            }
        });
    }

    public List<ContactEventListener> getContactEventListenerList() {
        List<ContactEventListener> contactEventListeners = new ArrayList<>();
        Iterator<WeakReference<ContactEventListener>> iterator = contactEventListenerList.iterator();
        while (iterator.hasNext()) {
            WeakReference<ContactEventListener> weakReference = iterator.next();
            if (weakReference.get() == null) {
                iterator.remove();
                continue;
            }
            contactEventListeners.add(weakReference.get());
        }
        return contactEventListeners;
    }

    public void addContactEventListener(ContactEventListener contactEventListener) {
        WeakReference<ContactEventListener> reference = new WeakReference<>(contactEventListener);
        Iterator<WeakReference<ContactEventListener>> iterator = contactEventListenerList.iterator();
        while (iterator.hasNext()) {
            WeakReference<ContactEventListener> weakReference = iterator.next();
            if (weakReference.get() == null) {
                iterator.remove();
                continue;
            }
            if (weakReference.get() == contactEventListener) {
                return;
            }
        }
        contactEventListenerList.add(reference);
    }


    public void addGroupEventListener(GroupEventListener groupEventListener) {
        if (groupEventListener == null) {
            return;
        }
        for (WeakReference<GroupEventListener> listenerWeakReference : groupEventListenerList) {
            if (listenerWeakReference.get() == groupEventListener) {
                return;
            }
        }
        groupEventListenerList.add(new WeakReference<>(groupEventListener));
    }

    public List<GroupEventListener> getGroupEventListenerList() {
        List<GroupEventListener> listeners = new ArrayList<>();
        Iterator<WeakReference<GroupEventListener>> iterator = groupEventListenerList.listIterator();
        while (iterator.hasNext()) {
            WeakReference<GroupEventListener> listenerWeakReference = iterator.next();
            GroupEventListener listener = listenerWeakReference.get();
            if (listener == null) {
                iterator.remove();
            } else {
                listeners.add(listener);
            }
        }
        return listeners;
    }

    private void initTheme() {
        TUIThemeManager.addLightTheme(R.style.TUIContactLightTheme);
        TUIThemeManager.addLivelyTheme(R.style.TUIContactLivelyTheme);
        TUIThemeManager.addSeriousTheme(R.style.TUIContactSeriousTheme);
    }

    public static Context getAppContext() {
        return ServiceInitializer.getAppContext();
    }
}
