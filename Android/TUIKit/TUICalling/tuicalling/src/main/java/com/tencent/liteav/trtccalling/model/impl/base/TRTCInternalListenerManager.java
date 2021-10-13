package com.tencent.liteav.trtccalling.model.impl.base;

import com.tencent.liteav.trtccalling.model.TRTCCallingDelegate;
import com.tencent.trtc.TRTCCloudDef;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * 这个类用来保存所有的监听个回调
 */
public class TRTCInternalListenerManager implements TRTCCallingDelegate {
    private List<WeakReference<TRTCCallingDelegate>> mWeakReferenceList;

    public TRTCInternalListenerManager() {
        mWeakReferenceList = new ArrayList<>();
    }

    public void addDelegate(TRTCCallingDelegate listener) {
        WeakReference<TRTCCallingDelegate> listenerWeakReference = new WeakReference<>(listener);
        mWeakReferenceList.add(listenerWeakReference);
    }

    public void removeDelegate(TRTCCallingDelegate listener) {
        Iterator iterator = mWeakReferenceList.iterator();
        while (iterator.hasNext()) {
            WeakReference<TRTCCallingDelegate> reference = (WeakReference<TRTCCallingDelegate>) iterator.next();
            if (reference.get() == null) {
                iterator.remove();
                continue;
            }
            if (reference.get() == listener) {
                iterator.remove();
            }
        }
    }

    @Override
    public void onError(int code, String msg) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onError(code, msg);
            }
        }
    }

    @Override
    public void onInvited(String sponsor, List<String> userIdList, boolean isFromGroup, int callType) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onInvited(sponsor, userIdList, isFromGroup, callType);
            }
        }
    }

    @Override
    public void onGroupCallInviteeListUpdate(List<String> userIdList) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onGroupCallInviteeListUpdate(userIdList);
            }
        }
    }

    @Override
    public void onUserEnter(String userId) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onUserEnter(userId);
            }
        }
    }

    @Override
    public void onUserLeave(String userId) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onUserLeave(userId);
            }
        }
    }

    @Override
    public void onReject(String userId) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onReject(userId);
            }
        }
    }

    @Override
    public void onNoResp(String userId) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onNoResp(userId);
            }
        }
    }

    @Override
    public void onLineBusy(String userId) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onLineBusy(userId);
            }
        }
    }

    @Override
    public void onCallingCancel() {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onCallingCancel();
            }
        }
    }

    @Override
    public void onCallingTimeout() {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onCallingTimeout();
            }
        }
    }

    @Override
    public void onCallEnd() {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onCallEnd();
            }
        }
    }

    @Override
    public void onUserVideoAvailable(String userId, boolean isVideoAvailable) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onUserVideoAvailable(userId, isVideoAvailable);
            }
        }
    }

    @Override
    public void onUserAudioAvailable(String userId, boolean isVideoAvailable) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onUserAudioAvailable(userId, isVideoAvailable);
            }
        }
    }

    @Override
    public void onUserVoiceVolume(Map<String, Integer> volumeMap) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onUserVoiceVolume(volumeMap);
            }
        }
    }

    @Override
    public void onNetworkQuality(TRTCCloudDef.TRTCQuality localQuality, ArrayList<TRTCCloudDef.TRTCQuality> remoteQuality) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onNetworkQuality(localQuality, remoteQuality);
            }
        }
    }

    @Override
    public void onSwitchToAudio(boolean success, String message) {
        for (WeakReference<TRTCCallingDelegate> reference : mWeakReferenceList) {
            TRTCCallingDelegate listener = reference.get();
            if (listener != null) {
                listener.onSwitchToAudio(success, message);
            }
        }
    }
}
