package com.tencent.qcloud.tuikit.tuicontact;

import android.content.Context;

import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.tuicontact.bean.ContactItemBean;
import com.tencent.qcloud.tuikit.tuicontact.bean.FriendApplicationBean;
import com.tencent.qcloud.tuikit.tuicontact.interfaces.ContactEventListener;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class TUIContactService extends ServiceInitializer implements ITUIContactService {
    public static final String TAG = TUIContactService.class.getSimpleName();

    private static TUIContactService instance;

    public static TUIContactService getInstance() {
        return instance;
    }

    private final List<WeakReference<ContactEventListener>> contactEventListenerList = new ArrayList<>();

    @Override
    public void init(Context context) {
        instance = this;
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
                    contactEventListener.onFriendRemarkChanged(id ,remark);
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
                for(V2TIMFriendApplication v2TIMFriendApplication : applicationList) {
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
                for(V2TIMFriendInfo v2TIMFriendInfo : users) {
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
                TUICore.notifyEvent(TUIConstants.TUIContact.EVENT_FRIEND_STATE_CHANGED,
                        TUIConstants.TUIContact.EVENT_SUB_KEY_FRIEND_DELETE, bundle);
            }

            @Override
            public void onBlackListAdd(List<V2TIMFriendInfo> infoList) {
                List<ContactEventListener> contactEventListenerList = getInstance().getContactEventListenerList();
                List<ContactItemBean> contactItemBeanList = new ArrayList<>();
                for(V2TIMFriendInfo v2TIMFriendInfo : infoList) {
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
                for(V2TIMFriendInfo v2TIMFriendInfo : infoList) {
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
    }

    public List<ContactEventListener> getContactEventListenerList() {
        List<ContactEventListener> contactEventListeners = new ArrayList<>();
        Iterator<WeakReference<ContactEventListener>> iterator = contactEventListenerList.iterator();
        while(iterator.hasNext()) {
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
        while(iterator.hasNext()) {
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

    @Override
    public int getLightThemeResId() {
        return R.style.TUIContactLightTheme;
    }

    @Override
    public int getLivelyThemeResId() {
        return R.style.TUIContactLivelyTheme;
    }

    @Override
    public int getSeriousThemeResId() {
        return R.style.TUIContactSeriousTheme;
    }
}
