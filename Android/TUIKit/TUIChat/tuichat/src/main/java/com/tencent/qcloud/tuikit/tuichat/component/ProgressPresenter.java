package com.tencent.qcloud.tuikit.tuichat.component;

import android.text.TextUtils;
import android.util.Log;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

public class ProgressPresenter {
    private static final String TAG = ProgressPresenter.class.getSimpleName();

    private static final class ProgressPresenterHolder {
        private static final ProgressPresenter instance = new ProgressPresenter();
    }

    // 每调用 30 次接口清理一次
    private final int REMOVE_THRESHOLD = 30;

    private final Map<String, List<WeakReference<ProgressListener>>> progressListenerMap = new ConcurrentHashMap<>();

    private int removeCount = 0;

    public static ProgressPresenter getInstance() {
        return ProgressPresenterHolder.instance;
    }

    private ProgressPresenter() {}

    public void registerProgressListener(String progressId, ProgressListener listener) {
        Log.i(TAG, "registerProgressListener id : " + progressId + ", listener : " + listener);
        if (TextUtils.isEmpty(progressId) || listener == null) {
            return;
        }

        removeCount++;
        if (removeCount > REMOVE_THRESHOLD) {
            removeEmptyReference();
            removeCount = 0;
        }

        List<WeakReference<ProgressListener>> list = progressListenerMap.get(progressId);
        if (list == null) {
            list = new CopyOnWriteArrayList<>();
            progressListenerMap.put(progressId, list);
        }
        WeakReference<ProgressListener> weakReference = new WeakReference<>(listener);
        list.add(weakReference);
    }

    public void updateProgress(String progressId, int progress) {
        removeCount++;
        if (removeCount > REMOVE_THRESHOLD) {
            removeEmptyReference();
            removeCount = 0;
        }

        List<WeakReference<ProgressListener>> referenceList = progressListenerMap.get(progressId);
        if (referenceList != null) {
            for (WeakReference<ProgressListener> weakReference : referenceList) {
                ProgressListener listener = weakReference.get();
                if (listener != null) {
                    listener.onProgress(progress);
                }
            }
        }
    }

    private void removeEmptyReference() {
        Iterator<Map.Entry<String, List<WeakReference<ProgressListener>>>> iterator = progressListenerMap.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<String, List<WeakReference<ProgressListener>>> entry = iterator.next();
            List<WeakReference<ProgressListener>> listenerList = entry.getValue();
            if (listenerList == null) {
                iterator.remove();
            } else {
                List<WeakReference<ProgressListener>> deleteList = new ArrayList<>();
                for (WeakReference<ProgressListener> reference : listenerList) {
                    if (reference.get() == null) {
                        deleteList.add(reference);
                    }
                }
                listenerList.removeAll(deleteList);
            }
        }
    }

    public void unregisterProgressListener(String progressId, ProgressListener listener) {
        Log.i(TAG, "unregisterProgressListener id : " + progressId + ", listener : " + listener);
        if (TextUtils.isEmpty(progressId) || listener == null) {
            return;
        }

        List<WeakReference<ProgressListener>> list = progressListenerMap.get(progressId);
        if (list != null) {
            return;
        }
        WeakReference<ProgressListener> remove = null;
        for (WeakReference<ProgressListener> reference : list) {
            if (reference.get() == listener) {
                remove = reference;
                break;
            }
        }
        list.remove(remove);
    }

    public interface ProgressListener {
        /**
         * 进度更新
         * @param progress 当前进度 0-100
         */
        void onProgress(int progress);
    }
}
