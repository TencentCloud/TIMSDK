package com.tencent.cloud.tuikit.roomkit.model;

import com.tencent.cloud.tuikit.roomkit.ConferenceDefine;
import com.tencent.cloud.tuikit.roomkit.ConferenceSession;

import java.util.List;

public class ConferenceSessionImpl extends ConferenceSession {
    public boolean mIsEnableWaterMark = false;
    public String  mWaterMarkText     = "";

    public Class<?>   mContactsActivity;
    public List<ConferenceDefine.User> mParticipants;

    private static ConferenceSessionImpl     sInstance;
    private final  ConferenceObserverManager mConferenceObserverManager = new ConferenceObserverManager();

    public boolean isShowAISpeechToTextButton = false;

    private ConferenceSessionImpl() {}

    public static ConferenceSessionImpl sharedInstance() {
        if (sInstance == null) {
            synchronized (ConferenceSessionImpl.class) {
                if (sInstance == null) {
                    sInstance = new ConferenceSessionImpl();
                }
            }
        }
        return sInstance;
    }

    public static void destroySharedInstance() {
        synchronized (ConferenceSessionImpl.class) {
            if (sInstance != null) {
                sInstance.destroy();
                sInstance = null;
            }
        }
    }

    @Override
    public void addObserver(ConferenceDefine.ConferenceObserver observer) {
        mConferenceObserverManager.addObserver(observer);
    }

    @Override
    public void removeObserver(ConferenceDefine.ConferenceObserver observer) {
        mConferenceObserverManager.removeObserver(observer);
    }

    @Override
    public void enableWaterMark() {
        mIsEnableWaterMark = true;
    }

    @Override
    public void setWaterMarkText(String waterMarkText) {
        mWaterMarkText = waterMarkText;
    }

    @Override
    public void setContactsViewProvider(Class<?> contactsActivity) {
        mContactsActivity = contactsActivity;
    }

    @Override
    public void setParticipants(List<ConferenceDefine.User> participants) {
        mParticipants = participants;
    }

    private void destroy() {
        mConferenceObserverManager.destroy();
    }
}
